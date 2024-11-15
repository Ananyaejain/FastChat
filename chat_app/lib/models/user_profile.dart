class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;
  String? pushToken;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
    required this.pushToken
  });

  UserProfile.fromJson(Map<String, dynamic> json){
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
    pushToken = json['pushToken'];
  }

  Map<String, dynamic> toJson(){
    final Map<String,dynamic> data =<String,dynamic>{};
    data['name'] = name;
    data['uid'] = uid;
    data['pfpURL'] = pfpURL;
    data['pushToken'] = pushToken;
    return data;
  }
}
