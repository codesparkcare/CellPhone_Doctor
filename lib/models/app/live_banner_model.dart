class LiveBannerModel {
  bool? status;
  List<LiveBannerData>? data;

  LiveBannerModel({this.status, this.data});

  LiveBannerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <LiveBannerData>[];
      json['data'].forEach((v) {
        data!.add(LiveBannerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LiveBannerData {
  int? id;
  String? name;
  int? sequence;
  String? status;
  String? url;
  String? createdAt;
  String? deletedAt;

  LiveBannerData(
      {this.id,
      this.name,
      this.sequence,
      this.status,
      this.url,
      this.createdAt,
      this.deletedAt});

  LiveBannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sequence = json['sequence'];
    status = json['status'];
    url = json['url'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['sequence'] = sequence;
    data['status'] = status;
    data['url'] = url;
    data['created_at'] = createdAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}
