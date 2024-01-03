// Login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// Register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// Generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

// // Register
// } on WeakPasswordAuthException {
//   await showErrorDialog(
//     context,
//     'Weak Password',
//   );
// } on EmailAlreadyInUseAuthException {
//   await showErrorDialog(
//     context,
//     'Email is already in use',
//   );
// } on InvalidEmailAuthException {
//   await showErrorDialog(
//     context,
//     'Invalid email',
//   );
// } on GenericAuthException {
//   await showErrorDialog(
//     context,
//     'Failed to register',
//   );
// }

// // Login
// } on UserNotFoundAuthException {
//   await showErrorDialog(
//     context,
//     'User not found',
//   );
// } on WrongPasswordAuthException {
//   await showErrorDialog(
//     context,
//     'Wrong password',
//   );
// } on GenericAuthException {
//   await showErrorDialog(
//     context,
//     'Authentication Error',
//   );
// }