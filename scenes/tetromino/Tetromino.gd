extends Node2D

class_name Tetromino

signal tetromino_locked(tetromino: Tetromino)

var bounds = {
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
}

var rotation_index = 0
var wall_kicks
var tetromino_data
var is_netx_piece
var pieces = []
var other_tetrominos: Array[Tetromino] = []

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
		hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)

func move(direction: Vector2):
	var new_position = calculate_global_position(direction, global_position)
	if new_position:
		global_position = new_position
		return true
	return false

func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	if is_colliding_with_other_tetrominos(direction, starting_global_position):
		return null
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x

func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2):
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true

func is_colliding_with_other_tetrominos(direction: Vector2, starting_global_position: Vector2):
	for tetromino in other_tetrominos:
		var tetromino_pieces = tetromino.pieces
		for tetromino_piece in tetromino_pieces:
			for piece in pieces:
				if starting_global_position + piece.position + direction * piece.get_size().x == tetromino.global_position + tetromino_piece.position:
					return true
	return false

func hard_drop():
	while (move(Vector2.DOWN)):
		continue
	lock()

func rotate_tetromino(direction: int):
	var original_rotation_index = rotation_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return

	apply_rotation(direction)
	
	rotation_index = wrap(rotation_index + direction, 0, 4)

func apply_rotation(direction: int):
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix

	var tetromino_cells = Shared.cells[tetromino_data.tetromino_type]

	for i in tetromino_cells.size():
		var cell = tetromino_cells[i]
		var coordindates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tetromino_cells[i] = coordindates

	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()

func lock():
	timer.stop()
	tetromino_locked.emit(self)
	set_process_input(false)

func _on_timer_timeout() -> void:
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()
