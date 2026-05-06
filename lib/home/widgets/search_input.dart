import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/di/locator.dart';
import '../models/filme_list_viewmodel.dart';

/// SearchInput — campo de busca com debounce de 500ms.
///
/// Extraído de HomeScreen para separar responsabilidades.
/// Quando o usuário para de digitar por 500ms, envia a query
/// para o FilmeListViewModel via `setSearchQuery`.
class SearchInput extends StatefulWidget {
  const SearchInput({super.key});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      getIt<FilmeListViewModel>().setSearchQuery(_searchController.text);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    getIt<FilmeListViewModel>().setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) {
          return TextField(
            controller: _searchController,
            onChanged: (_) => _scheduleSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Buscar por título ou gênero…',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: scheme.primary,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: _clearSearch,
                      tooltip: 'Limpar busca',
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
