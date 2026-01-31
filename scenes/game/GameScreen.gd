extends Control

# Script principal de la scène de jeu

@onready var power_meter = $PowerMeterContainer/PowerMeter
@onready var slap_controller = $SlapController
@onready var slap_button = $PowerMeterContainer/SlapButton
@onready var health_bar = $UI/TopBar/MarginContainer/HBoxContainer/RightInfo/HealthBar
@onready var health_label = $UI/TopBar/MarginContainer/HBoxContainer/RightInfo/HealthLabel
@onready var score_label = $UI/TopBar/MarginContainer/HBoxContainer/LeftInfo/ScoreLabel
@onready var coins_label = $UI/TopBar/MarginContainer/HBoxContainer/LeftInfo/CoinsLabel
@onready var avatar_head = $AvatarContainer/AvatarHead/HeadColor
@onready var avatar_face = $AvatarContainer/AvatarHead/Face
@onready var avatar_body = $AvatarContainer/AvatarBody/ColorRect
@onready var damage_overlay = $AvatarContainer/DamageOverlay
@onready var feedback_label = $UI/FeedbackLabel
@onready var feedback_timer = $UI/FeedbackLabel/FeedbackTimer

var is_meter_active = false
var difficulty_level = 1

func _ready():
	print("GameScreen chargé !")
	GameManager.change_state(GameManager.GameState.PLAYING)
	GameManager.reset_game()
	AvatarManager.reset_health()

	# Connecter les signaux
	AvatarManager.health_changed.connect(_on_health_changed)
	AvatarManager.avatar_ko.connect(_on_avatar_ko)
	power_meter.power_locked.connect(_on_power_locked)
	slap_controller.slap_completed.connect(_on_slap_completed)
	feedback_timer.timeout.connect(_on_feedback_timeout)

	update_all_displays()
	feedback_label.text = ""

func _on_slap_button_pressed():
	if not is_meter_active:
		# Démarrer la jauge
		start_power_meter()
	else:
		# Arrêter la jauge et calculer le résultat
		stop_power_meter()

func start_power_meter():
	is_meter_active = true
	slap_button.text = "STOP"
	power_meter.start_meter(difficulty_level)

func stop_power_meter():
	is_meter_active = false
	slap_button.disabled = true
	var result = power_meter.stop_meter()

	# Afficher le feedback visuel
	show_feedback(result.zone, result.power)

	# Exécuter la gifle
	slap_controller.perform_slap(result.power, result.accuracy)

func show_feedback(zone: String, power: float):
	var feedback_text = ""
	var feedback_color = Color.WHITE

	match zone:
		"perfect":
			feedback_text = "🎯 PERFECT"
			feedback_color = Color(0, 1, 0)
		"good":
			feedback_text = "👍 GOOD"
			feedback_color = Color(1, 0.6, 0)
		"ok":
			feedback_text = "👌 OK"
			feedback_color = Color(1, 1, 0)
		_:
			feedback_text = "❌ MISS"
			feedback_color = Color(1, 0, 0)

	feedback_label.text = feedback_text
	feedback_label.add_theme_color_override("font_color", feedback_color)
	feedback_timer.start()

func _on_feedback_timeout():
	feedback_label.text = ""

func _on_power_locked(power: float, accuracy: float):
	print("Puissance: ", power, " Précision: ", accuracy)

func _on_slap_completed(damage: float):
	print("Dégâts infligés: ", damage)

	# Flash rouge sur l'avatar
	damage_overlay.visible = true
	await get_tree().create_timer(0.2).timeout
	damage_overlay.visible = false

	# Mettre à jour le score
	GameManager.add_score(10 * difficulty_level)
	update_score_display()

	# Augmenter la difficulté tous les 5 coups
	if GameManager.score % 50 == 0:
		difficulty_level += 1
		show_temporary_message("⭐ NIVEAU " + str(difficulty_level) + " !")

	# Réinitialiser le bouton après un délai
	await get_tree().create_timer(1.5).timeout

	if AvatarManager.current_health > 0:
		slap_button.disabled = false
		slap_button.text = "SLAP"
		is_meter_active = false

func show_temporary_message(message: String):
	feedback_label.text = message
	await get_tree().create_timer(2.0).timeout
	feedback_label.text = ""

func _on_health_changed(new_health: float):
	update_health_display()
	update_avatar_appearance()

func update_all_displays():
	update_health_display()
	update_score_display()
	update_avatar_appearance()

func update_health_display():
	health_bar.value = AvatarManager.current_health
	health_label.text = "❤️ " + str(int(AvatarManager.current_health))

	# Changer la couleur de la barre selon la santé
	var health_percent = AvatarManager.current_health / AvatarManager.max_health
	if health_percent > 0.6:
		health_bar.modulate = Color(0, 1, 0)
	elif health_percent > 0.3:
		health_bar.modulate = Color(1, 0.6, 0)
	else:
		health_bar.modulate = Color(1, 0, 0)

func update_score_display():
	score_label.text = "💯 Score: " + str(GameManager.score)
	coins_label.text = "💰 Pièces: " + str(ProgressionManager.player_data.coins)

func update_avatar_appearance():
	var damage_level = AvatarManager.get_damage_level()

	match damage_level:
		AvatarManager.DamageLevel.PRISTINE:
			avatar_face.text = "😐"
			avatar_head.color = Color(1, 0.85, 0.7, 1)
		AvatarManager.DamageLevel.LIGHT:
			avatar_face.text = "😕"
			avatar_head.color = Color(1, 0.75, 0.6, 1)
		AvatarManager.DamageLevel.MODERATE:
			avatar_face.text = "😣"
			avatar_head.color = Color(1, 0.65, 0.5, 1)
		AvatarManager.DamageLevel.HEAVY:
			avatar_face.text = "😖"
			avatar_head.color = Color(1, 0.55, 0.4, 1)
		AvatarManager.DamageLevel.CRITICAL:
			avatar_face.text = "😵"
			avatar_head.color = Color(1, 0.45, 0.3, 1)
		AvatarManager.DamageLevel.KO:
			avatar_face.text = "💫"
			avatar_head.color = Color(0.8, 0.3, 0.2, 1)

func _on_avatar_ko():
	print("KO ! Game Over")
	slap_button.disabled = true
	slap_button.text = "K.O."

	# Effet KO dramatique
	feedback_label.text = "💥 K.O."
	feedback_label.add_theme_color_override("font_color", Color.RED)

	GameManager.change_state(GameManager.GameState.GAME_OVER)

	# Sauvegarder les stats
	var game_stats = {
		"score": GameManager.score,
		"total_hits": GameManager.score / 10,
		"total_damage": AvatarManager.max_health,
		"coins_earned": GameManager.score / 10,
		"experience_earned": GameManager.score
	}
	ProgressionManager.save_game_stats(game_stats)

	# Sync Supabase
	if SupabaseManager.is_valid_config():
		SupabaseManager.sync_player_data()
		SupabaseManager.sync_game_stats(game_stats)

	# Afficher le score final
	await get_tree().create_timer(2.0).timeout
	feedback_label.text = "SCORE: " + str(GameManager.score)

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
