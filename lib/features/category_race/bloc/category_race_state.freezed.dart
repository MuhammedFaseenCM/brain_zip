// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_race_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryRaceState {

 CategoryRaceStatus get status; WordCategory? get category; String get letter; int get totalSeconds; int get remainingSeconds; List<String> get answers; String? get feedback; String? get error; bool? get improved; ResultsArgs? get resultsExtra; bool get finished;
/// Create a copy of CategoryRaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryRaceStateCopyWith<CategoryRaceState> get copyWith => _$CategoryRaceStateCopyWithImpl<CategoryRaceState>(this as CategoryRaceState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceState&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.letter, letter) || other.letter == letter)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&const DeepCollectionEquality().equals(other.answers, answers)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.error, error) || other.error == error)&&(identical(other.improved, improved) || other.improved == improved)&&(identical(other.resultsExtra, resultsExtra) || other.resultsExtra == resultsExtra)&&(identical(other.finished, finished) || other.finished == finished));
}


@override
int get hashCode => Object.hash(runtimeType,status,category,letter,totalSeconds,remainingSeconds,const DeepCollectionEquality().hash(answers),feedback,error,improved,resultsExtra,finished);

@override
String toString() {
  return 'CategoryRaceState(status: $status, category: $category, letter: $letter, totalSeconds: $totalSeconds, remainingSeconds: $remainingSeconds, answers: $answers, feedback: $feedback, error: $error, improved: $improved, resultsExtra: $resultsExtra, finished: $finished)';
}


}

