import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class PriceFilterSlider extends StatefulWidget {
  const PriceFilterSlider({super.key});

  @override
  State<PriceFilterSlider> createState() => _PriceFilterSliderState();
}

class _PriceFilterSliderState extends State<PriceFilterSlider> {
  late RangeValues _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = context.read<ProductProvider>().priceRange;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providerRange = context.watch<ProductProvider>().priceRange;
    _currentValues = providerRange;
  }

  void _applyQuickPreset(double min, double max) {
    setState(() {
      _currentValues = RangeValues(min, max);
    });
    context.read<ProductProvider>().setPriceRange(RangeValues(min, max));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.grey.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Price Range Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${_currentValues.start.toStringAsFixed(0)} - \$${_currentValues.end.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // The Price Range Slider
            RangeSlider(
              values: _currentValues,
              min: ProductProvider.minAllowedPrice,
              max: ProductProvider.maxAllowedPrice,
              divisions: 40,
              activeColor: theme.colorScheme.primary,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '\$${_currentValues.start.toStringAsFixed(0)}',
                '\$${_currentValues.end.toStringAsFixed(0)}',
              ),
              onChanged: (RangeValues newValues) {
                setState(() {
                  _currentValues = newValues;
                });
              },
              onChangeEnd: (RangeValues finalValues) {
                provider.setPriceRange(finalValues);
              },
            ),

            // Quick preset chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    label: 'All',
                    isSelected: _currentValues.start == ProductProvider.minAllowedPrice &&
                        _currentValues.end == ProductProvider.maxAllowedPrice,
                    onTap: () => _applyQuickPreset(
                      ProductProvider.minAllowedPrice,
                      ProductProvider.maxAllowedPrice,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _PresetChip(
                    label: 'Under \$50',
                    isSelected: _currentValues.start == 0 && _currentValues.end == 50,
                    onTap: () => _applyQuickPreset(0, 50),
                  ),
                  const SizedBox(width: 6),
                  _PresetChip(
                    label: '\$50 - \$100',
                    isSelected: _currentValues.start == 50 && _currentValues.end == 100,
                    onTap: () => _applyQuickPreset(50, 100),
                  ),
                  const SizedBox(width: 6),
                  _PresetChip(
                    label: '\$100 - \$200',
                    isSelected: _currentValues.start == 100 && _currentValues.end == 200,
                    onTap: () => _applyQuickPreset(100, 200),
                  ),
                  const SizedBox(width: 6),
                  _PresetChip(
                    label: '\$200+',
                    isSelected: _currentValues.start == 200 &&
                        _currentValues.end == ProductProvider.maxAllowedPrice,
                    onTap: () => _applyQuickPreset(
                      200,
                      ProductProvider.maxAllowedPrice,
                    ),
                  ),
                  if (provider.isFiltered) ...[
                    const SizedBox(width: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Reset', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        provider.resetFilters();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
