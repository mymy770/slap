extends Node2D

# Contrôleur de la gifle et animations

signal slap_completed(damage: float)

@onready var hand_sprite = $Hand
@onready var animation_player = $AnimationPlayer

var is_slapping: bool = false

func _ready():
	if hand_sprite:
		hand_sprite.visible = false

func perform_slap(power: float, accuracy: float):
	if is_slapping:
		return

	is_slapping = true

	# Calculer les dégâts selon puissance et précision
	var base_damage = 15.0
	var damage = base_damage * power * (0.5 + accuracy * 0.5)

	# Choisir l'animation selon la puissance
	var animation_name = "slap_weak"
	if power >= 0.8:
		animation_name = "slap_strong"
	elif power >= 0.5:
		animation_name = "slap_medium"

	# Jouer l'animation
	if animation_player and animation_player.has_animation(animation_name):
		hand_sprite.visible = true
		animation_player.play(animation_name)
		await animation_player.animation_finished
		hand_sprite.visible = false
	else:
		# Animation simple par défaut
		await perform_simple_slap_animation(power)

	# Appliquer les dégâts via AvatarManager
	AvatarManager.take_damage(damage)

	slap_completed.emit(damage)
	is_slapping = false

func perform_simple_slap_animation(power: float):
	if not hand_sprite:
		await get_tree().create_timer(0.5).timeout
		return

	hand_sprite.visible = true
	hand_sprite.position = Vector2(800, 300)
	hand_sprite.scale = Vector2(1, 1)

	# Animation de la main qui arrive
	var tween = create_tween()
	tween.set_parallel(true)

	var speed = 0.3 / power  # Plus rapide si plus de puissance
	speed = clamp(speed, 0.1, 0.5)

	# Déplacement
	tween.tween_property(hand_sprite, "position", Vector2(400, 300), speed)

	# Rotation pour effet réaliste
	tween.tween_property(hand_sprite, "rotation_degrees", -30, speed * 0.5)
	tween.tween_property(hand_sprite, "rotation_degrees", 0, speed * 0.5).set_delay(speed * 0.5)

	await tween.finished

	# Impact
	trigger_screen_shake(power)

	# Retour
	var tween_back = create_tween()
	tween_back.tween_property(hand_sprite, "position", Vector2(800, 300), 0.2)
	await tween_back.finished

	hand_sprite.visible = false

func trigger_screen_shake(intensity: float):
	# Vibration pour retour haptique (mobile)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(int(100 * intensity))

	# Effet de shake de caméra
	var camera = get_viewport().get_camera_2d()
	if camera:
		var original_offset = camera.offset
		var shake_intensity = 20.0 * intensity

		var shake_tween = create_tween()
		shake_tween.tween_property(camera, "offset", original_offset + Vector2(shake_intensity, 0), 0.05)
		shake_tween.tween_property(camera, "offset", original_offset + Vector2(-shake_intensity, 0), 0.05)
		shake_tween.tween_property(camera, "offset", original_offset, 0.05)
