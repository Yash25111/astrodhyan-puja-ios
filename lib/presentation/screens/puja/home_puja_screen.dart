import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/puja.dart';
import '../../../widgets/app_search_field.dart';
import '../../bloc/puja/puja_bloc.dart';
import '../../router/app_router.dart';
import 'widgets/puja_list_card.dart';

class HomePujaScreen extends StatefulWidget {
  const HomePujaScreen({super.key});

  @override
  State<HomePujaScreen> createState() => _HomePujaScreenState();
}

class _HomePujaScreenState extends State<HomePujaScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    search.text = context.read<PujaBloc>().state.search;
    context.read<PujaBloc>().add(const HomePujasRequested());
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
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
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(18),
              sliver: SliverToBoxAdapter(
                child: AppSearchField(
                  controller: search,
                  hintText: 'Search puja',
                  onSubmitted: (v) {
                    context.read<PujaBloc>().add(SearchChanged(v));
                  },
                ),
              ),
            ),

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
                        height: 178,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: s.specialPujas.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final puja = s.specialPujas[index];
                            return SizedBox(
                              width: MediaQuery.sizeOf(context).width - 36,
                              child: _SpecialPujaBanner(
                                puja: puja,
                                onTap: () => Navigator.pushNamed(
                                  c,
                                  AppRouter.detail,
                                  arguments: puja.id,
                                ),
                              ),
                            );
                          },
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

class _SpecialPujaBanner extends StatelessWidget {
  final Puja puja;
  final VoidCallback onTap;

  const _SpecialPujaBanner({required this.puja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: AppColors.primary,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 178,
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
                // const DecoratedBox(
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [Color(0xDD3B1709), Color(0x33000000)],
                //       begin: Alignment.bottomCenter,
                //       end: Alignment.topCenter,
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(18),
                //   child: Align(
                //     alignment: Alignment.bottomLeft,
                //     child: Text(
                //       puja.title,
                //       maxLines: 2,
                //       overflow: TextOverflow.ellipsis,
                //       style: const TextStyle(
                //         color: Colors.white,
                //         fontSize: 22,
                //         fontWeight: FontWeight.w800,
                //         height: 1.15,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
