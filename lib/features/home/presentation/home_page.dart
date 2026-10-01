import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/main_shell.dart';
import '../../auth/data/auth_controller.dart';
import '../../properties/data/property_providers.dart';
import '../../properties/models/property.dart';
import '../../properties/presentation/property_card.dart';
import '../../properties/presentation/property_details_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    final propertiesAsync = ref.watch(
      propertiesProvider(
        const PropertyQuery(
          sort: 'newest',
          page: 1,
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                propertiesProvider(
                  const PropertyQuery(
                    sort: 'newest',
                    page: 1,
                  ),
                ),
              );

              await ref.read(
                propertiesProvider(
                  const PropertyQuery(
                    sort: 'newest',
                    page: 1,
                  ),
                ).future,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(
                    userName: user?.name,
                    onProfilePressed: () {
                      MainShell.of(context)?.goToTab(4);
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      0,
                    ),
                    child: _SearchBanner(
                      onTap: () {
                        MainShell.of(context)?.goToTab(1);
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      28,
                      20,
                      14,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'أحدث العقارات',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            MainShell.of(context)?.goToTab(1);
                          },
                          child: const Text('عرض الكل'),
                        ),
                      ],
                    ),
                  ),
                ),

                propertiesAsync.when(
                  loading: () {
                    return const SliverToBoxAdapter(
                      child: _PropertiesLoading(),
                    );
                  },
                  error: (error, _) {
                    return SliverToBoxAdapter(
                      child: _PropertiesError(
                        onRetry: () {
                          ref.invalidate(
                            propertiesProvider(
                              const PropertyQuery(
                                sort: 'newest',
                                page: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  data: (result) {
                    if (result.properties.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: _EmptyProperties(),
                      );
                    }

                    return SliverToBoxAdapter(
                      child: _PropertiesSection(
                        properties: result.properties,
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      28,
                      20,
                      24,
                    ),
                    child: _QuickActions(
                      onSearch: () {
                        MainShell.of(context)?.goToTab(1);
                      },
                      onFavorites: () {
                        MainShell.of(context)?.goToTab(2);
                      },
                      onBookings: () {
                        MainShell.of(context)?.goToTab(3);
                      },
                      onProfile: () {
                        MainShell.of(context)?.goToTab(4);
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.onProfilePressed,
  });

  final String? userName;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final displayName =
        userName?.trim().isNotEmpty == true
            ? userName!.trim()
            : 'المستخدم';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onProfilePressed,
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBanner extends StatelessWidget {
  const _SearchBanner({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ابحث عن عقار، مدينة أو منطقة...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                size: 21,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertiesSection extends StatelessWidget {
  const _PropertiesSection({
    required this.properties,
  });

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 315,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: properties.length,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final property = properties[index];

          return SizedBox(
            width: 300,
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
    );
  }
}

class _PropertiesLoading extends StatelessWidget {
  const _PropertiesLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 315,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (_, _) {
          return Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class _PropertiesError extends StatelessWidget {
  const _PropertiesError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 45,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل العقارات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _EmptyProperties extends StatelessWidget {
  const _EmptyProperties();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      child: Column(
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 52,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد عقارات حالياً',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onSearch,
    required this.onFavorites,
    required this.onBookings,
    required this.onProfile,
  });

  final VoidCallback onSearch;
  final VoidCallback onFavorites;
  final VoidCallback onBookings;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصول السريع',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.search_rounded,
                title: 'البحث',
                onTap: onSearch,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.favorite_rounded,
                title: 'المفضلة',
                onTap: onFavorites,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'حجوزاتي',
                onTap: onBookings,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.person_rounded,
                title: 'حسابي',
                onTap: onProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: primary,
                size: 28,
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}