import 'dart:convert';

class TesseractLogs {
  String? workerId;
  String? jobId;
  String? status;
  double? progress;

  TesseractLogs({this.workerId, this.jobId, this.status, this.progress});

  static TesseractLogs fromJson(jsonData) {
    var data = json.decode(jsonData);
    return TesseractLogs(
      workerId: data['workerId'],
      jobId: data['userJobId'],
      status: data['status'],
      progress: double.tryParse(data['progress']?.toString() ?? '0'),
    );
  }

  toJson() {
    return {
      "workerId": workerId,
      "jobId": jobId,
      "status": status,
      "progress": progress
    };
  }
}
