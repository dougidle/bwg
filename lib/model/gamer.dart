class Gamer {
  int userId;
  String nickName;
  bool isSubscriber;

  Gamer({
    required this.userId,
    required this.nickName,
    required this.isSubscriber,
  });

  factory Gamer.fromJson(Map<String, dynamic> json) {
    return Gamer(
      userId: json['UserId'] as int,
      nickName: json['NickName'] as String,
      isSubscriber: json['isSubscriber'] == 1,
    );
  }

}

class GamerParser {
  static List<Gamer> parseGamers(Map<String, dynamic> jsonResponse) {
    if (jsonResponse['error'] == true) {
      throw Exception(jsonResponse['message'] ?? 'Failed to parse gamers: Unknown error');
    }
    final List<dynamic>? gamersJsonList = jsonResponse['gamers'] as List<dynamic>?;
    if (gamersJsonList == null) {
      throw Exception('Failed to parse gamers: "gamers" key is missing or not a list.');
    }
    return gamersJsonList.map((json) => Gamer.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}