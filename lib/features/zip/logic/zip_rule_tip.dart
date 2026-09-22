/// Coaching tip when a Zip stroke ends without a valid win.
enum ZipRuleTip {
  /// Tried to start on a cell that is not number 1.
  startAtOne,

  /// Path ends on the last number but empty cells remain.
  fillEveryCell,

  /// Board is full (or nearly finished) but tip is not the last number.
  finishOnLast,

  /// Numbers were not visited in order 1…N.
  visitInOrder,
}
