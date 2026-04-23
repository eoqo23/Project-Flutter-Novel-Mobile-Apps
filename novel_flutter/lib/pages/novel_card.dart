import 'package:flutter/material.dart';
import '../models/novel.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;

  const NovelCard({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey[300],
        image: novel.cover.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(novel.cover),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: novel.cover.isEmpty
          ? const Center(
              child: Icon(Icons.image_not_supported),
            )
          : null,
    );
  }
}