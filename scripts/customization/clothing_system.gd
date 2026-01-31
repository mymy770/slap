extends Control

# Système de customisation des vêtements

signal customization_complete

@export var category: String = "top"  # top, bottom, shoes

var available_items = []
var current_selection: int = 0

func _ready():
	load_available_items()

func load_available_items():
	# Pour l'instant, créer des items de base
	# Plus tard on chargera depuis un fichier de configuration
	match category:
		"top":
			available_items = [
				{"name": "T-shirt", "color": Color.RED},
				{"name": "Hoodie", "color": Color.BLUE},
				{"name": "Tank Top", "color": Color.GREEN},
				{"name": "Jacket", "color": Color.BLACK},
				{"name": "Shirt", "color": Color.WHITE}
			]
		"bottom":
			available_items = [
				{"name": "Jeans", "color": Color.BLUE},
				{"name": "Shorts", "color": Color.GRAY},
				{"name": "Pants", "color": Color.BLACK},
				{"name": "Skirt", "color": Color.PURPLE}
			]
		"shoes":
			available_items = [
				{"name": "Sneakers", "color": Color.WHITE},
				{"name": "Boots", "color": Color.BROWN},
				{"name": "Sandals", "color": Color.TAN},
				{"name": "Dress Shoes", "color": Color.BLACK}
			]

func select_next():
	current_selection = (current_selection + 1) % available_items.size()
	apply_selection()

func select_previous():
	current_selection = (current_selection - 1 + available_items.size()) % available_items.size()
	apply_selection()

func apply_selection():
	var item = available_items[current_selection]
	AvatarManager.update_clothing(category, current_selection)

func change_color(new_color: Color):
	AvatarManager.update_color(category, new_color)

func get_current_item() -> Dictionary:
	if current_selection < available_items.size():
		return available_items[current_selection]
	return {}
