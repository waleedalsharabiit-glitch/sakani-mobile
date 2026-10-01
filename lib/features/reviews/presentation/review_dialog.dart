import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../data/review_providers.dart';

class ReviewDialog extends ConsumerStatefulWidget {
  const ReviewDialog({
    super.key,
    required this.propertyId,
    this.existingReviewId,
    this.initialRating = 0,
    this.initialComment,
  });

  final String propertyId;
  final String? existingReviewId;
  final int initialRating;
  final String? initialComment;

  bool get isEditing => existingReviewId != null;

  @override
  ConsumerState<ReviewDialog> createState() =>
      _ReviewDialogState();
}

class _ReviewDialogState
    extends ConsumerState<ReviewDialog> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _rating = widget.initialRating;

    _commentController = TextEditingController(
      text: widget.initialComment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      _showMessage('اختر عدد النجوم أولاً');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(
        reviewRepositoryProvider,
      );

      if (widget.isEditing) {
        await repository.updateReview(
          reviewId: widget.existingReviewId!,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
      } else {
        await repository.addReview(
          propertyId: widget.propertyId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
      }

      ref.invalidate(
        reviewsProvider(widget.propertyId),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.isEditing
              ? 'تعديل التقييم'
              : 'قيّم هذا العقار',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ما تقييمك لهذا العقار؟',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) {
                    final star = index + 1;

                    return IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _rating = star;
                              });
                            },
                      icon: Icon(
                        star <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 38,
                        color: AppColors.warning,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                enabled: !_isLoading,
                maxLines: 4,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب تجربتك وتعليقك...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.isEditing
                        ? 'حفظ التعديل'
                        : 'إرسال التقييم',
                  ),
          ),
        ],
      ),
    );
  }
}