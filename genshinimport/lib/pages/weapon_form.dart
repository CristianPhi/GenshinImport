import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/weapon.dart';
import '../services/api_service.dart';

class WeaponFormPage extends StatefulWidget {
  final Weapon? weapon;
  final VoidCallback onSave;
  final String token;

  const WeaponFormPage({
    super.key,
    this.weapon,
    required this.onSave,
    required this.token,
  });

  @override
  State<WeaponFormPage> createState() => _WeaponFormPageState();
}

class _WeaponFormPageState extends State<WeaponFormPage> {
  late final nameController = TextEditingController(text: widget.weapon?.name ?? '');
  late final typeController = TextEditingController(text: widget.weapon?.type ?? '');
  late final descriptionController = TextEditingController(text: widget.weapon?.description ?? '');
  late final stockController = TextEditingController(text: widget.weapon?.stock.toString() ?? '1');
  late final priceController = TextEditingController(text: widget.weapon?.price.toString() ?? '');
  late final imageUrlController = TextEditingController(text: widget.weapon?.imageUrl ?? '');

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _pickedImage;
  double _stockSlider = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stockSlider = double.tryParse(stockController.text) ?? 1;
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    descriptionController.dispose();
    stockController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _saveWeapon() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final imageUrl = imageUrlController.text.trim();
      final data = (
        name: nameController.text,
        type: typeController.text,
        description: descriptionController.text,
        stock: int.parse(stockController.text),
        price: double.parse(priceController.text),
        image: imageUrl.isEmpty ? null : imageUrl,
      );

      if (widget.weapon == null) {
        await ApiService.createWeapon(
          token: widget.token,
          name: data.name,
          type: data.type,
          description: data.description,
          stock: data.stock,
          price: data.price,
          imageUrl: data.image,
        );
      } else {
        await ApiService.updateWeapon(
          widget.token,
          widget.weapon!.id,
          name: data.name,
          type: data.type,
          description: data.description,
          stock: data.stock,
          price: data.price,
          imageUrl: data.image,
        );
      }

      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tersimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _preview() {
    if (_pickedImage != null) return Image.file(_pickedImage!, fit: BoxFit.cover);
    final url = imageUrlController.text.trim();
    if (url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Text('URL tidak valid')));
    }
    return const Center(child: Icon(Icons.image_outlined, size: 40));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.weapon != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Weapon' : 'Tambah Weapon')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(height: 140, child: _preview()),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton(onPressed: _pickImage, child: const Text('Pilih Gambar')),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Simpan pakai URL', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Text('Stock: ${_stockSlider.toInt()}'),
            Slider(
              value: _stockSlider.clamp(0, 100),
              max: 100,
              divisions: 100,
              label: _stockSlider.toInt().toString(),
              onChanged: (v) => setState(() {
                _stockSlider = v;
                stockController.text = v.toInt().toString();
              }),
            ),
            TextFormField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Angka >= 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Angka > 0';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _saveWeapon,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Update' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
