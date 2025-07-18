class_name Room extends Node2D

@export var palette: Texture2D

@export var limits_enabled = true
@export var limit_top = 0
@export var limit_left = 0
@export var limit_bottom = 240
@export var limit_right = 320

var camera: Camera
var player: Player

func _enter_tree() -> void:
	RoomManager.current_room = self
	# Engine.time_scale = 1.0
