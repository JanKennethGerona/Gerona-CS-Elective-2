import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/lego_theme.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? productToEdit;

  const ProductFormDialog({super.key, this.productToEdit});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  bool _isSubmitting = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productToEdit?.name ?? '');
    _descController = TextEditingController(text: widget.productToEdit?.description ?? '');
    _priceController = TextEditingController(
      text: widget.productToEdit != null
          ? widget.productToEdit!.price.toStringAsFixed(2)
          : '',
    );
    _stockController = TextEditingController(
      text: widget.productToEdit != null
          ? widget.productToEdit!.stock.toString()
          : '10',
    );
    _imageUrlController = TextEditingController(
      text: widget.productToEdit?.imageUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ProductProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final imageUrl = _imageUrlController.text.trim().isEmpty
        ? 'https://images.unsplash.com/photo-1585366119957-e9730b6d0f60?w=500' // LEGO toy Unsplash
        : _imageUrlController.text.trim();

    bool success;
    if (isEditing) {
      final updated = widget.productToEdit!.copyWith(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
      );
      success = await provider.updateProduct(updated);
    } else {
      final newProduct = Product(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
      );
      success = await provider.addProduct(newProduct);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Updated "$name"' : 'Snapped "$name" into place!',
            ),
            backgroundColor: LegoTheme.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'An error occurred'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: LegoTheme.red, width: 3.5),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: LegoTheme.red,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.extension_rounded, color: LegoTheme.yellow),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Edit Brick Item' : 'Assemble New Brick',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Brick Name *',
                  hintText: 'e.g. Starfighter 500 Pcs',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Set details, brick count, minifigures...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (\$) *',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter price';
                        }
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Qty',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: LegoTheme.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  isEditing ? 'Save Changes' : 'Snap In Place',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
        ),
      ],
    );
  }
}
