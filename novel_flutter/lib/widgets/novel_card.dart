import 'package:flutter/material.dart';
import '../models/novel.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;

  const NovelCard({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 160,
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          novel.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}