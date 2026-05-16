import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';
import '../models/paper.dart';
import '../models/pyq_data.dart';

class PyqDataService {
  static const String _owner = 'M4dhav';
  static const String _repo = 'BU-Scholar';
  static const String _dataFile = 'pyq-data.json';
  static const String _pdfFolder = 'pyqs';

  static const String _vercelEnv = String.fromEnvironment('VERCEL_ENV');
  static const bool _isProduction = _vercelEnv == 'production';
  static const String _branch = _isProduction ? 'main' : 'dev';

  static const String _rawBase =
      'https://raw.githubusercontent.com/$_owner/$_repo/$_branch';

  Future<PyqData> fetchPyqData() async {
    final response = await http.get(Uri.parse('$_rawBase/$_dataFile'));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch pyq-data.json (status ${response.statusCode})',
      );
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = PyqData.fromJson(decoded);

    for (final course in data.courses) {
      course.papers.sort((a, b) {
        final byYear = b.paperYear.compareTo(a.paperYear);
        if (byYear != 0) return byYear;
        return a.paperName.compareTo(b.paperName);
      });
    }

    return data;
  }

  Stream<Course> fetchCoursesStream() async* {
    final data = await fetchPyqData();
    for (final course in data.courses) {
      yield course;
    }
  }

  static String paperUrl(Paper paper) => '$_rawBase/$_pdfFolder/${paper.paperId}';
}
