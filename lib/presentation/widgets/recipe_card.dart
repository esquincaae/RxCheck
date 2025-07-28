import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/recipe.dart';
import '../screens/recipe_detail_screen.dart';
import 'custom_card.dart';
import '../viewmodels/recipe_detail_viewmodel.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 72,
      onTap: () {
        // Antes de navegar aseguramos que el VM está limpio
        context.read<RecipeDetailViewModel>().medications = [];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recipe.issueAt,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
