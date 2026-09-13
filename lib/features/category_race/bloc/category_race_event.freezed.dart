// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_race_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryRaceEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryRaceEvent()';
}


}

/// @nodoc
class $CategoryRaceEventCopyWith<$Res>  {
$CategoryRaceEventCopyWith(CategoryRaceEvent _, $Res Function(CategoryRaceEvent) __);
}


/// Adds pattern-matching-related methods to [CategoryRaceEvent].
extension CategoryRaceEventPatterns on CategoryRaceEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CategoryRaceFetchCategories value)?  fetchCategories,TResult Function( CategoryRaceStarted value)?  started,TResult Function( CategoryRaceTick value)?  tick,TResult Function( CategoryRaceAnswerSubmitted value)?  answerSubmitted,TResult Function( CategoryRaceFinishRequested value)?  finishRequested,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CategoryRaceFetchCategories() when fetchCategories != null:
return fetchCategories(_that);case CategoryRaceStarted() when started != null:
return started(_that);case CategoryRaceTick() when tick != null:
return tick(_that);case CategoryRaceAnswerSubmitted() when answerSubmitted != null:
return answerSubmitted(_that);case CategoryRaceFinishRequested() when finishRequested != null:
return finishRequested(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CategoryRaceFetchCategories value)  fetchCategories,required TResult Function( CategoryRaceStarted value)  started,required TResult Function( CategoryRaceTick value)  tick,required TResult Function( CategoryRaceAnswerSubmitted value)  answerSubmitted,required TResult Function( CategoryRaceFinishRequested value)  finishRequested,}){
final _that = this;
switch (_that) {
case CategoryRaceFetchCategories():
return fetchCategories(_that);case CategoryRaceStarted():
return started(_that);case CategoryRaceTick():
return tick(_that);case CategoryRaceAnswerSubmitted():
return answerSubmitted(_that);case CategoryRaceFinishRequested():
return finishRequested(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CategoryRaceFetchCategories value)?  fetchCategories,TResult? Function( CategoryRaceStarted value)?  started,TResult? Function( CategoryRaceTick value)?  tick,TResult? Function( CategoryRaceAnswerSubmitted value)?  answerSubmitted,TResult? Function( CategoryRaceFinishRequested value)?  finishRequested,}){
final _that = this;
switch (_that) {
case CategoryRaceFetchCategories() when fetchCategories != null:
return fetchCategories(_that);case CategoryRaceStarted() when started != null:
return started(_that);case CategoryRaceTick() when tick != null:
return tick(_that);case CategoryRaceAnswerSubmitted() when answerSubmitted != null:
return answerSubmitted(_that);case CategoryRaceFinishRequested() when finishRequested != null:
return finishRequested(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fetchCategories,TResult Function()?  started,TResult Function()?  tick,TResult Function( String raw)?  answerSubmitted,TResult Function()?  finishRequested,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CategoryRaceFetchCategories() when fetchCategories != null:
return fetchCategories();case CategoryRaceStarted() when started != null:
return started();case CategoryRaceTick() when tick != null:
return tick();case CategoryRaceAnswerSubmitted() when answerSubmitted != null:
return answerSubmitted(_that.raw);case CategoryRaceFinishRequested() when finishRequested != null:
return finishRequested();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fetchCategories,required TResult Function()  started,required TResult Function()  tick,required TResult Function( String raw)  answerSubmitted,required TResult Function()  finishRequested,}) {final _that = this;
switch (_that) {
case CategoryRaceFetchCategories():
return fetchCategories();case CategoryRaceStarted():
return started();case CategoryRaceTick():
return tick();case CategoryRaceAnswerSubmitted():
return answerSubmitted(_that.raw);case CategoryRaceFinishRequested():
return finishRequested();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fetchCategories,TResult? Function()?  started,TResult? Function()?  tick,TResult? Function( String raw)?  answerSubmitted,TResult? Function()?  finishRequested,}) {final _that = this;
switch (_that) {
case CategoryRaceFetchCategories() when fetchCategories != null:
return fetchCategories();case CategoryRaceStarted() when started != null:
return started();case CategoryRaceTick() when tick != null:
return tick();case CategoryRaceAnswerSubmitted() when answerSubmitted != null:
return answerSubmitted(_that.raw);case CategoryRaceFinishRequested() when finishRequested != null:
return finishRequested();case _:
  return null;

}
}

}

/// @nodoc


class CategoryRaceFetchCategories implements CategoryRaceEvent {
  const CategoryRaceFetchCategories();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceFetchCategories);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryRaceEvent.fetchCategories()';
}


}




/// @nodoc


class CategoryRaceStarted implements CategoryRaceEvent {
  const CategoryRaceStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryRaceEvent.started()';
}


}




/// @nodoc


class CategoryRaceTick implements CategoryRaceEvent {
  const CategoryRaceTick();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceTick);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryRaceEvent.tick()';
}


}




/// @nodoc


class CategoryRaceAnswerSubmitted implements CategoryRaceEvent {
  const CategoryRaceAnswerSubmitted(this.raw);
  

 final  String raw;

/// Create a copy of CategoryRaceEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryRaceAnswerSubmittedCopyWith<CategoryRaceAnswerSubmitted> get copyWith => _$CategoryRaceAnswerSubmittedCopyWithImpl<CategoryRaceAnswerSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceAnswerSubmitted&&(identical(other.raw, raw) || other.raw == raw));
}


@override
int get hashCode => Object.hash(runtimeType,raw);

@override
String toString() {
  return 'CategoryRaceEvent.answerSubmitted(raw: $raw)';
}


}

/// @nodoc
abstract mixin class $CategoryRaceAnswerSubmittedCopyWith<$Res> implements $CategoryRaceEventCopyWith<$Res> {
  factory $CategoryRaceAnswerSubmittedCopyWith(CategoryRaceAnswerSubmitted value, $Res Function(CategoryRaceAnswerSubmitted) _then) = _$CategoryRaceAnswerSubmittedCopyWithImpl;
@useResult
$Res call({
 String raw
});




}
/// @nodoc
class _$CategoryRaceAnswerSubmittedCopyWithImpl<$Res>
    implements $CategoryRaceAnswerSubmittedCopyWith<$Res> {
  _$CategoryRaceAnswerSubmittedCopyWithImpl(this._self, this._then);

  final CategoryRaceAnswerSubmitted _self;
  final $Res Function(CategoryRaceAnswerSubmitted) _then;

/// Create a copy of CategoryRaceEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? raw = null,}) {
  return _then(CategoryRaceAnswerSubmitted(
null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CategoryRaceFinishRequested implements CategoryRaceEvent {
  const CategoryRaceFinishRequested();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRaceFinishRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CategoryRaceEvent.finishRequested()';
}


}




// dart format on
