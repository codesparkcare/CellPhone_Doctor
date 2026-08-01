class CommonResponseModel {
  final bool status;
  final String message;

  CommonResponseModel({
    required this.status,
    required this.message
  });

  factory CommonResponseModel.fromJson(Map<String, dynamic> json) {
    return CommonResponseModel(
      status: json['status'],
      message: json['message']
    );
  }
}
