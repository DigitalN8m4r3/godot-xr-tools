tool
class_name XRToolsGrabPointHand
extends XRToolsGrabPoint


## XR Tools Grab Point Hand Script
##
## This script allows specifying a grab point for a specific hand. Additionally
## the grab point can be used to control the pose of the hand, and to allow the
## grab point position to be fine-tuned in the editor.


## Hand for this grab point
enum Hand {
	LEFT,	## Left hand
	RIGHT	## Right hand
}


## Which hand this grab point is for
export (Hand) var hand

## TODO: Open hand pose
export (Animation) var open_hand_pose : Animation

## TODO: Closed hand pose
export (Animation) var closed_hand_pos : Animation

## Scene to use for the hand in the editor
export var _editor_hand_scene : PackedScene

## If true, the hand is shown in the editor
export var _show_in_editor : bool = false setget _set_show_in_editor


## Hand model to use in the editor
var _editor_hand_model : XRToolsHand


## Called when the node enters the scene tree for the first time.
func _ready():
	# Load the hand if inside the editor
	if Engine.editor_hint:
		# Pick the hand scene
		var scene : PackedScene = _editor_hand_scene
		if not scene and hand == Hand.LEFT:
			scene = load("res://addons/godot-xr-tools/assets/left_hand.tscn")
		if not scene and hand == Hand.RIGHT:
			scene = load("res://addons/godot-xr-tools/assets/right_hand.tscn")

		# Load the hand model
		if scene:
			_editor_hand_model = scene.instance()
			_editor_hand_model.visible = _show_in_editor
			add_child(_editor_hand_model)


## Test if a grabber can grab by this grab-point
func can_grab(_grabber : Node) -> bool:
	# Skip if not enabled
	if not enabled:
		return false

	# Ensure the pickup is valid
	if not is_instance_valid(_grabber):
		return false

	# Ensure the pickup is a function pickup for a controller
	var pickup := _grabber as XRToolsFunctionPickup
	if not pickup:
		return false

	# Get the parent controller
	var controller := _grabber.get_parent() as ARVRController
	if not controller:
		return false

	# Only allow left controller to grab left-hand grab points
	if hand == Hand.LEFT and controller.controller_id != 1:
		return false

	# Only allow right controller to grab right-hand grab points
	if hand == Hand.RIGHT and controller.controller_id != 2:
		return false

	# Allow grab
	return true


## Handle setting the show in editor flag
func _set_show_in_editor(new_value : bool) -> void:
	# Set hand visibility
	_show_in_editor = new_value
	if _editor_hand_model:
		_editor_hand_model.visible = _show_in_editor
