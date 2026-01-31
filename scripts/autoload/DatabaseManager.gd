extends Node

# Singleton pour gérer la base de données SQLite

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db: SQLite
var db_path = "user://slap_game.db"

func _ready():
	initialize_database()

func initialize_database():
	db = SQLite.new()
	db.path = db_path
	db.open_db()

	create_tables()
	print("Base de données initialisée : ", db_path)

func create_tables():
	# Table des joueurs
	var query = """
	CREATE TABLE IF NOT EXISTS player (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		level INTEGER DEFAULT 1,
		experience INTEGER DEFAULT 0,
		total_slaps INTEGER DEFAULT 0,
		total_damage_dealt REAL DEFAULT 0,
		coins INTEGER DEFAULT 0,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		last_played TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	"""
	db.query(query)

	# Table des skins
	var query_skins = """
	CREATE TABLE IF NOT EXISTS skins (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE,
		type TEXT NOT NULL,
		rarity TEXT DEFAULT 'common',
		cost INTEGER DEFAULT 0,
		unlock_level INTEGER DEFAULT 1,
		description TEXT
	);
	"""
	db.query(query_skins)

	# Table des skins débloqués par le joueur
	var query_unlocked = """
	CREATE TABLE IF NOT EXISTS player_skins (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER NOT NULL,
		skin_id INTEGER NOT NULL,
		unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		is_equipped INTEGER DEFAULT 0,
		FOREIGN KEY (player_id) REFERENCES player(id),
		FOREIGN KEY (skin_id) REFERENCES skins(id),
		UNIQUE(player_id, skin_id)
	);
	"""
	db.query(query_unlocked)

	# Table des parties
	var query_games = """
	CREATE TABLE IF NOT EXISTS games (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER NOT NULL,
		score INTEGER DEFAULT 0,
		max_combo INTEGER DEFAULT 0,
		total_damage REAL DEFAULT 0,
		perfect_hits INTEGER DEFAULT 0,
		good_hits INTEGER DEFAULT 0,
		ok_hits INTEGER DEFAULT 0,
		miss_hits INTEGER DEFAULT 0,
		duration_seconds INTEGER DEFAULT 0,
		coins_earned INTEGER DEFAULT 0,
		experience_earned INTEGER DEFAULT 0,
		played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (player_id) REFERENCES player(id)
	);
	"""
	db.query(query_games)

	# Table des achievements
	var query_achievements = """
	CREATE TABLE IF NOT EXISTS achievements (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE,
		description TEXT,
		requirement_type TEXT NOT NULL,
		requirement_value INTEGER NOT NULL,
		reward_coins INTEGER DEFAULT 0,
		reward_experience INTEGER DEFAULT 0,
		icon TEXT
	);
	"""
	db.query(query_achievements)

	# Table des achievements débloqués
	var query_player_achievements = """
	CREATE TABLE IF NOT EXISTS player_achievements (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		player_id INTEGER NOT NULL,
		achievement_id INTEGER NOT NULL,
		unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (player_id) REFERENCES player(id),
		FOREIGN KEY (achievement_id) REFERENCES achievements(id),
		UNIQUE(player_id, achievement_id)
	);
	"""
	db.query(query_player_achievements)

	# Insérer des skins de base si la table est vide
	insert_default_skins()
	insert_default_achievements()

	# Créer un joueur par défaut si aucun n'existe
	create_default_player()

