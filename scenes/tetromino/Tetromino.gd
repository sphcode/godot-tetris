extends Node2D

class_name Tetromino

var wall_kicks
var tetromino_data
var is_netx_piece
var pieces = []

@onready var piece_scene = preload("res://scenes/piece/Piece.tscn")

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
		
