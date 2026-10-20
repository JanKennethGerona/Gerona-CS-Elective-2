import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/type_filter_provider.dart';
import '../utils/type_colors.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(availableTypesProvider);
    final selected = ref.watch(selectedTypeProvider);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          // "All" chip to reset filter
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(
                'All Types',
                style: GoogleFonts.pixelifySans(
                  fontSize: 13,
                  fontWeight: selected == null ? FontWeight.bold : FontWeight.normal,
                  color: selected == null ? Colors.white : Colors.white70,
                ),
              ),
              selected: selected == null,
              selectedColor: const Color(0xFFCE3A47),
              backgroundColor: const Color(0xFF333338),
              side: BorderSide(
                color: selected == null
                    ? const Color(0xFFCE3A47)
                    : Colors.white.withValues(alpha: 0.15),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (_) {
                ref.read(selectedTypeProvider.notifier).state = null;
              },
            ),
          ),

          // Individual type chips
          for (final type in types)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Builder(builder: (context) {
                final isSelected = selected != null &&
                    selected.toLowerCase() == type.toLowerCase();
                final typeColor = getTypeColor(type);

                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: GoogleFonts.pixelifySans(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: typeColor,
                  backgroundColor: typeColor.withValues(alpha: 0.25),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.white
                        : typeColor.withValues(alpha: 0.5),
                    width: isSelected ? 1.5 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (bool selectedChip) {
                    ref.read(selectedTypeProvider.notifier).state =
                        isSelected ? null : type;
                  },
                );
              }),
            ),
        ],
      ),
    );
  }
}
