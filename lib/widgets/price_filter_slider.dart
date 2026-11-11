import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../utils/lego_theme.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LegoTheme.yellow, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header stud strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: LegoTheme.yellow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, size: 18, color: LegoTheme.black),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Price Filter (Bricks)',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: LegoTheme.black,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: LegoTheme.red,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$${_currentValues.start.toStringAsFixed(0)} - \$${_currentValues.end.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The Price Range Slider (LEGO Red active track)
                RangeSlider(
                  values: _currentValues,
                  min: ProductProvider.minAllowedPrice,
                  max: ProductProvider.maxAllowedPrice,
                  divisions: 40,
                  activeColor: LegoTheme.red,
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

                // Quick preset brick chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _LegoFilterChip(
                        label: 'All',
                        color: LegoTheme.blue,
                        isSelected: _currentValues.start == ProductProvider.minAllowedPrice &&
                            _currentValues.end == ProductProvider.maxAllowedPrice,
                        onTap: () => _applyQuickPreset(
                          ProductProvider.minAllowedPrice,
                          ProductProvider.maxAllowedPrice,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _LegoFilterChip(
                        label: 'Under \$50',
                        color: LegoTheme.green,
                        isSelected: _currentValues.start == 0 && _currentValues.end == 50,
                        onTap: () => _applyQuickPreset(0, 50),
                      ),
                      const SizedBox(width: 6),
                      _LegoFilterChip(
                        label: '\$50 - \$100',
                        color: LegoTheme.yellow,
                        textColor: LegoTheme.black,
                        isSelected: _currentValues.start == 50 && _currentValues.end == 100,
                        onTap: () => _applyQuickPreset(50, 100),
                      ),
                      const SizedBox(width: 6),
                      _LegoFilterChip(
                        label: '\$100 - \$200',
                        color: LegoTheme.red,
                        isSelected: _currentValues.start == 100 && _currentValues.end == 200,
                        onTap: () => _applyQuickPreset(100, 200),
                      ),
                      const SizedBox(width: 6),
                      _LegoFilterChip(
                        label: '\$200+',
                        color: LegoTheme.blue,
                        isSelected: _currentValues.start == 200 &&
                            _currentValues.end == ProductProvider.maxAllowedPrice,
                        onTap: () => _applyQuickPreset(
                          200,
                          ProductProvider.maxAllowedPrice,
                        ),
                      ),
                      if (provider.isFiltered) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => provider.resetFilters(),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close, size: 12, color: Colors.black87),
                                SizedBox(width: 2),
                                Text(
                                  'Reset',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegoFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LegoFilterChip({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.black.withValues(alpha: 0.3) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isSelected ? textColor : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}
