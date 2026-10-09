import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/booking_repository.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.items = const [],
    this.detail,
    this.loading = false,
    this.detailLoading = false,
    this.reviewSubmitting = false,
    this.reviewSuccess = false,
    this.loadingMore = false,
    this.more = false,
    this.page = 1,
    this.error,
  });
  final List<PujaTransaction> items;
  final TransactionDetail? detail;
  final bool loading;
  final bool detailLoading;
  final bool reviewSubmitting;
  final bool reviewSuccess;
  final bool loadingMore;
  final bool more;
  final int page;
  final String? error;

  HistoryState copyWith({
    List<PujaTransaction>? items,
    TransactionDetail? detail,
    bool? loading,
    bool? detailLoading,
    bool? reviewSubmitting,
    bool? reviewSuccess,
    bool? loadingMore,
    bool? more,
    int? page,
    String? error,
    bool clearDetail = false,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      detail: clearDetail ? null : detail ?? this.detail,
      loading: loading ?? this.loading,
      detailLoading: detailLoading ?? this.detailLoading,
      reviewSubmitting: reviewSubmitting ?? this.reviewSubmitting,
      reviewSuccess: reviewSuccess ?? this.reviewSuccess,
      loadingMore: loadingMore ?? this.loadingMore,
      more: more ?? this.more,
      page: page ?? this.page,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    items,
    detail,
    loading,
    detailLoading,
    reviewSubmitting,
    reviewSuccess,
    loadingMore,
    more,
    page,
    error,
  ];
}

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class HistoryRequested extends HistoryEvent {
  const HistoryRequested();
}

class HistoryMoreRequested extends HistoryEvent {
  const HistoryMoreRequested();
}

class TransactionRequested extends HistoryEvent {
  const TransactionRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ReviewSubmitted extends HistoryEvent {
  const ReviewSubmitted({
    required this.pujaId,
    required this.transactionId,
    required this.review,
    required this.rating,
  });
  final String pujaId;
  final String transactionId;
  final String review;
  final double rating;
  @override
  List<Object?> get props => [pujaId, transactionId, review, rating];
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this.repository) : super(const HistoryState()) {
    on<HistoryRequested>(_history);
    on<HistoryMoreRequested>(_more);
    on<TransactionRequested>(_detail);
    on<ReviewSubmitted>(_submitReview);
  }
  final BookingRepository repository;

  Future<void> _history(
    HistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true, page: 1));
    try {
      final items = await repository.history(page: 1);
      emit(
        state.copyWith(
          loading: false,
          items: items,
          page: 1,
          more: items.length >= BookingRepository.pageSize,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> _more(
    HistoryMoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state.loading || state.loadingMore || !state.more) return;
    emit(state.copyWith(loadingMore: true, clearError: true));
    try {
      final nextPage = state.page + 1;
      final items = await repository.history(page: nextPage);
      final existingIds = state.items.map((item) => item.id).toSet();
      final newItems = items
          .where((item) => !existingIds.contains(item.id))
          .toList();
      emit(
        state.copyWith(
          loadingMore: false,
          items: [...state.items, ...newItems],
          page: nextPage,
          more:
              newItems.isNotEmpty && items.length >= BookingRepository.pageSize,
        ),
      );
    } catch (error) {
      emit(state.copyWith(loadingMore: false, error: error.toString()));
    }
  }

  Future<void> _detail(
    TransactionRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(detailLoading: true, clearDetail: true, clearError: true),
    );
    try {
      final detail = await repository.transaction(event.id);
      emit(state.copyWith(detailLoading: false, detail: detail));
    } catch (error) {
      emit(state.copyWith(detailLoading: false, error: error.toString()));
    }
  }

  Future<void> _submitReview(
    ReviewSubmitted event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        reviewSubmitting: true,
        reviewSuccess: false,
        clearError: true,
      ),
    );
    try {
      await repository.review(
        pujaId: event.pujaId,
        transactionId: event.transactionId,
        text: event.review,
        rating: event.rating,
      );
      emit(state.copyWith(reviewSubmitting: false, reviewSuccess: true));
    } catch (error) {
      emit(state.copyWith(reviewSubmitting: false, error: error.toString()));
    }
  }
}
