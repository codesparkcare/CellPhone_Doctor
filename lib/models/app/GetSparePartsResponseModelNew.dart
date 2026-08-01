/// status : true
/// data : [{"id":55,"category":2,"brand":19,"model":2,"sparetitle":2,"sequence":1,"spare":[{"id":61,"product_id":55,"variant_slug":"original display(display class combo offer)-69368769dff71","price":"25999.00","sequence":1,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":1,"name":"original display(display class combo offer)","converted_price":25999,"converted_discount_price":null,"translations":[{"id":167,"product_variant_id":61,"language_code":"en","name":"original display(display class combo offer)","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]},{"id":62,"product_id":55,"variant_slug":"LCD Display Module Black High Quality-69368769e0324","price":"17999.00","sequence":2,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":0,"name":"LCD Display Module Black High Quality","converted_price":17999,"converted_discount_price":null,"translations":[{"id":168,"product_variant_id":62,"language_code":"en","name":"LCD Display Module Black High Quality","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]},{"id":63,"product_id":55,"variant_slug":"Compatible  LCD Display, Touch Screen Combo-69368769e0551","price":"17999.00","sequence":3,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":0,"name":"Compatible  LCD Display, Touch Screen Combo","converted_price":17999,"converted_discount_price":null,"translations":[{"id":169,"product_variant_id":63,"language_code":"en","name":"Compatible  LCD Display, Touch Screen Combo","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]}]}]

class GetSparePartsResponseModelNew {
  GetSparePartsResponseModelNew({
      bool? status, 
      List<Data>? data,}){
    _status = status;
    _data = data;
}

