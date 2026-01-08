/// Interface for email service implementations
abstract class EmailServiceInterface {
  Future<bool> sendOTPEmail({
    required String toEmail,
    required String otp,
    required String userName,
  });

  Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
  });
}
