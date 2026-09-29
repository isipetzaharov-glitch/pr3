import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final showCheckbox = onToggleSelect != null;
    final showActions = actions != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Двумерная прокрутка — таблица не уезжает за край окна
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _sortColumnIndex(),
                sortAscending: sortAscending,
                columns: [
                  if (showCheckbox) const DataColumn(label: Text('')),
                  for (var i = 0; i < columns.length; i++)
                    DataColumn(
                      label: Text(columns[i].label),
                      numeric: columns[i].numeric,
                      onSort: columns[i].sortField != null && onSort != null
                          ? (_, _) => onSort!(columns[i].sortField!)
                          : null,
                    ),
                  if (showActions) const DataColumn(label: Text('Действия')),
                ],
                rows: [
                  for (final item in items)
                    DataRow(
                      selected: selected.contains(idOf(item)),
                      cells: [
                        if (showCheckbox)
                          DataCell(
                            Checkbox(
                              value: selected.contains(idOf(item)),
                              onChanged: (_) => onToggleSelect!(idOf(item)),
                            ),
                          ),
                        for (final c in columns) DataCell(c.build(item)),
                        if (showActions)
                          DataCell(Row(children: actions!(item))),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int? _sortColumnIndex() {
    if (sortField == null) return null;
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].sortField == sortField) {
        return i + 1; // +1 из-за колонки чекбокса
      }
    }
    return null;
  }
}
