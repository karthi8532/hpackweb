class LoginModel {
  final String salesEmployeeId;
  final String salesEmployeeName;

  LoginModel({required this.salesEmployeeId, required this.salesEmployeeName});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      salesEmployeeId: json['salesEmployeeId'],
      salesEmployeeName: json['salesEmployeeName'],
    );
  }
}
