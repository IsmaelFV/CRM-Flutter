import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../shared/models/usuario_model.dart';
import '../../shared/providers/auth_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    final usuarios = await _userService.getAllUsers();
    if (mounted) {
      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    }
  }

  Future<void> _cambiarRol(Usuario usuario) async {
    final nuevoRol = await showDialog<RolUsuario>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Seleccionar nuevo rol'),
        children: RolUsuario.values.map((rol) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, rol),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                rol.displayName,
                style: TextStyle(
                  fontWeight: rol == usuario.rol ? FontWeight.bold : FontWeight.normal,
                  color: rol == usuario.rol ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (nuevoRol != null && nuevoRol != usuario.rol) {
      final success = await _userService.updateUserRole(usuario.id, nuevoRol);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rol actualizado correctamente')),
          );
          _cargarUsuarios();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el rol'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _toggleEstado(Usuario usuario) async {
    final nuevoEstado = !usuario.activo;
    final success = await _userService.toggleUserStatus(usuario.id, nuevoEstado);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario ${nuevoEstado ? 'activado' : 'desactivado'}')),
        );
        _cargarUsuarios();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar estado'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    // Confirmar eliminación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${usuario.nombreCompleto}?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await _userService.deleteUser(usuario.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado correctamente')),
          );
          _cargarUsuarios();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar usuario'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Color _getRoleColor(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.superadmin:
        return Colors.purple;
      case RolUsuario.dueno:
        return Colors.blue;
      case RolUsuario.empleado:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarUsuarios,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios registrados'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _usuarios.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleColor(usuario.rol).withOpacity(0.2),
                          child: Text(
                            usuario.nombre.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(usuario.rol),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(usuario.nombreCompleto),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usuario.email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(usuario.rol).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _getRoleColor(usuario.rol).withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    usuario.rol.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getRoleColor(usuario.rol),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!usuario.activo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                                    ),
                                    child: const Text(
                                      'INACTIVO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final currentUser = authProvider.currentUser;
                            final canDelete = currentUser != null && (
                              currentUser.esSuperadmin || 
                              (currentUser.esDueno && usuario.esEmpleado)
                            );
                            
                            return PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'rol') {
                                  _cambiarRol(usuario);
                                } else if (value == 'estado') {
                                  _toggleEstado(usuario);
                                } else if (value == 'eliminar') {
                                  _eliminarUsuario(usuario);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'rol',
                                  child: Row(
                                    children: [
                                      Icon(Icons.admin_panel_settings, size: 20),
                                      SizedBox(width: 8),
                                      Text('Cambiar Rol'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'estado',
                                  child: Row(
                                    children: [
                                      Icon(
                                        usuario.activo ? Icons.block : Icons.check_circle, 
                                        size: 20,
                                        color: usuario.activo ? Colors.red : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(usuario.activo ? 'Desactivar Usuario' : 'Activar Usuario'),
                                    ],
                                  ),
                                ),
                                if (canDelete) ...[
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'eliminar',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_forever, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Eliminar Usuario', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
