/// ReviewNicheView
/// {
///     "properties": {
///         "slug": {
///             "type": "string",
///             "title": "Slug"
///         },
///         "name": {
///             "type": "string",
///             "title": "Name"
///         }
///     },
///     "type": "object",
///     "required": [
///         "slug",
///         "name"
///     ],
///     "title": "ReviewNicheView"
/// }
library review_niche_view;

import 'exports.dart';
part 'review_niche_view.freezed.dart';
part 'review_niche_view.g.dart'; // ReviewNicheView

@freezed
abstract class ReviewNicheView with _$ReviewNicheView {
  const ReviewNicheView._();

  @jsonSerializable
  const factory ReviewNicheView({
    /// slug
    @JsonKey(name: ReviewNicheView.slugKey_) required String slug,

    /// name
    @JsonKey(name: ReviewNicheView.nameKey_) required String name,
  }) = _ReviewNicheView;

  factory ReviewNicheView.fromJson(Map<String, dynamic> json) =>
      _$ReviewNicheViewFromJson(json);

  static const String slugKey_ = r'slug';

  static const String nameKey_ = r'name';
}
