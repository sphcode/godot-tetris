extends Node

class_name Board

signal current_tetromino_locked

const ROW_COUNT = 20
const COLUMN_COUNT = 10

var tetrominos: Array[Tetromino] = []
@export var tetromino_scene: PackedScene

func spawn_tetromino(type: Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino: Tetromino = tetromino_scene.instantiate() as Tetromino

	tetromino.tetromino_data = tetromino_data
	tetromino.is_netx_piece = is_next_piece

	if !is_next_piece:
		tetromino.position = tetromino_data.spawn_position
		tetromino.other_tetrominos = tetrominos
		tetromino.tetromino_locked.connect(on_tetromino_locked)
		add_child(tetromino)

func on_tetromino_locked(tetromino: Tetromino):
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
