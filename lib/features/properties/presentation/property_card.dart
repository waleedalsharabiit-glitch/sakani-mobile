import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../favorites/data/favorite_providers.dart';
import '../models/property.dart';

class PropertyCard extends ConsumerStatefulWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  final Property property;
  final VoidCallback onTap;

  static const _serverUrl = 'http://10.0.2.2:3000';

  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  bool _isLoadingFavorite = false;

  String? get imageUrl {
    final image = widget.property.image;

    if (image == null || image.isEmpty) {
      return null;
    }

    if (image.startsWith('http')) {
      return image;
    }

    return '${PropertyCard._serverUrl}$image';
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) {
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final favoriteIds = ref.read(favoriteIdsProvider);
      final isFavorite =
          favoriteIds.contains(widget.property.id);

      final repository = ref.read(
        favoriteRepositoryProvider,
      );

      if (isFavorite) {
        await repository.removeFavorite(
          widget.property.id,
        );
      } else {
        await repository.addFavorite(
          widget.property.id,
        );
      }

      ref.invalidate(favoritesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1200),
            content: Text(
              isFavorite
                  ? 'تم حذف العقار من المفضلة'
                  : 'تمت إضافة العقار إلى المفضلة',
            ),
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
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.##', 'ar');

    final favoriteIds = ref.watch(favoriteIdsProvider);
    final isFavorite =
        favoriteIds.contains(widget.property.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (_, _, _) {
                        return const _ImagePlaceholder();
                      },
                    )
                  else
                    const _ImagePlaceholder(),

                  // التصنيف
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(
                          alpha: 0.82,
                        ),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.property.category.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // زر المفضلة
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Material(
                      color: AppColors.background.withValues(
                        alpha: 0.82,
                      ),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isLoadingFavorite
                            ? null
                            : _toggleFavorite,
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: _isLoadingFavorite
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons
                                            .favorite_border_rounded,
                                    color: isFavorite
                                        ? AppColors.danger
                                        : AppColors.white,
                                    size: 23,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // عدد الصور
                  if (widget.property.imagesCount > 0)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.background.withValues(
                            alpha: 0.82,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.property.imagesCount}',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${widget.property.city} - ${widget.property.address}',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color:
                                AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${formatter.format(widget.property.price)} ريال',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Spacer(),

                      if (widget.property.reviewsCount > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.property.reviewsCount}',
                              style: const TextStyle(
                                color:
                                    AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 56,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}