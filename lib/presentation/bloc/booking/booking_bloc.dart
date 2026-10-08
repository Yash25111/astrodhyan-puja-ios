import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_result.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/booking_repository.dart';
class BookingState extends Equatable{
  final bool loading,success;
  final OrderResult?order;
  final String?error;
  const BookingState({
    this.loading=false,this.success=false,this.order,this.error
  }
  );
  @override List<Object?>get props=>[loading,success,order,error];
}
sealed class BookingEvent extends Equatable{
  const BookingEvent();
  @override List<Object?>get props=>[];
}
class CreateOrder extends BookingEvent{
  final String pujaId,packageId;
  final List<String>offerings;
  final List<MemberDetails>members;
  const CreateOrder({
    required this.pujaId,required this.packageId,required this.offerings,required this.members
  }
  );
  @override List<Object?>get props=>[pujaId,packageId,offerings,members];
}
class ResetBooking extends BookingEvent{
  const ResetBooking();
}
class BookingBloc extends Bloc<BookingEvent,BookingState>{
  final BookingRepository repo;
  BookingBloc(this.repo):super(const BookingState()){
    on<CreateOrder>(_create);
    on<ResetBooking>((e,o)=>o(const BookingState()));
  }
  Future<void>_create(CreateOrder e,Emitter<BookingState>o)async{
    o(const BookingState(loading:true));
    try{
      o(BookingState(success:true,order:await repo.createOrder(pujaId:e.pujaId,packageId:e.packageId,offerings:e.offerings,members:e.members)));
    } catch(x){
      o(BookingState(error:x.toString()));
    }
  }
}
