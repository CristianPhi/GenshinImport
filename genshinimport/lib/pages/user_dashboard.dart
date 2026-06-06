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

  void _refresh() => setState(_loadData);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buyWeapon(Weapon weapon) {
    double qty = 1;
    final maxQty = weapon.stock > 0 ? weapon.stock.clamp(1, 20) : 1;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setDialog) => AlertDialog(
          title: Text(weapon.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Harga: \$${weapon.price}'),
              Slider(
                value: qty.clamp(1, maxQty.toDouble()),
                min: 1,
                max: maxQty.toDouble(),
                divisions: maxQty > 1 ? maxQty - 1 : null,
                label: qty.toInt().toString(),
                onChanged: weapon.stock > 0 ? (v) => setDialog(() => qty = v) : null,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                try {
                  await ApiService.createOrder(widget.token, weapon.id, qty.toInt());
                  if (!mounted) return;
                  _refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pembelian berhasil')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('Beli'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weapons'),
            Tab(text: 'Orders'),
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
              child: Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Weapons'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Orders'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
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

  Widget _shopTab() {
    return FutureBuilder<List<Weapon>>(
      future: weaponsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));

        final weapons = snapshot.data ?? [];
        if (weapons.isEmpty) return const Center(child: Text('Tidak ada weapon'));

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.72,
          ),
          itemCount: weapons.length,
          itemBuilder: (context, i) {
            final w = weapons[i];
            final hasImg = w.imageUrl != null && w.imageUrl!.isNotEmpty;

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: hasImg
                          ? Image.network(w.imageUrl!, fit: BoxFit.cover)
                          : ColoredBox(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.shield_outlined, size: 40),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('\$${w.price}', style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => WeaponDetailPage(weapon: w)),
                              ),
                              child: const Text('Detail'),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: w.stock > 0 ? () => _buyWeapon(w) : null,
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
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) return const Center(child: Text('Belum ada pesanan'));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final o = orders[i];
            return Card(
              child: ListTile(
                title: Text('Order #${o['id']}'),
                subtitle: Text('Weapon ${o['weapon_id']} · Qty ${o['quantity']}'),
                trailing: Text('\$${o['total_price']}'),
              ),
            );
          },
        );
      },
    );
  }
}
