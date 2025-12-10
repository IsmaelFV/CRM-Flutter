import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/producto_service.dart';

class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();
  
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _stockMinimoController = TextEditingController(text: '5');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _codigoBarrasController.dispose();
    _categoriaController.dispose();
    _descripcionController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final producto = await _productoService.crearProducto(
      nombre: _nombreController.text,
      precio: double.parse(_precioController.text),
      stock: int.parse(_stockController.text),
      codigoBarras: _codigoBarrasController.text.isEmpty 
          ? null 
          : _codigoBarrasController.text,
      descripcion: _descripcionController.text.isEmpty 
          ? null 
          : _descripcionController.text,
      stockMinimo: int.parse(_stockMinimoController.text),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (producto != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear el producto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Precio
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Stock
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Inicial',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stock inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Stock mínimo
              TextFormField(
                controller: _stockMinimoController,
                decoration: const InputDecoration(
                  labelText: 'Stock Mínimo',
                  prefixIcon: Icon(Icons.warning),
                  helperText: 'Alerta cuando el stock sea menor o igual a este valor',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el stock mínimo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stock mínimo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Código de barras
              TextFormField(
                controller: _codigoBarrasController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras (opcional)',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),
              
              // Categoría
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              
              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarProducto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
