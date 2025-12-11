import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
// Conditional import for web
import 'dart:html' as html show AnchorElement, Url, Blob;
import '../shared/models/venta_model.dart';
import '../shared/models/gasto_model.dart';
import '../shared/models/producto_model.dart';
import 'venta_service.dart';
import 'gasto_service.dart';
import 'producto_service.dart';

class ExportService {
  final VentaService _ventaService = VentaService();
  final GastoService _gastoService = GastoService();
  final ProductoService _productoService = ProductoService();

  // Exportar ventas a Excel
  Future<File?> exportarVentas({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    try {
      final ventas = await _ventaService.getVentas(desde: desde, hasta: hasta, duenoId: duenoId);
      
      final excel = Excel.createExcel();
      final sheet = excel['Ventas'];

      // Encabezados
      sheet.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Producto'),
        TextCellValue('Cantidad'),
        TextCellValue('Importe'),
        TextCellValue('Método de Pago'),
        TextCellValue('Creado Por'),
        TextCellValue('Comentarios'),
      ]);

      // Datos
      for (final venta in ventas) {
        sheet.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(venta.fecha)),
          TextCellValue(venta.productoNombre ?? 'N/A'),
          IntCellValue(venta.cantidad),
          DoubleCellValue(venta.importe),
          TextCellValue(venta.metodoPago.displayName),
          TextCellValue(venta.creadoPorNombre ?? 'N/A'),
          TextCellValue(venta.comentarios ?? ''),
        ]);
      }

      // Total
      final total = ventas.fold(0.0, (sum, v) => sum + v.importe);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('TOTAL:'),
        DoubleCellValue(total),
      ]);

      return await _guardarExcel(excel, 'ventas');
    } catch (e) {
      print('Error exportando ventas: $e');
      return null;
    }
  }

  // Exportar gastos a Excel
  Future<File?> exportarGastos({DateTime? desde, DateTime? hasta, String? duenoId}) async {
    try {
      final gastos = await _gastoService.getGastos(desde: desde, hasta: hasta, duenoId: duenoId);
      
      final excel = Excel.createExcel();
      final sheet = excel['Gastos'];

      // Encabezados
      sheet.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Concepto'),
        TextCellValue('Cantidad'),
        TextCellValue('Importe'),
        TextCellValue('Método de Pago'),
        TextCellValue('Categoría'),
        TextCellValue('Creado Por'),
        TextCellValue('Comentarios'),
      ]);

      // Datos
      for (final gasto in gastos) {
        sheet.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(gasto.fecha)),
          TextCellValue(gasto.concepto),
          IntCellValue(gasto.cantidad ?? 0),
          DoubleCellValue(gasto.importe),
          TextCellValue(gasto.metodoPago.displayName),
          TextCellValue(gasto.categoriaGasto ?? 'N/A'),
          TextCellValue(gasto.creadoPorNombre ?? 'N/A'),
          TextCellValue(gasto.comentarios ?? ''),
        ]);
      }

      // Total
      final total = gastos.fold(0.0, (sum, g) => sum + g.importe);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue('TOTAL:'),
        DoubleCellValue(total),
      ]);

      return await _guardarExcel(excel, 'gastos');
    } catch (e) {
      print('Error exportando gastos: $e');
      return null;
    }
  }

  // Exportar productos a Excel
  Future<File?> exportarProductos({String? duenoId}) async {
    try {
      final productos = await _productoService.getProductos(duenoId: duenoId);
      
      final excel = Excel.createExcel();
      final sheet = excel['Productos'];

      // Encabezados
      sheet.appendRow([
        TextCellValue('Nombre'),
        TextCellValue('Precio'),
        TextCellValue('Stock'),
        TextCellValue('Stock Mínimo'),
        TextCellValue('Código de Barras'),
        TextCellValue('Categoría'),
        TextCellValue('Estado Stock'),
      ]);

      // Datos
      for (final producto in productos) {
        sheet.appendRow([
          TextCellValue(producto.nombre),
          DoubleCellValue(producto.precio),
          IntCellValue(producto.stock),
          IntCellValue(producto.stockMinimo),
          TextCellValue(producto.codigoBarras ?? 'N/A'),
          TextCellValue(producto.categoria ?? 'N/A'),
          TextCellValue(producto.sinStock 
              ? 'SIN STOCK' 
              : producto.stockBajo 
                  ? 'STOCK BAJO' 
                  : 'OK'),
        ]);
      }

      return await _guardarExcel(excel, 'productos');
    } catch (e) {
      print('Error exportando productos: $e');
      return null;
    }
  }

  // Exportar informe completo
  Future<File?> exportarInformeCompleto({
    DateTime? desde,
    DateTime? hasta,
    String? duenoId,
  }) async {
    try {
      final ventas = await _ventaService.getVentas(desde: desde, hasta: hasta, duenoId: duenoId);
      final gastos = await _gastoService.getGastos(desde: desde, hasta: hasta, duenoId: duenoId);
      final productos = await _productoService.getProductos(duenoId: duenoId);
      
      final excel = Excel.createExcel();

      // Hoja de resumen
      final resumen = excel['Resumen'];
      final totalVentas = ventas.fold(0.0, (sum, v) => sum + v.importe);
      final totalGastos = gastos.fold(0.0, (sum, g) => sum + g.importe);
      final ganancias = totalVentas - totalGastos;

      resumen.appendRow([TextCellValue('INFORME MARKETMOVE')]);
      resumen.appendRow([]);
      resumen.appendRow([
        TextCellValue('Período:'), 
        TextCellValue('${desde != null ? DateFormat('dd/MM/yyyy').format(desde) : 'Inicio'} - ${hasta != null ? DateFormat('dd/MM/yyyy').format(hasta) : 'Hoy'}')
      ]);
      resumen.appendRow([]);
      resumen.appendRow([TextCellValue('Total Ventas:'), DoubleCellValue(totalVentas)]);
      resumen.appendRow([TextCellValue('Total Gastos:'), DoubleCellValue(totalGastos)]);
      resumen.appendRow([TextCellValue('Ganancias:'), DoubleCellValue(ganancias)]);
      resumen.appendRow([]);
      resumen.appendRow([TextCellValue('Número de Ventas:'), IntCellValue(ventas.length)]);
      resumen.appendRow([TextCellValue('Número de Gastos:'), IntCellValue(gastos.length)]);
      resumen.appendRow([TextCellValue('Productos en Catálogo:'), IntCellValue(productos.length)]);

      // Hoja de ventas
      final sheetVentas = excel['Ventas'];
      sheetVentas.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Producto'),
        TextCellValue('Cantidad'),
        TextCellValue('Importe'),
        TextCellValue('Método de Pago'),
      ]);
      for (final venta in ventas) {
        sheetVentas.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(venta.fecha)),
          TextCellValue(venta.productoNombre ?? 'N/A'),
          IntCellValue(venta.cantidad),
          DoubleCellValue(venta.importe),
          TextCellValue(venta.metodoPago.displayName),
        ]);
      }

      // Hoja de gastos
      final sheetGastos = excel['Gastos'];
      sheetGastos.appendRow([
        TextCellValue('Fecha'),
        TextCellValue('Concepto'),
        TextCellValue('Importe'),
        TextCellValue('Método de Pago'),
        TextCellValue('Categoría'),
      ]);
      for (final gasto in gastos) {
        sheetGastos.appendRow([
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(gasto.fecha)),
          TextCellValue(gasto.concepto),
          DoubleCellValue(gasto.importe),
          TextCellValue(gasto.metodoPago.displayName),
          TextCellValue(gasto.categoriaGasto ?? 'N/A'),
        ]);
      }

      return await _guardarExcel(excel, 'informe_completo');
    } catch (e) {
      print('Error exportando informe completo: $e');
      return null;
    }
  }

  // Guardar archivo Excel
  Future<File?> _guardarExcel(Excel excel, String nombre) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${nombre}_$timestamp.xlsx';
    
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Error al generar el archivo Excel');
    
    if (kIsWeb) {
      // Para web: descargar directamente al navegador
      _descargarArchivoWeb(bytes, fileName);
      return null; // En web no devolvemos File
    } else {
      // Para móvil/desktop: guardar en sistema de archivos
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    }
  }
  
  // Descargar archivo en web
  void _descargarArchivoWeb(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
