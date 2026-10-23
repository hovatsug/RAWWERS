// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_answer_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InterviewAnswerView _$InterviewAnswerViewFromJson(Map<String, dynamic> json) =>
    _InterviewAnswerView(
      questionId: json['question_id'] as String,
      prompt: json['prompt'] as String,
      title: json['title'] as String,
      hint: json['hint'] as String?,
      minChars: (json['min_chars'] as num).toInt(),
      maxChars: (json['max_chars'] as num).toInt(),
      draft: json['draft'] as String?,
      published: json['published'] as String?,
      warning: json['warning'] as String?,
    );

Map<String, dynamic> _$InterviewAnswerViewToJson(
  _InterviewAnswerView instance,
) => <String, dynamic>{
  'question_id': instance.questionId,
  'prompt': instance.prompt,
  'title': instance.title,
  'hint': instance.hint,
  'min_chars': instance.minChars,
  'max_chars': instance.maxChars,
  'draft': instance.draft,
  'published': instance.published,
  'warning': instance.warning,
};
