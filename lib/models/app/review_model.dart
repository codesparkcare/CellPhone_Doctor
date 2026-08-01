class ReviewModel {
  bool? status;
  List<ReviewData>? data;
  List<ReviewVideo>? video;

  ReviewModel({this.status, this.data, this.video});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <ReviewData>[];
      json['data'].forEach((v) {
        data!.add(ReviewData.fromJson(v));
      });
    }
    if (json['video'] != null) {
      video = <ReviewVideo>[];
      json['video'].forEach((v) {
        video!.add(ReviewVideo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.video != null) {
      data['video'] = this.video!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReviewVideo {
  int? id;
  String? url;
  String? type;
  String? status;
  String? createdAt;
  int? deletedAt;
  String? updatedAt;

  ReviewVideo(
      {this.id,
      this.url,
      this.type,
      this.status,
      this.createdAt,
      this.deletedAt,
      this.updatedAt});

  ReviewVideo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    type = json['type'];
    status = json['status'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['url'] = url;
    data['type'] = type;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ReviewData {
  int? id;
  String? name;
  String? rating;
  String? image;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? status;

  ReviewData(
      {this.id,
      this.name,
      this.rating,
      this.image,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.status});

  ReviewData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    // Ensure rating is handled as string even if it comes as int
    if (json['rating'] is int) {
      rating = json['rating'].toString();
    } else {
      rating = json['rating'];
    }
    image = json['image'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['rating'] = rating;
    data['image'] = image;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    return data;
  }
}
