/// status : true
/// data : [{"id":12,"slug":"Apple-Mac-Book-Air","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop-Model/Mac-Book-Air.png","sequence":1,"category":1,"brand":1,"status":"active","created_at":"2025-11-29T12:15:57.000000Z","updated_at":"2025-11-29T12:19:59.000000Z"},{"id":13,"slug":"Apple-Mac-Book-Pro","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop-Model/Mac-Pro.png","sequence":2,"category":1,"brand":1,"status":"active","created_at":"2025-11-29T12:21:55.000000Z","updated_at":"2025-11-29T12:21:55.000000Z"}]

class GetSelectModelResponse {
  GetSelectModelResponse({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  GetSelectModelResponse.fromJson(dynamic json) {
    _status = json['status'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _status;
  List<Data>? _data;
  GetSelectModelResponse copyWith({  bool? status,
  List<Data>? data,
}) => GetSelectModelResponse(  status: status ?? _status,
  data: data ?? _data,
);
  bool? get status => _status;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 12
/// slug : "Apple-Mac-Book-Air"
/// logo_url : "https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop-Model/Mac-Book-Air.png"
/// sequence : 1
/// category : 1
/// brand : 1
/// status : "active"
/// created_at : "2025-11-29T12:15:57.000000Z"
/// updated_at : "2025-11-29T12:19:59.000000Z"

class Data {
  Data({
      num? id, 
      String? slug, 
      String? logoUrl, 
      num? sequence, 
      num? category, 
      num? brand, 
      String? status, 
      String? series,
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _slug = slug;
    _logoUrl = logoUrl;
    _sequence = sequence;
    _category = category;
    _brand = brand;
    _status = status;
    _series = series;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _slug = json['slug'];
    _logoUrl = json['logo_url'];
    _sequence = json['sequence'];
    _category = json['category'];
    _brand = json['brand'];
    _status = json['status'];
    _series = json['series'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _slug;
  String? _logoUrl;
  num? _sequence;
  num? _category;
  num? _brand;
  String? _status;
  String? _series;
  String? _createdAt;
  String? _updatedAt;

Data copyWith({  num? id,
  String? slug,
  String? logoUrl,
  num? sequence,
  num? category,
  num? brand,
  String? status,
  String? series,
  String? createdAt,
  String? updatedAt,
}) => Data(  id: id ?? _id,
  slug: slug ?? _slug,
  logoUrl: logoUrl ?? _logoUrl,
  sequence: sequence ?? _sequence,
  category: category ?? _category,
  brand: brand ?? _brand,
  status: status ?? _status,
  series: series ?? _series,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get slug => _slug;
  String? get logoUrl => _logoUrl;
  num? get sequence => _sequence;
  num? get category => _category;
  num? get brand => _brand;
  String? get status => _status;
  String? get series => _series;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['slug'] = _slug;
    map['logo_url'] = _logoUrl;
    map['sequence'] = _sequence;
    map['category'] = _category;
    map['brand'] = _brand;
    map['status'] = _status;
    map['series'] = _series;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}