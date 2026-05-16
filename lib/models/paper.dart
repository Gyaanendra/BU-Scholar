import 'package:json_annotation/json_annotation.dart';

part 'generated/paper.g.dart';

@JsonSerializable()
class Paper {
  @JsonKey(name: 'paper_name')
  final String paperName;

  @JsonKey(name: 'paper_suffix')
  final String paperSuffix;

  @JsonKey(name: 'paper_id')
  final String paperId;

  @JsonKey(name: 'paper_num')
  final int paperNum;

  const Paper({
    required this.paperName,
    required this.paperSuffix,
    required this.paperId,
    required this.paperNum,
  });

  factory Paper.fromJson(Map<String, dynamic> json) => _$PaperFromJson(json);

  Map<String, dynamic> toJson() => _$PaperToJson(this);

  String get label => '$paperName $paperSuffix';

  int? get yearOrNull => int.tryParse(paperSuffix);
}
