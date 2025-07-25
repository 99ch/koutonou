import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/providers/auth_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final authProvider = AuthProvider();

  /// Test initialization
  await authProvider.initialize();
  print('Is Logged In: ${authProvider.isLoggedIn}'); /// Should print: false (or true if user data exists)
  print('User Data: ${authProvider.userData}'); /// Should print: null (or user data)

  /// Test login
  try {
    await authProvider.login('test@example.com', 'password123');
    print('Login successful: ${authProvider.isLoggedIn}');
    print('User Data: ${authProvider.userData}');
  } catch (e) {
    print('Login error: ${authProvider.errorMessage}');
  }

  /// Test signup
  try {
    await authProvider.signup({
      'email': 'newuser@example.com',
      'passwd': 'password123',
      'firstname': 'John',
      'lastname': 'Doe',
    });
    print('Signup successful: ${authProvider.isLoggedIn}');
    print('User Data: ${authProvider.userData}');
  } catch (e) {
    print('Signup error: ${authProvider.errorMessage}');
  }

  /// Test logout
  try {
    await authProvider.logout();
    print('Logout successful: ${authProvider.isLoggedIn}'); /// Should print: false
    print('User Data: ${authProvider.userData}'); /// Should print: null
  } catch (e) {
    print('Logout error: ${authProvider.errorMessage}');
  }
}