  GetSparePartsResponseModelNew.fromJson(dynamic json) {
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
GetSparePartsResponseModelNew copyWith({  bool? status,
  List<Data>? data,
}) => GetSparePartsResponseModelNew(  status: status ?? _status,
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

/// id : 55
/// category : 2
/// brand : 19
/// model : 2
/// sparetitle : 2
/// sequence : 1
/// spare : [{"id":61,"product_id":55,"variant_slug":"original display(display class combo offer)-69368769dff71","price":"25999.00","sequence":1,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":1,"name":"original display(display class combo offer)","converted_price":25999,"converted_discount_price":null,"translations":[{"id":167,"product_variant_id":61,"language_code":"en","name":"original display(display class combo offer)","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]},{"id":62,"product_id":55,"variant_slug":"LCD Display Module Black High Quality-69368769e0324","price":"17999.00","sequence":2,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":0,"name":"LCD Display Module Black High Quality","converted_price":17999,"converted_discount_price":null,"translations":[{"id":168,"product_variant_id":62,"language_code":"en","name":"LCD Display Module Black High Quality","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]},{"id":63,"product_id":55,"variant_slug":"Compatible  LCD Display, Touch Screen Combo-69368769e0551","price":"17999.00","sequence":3,"image":"https://thecellphonedoctor.com/mobileapp/public/storage/photos/1/Service/spare options/display","discount_price":null,"stock":0,"SKU":null,"barcode":null,"weight":null,"dimensions":null,"is_primary":1,"created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z","description":null,"is_cart":0,"name":"Compatible  LCD Display, Touch Screen Combo","converted_price":17999,"converted_discount_price":null,"translations":[{"id":169,"product_variant_id":63,"language_code":"en","name":"Compatible  LCD Display, Touch Screen Combo","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]}]

class Data {
  Data({
      num? id, 
      num? category, 
      num? brand, 
      num? model, 
      num? sparetitle, 
      String? parentname,
      String? name,
      String? image,
      num? sequence, 
      List<Spare>? spare,}){
    _id = id;
    _category = category;
    _brand = brand;
    _model = model;
    _sparetitle = sparetitle;
    _parentname = parentname;
    _name = name;
    _image = image;
    _sequence = sequence;
    _spare = spare;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _category = json['category'];
    _brand = json['brand'];
    _model = json['model'];
    _sparetitle = json['sparetitle'];
    _parentname = json['parentname'];
    _name = json['name'];
    _image = json['image'];
    _sequence = json['sequence'];
    if (json['spare'] != null) {
      _spare = [];
      json['spare'].forEach((v) {
        _spare?.add(Spare.fromJson(v));
      });
    }
  }
  num? _id;
  num? _category;
  num? _brand;
  num? _model;
  num? _sparetitle;
  String? _parentname;
  String? _name;
  String? _image;
  num? _sequence;
  List<Spare>? _spare;
Data copyWith({  num? id,
  num? category,
  num? brand,
  num? model,
  num? sparetitle,
  String? parentname,
  String? name,
  String? image,
  num? sequence,
  List<Spare>? spare,
}) => Data(  id: id ?? _id,
  category: category ?? _category,
  brand: brand ?? _brand,
  model: model ?? _model,
  sparetitle: sparetitle ?? _sparetitle,
  parentname: parentname ?? _parentname,
  name: name ?? _name,
  image: image ?? _image,
  sequence: sequence ?? _sequence,
  spare: spare ?? _spare,
);
  num? get id => _id;
  num? get category => _category;
  num? get brand => _brand;
  num? get model => _model;
  num? get sparetitle => _sparetitle;
  String? get parentname => _parentname;
  String? get name => _name;
  String? get image => _image;
  num? get sequence => _sequence;
  List<Spare>? get spare => _spare;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['category'] = _category;
    map['brand'] = _brand;
    map['model'] = _model;
    map['sparetitle'] = _sparetitle;
    map['parentname'] = _parentname;
    map['name'] = _name;
    map['image'] = _image;
    map['sequence'] = _sequence;
    if (_spare != null) {
      map['spare'] = _spare?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 61
/// product_id : 55
/// variant_slug : "original display(display class combo offer)-69368769dff71"
/// price : "25999.00"
/// sequence : 1
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
/// is_cart : 1
/// name : "original display(display class combo offer)"
/// converted_price : 25999
/// converted_discount_price : null
/// translations : [{"id":167,"product_variant_id":61,"language_code":"en","name":"original display(display class combo offer)","created_at":"2025-12-08T08:08:09.000000Z","updated_at":"2025-12-08T08:08:09.000000Z"}]

class Spare {
  Spare({
      num? id, 
      num? productId, 
      String? variantSlug, 
      String? price,
      String? regularPrice,
      num? sequence,
      String? image,
      String? warranty,
      String? warranty_discription,
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
      num? isCart, 
      String? name,
    String? convertedPrice,
      dynamic convertedDiscountPrice, 
      List<Translations>? translations,}){
    _id = id;
    _productId = productId;
    _variantSlug = variantSlug;
    _price = price;
    _regularPrice = regularPrice;
    _sequence = sequence;
    _image = image;
    _warranty = warranty;
    _warranty_discription = warranty_discription;
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
    _isCart = isCart;
    _name = name;
    _convertedPrice = convertedPrice;
    _convertedDiscountPrice = convertedDiscountPrice;
    _translations = translations;
}

  Spare.fromJson(dynamic json) {
    _id = json['id'];
    _productId = json['product_id'];
    _variantSlug = json['variant_slug'];
    _price = json['price'];
    _regularPrice = json['regular_price'];
    _sequence = json['sequence'];
    _image = json['image'];
    _warranty = json['warranty'];
    _warranty_discription = json['warranty_discription'];
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
    _isCart = json['is_cart'];
    _name = json['name'];
    _convertedPrice = json['converted_price'];
    _convertedDiscountPrice = json['converted_discount_price'];
    if (json['translations'] != null) {
      _translations = [];
      json['translations'].forEach((v) {
        _translations?.add(Translations.fromJson(v));
      });
    }
  }
  num? _id;
  num? _productId;
  String? _variantSlug;
  String? _price;
  String? _regularPrice;
  num? _sequence;
  String? _image;
  String? _warranty;
  String? _warranty_discription;
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
  num? _isCart;
  String? _name;
  String? _convertedPrice;
  dynamic _convertedDiscountPrice;
  List<Translations>? _translations;
Spare copyWith({  num? id,
  num? productId,
  String? variantSlug,
  String? price,
  String? regularPrice,
  num? sequence,
  String? image,
  String? warranty,
  String? warranty_discription,
  String? w,
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
  num? isCart,
  String? name,
  String? convertedPrice,
  dynamic convertedDiscountPrice,
  List<Translations>? translations,
}) => Spare(  id: id ?? _id,
  productId: productId ?? _productId,
  variantSlug: variantSlug ?? _variantSlug,
  price: price ?? _price,
  regularPrice: regularPrice ?? _regularPrice,
  sequence: sequence ?? _sequence,
  image: image ?? _image,
  warranty: warranty ?? _warranty,
  warranty_discription: warranty_discription ?? _warranty_discription,
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
  isCart: isCart ?? _isCart,
  name: name ?? _name,
  convertedPrice: convertedPrice ?? _convertedPrice,
  convertedDiscountPrice: convertedDiscountPrice ?? _convertedDiscountPrice,
  translations: translations ?? _translations,
);
  num? get id => _id;
  num? get productId => _productId;
  String? get variantSlug => _variantSlug;
  String? get price => _price;
  String? get regularPrice => _regularPrice;
  num? get sequence => _sequence;
  String? get image => _image;
  String? get warranty => _warranty;
  String? get warranty_discription => _warranty_discription;
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
  num? get isCart => _isCart;
  String? get name => _name;
  String? get convertedPrice => _convertedPrice;
  dynamic get convertedDiscountPrice => _convertedDiscountPrice;
  List<Translations>? get translations => _translations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['product_id'] = _productId;
    map['variant_slug'] = _variantSlug;
    map['price'] = _price;
    map['regular_price'] = _regularPrice;
    map['sequence'] = _sequence;
    map['image'] = _image;
    map['warranty'] = _warranty;
    map['warranty_discription'] = _warranty_discription;
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
    map['is_cart'] = _isCart;
    map['name'] = _name;
    map['converted_price'] = _convertedPrice;
    map['converted_discount_price'] = _convertedDiscountPrice;
    if (_translations != null) {
      map['translations'] = _translations?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 167
/// product_variant_id : 61
/// language_code : "en"
/// name : "original display(display class combo offer)"
/// created_at : "2025-12-08T08:08:09.000000Z"
/// updated_at : "2025-12-08T08:08:09.000000Z"

class Translations {
  Translations({
      num? id, 
      num? productVariantId, 
      String? languageCode, 
      String? name, 
      String? createdAt, 
      String? updatedAt,}){
    _id = id;
    _productVariantId = productVariantId;
    _languageCode = languageCode;
    _name = name;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
}

  Translations.fromJson(dynamic json) {
    _id = json['id'];
    _productVariantId = json['product_variant_id'];
    _languageCode = json['language_code'];
    _name = json['name'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  num? _productVariantId;
  String? _languageCode;
  String? _name;
  String? _createdAt;
  String? _updatedAt;
Translations copyWith({  num? id,
  num? productVariantId,
  String? languageCode,
  String? name,
  String? createdAt,
  String? updatedAt,
}) => Translations(  id: id ?? _id,
  productVariantId: productVariantId ?? _productVariantId,
  languageCode: languageCode ?? _languageCode,
  name: name ?? _name,
  createdAt: createdAt ?? _createdAt,
  updatedAt: updatedAt ?? _updatedAt,
);
  num? get id => _id;
  num? get productVariantId => _productVariantId;
  String? get languageCode => _languageCode;
  String? get name => _name;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['product_variant_id'] = _productVariantId;
    map['language_code'] = _languageCode;
    map['name'] = _name;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}