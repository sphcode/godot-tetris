extends Node

var current_tetromino
var next_tetromino

@onready var board = $"../Board" as Board
@onready var ui = $"../UI" as UI

var is_game_over = false

func _ready():
	if !board.is_node_ready():
		await board.ready
	if !ui.is_node_ready():
		await ui.ready

	board.current_tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
	current_tetromino = Shared.Tetromino.values().pick_random()
	next_tetromino = Shared.Tetromino.values().pick_random()
	var current_piece_spawned = await board.spawn_tetromino(current_tetromino, false)
	if !current_piece_spawned:
		return
	await board.spawn_tetromino(next_tetromino, true)

func on_tetromino_locked():
	if is_game_over:
		return

	current_tetromino = next_tetromino
	next_tetromino = Shared.Tetromino.values().pick_random()
	var current_piece_spawned = await board.spawn_tetromino(current_tetromino, false)
	if !current_piece_spawned:
		return
	await board.spawn_tetromino(next_tetromino, true)

func on_game_over():
	is_game_over = true
	ui.show_game_over()
