extends Control

# Script principal de la scène de jeu

@onready var power_meter = $PowerMeter
@onready var slap_controller = $SlapController
@onready var slap_button = $UI/BottomPanel/SlapButton
@onready var status_label = $UI/BottomPanel/StatusLabel
@onready var health_bar = $UI/TopBar/HealthBar
@onready var health_value = $UI/TopBar/HealthValue
@onready var avatar_placeholder = $AvatarPlaceholder

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

	update_health_display()

func _on_slap_button_pressed():
	if not is_meter_active:
		# Démarrer la jauge
		start_power_meter()
	else:
		# Arrêter la jauge et calculer le résultat
		stop_power_meter()

func start_power_meter():
	is_meter_active = true
	slap_button.text = "STOP ! ⏸️"
	status_label.text = "Cliquez au bon moment !"
	power_meter.start_meter(difficulty_level)

func stop_power_meter():
	is_meter_active = false
	slap_button.disabled = true
	var result = power_meter.stop_meter()

	# Afficher le résultat
	var zone_text = ""
	match result.zone:
		"perfect":
			zone_text = "PARFAIT ! 🎯"
			status_label.add_theme_color_override("font_color", Color.GREEN)
		"good":
			zone_text = "BIEN ! 👍"
			status_label.add_theme_color_override("font_color", Color.ORANGE)
		"ok":
			zone_text = "OK 👌"
			status_label.add_theme_color_override("font_color", Color.YELLOW)
		_:
			zone_text = "RATÉ ! 😅"
			status_label.add_theme_color_override("font_color", Color.RED)

	status_label.text = zone_text

	# Exécuter la gifle
	slap_controller.perform_slap(result.power, result.accuracy)

func _on_power_locked(power: float, accuracy: float):
	print("Puissance: ", power, " Précision: ", accuracy)

func _on_slap_completed(damage: float):
	print("Dégâts infligés: ", damage)

	# Augmenter la difficulté tous les 3 coups
	GameManager.add_score(1)
	if GameManager.score % 3 == 0:
		difficulty_level += 1
		status_label.text = "Niveau " + str(difficulty_level) + " !"

	# Réinitialiser le bouton après 1 seconde
	await get_tree().create_timer(1.5).timeout

	if AvatarManager.current_health > 0:
		slap_button.disabled = false
		slap_button.text = "GIFLE ! 👋"
		status_label.text = "Prêt pour le prochain coup"
		status_label.add_theme_color_override("font_color", Color.WHITE)

func _on_health_changed(new_health: float):
	update_health_display()

	# Animation du placeholder avatar selon les dégâts
	var damage_level = AvatarManager.get_damage_level()
	match damage_level:
		AvatarManager.DamageLevel.PRISTINE:
			avatar_placeholder.color = Color(0.8, 0.7, 0.6, 1)
		AvatarManager.DamageLevel.LIGHT:
			avatar_placeholder.color = Color(0.9, 0.6, 0.5, 1)
		AvatarManager.DamageLevel.MODERATE:
			avatar_placeholder.color = Color(0.9, 0.5, 0.4, 1)
		AvatarManager.DamageLevel.HEAVY:
			avatar_placeholder.color = Color(0.9, 0.4, 0.3, 1)
		AvatarManager.DamageLevel.CRITICAL:
			avatar_placeholder.color = Color(0.8, 0.3, 0.2, 1)

func update_health_display():
	health_bar.value = AvatarManager.current_health
	health_value.text = str(int(AvatarManager.current_health))

	# Changer la couleur de la barre selon la santé
	var health_percent = AvatarManager.current_health / AvatarManager.max_health
	if health_percent > 0.6:
		health_bar.modulate = Color.GREEN
	elif health_percent > 0.3:
		health_bar.modulate = Color.ORANGE
	else:
		health_bar.modulate = Color.RED

func _on_avatar_ko():
	print("KO ! Game Over")
	status_label.text = "K.O. ! 💫"
	status_label.add_theme_color_override("font_color", Color.RED)
	slap_button.disabled = true
	slap_button.text = "GAME OVER"

	GameManager.change_state(GameManager.GameState.GAME_OVER)

	# Afficher le score
	await get_tree().create_timer(2.0).timeout
	status_label.text = "Score: " + str(GameManager.score) + " coups"

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
