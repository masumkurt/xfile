import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/file_manager_state.dart';

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FileManagerState>();
    final parts = state.currentPath.split('/').where((p) => p.isNotEmpty).toList();

    return Container(
      height: 36,
      color: const Color(0xFF0F3460),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: parts.length + 1,
        separatorBuilder: (_, __) => Icon(
          Icons.chevron_right_rounded,
          size: 14,
          color: Colors.white.withOpacity(0.3),
        ),
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return InkWell(
              onTap: () => state.navigateTo('/storage/emulated/0'),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  'Depolama',
                  style: TextStyle(
                    fontSize: 12,
                    color: i == parts.length
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.45),
                  ),
                ),
              ),
            );
          }
          final segment = parts[i - 1];
          final isLast = i == parts.length;
          final pathUpTo = '/${parts.sublist(0, i).join('/')}';

          return InkWell(
            onTap: isLast ? null : () => state.navigateTo(pathUpTo),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                segment,
                style: TextStyle(
                  fontSize: 12,
                  color: isLast
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.45),
                  fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
