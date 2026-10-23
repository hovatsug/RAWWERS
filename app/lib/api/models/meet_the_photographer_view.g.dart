// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meet_the_photographer_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeetThePhotographerView _$MeetThePhotographerViewFromJson(
  Map<String, dynamic> json,
) => _MeetThePhotographerView(
  video: json['video'] == null
      ? null
      : PresentationVideoView.fromJson(json['video'] as Map<String, dynamic>),
  interview: (json['interview'] as List<dynamic>?)
      ?.map((e) => MeetInterviewItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MeetThePhotographerViewToJson(
  _MeetThePhotographerView instance,
) => <String, dynamic>{
  'video': instance.video,
  'interview': instance.interview,
};
