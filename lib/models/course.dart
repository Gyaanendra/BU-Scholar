import 'package:json_annotation/json_annotation.dart';

import 'paper.dart';

part 'generated/course.g.dart';

@JsonSerializable()
class Course {
  @JsonKey(name: 'course_num')
  final int courseNum;

  final String name;

  @JsonKey(name: 'course_id')
  final List<String> courseId;

  final List<Paper> papers;

  const Course({
    required this.courseNum,
    required this.name,
    required this.courseId,
    required this.papers,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  String get primaryCourseId => courseId.isNotEmpty ? courseId.first : '';

  String get joinedCourseIds => courseId.join(' / ');
}
