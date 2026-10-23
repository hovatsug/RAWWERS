/// FindingView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "title": "Gig Id"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         },
///         "reason": {
///             "type": "string",
///             "title": "Reason"
///         },
///         "note": {
///             "type": "string",
///             "title": "Note"
///         },
///         "severe": {
///             "type": "boolean",
///             "title": "Severe"
///         },
///         "created_at": {
///             "type": "string",
///             "title": "Created At"
///         },
///         "first_seen_at": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "First Seen At"
///         },
///         "window_ends_at": {
///             "type": "string",
///             "title": "Window Ends At"
///         },
///         "response": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Response"
///         },
///         "decision_note": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Decision Note"
///         },
///         "consequence": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Consequence"
///         },
///         "strike_number": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Strike Number"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "gig_id",
///         "status",
///         "reason",
///         "note",
///         "severe",
///         "created_at",
///         "window_ends_at"
///     ],
///     "title": "FindingView"
/// }
library finding_view;

import 'exports.dart';
part 'finding_view.freezed.dart';
part 'finding_view.g.dart'; // FindingView

@freezed
abstract class FindingView with _$FindingView {
  const FindingView._();

  @jsonSerializable
  const factory FindingView({
    /// id
    @JsonKey(name: FindingView.idKey_) required String id,

    /// gigId
    @JsonKey(name: FindingView.gigIdKey_) required String gigId,

    /// status
    @JsonKey(name: FindingView.statusKey_) required String status,

    /// reason
    @JsonKey(name: FindingView.reasonKey_) required String reason,

    /// note
    @JsonKey(name: FindingView.noteKey_) required String note,

    /// severe
    @JsonKey(name: FindingView.severeKey_) required bool severe,

    /// createdAt
    @JsonKey(name: FindingView.createdAtKey_) required String createdAt,

    /// firstSeenAt
    @JsonKey(name: FindingView.firstSeenAtKey_) String? firstSeenAt,

    /// windowEndsAt
    @JsonKey(name: FindingView.windowEndsAtKey_) required String windowEndsAt,

    /// response
    @JsonKey(name: FindingView.responseKey_) String? response,

    /// decisionNote
    @JsonKey(name: FindingView.decisionNoteKey_) String? decisionNote,

    /// consequence
    @JsonKey(name: FindingView.consequenceKey_) String? consequence,

    /// strikeNumber
    @JsonKey(name: FindingView.strikeNumberKey_) int? strikeNumber,
  }) = _FindingView;

  factory FindingView.fromJson(Map<String, dynamic> json) =>
      _$FindingViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String statusKey_ = r'status';

  static const String reasonKey_ = r'reason';

  static const String noteKey_ = r'note';

  static const String severeKey_ = r'severe';

  static const String createdAtKey_ = r'created_at';

  static const String firstSeenAtKey_ = r'first_seen_at';

  static const String windowEndsAtKey_ = r'window_ends_at';

  static const String responseKey_ = r'response';

  static const String decisionNoteKey_ = r'decision_note';

  static const String consequenceKey_ = r'consequence';

  static const String strikeNumberKey_ = r'strike_number';
}
