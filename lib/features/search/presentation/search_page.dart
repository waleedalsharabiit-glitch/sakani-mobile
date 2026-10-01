import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../properties/data/property_providers.dart';
import '../../properties/models/property.dart';
import '../../properties/presentation/property_card.dart';
import '../../properties/presentation/property_details_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  Timer? _debounce;

  String _query = '';
  String _sort = 'newest';
  String _city = '';
String _category = '';

  int _currentPage = 1;

  final List<Property> _properties = [];

  bool _isLoadingMore = false;
  bool _hasNextPage = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstPage();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 500) {
      _loadNextPage();
    }
  }

  
  Future<void> _loadFirstPage() async {
    if (!mounted) return;

    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasNextPage = false;
      _properties.clear();
    });

    try {
      final result = await ref.read(
       
  propertiesProvider(
    PropertyQuery(
      search: _query,
      city: _city.isEmpty ? null : _city,
      category: _category.isEmpty ? null : _category,
      sort: _sort,
      page: 1,
    ),
  ).future,

      );

      if (!mounted) return;

      setState(() {
        _properties.addAll(result.properties);
        _currentPage = result.page;
        _hasNextPage = result.hasNextPage;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isInitialLoading = false;
        _errorMessage = _cleanError(error);
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_isInitialLoading ||
        _isLoadingMore ||
        !_hasNextPage) {
      return;
    }

    final nextPage = _currentPage + 1;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final result = await ref.read(
       
  propertiesProvider(
    PropertyQuery(
      search: _query,
      city: _city.isEmpty ? null : _city,
      category: _category.isEmpty ? null : _category,
      sort: _sort,
      page: nextPage,
    ),
  ).future,
      );

      if (!mounted) return;

      setState(() {
        _properties.addAll(result.properties);
        _currentPage = result.page;
        _hasNextPage = result.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(error)),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadFirstPage();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        if (!mounted) return;

        setState(() {
          _query = value.trim();
        });

        _loadFirstPage();
      },
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _query = '';
    });

    _loadFirstPage();
  }

  void _changeSort(String value) {
    if (_sort == value) {
      return;
    }

    setState(() {
      _sort = value;
    });

    _loadFirstPage();
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'استكشف سَكَني',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
           _SearchHeader(
  controller: _searchController,
  sort: _sort,
  onSearchChanged: _onSearchChanged,
  onClear: _clearSearch,
  onSortChanged: _changeSort,
  onFilterPressed: _openFilters,
  hasFilters: _city.isNotEmpty || _category.isNotEmpty,
),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _properties.isEmpty) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: _loadFirstPage,
      );
    }

    if (_properties.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24,
        ),
        itemCount:
            _properties.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) {
          return const SizedBox(height: 14);
        },
        itemBuilder: (context, index) {
          if (index >= _properties.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          }

          final property = _properties[index];

          return PropertyCard(
            property: property,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsPage(
                    propertyId: property.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openFilters() async {
  final cityController = TextEditingController(text: _city);
  final categoryController = TextEditingController(
    text: _category,
  );

  final result = await showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'فلاتر البحث',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  hintText: 'مثال: تعز',
                  prefixIcon: Icon(
                    Icons.location_city_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  hintText: 'مثال: شقة',
                  prefixIcon: Icon(
                    Icons.category_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      {
                        'city': cityController.text.trim(),
                        'category':
                            categoryController.text.trim(),
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.filter_alt_rounded,
                  ),
                  label: const Text(
                    'تطبيق الفلاتر',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      {
                        'city': '',
                        'category': '',
                      },
                    );
                  },
                  child: const Text(
                    'مسح جميع الفلاتر',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  cityController.dispose();
  categoryController.dispose();

  if (result == null || !mounted) {
    return;
  }

  setState(() {
    _city = result['city'] ?? '';
    _category = result['category'] ?? '';
  });

  await _loadFirstPage();
}
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.sort,
    required this.onSearchChanged,
    required this.onClear,
    required this.onSortChanged,
    required this.onFilterPressed,
    required this.hasFilters,
  });

  final TextEditingController controller;
  final String sort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onFilterPressed;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      child: Column(
        children: [
        TextField(
  controller: controller,
  onChanged: onSearchChanged,
  textInputAction: TextInputAction.search,
  decoration: InputDecoration(
    hintText: 'ابحث عن عقار أو مدينة...',
    prefixIcon: const Icon(
      Icons.search_rounded,
    ),
    suffixIcon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.text.isNotEmpty)
          IconButton(
            onPressed: onClear,
            icon: const Icon(
              Icons.clear_rounded,
            ),
          ),
        IconButton(
          onPressed: onFilterPressed,
          icon: Icon(
            hasFilters
                ? Icons.filter_alt_rounded
                : Icons.filter_alt_outlined,
          ),
        ),
      ],
    ),
  ),
),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.sort_rounded,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'الترتيب:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sort,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'newest',
                        child: Text('الأحدث'),
                      ),
                      DropdownMenuItem(
                        value: 'price_low',
                        child: Text('السعر الأقل'),
                      ),
                      DropdownMenuItem(
                        value: 'price_high',
                        child: Text('السعر الأعلى'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onSortChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
            ),
            const SizedBox(height: 18),
            const Text(
              'لم نجد عقارات مطابقة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'جرّب البحث باسم مختلف أو مدينة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}