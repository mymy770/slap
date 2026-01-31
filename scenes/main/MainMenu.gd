extends Control

# Script du menu principal

func _ready():
	print("Slap Game - Menu Principal chargé !")
	GameManager.change_state(GameManager.GameState.MENU)

func _on_play_button_pressed():
	print("Bouton JOUER pressé")
	GameManager.change_state(GameManager.GameState.PLAYING)
	get_tree().change_scene_to_file("res://scenes/game/GameScreen.tscn")

func _on_customize_button_pressed():
	print("Bouton CUSTOMISER pressé")
	$MenuContainer/InfoLabel.text = "Scène de customisation à créer !"

	# Décommenter quand CustomizationScreen.tscn sera créé :
	# get_tree().change_scene_to_file("res://scenes/customization/CustomizationScreen.tscn")
