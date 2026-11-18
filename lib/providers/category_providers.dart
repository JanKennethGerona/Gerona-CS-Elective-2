import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'auth_providers.dart';

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final service = ref.watch(supabaseServiceProvider);
    final raw = await service.fetchCategories();
    return raw.map((c) => Category.fromJson(c)).toList();
  }

  Future<void> addCategory(String name) async {
    final service = ref.read(supabaseServiceProvider);
    await service.createCategory(name);
    ref.invalidateSelf();
    await future;
  }

  Future<void> editCategory(int id, String name) async {
    final service = ref.read(supabaseServiceProvider);
    await service.updateCategory(id, name);
    ref.invalidateSelf();
    await future;
  }

  Future<void> removeCategory(int id) async {
    final service = ref.read(supabaseServiceProvider);
    await service.deleteCategory(id);
    ref.invalidateSelf();
    await future;
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(() {
  return CategoriesNotifier();
});
