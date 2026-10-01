import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../data/booking_providers.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  const CreateBookingPage({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.pricePerDay,
  });

  final String propertyId;
  final String propertyTitle;
  final double pricePerDay;

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final _dateFormat = DateFormat('yyyy/MM/dd');

  int get _days {
    if (_startDate == null || _endDate == null) {
      return 0;
    }

    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice {
    return _days * widget.pricePerDay;
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _startDate = date;

      if (_endDate != null && !_endDate!.isAfter(date)) {
        _endDate = null;
      }
    });
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر تاريخ الوصول أولاً')));
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _endDate = date;
    });
  }

  Future<void> _createBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ الوصول والمغادرة')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final booking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(
            propertyId: widget.propertyId,
            startDate: _startDate!,
            endDate: _endDate!,
          );

      if (!mounted) {
        return;
      }

      ref.invalidate(bookingsProvider);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'تم إنشاء الحجز بنجاح — ${booking.totalPrice.toStringAsFixed(0)} ريال',
    ),
  ),
);

Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز العقار'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.propertyTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              '${widget.pricePerDay.toStringAsFixed(0)} ريال / يوم',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'تاريخ الوصول',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            _DateButton(
              text: _startDate == null
                  ? 'اختر تاريخ الوصول'
                  : _dateFormat.format(_startDate!),
              icon: Icons.login_rounded,
              onPressed: _selectStartDate,
            ),

            const SizedBox(height: 20),

            const Text(
              'تاريخ المغادرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            _DateButton(
              text: _endDate == null
                  ? 'اختر تاريخ المغادرة'
                  : _dateFormat.format(_endDate!),
              icon: Icons.logout_rounded,
              onPressed: _selectEndDate,
            ),

            const SizedBox(height: 30),

            if (_days > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _SummaryRow(title: 'عدد الأيام', value: '$_days يوم'),
                    const SizedBox(height: 14),
                    _SummaryRow(
                      title: 'السعر اليومي',
                      value: '${widget.pricePerDay.toStringAsFixed(0)} ريال',
                    ),
                    const Divider(height: 28),
                    _SummaryRow(
                      title: 'الإجمالي',
                      value: '${_totalPrice.toStringAsFixed(0)} ريال',
                      highlighted: true,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _createBooking,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _isLoading ? 'جاري إنشاء الحجز...' : 'تأكيد الحجز',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Align(
          alignment: Alignment.centerRight,
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.value,
    this.highlighted = false,
  });

  final String title;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: highlighted ? AppColors.primary : AppColors.textPrimary,
            fontSize: highlighted ? 19 : 15,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
