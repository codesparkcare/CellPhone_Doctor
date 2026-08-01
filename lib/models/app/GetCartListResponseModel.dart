/// message : "success"
/// data : [{"id":55,"shop_id":1,"spare_id":2,"vendor_id":null,"category_id":2,"brand_id":19,"model_id":2,"product_type":"variable","image":null,"status":1,"sequence":1,"created_at":"2025-11-29T11:32:01.000000Z","updated_at":"2025-11-29T11:32:01.000000Z","spare":{"id":62,"product_id":55,"variant_slug":"LCD Display Module Black High Quality-69368769e0324","price":"17999.00","sequence":2,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"converted_price":17999,"converted_discount_price":null}}]

class GetCartListResponseModel {
  GetCartListResponseModel({
      String? message, 
      double? deliveryCharge,
      List<Data>? data,}){
    _message = message;
    _deliveryCharge = deliveryCharge;
    _data = data;
}

  GetCartListResponseModel.fromJson(dynamic json) {
    _message = json['message'];
    if (json['delivery_charge'] != null) {
      _deliveryCharge = double.tryParse(json['delivery_charge'].toString());
    }
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  String? _message;
  double? _deliveryCharge;
  List<Data>? _data;
GetCartListResponseModel copyWith({  String? message,
  List<Data>? data,
}) => GetCartListResponseModel(  message: message ?? _message,
  data: data ?? _data,
);
  String? get message => _message;
  double? get deliveryCharge => _deliveryCharge;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 55
/// shop_id : 1
/// spare_id : 2
/// vendor_id : null
/// category_id : 2
/// brand_id : 19
/// model_id : 2
/// product_type : "variable"
/// image : null
/// status : 1
/// sequence : 1
/// created_at : "2025-11-29T11:32:01.000000Z"
/// updated_at : "2025-11-29T11:32:01.000000Z"
/// spare : {"id":62,"product_id":55,"variant_slug":"LCD Display Module Black High Quality-69368769e0324","price":"17999.00","sequence":2,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"converted_price":17999,"converted_discount_price":null}

class Data {
  Data({
      num? id, 
      num? shopId, 
      num? spareId, 
      dynamic vendorId, 
      num? categoryId, 
      num? brandId, 
      num? modelId, 
      String? productType, 
      dynamic image, 
      num? status, 
      num? sequence, 
      String? createdAt, 
      String? updatedAt, 
      Spare? spare,}){
    _id = id;
    _shopId = shopId;
    _spareId = spareId;
    _vendorId = vendorId;
    _categoryId = categoryId;
    _brandId = brandId;
    _modelId = modelId;
    _productType = productType;
    _image = image;
    _status = status;
    _sequence = sequence;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _spare = spare;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _shopId = json['shop_id'];
    _spareId = json['spare_id'];
    _vendorId = json['vendor_id'];
    _categoryId = json['category_id'];
    _brandId = json['brand_id'];
    _modelId = json['model_id'];
    _productType = json['product_type'];
    _image = json['image'];
    _status = json['status'];
    _sequence = json['sequence'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _spare = json['spare'] != null ? Spare.fromJson(json['spare']) : null;
  }
  num? _id;
  num? _shopId;
  num? _spareId;
  dynamic _vendorId;
  num? _categoryId;
  num? _brandId;
  num? _modelId;
  String? _productType;
  dynamic _image;
  num? _status;
  num? _sequence;
  String? _createdAt;
  String? _updatedAt;
  Spare? _spare;
Data copyWith({  num? id,
  num? shopId,
  num? spareId,
  dynamic vendorId,
  num? categoryId,
  num? brandId,
  num? modelId,
  String? productType,
  dynamic image,
  num? status,
  num? sequence,
  String? createdAt,
  String? updatedAt,
  Spare? spare,
}) => Data(  id: id ?? _id,
  shopId: shopId ?? _shopId,
  spareId: spareId ?? _spareId,
  vendorId: vendorId ?? _vendorId,
  categoryId: categoryId ?? _categoryId,
  brandId: brandId ?? _brandId,
  modelId: modelId ?? _modelId,
  productType: productType ?? _productType,
  image: image ?? _image,
  status: status ?? _status,
  sequence: sequence ?? _sequence,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  spare: spare ?? _spare,
);
  num? get id => _id;
  num? get shopId => _shopId;
  num? get spareId => _spareId;
  dynamic get vendorId => _vendorId;
  num? get categoryId => _categoryId;
  num? get brandId => _brandId;
  num? get modelId => _modelId;
  String? get productType => _productType;
  dynamic get image => _image;
  num? get status => _status;
  num? get sequence => _sequence;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  Spare? get spare => _spare;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['shop_id'] = _shopId;
    map['spare_id'] = _spareId;
    map['vendor_id'] = _vendorId;
    map['category_id'] = _categoryId;
    map['brand_id'] = _brandId;
    map['model_id'] = _modelId;
    map['product_type'] = _productType;
    map['image'] = _image;
    map['status'] = _status;
    map['sequence'] = _sequence;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_spare != null) {
      map['spare'] = _spare?.toJson();
    }
    return map;
  }

}

/// id : 62
/// product_id : 55
/// variant_slug : "LCD Display Module Black High Quality-69368769e0324"
/// price : "17999.00"
/// sequence : 2
/// image : "https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display"
/// discount_price : null
/// stock : 0
/// SKU : null
/// barcode : null
/// weight : null
/// dimensions : null
/// is_primary : 1
/// created_at : "2025-12-08T08:08:09.000000Z"
/// updated_at : "2025-12-08T08:08:09.000000Z"
/// description : null
/// converted_price : 17999
/// converted_discount_price : null

class Spare {
  Spare({
      num? id, 
      num? productId, 
      String? variantSlug, 
      String? price, 
      num? sequence, 
      String? image, 
      dynamic discountPrice, 
      num? stock, 
      dynamic sku, 
      dynamic barcode, 
      dynamic weight, 
      dynamic dimensions, 
      num? isPrimary, 
      String? createdAt, 
      String? updatedAt, 
      dynamic description,
    String? convertedPrice,
      dynamic convertedDiscountPrice,
      dynamic regularPrice,}){
    _id = id;
    _productId = productId;
    _variantSlug = variantSlug;
    _price = price;
    _sequence = sequence;
    _image = image;
    _discountPrice = discountPrice;
    _stock = stock;
    _sku = sku;
    _barcode = barcode;
    _weight = weight;
    _dimensions = dimensions;
    _isPrimary = isPrimary;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _description = description;
    _convertedPrice = convertedPrice;
    _convertedDiscountPrice = convertedDiscountPrice;
    _regularPrice = regularPrice;
}

