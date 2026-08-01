/// message : "Success"
/// customer : [{"id":1,"c_id":2,"name":"vvvv","url":"storage/photos/1/Stories/1766754937.mp4","status":"active","deleted_at":0,"created_at":"2025-12-26T13:15:37.000000Z","updated_at":"2025-12-26T13:15:37.000000Z"}]

class GetStoryListReponseModel {
  GetStoryListReponseModel({
      String? message, 
      List<Customer>? customer,}){
    _message = message;
    _customer = customer;
}

  GetStoryListReponseModel.fromJson(dynamic json) {
    _message = json['message'];
    if (json['customer'] != null) {
      _customer = [];
      json['customer'].forEach((v) {
        _customer?.add(Customer.fromJson(v));
      });
    }
  }
  String? _message;
  List<Customer>? _customer;
GetStoryListReponseModel copyWith({  String? message,
  List<Customer>? customer,
}) => GetStoryListReponseModel(  message: message ?? _message,
  customer: customer ?? _customer,
);
  String? get message => _message;
  List<Customer>? get customer => _customer;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_customer != null) {
      map['customer'] = _customer?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 1
/// c_id : 2
/// name : "vvvv"
/// url : "storage/photos/1/Stories/1766754937.mp4"
/// status : "active"
/// deleted_at : 0
/// created_at : "2025-12-26T13:15:37.000000Z"
/// updated_at : "2025-12-26T13:15:37.000000Z"

class Customer {
  Customer({
      num? id, 
      num? cId, 
      String? name, 
      String? url, 
      String? status, 
      num? deletedAt, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _cId = cId;
    _name = name;
    _url = url;
    _status = status;
    _deletedAt = deletedAt;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Customer.fromJson(dynamic json) {
    _id = json['id'];
    _cId = json['c_id'];
    _name = json['name'];
    _url = json['url'];
    _status = json['status'];
    _deletedAt = json['deleted_at'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  num? _cId;
  String? _name;
  String? _url;
  String? _status;
  num? _deletedAt;
  String? _createdAt;
  String? _updatedAt;
Customer copyWith({  num? id,
  num? cId,
  String? name,
  String? url,
  String? status,
  num? deletedAt,
  String? createdAt,
  String? updatedAt,
}) => Customer(  id: id ?? _id,
  cId: cId ?? _cId,
  name: name ?? _name,
  url: url ?? _url,
  status: status ?? _status,
  deletedAt: deletedAt ?? _deletedAt,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  num? get cId => _cId;
  String? get name => _name;
  String? get url => _url;
  String? get status => _status;
  num? get deletedAt => _deletedAt;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['c_id'] = _cId;
    map['name'] = _name;
    map['url'] = _url;
    map['status'] = _status;
    map['deleted_at'] = _deletedAt;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}