extends Node

class_name Board

signal current_tetromino_locked

const ROW_COUNT = 20
const COLUMN_COUNT = 10
const NEXT_PIECE_SCALE = Vector2(0.5, 0.5)
const NEXT_PIECE_GAP = 12.0

var tetrominos: Array[Tetromino] = []
var next_tetromino

@onready var panel_container = $"../PanelContainer"
@onready var next_piece_label = $"../PanelContainer/Label"
@export var tetromino_scene: PackedScene

func spawn_tetromino(type: Shared.Tetromino, is_next_piece):
	var tetromino_data = Shared.data[type]
	var tetromino: Tetromino = tetromino_scene.instantiate() as Tetromino

	tetromino.tetromino_data = tetromino_data
	tetromino.is_netx_piece = is_next_piece

	if !is_next_piece:
		tetromino.position = tetromino_data.spawn_position
		tetromino.other_tetrominos = tetrominos
		tetromino.tetromino_locked.connect(on_tetromino_locked)
		add_child(tetromino)
	else:
		tetromino.scale = NEXT_PIECE_SCALE
		panel_container.add_child(tetromino)
		next_tetromino = tetromino
		if !tetromino.is_node_ready():
			await tetromino.ready
		center_next_tetromino_below_label(tetromino)

func center_next_tetromino_below_label(tetromino: Tetromino):
	var first_piece = tetromino.pieces[0]
	var half_piece_size = first_piece.get_size() / 2.0
	var min_position = first_piece.position - half_piece_size
	var max_position = first_piece.position + half_piece_size

	for piece in tetromino.pieces:
		min_position = min_position.min(piece.position - half_piece_size)
		max_position = max_position.max(piece.position + half_piece_size)

	var tetromino_center = (min_position + max_position) / 2.0
	var label_center_x = next_piece_label.position.x + next_piece_label.size.x / 2.0
	var preview_top = next_piece_label.position.y + next_piece_label.size.y + NEXT_PIECE_GAP

	tetromino.position = Vector2(
		label_center_x - tetromino_center.x * tetromino.scale.x,
		preview_top - min_position.y * tetromino.scale.y
	)

func on_tetromino_locked(tetromino: Tetromino):
	next_tetromino.queue_free()
	tetrominos.append(tetromino)
	current_tetromino_locked.emit()
	clear_lines()

func clear_lines():
	var board_pieces = fill_board_pieces()
	clear_board_pieces(board_pieces)

func fill_board_pieces():
	var board_pieces = []

	for i in ROW_COUNT:
		board_pieces.append([])

	for tetromino in tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in tetromino_pieces:
			var row = (piece.global_position.y + piece.get_size().y / 2) / piece.get_size().y + ROW_COUNT / 2
			board_pieces[row - 1].append(piece)
	return board_pieces

func clear_board_pieces(board_pieces):
	var i = ROW_COUNT - 1
	while i >= 0:
		var row_to_analyze = board_pieces[i]
		if row_to_analyze.size():
			print(row_to_analyze.size())
		if row_to_analyze.size() == COLUMN_COUNT:
			clear_row(row_to_analyze)
			board_pieces[i].clear()
			move_all_row_pieces_down(board_pieces, i)
			continue
		i -= 1

func clear_row(row):
	for piece in row:
		piece.queue_free()

func move_all_row_pieces_down(board_pieces, cleared_row_number):
	for i in range(cleared_row_number - 1, -1, -1):
		var row_to_move = board_pieces[i]

		for piece in row_to_move:
			piece.position.y += piece.get_size().y
			board_pieces[i + 1].append(piece)

		row_to_move.clear()
