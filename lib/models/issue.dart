class Issue {
  late int id;
  String? createdAt;
  String? createdBy;
  String? title;
  String? content;
  List<String>? photos;
  int? status;
  bool? isEnable;
  AccountPublic? accountPublic;

  Issue({
      required this.id,
      this.createdAt, 
      this.createdBy, 
      this.title, 
      this.content, 
      this.photos, 
      this.status, 
      this.isEnable, 
      this.accountPublic});

  Issue.fromJson(dynamic json) {
    id = json["id"];
    createdAt = json["createdAt"];
    createdBy = json["createdBy"];
    title = json["title"];
    content = json["content"];
    photos = json["photos"] != null ? json["photos"].cast<String>() : [];
    status = json["status"];
    isEnable = json["isEnable"];
    accountPublic = json["accountPublic"] != null ? AccountPublic.fromJson(json["accountPublic"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["createdAt"] = createdAt;
    map["createdBy"] = createdBy;
    map["title"] = title;
    map["content"] = content;
    map["photos"] = photos;
    map["status"] = status;
    map["isEnable"] = isEnable;
    if (accountPublic != null) {
      map["accountPublic"] = accountPublic?.toJson();
    }
    return map;
  }

}

class AccountPublic {
  int? id;
  String? name;
  String? avatar;

  AccountPublic({
      this.id, 
      this.name, 
      this.avatar});

  AccountPublic.fromJson(dynamic json) {
    id = json["id"];
    name = json["name"];
    avatar = json["avatar"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["avatar"] = avatar;
    return map;
  }

}