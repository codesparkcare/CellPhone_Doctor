class GetProfileResponseModel {
  GetProfileResponseModel({
    num? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? status,
    dynamic createdAt,
    dynamic updatedAt,
  }) {
    _id = id ?? 0;                     // SAFE DEFAULT
    _name = name ?? "";               // SAFE DEFAULT
    _email = email ?? "";
    _phone = phone ?? "";
    _address = address ?? "";
    _status = status ?? "";
    _createdAt = createdAt ?? "";
    _updatedAt = updatedAt ?? "";
  }

  GetProfileResponseModel.fromJson(dynamic json) {
    _id = json['id'] ?? 0;
    _name = json['name'] ?? "";
    _email = json['email'] ?? "";
    _phone = json['phone'] ?? "";
    _address = json['address'] ?? "";
    _status = json['status'] ?? "";
    _createdAt = json['created_at'] ?? "";
    _updatedAt = json['updated_at'] ?? "";
  }

  num _id = 0;
  String _name = "";
  String _email = "";
  String _phone = "";
  String _address = "";
  String _status = "";
  dynamic _createdAt = "";
  dynamic _updatedAt = "";

  GetProfileResponseModel copyWith({
    num? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? status,
    dynamic createdAt,
    dynamic updatedAt,
  }) =>
      GetProfileResponseModel(
        id: id ?? _id,
        name: name ?? _name,
        email: email ?? _email,
        phone: phone ?? _phone,
        address: address ?? _address,
        status: status ?? _status,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  // SAFE GETTERS — NEVER RETURN NULL
  num get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get status => _status;
  dynamic get createdAt => _createdAt;
  dynamic get updatedAt => _updatedAt;

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
