import 'dart:async';

import 'package:flutter/material.dart';

class MicrobusinessFilterBar extends StatefulWidget {
  const MicrobusinessFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.initialSearch,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });

  final List<String> categories;
  final String? selectedCategory;
  final String initialSearch;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  State<MicrobusinessFilterBar> createState() => _MicrobusinessFilterBarState();
}

class _MicrobusinessFilterBarState extends State<MicrobusinessFilterBar> {
  late final TextEditingController _searchCtrl;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant MicrobusinessFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearch != widget.initialSearch &&
        _searchCtrl.text != widget.initialSearch) {
      _searchCtrl.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchInput(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: _onSearchInput,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar por nombre',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterButton(
                label: 'Todas',
                selected: widget.selectedCategory == null,
                onPressed: () => widget.onCategoryChanged(null),
              ),
              const SizedBox(width: 8),
              ...widget.categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterButton(
                    label: cat,
                    selected: widget.selectedCategory == cat,
                    onPressed: () => widget.onCategoryChanged(cat),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final background = selected
        ? theme.colorScheme.secondaryContainer
        : theme.colorScheme.surface;

    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: selected ? const Icon(Icons.check, size: 16) : const SizedBox(),
        label: Text(label),
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          minimumSize: const Size(76, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
