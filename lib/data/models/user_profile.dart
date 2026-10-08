class UserProfile {
  final String id,name,email,number,gender,image;
  final num wallet;
  final bool emailVerified;
  const UserProfile({
    required this.id,required this.name,required this.email,required this.number,required this.gender,required this.image,required this.wallet,required this.emailVerified
  }
  );
  factory UserProfile.fromJson(Map<String,dynamic> j)=>UserProfile(id:'${j['_id']??''}',name:'${j['name']??''}',email:'${j['email']??''}',number:'${j['number']??''}',gender:'${j['gender']??''}',image:'${j['profile_img']??''}',wallet:j['wallet'] is num?j['wallet']:num.tryParse('${j['wallet']}')??0,emailVerified:j['isEmailVerified']==true);
}
