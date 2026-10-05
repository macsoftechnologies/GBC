class GetInspectionReport {
  String? status;
  String? message;
  String? inspectionReport;

  GetInspectionReport({
    this.status,
    this.message,
    this.inspectionReport,
  });

  factory GetInspectionReport.fromJson(Map<String, dynamic> json) {
    return GetInspectionReport(
      status: json['status'],
      message: json['message'],
      inspectionReport: json['inspection_report'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'inspection_report': inspectionReport,
    };
  }
}
