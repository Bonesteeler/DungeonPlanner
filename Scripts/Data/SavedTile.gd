# TODO better name
class_name SavedTile
extends RefCounted

enum TileFillState {EMPTY, HOVERED, OCCUPIED_CHILD, OCCUPIED_ROOT}

var id = ""
var rotation: Vector3
var x = 0
var y = 0
var fillState = TileFillState.EMPTY

func setFillState(state: TileFillState):
  match state:
    TileFillState.EMPTY:
      fillState = TileFillState.EMPTY
    TileFillState.HOVERED:
      if fillState == TileFillState.EMPTY:
        fillState = TileFillState.HOVERED
    TileFillState.OCCUPIED_CHILD:
      if fillState == TileFillState.EMPTY || fillState == TileFillState.HOVERED:
        fillState = TileFillState.OCCUPIED_CHILD
    TileFillState.OCCUPIED_ROOT:
      if fillState == TileFillState.EMPTY || fillState == TileFillState.HOVERED:
        fillState = TileFillState.OCCUPIED_ROOT

func getFillState() -> TileFillState:
  return fillState
