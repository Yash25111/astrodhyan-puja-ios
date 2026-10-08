import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_key_value.dart';
import '../../../widgets/app_rupee_amount.dart';
import '../../../widgets/app_text_field.dart';
import '../../bloc/history/history_bloc.dart';
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key, required this.id
  }
  );
  final String id;
  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
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
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a rating.')),
      );
      return;
    }
    context.read<HistoryBloc>().add(ReviewSubmitted(
    pujaId: pujaId,
    transactionId: widget.id,
    review: reviewController.text.trim(),
    rating: rating,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: const Text('Booking Details')),
    body: BlocListener<HistoryBloc, HistoryState>(
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
        );
      }
      if (state.reviewSuccess) {
        reviewController.clear();
        setState(() => rating = 0);
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    }
    ,
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
      detail.status,
      style: const TextStyle(
      color: AppColors.success,
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
      AppKeyValue(label: 'Date', value: detail.date),
      const SizedBox(height: 8),
      AppKeyValue(label: 'Time', value: detail.time),
      const SizedBox(height: 8),
      AppKeyValue(label: 'Location', value: detail.location),
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
      AppKeyValue(label: 'Package', value: detail.packageType),
      const SizedBox(height: 8),
      AppKeyValue(
      label: 'Package Price',
      value: '₹${detail.packagePrice}',
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
      const SizedBox(height: 12),
      AppCard(
      color: AppColors.cream,
      child: Column(
      children: [
      AppKeyValue(
      label: 'Order Amount',
      value: '₹${detail.orderAmount}',
      ),
      const SizedBox(height: 8),
      if (detail.discount > 0)
      AppKeyValue(
      label: 'Discount',
      value: '-₹${detail.discount}',
      valueColor: AppColors.success,
      ),
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
        onPressed: () => setState(() => rating = value.toDouble()),
        icon: Icon(
        value <= rating ? Icons.star : Icons.star_border,
        color: AppColors.secondary,
        size: 30,
        ),
        );
      }
      ),
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
    }
    ,
    ),
    ),
    );
  }
}
