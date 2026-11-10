import 'package:flutter/material.dart';
import '../config.dart';

class AuthorFooter extends StatelessWidget {
  final bool onDark;
  const AuthorFooter({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = onDark ? Colors.white : cs.primary;
    return Center(
      heightFactor: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: fg.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.verified_rounded, size: 14, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text('© ${AppConfig.author}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
          ),
        ]),
      ),
    );
  }
}
