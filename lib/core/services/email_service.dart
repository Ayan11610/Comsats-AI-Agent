import 'email_service_interface.dart';
// Conditional imports for platform-specific implementations
import 'email_service_mobile.dart' if (dart.library.html) 'email_service_web.dart';

/// Service for sending emails (OTP verification)
/// Automatically uses the correct implementation based on platform:
/// - Mobile/Desktop: Uses SMTP via mailer package
/// - Web: Uses HTTP-based fallback (logs OTP to console)
class EmailService implements EmailServiceInterface {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Platform-specific implementation
  final EmailServiceInterface _implementation = _createImplementation();

  static EmailServiceInterface _createImplementation() {
    // This will automatically use EmailServiceMobile on mobile/desktop
    // and EmailServiceWeb on web platforms
    return EmailServiceMobile();
  }

  @override
  Future<bool> sendOTPEmail({
    required String toEmail,
    required String otp,
    required String userName,
  }) async {
    return _implementation.sendOTPEmail(
      toEmail: toEmail,
      otp: otp,
      userName: userName,
    );
  }

  @override
  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  }) async {
    return _implementation.sendWelcomeEmail(
      toEmail: toEmail,
      userName: userName,
    );
  }
}
