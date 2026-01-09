import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

/// Authentication service using Firebase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();

  // Store OTPs temporarily (in production, use Firebase Firestore or Redis)
  final Map<String, OTPData> _otpStorage = {};

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Generate 6-digit OTP
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Sign up with email and password (with OTP verification)
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if email already exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return {
          'success': false,
          'message': 'Email already registered. Please login instead.',
        };
      }

      // Generate OTP
      final otp = _generateOTP();
      final otpExpiry = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP data
      _otpStorage[email] = OTPData(
        otp: otp,
        expiry: otpExpiry,
        email: email,
        password: password,
        name: name,
      );

      // Send OTP email
      print('📧 Attempting to send OTP email to: $email');
      final emailSent = await _emailService.sendOTPEmail(
        toEmail: email,
        otp: otp,
        userName: name,
      );

      if (!emailSent) {
        print('❌ Failed to send OTP email');
        // Still allow signup to proceed, but inform user
        return {
          'success': true,
          'message': 'OTP generated. Check console for OTP (Email service may not be configured). OTP: $otp',
          'requiresOTP': true,
        };
      }

      print('✅ OTP email sent successfully');
      return {
        'success': true,
        'message': 'OTP sent to your email. Please check your inbox and verify to complete registration.',
        'requiresOTP': true,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Verify OTP and complete registration
  Future<Map<String, dynamic>> verifyOTPAndRegister({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔍 Verifying OTP for email: $email');
      print('🔍 Entered OTP: $otp');
      
      // Check if OTP exists
      if (!_otpStorage.containsKey(email)) {
        print('❌ No OTP found in storage for email: $email');
        return {
          'success': false,
          'message': 'OTP expired or invalid. Please request a new one.',
        };
      }

      final otpData = _otpStorage[email]!;
      print('✅ OTP found in storage');
      print('🔍 Stored OTP: ${otpData.otp}');
      print('🔍 OTP expiry: ${otpData.expiry}');

      // Check if OTP is expired
      if (DateTime.now().isAfter(otpData.expiry)) {
        print('❌ OTP has expired');
        _otpStorage.remove(email);
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Verify OTP
      if (otpData.otp != otp) {
        print('❌ OTP mismatch! Expected: ${otpData.otp}, Got: $otp');
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }

      print('✅ OTP verified successfully!');
      print('📝 Creating user account...');

      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: otpData.email,
        password: otpData.password,
      );

      print('✅ User account created: ${userCredential.user!.uid}');

      // Update user profile
      await userCredential.user?.updateDisplayName(otpData.name);
      print('✅ User profile updated');

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': otpData.email,
        'name': otpData.name,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': true,
      });

      print('✅ User data stored in Firestore');

      // Remove OTP from storage
      _otpStorage.remove(email);
      print('✅ OTP removed from storage');

      // Send welcome email
      print('📧 Sending welcome email...');
      await _emailService.sendWelcomeEmail(
        toEmail: otpData.email,
        userName: otpData.name,
      );

      print('🎉 Registration completed successfully!');

      return {
        'success': true,
        'message': 'Registration successful! Welcome to COMSATS GPT.',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      if (!_otpStorage.containsKey(email)) {
        return {
          'success': false,
          'message': 'No pending registration found. Please sign up again.',
        };
      }

      final oldData = _otpStorage[email]!;
      final newOTP = _generateOTP();
      final otpExpiry = DateTime.now().add(const Duration(minutes: 10));

      // Update OTP
      _otpStorage[email] = OTPData(
        otp: newOTP,
        expiry: otpExpiry,
        email: oldData.email,
        password: oldData.password,
        name: oldData.name,
      );

      // Send new OTP
      final emailSent = await _emailService.sendOTPEmail(
        toEmail: email,
        otp: newOTP,
        userName: oldData.name,
      );

      if (!emailSent) {
        return {
          'success': false,
          'message': 'Failed to send OTP. Please try again.',
        };
      }

      return {
        'success': true,
        'message': 'New OTP sent to your email.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to resend OTP. Please try again.',
      };
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'message': 'Login successful!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoURL != null) updates['photoURL'] = photoURL;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(updates);

      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Get error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// OTP Data model
class OTPData {
  final String otp;
  final DateTime expiry;
  final String email;
  final String password;
  final String name;

  OTPData({
    required this.otp,
    required this.expiry,
    required this.email,
    required this.password,
    required this.name,
  });
}
