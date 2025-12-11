import 'package:flutter/foundation.dart';
import '../models/usuario_model.dart';
import '../models/tienda_model.dart';
import '../../services/auth_service.dart';
import '../../services/tienda_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final TiendaService _tiendaService = TiendaService();
  
  Usuario? _currentUser;
  Tienda? _tiendaActual;
  String? _tiendaSeleccionadaId; // Para superadmin: ID de tienda seleccionada para filtrar
  bool _isLoading = false;
  String? _errorMessage;

  Usuario? get currentUser => _currentUser;
  Tienda? get tiendaActual => _tiendaActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  // LÓGICA DE ROLES
  // ==============================================================================
  // Propiedades que indican el rol del usuario actual
  RolUsuario? get userRole => _currentUser?.rol;
  bool get isSuperadmin => _currentUser?.esSuperadmin ?? false;
  bool get isDueno => _currentUser?.esDueno ?? false;
  bool get isEmpleado => _currentUser?.esEmpleado ?? false;
  
  // Getter inteligente para filtrar datos:
  // 1. Si es DUEÑO/EMPLEADO: Devuelve su propio ID (solo ven su tienda).
  // 2. Si es SUPERADMIN: Devuelve la tienda seleccionada o null (todas).
  // Esta propiedad se usa en todos los servicios para filtrar las consultas SQL.
  String? get duenoId {
    if (_currentUser == null) return null;
    if (_currentUser!.esDueno) return _currentUser!.id;
    if (_currentUser!.esEmpleado) return _currentUser!.duenoId;
    return null; // Superadmin
  }
  
  // LÓGICA MULTI-TIENDA PARA SUPERADMIN
  // ==============================================================================
  // Variable que almacena la tienda que el Superadmin está "observando".
  // Si es null, el Superadmin ve los datos globales de todas las tiendas.
  String? get tiendaSeleccionadaId => _tiendaSeleccionadaId;
  
  // Cambiar tienda seleccionada (solo para superadmin)
  Future<void> seleccionarTienda(String? tiendaId) async {
    if (_currentUser?.esSuperadmin != true) return;
    
    _tiendaSeleccionadaId = tiendaId;
    
    // Si se selecciona una tienda, cargar sus datos
    if (tiendaId != null) {
      _tiendaActual = await _tiendaService.getAllTiendas()
          .then((tiendas) => tiendas.firstWhere((t) => t.id == tiendaId));
    } else {
      _tiendaActual = null;
    }
    
    notifyListeners();
  }

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      
      // Cargar tienda si el usuario está autenticado
      if (_currentUser != null && !_currentUser!.esSuperadmin) {
        _tiendaActual = await _tiendaService.getTiendaActual(_currentUser!.id);
      }
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
      
      // Verificar si el usuario está inactivo
      if (_currentUser != null && !_currentUser!.activo) {
        _errorMessage = 'Tu cuenta ha sido desactivada. Contacta con el administrador.';
        await _authService.signOut();
        _currentUser = null;
        _tiendaActual = null;
        notifyListeners();
        return;
      }
      
      // Cargar tienda si el usuario está autenticado y no es superadmin
      if (_currentUser != null && !_currentUser!.esSuperadmin) {
        _tiendaActual = await _tiendaService.getTiendaActual(_currentUser!.id);
      }
      
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
      _tiendaActual = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally{
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
