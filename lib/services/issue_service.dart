import 'package:app_api_demo/models/issue.dart';
import 'package:app_api_demo/services/api_service.dart';

extension UserService on ApiService {
  Future<void> getIssues({
    required Map<String, dynamic> parameters,
    required Function(List<Issue>) onSuccess,
    required Function(String) onFailure,
  }) async {

    request(
      path: '/api/issues?limit=${parameters["limit"]}&offset=${parameters["offset"]}',
      method: Method.get,
      parameters: parameters,
      onSuccess: (json) {
        final issues = List<Issue>.from(json.map((e) => Issue.fromJson(e)));
        onSuccess(issues);
      },
      onFailure: onFailure,
    );

  }
}