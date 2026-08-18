import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// Router configuration demonstrating nested routing
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const FruitListPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'fruit/:name',
          builder: (BuildContext context, GoRouterState state) {
            final String fruitName = state.pathParameters['name'] ?? 'unknown';
            return FruitDetailPage(fruitName: fruitName);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Fruit Router App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  final List<Map<String, String>> fruits = const [
    {'name': 'apple', 'display': 'Apple', 'icon': '🍎'},
    {'name': 'banana', 'display': 'Banana', 'icon': '🍌'},
    {'name': 'pineapple', 'display': 'Pineapple', 'icon': '🍍'},
    {'name': 'strawberry', 'display': 'Strawberry', 'icon': '🍓'},
    {'name': 'watermelon', 'display': 'Watermelon', 'icon': '🍉'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final fruit in fruits)
                          ListTile(
                            leading: Text(
                              fruit['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            title: Text(fruit['display']!),
                            onTap: () {
                              context.go('/fruit/${fruit['name']}');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FruitDetailPage extends StatelessWidget {
  final String fruitName;

  const FruitDetailPage({super.key, required this.fruitName});

  Map<String, String> _getFruitData(String name) {
    switch (name.toLowerCase()) {
      case 'apple':
        return {'title': 'Apple', 'icon': '🍎'};
      case 'banana':
        return {'title': 'Banana', 'icon': '🍌'};
      case 'orange':
        return {'title': 'Orange', 'icon': '🍊'};
      case 'strawberry':
        return {'title': 'Strawberry', 'icon': '🍓'};
      case 'watermelon':
        return {'title': 'Watermelon', 'icon': '🍉'};
      default:
        return {'title': name, 'icon': '🍇'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final fruitData = _getFruitData(fruitName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(fruitData['icon']!, style: const TextStyle(fontSize: 120)),
            const SizedBox(height: 20),
            Text(
              fruitData['title']!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: /fruit/$fruitName',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
