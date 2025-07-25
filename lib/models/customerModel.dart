class CustomerModel {
  String? cardCode;
  String? cardName;
  final List<AddressModel> billingAddress;
  final List<AddressModel> shippingAddress;
  CustomerModel({
    required this.cardCode,
    required this.cardName,
    required this.billingAddress,
    required this.shippingAddress,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      cardCode: json["cardCode"],
      cardName: json["cardName"],
      billingAddress:
          (json['billingAddress'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
      shippingAddress:
          (json['shippingAddress'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
    );
  }
  String get billingFullAddress =>
      billingAddress.isNotEmpty ? billingAddress.first.fullAddress : '';

  String get shippingFullAddress =>
      shippingAddress.isNotEmpty ? shippingAddress.first.fullAddress : '';
}
class AddressModel {
  final String address;
  final String address2;
  final String address3;
  final String zipCode;
  final String city;
  final String country;

  AddressModel({
    required this.address,
    required this.address2,
    required this.address3,
    required this.zipCode,
    required this.city,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address: json['address'] ?? '',
      address2: json['address2'] ?? '',
      address3: json['address3'] ?? '',
      zipCode: json['zipCode'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  String get fullAddress {
    return [
      address,
      address2,
      address3,
      city,
      zipCode,
      country,
    ].where((e) => e.isNotEmpty).join(', ');
  }
}
