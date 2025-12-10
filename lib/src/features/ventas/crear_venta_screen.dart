import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/venta_service.dart';
import '../../services/producto_service.dart';
import '../../shared/models/venta_model.dart';
import '../../shared/models/producto_model.dart';

class CrearVentaScreen extends StatefulWidget {
  const CrearVentaScreen({super.key});

  @override
  State<CrearVentaScreen> createState() => _CrearVentaScreenState();
}

class _CrearVentaScreenState extends State<CrearVentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final VentaService _ventaService = VentaService();
  final ProductoService _productoService = ProductoService();
  
  List<Producto> _productos = [];
  Producto? _productoSeleccionado;
  int _cantidad = 1;
  MetodoPago _metodoPago = MetodoPago.efectivo;
  final _comentariosController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() => _isLoading = true);
    _productos = await _productoService.getProductos();
    setState(() => _isLoading = false);
  }

  Future<void> _guardarVenta() async {
    if (!_formKey.currentState!.validate() || _productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final importe = _productoSeleccionado!.precio * _cantidad;
    
    final venta = await _ventaService.crearVenta(
      importe: importe,
      productoId: _productoSeleccionado!.id,
      cantidad: _cantidad,
      metodoPago: _metodoPago,
      comentarios: _comentariosController.text.isEmpty 
          ? null 
          : _comentariosController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (venta != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venta registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar la venta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
      ),
      body: _isLoading && _productos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de producto
                    DropdownButtonFormField<Producto>(
                      value: _productoSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Producto',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: _productos.map((producto) {
                        return DropdownMenuItem(
                          value: producto,
                          child: Text(
                            '${producto.nombre} - €${producto.precio} (Stock: ${producto.stock})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _productoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona un producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Cantidad
                    TextFormField(
                      initialValue: _cantidad.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _cantidad = int.tryParse(value) ?? 1;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la cantidad';
                        }
                        final cantidad = int.tryParse(value);
                        if (cantidad == null || cantidad <= 0) {
                          return 'Cantidad inválida';
                        }
                        if (_productoSeleccionado != null && 
                            cantidad > _productoSeleccionado!.stock) {
                          return 'Stock insuficiente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Método de pago
                    DropdownButtonFormField<MetodoPago>(
                      value: _metodoPago,
                      decoration: const InputDecoration(
                        labelText: 'Método de Pago',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: MetodoPago.values.map((metodo) {
                        return DropdownMenuItem(
                          value: metodo,
                          child: Text(metodo.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _metodoPago = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Comentarios
                    TextFormField(
                      controller: _comentariosController,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios (opcional)',
                        prefixIcon: Icon(Icons.comment),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Total
                    if (_productoSeleccionado != null)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '€${(_productoSeleccionado!.precio * _cantidad).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Botón guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _guardarVenta,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Registrar Venta'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
