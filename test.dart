class Data {
  dynamic deliveryCharge;
  Data({this.deliveryCharge});
  Data copyWith({dynamic deliveryCharge}) {
    return Data(deliveryCharge: deliveryCharge ?? this.deliveryCharge);
  }
}
void main() {
  dynamic jsonDeliveryCharge = 99.0;
  var item = Data(deliveryCharge: null);
  if (item.deliveryCharge == null) {
    item = item.copyWith(deliveryCharge: jsonDeliveryCharge);
  }
  print(item.deliveryCharge);
  print(item.deliveryCharge.toString() != "0");
}
