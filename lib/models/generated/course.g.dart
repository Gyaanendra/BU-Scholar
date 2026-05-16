// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  courseNum: (json['course_num'] as num).toInt(),
  name: json['name'] as String,
  courseId:
      (json['course_id'] as List<dynamic>).map((e) => e as String).toList(),
  papers:
      (json['papers'] as List<dynamic>)
          .map((e) => Paper.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'course_num': instance.courseNum,
  'name': instance.name,
  'course_id': instance.courseId,
  'papers': instance.papers,
};
