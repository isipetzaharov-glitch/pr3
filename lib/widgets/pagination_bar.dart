import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          IconButton(
            tooltip: 'Первая',
            onPressed: page > 1 ? () => onPageChanged(1) : null,
            icon: const Icon(Icons.first_page),
          ),
          IconButton(
            tooltip: 'Назад',
            onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Стр. $page из $totalPages  (всего: $total)'),
          IconButton(
            tooltip: 'Вперёд',
            onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
          IconButton(
            tooltip: 'Последняя',
            onPressed: page < totalPages
                ? () => onPageChanged(totalPages)
                : null,
            icon: const Icon(Icons.last_page),
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: size,
            items: const [
              DropdownMenuItem(value: 10, child: Text('10 / стр.')),
              DropdownMenuItem(value: 25, child: Text('25 / стр.')),
              DropdownMenuItem(value: 50, child: Text('50 / стр.')),
            ],
            onChanged: (v) => v != null ? onSizeChanged(v) : null,
          ),
        ],
      ),
    );
  }
}
