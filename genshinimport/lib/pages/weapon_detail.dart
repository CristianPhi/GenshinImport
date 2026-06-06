import 'package:flutter/material.dart';
import '../models/weapon.dart';

class WeaponDetailPage extends StatelessWidget {
  final Weapon weapon;

  const WeaponDetailPage({super.key, required this.weapon});

  @override
  Widget build(BuildContext context) {
    final hasImage = weapon.imageUrl != null && weapon.imageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(weapon.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: hasImage
                  ? Image.network(
                      weapon.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(weapon.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _infoRow('Type', weapon.type),
          _infoRow('Stock', '${weapon.stock}'),
          _infoRow('Price', '\$${weapon.price}'),
          const SizedBox(height: 12),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(weapon.description),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value', style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: const Center(child: Icon(Icons.image_outlined, size: 48)),
    );
  }
}
