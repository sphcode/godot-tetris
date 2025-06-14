extends Node2D

class_name Tetromino

var wall_kicks
var tetromino_data
var is_netx_piece
var pieces = []

@onready var piece_scene = preload("res://scenes/piece/Piece.tscn")
@onready var timer = $Timer

var tetromino_cells

func _ready():
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
		piece.set_texture(tetromino_data.piece_texture)

	if !is_netx_piece:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		


func _input(event):
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("hard_drop"):
		pass
	elif Input.is_action_just_pressed("rotate_left"):
		pass

func move(direction: Vector2):
	var new_position = calculate_global_position(direction, global_position)
	if new_position:
		global_position = new_position
		return true
	return false

func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	return starting_global_position + direction * pieces[0].get_size().x
	

func _on_timer_timeout() -> void:
	move(Vector2.DOWN)
