import 'package:flutter/foundation.dart';
import '../../services/venta_service.dart';
import '../../services/gasto_service.dart';
import '../../services/producto_service.dart';
import '../models/producto_model.dart';

class DashboardProvider with ChangeNotifier {
  final VentaService _ventaService = VentaService();
  final GastoService _gastoService = GastoService();
  final ProductoService _productoService = ProductoService();

  bool _isLoading = false;
  String? _errorMessage;

  // Datos del día
  double _ventasHoy = 0.0;
  double _gastosHoy = 0.0;
  double _gananciasHoy = 0.0;

  // Datos del mes
  double _ventasMes = 0.0;
  double _gastosMes = 0.0;
  double _gananciasMes = 0.0;

  // Productos con stock bajo
  List<Producto> _productosStockBajo = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  double get ventasHoy => _ventasHoy;
  double get gastosHoy => _gastosHoy;
  double get gananciasHoy => _gananciasHoy;
  
  double get ventasMes => _ventasMes;
  double get gastosMes => _gastosMes;
  double get gananciasMes => _gananciasMes;
  
  List<Producto> get productosStockBajo => _productosStockBajo;
  int get alertasStockBajo => _productosStockBajo.length;

  Future<void> cargarDatos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar datos en paralelo
      await Future.wait([
        _cargarDatosHoy(),
        _cargarDatosMes(),
        _cargarProductosStockBajo(),
      ]);
    } catch (e) {
      _errorMessage = 'Error cargando datos: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cargarDatosHoy() async {
    _ventasHoy = await _ventaService.getTotalVentasHoy();
    _gastosHoy = await _gastoService.getTotalGastosHoy();
    _gananciasHoy = _ventasHoy - _gastosHoy;
  }

  Future<void> _cargarDatosMes() async {
    _ventasMes = await _ventaService.getTotalVentasMes();
    _gastosMes = await _gastoService.getTotalGastosMes();
    _gananciasMes = _ventasMes - _gastosMes;
  }

  Future<void> _cargarProductosStockBajo() async {
    _productosStockBajo = await _productoService.getProductosStockBajo();
  }

  // Comparativa con el mes anterior
  Future<Map<String, double>> getComparativaMensual() async {
    final hoy = DateTime.now();
    final inicioMesActual = DateTime(hoy.year, hoy.month, 1);
    final inicioMesAnterior = DateTime(hoy.year, hoy.month - 1, 1);
    final finMesAnterior = inicioMesActual.subtract(const Duration(days: 1));

    final ventasMesAnterior = await _ventaService.getTotalVentas(
      desde: inicioMesAnterior,
      hasta: finMesAnterior,
    );

    final gastosMesAnterior = await _gastoService.getTotalGastos(
      desde: inicioMesAnterior,
      hasta: finMesAnterior,
    );

    final gananciasMesAnterior = ventasMesAnterior - gastosMesAnterior;

    final cambioVentas = _ventasMes - ventasMesAnterior;
    final cambioGastos = _gastosMes - gastosMesAnterior;
    final cambioGanancias = _gananciasMes - gananciasMesAnterior;

    final porcentajeVentas = ventasMesAnterior > 0 
        ? (cambioVentas / ventasMesAnterior) * 100 
        : 0.0;
    final porcentajeGastos = gastosMesAnterior > 0 
        ? (cambioGastos / gastosMesAnterior) * 100 
        : 0.0;
    final porcentajeGanancias = gananciasMesAnterior > 0 
        ? (cambioGanancias / gananciasMesAnterior) * 100 
        : 0.0;

    return {
      'ventas_cambio': cambioVentas,
      'ventas_porcentaje': porcentajeVentas,
      'gastos_cambio': cambioGastos,
      'gastos_porcentaje': porcentajeGastos,
      'ganancias_cambio': cambioGanancias,
      'ganancias_porcentaje': porcentajeGanancias,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
