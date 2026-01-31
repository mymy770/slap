extends Node

# Singleton qui gère l'état global du jeu

signal game_started
signal game_paused
signal game_over(final_score: int)

enum GameState {
	MENU,
	CUSTOMIZATION,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var score: int = 0
var high_score: int = 0

func _ready():
	load_high_score()

func change_state(new_state: GameState):
	current_state = new_state
	match new_state:
		GameState.PLAYING:
			game_started.emit()
		GameState.GAME_OVER:
			if score > high_score:
				high_score = score
				save_high_score()
			game_over.emit(score)

func reset_game():
	score = 0

func add_score(points: int):
	score += points

func load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		high_score = file.get_32()
		file.close()

func save_high_score():
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	file.store_32(high_score)
	file.close()
