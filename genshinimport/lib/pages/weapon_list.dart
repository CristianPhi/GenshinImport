import 'package:flutter/material.dart';
import '../models/weapon.dart';
import '../services/api_service.dart';
import 'weapon_detail.dart';
import 'weapon_form.dart';

class WeaponListPage extends StatefulWidget {
  final String token;
  final VoidCallback onLogout;

  const WeaponListPage({super.key, required this.token, required this.onLogout});

  @override
  State<WeaponListPage> createState() => _WeaponListPageState();
}

class _WeaponListPageState extends State<WeaponListPage> {
  late Future<List<Weapon>> futureWeapons;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    futureWeapons = ApiService.getWeapons();
  }

  void _refreshWeapons() {
    setState(() => futureWeapons = ApiService.getWeapons());
  }

  void _openDetail(Weapon weapon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeaponDetailPage(weapon: weapon)),
    );
  }

  void _openForm({Weapon? weapon}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeaponFormPage(
          weapon: weapon,
          onSave: _refreshWeapons,
          token: widget.token,
        ),
      ),
    );
  }

  void _deleteWeapon(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus weapon?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteWeapon(widget.token, id);
                if (!mounted) return;
                _refreshWeapons();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Weapon dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _thumb(Weapon weapon, {double size = 48}) {
    final url = weapon.imageUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, width: size, height: size, fit: BoxFit.cover),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shield_outlined, color: Color(0xFF4A6FA5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshWeapons),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Weapon'),
              onTap: () {
                Navigator.pop(context);
                _openForm();
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
      body: FutureBuilder<List<Weapon>>(
        future: futureWeapons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final weapons = snapshot.data ?? [];
          if (weapons.isEmpty) {
            return const Center(child: Text('Belum ada weapon'));
          }

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemCount: weapons.length,
              itemBuilder: (context, i) {
                final w = weapons[i];
                return InkWell(
                  onTap: () => _openDetail(w),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Center(child: _thumb(w, size: 72))),
                          Text(w.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${w.type} · Stock ${w.stock}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: weapons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final w = weapons[i];
              return Card(
                child: ListTile(
                  leading: _thumb(w),
                  title: Text(w.name),
                  subtitle: Text('${w.type} · \$${w.price} · Stock ${w.stock}'),
                  onTap: () => _openDetail(w),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(weapon: w);
                      if (v == 'delete') _deleteWeapon(w.id);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Hapus')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
