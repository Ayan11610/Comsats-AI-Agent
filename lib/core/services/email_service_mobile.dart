import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'email_service_interface.dart';

/// Mobile implementation of email service using SMTP
class EmailServiceMobile implements EmailServiceInterface {
  final String _mailHost = dotenv.env['MAIL_HOST'] ?? 'smtp.gmail.com';
  final String _mailPort = dotenv.env['MAIL_PORT'] ?? '587';
  final String _mailUsername = dotenv.env['MAIL_USERNAME'] ?? '';
  final String _mailPassword = dotenv.env['MAIL_PASSWORD'] ?? '';
  final String _mailFromAddress = dotenv.env['MAIL_FROM_ADDRESS'] ?? '';
  final String _mailFromName = dotenv.env['MAIL_FROM_NAME'] ?? 'COMSATS GPT';

  @override
  Future<bool> sendOTPEmail({
    required String toEmail,
    required String otp,
    required String userName,
  }) async {
    try {
      // Check if email credentials are configured
      if (_mailUsername.isEmpty || _mailPassword.isEmpty) {
        print('❌ Email credentials not configured in .env file');
        print('OTP for $toEmail: $otp (shown in terminal because email is not configured)');
        return false;
      }

      final emailBody = _getOTPEmailBody(userName, otp);

      // Configure SMTP server
      final smtpServer = SmtpServer(
        _mailHost,
        port: int.parse(_mailPort),
        username: _mailUsername,
        password: _mailPassword,
        ssl: false,
        allowInsecure: true,
      );

      // Create the email message
      final message = Message()
        ..from = Address(_mailFromAddress, _mailFromName)
        ..recipients.add(toEmail)
        ..subject = 'COMSATS GPT - Email Verification Code'
        ..html = emailBody;

      // Send the email
      print('📧 Sending OTP email to $toEmail...');
      final sendReport = await send(message, smtpServer);
      print('✅ OTP email sent successfully to $toEmail');
      print('Message ID: ${sendReport.toString()}');
      
      return true;
    } catch (e) {
      print('Error sending OTP email: $e');
      return false;
    }
  }

  @override
  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    try {
      // Check if email credentials are configured
      if (_mailUsername.isEmpty || _mailPassword.isEmpty) {
        print('❌ Email credentials not configured in .env file');
        print('Welcome email would be sent to $toEmail (skipped because email is not configured)');
        return false;
      }

      final emailBody = _getWelcomeEmailBody(userName);

      // Configure SMTP server
      final smtpServer = SmtpServer(
        _mailHost,
        port: int.parse(_mailPort),
        username: _mailUsername,
        password: _mailPassword,
        ssl: false,
        allowInsecure: true,
      );

      // Create the email message
      final message = Message()
        ..from = Address(_mailFromAddress, _mailFromName)
        ..recipients.add(toEmail)
        ..subject = 'Welcome to COMSATS GPT! 🎉'
        ..html = emailBody;

      // Send the email
      print('📧 Sending welcome email to $toEmail...');
      final sendReport = await send(message, smtpServer);
      print('✅ Welcome email sent successfully to $toEmail');
      
      return true;
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  String _getOTPEmailBody(String userName, String otp) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .otp-box { background: white; border: 2px dashed #667eea; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px; }
        .otp-code { font-size: 32px; font-weight: bold; color: #667eea; letter-spacing: 5px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>COMSATS GPT</h1>
            <p>Email Verification</p>
        </div>
        <div class="content">
            <h2>Hello $userName!</h2>
            <p>Thank you for signing up with COMSATS GPT. To complete your registration, please use the following One-Time Password (OTP):</p>
            
            <div class="otp-box">
                <p style="margin: 0; color: #666;">Your OTP Code:</p>
                <div class="otp-code">$otp</div>
            </div>
            
            <p><strong>Important:</strong></p>
            <ul>
                <li>This OTP is valid for 10 minutes</li>
                <li>Do not share this code with anyone</li>
                <li>If you didn't request this code, please ignore this email</li>
            </ul>
            
            <p>Best regards,<br>COMSATS GPT Team</p>
        </div>
        <div class="footer">
            <p>This is an automated email. Please do not reply to this message.</p>
            <p>&copy; 2026 COMSATS GPT. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  String _getWelcomeEmailBody(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; padding: 12px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to COMSATS GPT! 🎉</h1>
        </div>
        <div class="content">
            <h2>Hello $userName!</h2>
            <p>Your account has been successfully created. Welcome to COMSATS GPT - your AI-powered assistant for COMSATS University.</p>
            
            <p><strong>What you can do with COMSATS GPT:</strong></p>
            <ul>
                <li>Get instant answers about COMSATS University</li>
                <li>Learn about admissions, academics, and campus life</li>
                <li>Explore scholarships and career opportunities</li>
                <li>Access information about student societies and activities</li>
            </ul>
            
            <p>Start chatting with your AI assistant now and discover everything COMSATS has to offer!</p>
            
            <p>Best regards,<br>COMSATS GPT Team</p>
        </div>
    </div>
</body>
</html>
''';
  }
}
