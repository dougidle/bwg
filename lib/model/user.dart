class User {
  String authId = "";
  String userFirstName = "";
  String userLastName = "";
  String userNickName = "";
  String loginType = "";

  User({
    required this.authId,
    required this.userFirstName,
    required this.userLastName,
    required this.userNickName,
    required this.loginType,
  });

  // Convert Dog → Map
  Map<String, Object?> toMap() {
    return {
      'authId': authId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userNickName': userNickName,
      'loginType': loginType,
    };
  }

  // Convert Map → Dog
  factory User.fromMap(Map<String, Object?> map) {
    return User(
      authId: map['authId'] as String,
      userFirstName: map['userFirstName'] as String,
      userLastName: map['userLastName'] as String,
      userNickName: map['userNickName'] as String,
      loginType: map['loginType'] as String,
    );
  }
}