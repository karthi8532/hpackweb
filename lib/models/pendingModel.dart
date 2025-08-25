class ApprovalListResponse {
  final bool status;
  final ApprovalListMessage message;

  ApprovalListResponse({required this.status, required this.message});

  factory ApprovalListResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalListResponse(
      status: json['status'],
      message: ApprovalListMessage.fromJson(json['message']),
    );
  }
}

class ApprovalListMessage {
  final int pending;
  final int approved;
  final int reject;
  final int cancelled;
  final List<ApprovalDetail> details;

  ApprovalListMessage({
    required this.pending,
    required this.approved,
    required this.reject,
    required this.cancelled,
    required this.details,
  });

  factory ApprovalListMessage.fromJson(Map<String, dynamic> json) {
    return ApprovalListMessage(
      pending: json['Pending'],
      approved: json['Approved'],
      reject: json['Reject'],
      cancelled: json['Cancelled'],
      details:
          (json['details'] as List)
              .map((e) => ApprovalDetail.fromJson(e))
              .toList(),
    );
  }
}

class ApprovalDetail {
  final int docentry;
  final String cardCode;
  final String cardName;
  final String effectiveDate;
  final String priceListName;
  final String remarks;
  final String approverremarks;
  final String status;

  ApprovalDetail({
    required this.docentry,
    required this.cardCode,
    required this.cardName,
    required this.effectiveDate,
    required this.priceListName,
    required this.remarks,
    required this.approverremarks,
    required this.status,
  });

  factory ApprovalDetail.fromJson(Map<String, dynamic> json) {
    return ApprovalDetail(
      docentry: json['DocEntry'],
      cardCode: json['CardCode'],
      cardName: json['CardName'],
      effectiveDate: json['EffectiveDate'],
      priceListName: json['PriceListName'],
      remarks: json['Remarks'] ?? "-",
      approverremarks: json['ApproverRemarks'] ?? "-",
      status: json['Status'],
    );
  }
}
