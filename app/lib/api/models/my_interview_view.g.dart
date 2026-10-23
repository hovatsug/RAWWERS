// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_interview_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyInterviewView _$MyInterviewViewFromJson(Map<String, dynamic> json) =>
    _MyInterviewView(
      items: (json['items'] as List<dynamic>)
          .map((e) => InterviewAnswerView.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublished: json['is_published'] as bool,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      hasUnpublishedChanges: json['has_unpublished_changes'] as bool,
    );

Map<String, dynamic> _$MyInterviewViewToJson(_MyInterviewView instance) =>
    <String, dynamic>{
      'items': instance.items,
      'is_published': instance.isPublished,
      'published_at': instance.publishedAt?.toIso8601String(),
      'has_unpublished_changes': instance.hasUnpublishedChanges,
    };
