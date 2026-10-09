import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/puja.dart';
import '../../bloc/puja/puja_bloc.dart';
import '../../router/app_router.dart';
import 'widgets/puja_list_card.dart';

class HomePujaScreen extends StatefulWidget {
  const HomePujaScreen({super.key});

  @override
  State<HomePujaScreen> createState() => _HomePujaScreenState();
}

class _HomePujaScreenState extends State<HomePujaScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PujaBloc>().add(const HomePujasRequested());
  }

  @override
  Widget build(BuildContext c) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<PujaBloc>().add(const HomePujasRequested(refresh: true));
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.cream,
                      child: Icon(
                        Icons.local_florist_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'May your day be blessed',
                            style: TextStyle(
                              color: AppColors.subheading,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(c, AppRouter.notifications),
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            BlocBuilder<PujaBloc, PujaState>(
              builder: (c, s) {
                if (s.homeLoading &&
                    s.homeItems.isEmpty &&
                    s.specialPujas.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (s.error != null &&
                    s.homeItems.isEmpty &&
                    s.specialPujas.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(s.error!)),
                  );
                }

                final visibleItems = s.homeItems.take(6).toList();
                return SliverList(
                  delegate: SliverChildListDelegate([
                    if (s.specialPujas.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: Text(
                          'Special Pujas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 218,
                        child: _SpecialPujaCarousel(
                          pujas: s.specialPujas,
                          onTap: (puja) => Navigator.pushNamed(
                            c,
                            AppRouter.detail,
                            arguments: puja.id,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          const Text(
                            'Puja List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(c, AppRouter.pujaList);
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                    if (visibleItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(child: Text('No pujas found')),
                      )
                    else
                      ...visibleItems.map(
                        (p) => Padding(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                          child: PujaListCard(
                            puja: p,
                            onTap: () => Navigator.pushNamed(
                              c,
                              AppRouter.detail,
                              arguments: p.id,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialPujaCarousel extends StatefulWidget {
  final List<Puja> pujas;
  final ValueChanged<Puja> onTap;

  const _SpecialPujaCarousel({required this.pujas, required this.onTap});

  @override
  State<_SpecialPujaCarousel> createState() => _SpecialPujaCarouselState();
}

class _SpecialPujaCarouselState extends State<_SpecialPujaCarousel> {
  late final PageController controller;
  Timer? timer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant _SpecialPujaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pujas.length != widget.pujas.length) {
      currentIndex = 0;
      if (controller.hasClients) {
        controller.jumpToPage(0);
      }
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    timer?.cancel();
    if (widget.pujas.length < 2) return;
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !controller.hasClients) return;
      final nextPage = (currentIndex + 1) % widget.pujas.length;
      controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller,
            padEnds: false,
            itemCount: widget.pujas.length,
            onPageChanged: (index) => setState(() => currentIndex = index),
            itemBuilder: (context, index) {
              final puja = widget.pujas[index];
              return AnimatedPadding(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  left: index == 0 ? 18 : 6,
                  right: index == widget.pujas.length - 1 ? 18 : 6,
                ),
                child: _SpecialPujaBanner(
                  puja: puja,
                  onTap: () => widget.onTap(puja),
                ),
              );
            },
          ),
        ),
        if (widget.pujas.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pujas.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: index == currentIndex ? 22 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == currentIndex
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SpecialPujaBanner extends StatelessWidget {
  final Puja puja;
  final VoidCallback onTap;

  const _SpecialPujaBanner({required this.puja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: AppColors.primary,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: ApiEndpoints.image(puja.bannerImage),
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: AppColors.primary,
                      child: Icon(
                        Icons.temple_hindu,
                        color: Colors.white54,
                        size: 72,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xAA260B00),
                          Color(0x33260B00),
                          Color(0x00260B00),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xD9000000), Color(0x00000000)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        puja.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
