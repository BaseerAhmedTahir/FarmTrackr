import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:goat_tracker/services/base_service.dart';

class EmailService extends BaseService {
  Future<void> sendReport({
    required String recipientEmail,
    required String subject,
    required String body,
    required File attachment,
  }) async {
    final smtpServer = await _getSmtpServer();
    if (smtpServer == null) {
      throw Exception('SMTP server configuration not found');
    }

    final message = Message()
      ..from = Address(await _getSenderEmail())
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body
      ..attachments = [
        FileAttachment(attachment)
          ..location = Location.attachment
          ..fileName = attachment.path.split('/').last
      ];

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Failed to send email: ${e.toString()}');
    }
  }

  Future<SmtpServer?> _getSmtpServer() async {
    try {
      final smtpSettings = await supabase
          .from('email_settings')
          .select()
          .single();

      return SmtpServer(
        smtpSettings['host'] as String,
        port: (smtpSettings['port'] as num).toInt(),
        username: smtpSettings['username'] as String,
        password: smtpSettings['password'] as String,
        ssl: smtpSettings['use_ssl'] as bool? ?? true,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String> _getSenderEmail() async {
    final settings = await supabase
        .from('email_settings')
        .select('sender_email')
        .single();
    
    return settings['sender_email'] as String;
  }
}
