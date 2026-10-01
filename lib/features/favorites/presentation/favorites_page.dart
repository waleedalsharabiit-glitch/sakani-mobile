import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../properties/presentation/property_details_page.dart';
import '../data/favorite_providers.dart';
import '../models/favorite.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static const String _serverUrl = 'http://10.0.2.2:3000';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: favorites.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(favoritesProvider);
          },
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesProvider);
              await ref.read(favoritesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _FavoriteCard(
                  favorite: items[index],
                  serverUrl: _serverUrl,
                  onRemoved: () {
                    ref.invalidate(favoritesProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends ConsumerStatefulWidget {
  const _FavoriteCard({
    required this.favorite,
    required this.serverUrl,
    required this.onRemoved,
  });

  final Favorite favorite;
  final String serverUrl;
  final VoidCallback onRemoved;

  @override
  ConsumerState<_FavoriteCard> createState() =>
      _FavoriteCardState();
}

class _FavoriteCardState
    extends ConsumerState<_FavoriteCard> {
  bool _isRemoving = false;

  String _imageUrl(String? image) {
    if (image == null || image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    return '${widget.serverUrl}$image';
  }

  Future<void> _remove() async {
    if (_isRemoving) return;

    setState(() {
      _isRemoving = true;
    });

    try {
      await ref
          .read(favoriteRepositoryProvider)
          .removeFavorite(widget.favorite.property.id);

      ref.invalidate(favoritesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العقار من المفضلة'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.favorite.property;
    final imageUrl = _imageUrl(property.image);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailsPage(
                propertyId: property.id,
              ),
            ),
          );
        },
        child: SizedBox(
          height: 130,
          child: Row(
            children: [
              SizedBox(
                width: 125,
                height: double.infinity,
                child: imageUrl.isEmpty
                    ? const _ImagePlaceholder()
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            const _ImagePlaceholder(
                          loading: true,
                        ),
                        errorWidget: (_, _, _) =>
                            const _ImagePlaceholder(),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _isRemoving ? null : _remove,
                            icon: _isRemoving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.favorite_rounded,
                                    color: AppColors.danger,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color:
                                AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.city,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${NumberFormat('#,##0').format(property.price)} ريال / يوم',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    this.loading = false,
  });

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: loading
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.image_outlined,
                color: AppColors.textMuted,
                size: 32,
              ),
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
              Icons.favorite_border_rounded,
              size: 72,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 18),
            const Text(
              'لا توجد عقارات مفضلة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف العقارات التي تعجبك إلى المفضلة لتجدها هنا بسهولة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
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
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل المفضلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst(
                'Exception: ',
                '',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}