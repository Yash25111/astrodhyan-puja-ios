import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/models/order_result.dart';
import '../../../data/models/transaction.dart';
import '../../../services/payment_service.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_key_value.dart';
import '../../../widgets/app_rupee_amount.dart';
import '../../bloc/booking/booking_bloc.dart';
import '../../router/app_router.dart';

class PujaBookingScreen extends StatefulWidget {
  const PujaBookingScreen({super.key, required this.data});
  final BookingData data;
  @override
  State<PujaBookingScreen> createState() => _PujaBookingScreenState();
}

class _MemberForm {
  final name = TextEditingController();
  final gotram = TextEditingController();
  String gender = 'Male';
  bool useDefaultGotram = false;
  void dispose() {
    name.dispose();
    gotram.dispose();
  }
}

class _PujaBookingScreenState extends State<PujaBookingScreen> {
  final formKey = GlobalKey<FormState>();
  final selectedOfferings = <String>{};
  final storage = LocalStorage();
  late final PaymentService paymentService;
  late final List<_MemberForm> members;
  @override
  void initState() {
    super.initState();
    paymentService = PaymentService();
    members = List.generate(
      widget.data.members.clamp(1, 10).toInt(),
      (_) => _MemberForm(),
    );
  }

  @override
  void dispose() {
    paymentService.dispose();
    for (final member in members) {
      member.dispose();
    }
    super.dispose();
  }

  num get offeringsTotal => widget.data.offerings
      .where((offering) => selectedOfferings.contains(offering.id))
      .fold<num>(0, (sum, offering) => sum + offering.price);
  num get total => widget.data.packagePrice + offeringsTotal;

  void _toggleOffering(String offeringId, bool selected) {
    setState(() {
      if (selected) {
        selectedOfferings.remove(offeringId);
      } else {
        selectedOfferings.add(offeringId);
      }
    });
  }

  void _toggleDefaultGotram(_MemberForm member, bool value) {
    setState(() {
      member.useDefaultGotram = value;
      if (value) {
        member.gotram.text = 'Kashyap';
      } else if (member.gotram.text.trim().toLowerCase() == 'kashyap') {
        member.gotram.clear();
      }
    });
  }

  void _createOrder() {
    if (!formKey.currentState!.validate()) return;
    context.read<BookingBloc>().add(
      CreateOrder(
        pujaId: widget.data.pujaId,
        packageId: widget.data.packageId,
        offerings: selectedOfferings.toList(growable: false),
        members: members
            .map(
              (member) => MemberDetails(
                fullName: member.name.text.trim(),
                gender: member.gender,
                gotram: member.gotram.text.trim(),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  Future<void> _openPayment(OrderResult order) async {
    final contact = await storage.getString(LocalStorage.phone) ?? '';
    if (!mounted) return;
    try {
      final result = await paymentService.startCheckout(
        orderId: order.orderId,
        amountInRupees: order.totalAmount,
        contact: contact,
        key: PaymentService.liveKey,
        description: 'Pooja Booking Payment',
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRouter.success,
        arguments: SuccessData(
          orderId: result.orderId.isNotEmpty ? result.orderId : order.orderId,
          transactionId: order.transactionId,
          paymentId: result.paymentId,
          signature: result.signature,
          amount: order.totalAmount,
        ),
      );
      context.read<BookingBloc>().add(const ResetBooking());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'Book Puja'),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.success && state.order != null) {
            _openPayment(state.order!);
          }
        },
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppKeyValue(label: 'Location', value: widget.data.location),
                    const SizedBox(height: 8),
                    AppKeyValue(
                      label: 'Package',
                      value: '₹${widget.data.packagePrice}',
                    ),
                  ],
                ),
              ),
              if (widget.data.offerings.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Add Offerings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                ...widget.data.offerings.map((offering) {
                  final selected = selectedOfferings.contains(offering.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                      color: selected ? AppColors.cream : Colors.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _toggleOffering(offering.id, selected),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: CachedNetworkImage(
                                    imageUrl: ApiEndpoints.image(
                                      offering.image,
                                    ),
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => const ColoredBox(
                                      color: AppColors.paleOrange,
                                      child: Icon(
                                        Icons.local_florist_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      offering.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (offering.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        offering.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.subheading,
                                          fontSize: 12,
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    AppRupeeAmount(
                                      amount: offering.price,
                                      fontSize: 14,
                                      color: AppColors.primaryDark,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Checkbox(
                                value: selected,
                                activeColor: AppColors.primary,
                                onChanged: (_) =>
                                    _toggleOffering(offering.id, selected),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 18),
              const Text(
                'Member Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ...List.generate(members.length, (index) {
                final member = members[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: member.name,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                          ),
                          validator: (value) =>
                              Validators.required(value, 'Full name'),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: member.gender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => member.gender = value);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: member.gotram,
                          readOnly: member.useDefaultGotram,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          decoration: const InputDecoration(
                            labelText: 'Gotram',
                          ),
                          validator: (value) =>
                              Validators.required(value, 'Gotram'),
                        ),
                        CheckboxListTile(
                          value: member.useDefaultGotram,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          title: const Text(
                            "I don't know my gotram",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onChanged: (value) =>
                              _toggleDefaultGotram(member, value ?? false),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              AppCard(
                color: AppColors.cream,
                child: Column(
                  children: [
                    AppKeyValue(
                      label: 'Package',
                      value: '₹${widget.data.packagePrice}',
                    ),
                    const SizedBox(height: 8),
                    AppKeyValue(label: 'Offerings', value: '₹$offeringsTotal'),
                    const Divider(height: 24),
                    AppKeyValue(
                      label: 'Total',
                      value: '₹$total',
                      valueColor: AppColors.primaryDark,
                      valueSize: 19,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) => AppButton(
                  text: 'Create Order & Pay',
                  loading: state.loading,
                  width: double.infinity,
                  onPressed: _createOrder,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The server creates the Razorpay order first. Payment opens only after a valid order is returned.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 11),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
