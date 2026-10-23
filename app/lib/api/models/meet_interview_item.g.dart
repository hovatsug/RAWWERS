// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meet_interview_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeetInterviewItem _$MeetInterviewItemFromJson(Map<String, dynamic> json) =>
    _MeetInterviewItem(
      questionId: json['question_id'] as String,
      title: json['title'] as String,
      answer: json['answer'] as String,
    );

Map<String, dynamic> _$MeetInterviewItemToJson(_MeetInterviewItem instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'title': instance.title,
      'answer': instance.answer,
    };
