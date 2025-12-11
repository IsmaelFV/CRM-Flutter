import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/user_service.dart';
import '../../services/export_service.dart';
import '../../shared/models/usuario_model.dart';
import '../../shared/providers/auth_provider.dart';

class DuenoScreen extends StatefulWidget {
  const DuenoScreen({super.key});

  @override
  State<DuenoScreen> createState() => _DuenoScreenState();
}

class _DuenoScreenState extends State<DuenoScreen> {
  final UserService _userService = UserService();
  final ExportService _exportService = ExportService();
  List<Usuario> _empleados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() => _isLoading = true);
    final todosUsuarios = await _userService.getAllUsers();
    if (mounted) {
      setState(() {
        // Filtrar solo empleados
        _empleados = todosUsuarios.where((u) => u.esEmpleado).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleEstado(Usuario empleado) async {
    final nuevoEstado = !empleado.activo;
    final success = await _userService.toggleUserStatus(empleado.id, nuevoEstado);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado ${nuevoEstado ? 'activado' : 'desactivado'}')),
        );
        _cargarEmpleados();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar estado'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarEmpleado(Usuario empleado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${empleado.nombreCompleto}?\n\nEsta acción no se puede deshacer.'),
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
      final success = await _userService.deleteUser(empleado.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empleado eliminado correctamente')),
          );
          _cargarEmpleados();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al eliminar empleado'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _exportarVentas() async {
    try {
      final file = await _exportService.exportarVentas(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
      );
      if (mounted) {
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ventas exportadas: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay ventas para exportar'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportarGastos() async {
    try {
      final file = await _exportService.exportarGastos(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
      );
      if (mounted) {
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gastos exportados: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay gastos para exportar'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportarProductos() async {
    try {
      final file = await _exportService.exportarProductos();
      if (mounted) {
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Productos exportados: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay productos para exportar'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportarInformeCompleto() async {
    try {
      final file = await _exportService.exportarInformeCompleto(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
      );
      if (mounted) {
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Informe completo exportado: ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay datos para exportar'), backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Dueño'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Exportación
                  const Text(
                    'Exportar Datos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildExportCard(
                        'Ventas',
                        Icons.point_of_sale,
                        Colors.green,
                        _exportarVentas,
                      ),
                      _buildExportCard(
                        'Gastos',
                        Icons.money_off,
                        Colors.red,
                        _exportarGastos,
                      ),
                      _buildExportCard(
                        'Productos',
                        Icons.inventory,
                        Colors.blue,
                        _exportarProductos,
                      ),
                      _buildExportCard(
                        'Informe Completo',
                        Icons.description,
                        Colors.purple,
                        _exportarInformeCompleto,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Sección de Empleados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestión de Empleados',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargarEmpleados,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_empleados.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No hay empleados registrados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _empleados.length,
                      itemBuilder: (context, index) {
                        final empleado = _empleados[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: empleado.activo ? Colors.green : Colors.red,
                              child: Text(
                                empleado.nombre[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(empleado.nombreCompleto),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(empleado.email),
                                if (empleado.telefono != null)
                                  Text('Tel: ${empleado.telefono}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!empleado.activo)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'estado') {
                                      _toggleEstado(empleado);
                                    } else if (value == 'eliminar') {
                                      _eliminarEmpleado(empleado);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'estado',
                                      child: Row(
                                        children: [
                                          Icon(
                                            empleado.activo ? Icons.block : Icons.check_circle,
                                            size: 20,
                                            color: empleado.activo ? Colors.red : Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(empleado.activo ? 'Desactivar' : 'Activar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_forever, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildExportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
