import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app_colors.dart';
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
        key: order.key.isNotEmpty ? order.key : PaymentService.testKey,
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
                    const SizedBox(height: 6),
                    Text(
                      widget.data.packageType,
                      style: const TextStyle(color: AppColors.subheading),
                    ),
                    const SizedBox(height: 12),
                    AppKeyValue(label: 'Date', value: widget.data.date),
                    const SizedBox(height: 8),
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
                      child: CheckboxListTile(
                        value: selected,
                        onChanged: (_) {
                          setState(() {
                            if (selected) {
                              selectedOfferings.remove(offering.id);
                            } else {
                              selectedOfferings.add(offering.id);
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                        title: Text(
                          offering.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          offering.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: AppRupeeAmount(amount: offering.price),
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
                          decoration: const InputDecoration(
                            labelText: 'Gotram',
                          ),
                          validator: (value) =>
                              Validators.required(value, 'Gotram'),
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
