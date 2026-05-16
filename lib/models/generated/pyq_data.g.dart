// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../pyq_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PyqData _$PyqDataFromJson(Map<String, dynamic> json) => PyqData(
  courses:
      (json['courses'] as List<dynamic>)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PyqDataToJson(PyqData instance) => <String, dynamic>{
  'courses': instance.courses,
};
