import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/puja_detail.dart';
import '../../../services/time_format_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_rating.dart';
import '../../../widgets/app_rupee_amount.dart';
import '../../bloc/puja/puja_bloc.dart';
import '../../router/app_router.dart';

class PujaDetailScreen extends StatefulWidget {
  final String id;

  const PujaDetailScreen({super.key, required this.id});

  @override
  State<PujaDetailScreen> createState() => _PujaDetailScreenState();
}

class _PujaDetailScreenState extends State<PujaDetailScreen> {
  static const detailImageAspectRatio = 1241 / 620;

  int selected = 0;

  @override
  void initState() {
    super.initState();
    context.read<PujaBloc>().add(DetailRequested(widget.id));
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: BlocBuilder<PujaBloc, PujaState>(
        builder: (c, s) {
          if (s.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = s.detail;
          if (d == null) {
            return Center(child: Text(s.error ?? 'Unable to load puja'));
          }
          final pkgs = d.packages;
          final packageIndex = pkgs.isEmpty
              ? 0
              : selected.clamp(0, pkgs.length - 1).toInt();
          final pkg = pkgs.isEmpty ? null : pkgs[packageIndex];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:
                    (MediaQuery.sizeOf(c).width / detailImageAspectRatio).clamp(
                      190.0,
                      240.0,
                    ),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: ApiEndpoints.image(
                      d.banners.isNotEmpty
                          ? d.banners.first
                          : d.puja.bannerImage,
                    ),
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: AppColors.cream,
                      child: Icon(
                        Icons.temple_hindu,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.puja.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        AppRupeeAmount(
                          amount: pkg?.price ?? d.puja.actualPrice,
                          fontSize: 20,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppRating(rating: d.rating),
                        const SizedBox(width: 6),
                        Text(
                          d.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d.puja.shortDescription,
                      style: const TextStyle(
                        color: AppColors.subheading,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _info(
                          Icons.calendar_month,
                          'Date',
                          TimeFormatService.formatDate(d.puja.pujaDate),
                        ),
                        const SizedBox(width: 10),
                        _info(
                          Icons.location_on_outlined,
                          'Location',
                          d.puja.location,
                        ),
                      ],
                    ),
                    if (pkgs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Choose your package',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        pkgs.length,
                        (i) => _packageTile(i, pkgs[i]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _PujaInfoTabs(detail: d),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: BlocBuilder<PujaBloc, PujaState>(
        builder: (c, s) {
          final d = s.detail;
          if (d == null) return const SizedBox.shrink();
          final packageIndex = d.packages.isEmpty
              ? 0
              : selected.clamp(0, d.packages.length - 1).toInt();
          final pkg = d.packages.isEmpty ? null : d.packages[packageIndex];

          return Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 14, color: Color(0x18000000))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Starting from',
                        style: TextStyle(fontSize: 11, color: AppColors.grey),
                      ),
                      AppRupeeAmount(
                        amount: pkg?.price ?? d.puja.actualPrice,
                        color: AppColors.primaryDark,
                        fontSize: 19,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: AppButton(
                    text: 'Book This Puja',
                    onPressed: () => Navigator.pushNamed(
                      c,
                      AppRouter.booking,
                      arguments: BookingData(
                        pujaId: d.puja.id,
                        title: d.puja.title,
                        date: d.puja.pujaDate,
                        location: d.puja.location,
                        packageId: pkg?.id ?? '',
                        packageType: pkg?.type ?? 'Standard',
                        packagePrice: pkg?.price ?? d.puja.actualPrice,
                        members: pkg?.members ?? 1,
                        offerings: d.offerings
                            .map(
                              (x) => BookingOffering(
                                id: x.id,
                                title: x.title,
                                description: x.description,
                                image: x.image,
                                price: x.price,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _packageTile(int i, PujaPackage package) {
    final isSelected = i == selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: EdgeInsets.zero,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        color: isSelected ? AppColors.cream : AppColors.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => selected = i),
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
            title: Text(
              package.type,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('${package.members} member(s)'),
            trailing: AppRupeeAmount(amount: package.price),
          ),
        ),
      ),
    );
  }
}

class _PujaInfoTabs extends StatefulWidget {
  final PujaDetail detail;

  const _PujaInfoTabs({required this.detail});

  @override
  State<_PujaInfoTabs> createState() => _PujaInfoTabsState();
}

class _PujaInfoTabsState extends State<_PujaInfoTabs>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
    controller.addListener(() {
      if (controller.index != selectedTab) {
        setState(() => selectedTab = controller.index);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.primaryDark,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Benefits'),
              Tab(text: 'Process'),
              Tab(text: 'FAQ'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _tabContent(selectedTab),
        ),
      ],
    );
  }

  Widget _tabContent(int index) {
    final d = widget.detail;
    return KeyedSubtree(
      key: ValueKey(index),
      child: switch (index) {
        0 => _AboutTab(
          text: d.about.isEmpty ? d.puja.shortDescription : d.about,
        ),
        1 => _BenefitsTab(benefits: d.benefits),
        2 => _ProcessTab(steps: d.steps),
        _ => _FaqTab(faqs: d.faqs),
      },
    );
  }
}

class _AboutTab extends StatelessWidget {
  final String text;

  const _AboutTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.isEmpty ? 'No information available.' : text,
      style: const TextStyle(color: AppColors.subheading, height: 1.5),
    );
  }
}

class _BenefitsTab extends StatelessWidget {
  final List<PujaBenefit> benefits;

  const _BenefitsTab({required this.benefits});

  @override
  Widget build(BuildContext context) {
    if (benefits.isEmpty) return const _EmptyInfoText('No benefits available.');
    return Column(
      children: benefits
          .map(
            (b) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: AppColors.primary),
              title: Text(
                b.header,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(b.description),
            ),
          )
          .toList(),
    );
  }
}

class _ProcessTab extends StatelessWidget {
  final List<PujaStep> steps;

  const _ProcessTab({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const _EmptyInfoText('No puja process available.');
    }
    return Column(
      children: steps
          .map(
            (x) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  '${x.number}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(
                x.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(x.description),
            ),
          )
          .toList(),
    );
  }
}

class _FaqTab extends StatelessWidget {
  final List<PujaFaq> faqs;

  const _FaqTab({required this.faqs});

  @override
  Widget build(BuildContext context) {
    if (faqs.isEmpty) return const _EmptyInfoText('No FAQs available.');
    return Column(
      children: faqs
          .map(
            (x) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                x.question,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      x.answer,
                      style: const TextStyle(color: AppColors.subheading),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _EmptyInfoText extends StatelessWidget {
  final String text;

  const _EmptyInfoText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: const TextStyle(color: AppColors.grey)),
    );
  }
}

Widget _info(IconData i, String t, String v) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(i, size: 18, color: AppColors.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t,
                  style: const TextStyle(fontSize: 10, color: AppColors.grey),
                ),
                Text(
                  v.isEmpty ? 'Not available' : v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
