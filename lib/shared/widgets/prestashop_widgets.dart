// Widgets UI pour PrestaShop - Phase 4
// Components Flutter réutilisables pour l'affichage des données

import 'package:flutter/material.dart';
import 'package:koutonou/core/theme.dart';

/// Card générique pour afficher un élément PrestaShop
class PrestaShopItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isActive;
  final Color? backgroundColor;

  const PrestaShopItemCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.actions,
    this.isActive = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: backgroundColor ?? (isActive ? null : Colors.grey.shade100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isActive ? null : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isActive
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 4, children: actions!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste générique avec pull-to-refresh et pagination
class PrestaShopListView<T> extends StatefulWidget {
  final Future<List<T>> Function() onRefresh;
  final Future<List<T>> Function(int page)? onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final bool enablePullToRefresh;
  final bool enablePagination;
  final String? title;

  const PrestaShopListView({
    super.key,
    required this.onRefresh,
    required this.itemBuilder,
    this.onLoadMore,
    this.emptyWidget,
    this.errorWidget,
    this.enablePullToRefresh = true,
    this.enablePagination = false,
    this.title,
  });

  @override
  State<PrestaShopListView<T>> createState() => _PrestaShopListViewState<T>();
}

class _PrestaShopListViewState<T> extends State<PrestaShopListView<T>> {
  List<T> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.enablePagination && widget.onLoadMore != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.onRefresh();
      setState(() {
        _items = items;
        _currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreItems = await widget.onLoadMore!(_currentPage + 1);
      setState(() {
        _items.addAll(moreItems);
        _currentPage++;
      });
    } catch (e) {
      // Ignorer les erreurs de pagination
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun élément',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'La liste est vide',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
    }

    Widget listView = ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      listView = RefreshIndicator(onRefresh: _loadData, child: listView);
    }

    return listView;
  }
}

/// Chip de statut avec couleurs appropriées
class StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor ?? Colors.green.shade100)
            : (inactiveColor ?? Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? (activeColor ?? Colors.green.shade300)
              : (inactiveColor ?? Colors.grey.shade400),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green.shade800 : Colors.grey.shade700,
        ),
      ),
    );
  }
}

/// Widget d'information avec icône
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: content,
    );
  }
}

/// Bouton d'action coloré
class ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isOutlined;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon, size: 16) : const SizedBox.shrink()),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : (icon != null ? Icon(icon, size: 16) : const SizedBox.shrink()),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Widget de recherche avec filtres
class SearchFilterBar extends StatefulWidget {
  final Function(String query, Map<String, String> filters) onSearch;
  final List<FilterOption>? filterOptions;
  final String? initialQuery;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    this.filterOptions,
    this.initialQuery,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _controller;
  final Map<String, String> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    widget.onSearch(_controller.text, _activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _performSearch();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        if (widget.filterOptions != null && widget.filterOptions!.isNotEmpty)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.filterOptions!.length,
              itemBuilder: (context, index) {
                final option = widget.filterOptions![index];
                final isActive = _activeFilters.containsKey(option.key);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option.label),
                    selected: isActive,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _activeFilters[option.key] = option.value;
                        } else {
                          _activeFilters.remove(option.key);
                        }
                      });
                      _performSearch();
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Option de filtre
class FilterOption {
  final String key;
  final String label;
  final String value;

  const FilterOption({
    required this.key,
    required this.label,
    required this.value,
  });
}
