import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/category_providers.dart';
import '../../utils/lego_theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/confirm_delete_dialog.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  ConsumerState<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  void _showCategoryDialog({int? editId, String? currentName}) {
    final textController = TextEditingController(text: currentName ?? '');
    final isEdit = editId != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: LegoTheme.blue, width: 2),
        ),
        title: Text(
          isEdit ? 'Rename Category' : 'New Category',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Ninjago',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LegoTheme.blue),
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              try {
                if (isEdit) {
                  await ref
                      .read(categoriesProvider.notifier)
                      .editCategory(editId, name);
                } else {
                  await ref
                      .read(categoriesProvider.notifier)
                      .addCategory(name);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit
                          ? 'Updated category to "$name"'
                          : 'Created category "$name"'),
                      backgroundColor: LegoTheme.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: LegoTheme.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LegoTheme.red,
        title: const Text(
          'Manage Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LegoTheme.yellow,
        foregroundColor: LegoTheme.black,
        onPressed: () => _showCategoryDialog(),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: categoriesAsync,
        emptyMessage: 'No categories yet. Tap + to add one!',
        isEmpty: (cats) => cats.isEmpty,
        data: (categories) {
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: categories.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: LegoTheme.yellow,
                    foregroundColor: LegoTheme.black,
                    child: Text(
                      '${cat.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: LegoTheme.blue),
                        onPressed: () => _showCategoryDialog(
                          editId: cat.id,
                          currentName: cat.name,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: LegoTheme.red),
                        onPressed: () async {
                          final ok = await showConfirmDeleteDialog(
                            context: context,
                            itemName: cat.name,
                            itemType: 'category',
                          );
                          if (ok == true) {
                            try {
                              await ref
                                  .read(categoriesProvider.notifier)
                                  .removeCategory(cat.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deleted "${cat.name}"'),
                                    backgroundColor: LegoTheme.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cannot delete category in use: $e'),
                                    backgroundColor: LegoTheme.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
