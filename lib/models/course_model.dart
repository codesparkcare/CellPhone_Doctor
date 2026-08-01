class CourseModel {
  bool? status;
  List<CourseVideo>? video;
  List<CourseData>? data;

  CourseModel({this.status, this.video, this.data});

  CourseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['video'] != null) {
      video = <CourseVideo>[];
      json['video'].forEach((v) {
        video!.add(CourseVideo.fromJson(v));
      });
    }
    if (json['data'] != null) {
      data = <CourseData>[];
      json['data'].forEach((v) {
        data!.add(CourseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (video != null) {
      data['video'] = video!.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CourseVideo {
  int? id;
  String? url;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;

  CourseVideo(
      {this.id,
      this.url,
      this.type,
      this.status,
      this.createdAt,
      this.updatedAt});

  CourseVideo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    type = json['type'];
    status = json['status'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['type'] = type;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class CourseData {
  int? id;
  String? title;
  String? description;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  CourseData(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  CourseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
