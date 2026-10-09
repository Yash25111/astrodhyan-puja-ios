import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/puja.dart';
import '../../../data/models/puja_detail.dart';
import '../../../data/repositories/puja_repository.dart';

class PujaState extends Equatable {
  final List<Puja> homeItems;
  final List<Puja> items;
  final List<Puja> specialPujas;
  final PujaDetail? detail;
  final bool homeLoading;
  final bool loading;
  final bool detailLoading;
  final bool more;
  final int page;
  final String lang;
  final String search;
  final String? error;

  const PujaState({
    this.homeItems = const [],
    this.items = const [],
    this.specialPujas = const [],
    this.detail,
    this.homeLoading = false,
    this.loading = false,
    this.detailLoading = false,
    this.more = false,
    this.page = 1,
    this.lang = 'en',
    this.search = '',
    this.error,
  });

  Puja? get specialPuja => specialPujas.isEmpty ? null : specialPujas.first;

  PujaState copy({
    List<Puja>? homeItems,
    List<Puja>? items,
    List<Puja>? specialPujas,
    PujaDetail? detail,
    bool? homeLoading,
    bool? loading,
    bool? detailLoading,
    bool? more,
    int? page,
    String? lang,
    String? search,
    String? error,
    bool clearSpecialPuja = false,
    bool clearDetail = false,
    bool clearError = false,
  }) {
    return PujaState(
      homeItems: homeItems ?? this.homeItems,
      items: items ?? this.items,
      specialPujas: clearSpecialPuja
          ? const []
          : specialPujas ?? this.specialPujas,
      detail: clearDetail ? null : detail ?? this.detail,
      homeLoading: homeLoading ?? this.homeLoading,
      loading: loading ?? this.loading,
      detailLoading: detailLoading ?? this.detailLoading,
      more: more ?? this.more,
      page: page ?? this.page,
      lang: lang ?? this.lang,
      search: search ?? this.search,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    homeItems,
    items,
    specialPujas,
    detail,
    homeLoading,
    loading,
    detailLoading,
    more,
    page,
    lang,
    search,
    error,
  ];
}

sealed class PujaEvent extends Equatable {
  const PujaEvent();

  @override
  List<Object?> get props => [];
}

class HomePujasRequested extends PujaEvent {
  final bool refresh;

  const HomePujasRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class PujasRequested extends PujaEvent {
  final bool refresh;

  const PujasRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class PujasMore extends PujaEvent {
  const PujasMore();
}

class SearchChanged extends PujaEvent {
  final String q;

  const SearchChanged(this.q);

  @override
  List<Object?> get props => [q];
}

class LanguageChanged extends PujaEvent {
  final String lang;

  const LanguageChanged(this.lang);

  @override
  List<Object?> get props => [lang];
}

class DetailRequested extends PujaEvent {
  final String id;

  const DetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class PujaBloc extends Bloc<PujaEvent, PujaState> {
  final PujaRepository repo;

  PujaBloc(this.repo) : super(const PujaState()) {
    on<HomePujasRequested>(_home);
    on<PujasRequested>(_list);
    on<PujasMore>(_more);
    on<SearchChanged>(_search);
    on<LanguageChanged>(_lang);
    on<DetailRequested>(_detail);
  }

  Future<void> _home(HomePujasRequested e, Emitter<PujaState> o) async {
    o(
      state.copy(
        homeLoading: true,
        clearError: true,
        homeItems: e.refresh ? [] : state.homeItems,
        clearSpecialPuja: e.refresh,
      ),
    );
    try {
      final x = await repo.home(lang: state.lang);
      o(
        state.copy(
          homeLoading: false,
          homeItems: x.pujas,
          specialPujas: x.specialPujas,
          clearSpecialPuja: x.specialPujas.isEmpty,
        ),
      );
    } catch (x) {
      o(state.copy(homeLoading: false, error: x.toString()));
    }
  }

  Future<void> _list(PujasRequested e, Emitter<PujaState> o) async {
    o(
      state.copy(
        loading: true,
        clearError: true,
        page: 1,
        items: e.refresh ? [] : state.items,
      ),
    );
    try {
      final x = await repo.list(
        page: 1,
        lang: state.lang,
        search: state.search,
      );
      o(
        state.copy(
          loading: false,
          items: x,
          page: 1,
          more: x.length >= PujaRepository.pageSize,
        ),
      );
    } catch (x) {
      o(state.copy(loading: false, error: x.toString()));
    }
  }

  Future<void> _more(PujasMore e, Emitter<PujaState> o) async {
    if (state.loading || state.more == false) return;
    o(state.copy(more: false));
    try {
      final x = await repo.list(
        page: state.page + 1,
        lang: state.lang,
        search: state.search,
      );
      final existingIds = state.items.map((p) => p.id).toSet();
      final newItems = x.where((p) => !existingIds.contains(p.id)).toList();
      o(
        state.copy(
          items: [...state.items, ...newItems],
          page: state.page + 1,
          more: newItems.isNotEmpty && x.length >= PujaRepository.pageSize,
        ),
      );
    } catch (x) {
      o(state.copy(more: false, error: x.toString()));
    }
  }

  Future<void> _search(SearchChanged e, Emitter<PujaState> o) async {
    final query = e.q.trim();
    if (query == state.search) return;
    o(state.copy(search: query));
    add(const PujasRequested(refresh: true));
  }

  Future<void> _lang(LanguageChanged e, Emitter<PujaState> o) async {
    if (e.lang == state.lang) return;
    o(state.copy(lang: e.lang));
    add(const HomePujasRequested(refresh: true));
    add(const PujasRequested(refresh: true));
  }

  Future<void> _detail(DetailRequested e, Emitter<PujaState> o) async {
    o(state.copy(detailLoading: true, clearDetail: true, clearError: true));
    try {
      o(
        state.copy(
          detailLoading: false,
          detail: await repo.detail(e.id, lang: state.lang),
        ),
      );
    } catch (x) {
      o(state.copy(detailLoading: false, error: x.toString()));
    }
  }
}
