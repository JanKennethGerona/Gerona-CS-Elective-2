import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../providers/auth_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/product_providers.dart';
import '../../utils/lego_theme.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormPage({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;

  int? _selectedCategoryId;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _isSaving = false;

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _stockController =
        TextEditingController(text: p != null ? p.stock.toString() : '10');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = xFile.name;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category for this brick product'),
          backgroundColor: LegoTheme.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final service = ref.read(supabaseServiceProvider);

    try {
      String? finalImageUrl = _imageUrlController.text.trim();

      // If user picked a local image file, upload it to Supabase Storage bucket 'product-images'
      if (_pickedImageBytes != null && _pickedImageName != null) {
        final uploaded = await service.uploadProductImage(
          fileBytes: _pickedImageBytes!,
          fileName: _pickedImageName!,
        );
        if (uploaded != null && uploaded.isNotEmpty) {
          finalImageUrl = uploaded;
        }
      }

      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      if (isEditing) {
        await service.updateProduct(
          id: widget.productToEdit!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          categoryId: _selectedCategoryId!,
          imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
        );
      } else {
        await service.addProduct(
          name: name,
          description: description,
          price: price,
          stock: stock,
          categoryId: _selectedCategoryId!,
          imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
        );
      }

      // Refresh products page
      ref.invalidate(productsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Updated "$name" successfully!'
                : 'Assembled new product "$name"!'),
            backgroundColor: LegoTheme.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: LegoTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: Text(
          isEditing ? 'Edit Brick Set' : 'Assemble New Brick',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isSaving ? null : _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g. LEGO Star Wars X-Wing',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title, color: LegoTheme.blue),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'A product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Piece count, features, minifigures included...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes, color: LegoTheme.blue),
                ),
              ),
              const SizedBox(height: 14),

              // Price and Stock row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (\$) *',
                        hintText: '49.99',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.attach_money, color: LegoTheme.green),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Price required';
                        }
                        final numVal = double.tryParse(val.trim());
                        if (numVal == null || numVal < 0) {
                          return 'Must be >= 0';
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
                        labelText: 'Stock (Qty) *',
                        hintText: '10',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.inventory_2, color: LegoTheme.red),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Stock required';
                        }
                        final intVal = int.tryParse(val.trim());
                        if (intVal == null || intVal < 0) {
                          return 'Must be whole number >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Category dropdown
              categoriesAsync.when(
                data: (cats) {
                  if (cats.isEmpty) {
                    return const Text('No categories exist. Add one first.');
                  }
                  // Pre-select first category if none selected
                  _selectedCategoryId ??= cats.first.id;

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category, color: LegoTheme.blue),
                    ),
                    items: cats.map((c) {
                      return DropdownMenuItem<int>(
                        value: c.id,
                        child: Text(c.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                    validator: (val) =>
                        val == null ? 'Please select category' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, stackTrace) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 16),

              // Image preview & Storage Upload
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Image (Supabase Storage)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Image display if available
                    if (_pickedImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _pickedImageBytes!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      )
                    else if (_imageUrlController.text.trim().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrlController.text.trim(),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, st) => const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: LegoTheme.blue,
                          ),
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: Text(
                            _pickedImageBytes != null
                                ? 'Change Image'
                                : 'Upload from Device',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Or Image URL (Direct / Fallback)',
                        hintText: 'https://images.brickset.com/sets/...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: LegoTheme.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving ? null : _saveProduct,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Assemble Brick Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
