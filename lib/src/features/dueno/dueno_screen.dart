import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  List<Usuario> _empleadosSinAsignar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final duenoId = authProvider.currentUser?.id;
    
    final todosUsuarios = await _userService.getAllUsers();
    
    if (mounted) {
      setState(() {
        // Filtrar solo empleados de este dueño
        _empleados = todosUsuarios.where((u) => 
          u.esEmpleado && u.duenoId == duenoId
        ).toList();
        
        // Filtrar empleados sin dueño asignado
        _empleadosSinAsignar = todosUsuarios.where((u) => 
          u.esEmpleado && u.duenoId == null
        ).toList();
        
        _isLoading = false;
      });
    }
  }

  Future<void> _asignarEmpleado(Usuario empleado) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final duenoId = authProvider.currentUser?.id;
      
      if (duenoId == null) return;
      
      // Actualizar directamente en Supabase
      await Supabase.instance.client
          .from('usuarios')
          .update({
            'dueno_id': duenoId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', empleado.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${empleado.nombreCompleto} añadido a tu equipo')),
        );
        _cargarEmpleados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar empleado: $e'), backgroundColor: Colors.red),
        );
      }
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
      final authProvider = context.read<AuthProvider>();
      final file = await _exportService.exportarVentas(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
        duenoId: authProvider.duenoId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ventas exportadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
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
      final authProvider = context.read<AuthProvider>();
      final file = await _exportService.exportarGastos(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
        duenoId: authProvider.duenoId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Gastos exportados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
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
      final authProvider = context.read<AuthProvider>();
      final file = await _exportService.exportarProductos(
        duenoId: authProvider.duenoId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Productos exportados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
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
      final authProvider = context.read<AuthProvider>();
      final file = await _exportService.exportarInformeCompleto(
        desde: DateTime.now().subtract(const Duration(days: 30)),
        hasta: DateTime.now(),
        duenoId: authProvider.duenoId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Informe completo exportado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
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
                  // Sección de Empleados (PRIMERO)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestión de Empleados',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargarEmpleados,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra a tus empleados: activa, desactiva o elimina usuarios',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_empleados.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay empleados registrados',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
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
                                            color: empleado.activo ? Colors.orange : Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(empleado.activo ? 'Desactivar' : 'Activar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'eliminar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
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
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Sección de Empleados Sin Asignar (SIEMPRE VISIBLE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Empleados Disponibles',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      if (_empleadosSinAsignar.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_empleadosSinAsignar.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empleados sin tienda asignada que puedes añadir a tu equipo',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_empleadosSinAsignar.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.person_add_disabled, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay empleados disponibles',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Todos los empleados ya están asignados a una tienda',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _empleadosSinAsignar.length,
                      itemBuilder: (context, index) {
                        final empleado = _empleadosSinAsignar[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue.withOpacity(0.2), width: 1),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withOpacity(0.05),
                                  Colors.blue.withOpacity(0.02),
                                ],
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.withOpacity(0.2),
                                child: Text(
                                  empleado.nombre[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                empleado.nombreCompleto,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(empleado.email, style: const TextStyle(fontSize: 12)),
                                  if (empleado.telefono != null)
                                    Text('Tel: ${empleado.telefono}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: ElevatedButton.icon(
                                onPressed: () => _asignarEmpleado(empleado),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Añadir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Sección de Exportación
                  const Text(
                    'Exportar Datos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exporta ventas, gastos, productos e informes completos a Excel',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildExportCard(
                        'Ventas',
                        Icons.trending_up,
                        Colors.green,
                        _exportarVentas,
                      ),
                      _buildExportCard(
                        'Gastos',
                        Icons.trending_down,
                        Colors.red,
                        _exportarGastos,
                      ),
                      _buildExportCard(
                        'Productos',
                        Icons.inventory_2_outlined,
                        Colors.blue,
                        _exportarProductos,
                      ),
                      _buildExportCard(
                        'Informe',
                        Icons.assessment_outlined,
                        Colors.purple,
                        _exportarInformeCompleto,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildExportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.download_outlined, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
