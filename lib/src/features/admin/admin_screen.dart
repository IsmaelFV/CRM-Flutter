import 'package:flutter/material.dart';
import '../../services/export_service.dart';
import 'package:intl/intl.dart';

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
    
    final file = await _exportService.exportarVentas();
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ventas exportadas: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar ventas'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportarGastos() async {
    setState(() => _isExporting = true);
    
    final file = await _exportService.exportarGastos();
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gastos exportados: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar gastos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportarProductos() async {
    setState(() => _isExporting = true);
    
    final file = await _exportService.exportarProductos();
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Productos exportados: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar productos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportarInformeCompleto() async {
    setState(() => _isExporting = true);
    
    final file = await _exportService.exportarInformeCompleto();
    
    setState(() => _isExporting = false);

    if (!mounted) return;

    if (file != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe completo exportado: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al exportar informe'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Exportando...'),
                  ],
                ),
              ),
            )
          else ...[
            // Exportar ventas
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.shopping_cart, color: Colors.white),
                ),
                title: const Text('Exportar Ventas'),
                subtitle: const Text('Exportar todas las ventas a Excel'),
                trailing: const Icon(Icons.download),
                onTap: _exportarVentas,
              ),
            ),
            const SizedBox(height: 12),
            
            // Exportar gastos
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.receipt_long, color: Colors.white),
                ),
                title: const Text('Exportar Gastos'),
                subtitle: const Text('Exportar todos los gastos a Excel'),
                trailing: const Icon(Icons.download),
                onTap: _exportarGastos,
              ),
            ),
            const SizedBox(height: 12),
            
            // Exportar productos
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.inventory, color: Colors.white),
                ),
                title: const Text('Exportar Productos'),
                subtitle: const Text('Exportar catálogo de productos a Excel'),
                trailing: const Icon(Icons.download),
                onTap: _exportarProductos,
              ),
            ),
            const SizedBox(height: 12),
            
            // Exportar informe completo
            Card(
              color: Colors.purple[50],
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.analytics, color: Colors.white),
                ),
                title: const Text(
                  'Exportar Informe Completo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Informe completo con ventas, gastos y productos'),
                trailing: const Icon(Icons.download),
                onTap: _exportarInformeCompleto,
              ),
            ),
          ],
          
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
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.people, color: Colors.white),
              ),
              title: const Text('Gestionar Usuarios'),
              subtitle: const Text('Crear, editar y eliminar usuarios'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad en desarrollo'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.security, color: Colors.white),
              ),
              title: const Text('Gestionar Permisos'),
              subtitle: const Text('Configurar roles y permisos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad en desarrollo'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
