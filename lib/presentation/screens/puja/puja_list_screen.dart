import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_appbar.dart';
import '../../../widgets/app_search_field.dart';
import '../../bloc/puja/puja_bloc.dart';
import '../../router/app_router.dart';
import 'widgets/puja_list_card.dart';

class PujaListScreen extends StatefulWidget {
  const PujaListScreen({super.key});

  @override
  State<PujaListScreen> createState() => _PujaListScreenState();
}

class _PujaListScreenState extends State<PujaListScreen> {
  final search = TextEditingController();
  final scroll = ScrollController();
  Timer? searchDebounce;

  @override
  void initState() {
    super.initState();
    search.text = context.read<PujaBloc>().state.search;
    context.read<PujaBloc>().add(const PujasRequested(refresh: true));
    scroll.addListener(() {
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 400) {
        context.read<PujaBloc>().add(const PujasMore());
      }
    });
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _queueSearch(String value) {
    searchDebounce?.cancel();
    final query = value.trim();
    final activeSearch = context.read<PujaBloc>().state.search;
    if (query.isNotEmpty && query.length < 3 && activeSearch.isEmpty) return;
    searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<PujaBloc>().add(
        SearchChanged(query.length >= 3 ? query : ''),
      );
    });
  }

  void _submitSearch(String value) {
    searchDebounce?.cancel();
    final query = value.trim();
    if (query.isNotEmpty && query.length < 3) return;
    context.read<PujaBloc>().add(SearchChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(titleText: 'All Pujas'),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<PujaBloc>().add(const PujasRequested(refresh: true));
        },
        child: CustomScrollView(
          controller: scroll,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(18),
              sliver: SliverToBoxAdapter(
                child: AppSearchField(
                  controller: search,
                  hintText: 'Search puja',
                  onChanged: _queueSearch,
                  onSubmitted: _submitSearch,
                ),
              ),
            ),
            BlocBuilder<PujaBloc, PujaState>(
              builder: (context, state) {
                if (state.loading && state.items.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.items.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.error ?? 'No pujas found')),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList.separated(
                    itemCount: state.items.length + (state.more ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final puja = state.items[index];
                      return PujaListCard(
                        puja: puja,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.detail,
                          arguments: puja.id,
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
