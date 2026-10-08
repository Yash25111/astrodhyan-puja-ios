class OrderResult {
  final String orderId,transactionId,key;
  final num totalAmount,orderAmount;
  const OrderResult({
    required this.orderId,required this.transactionId,required this.key,required this.totalAmount,required this.orderAmount
  }
  );
  factory OrderResult.fromJson(Map<String,dynamic> j){
    final s=j['orderSummary'] is Map?j['orderSummary']:{
    }
    ;
    return OrderResult(orderId:'${j['order']??''}',transactionId:'${j['transactionId']??''}',key:'${j['key']??''}',totalAmount:_n(s['totalAmount']),orderAmount:_n(s['orderAmount']));
  }
  static num _n(dynamic v)=>v is num?v:num.tryParse('$v')??0;
}
