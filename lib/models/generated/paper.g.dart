// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../paper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paper _$PaperFromJson(Map<String, dynamic> json) => Paper(
  paperName: json['paper_name'] as String,
  paperYear: (json['paper_year'] as num).toInt(),
  paperId: json['paper_id'] as String,
  paperNum: (json['paper_num'] as num).toInt(),
);

Map<String, dynamic> _$PaperToJson(Paper instance) => <String, dynamic>{
  'paper_name': instance.paperName,
  'paper_year': instance.paperYear,
  'paper_id': instance.paperId,
  'paper_num': instance.paperNum,
};
