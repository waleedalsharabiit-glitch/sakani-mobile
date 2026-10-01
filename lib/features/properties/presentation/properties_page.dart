import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../data/property_providers.dart';
import '../models/property_list_response.dart';
import 'property_card.dart';
import 'property_details_page.dart';

class PropertiesPage extends ConsumerStatefulWidget {
  const PropertiesPage({super.key});

  @override
  ConsumerState<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends ConsumerState<PropertiesPage> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String? _city;
  String? _category;
  String _sort = 'newest';
  int _page = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PropertyQuery get _query {
    return PropertyQuery(
      search: _search,
      city: _city,
      category: _category,
      sort: _sort,
      page: _page,
    );
  }

  void _performSearch() {
    FocusScope.of(context).unfocus();

    setState(() {
      _search = _searchController.text.trim();
      _page = 1;
    });
  }

  void _clearFilters() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchController.clear();
      _search = '';
      _city = null;
      _category = null;
      _sort = 'newest';
      _page = 1;
    });
  }

  Future<void> _openAddPropertyContact() async {
    final uri = Uri(scheme: 'tel', path: '734705920');

    try {
      final launched = await launchUrl(uri);

      if (!launched && mounted) {
        _showMessage('تعذر فتح تطبيق الاتصال');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('تعذر فتح تطبيق الاتصال');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFilters() async {
    final cityController = TextEditingController(text: _city ?? '');

    final categoryController = TextEditingController(text: _category ?? '');

    var selectedSort = _sort;

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'تصفية العقارات',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'المدينة',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cityController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'مثال: عدن',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        suffixIcon: cityController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  cityController.clear();
                                  setSheetState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'التصنيف',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'مثال: شقق',
                        prefixIcon: const Icon(Icons.category_outlined),
                        suffixIcon: categoryController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  categoryController.clear();
                                  setSheetState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'الترتيب',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue: selectedSort,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.sort_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('الأحدث'),
                        ),
                        DropdownMenuItem(
                          value: 'price_low',
                          child: Text('السعر: من الأقل'),
                        ),
                        DropdownMenuItem(
                          value: 'price_high',
                          child: Text('السعر: من الأعلى'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setSheetState(() {
                          selectedSort = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              cityController.clear();
                              categoryController.clear();

                              setSheetState(() {
                                selectedSort = 'newest';
                              });
                            },
                            child: const Text('مسح'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(sheetContext).pop(
                                _FilterResult(
                                  city: cityController.text.trim().isEmpty
                                      ? null
                                      : cityController.text.trim(),
                                  category:
                                      categoryController.text.trim().isEmpty
                                      ? null
                                      : categoryController.text.trim(),
                                  sort: selectedSort,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('تطبيق الفلاتر'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    cityController.dispose();
    categoryController.dispose();

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _city = result.city;
      _category = result.category;
      _sort = result.sort;
      _page = 1;
    });
  }

  void _nextPage(PropertyListResponse response) {
    if (!response.hasNextPage) {
      return;
    }

    setState(() {
      _page++;
    });
  }

  void _previousPage(PropertyListResponse response) {
    if (_page <= 1) {
      return;
    }

    setState(() {
      _page--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider(_query));

    final hasFilters =
        _search.isNotEmpty ||
        _city != null ||
        _category != null ||
        _sort != 'newest';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('العقارات'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تصفية',
            onPressed: _openFilters,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded),
                if (hasFilters)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(propertiesProvider(_query));

          await ref.read(propertiesProvider(_query).future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _SearchSection(
                controller: _searchController,
                onSearch: _performSearch,
                onFilter: _openFilters,
                hasFilters: hasFilters,
                onClearFilters: _clearFilters,
              ),
            ),

            SliverToBoxAdapter(
              child: _AddPropertyNotice(onCall: _openAddPropertyContact),
            ),

            propertiesAsync.when(
              loading: () {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              error: (error, stackTrace) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    error: error,
                    onRetry: () {
                      ref.invalidate(propertiesProvider(_query));
                    },
                  ),
                );
              },
              data: (response) {
                if (response.properties.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyProperties(
                      hasFilters: hasFilters,
                      onClear: _clearFilters,
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _ResultsHeader(response: response, sort: _sort),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      sliver: SliverList.builder(
                        itemCount: response.properties.length,
                        itemBuilder: (context, index) {
                          final property = response.properties[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PropertyCard(
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
                            ),
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Pagination(
                        response: response,
                        onPrevious: () {
                          _previousPage(response);
                        },
                        onNext: () {
                          _nextPage(response);
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({
    required this.controller,
    required this.onSearch,
    required this.onFilter,
    required this.hasFilters,
    required this.onClearFilters,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'ابحث عن شقة، فيلا، غرفة...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        controller.clear();
                        onSearch();
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFilter,
                  icon: const Icon(Icons.tune_rounded, size: 19),
                  label: const Text('الفلاتر والترتيب'),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'مسح الفلاتر',
                  onPressed: onClearFilters,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                  ),
                  icon: const Icon(Icons.filter_alt_off_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPropertyNotice extends StatelessWidget {
  const _AddPropertyNotice({required this.onCall});

  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.add_home_work_outlined,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هل لديك عقار ترغب في إضافته؟',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'لإضافة عقارك إلى منصة سَكَني، '
                      'تواصل معنا وسنساعدك في إدراجه '
                      'على المنصة.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
              label: const Text(
                '734705920',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.response, required this.sort});

  final PropertyListResponse response;
  final String sort;

  String get _sortLabel {
    switch (sort) {
      case 'price_low':
        return 'الأقل سعرًا';
      case 'price_high':
        return 'الأعلى سعرًا';
      default:
        return 'الأحدث';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'ar');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          const Text(
            'العقارات المتاحة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              formatter.format(response.total),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          Text(
            _sortLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.response,
    required this.onPrevious,
    required this.onNext,
  });

  final PropertyListResponse response;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    if (response.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: response.page > 1 ? onPrevious : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            Expanded(
              child: Text(
                'الصفحة ${response.page} من '
                '${response.totalPages}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: response.hasNextPage ? onNext : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProperties extends StatelessWidget {
  const _EmptyProperties({required this.hasFilters, required this.onClear});

  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilters ? 'لم نجد عقارات مطابقة' : 'لا توجد عقارات حاليًا',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'جرّب تغيير كلمات البحث أو الفلاتر.'
                  : 'ستظهر العقارات المضافة هنا.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('مسح الفلاتر'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error.toString().replaceFirst('Exception: ', '');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل العقارات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({
    required this.city,
    required this.category,
    required this.sort,
  });

  final String? city;
  final String? category;
  final String sort;
}
