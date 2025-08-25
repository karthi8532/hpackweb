class LoginModel {
  final String salesEmployeeId;
  final String salesEmployeeName;
  final String approvedby;
  final String fromMail;
  final String toMail;

  LoginModel({
    required this.salesEmployeeId,
    required this.salesEmployeeName,
    required this.approvedby,
    required this.fromMail,
    required this.toMail,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      salesEmployeeId: json['salesEmployeeId'],
      salesEmployeeName: json['salesEmployeeName'],
      approvedby: json['approvedby'],
      fromMail: json['fromMailId'],
      toMail: json['toMailId'],
    );
  }
}
