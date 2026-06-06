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
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController descriptionController;
  late TextEditingController stockController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  File? _pickedImage;
  double _stockSlider = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.weapon?.name ?? '');
    typeController = TextEditingController(text: widget.weapon?.type ?? '');
    descriptionController = TextEditingController(
      text: widget.weapon?.description ?? '',
    );
    stockController = TextEditingController(
      text: widget.weapon?.stock.toString() ?? '1',
    );
    priceController = TextEditingController(
      text: widget.weapon?.price.toString() ?? '',
    );
    imageUrlController = TextEditingController(
      text: widget.weapon?.imageUrl ?? '',
    );
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
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _saveWeapon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final imageUrl = imageUrlController.text.trim();
      final name = nameController.text;
      final type = typeController.text;
      final description = descriptionController.text;
      final stock = int.parse(stockController.text);
      final price = double.parse(priceController.text);

      if (widget.weapon == null) {
        await ApiService.createWeapon(
          token: widget.token,
          name: name,
          type: type,
          description: description,
          stock: stock,
          price: price,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        );
      } else {
        await ApiService.updateWeapon(
          widget.token,
          widget.weapon!.id,
          name: name,
          type: type,
          description: description,
          stock: stock,
          price: price,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
        );
      }

      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data weapon tersimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _imagePreview() {
    if (_pickedImage != null) {
      return Image.file(_pickedImage!, fit: BoxFit.cover);
    }
    final url = imageUrlController.text.trim();
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Text('URL gambar tidak valid')),
      );
    }
    return const Center(child: Text('Belum ada gambar'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.weapon == null ? 'Tambah Weapon' : 'Edit Weapon'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _imagePreview(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pilih Gambar'),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Preview lokal. Simpan pakai URL di bawah.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://picsum.photos/200',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type'),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Text('Stock: ${_stockSlider.toInt()}'),
            Slider(
              value: _stockSlider.clamp(0, 100),
              min: 0,
              max: 100,
              divisions: 100,
              label: _stockSlider.toInt().toString(),
              onChanged: (val) {
                setState(() {
                  _stockSlider = val;
                  stockController.text = val.toInt().toString();
                });
              },
            ),
            TextFormField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Harus angka >= 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Harus angka > 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _saveWeapon,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.weapon == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
