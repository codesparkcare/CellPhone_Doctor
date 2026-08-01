/// status : true
/// data : [{"id":1,"slug":"laptop-apple","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptopapple.png","sequence":1,"status":"active","category":1,"name":"Laptop-Apple","description":null},{"id":2,"slug":"laptop-samsung","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptopsamsung.png","sequence":1,"status":"active","category":1,"name":"Laptop-Samsung","description":null},{"id":3,"slug":"laptop-hp","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptophp.png","sequence":3,"status":"active","category":1,"name":"Laptop-Hp","description":null},{"id":4,"slug":"laptop-compaq","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptopcompaq.png","sequence":4,"status":"active","category":1,"name":"Laptop-Compaq","description":null},{"id":5,"slug":"laptop-lenovo","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptoplenovo.png","sequence":5,"status":"active","category":1,"name":"Laptop-Lenovo","description":null},{"id":6,"slug":"laptop-acer","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptopacer.png","sequence":6,"status":"active","category":1,"name":"Laptop-Acer","description":null},{"id":7,"slug":"laptop-toshiba","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptoptoshiba.png","sequence":7,"status":"active","category":1,"name":"Laptop-Toshiba","description":null},{"id":38,"slug":"tablet-lenovo","logo_url":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Tablet brands/Tablet-lenovo","sequence":5,"status":"active","category":1,"name":"tablet-lenovo","description":null}]

class GetBrandListModel {
  GetBrandListModel({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  GetBrandListModel.fromJson(dynamic json) {
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
GetBrandListModel copyWith({  bool? status,
  List<Data>? data,
}) => GetBrandListModel(  status: status ?? _status,
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

/// id : 1
/// slug : "laptop-apple"
/// logo_url : "https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Brand/Laptop brands/laptopapple.png"
/// sequence : 1
/// status : "active"
/// category : 1
/// name : "Laptop-Apple"
/// description : null

class Data {
  Data({
      num? id, 
      String? slug, 
      String? logoUrl, 
      num? sequence, 
      String? status, 
      num? category, 
      String? name, 
      dynamic description,}){
    _id = id;
    _slug = slug;
    _logoUrl = logoUrl;
    _sequence = sequence;
    _status = status;
    _category = category;
    _name = name;
    _description = description;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _slug = json['slug'];
    _logoUrl = json['logo_url'];
    _sequence = json['sequence'];
    _status = json['status'];
    _category = json['category'];
    _name = json['name'];
    _description = json['description'];
  }
  num? _id;
  String? _slug;
  String? _logoUrl;
  num? _sequence;
  String? _status;
  num? _category;
  String? _name;
  dynamic _description;
Data copyWith({  num? id,
  String? slug,
  String? logoUrl,
  num? sequence,
  String? status,
  num? category,
  String? name,
  dynamic description,
}) => Data(  id: id ?? _id,
  slug: slug ?? _slug,
  logoUrl: logoUrl ?? _logoUrl,
  sequence: sequence ?? _sequence,
  status: status ?? _status,
  category: category ?? _category,
  name: name ?? _name,
  description: description ?? _description,
);
  num? get id => _id;
  String? get slug => _slug;
  String? get logoUrl => _logoUrl;
  num? get sequence => _sequence;
  String? get status => _status;
  num? get category => _category;
  String? get name => _name;
  dynamic get description => _description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['slug'] = _slug;
    map['logo_url'] = _logoUrl;
    map['sequence'] = _sequence;
    map['status'] = _status;
    map['category'] = _category;
    map['name'] = _name;
    map['description'] = _description;
    return map;
  }

}