import 'dart:async';

import 'package:app_api_demo/models/issue.dart';
import 'package:app_api_demo/services/api_service.dart';
import 'package:app_api_demo/services/issue_service.dart';


class IssueBloc {


  final _streamController = StreamController<List<Issue>>();
  Stream<List<Issue>> get stream => _streamController.stream;

  var issues = <Issue>[];

  UserBloc() {
    // getUsers();
  }

  void dispose() {
    _streamController.close();
  }

  void getIssue({required dynamic limit,required dynamic offset}) {
    Map<String, dynamic> parameters = Map<String, dynamic>();
    parameters["limit"] = limit;
    parameters["offset"] = offset;

    apiService.getIssues(
      parameters: parameters,
      onSuccess: (data) {
        print('$data');
        issues = data;
        _streamController.sink.add(issues);
      },
      onFailure: (error) {
        _streamController.addError(error);
      },
    );
  }

  void addListIssue({required dynamic limit,required dynamic offset}) {
    Map<String, dynamic> parameters = Map<String, dynamic>();
    parameters["limit"] = limit;
    parameters["offset"] = offset;

    apiService.getIssues(
      parameters: parameters,
      onSuccess: (data) {
        print('$data');
        issues.addAll(data);
        _streamController.sink.add(issues);
      },
      onFailure: (error) {
        _streamController.addError(error);
      },
    );
  }
}