// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_match_play_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordMatchPlayState {

 WordMatchPlayStatus get status; String? get deckId; WordMatchDeck? get deck; int get remainingSeconds; int get matched; int get total; bool get finished; ResultsArgs? get resultsExtra; String? get error;
/// Create a copy of WordMatchPlayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordMatchPlayStateCopyWith<WordMatchPlayState> get copyWith => _$WordMatchPlayStateCopyWithImpl<WordMatchPlayState>(this as WordMatchPlayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordMatchPlayState&&(identical(other.status, status) || other.status == status)&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.deck, deck) || other.deck == deck)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.total, total) || other.total == total)&&(identical(other.finished, finished) || other.finished == finished)&&(identical(other.resultsExtra, resultsExtra) || other.resultsExtra == resultsExtra)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,deckId,deck,remainingSeconds,matched,total,finished,resultsExtra,error);

@override
String toString() {
  return 'WordMatchPlayState(status: $status, deckId: $deckId, deck: $deck, remainingSeconds: $remainingSeconds, matched: $matched, total: $total, finished: $finished, resultsExtra: $resultsExtra, error: $error)';
}


}

/// @nodoc
abstract mixin class $WordMatchPlayStateCopyWith<$Res>  {
  factory $WordMatchPlayStateCopyWith(WordMatchPlayState value, $Res Function(WordMatchPlayState) _then) = _$WordMatchPlayStateCopyWithImpl;
@useResult
$Res call({
 WordMatchPlayStatus status, String? deckId, WordMatchDeck? deck, int remainingSeconds, int matched, int total, bool finished, ResultsArgs? resultsExtra, String? error
});




}
/// @nodoc
class _$WordMatchPlayStateCopyWithImpl<$Res>
    implements $WordMatchPlayStateCopyWith<$Res> {
  _$WordMatchPlayStateCopyWithImpl(this._self, this._then);

  final WordMatchPlayState _self;
  final $Res Function(WordMatchPlayState) _then;

/// Create a copy of WordMatchPlayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? deckId = freezed,Object? deck = freezed,Object? remainingSeconds = null,Object? matched = null,Object? total = null,Object? finished = null,Object? resultsExtra = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WordMatchPlayStatus,deckId: freezed == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String?,deck: freezed == deck ? _self.deck : deck // ignore: cast_nullable_to_non_nullable
as WordMatchDeck?,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,resultsExtra: freezed == resultsExtra ? _self.resultsExtra : resultsExtra // ignore: cast_nullable_to_non_nullable
as ResultsArgs?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordMatchPlayState].
extension WordMatchPlayStatePatterns on WordMatchPlayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordMatchPlayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordMatchPlayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordMatchPlayState value)  $default,){
final _that = this;
switch (_that) {
case _WordMatchPlayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordMatchPlayState value)?  $default,){
final _that = this;
switch (_that) {
case _WordMatchPlayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WordMatchPlayStatus status,  String? deckId,  WordMatchDeck? deck,  int remainingSeconds,  int matched,  int total,  bool finished,  ResultsArgs? resultsExtra,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordMatchPlayState() when $default != null:
return $default(_that.status,_that.deckId,_that.deck,_that.remainingSeconds,_that.matched,_that.total,_that.finished,_that.resultsExtra,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WordMatchPlayStatus status,  String? deckId,  WordMatchDeck? deck,  int remainingSeconds,  int matched,  int total,  bool finished,  ResultsArgs? resultsExtra,  String? error)  $default,) {final _that = this;
switch (_that) {
case _WordMatchPlayState():
return $default(_that.status,_that.deckId,_that.deck,_that.remainingSeconds,_that.matched,_that.total,_that.finished,_that.resultsExtra,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WordMatchPlayStatus status,  String? deckId,  WordMatchDeck? deck,  int remainingSeconds,  int matched,  int total,  bool finished,  ResultsArgs? resultsExtra,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _WordMatchPlayState() when $default != null:
return $default(_that.status,_that.deckId,_that.deck,_that.remainingSeconds,_that.matched,_that.total,_that.finished,_that.resultsExtra,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _WordMatchPlayState implements WordMatchPlayState {
  const _WordMatchPlayState({this.status = WordMatchPlayStatus.initial, this.deckId, this.deck, this.remainingSeconds = 0, this.matched = 0, this.total = 0, this.finished = false, this.resultsExtra, this.error});
  

@override@JsonKey() final  WordMatchPlayStatus status;
@override final  String? deckId;
@override final  WordMatchDeck? deck;
@override@JsonKey() final  int remainingSeconds;
@override@JsonKey() final  int matched;
@override@JsonKey() final  int total;
@override@JsonKey() final  bool finished;
@override final  ResultsArgs? resultsExtra;
@override final  String? error;

/// Create a copy of WordMatchPlayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordMatchPlayStateCopyWith<_WordMatchPlayState> get copyWith => __$WordMatchPlayStateCopyWithImpl<_WordMatchPlayState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordMatchPlayState&&(identical(other.status, status) || other.status == status)&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.deck, deck) || other.deck == deck)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.total, total) || other.total == total)&&(identical(other.finished, finished) || other.finished == finished)&&(identical(other.resultsExtra, resultsExtra) || other.resultsExtra == resultsExtra)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,deckId,deck,remainingSeconds,matched,total,finished,resultsExtra,error);

@override
String toString() {
  return 'WordMatchPlayState(status: $status, deckId: $deckId, deck: $deck, remainingSeconds: $remainingSeconds, matched: $matched, total: $total, finished: $finished, resultsExtra: $resultsExtra, error: $error)';
}


}

/// @nodoc
abstract mixin class _$WordMatchPlayStateCopyWith<$Res> implements $WordMatchPlayStateCopyWith<$Res> {
  factory _$WordMatchPlayStateCopyWith(_WordMatchPlayState value, $Res Function(_WordMatchPlayState) _then) = __$WordMatchPlayStateCopyWithImpl;
@override @useResult
$Res call({
 WordMatchPlayStatus status, String? deckId, WordMatchDeck? deck, int remainingSeconds, int matched, int total, bool finished, ResultsArgs? resultsExtra, String? error
});




}
/// @nodoc
class __$WordMatchPlayStateCopyWithImpl<$Res>
    implements _$WordMatchPlayStateCopyWith<$Res> {
  __$WordMatchPlayStateCopyWithImpl(this._self, this._then);

  final _WordMatchPlayState _self;
  final $Res Function(_WordMatchPlayState) _then;

/// Create a copy of WordMatchPlayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? deckId = freezed,Object? deck = freezed,Object? remainingSeconds = null,Object? matched = null,Object? total = null,Object? finished = null,Object? resultsExtra = freezed,Object? error = freezed,}) {
  return _then(_WordMatchPlayState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WordMatchPlayStatus,deckId: freezed == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String?,deck: freezed == deck ? _self.deck : deck // ignore: cast_nullable_to_non_nullable
as WordMatchDeck?,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,resultsExtra: freezed == resultsExtra ? _self.resultsExtra : resultsExtra // ignore: cast_nullable_to_non_nullable
as ResultsArgs?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
