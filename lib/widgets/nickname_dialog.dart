import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pokemon.dart';
import '../providers/nickname_provider.dart';

/// Shows a dialog / bottom sheet to edit or remove a Pokémon's nickname
void showNicknameDialog(BuildContext context, WidgetRef ref, Pokemon pokemon) {
  final currentNickname = ref.read(nicknameProvider)[pokemon.id];
  final controller = TextEditingController(text: currentNickname ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E22),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFCE3A47),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nickname: ${pokemon.formattedName}',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Give your ${pokemon.formattedName} a custom nickname. Leave empty or press Remove to clear.',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.pixelifySans(
                fontSize: 18,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2B2B30),
                hintText: 'e.g. Sparky',
                hintStyle: GoogleFonts.pixelifySans(color: Colors.white38),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFCE3A47), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (currentNickname != null && currentNickname.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text(
                      'Remove',
                      style: GoogleFonts.pixelifySans(fontSize: 14),
                    ),
                    onPressed: () {
                      ref
                          .read(nicknameProvider.notifier)
                          .removeNickname(pokemon.id);
                      Navigator.of(ctx).pop();
                    },
                  ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.pixelifySans(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCE3A47),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();
                    ref
                        .read(nicknameProvider.notifier)
                        .setNickname(pokemon.id, text);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Save',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  ).whenComplete(() {
    controller.dispose();
  });
}
