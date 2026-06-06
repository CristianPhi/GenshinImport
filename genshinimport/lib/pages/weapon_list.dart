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
    setState(() {
      futureWeapons = ApiService.getWeapons();
    });
  }

  void _openDetail(Weapon weapon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WeaponDetailPage(weapon: weapon)),
    );
  }

  void _openForm({Weapon? weapon}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeaponFormPage(
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Weapon?'),
          content: const Text('Data akan dihapus permanen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
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
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _handleMenu(String value, Weapon weapon) {
    if (value == 'view') {
      _openDetail(weapon);
    } else if (value == 'edit') {
      _openForm(weapon: weapon);
    } else if (value == 'delete') {
      _deleteWeapon(weapon.id);
    }
  }

  Widget _weaponImage(Weapon weapon) {
    if (weapon.imageUrl != null && weapon.imageUrl!.isNotEmpty) {
      return Image.network(
        weapon.imageUrl!,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return Container(
      height: 100,
      color: Colors.grey.shade200,
      child: const Icon(Icons.shield),
    );
  }

  Widget _listTile(Weapon weapon) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: weapon.imageUrl != null && weapon.imageUrl!.isNotEmpty
            ? Image.network(
                weapon.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.shield),
              )
            : const Icon(Icons.shield),
        title: Text(weapon.name),
        subtitle: Text('${weapon.type} - Stock: ${weapon.stock}'),
        onTap: () => _openDetail(weapon),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenu(value, weapon),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('Lihat Detail')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(Weapon weapon) {
    return GestureDetector(
      onTap: () => _openDetail(weapon),
      child: Card(
        margin: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _weaponImage(weapon),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(weapon.type),
                  Text('Stock: ${weapon.stock}'),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (value) => _handleMenu(value, weapon),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('Lihat')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
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
        title: const Text('Weapon List'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshWeapons),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Daftar Weapon'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Weapon'),
              onTap: () {
                Navigator.pop(context);
                _openForm();
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
      body: FutureBuilder<List<Weapon>>(
        future: futureWeapons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada weapon'));
          }

          final weapons = snapshot.data!;

          if (_isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: weapons.length,
              itemBuilder: (context, index) => _gridTile(weapons[index]),
            );
          }

          return ListView.builder(
            itemCount: weapons.length,
            itemBuilder: (context, index) => _listTile(weapons[index]),
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
