class MemberDetails {
  final String fullName,gender,gotram;
  const MemberDetails({
    required this.fullName,required this.gender,required this.gotram
  }
  );
  factory MemberDetails.fromJson(Map<String,dynamic> j)=>MemberDetails(fullName:'${j['fullName']??''}',gender:'${j['gender']??''}',gotram:'${j['gotram']??''}');
}
class PujaTransaction {
  final String id,name,date,status,image,pujaId,createdAt;
  final double rating;
  const PujaTransaction({
    required this.id,required this.name,required this.date,required this.status,required this.image,required this.pujaId,required this.createdAt,required this.rating
  }
  );
  factory PujaTransaction.fromJson(Map<String,dynamic> j){
    final p=j['pujaId'];
    return PujaTransaction(id:'${j['_id']??''}',name:'${j['pujaName']??(p is Map?p['title']??'':'')}',date:'${j['pujaDate']??''}',status:'${j['pujaStatus']??''}',image:p is Map?'${p['pujaImage']??''}':'',pujaId:p is Map?'${p['_id']??''}':'$p',createdAt:'${j['created_at']??''}',rating:double.tryParse('${j['rating']??0}')??0);
  }
}
class TransactionDetail {
  final String id,name,date,time,location,status,orderId,paymentId,image,packageType,pujaId;
  final num total,orderAmount,discount,packagePrice;
  final List<MemberDetails> members;
  const TransactionDetail({
    required this.id,required this.name,required this.date,required this.time,required this.location,required this.status,required this.orderId,required this.paymentId,required this.image,required this.packageType,required this.packagePrice,required this.total,required this.orderAmount,required this.discount,required this.members,required this.pujaId
  }
  );
  factory TransactionDetail.fromJson(Map<String,dynamic> j){
    final p=j['pujaId'] is Map?Map<String,dynamic>.from(j['pujaId']):{
    }
    ;
    final pkg=j['package'] is Map?Map<String,dynamic>.from(j['package']):{
    }
    ;
    return TransactionDetail(id:'${j['_id']??''}',name:'${j['pujaName']??''}',date:'${j['pujaDate']??''}',time:'${j['pujaTime']??''}',location:'${j['location']??''}',status:'${j['status']??j['pujaStatus']??''}',orderId:'${j['orderId']??''}',paymentId:'${j['paymentId']??''}',image:'${p['pujaImage']??''}',packageType:'${pkg['type']??''}',packagePrice:_n(pkg['price']),total:_n(j['totalAmount']),orderAmount:_n(j['orderAmount']),discount:_n(j['discountAmount']),pujaId:'${p['_id']??''}',members:(j['customerDetails'] as List? ?? []).whereType<Map>().map((e)=>MemberDetails.fromJson(Map<String,dynamic>.from(e))).toList());
  }
  static num _n(dynamic v)=>v is num?v:num.tryParse('$v')??0;
}
