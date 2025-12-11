import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/export_service.dart';
import '../../shared/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'user_management_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;

  Future<void> _exportarVentas() async {
    setState(() => _isExporting = true);
    
    final authProvider = context.read<AuthProvider>();
    final duenoId = authProvider.tiendaActual?.duenoId; // null = todas las tiendas
    
    final file = await _exportService.exportarVentas(duenoId: duenoId);
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Ventas exportadas correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _exportarGastos() async {
    setState(() => _isExporting = true);
    
    final authProvider = context.read<AuthProvider>();
    final duenoId = authProvider.tiendaActual?.duenoId; // null = todas las tiendas
    
    final file = await _exportService.exportarGastos(duenoId: duenoId);
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Gastos exportados correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _exportarProductos() async {
    setState(() => _isExporting = true);
    
    final authProvider = context.read<AuthProvider>();
    final duenoId = authProvider.tiendaActual?.duenoId; // null = todas las tiendas
    
    final file = await _exportService.exportarProductos(duenoId: duenoId);
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Productos exportados correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _exportarInformeCompleto() async {
    setState(() => _isExporting = true);
    
    final authProvider = context.read<AuthProvider>();
    final duenoId = authProvider.tiendaActual?.duenoId; // null = todas las tiendas
    
    final file = await _exportService.exportarInformeCompleto(duenoId: duenoId);
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Informe completo exportado correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Título
          Text(
            'Panel de Administración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestión y exportación de datos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección de exportación
          Text(
            'Exportar Datos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isExporting)
            Card(
              elevation: 0,
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 16),
                    Text('Exportando...', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            )
          else
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
          
          const SizedBox(height: 32),
          
          // Sección de gestión de usuarios (placeholder)
          Text(
            'Gestión de Usuarios',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.withOpacity(0.2), width: 1),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.withOpacity(0.05),
                      Colors.orange.withOpacity(0.02),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_outline, size: 24, color: Colors.orange),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestionar Usuarios',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crear, editar y eliminar usuarios',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ],
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
