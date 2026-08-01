/// message : "Login successful"
/// token : "60|2keqAO9GOftXHjnl3aJ18272pceTl3sFFfSpXT0nb3fe064f"
/// customer : {"id":2,"name":"","email":"","phone":"9629849073","address":null,"status":"active","created_at":"2025-12-01T17:26:04.000000Z","updated_at":"2025-12-01T17:26:04.000000Z"}
/// type : "existing_user"

class LoginResponseModel {
  LoginResponseModel({
      String? message, 
      String? token, 
      Customer? customer, 
      String? type,}){
    _message = message;
    _token = token;
    _customer = customer;
    _type = type;
}

  LoginResponseModel.fromJson(dynamic json) {
    _message = json['message'];
    _token = json['token'];
    _customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    _type = json['type'];
  }
  String? _message;
  String? _token;
  Customer? _customer;
  String? _type;
LoginResponseModel copyWith({  String? message,
  String? token,
  Customer? customer,
  String? type,
}) => LoginResponseModel(  message: message ?? _message,
  token: token ?? _token,
  customer: customer ?? _customer,
  type: type ?? _type,
);
  String? get message => _message;
  String? get token => _token;
  Customer? get customer => _customer;
  String? get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['token'] = _token;
    if (_customer != null) {
      map['customer'] = _customer?.toJson();
    }
    map['type'] = _type;
    return map;
  }

}

/// id : 2
/// name : ""
/// email : ""
/// phone : "9629849073"
/// address : null
/// status : "active"
/// created_at : "2025-12-01T17:26:04.000000Z"
/// updated_at : "2025-12-01T17:26:04.000000Z"

class Customer {
  Customer({
      num? id, 
      String? name, 
      String? email, 
      String? phone, 
      dynamic address, 
      String? status, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _name = name;
    _email = email;
    _phone = phone;
    _address = address;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Customer.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _phone = json['phone'];
    _address = json['address'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _name;
  String? _email;
  String? _phone;
  dynamic _address;
  String? _status;
  String? _createdAt;
  String? _updatedAt;
Customer copyWith({  num? id,
  String? name,
  String? email,
  String? phone,
  dynamic address,
  String? status,
  String? createdAt,
  String? updatedAt,
}) => Customer(  id: id ?? _id,
  name: name ?? _name,
  email: email ?? _email,
  phone: phone ?? _phone,
  address: address ?? _address,
  status: status ?? _status,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  dynamic get address => _address;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['phone'] = _phone;
    map['address'] = _address;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}