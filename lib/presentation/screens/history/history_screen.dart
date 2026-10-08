import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../widgets/app_card.dart';
import '../../bloc/history/history_bloc.dart';
import '../../router/app_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryRequested());
  }

  @override
  Widget build(BuildContext c) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HistoryBloc>().add(const HistoryRequested());
        },
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'My Bookings',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            BlocBuilder<HistoryBloc, HistoryState>(
              builder: (c, s) {
                if (s.loading && s.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (s.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No puja bookings yet')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList.separated(
                    itemCount: s.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      final x = s.items[i];
                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            c,
                            AppRouter.transaction,
                            arguments: x.id,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    width: 78,
                                    height: 78,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiEndpoints.image(x.image),
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) =>
                                          const ColoredBox(
                                            color: AppColors.cream,
                                            child: Icon(
                                              Icons.temple_hindu,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        x.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        x.date,
                                        style: const TextStyle(
                                          color: AppColors.subheading,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.cream,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          x.status.isEmpty
                                              ? 'Pending'
                                              : x.status,
                                          style: const TextStyle(
                                            color: AppColors.primaryDark,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