  Spare.fromJson(dynamic json) {
    _id = json['id'];
    _productId = json['product_id'];
    _variantSlug = json['variant_slug'];
    _price = json['price'];
    _sequence = json['sequence'];
    _image = json['image'];
    _discountPrice = json['discount_price'];
    _stock = json['stock'];
    _sku = json['SKU'];
    _barcode = json['barcode'];
    _weight = json['weight'];
    _dimensions = json['dimensions'];
    _isPrimary = json['is_primary'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _description = json['description'];
    _convertedPrice = json['converted_price'];
    _convertedDiscountPrice = json['converted_discount_price'];
    _regularPrice = json['regular_price'];
  }
  num? _id;
  num? _productId;
  String? _variantSlug;
  String? _price;
  num? _sequence;
  String? _image;
  dynamic _discountPrice;
  num? _stock;
  dynamic _sku;
  dynamic _barcode;
  dynamic _weight;
  dynamic _dimensions;
  num? _isPrimary;
  String? _createdAt;
  String? _updatedAt;
  dynamic _description;
  String? _convertedPrice;
  dynamic _convertedDiscountPrice;
  dynamic _regularPrice;
Spare copyWith({  num? id,
  num? productId,
  String? variantSlug,
  String? price,
  num? sequence,
  String? image,
  dynamic discountPrice,
  num? stock,
  dynamic sku,
  dynamic barcode,
  dynamic weight,
  dynamic dimensions,
  num? isPrimary,
  String? createdAt,
  String? updatedAt,
  dynamic description,
  String? convertedPrice,
  dynamic convertedDiscountPrice,
  dynamic regularPrice,
}) => Spare(  id: id ?? _id,
  productId: productId ?? _productId,
  variantSlug: variantSlug ?? _variantSlug,
  price: price ?? _price,
  sequence: sequence ?? _sequence,
  image: image ?? _image,
  discountPrice: discountPrice ?? _discountPrice,
  stock: stock ?? _stock,
  sku: sku ?? _sku,
  barcode: barcode ?? _barcode,
  weight: weight ?? _weight,
  dimensions: dimensions ?? _dimensions,
  isPrimary: isPrimary ?? _isPrimary,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
  description: description ?? _description,
  convertedPrice: convertedPrice ?? _convertedPrice,
  convertedDiscountPrice: convertedDiscountPrice ?? _convertedDiscountPrice,
  regularPrice: regularPrice ?? _regularPrice,
);
  num? get id => _id;
  num? get productId => _productId;
  String? get variantSlug => _variantSlug;
  String? get price => _price;
  num? get sequence => _sequence;
  String? get image => _image;
  dynamic get discountPrice => _discountPrice;
  num? get stock => _stock;
  dynamic get sku => _sku;
  dynamic get barcode => _barcode;
  dynamic get weight => _weight;
  dynamic get dimensions => _dimensions;
  num? get isPrimary => _isPrimary;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  dynamic get description => _description;
  String? get convertedPrice => _convertedPrice;
  dynamic get convertedDiscountPrice => _convertedDiscountPrice;
  dynamic get regularPrice => _regularPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['product_id'] = _productId;
    map['variant_slug'] = _variantSlug;
    map['price'] = _price;
    map['sequence'] = _sequence;
    map['image'] = _image;
    map['discount_price'] = _discountPrice;
    map['stock'] = _stock;
    map['SKU'] = _sku;
    map['barcode'] = _barcode;
    map['weight'] = _weight;
    map['dimensions'] = _dimensions;
    map['is_primary'] = _isPrimary;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['description'] = _description;
    map['converted_price'] = _convertedPrice;
    map['converted_discount_price'] = _convertedDiscountPrice;
    map['regular_price'] = _regularPrice;
    return map;
  }

}