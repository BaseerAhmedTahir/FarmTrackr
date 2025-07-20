import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { PDFDocument, StandardFonts } from "https://esm.sh/pdf-lib@1.17.1";
import dayjs from "https://esm.sh/dayjs@1.11.9";

serve(async (_req) => {
  const supa = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_KEY")!
  );

  // Get financial data
  const { data: finances } = await supa.from("v_goat_financials").select();
  const { data: weights } = await supa.from("weight_logs")
    .select("goat_id, weight_kg, recorded_at")
    .gte("recorded_at", dayjs().subtract(1, "month").toISOString());

  // Create PDF
  const pdf = await PDFDocument.create();
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const page = pdf.addPage([595, 842]); // A4
  let y = 800;

  // Title
  page.drawText(`Goat Finance Summary – ${dayjs().format("MMM YYYY")}`, {
    x: 40,
    y,
    size: 18,
    font,
  });
  y -= 40;

  // Financial summary
  let totalInvested = 0;
  let totalSales = 0;
  let totalProfit = 0;

  finances.forEach((r: any) => {
    totalInvested += r.purchase_price;
    totalSales += r.sale_price ?? 0;
    totalProfit += r.net_profit;

    const line = `${r.tag_id} - Buy:₹${r.purchase_price} | Expense:₹${r.total_expense} | Sale:${
      r.sale_price ? `₹${r.sale_price}` : "Not sold"
    } | Profit:₹${r.net_profit}`;
    
    page.drawText(line, { x: 40, y, size: 10, font });
    y -= 14;
  });

  y -= 20;
  page.drawText("Summary:", { x: 40, y, size: 14, font });
  y -= 20;
  page.drawText(`Total Invested: ₹${totalInvested}`, { x: 40, y, size: 12, font });
  y -= 16;
  page.drawText(`Total Sales: ₹${totalSales}`, { x: 40, y, size: 12, font });
  y -= 16;
  page.drawText(`Net Profit: ₹${totalProfit}`, { x: 40, y, size: 12, font });

  // Weight changes section if any
  if (weights.length > 0) {
    y -= 30;
    page.drawText("Recent Weight Changes:", { x: 40, y, size: 14, font });
    y -= 20;

    weights.forEach((w: any) => {
      const line = `${w.goat_id} - ${w.weight_kg}kg on ${dayjs(w.recorded_at).format(
        "DD MMM YYYY"
      )}`;
      page.drawText(line, { x: 40, y, size: 10, font });
      y -= 14;
    });
  }

  // Convert to base64
  const pdfBytes = await pdf.save();
  const base64 = btoa(String.fromCharCode(...pdfBytes));

  // Send email
  await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${Deno.env.get("RESEND_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "Goat Tracker <noreply@goattracker.com>",
      to: [Deno.env.get("REPORT_EMAIL")!],
      subject: `Monthly Goat Report - ${dayjs().format("MMM YYYY")}`,
      html: `<p>Please find attached the monthly goat farm report.</p>
            <p>Summary:</p>
            <ul>
              <li>Total Invested: ₹${totalInvested}</li>
              <li>Total Sales: ₹${totalSales}</li>
              <li>Net Profit: ₹${totalProfit}</li>
            </ul>
            <p>Details in the attached PDF.</p>`,
      attachments: [
        {
          filename: `goat_report_${dayjs().format("YYYY_MM")}.pdf`,
          content: base64,
          type: "application/pdf",
        },
      ],
    }),
  });

  return new Response("Report sent successfully", { status: 200 });
});
