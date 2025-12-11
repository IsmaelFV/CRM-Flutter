import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../shared/providers/dashboard_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../ventas/ventas_screen.dart';
import '../gastos/gastos_screen.dart';
import '../productos/productos_screen.dart';
import '../dueno/dueno_screen.dart';
import '../admin/admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    final screens = [
      const DashboardHomeScreen(),
      const VentasScreen(),
      const GastosScreen(),
      const ProductosScreen(),
      if (authProvider.isDueno) DuenoScreen(),
      if (authProvider.isSuperadmin) const AdminScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('MarketMove', style: TextStyle(fontSize: 18)),
            if (authProvider.tiendaActual != null)
              Text(
                authProvider.tiendaActual!.nombre,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().cargarDatos();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                enabled: false,
                child: Text(authProvider.currentUser?.nombreCompleto ?? 'Usuario'),
              ),
              PopupMenuItem<String>(
                value: 'role',
                enabled: false,
                child: Text(
                  authProvider.currentUser?.rol.displayName ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
                onTap: () {
                  authProvider.signOut();
                },
              ),
            ],
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart),
            label: 'Ventas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Gastos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          if (authProvider.isDueno)
            const NavigationDestination(
              icon: Icon(Icons.store),
              label: 'Dueño',
            ),
          if (authProvider.isSuperadmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => dashboardProvider.cargarDatos(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Título
              Text(
                'Resumen del Día',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tarjetas de resumen del día
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Ventas',
                      value: currencyFormat.format(dashboardProvider.ventasHoy),
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Gastos',
                      value: currencyFormat.format(dashboardProvider.gastosHoy),
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Ganancias del día
              _StatCard(
                title: 'Ganancias del Día',
                value: currencyFormat.format(dashboardProvider.gananciasHoy),
                icon: Icons.account_balance_wallet,
                color: dashboardProvider.gananciasHoy >= 0 
                    ? Colors.blue 
                    : Colors.orange,
                isLarge: true,
              ),
              const SizedBox(height: 24),
              
              // Título mes
              Text(
                'Resumen del Mes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Tarjetas de resumen del mes
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Ventas',
                      value: currencyFormat.format(dashboardProvider.ventasMes),
                      icon: Icons.shopping_bag,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Gastos',
                      value: currencyFormat.format(dashboardProvider.gastosMes),
                      icon: Icons.receipt,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Ganancias del mes
              _StatCard(
                title: 'Ganancias del Mes',
                value: currencyFormat.format(dashboardProvider.gananciasMes),
                icon: Icons.savings,
                color: dashboardProvider.gananciasMes >= 0 
                    ? Colors.blue 
                    : Colors.orange,
                isLarge: true,
              ),
              const SizedBox(height: 24),
              
              // Alertas de stock bajo
              if (dashboardProvider.alertasStockBajo > 0) ...[
                Card(
                  color: Colors.orange[50],
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text(
                      'Productos con stock bajo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${dashboardProvider.alertasStockBajo} producto(s) necesitan reposición',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navegar a productos con filtro de stock bajo
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Lista de productos con stock bajo
              if (dashboardProvider.productosStockBajo.isNotEmpty) ...[
                Text(
                  'Productos con Stock Bajo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...dashboardProvider.productosStockBajo.take(5).map((producto) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: producto.sinStock 
                            ? Colors.red 
                            : Colors.orange,
                        child: Text(
                          producto.stock.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(producto.nombre),
                      subtitle: Text(
                        producto.sinStock 
                            ? 'SIN STOCK' 
                            : 'Stock bajo (mín: ${producto.stockMinimo})',
                      ),
                      trailing: Text(
                        currencyFormat.format(producto.precio),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isLarge ? 28 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isLarge ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isLarge ? 28 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
