import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
enum AuthStatus{
  unknown,unauthenticated,authenticated
}
class AuthState extends Equatable{
  final AuthStatus status;
  final bool loading;
  final String? error;
  final String? phone;
  const AuthState({
    this.status=AuthStatus.unknown,this.loading=false,this.error,this.phone
  }
  );
  AuthState copy({
    AuthStatus?status,bool?loading,String?error,String?phone,bool clearError=false
  }
  )=>AuthState(status:status??this.status,loading:loading??this.loading,error:clearError?null:error??this.error,phone:phone??this.phone);
  @override List<Object?>get props=>[status,loading,error,phone];
}
sealed class AuthEvent extends Equatable{
  const AuthEvent();
  @override List<Object?>get props=>[];
}
class AuthStarted extends AuthEvent{
  const AuthStarted();
}
class LoginRequested extends AuthEvent{
  final String phone;
  const LoginRequested(this.phone);
  @override List<Object?>get props=>[phone];
}
class OtpRequested extends AuthEvent{
  final String phone,otp;
  const OtpRequested(this.phone,this.otp);
  @override List<Object?>get props=>[phone,otp];
}
class LogoutRequested extends AuthEvent{
  const LogoutRequested();
}
class AuthBloc extends Bloc<AuthEvent,AuthState>{
  final AuthRepository repo;
  AuthBloc(this.repo):super(const AuthState()){
    on<AuthStarted>(_start);
    on<LoginRequested>(_login);
    on<OtpRequested>(_otp);
    on<LogoutRequested>(_logout);
  }
  Future<void>_start(AuthStarted e,Emitter<AuthState>o)async{
    o(state.copy(status:await repo.hasSession()?AuthStatus.authenticated:AuthStatus.unauthenticated));
  }
  Future<void>_login(LoginRequested e,Emitter<AuthState>o)async{
    o(state.copy(loading:true,phone:e.phone,clearError:true));
    try{
      await repo.login(e.phone);
      o(state.copy(loading:false));
    } catch(x){
      o(state.copy(loading:false,error:x.toString()));
    }
  }
  Future<void>_otp(OtpRequested e,Emitter<AuthState>o)async{
    o(state.copy(loading:true,clearError:true));
    try{
      await repo.verify(e.phone,e.otp);
      o(state.copy(loading:false,status:AuthStatus.authenticated));
    } catch(x){
      o(state.copy(loading:false,error:x.toString()));
    }
  }
  Future<void>_logout(LogoutRequested e,Emitter<AuthState>o)async{
    await repo.logout();
    o(const AuthState(status:AuthStatus.unauthenticated));
  }
}
