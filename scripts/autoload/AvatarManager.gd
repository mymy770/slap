extends Node

# Singleton qui gère l'avatar et sa customisation

signal avatar_updated
signal health_changed(new_health: float)
signal avatar_ko

# Structure de l'avatar
var avatar_data = {
	"face_texture": null,  # Texture du visage (photo ou généré)
	"clothing": {
		"top": 0,
		"bottom": 0,
		"shoes": 0
	},
	"accessories": [],
	"colors": {
		"top": Color.WHITE,
		"bottom": Color.WHITE,
		"shoes": Color.WHITE
	}
}

# Système de santé
var max_health: float = 100.0
var current_health: float = 100.0

# Niveaux de dégâts visuels
enum DamageLevel {
	PRISTINE,    # 100-80%
	LIGHT,       # 80-60%
	MODERATE,    # 60-40%
	HEAVY,       # 40-20%
	CRITICAL,    # 20-0%
	KO           # 0%
}

func _ready():
	reset_health()

func reset_health():
	current_health = max_health
	health_changed.emit(current_health)

func take_damage(damage: float):
	current_health = max(0, current_health - damage)
	health_changed.emit(current_health)

	if current_health <= 0:
		avatar_ko.emit()

func get_damage_level() -> DamageLevel:
	var health_percent = (current_health / max_health) * 100

	if health_percent == 0:
		return DamageLevel.KO
	elif health_percent <= 20:
		return DamageLevel.CRITICAL
	elif health_percent <= 40:
		return DamageLevel.HEAVY
	elif health_percent <= 60:
		return DamageLevel.MODERATE
	elif health_percent <= 80:
		return DamageLevel.LIGHT
	else:
		return DamageLevel.PRISTINE

func update_clothing(slot: String, index: int):
	if avatar_data.clothing.has(slot):
		avatar_data.clothing[slot] = index
		avatar_updated.emit()

func update_color(slot: String, color: Color):
	if avatar_data.colors.has(slot):
		avatar_data.colors[slot] = color
		avatar_updated.emit()

func add_accessory(accessory_id: int):
	if not avatar_data.accessories.has(accessory_id):
		avatar_data.accessories.append(accessory_id)
		avatar_updated.emit()

func remove_accessory(accessory_id: int):
	avatar_data.accessories.erase(accessory_id)
	avatar_updated.emit()

func set_face_texture(texture: Texture2D):
	avatar_data.face_texture = texture
	avatar_updated.emit()

func save_avatar():
	var file = FileAccess.open("user://avatar.save", FileAccess.WRITE)
	file.store_var(avatar_data)
	file.close()

func load_avatar():
	if FileAccess.file_exists("user://avatar.save"):
		var file = FileAccess.open("user://avatar.save", FileAccess.READ)
		avatar_data = file.get_var()
		file.close()
		avatar_updated.emit()
