import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/venta_service.dart';
import '../../shared/models/venta_model.dart';
import 'crear_venta_screen.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService _ventaService = VentaService();
  List<Venta> _ventas = [];
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() => _isLoading = true);
    _ventas = await _ventaService.getVentas();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarVentas,
              child: _ventas.isEmpty
                  ? const Center(
                      child: Text('No hay ventas registradas'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _ventas.length,
                      itemBuilder: (context, index) {
                        final venta = _ventas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              venta.productoNombre ?? 'Producto',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad: ${venta.cantidad}'),
                                Text(dateFormat.format(venta.fecha)),
                                Text('Método: ${venta.metodoPago.displayName}'),
                              ],
                            ),
                            trailing: Text(
                              currencyFormat.format(venta.importe),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearVentaScreen(),
            ),
          );
          if (result == true) {
            _cargarVentas();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
      ),
    );
  }
}
