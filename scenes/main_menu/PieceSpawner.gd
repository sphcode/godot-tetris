extends Node

var current_tetromino
var next_tetromino

@onready var board = $"../Board" as Board

func _ready():
	if !board.is_node_ready():
		await board.ready

	current_tetromino = Shared.Tetromino.values().pick_random()
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false)
	board.spawn_tetromino(next_tetromino, true)
	board.current_tetromino_locked.connect(on_tetromino_locked)

func on_tetromino_locked():
	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false)
	board.spawn_tetromino(next_tetromino, true)
