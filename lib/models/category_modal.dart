// lib/models/category_model.dart

class CategoryModel {
  final String name;
  final String image;

  CategoryModel({
    required this.name,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
    };
  }
}
