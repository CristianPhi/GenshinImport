import 'package:flutter/material.dart';
import '../models/weapon.dart';
import '../services/api_service.dart';
import 'weapon_detail.dart';

class UserDashboardPage extends StatefulWidget {
  final String token;
  final int userId;
  final VoidCallback onLogout;

  const UserDashboardPage({
    super.key,
    required this.token,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Weapon>> weaponsFuture;
  late Future<List<dynamic>> ordersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    weaponsFuture = ApiService.getWeapons();
    ordersFuture = ApiService.getOrders(widget.token, widget.userId);
  }

  void _refresh() {
    setState(_loadData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyWeapon(Weapon weapon) {
    double quantity = 1;
    final maxQty = weapon.stock > 0 ? weapon.stock.clamp(1, 20) : 1;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Beli ${weapon.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Harga: \$${weapon.price}'),
                  Text('Jumlah: ${quantity.toInt()}'),
                  Slider(
                    value: quantity.clamp(1, maxQty.toDouble()),
                    min: 1,
                    max: maxQty.toDouble(),
                    divisions: maxQty > 1 ? maxQty - 1 : null,
                    label: quantity.toInt().toString(),
                    onChanged: weapon.stock > 0
                        ? (val) => setDialogState(() => quantity = val)
                        : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    try {
                      await ApiService.createOrder(
                        widget.token,
                        weapon.id,
                        quantity.toInt(),
                      );
                      if (!mounted) return;
                      _refresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pembelian berhasil')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Beli'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _shopTab() {
    return FutureBuilder<List<Weapon>>(
      future: weaponsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final weapons = snapshot.data ?? [];
        if (weapons.isEmpty) {
          return const Center(child: Text('Tidak ada weapon'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
          ),
          itemCount: weapons.length,
          itemBuilder: (context, index) {
            final weapon = weapons[index];
            final hasImage = weapon.imageUrl != null && weapon.imageUrl!.isNotEmpty;

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: hasImage
                        ? Image.network(
                            weapon.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 48),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.shield, size: 48),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${weapon.price}'),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WeaponDetailPage(weapon: weapon),
                                  ),
                                );
                              },
                              child: const Text('Detail'),
                            ),
                            ElevatedButton(
                              onPressed: weapon.stock > 0 ? () => _buyWeapon(weapon) : null,
                              child: const Text('Beli'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _ordersTab() {
    return FutureBuilder<List<dynamic>>(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('Order #${order['id']}'),
                subtitle: Text(
                  'Weapon ID: ${order['weapon_id']} | Qty: ${order['quantity']}',
                ),
                trailing: Text('\$${order['total_price']}'),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genshin Shop'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'Shop'),
            Tab(icon: Icon(Icons.receipt), text: 'Orders'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('User Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Shop'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Pesanan Saya'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: widget.onLogout,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_shopTab(), _ordersTab()],
      ),
    );
  }
}
