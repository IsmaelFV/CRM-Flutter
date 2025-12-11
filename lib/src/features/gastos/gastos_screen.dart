import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/gasto_service.dart';
import '../../shared/models/gasto_model.dart';
import '../../shared/providers/auth_provider.dart';
import 'crear_gasto_screen.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  final GastoService _gastoService = GastoService();
  List<Gasto> _gastos = [];
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    
    // Determinar el filtro de duenoId
    final filtroDuenoId = authProvider.isSuperadmin
        ? authProvider.tiendaActual?.duenoId  // Tienda seleccionada o null (todas)
        : authProvider.duenoId;                // Dueño/empleado actual
    
    _gastos = await _gastoService.getGastos(duenoId: filtroDuenoId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarGastos,
              child: _gastos.isEmpty
                  ? const Center(
                      child: Text('No hay gastos registrados'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _gastos.length,
                      itemBuilder: (context, index) {
                        final gasto = _gastos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: gasto.tieneFoto
                                  ? const Icon(Icons.image, color: Colors.white)
                                  : const Icon(Icons.receipt, color: Colors.white),
                            ),
                            title: Text(
                              gasto.concepto,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (gasto.cantidad != null)
                                  Text('Cantidad: ${gasto.cantidad}'),
                                Text(dateFormat.format(gasto.fecha)),
                                Text('Método: ${gasto.metodoPago.displayName}'),
                                if (gasto.categoriaGasto != null)
                                  Text('Categoría: ${gasto.categoriaGasto}'),
                              ],
                            ),
                            trailing: Text(
                              currencyFormat.format(gasto.importe),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
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
              builder: (context) => const CrearGastoScreen(),
            ),
          );
          if (result == true) {
            _cargarGastos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
