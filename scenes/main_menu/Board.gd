extends Node

class_name Board

@export var tetromino_scene: PackedScene

func spawn_tetromino(type: Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	
	tetromino.tetromino_data = tetromino_data
	tetromino.is_netx_piece = is_next_piece
	
	if !is_next_piece:
		tetromino.position = tetromino_data.spawn_position
		add_child(tetromino)
