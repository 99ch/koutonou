import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/services/auth_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final authService = AuthService();

  // Test login
  try {
    final userData = await authService.login(
      'test@example.com',
      'password123',
    );
    print('Login successful: $userData');
  } catch (e) {
    print('Login error: $e');
  }

  // Test signup
  try {
    final userData = await authService.signup({
      'email': 'newuser@example.com',
      'passwd': 'password123',
      'firstname': 'John',
      'lastname': 'Doe',
    });
    print('Signup successful: $userData');
  } catch (e) {
    print('Signup error: $e');
  }

  // Test invalid email
  try {
    await authService.login('invalid_email', 'password123');
  } catch (e) {
    print('Invalid email error: $e'); // Should print: "Invalid email format"
  }

  // Test logout
  try {
    await authService.logout();
    final userData = await authService.getUserData();
    print('User data after logout: $userData'); // Should print: null
  } catch (e) {
    print('Logout error: $e');
  }
}