func insert_default_skins():
	var count = db.select_rows("skins", "", ["COUNT(*) as count"])
	if count.size() > 0 and count[0]["count"] == 0:
		# Skins de vêtements
		var default_skins = [
			# Hauts
			{"name": "T-shirt Basique", "type": "top", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Le classique"},
			{"name": "Hoodie Rouge", "type": "top", "rarity": "common", "cost": 50, "unlock_level": 2, "description": "Confortable et stylé"},
			{"name": "Veste en Cuir", "type": "top", "rarity": "rare", "cost": 200, "unlock_level": 5, "description": "Look badass"},
			{"name": "Armure Dorée", "type": "top", "rarity": "legendary", "cost": 1000, "unlock_level": 10, "description": "Pour les champions"},

			# Bas
			{"name": "Jean Basique", "type": "bottom", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Indémodable"},
			{"name": "Short Sport", "type": "bottom", "rarity": "common", "cost": 40, "unlock_level": 2, "description": "Pour l'agilité"},
			{"name": "Pantalon Cargo", "type": "bottom", "rarity": "rare", "cost": 180, "unlock_level": 5, "description": "Plein de poches"},

			# Chaussures
			{"name": "Sneakers Blanches", "type": "shoes", "rarity": "common", "cost": 0, "unlock_level": 1, "description": "Toujours propres"},
			{"name": "Bottes de Combat", "type": "shoes", "rarity": "rare", "cost": 150, "unlock_level": 4, "description": "Robustes"},

			# Accessoires
			{"name": "Casquette Noire", "type": "accessory", "rarity": "common", "cost": 30, "unlock_level": 1, "description": "Style urbain"},
			{"name": "Lunettes de Soleil", "type": "accessory", "rarity": "rare", "cost": 120, "unlock_level": 3, "description": "Trop cool"},
			{"name": "Couronne Royale", "type": "accessory", "rarity": "legendary", "cost": 800, "unlock_level": 8, "description": "Le roi du slap"}
		]

		for skin in default_skins:
			db.insert_row("skins", skin)

		print("Skins par défaut insérés")

func insert_default_achievements():
	var count = db.select_rows("achievements", "", ["COUNT(*) as count"])
	if count.size() > 0 and count[0]["count"] == 0:
		var default_achievements = [
			{"name": "Première Gifle", "description": "Donner votre première gifle", "requirement_type": "total_slaps", "requirement_value": 1, "reward_coins": 10, "reward_experience": 50},
			{"name": "Amateur", "description": "Donner 10 gifles", "requirement_type": "total_slaps", "requirement_value": 10, "reward_coins": 50, "reward_experience": 100},
			{"name": "Professionnel", "description": "Donner 100 gifles", "requirement_type": "total_slaps", "requirement_value": 100, "reward_coins": 200, "reward_experience": 500},
			{"name": "Maître du Slap", "description": "Donner 1000 gifles", "requirement_type": "total_slaps", "requirement_value": 1000, "reward_coins": 1000, "reward_experience": 2000},

			{"name": "Perfectionniste", "description": "10 coups parfaits", "requirement_type": "perfect_hits", "requirement_value": 10, "reward_coins": 100, "reward_experience": 200},
			{"name": "Précision Extrême", "description": "50 coups parfaits", "requirement_type": "perfect_hits", "requirement_value": 50, "reward_coins": 500, "reward_experience": 1000},

			{"name": "Destructeur", "description": "Infliger 1000 de dégâts", "requirement_type": "total_damage", "requirement_value": 1000, "reward_coins": 300, "reward_experience": 600},

			{"name": "Niveau 5", "description": "Atteindre le niveau 5", "requirement_type": "level", "requirement_value": 5, "reward_coins": 150, "reward_experience": 0},
			{"name": "Niveau 10", "description": "Atteindre le niveau 10", "requirement_type": "level", "requirement_value": 10, "reward_coins": 500, "reward_experience": 0}
		]

		for achievement in default_achievements:
			db.insert_row("achievements", achievement)

		print("Achievements par défaut insérés")

func create_default_player():
	var players = db.select_rows("player", "", ["*"])
	if players.size() == 0:
		var player_data = {
			"name": "Joueur",
			"level": 1,
			"experience": 0,
			"coins": 100  # Coins de départ
		}
		db.insert_row("player", player_data)

		# Débloquer les skins de base (gratuits)
		var player_id = db.select_rows("player", "", ["id"])[0]["id"]
		var free_skins = db.select_rows("skins", "cost = 0", ["id"])
		for skin in free_skins:
			db.insert_row("player_skins", {
				"player_id": player_id,
				"skin_id": skin["id"],
				"is_equipped": 0
			})

		print("Joueur par défaut créé avec skins de base")

# ===== FONCTIONS UTILITAIRES =====

func get_player() -> Dictionary:
	var players = db.select_rows("player", "", ["*"])
	if players.size() > 0:
		return players[0]
	return {}

func update_player(data: Dictionary):
	var player = get_player()
	if player.has("id"):
		db.update_rows("player", "id = " + str(player["id"]), data)
		print("Joueur mis à jour: ", data)

func add_experience(exp: int):
	var player = get_player()
	var new_exp = player["experience"] + exp
	var new_level = player["level"]

	# Système de level up (100 exp par niveau)
	var exp_for_next_level = new_level * 100
	while new_exp >= exp_for_next_level:
		new_exp -= exp_for_next_level
		new_level += 1
		exp_for_next_level = new_level * 100
		print("LEVEL UP ! Niveau ", new_level)

	update_player({
		"experience": new_exp,
		"level": new_level
	})

func add_coins(amount: int):
	var player = get_player()
	update_player({"coins": player["coins"] + amount})
	print("Coins gagnés: ", amount, " | Total: ", player["coins"] + amount)

func can_afford_skin(skin_id: int) -> bool:
	var player = get_player()
	var skin = db.select_rows("skins", "id = " + str(skin_id), ["cost"])[0]
	return player["coins"] >= skin["cost"]

func unlock_skin(skin_id: int) -> bool:
	if not can_afford_skin(skin_id):
		print("Pas assez de coins !")
		return false

	var player = get_player()
	var skin = db.select_rows("skins", "id = " + str(skin_id), ["cost"])[0]

	# Débloquer le skin
	db.insert_row("player_skins", {
		"player_id": player["id"],
		"skin_id": skin_id,
		"is_equipped": 0
	})

	# Retirer les coins
	update_player({"coins": player["coins"] - skin["cost"]})

	print("Skin débloqué !")
	return true

func get_unlocked_skins(type: String = "") -> Array:
	var player = get_player()
	var condition = "player_skins.player_id = " + str(player["id"])
	if type != "":
		condition += " AND skins.type = '" + type + "'"

	var query = """
	SELECT skins.*, player_skins.is_equipped
	FROM skins
	INNER JOIN player_skins ON skins.id = player_skins.skin_id
	WHERE """ + condition + """
	"""

	return db.query(query)

func save_game_stats(stats: Dictionary):
	var player = get_player()
	stats["player_id"] = player["id"]

	db.insert_row("games", stats)
	print("Statistiques de partie sauvegardées")

	# Vérifier les achievements
	check_achievements()

func check_achievements():
	var player = get_player()
	var achievements = db.select_rows("achievements", "", ["*"])

	for achievement in achievements:
		# Vérifier si déjà débloqué
		var unlocked = db.select_rows(
			"player_achievements",
			"player_id = " + str(player["id"]) + " AND achievement_id = " + str(achievement["id"]),
			["*"]
		)

		if unlocked.size() > 0:
			continue  # Déjà débloqué

		# Vérifier les conditions
		var requirement_met = false
		match achievement["requirement_type"]:
			"total_slaps":
				requirement_met = player["total_slaps"] >= achievement["requirement_value"]
			"perfect_hits":
				var games = db.select_rows("games", "player_id = " + str(player["id"]), ["SUM(perfect_hits) as total"])
				if games.size() > 0:
					requirement_met = games[0]["total"] >= achievement["requirement_value"]
			"total_damage":
				requirement_met = player["total_damage_dealt"] >= achievement["requirement_value"]
			"level":
				requirement_met = player["level"] >= achievement["requirement_value"]

		if requirement_met:
			# Débloquer l'achievement
			db.insert_row("player_achievements", {
				"player_id": player["id"],
				"achievement_id": achievement["id"]
			})

			# Récompenses
			add_coins(achievement["reward_coins"])
			add_experience(achievement["reward_experience"])

			print("🏆 Achievement débloqué: ", achievement["name"])
