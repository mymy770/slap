extends Node2D

# Système de rendu de l'avatar avec layers et dégâts

@onready var face_layer = $Layers/Face
@onready var body_layer = $Layers/Body
@onready var clothing_top_layer = $Layers/ClothingTop
@onready var clothing_bottom_layer = $Layers/ClothingBottom
@onready var shoes_layer = $Layers/Shoes
@onready var accessories_layer = $Layers/Accessories
@onready var damage_overlay = $Layers/DamageOverlay

var damage_textures = {}

func _ready():
	AvatarManager.avatar_updated.connect(_on_avatar_updated)
	AvatarManager.health_changed.connect(_on_health_changed)

	load_damage_textures()
	_on_avatar_updated()

func load_damage_textures():
	# Charger les textures de dégâts si elles existent
	# Pour l'instant on va créer des overlays procéduraux
	pass

func _on_avatar_updated():
	update_avatar_display()

func update_avatar_display():
	# Mettre à jour le visage
	if AvatarManager.avatar_data.face_texture:
		if face_layer is Sprite2D:
			face_layer.texture = AvatarManager.avatar_data.face_texture

	# Mettre à jour les vêtements
	# Pour l'instant on va utiliser des couleurs simples
	if clothing_top_layer is Sprite2D:
		clothing_top_layer.modulate = AvatarManager.avatar_data.colors.top

	if clothing_bottom_layer is Sprite2D:
		clothing_bottom_layer.modulate = AvatarManager.avatar_data.colors.bottom

	if shoes_layer is Sprite2D:
		shoes_layer.modulate = AvatarManager.avatar_data.colors.shoes

func _on_health_changed(new_health: float):
	update_damage_display()

func update_damage_display():
	var damage_level = AvatarManager.get_damage_level()

	# Mettre à jour l'overlay de dégâts
	if damage_overlay:
		match damage_level:
			AvatarManager.DamageLevel.PRISTINE:
				damage_overlay.modulate = Color(1, 1, 1, 0)
			AvatarManager.DamageLevel.LIGHT:
				damage_overlay.modulate = Color(1, 0.9, 0.9, 0.2)
			AvatarManager.DamageLevel.MODERATE:
				damage_overlay.modulate = Color(1, 0.7, 0.7, 0.4)
			AvatarManager.DamageLevel.HEAVY:
				damage_overlay.modulate = Color(1, 0.5, 0.5, 0.6)
			AvatarManager.DamageLevel.CRITICAL:
				damage_overlay.modulate = Color(1, 0.3, 0.3, 0.8)
			AvatarManager.DamageLevel.KO:
				damage_overlay.modulate = Color(0.5, 0, 0, 0.9)
				play_ko_animation()

func play_ko_animation():
	# Animation de KO
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 90, 0.5)
	tween.tween_property(self, "position:y", position.y + 200, 0.5)
	tween.tween_property(self, "modulate:a", 0.5, 0.3)

func reset_position():
	rotation_degrees = 0
	modulate.a = 1.0
