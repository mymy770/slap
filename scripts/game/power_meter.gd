extends Node2D

# Système de jauge de puissance (comme penalty FIFA)

signal power_locked(power_value: float, accuracy: float)

@export var min_speed: float = 200.0  # Vitesse minimale
@export var max_speed: float = 800.0  # Vitesse maximale
@export var speed_increase_rate: float = 50.0  # Augmentation de vitesse par niveau

var current_speed: float = min_speed
var is_active: bool = false
var cursor_position: float = 0.0
var direction: int = 1  # 1 pour droite, -1 pour gauche
var difficulty_level: int = 1

# Zones de précision
const PERFECT_ZONE_START = 0.45
const PERFECT_ZONE_END = 0.55
const GOOD_ZONE_START = 0.35
const GOOD_ZONE_END = 0.65
const OK_ZONE_START = 0.25
const OK_ZONE_END = 0.75

func _ready():
	set_process(false)

func start_meter(level: int = 1):
	difficulty_level = level
	current_speed = min_speed + (level - 1) * speed_increase_rate
	current_speed = clamp(current_speed, min_speed, max_speed)
	cursor_position = 0.0
	direction = 1
	is_active = true
	set_process(true)

func _process(delta):
	if not is_active:
		return

	# Déplacer le curseur
	cursor_position += direction * current_speed * delta

	# Rebondir aux extrémités
	if cursor_position >= 1.0:
		cursor_position = 1.0
		direction = -1
	elif cursor_position <= 0.0:
		cursor_position = 0.0
		direction = 1

	queue_redraw()

func stop_meter() -> Dictionary:
	if not is_active:
		return {"power": 0.0, "accuracy": 0.0, "zone": "miss"}

	is_active = false
	set_process(false)

	var result = calculate_result()
	power_locked.emit(result.power, result.accuracy)

	return result

func calculate_result() -> Dictionary:
	var power = cursor_position  # 0.0 à 1.0
	var accuracy = 0.0
	var zone = "miss"

	# Calculer la précision selon la zone
	if cursor_position >= PERFECT_ZONE_START and cursor_position <= PERFECT_ZONE_END:
		zone = "perfect"
		accuracy = 1.0
		# Bonus de puissance pour zone parfaite
		power = power * 1.2
	elif cursor_position >= GOOD_ZONE_START and cursor_position <= GOOD_ZONE_END:
		zone = "good"
		accuracy = 0.75
		power = power * 1.0
	elif cursor_position >= OK_ZONE_START and cursor_position <= OK_ZONE_END:
		zone = "ok"
		accuracy = 0.5
		power = power * 0.8
	else:
		zone = "miss"
		accuracy = 0.2
		power = power * 0.5

	return {
		"power": clamp(power, 0.0, 1.2),
		"accuracy": accuracy,
		"zone": zone,
		"position": cursor_position
	}

func _draw():
	if not is_active:
		return

	var bar_width = 800.0
	var bar_height = 60.0
	var start_pos = Vector2(140, 0)

	# Fond de la barre
	draw_rect(Rect2(start_pos, Vector2(bar_width, bar_height)), Color(0.2, 0.2, 0.2, 0.8))

	# Zones colorées
	# Zone parfaite (vert)
	var perfect_start = start_pos.x + (bar_width * PERFECT_ZONE_START)
	var perfect_width = bar_width * (PERFECT_ZONE_END - PERFECT_ZONE_START)
	draw_rect(Rect2(Vector2(perfect_start, start_pos.y), Vector2(perfect_width, bar_height)), Color(0.0, 1.0, 0.0, 0.5))

	# Zone bonne (orange)
	var good_start = start_pos.x + (bar_width * GOOD_ZONE_START)
	var good_width_left = bar_width * (PERFECT_ZONE_START - GOOD_ZONE_START)
	draw_rect(Rect2(Vector2(good_start, start_pos.y), Vector2(good_width_left, bar_height)), Color(1.0, 0.6, 0.0, 0.5))

	var good_start_right = start_pos.x + (bar_width * PERFECT_ZONE_END)
	var good_width_right = bar_width * (GOOD_ZONE_END - PERFECT_ZONE_END)
	draw_rect(Rect2(Vector2(good_start_right, start_pos.y), Vector2(good_width_right, bar_height)), Color(1.0, 0.6, 0.0, 0.5))

	# Zone OK (jaune)
	var ok_start = start_pos.x + (bar_width * OK_ZONE_START)
	var ok_width_left = bar_width * (GOOD_ZONE_START - OK_ZONE_START)
	draw_rect(Rect2(Vector2(ok_start, start_pos.y), Vector2(ok_width_left, bar_height)), Color(1.0, 1.0, 0.0, 0.3))

	var ok_start_right = start_pos.x + (bar_width * GOOD_ZONE_END)
	var ok_width_right = bar_width * (OK_ZONE_END - GOOD_ZONE_END)
	draw_rect(Rect2(Vector2(ok_start_right, start_pos.y), Vector2(ok_width_right, bar_height)), Color(1.0, 1.0, 0.0, 0.3))

	# Curseur
	var cursor_x = start_pos.x + (bar_width * cursor_position)
	draw_rect(Rect2(Vector2(cursor_x - 5, start_pos.y - 10), Vector2(10, bar_height + 20)), Color.WHITE)

	# Bordure
	draw_rect(Rect2(start_pos, Vector2(bar_width, bar_height)), Color.WHITE, false, 2.0)