/// @nodoc
abstract mixin class $CategoryRaceStateCopyWith<$Res>  {
  factory $CategoryRaceStateCopyWith(CategoryRaceState value, $Res Function(CategoryRaceState) _then) = _$CategoryRaceStateCopyWithImpl;
@useResult
$Res call({
 CategoryRaceStatus status, WordCategory? category, String letter, int totalSeconds, int remainingSeconds, List<String> answers, String? feedback, String? error, bool? improved, ResultsArgs? resultsExtra, bool finished
});




}
/// @nodoc
class _$CategoryRaceStateCopyWithImpl<$Res>
    implements $CategoryRaceStateCopyWith<$Res> {
  _$CategoryRaceStateCopyWithImpl(this._self, this._then);

  final CategoryRaceState _self;
  final $Res Function(CategoryRaceState) _then;

/// Create a copy of CategoryRaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? category = freezed,Object? letter = null,Object? totalSeconds = null,Object? remainingSeconds = null,Object? answers = null,Object? feedback = freezed,Object? error = freezed,Object? improved = freezed,Object? resultsExtra = freezed,Object? finished = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CategoryRaceStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WordCategory?,letter: null == letter ? _self.letter : letter // ignore: cast_nullable_to_non_nullable
as String,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<String>,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,improved: freezed == improved ? _self.improved : improved // ignore: cast_nullable_to_non_nullable
as bool?,resultsExtra: freezed == resultsExtra ? _self.resultsExtra : resultsExtra // ignore: cast_nullable_to_non_nullable
as ResultsArgs?,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryRaceState].
extension CategoryRaceStatePatterns on CategoryRaceState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryRaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryRaceState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryRaceState value)  $default,){
final _that = this;
switch (_that) {
case _CategoryRaceState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryRaceState value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryRaceState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryRaceStatus status,  WordCategory? category,  String letter,  int totalSeconds,  int remainingSeconds,  List<String> answers,  String? feedback,  String? error,  bool? improved,  ResultsArgs? resultsExtra,  bool finished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryRaceState() when $default != null:
return $default(_that.status,_that.category,_that.letter,_that.totalSeconds,_that.remainingSeconds,_that.answers,_that.feedback,_that.error,_that.improved,_that.resultsExtra,_that.finished);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryRaceStatus status,  WordCategory? category,  String letter,  int totalSeconds,  int remainingSeconds,  List<String> answers,  String? feedback,  String? error,  bool? improved,  ResultsArgs? resultsExtra,  bool finished)  $default,) {final _that = this;
switch (_that) {
case _CategoryRaceState():
return $default(_that.status,_that.category,_that.letter,_that.totalSeconds,_that.remainingSeconds,_that.answers,_that.feedback,_that.error,_that.improved,_that.resultsExtra,_that.finished);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryRaceStatus status,  WordCategory? category,  String letter,  int totalSeconds,  int remainingSeconds,  List<String> answers,  String? feedback,  String? error,  bool? improved,  ResultsArgs? resultsExtra,  bool finished)?  $default,) {final _that = this;
switch (_that) {
case _CategoryRaceState() when $default != null:
return $default(_that.status,_that.category,_that.letter,_that.totalSeconds,_that.remainingSeconds,_that.answers,_that.feedback,_that.error,_that.improved,_that.resultsExtra,_that.finished);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryRaceState implements CategoryRaceState {
  const _CategoryRaceState({this.status = CategoryRaceStatus.initial, this.category, this.letter = 'A', this.totalSeconds = 60, this.remainingSeconds = 60, final  List<String> answers = const <String>[], this.feedback, this.error, this.improved, this.resultsExtra, this.finished = false}): _answers = answers;
  

@override@JsonKey() final  CategoryRaceStatus status;
@override final  WordCategory? category;
@override@JsonKey() final  String letter;
@override@JsonKey() final  int totalSeconds;
@override@JsonKey() final  int remainingSeconds;
 final  List<String> _answers;
@override@JsonKey() List<String> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

@override final  String? feedback;
@override final  String? error;
@override final  bool? improved;
@override final  ResultsArgs? resultsExtra;
@override@JsonKey() final  bool finished;

/// Create a copy of CategoryRaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryRaceStateCopyWith<_CategoryRaceState> get copyWith => __$CategoryRaceStateCopyWithImpl<_CategoryRaceState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryRaceState&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.letter, letter) || other.letter == letter)&&(identical(other.totalSeconds, totalSeconds) || other.totalSeconds == totalSeconds)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&const DeepCollectionEquality().equals(other._answers, _answers)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.error, error) || other.error == error)&&(identical(other.improved, improved) || other.improved == improved)&&(identical(other.resultsExtra, resultsExtra) || other.resultsExtra == resultsExtra)&&(identical(other.finished, finished) || other.finished == finished));
}


@override
int get hashCode => Object.hash(runtimeType,status,category,letter,totalSeconds,remainingSeconds,const DeepCollectionEquality().hash(_answers),feedback,error,improved,resultsExtra,finished);

@override
String toString() {
  return 'CategoryRaceState(status: $status, category: $category, letter: $letter, totalSeconds: $totalSeconds, remainingSeconds: $remainingSeconds, answers: $answers, feedback: $feedback, error: $error, improved: $improved, resultsExtra: $resultsExtra, finished: $finished)';
}


}

/// @nodoc
abstract mixin class _$CategoryRaceStateCopyWith<$Res> implements $CategoryRaceStateCopyWith<$Res> {
  factory _$CategoryRaceStateCopyWith(_CategoryRaceState value, $Res Function(_CategoryRaceState) _then) = __$CategoryRaceStateCopyWithImpl;
@override @useResult
$Res call({
 CategoryRaceStatus status, WordCategory? category, String letter, int totalSeconds, int remainingSeconds, List<String> answers, String? feedback, String? error, bool? improved, ResultsArgs? resultsExtra, bool finished
});




}
/// @nodoc
class __$CategoryRaceStateCopyWithImpl<$Res>
    implements _$CategoryRaceStateCopyWith<$Res> {
  __$CategoryRaceStateCopyWithImpl(this._self, this._then);

  final _CategoryRaceState _self;
  final $Res Function(_CategoryRaceState) _then;

/// Create a copy of CategoryRaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? category = freezed,Object? letter = null,Object? totalSeconds = null,Object? remainingSeconds = null,Object? answers = null,Object? feedback = freezed,Object? error = freezed,Object? improved = freezed,Object? resultsExtra = freezed,Object? finished = null,}) {
  return _then(_CategoryRaceState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CategoryRaceStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WordCategory?,letter: null == letter ? _self.letter : letter // ignore: cast_nullable_to_non_nullable
as String,totalSeconds: null == totalSeconds ? _self.totalSeconds : totalSeconds // ignore: cast_nullable_to_non_nullable
as int,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<String>,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,improved: freezed == improved ? _self.improved : improved // ignore: cast_nullable_to_non_nullable
as bool?,resultsExtra: freezed == resultsExtra ? _self.resultsExtra : resultsExtra // ignore: cast_nullable_to_non_nullable
as ResultsArgs?,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
