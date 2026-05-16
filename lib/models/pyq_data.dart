import 'package:json_annotation/json_annotation.dart';

import 'course.dart';

part 'generated/pyq_data.g.dart';

@JsonSerializable()
class PyqData {
  final List<Course> courses;

  const PyqData({required this.courses});

  factory PyqData.fromJson(Map<String, dynamic> json) =>
      _$PyqDataFromJson(json);

  Map<String, dynamic> toJson() => _$PyqDataToJson(this);
}
