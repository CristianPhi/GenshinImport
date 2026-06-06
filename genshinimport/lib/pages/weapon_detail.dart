import 'package:flutter/material.dart';
import '../models/weapon.dart';

class WeaponDetailPage extends StatefulWidget {
  final Weapon weapon;

  const WeaponDetailPage({super.key, required this.weapon});

  @override
  State<WeaponDetailPage> createState() => _WeaponDetailPageState();
}

class _WeaponDetailPageState extends State<WeaponDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> get _images {
    if (widget.weapon.imageUrl != null && widget.weapon.imageUrl!.isNotEmpty) {
      return [widget.weapon.imageUrl!];
    }
    return [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weapon = widget.weapon;
    final hasImage = _images.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(weapon.name)),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: hasImage
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) {
                          return Image.network(
                            _images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          );
                        },
                      ),
                      if (_images.length > 1)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_images.length, (i) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _currentPage
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  )
                : _placeholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weapon.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Type: ${weapon.type}'),
                Text('Stock: ${weapon.stock}'),
                Text('Price: \$${weapon.price}'),
                const SizedBox(height: 12),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(weapon.description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
      ),
    );
  }
}
