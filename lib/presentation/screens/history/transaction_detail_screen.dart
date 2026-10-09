import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../services/time_format_service.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_key_value.dart';
import '../../../widgets/app_rating.dart';
import '../../../widgets/app_rupee_amount.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/status_pill.dart';
import '../../bloc/history/history_bloc.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.id});
  final String id;
  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final reviewController = TextEditingController();
  double rating = 0;
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(TransactionRequested(widget.id));
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  void _submitReview(String pujaId) {
    if (rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating.')));
      return;
    }
    context.read<HistoryBloc>().add(
      ReviewSubmitted(
        pujaId: pujaId,
        transactionId: widget.id,
        review: reviewController.text.trim(),
        rating: rating,
      ),
    );
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid video link')));
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open video')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Booking Details'),
      body: BlocListener<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.reviewSuccess) {
            reviewController.clear();
            setState(() => rating = 0);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review submitted successfully')),
            );
          }
        },
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state.detailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final detail = state.detail;
            if (detail == null) {
              return Center(child: Text(state.error ?? 'Booking not found'));
            }
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          color: AppColors.cream,
                          image: detail.image.isEmpty
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(
                                    ApiEndpoints.image(detail.image),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: detail.image.isEmpty
                            ? const Icon(
                                Icons.temple_hindu,
                                size: 64,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.name,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detail.paymentStatus.isEmpty
                                  ? 'Payment status unavailable'
                                  : detail.paymentStatus,
                              style: const TextStyle(
                                color: AppColors.subheading,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Puja Information',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppKeyValue(
                        label: 'Date',
                        value: TimeFormatService.formatDate(detail.date),
                      ),
                      const SizedBox(height: 8),
                      AppKeyValue(
                        label: 'Time',
                        value: TimeFormatService.formatTime(detail.time),
                      ),
                      const SizedBox(height: 8),
                      AppKeyValue(label: 'Location', value: detail.location),
                      const SizedBox(height: 8),
                      _StatusKeyValue(
                        label: 'Puja Status',
                        status: detail.status,
                      ),
                      if (detail.rating > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Rating',
                                style: TextStyle(
                                  color: AppColors.subheading,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            AppRating(rating: detail.rating, starSize: 16),
                            const SizedBox(width: 6),
                            Text(
                              detail.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (detail.videoUrl.isNotEmpty) ...[
                        const Divider(height: 24),
                        InkWell(
                          onTap: () => _openVideo(detail.videoUrl),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.slow_motion_video,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Join Puja Video',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Package & Members',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (detail.packageType.isNotEmpty) ...[
                        AppKeyValue(
                          label: 'Package',
                          value: detail.packageType,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (detail.packagePrice > 0) ...[
                        AppKeyValue(
                          label: 'Package Price',
                          value: '₹${detail.packagePrice}',
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (detail.members.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No member details available.',
                            style: TextStyle(color: AppColors.subheading),
                          ),
                        ),
                      const SizedBox(height: 10),
                      ...detail.members.map(
                        (member) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            member.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('${member.gender} • ${member.gotram}'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (detail.offerings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Offerings',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...detail.offerings.map(
                          (offering) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offering.title.isEmpty
                                            ? 'Offering'
                                            : offering.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (offering.description.isNotEmpty)
                                        Text(
                                          offering.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.subheading,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${offering.price}',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                AppCard(
                  color: AppColors.cream,
                  child: Column(
                    children: [
                      AppKeyValue(
                        label: 'Order Amount',
                        value: '₹${detail.orderAmount}',
                      ),
                      if (detail.packagePrice > 0) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Package Amount',
                          value: '₹${detail.packagePrice}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (detail.discount > 0)
                        AppKeyValue(
                          label: 'Discount',
                          value: '-₹${detail.discount}',
                          valueColor: AppColors.success,
                        ),
                      if (detail.paymentStatus.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Payment Status',
                          value: detail.paymentStatus,
                        ),
                      ],
                      const Divider(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Total Amount',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          AppRupeeAmount(
                            amount: detail.total,
                            fontSize: 20,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                      if (detail.orderId.isNotEmpty) ...[
                        const Divider(height: 22),
                        AppKeyValue(label: 'Order ID', value: detail.orderId),
                      ],
                      if (detail.paymentId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Payment ID',
                          value: detail.paymentId,
                        ),
                      ],
                      if (detail.receiptId.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Receipt ID',
                          value: detail.receiptId,
                        ),
                      ],
                      if (detail.couponCode.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(label: 'Coupon', value: detail.couponCode),
                      ],
                      if (detail.createdAt.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Booked On',
                          value: TimeFormatService.formatDateTime(
                            detail.createdAt,
                          ),
                        ),
                      ],
                      if (detail.completedAt.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        AppKeyValue(
                          label: 'Completed On',
                          value: TimeFormatService.formatDateTime(
                            detail.completedAt,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate your experience',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          return IconButton(
                            onPressed: () =>
                                setState(() => rating = value.toDouble()),
                            icon: Icon(
                              value <= rating ? Icons.star : Icons.star_border,
                              color: AppColors.secondary,
                              size: 30,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: reviewController,
                        labelText: 'Write a review',
                        hintText: 'Tell us about your puja experience',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Submit Review',
                        loading: state.reviewSubmitting,
                        width: double.infinity,
                        onPressed: () => _submitReview(detail.pujaId),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusKeyValue extends StatelessWidget {
  final String label;
  final String status;

  const _StatusKeyValue({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.subheading, fontSize: 13),
          ),
        ),
        Flexible(child: StatusPill(status: status)),
      ],
    );
  }
}
