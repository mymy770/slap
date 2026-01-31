extends Node

# Système de progression avec sauvegarde JSON (natif Godot)

signal level_up(new_level: int)
signal coins_changed(new_amount: int)
signal skin_unlocked(skin_data: Dictionary)
signal achievement_unlocked(achievement_data: Dictionary)

var save_path = "user://progression.save"

# Données du joueur
var player_data = {
	"name": "Joueur",
	"level": 1,
	"experience": 0,
	"coins": 100,
	"total_slaps": 0,
	"total_damage_dealt": 0.0,
	"games_played": 0,
	"created_at": "",
	"last_played": ""
}

# Skins disponibles et débloqués
var all_skins = []
var unlocked_skins = []
var equipped_skins = {
	"top": 0,
	"bottom": 0,
	"shoes": 0,
	"accessory": -1
}

# Achievements
var all_achievements = []
var unlocked_achievements = []

# Statistiques de jeu
var game_history = []

func _ready():
	initialize_content()
	load_progression()

func initialize_content():
	# Définir tous les skins
	all_skins = [
		# Hauts (tops)
		{"id": 0, "name": "T-shirt Basique", "type": "top", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Le classique", "color": Color.WHITE},
		{"id": 1, "name": "Hoodie Rouge", "type": "top", "rarity": "common", "cost": 50, "unlock_level": 2, "description": "Confortable et stylé", "color": Color.RED},
		{"id": 2, "name": "T-shirt Bleu", "type": "top", "rarity": "common", "cost": 50, "unlock_level": 2, "description": "Fraîcheur garantie", "color": Color.BLUE},
		{"id": 3, "name": "Veste Verte", "type": "top", "rarity": "rare", "cost": 150, "unlock_level": 4, "description": "Style militaire", "color": Color.GREEN},
		{"id": 4, "name": "Veste en Cuir", "type": "top", "rarity": "rare", "cost": 200, "unlock_level": 5, "description": "Look badass", "color": Color(0.2, 0.1, 0.0)},
		{"id": 5, "name": "Chemise Dorée", "type": "top", "rarity": "epic", "cost": 500, "unlock_level": 7, "description": "Brillant de mille feux", "color": Color.GOLD},
		{"id": 6, "name": "Armure Légendaire", "type": "top", "rarity": "legendary", "cost": 1000, "unlock_level": 10, "description": "Pour les champions", "color": Color(0.8, 0.5, 1.0)},

		# Bas (bottoms)
		{"id": 7, "name": "Jean Basique", "type": "bottom", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Indémodable", "color": Color(0.3, 0.4, 0.8)},
		{"id": 8, "name": "Short Sport", "type": "bottom", "rarity": "common", "cost": 40, "unlock_level": 2, "description": "Pour l'agilité", "color": Color.BLACK},
		{"id": 9, "name": "Pantalon Cargo", "type": "bottom", "rarity": "rare", "cost": 180, "unlock_level": 5, "description": "Plein de poches", "color": Color(0.4, 0.5, 0.3)},
		{"id": 10, "name": "Jogging Violet", "type": "bottom", "rarity": "epic", "cost": 400, "unlock_level": 6, "description": "Confort ultime", "color": Color.PURPLE},

		# Chaussures (shoes)
		{"id": 11, "name": "Sneakers Blanches", "type": "shoes", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Toujours propres", "color": Color.WHITE},
		{"id": 12, "name": "Baskets Rouges", "type": "shoes", "rarity": "common", "cost": 45, "unlock_level": 2, "description": "Vitesse +10", "color": Color.RED},
		{"id": 13, "name": "Bottes de Combat", "type": "shoes", "rarity": "rare", "cost": 150, "unlock_level": 4, "description": "Robustes", "color": Color(0.2, 0.15, 0.1)},
		{"id": 14, "name": "Chaussures Dorées", "type": "shoes", "rarity": "legendary", "cost": 800, "unlock_level": 8, "description": "Marcher sur l'or", "color": Color.GOLD},

		# Accessoires (accessory)
		{"id": 15, "name": "Casquette Noire", "type": "accessory", "rarity": "common", "cost": 30, "unlock_level": 1, "description": "Style urbain", "color": Color.BLACK},
		{"id": 16, "name": "Lunettes de Soleil", "type": "accessory", "rarity": "rare", "cost": 120, "unlock_level": 3, "description": "Trop cool", "color": Color(0.2, 0.2, 0.2)},
		{"id": 17, "name": "Bandeau Rouge", "type": "accessory", "rarity": "rare", "cost": 100, "unlock_level": 3, "description": "Esprit guerrier", "color": Color.RED},
		{"id": 18, "name": "Couronne Royale", "type": "accessory", "rarity": "legendary", "cost": 800, "unlock_level": 8, "description": "Le roi du slap", "color": Color.GOLD}
	]

	# Définir tous les achievements
	all_achievements = [
		{"id": 0, "name": "Première Gifle", "description": "Donner votre première gifle", "type": "total_slaps", "value": 1, "reward_coins": 10, "reward_exp": 50, "icon": "🥊"},
		{"id": 1, "name": "Amateur", "description": "Donner 10 gifles", "type": "total_slaps", "value": 10, "reward_coins": 50, "reward_exp": 100, "icon": "👊"},
		{"id": 2, "name": "Professionnel", "description": "Donner 100 gifles", "type": "total_slaps", "value": 100, "reward_coins": 200, "reward_exp": 500, "icon": "💪"},
		{"id": 3, "name": "Maître du Slap", "description": "Donner 1000 gifles", "type": "total_slaps", "value": 1000, "reward_coins": 1000, "reward_exp": 2000, "icon": "👑"},

		{"id": 4, "name": "Perfectionniste", "description": "10 coups parfaits en une partie", "type": "perfect_hits_game", "value": 10, "reward_coins": 100, "reward_exp": 200, "icon": "🎯"},
		{"id": 5, "name": "Précision Extrême", "description": "20 coups parfaits en une partie", "type": "perfect_hits_game", "value": 20, "reward_coins": 300, "reward_exp": 500, "icon": "🎖️"},

		{"id": 6, "name": "Destructeur", "description": "Infliger 500 de dégâts total", "type": "total_damage", "value": 500, "reward_coins": 200, "reward_exp": 400, "icon": "💥"},
		{"id": 7, "name": "Annihilateur", "description": "Infliger 2000 de dégâts total", "type": "total_damage", "value": 2000, "reward_coins": 600, "reward_exp": 1000, "icon": "⚡"},

		{"id": 8, "name": "Niveau 5", "description": "Atteindre le niveau 5", "type": "level", "value": 5, "reward_coins": 150, "reward_exp": 0, "icon": "⭐"},
		{"id": 9, "name": "Niveau 10", "description": "Atteindre le niveau 10", "type": "level", "value": 10, "reward_coins": 500, "reward_exp": 0, "icon": "🌟"},
		{"id": 10, "name": "Niveau 20", "description": "Atteindre le niveau 20", "type": "level", "value": 20, "reward_coins": 1500, "reward_exp": 0, "icon": "✨"},

		{"id": 11, "name": "Marathonien", "description": "Jouer 50 parties", "type": "games_played", "value": 50, "reward_coins": 300, "reward_exp": 600, "icon": "🏃"},
		{"id": 12, "name": "Collectionneur", "description": "Débloquer 10 skins", "type": "skins_unlocked", "value": 10, "reward_coins": 500, "reward_exp": 1000, "icon": "👕"}
	]

func load_progression():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var data = json.get_data()
			player_data = data.get("player_data", player_data)
			unlocked_skins = data.get("unlocked_skins", [])
			equipped_skins = data.get("equipped_skins", equipped_skins)
			unlocked_achievements = data.get("unlocked_achievements", [])
			game_history = data.get("game_history", [])

			print("Progression chargée")
		else:
			print("Erreur de parsing JSON")
	else:
		# Première fois : débloquer les skins gratuits
		for skin in all_skins:
			if skin["cost"] == 0:
				unlocked_skins.append(skin["id"])

		player_data["created_at"] = Time.get_datetime_string_from_system()
		save_progression()
		print("Nouvelle progression créée")

	player_data["last_played"] = Time.get_datetime_string_from_system()

func save_progression():
	var data = {
		"player_data": player_data,
		"unlocked_skins": unlocked_skins,
		"equipped_skins": equipped_skins,
		"unlocked_achievements": unlocked_achievements,
		"game_history": game_history
	}

	var json_string = JSON.stringify(data, "\t")

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()

	print("Progression sauvegardée")

# ===== SYSTÈME D'EXPÉRIENCE ET LEVEL =====

func add_experience(exp: int):
	player_data["experience"] += exp

	# Level up (exp nécessaire augmente avec le niveau)
	var exp_needed = get_exp_for_next_level()

	while player_data["experience"] >= exp_needed:
		player_data["experience"] -= exp_needed
		player_data["level"] += 1
		exp_needed = get_exp_for_next_level()

		level_up.emit(player_data["level"])
		print("🎉 LEVEL UP ! Niveau ", player_data["level"])

		# Récompense de level up
		add_coins(player_data["level"] * 10)

		# Vérifier les achievements
		check_achievement_level()

	save_progression()

func get_exp_for_next_level() -> int:
	# Formule : 100 * level (augmente linéairement)
	return 100 * player_data["level"]

func get_level_progress() -> float:
	# Retourne un float entre 0.0 et 1.0
	var exp_needed = get_exp_for_next_level()
	return float(player_data["experience"]) / float(exp_needed)

# ===== SYSTÈME DE COINS =====

func add_coins(amount: int):
	player_data["coins"] += amount
	coins_changed.emit(player_data["coins"])
	save_progression()

func remove_coins(amount: int) -> bool:
	if player_data["coins"] >= amount:
		player_data["coins"] -= amount
		coins_changed.emit(player_data["coins"])
		save_progression()
		return true
	return false

func can_afford(cost: int) -> bool:
	return player_data["coins"] >= cost

# ===== SYSTÈME DE SKINS =====

func get_skin_by_id(id: int) -> Dictionary:
	for skin in all_skins:
		if skin["id"] == id:
			return skin
	return {}

func is_skin_unlocked(skin_id: int) -> bool:
	return unlocked_skins.has(skin_id)

func can_unlock_skin(skin_id: int) -> bool:
	var skin = get_skin_by_id(skin_id)
	return (not is_skin_unlocked(skin_id) and
			can_afford(skin["cost"]) and
			player_data["level"] >= skin["unlock_level"])

func unlock_skin(skin_id: int) -> bool:
	var skin = get_skin_by_id(skin_id)

	if not can_unlock_skin(skin_id):
		print("Impossible de débloquer ce skin")
		return false

	if remove_coins(skin["cost"]):
		unlocked_skins.append(skin_id)
		skin_unlocked.emit(skin)
		print("✨ Skin débloqué: ", skin["name"])
		check_achievement_skins()
		return true

	return false

func equip_skin(skin_id: int):
	if not is_skin_unlocked(skin_id):
		return

	var skin = get_skin_by_id(skin_id)
	equipped_skins[skin["type"]] = skin_id

	# Mettre à jour l'AvatarManager
	match skin["type"]:
		"top":
			AvatarManager.update_clothing("top", skin_id)
			AvatarManager.update_color("top", skin["color"])
		"bottom":
			AvatarManager.update_clothing("bottom", skin_id)
			AvatarManager.update_color("bottom", skin["color"])
		"shoes":
			AvatarManager.update_clothing("shoes", skin_id)
			AvatarManager.update_color("shoes", skin["color"])
		"accessory":
			if skin_id >= 0:
				AvatarManager.add_accessory(skin_id)

	save_progression()
	print("Skin équipé: ", skin["name"])

func get_skins_by_type(type: String) -> Array:
	var skins = []
	for skin in all_skins:
		if skin["type"] == type:
			skins.append(skin)
	return skins

# ===== SYSTÈME DE STATISTIQUES =====

func save_game_stats(stats: Dictionary):
	stats["timestamp"] = Time.get_datetime_string_from_system()
	game_history.append(stats)

	# Limiter l'historique à 100 parties
	if game_history.size() > 100:
		game_history.pop_front()

	# Mettre à jour les stats globales
	player_data["total_slaps"] += stats.get("total_hits", 0)
	player_data["total_damage_dealt"] += stats.get("total_damage", 0.0)
	player_data["games_played"] += 1

	# Calculer récompenses
	var coins_earned = stats.get("score", 0) * 2
	var exp_earned = stats.get("score", 0) * 10

	add_coins(coins_earned)
	add_experience(exp_earned)

	# Vérifier achievements
	check_achievements(stats)

	save_progression()

	print("Stats sauvegardées | Coins: +", coins_earned, " | Exp: +", exp_earned)

# ===== SYSTÈME D'ACHIEVEMENTS =====

func check_achievements(game_stats: Dictionary = {}):
	for achievement in all_achievements:
		if unlocked_achievements.has(achievement["id"]):
			continue

		var unlocked = false

		match achievement["type"]:
			"total_slaps":
				unlocked = player_data["total_slaps"] >= achievement["value"]
			"total_damage":
				unlocked = player_data["total_damage_dealt"] >= achievement["value"]
			"level":
				unlocked = player_data["level"] >= achievement["value"]
			"games_played":
				unlocked = player_data["games_played"] >= achievement["value"]
			"perfect_hits_game":
				if game_stats.has("perfect_hits"):
					unlocked = game_stats["perfect_hits"] >= achievement["value"]
			"skins_unlocked":
				unlocked = unlocked_skins.size() >= achievement["value"]

		if unlocked:
			unlock_achievement(achievement)

func check_achievement_level():
	for achievement in all_achievements:
		if achievement["type"] == "level" and not unlocked_achievements.has(achievement["id"]):
			if player_data["level"] >= achievement["value"]:
				unlock_achievement(achievement)

func check_achievement_skins():
	for achievement in all_achievements:
		if achievement["type"] == "skins_unlocked" and not unlocked_achievements.has(achievement["id"]):
			if unlocked_skins.size() >= achievement["value"]:
				unlock_achievement(achievement)

func unlock_achievement(achievement: Dictionary):
	unlocked_achievements.append(achievement["id"])
	achievement_unlocked.emit(achievement)

	# Récompenses
	add_coins(achievement["reward_coins"])
	if achievement["reward_exp"] > 0:
		add_experience(achievement["reward_exp"])

	save_progression()

	print("🏆 Achievement débloqué: ", achievement["name"],
		  " | +", achievement["reward_coins"], " coins",
		  " | +", achievement["reward_exp"], " exp")

func get_achievement_progress(achievement_id: int) -> float:
	var achievement = all_achievements[achievement_id]

	if unlocked_achievements.has(achievement_id):
		return 1.0

	match achievement["type"]:
		"total_slaps":
			return float(player_data["total_slaps"]) / float(achievement["value"])
		"total_damage":
			return float(player_data["total_damage_dealt"]) / float(achievement["value"])
		"level":
			return float(player_data["level"]) / float(achievement["value"])
		"games_played":
			return float(player_data["games_played"]) / float(achievement["value"])
		"skins_unlocked":
			return float(unlocked_skins.size()) / float(achievement["value"])

	return 0.0
