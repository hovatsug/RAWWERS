// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsubscribe_link_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnsubscribeLinkView _$UnsubscribeLinkViewFromJson(Map<String, dynamic> json) =>
    _UnsubscribeLinkView(
      topic: json['topic'] as String,
      topicLabel: json['topic_label'] as String,
      all: UnsubscribeAllLink.fromJson(json['all'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnsubscribeLinkViewToJson(
  _UnsubscribeLinkView instance,
) => <String, dynamic>{
  'topic': instance.topic,
  'topic_label': instance.topicLabel,
  'all': instance.all,
};
