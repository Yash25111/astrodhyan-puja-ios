import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_colors.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/transaction.dart';
import '../../../services/time_format_service.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_pill.dart';
import '../../bloc/history/history_bloc.dart';
import '../../router/app_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryRequested());
    scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scroll.hasClients) return;
    if (scroll.position.pixels > scroll.position.maxScrollExtent - 320) {
      context.read<HistoryBloc>().add(const HistoryMoreRequested());
    }
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
  Widget build(BuildContext c) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HistoryBloc>().add(const HistoryRequested());
        },
        child: CustomScrollView(
          controller: scroll,
          slivers: [
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
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  sliver: SliverList.separated(
                    itemCount: s.items.length + (s.loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      if (i >= s.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final x = s.items[i];
                      return _BookingHistoryCard(
                        transaction: x,
                        onOpen: () => Navigator.pushNamed(
                          c,
                          AppRouter.transaction,
                          arguments: x.id,
                        ),
                        onVideo: x.videoUrl.isEmpty
                            ? null
                            : () => _openVideo(x.videoUrl),
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

class _BookingHistoryCard extends StatelessWidget {
  final PujaTransaction transaction;
  final VoidCallback onOpen;
  final VoidCallback? onVideo;

  const _BookingHistoryCard({
    required this.transaction,
    required this.onOpen,
    required this.onVideo,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 88,
                  height: 84,
                  child: CachedNetworkImage(
                    imageUrl: ApiEndpoints.image(transaction.image),
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: AppColors.cream,
                      child: Icon(Icons.temple_hindu, color: AppColors.primary),
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
                      transaction.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            TimeFormatService.formatDate(transaction.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.subheading,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill(status: transaction.status),
                        if (transaction.rating > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 15,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${transaction.rating.toStringAsFixed(1)}/5',
                                style: const TextStyle(
                                  color: AppColors.subheading,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        if (onVideo != null)
                          InkWell(
                            onTap: onVideo,
                            borderRadius: BorderRadius.circular(999),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.slow_motion_video,
                                size: 20,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (transaction.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Booked on ${TimeFormatService.formatDate(transaction.createdAt)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
