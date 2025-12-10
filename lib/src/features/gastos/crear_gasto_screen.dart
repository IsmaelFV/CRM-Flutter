import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/gasto_service.dart';
import '../../shared/models/gasto_model.dart';

class CrearGastoScreen extends StatefulWidget {
  const CrearGastoScreen({super.key});

  @override
  State<CrearGastoScreen> createState() => _CrearGastoScreenState();
}

class _CrearGastoScreenState extends State<CrearGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final GastoService _gastoService = GastoService();
  final ImagePicker _imagePicker = ImagePicker();
  
  final _conceptoController = TextEditingController();
  final _importeController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _comentariosController = TextEditingController();
  final _categoriaController = TextEditingController();
  
  MetodoPago _metodoPago = MetodoPago.efectivo;
  File? _imagenSeleccionada;
  bool _isLoading = false;

  @override
  void dispose() {
    _conceptoController.dispose();
    _importeController.dispose();
    _cantidadController.dispose();
    _comentariosController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imagenSeleccionada = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _guardarGasto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final gasto = await _gastoService.crearGasto(
      importe: double.parse(_importeController.text),
      concepto: _conceptoController.text,
      metodoPago: _metodoPago,
      cantidad: _cantidadController.text.isEmpty 
          ? null 
          : int.parse(_cantidadController.text),
      comentarios: _comentariosController.text.isEmpty 
          ? null 
          : _comentariosController.text,
      categoriaGasto: _categoriaController.text.isEmpty 
          ? null 
          : _categoriaController.text,
      foto: _imagenSeleccionada,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (gasto != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar el gasto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Concepto
              TextFormField(
                controller: _conceptoController,
                decoration: const InputDecoration(
                  labelText: 'Concepto',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el concepto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Importe
              TextFormField(
                controller: _importeController,
                decoration: const InputDecoration(
                  labelText: 'Importe',
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el importe';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Importe inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cantidad (opcional)
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (opcional)',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              
              // Foto
              if (_imagenSeleccionada != null) ...[
                Card(
                  child: Column(
                    children: [
                      Image.file(
                        _imagenSeleccionada!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _imagenSeleccionada = null;
                          });
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar foto'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              OutlinedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _imagenSeleccionada == null 
                      ? 'Adjuntar Foto (opcional)' 
                      : 'Cambiar Foto',
                ),
              ),
              const SizedBox(height: 24),
              
              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _guardarGasto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
