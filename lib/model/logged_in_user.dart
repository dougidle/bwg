class LoggedInUser {
  int userId;
  String authId;
  String userFirstName;
  String userLastName;
  String userNickName;
  String loginType;
  bool isSubscriber;

  LoggedInUser({
    required this.userId,
    required this.authId,
    required this.userFirstName,
    required this.userLastName,
    required this.userNickName,
    required this.loginType,
    required this.isSubscriber,
  });

  /// Creates a [LoggedInUser] instance from a JSON map.
  factory LoggedInUser.fromJson(Map<String, dynamic> json) {
    return LoggedInUser(
      userId: json['userId'] as int? ?? 0,
      authId: json['authId'] as String? ?? '',
      userFirstName: json['userFirstName'] as String? ?? '',
      userLastName: json['userLastName'] as String? ?? '',
      userNickName: json['userNickName'] as String? ?? '',
      loginType: json['loginType'] as String? ?? '',
      isSubscriber: json['isSubscriber'] == 1 || json['isSubscriber'] == true,
    );
  }

  /// Converts this [LoggedInUser] instance to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'authId': authId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userNickName': userNickName,
      'loginType': loginType,
      'isSubscriber': isSubscriber,
    };
  }

  /// Converts this [LoggedInUser] instance to a map for database operations.
  /// This is often used for `sqflite` insert/update operations.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'authId': authId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userNickName': userNickName,
      'loginType': loginType,
      'isSubscriber': isSubscriber ? 1 : 0,
    };
  }
}