import 'package:flutter/foundation.dart';
import '../models/usuario_model.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  RolUsuario? get userRole => _currentUser?.rol;
  bool get isSuperadmin => _currentUser?.esSuperadmin ?? false;
  bool get isDueno => _currentUser?.esDueno ?? false;
  bool get isEmpleado => _currentUser?.esEmpleado ?? false;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((event) {
      if (event.session == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        loadCurrentUser();
      }
    });
  }

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email: email, password: password);
      await loadCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    String? telefono,
    RolUsuario rol = RolUsuario.empleado,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        rol: rol,
      );
      await loadCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.signInWithGoogle();
      if (success) {
        await loadCurrentUser();
      }
      return success;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Credenciales incorrectas';
    } else if (error.contains('Email not confirmed')) {
      return 'Por favor, confirma tu email';
    } else if (error.contains('User already registered')) {
      return 'El usuario ya está registrado';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return 'Error de autenticación: $error';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
