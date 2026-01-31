extends Control

# Système de jauge de puissance avec UI visuelle

signal power_locked(power_value: float, accuracy: float)

@export var min_speed: float = 0.3  # Vitesse minimale (0-1 par seconde)
@export var max_speed: float = 1.5  # Vitesse maximale
@export var speed_increase_rate: float = 0.1  # Augmentation par niveau

@onready var cursor = $MeterBar/Cursor
@onready var meter_bar = $MeterBar

var current_speed: float = min_speed
var is_active: bool = false
var cursor_position: float = 0.0  # Position 0.0 à 1.0
var direction: int = 1  # 1 pour droite, -1 pour gauche
var difficulty_level: int = 1

# Zones de précision (en pourcentage 0-1)
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
	update_cursor_visual()

func _process(delta):
	if not is_active:
		return

	# Déplacer le curseur (0.0 à 1.0)
	cursor_position += direction * current_speed * delta

	# Rebondir aux extrémités
	if cursor_position >= 1.0:
		cursor_position = 1.0
		direction = -1
	elif cursor_position <= 0.0:
		cursor_position = 0.0
		direction = 1

	update_cursor_visual()

func update_cursor_visual():
	if not cursor or not meter_bar:
		return

	# Largeur totale de la barre (700 pixels)
	var bar_width = 700.0
	var cursor_x = cursor_position * bar_width

	# Positionner le curseur
	cursor.position.x = cursor_x

func stop_meter() -> Dictionary:
	is_active = false
	set_process(false)

	# Calculer la zone et la précision
	var zone = get_zone(cursor_position)
	var accuracy = get_accuracy(cursor_position)
	var power = cursor_position  # La puissance est la position du curseur

	power_locked.emit(power, accuracy)

	return {
		"power": power,
		"accuracy": accuracy,
		"zone": zone
	}

func get_zone(position: float) -> String:
	if position >= PERFECT_ZONE_START and position <= PERFECT_ZONE_END:
		return "perfect"
	elif position >= GOOD_ZONE_START and position <= GOOD_ZONE_END:
		return "good"
	elif position >= OK_ZONE_START and position <= OK_ZONE_END:
		return "ok"
	else:
		return "miss"

func get_accuracy(position: float) -> float:
	# Calculer la précision (1.0 = parfait, 0.0 = raté)
	var center = 0.5
	var distance_from_center = abs(position - center)

	if distance_from_center <= 0.05:  # Zone parfaite
		return 1.0
	elif distance_from_center <= 0.15:  # Zone bonne
		return 0.7
	elif distance_from_center <= 0.25:  # Zone OK
		return 0.4
	else:  # Raté
		return 0.1
