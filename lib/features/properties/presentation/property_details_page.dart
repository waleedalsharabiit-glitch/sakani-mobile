
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../reviews/data/review_providers.dart';
import '../../reviews/models/review.dart';
import '../../../app/theme/app_colors.dart';
import '../../bookings/presentation/create_booking_page.dart';
import '../../favorites/data/favorite_providers.dart';
import '../data/property_providers.dart';
import '../models/property_details.dart';
import '../../reviews/presentation/review_dialog.dart';
import '../../auth/data/auth_controller.dart';

class PropertyDetailsPage extends ConsumerStatefulWidget {
  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });

  final String propertyId;

  static const _serverUrl = 'http://10.0.2.2:3000';

  @override
  ConsumerState<PropertyDetailsPage> createState() =>
      _PropertyDetailsPageState();
}

class _PropertyDetailsPageState
    extends ConsumerState<PropertyDetailsPage> {
  bool _isLoadingFavorite = false;

  String _imageUrl(String url) {
    if (url.startsWith('http://') ||
        url.startsWith('https://')) {
      return url;
    }

    return '${PropertyDetailsPage._serverUrl}$url';
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) {
      return;
    }

    final favoriteIds = ref.read(favoriteIdsProvider);
    final isFavorite =
        favoriteIds.contains(widget.propertyId);

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final repository = ref.read(
        favoriteRepositoryProvider,
      );

      if (isFavorite) {
        await repository.removeFavorite(
          widget.propertyId,
        );
      } else {
        await repository.addFavorite(
          widget.propertyId,
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
    final propertyAsync = ref.watch(
      propertyDetailsProvider(widget.propertyId),
    );

    final favoriteIds = ref.watch(favoriteIdsProvider);
    final isFavorite =
        favoriteIds.contains(widget.propertyId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل العقار'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Material(
              color: AppColors.surface,
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
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
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
                                : AppColors.textPrimary,
                            size: 23,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: propertyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(
              propertyDetailsProvider(widget.propertyId),
            );
          },
        ),
        data: (property) {
          return _DetailsContent(
            property: property,
            imageUrlBuilder: _imageUrl,
          );
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.property,
    required this.imageUrlBuilder,
  });

  final PropertyDetails property;
  final String Function(String) imageUrlBuilder;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _ImageGallery(
            images: property.images,
            imageUrlBuilder: imageUrlBuilder,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _CategoryBadge(
                text: property.category.name,
              ),
              const SizedBox(height: 14),
              Text(
                property.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${property.city} - ${property.address}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PriceCard(
                price: property.price,
              ),
              const SizedBox(height: 20),
              _RatingCard(
                average: property.rating.average,
                count: property.rating.count,
              ),
              if (property.description != null &&
                  property.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 28),
                const _SectionTitle(title: 'الوصف'),
                const SizedBox(height: 10),
                Text(
                  property.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.8,
                    fontSize: 15,
                  ),
                ),
              ],
              if (property.amenities.isNotEmpty) ...[
                const SizedBox(height: 28),
                const _SectionTitle(title: 'المرافق'),
                const SizedBox(height: 12),
                _Amenities(
                  amenities: property.amenities,
                ),
              ],
              const SizedBox(height: 28),
              const _SectionTitle(title: 'المالك'),
              const SizedBox(height: 12),
              _OwnerCard(
                owner: property.owner,
                imageUrlBuilder: imageUrlBuilder,
              ),
              _ReviewsSection(
  propertyId: property.id,
),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateBookingPage(
                          propertyId: property.id,
                          propertyTitle: property.title,
                          pricePerDay: property.price,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text(
                    'احجز الآن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.imageUrlBuilder,
  });

  final List<PropertyImage> images;
  final String Function(String) imageUrlBuilder;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 260,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Icon(
            Icons.home_work_outlined,
            size: 70,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index];

          return Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: imageUrlBuilder(image.url),
                fit: BoxFit.cover,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 60,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.price,
  });

  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          const Text(
            'السعر',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '${price.toStringAsFixed(0)} ريال',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.average,
    required this.count,
  });

  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: AppColors.warning,
          size: 25,
        ),
        const SizedBox(width: 6),
        Text(
          average.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '($count تقييم)',
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Amenities extends StatelessWidget {
  const _Amenities({
    required this.amenities,
  });

  final List<PropertyAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map(
        (amenity) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Text(
              amenity.name,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({
    required this.owner,
    required this.imageUrlBuilder,
  });

  final PropertyOwner owner;
  final String Function(String) imageUrlBuilder;

  @override
  Widget build(BuildContext context) {
    final image = owner.image;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.background,
            backgroundImage:
                image != null && image.isNotEmpty
                    ? CachedNetworkImageProvider(
                        imageUrlBuilder(image),
                      )
                    : null,
            child: image == null || image.isEmpty
                ? const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              owner.name?.trim().isNotEmpty == true
                  ? owner.name!
                  : 'مالك العقار',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  final Object error;
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
              size: 60,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل تفاصيل العقار',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
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



class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({
    required this.propertyId,
  });

  final String propertyId;

  Future<void> _openAddReview(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ReviewDialog(
        propertyId: propertyId,
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة تقييمك بنجاح'),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final reviewsAsync = ref.watch(
      reviewsProvider(propertyId),
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),

        Row(
          children: [
            const Expanded(
              child: _SectionTitle(
                title: 'التقييمات والمراجعات',
              ),
            ),
            TextButton.icon(
              onPressed: () => _openAddReview(context),
              icon: const Icon(
                Icons.rate_review_outlined,
                size: 18,
              ),
              label: const Text('قيّم العقار'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        reviewsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.danger,
                  size: 30,
                ),
                const SizedBox(height: 8),
                const Text(
                  'تعذر تحميل التقييمات',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(
                      reviewsProvider(propertyId),
                    );
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (response) {
            if (response.reviews.isEmpty) {
              return const _EmptyReviews();
            }

            return Column(
              children: [
                _ReviewsSummary(
                  averageRating:
                      response.averageRating,
                  count: response.count,
                ),
                const SizedBox(height: 12),
                ...response.reviews.map(
                  (review) => _ReviewItem(
                    review: review,
                    propertyId: propertyId,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}





class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({
    required this.averageRating,
    required this.count,
  });

  final double averageRating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Text(
            '$count مراجعة',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
class _ReviewItem extends ConsumerStatefulWidget {
  const _ReviewItem({
    required this.review,
    required this.propertyId,
  });

  final Review review;
  final String propertyId;

  @override
  ConsumerState<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends ConsumerState<_ReviewItem> {
  bool _isDeleting = false;

  Future<void> _edit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ReviewDialog(
        propertyId: widget.propertyId,
        existingReviewId: widget.review.id,
        initialRating: widget.review.rating,
        initialComment: widget.review.comment,
      ),
    );

    if (result == true && mounted) {
      ref.invalidate(reviewsProvider(widget.propertyId));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف المراجعة'),
          content: const Text(
            'هل أنت متأكد من حذف هذه المراجعة؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref
          .read(reviewRepositoryProvider)
          .deleteReview(widget.review.id);

      ref.invalidate(reviewsProvider(widget.propertyId));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المراجعة بنجاح'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.value;

    final isOwner =
        currentUser != null &&
        currentUser.id == widget.review.user.id;

    final review = widget.review;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(
                  alpha: 0.15,
                ),
                child: Text(
                  (review.user.name?.trim().isNotEmpty ?? false)
                      ? review.user.name!.trim()[0].toUpperCase()
                      : '؟',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name?.trim().isNotEmpty == true
                          ? review.user.name!
                          : 'مستخدم',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 17,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // تظهر أزرار التحكم فقط لصاحب المراجعة.
              if (isOwner)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _isDeleting ? null : _edit,
                      tooltip: 'تعديل',
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                    ),
                    IconButton(
                      onPressed: _isDeleting ? null : _delete,
                      tooltip: 'حذف',
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                    ),
                  ],
                ),
            ],
          ),

          if (review.comment != null &&
              review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            color: AppColors.textMuted,
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            'لا توجد مراجعات بعد',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}