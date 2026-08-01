/// status : true
/// data : [{"id":2,"title":"Anna nagar","image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/slider/ourstore-slider 2","status":"1","sequence":2,"phone":"9289309109","timing":"11.00 AM to 10.00 PM","address":"New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph:","description":null,"created_at":"2025-11-29T11:02:24.000000Z","deleted_at":0,"updated_at":"2025-11-29T11:02:24.000000Z","map":null},{"id":3,"title":"Perambur","image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/slider/ourstore-slider1","status":"1","sequence":3,"phone":"9585503380","timing":"11.00 AM to 10.00 PM","address":"No:116, For SERVICE RATE ENQUIRY: Refer our website above (2000+ available models, 271, Paper Mills Road, Sembiyan, Perambur, Chennai, Tamil Nadu 600011","description":null,"created_at":"2025-11-29T12:34:11.000000Z","deleted_at":0,"updated_at":"2025-11-29T12:34:11.000000Z","map":"https://maps.app.goo.gl/bQQcR6CsXQ3zTnrg9"}]

class GetNearByStoreResponseModel {
  GetNearByStoreResponseModel({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  GetNearByStoreResponseModel.fromJson(dynamic json) {
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
GetNearByStoreResponseModel copyWith({  bool? status,
  List<Data>? data,
}) => GetNearByStoreResponseModel(  status: status ?? _status,
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

/// id : 2
/// title : "Anna nagar"
/// image : "https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/slider/ourstore-slider 2"
/// status : "1"
/// sequence : 2
/// phone : "9289309109"
/// timing : "11.00 AM to 10.00 PM"
/// address : "New Door No. AA-72, Old Door No. AA-107, Ground Floor, Shanthi Colony Main Road, IVth Avenue, Anna Nagar, Chennai - 600040, Ph:"
/// description : null
/// created_at : "2025-11-29T11:02:24.000000Z"
/// deleted_at : 0
/// updated_at : "2025-11-29T11:02:24.000000Z"
/// map : null

class Data {
  Data({
      num? id, 
      String? title, 
      String? image, 
      String? status, 
      num? sequence, 
      String? phone, 
      String? timing, 
      String? address, 
      String? city,
      dynamic description, 
      String? createdAt, 
      num? deletedAt, 
      String? updatedAt, 
      dynamic map,
      String? landmark,}){
    _id = id;
    _title = title;
    _image = image;
    _status = status;
    _sequence = sequence;
    _phone = phone;
    _timing = timing;
    _address = address;
    _city = city;
    _description = description;
    _createdAt = createdAt;
    _deletedAt = deletedAt;
    _updatedAt = updatedAt;
    _map = map;
    _landmark = landmark;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _image = json['image'];
    _status = json['status'];
    _sequence = json['sequence'];
    _phone = json['phone'];
    _timing = json['timing'];
    _address = json['address'];
    _city = json['city'];
    _description = json['description'];
    _createdAt = json['created_at'];
    _deletedAt = json['deleted_at'];
    _updatedAt = json['updated_at'];
    _map = json['map'];
    _landmark = json['landmark'];
  }
  num? _id;
  String? _title;
  String? _image;
  String? _status;
  num? _sequence;
  String? _phone;
  String? _timing;
  String? _address;
  String? _city;
  dynamic _description;
  String? _createdAt;
  num? _deletedAt;
  String? _updatedAt;
  dynamic _map;
  String? _landmark;
Data copyWith({  num? id,
  String? title,
  String? image,
  String? status,
  num? sequence,
  String? phone,
  String? timing,
  String? address,
  dynamic description,
  String? createdAt,
  num? deletedAt,
  String? updatedAt,
  dynamic map,
  String? landmark,
}) => Data(  id: id ?? _id,
  title: title ?? _title,
  image: image ?? _image,
  status: status ?? _status,
  sequence: sequence ?? _sequence,
  phone: phone ?? _phone,
  timing: timing ?? _timing,
  address: address ?? _address,
  description: description ?? _description,
  createdAt: createdAt ?? _createdAt,
  deletedAt: deletedAt ?? _deletedAt,
  updatedAt: updatedAt ?? _updatedAt,
  map: map ?? _map,
  landmark: landmark ?? _landmark,
);
  num? get id => _id;
  String? get title => _title;
  String? get image => _image;
  String? get status => _status;
  num? get sequence => _sequence;
  String? get phone => _phone;
  String? get timing => _timing;
  String? get address => _address;
  String? get city => _city;
  dynamic get description => _description;
  String? get createdAt => _createdAt;
  num? get deletedAt => _deletedAt;
  String? get updatedAt => _updatedAt;
  dynamic get map => _map;
  String? get landmark => _landmark;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['image'] = _image;
    map['status'] = _status;
    map['sequence'] = _sequence;
    map['phone'] = _phone;
    map['timing'] = _timing;
    map['address'] = _address;
    map['city'] = _city;
    map['description'] = _description;
    map['created_at'] = _createdAt;
    map['deleted_at'] = _deletedAt;
    map['updated_at'] = _updatedAt;
    map['map'] = _map;
    map['landmark'] = _landmark;
    return map;
  }

}