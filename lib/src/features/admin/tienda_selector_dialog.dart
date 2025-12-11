import 'package:flutter/material.dart';
import '../../shared/models/tienda_model.dart';
import '../../services/tienda_service.dart';

class TiendaSelectorDialog extends StatefulWidget {
  final String? tiendaActualId;
  
  const TiendaSelectorDialog({
    super.key,
    this.tiendaActualId,
  });

  @override
  State<TiendaSelectorDialog> createState() => _TiendaSelectorDialogState();
}

class _TiendaSelectorDialogState extends State<TiendaSelectorDialog> {
  final TiendaService _tiendaService = TiendaService();
  List<Tienda> _tiendas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tiendas = await _tiendaService.getAllTiendas();
      print('DEBUG: Tiendas cargadas: ${tiendas.length}');
      for (var tienda in tiendas) {
        print('  - ${tienda.nombre} (ID: ${tienda.id}, Dueño: ${tienda.duenoId})');
      }
      if (mounted) {
        setState(() {
          _tiendas = tiendas;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('ERROR cargando tiendas: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seleccionar Tienda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cambia entre tiendas para ver sus datos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarTiendas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_tiendas.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No hay tiendas registradas'),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    // Opción para ver todas las tiendas
                    Card(
                      color: widget.tiendaActualId == null 
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                        title: const Text(
                          'Todas las Tiendas',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Ver datos de todas las tiendas'),
                        trailing: widget.tiendaActualId == null
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () => Navigator.pop(context, null),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Lista de tiendas individuales
                    ..._tiendas.map((tienda) => Card(
                      color: widget.tiendaActualId == tienda.id
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tienda.activa ? Colors.blue : Colors.grey,
                          child: Text(
                            tienda.nombre[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tienda.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tienda.direccion != null)
                              Text(tienda.direccion!),
                            if (!tienda.activa)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                                ),
                                child: const Text(
                                  'INACTIVA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: widget.tiendaActualId == tienda.id
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.pop(context, tienda.id),
                      ),
                    )).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
