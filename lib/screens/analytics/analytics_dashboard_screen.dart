import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/models/financial_summary.dart';
import 'package:goat_tracker/services/report_service.dart';
import 'package:goat_tracker/widgets/app_bar.dart';
import 'package:goat_tracker/widgets/chart_card.dart';
import 'package:goat_tracker/providers.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final analytics = await ref.read(reportServiceProvider).getAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      );

      final trends = await ref.read(reportServiceProvider).getMonthlyTrends();
      final breedPerformance = await ref.read(reportServiceProvider).getBreedPerformance();
      final caretakerPerformance = await ref.read(reportServiceProvider).getCaretakerPerformance();

      // TODO: Update UI with analytics data
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading analytics: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analytics',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                final email = await ref.read(settingsServiceProvider).getReportEmail();
                if (email == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please configure email settings first'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final report = await ref.read(reportServiceProvider).generateMonthlyReport(
                  recipientEmail: email,
                  startDate: _startDate,
                  endDate: _endDate,
                );

                if (!mounted) return;
                Navigator.pushNamed(
                  context,
                  '/pdf-viewer',
                  arguments: {
                    'file': report,
                    'title': 'Farm Report',
                  },
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error generating report: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${DateFormat.yMMMd().format(_startDate)} - ${DateFormat.yMMMd().format(_endDate)}',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // TODO: Add analytics charts and data visualization
                  ],
                ),
              ),
            ),
    );
  }
}
