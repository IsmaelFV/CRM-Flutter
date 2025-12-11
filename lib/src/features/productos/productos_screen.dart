import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/producto_service.dart';
import '../../shared/models/producto_model.dart';
import '../../shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'crear_producto_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productos = [];
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    
    // Determinar el filtro de duenoId
    final filtroDuenoId = authProvider.isSuperadmin
        ? authProvider.tiendaActual?.duenoId  // Tienda seleccionada o null (todas)
        : authProvider.duenoId;                // Dueño/empleado actual
    
    _productos = await _productoService.getProductos(duenoId: filtroDuenoId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final puedeGestionar = authProvider.isSuperadmin || authProvider.isDueno;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarProductos,
              child: _productos.isEmpty
                  ? const Center(
                      child: Text('No hay productos registrados'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: producto.sinStock
                                  ? Colors.red
                                  : producto.stockBajo
                                      ? Colors.orange
                                      : Colors.green,
                              child: Text(
                                producto.stock.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              producto.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Precio: ${currencyFormat.format(producto.precio)}'),
                                Text('Stock: ${producto.stock}'),
                                if (producto.categoria != null)
                                  Text('Categoría: ${producto.categoria}'),
                                if (producto.stockBajo)
                                  Text(
                                    producto.sinStock ? 'SIN STOCK' : 'STOCK BAJO',
                                    style: TextStyle(
                                      color: producto.sinStock ? Colors.red : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: puedeGestionar
                                ? PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'editar',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Editar'),
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
                                    onSelected: (value) async {
                                      if (value == 'eliminar') {
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmar'),
                                            content: Text(
                                              '¿Eliminar ${producto.nombre}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirmar == true) {
                                          await _productoService.eliminarProducto(producto.id);
                                          _cargarProductos();
                                        }
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CrearProductoScreen(),
                  ),
                );
                if (result == true) {
                  _cargarProductos();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Producto'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}
