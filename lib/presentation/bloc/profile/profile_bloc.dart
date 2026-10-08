import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';
class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.loading = false,
    this.updating = false,
    this.error,
    this.updateSuccess = false,
  }
  );
  final UserProfile? profile;
  final bool loading;
  final bool updating;
  final String? error;
  final bool updateSuccess;
  ProfileState copyWith({
    UserProfile? profile,
    bool? loading,
    bool? updating,
    String? error,
    bool? updateSuccess,
    bool clearError = false,
  }
  ) {
    return ProfileState(
    profile: profile ?? this.profile,
    loading: loading ?? this.loading,
    updating: updating ?? this.updating,
    error: clearError ? null : error ?? this.error,
    updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
  @override
  List<Object?> get props => [profile, loading, updating, error, updateSuccess];
}
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}
class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}
class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
    required this.name,
    required this.email,
    required this.gender,
    this.imagePath,
  }
  );
  final String name;
  final String email;
  final String gender;
  final String? imagePath;
  @override
  List<Object?> get props => [name, email, gender, imagePath];
}
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this.repository) : super(const ProfileState()) {
    on<ProfileRequested>(_getProfile);
    on<ProfileUpdateRequested>(_updateProfile);
  }
  final ProfileRepository repository;
  Future<void> _getProfile(
  ProfileRequested event,
  Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final profile = await repository.get();
      emit(state.copyWith(loading: false, profile: profile));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }
  Future<void> _updateProfile(
  ProfileUpdateRequested event,
  Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updating: true, updateSuccess: false, clearError: true));
    try {
      final profile = await repository.update(
      name: event.name,
      email: event.email,
      gender: event.gender,
      imagePath: event.imagePath,
      );
      emit(state.copyWith(
      updating: false,
      profile: profile,
      updateSuccess: true,
      ));
    } catch (error) {
      emit(state.copyWith(updating: false, error: error.toString()));
    }
  }
}
