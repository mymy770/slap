extends Node

# Gestionnaire Supabase pour sync cloud

signal connection_status_changed(is_connected: bool)
signal sync_completed()
signal sync_failed(error: String)

# Configuration Supabase (À REMPLACER avec vos propres credentials)
var supabase_url = "https://YOUR_PROJECT.supabase.co"
var supabase_anon_key = "YOUR_ANON_KEY"

var http_request: HTTPRequest
var is_connected = false
var player_uuid = ""  # ID unique du joueur

func _ready():
	# Créer le HTTPRequest
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	# Générer ou charger UUID du joueur
	load_or_create_uuid()

func load_or_create_uuid():
	var uuid_path = "user://player_uuid.save"
	if FileAccess.file_exists(uuid_path):
		var file = FileAccess.open(uuid_path, FileAccess.READ)
		player_uuid = file.get_as_text()
		file.close()
	else:
		# Générer un UUID simple (timestamp + random)
		player_uuid = str(Time.get_unix_time_from_system()) + "_" + str(randi())
		var file = FileAccess.open(uuid_path, FileAccess.WRITE)
		file.store_string(player_uuid)
		file.close()

	print("Player UUID: ", player_uuid)

# ===== API CALLS =====

func sync_player_data():
	if not is_valid_config():
		print("Configuration Supabase manquante")
		return

	var player_data = ProgressionManager.player_data.duplicate()
	player_data["uuid"] = player_uuid
	player_data["last_synced"] = Time.get_datetime_string_from_system()

	# Upsert (insert or update)
	var endpoint = supabase_url + "/rest/v1/players"
	var headers = [
		"apikey: " + supabase_anon_key,
		"Authorization: Bearer " + supabase_anon_key,
		"Content-Type: application/json",
		"Prefer: resolution=merge-duplicates"
	]

	var body = JSON.stringify(player_data)

	http_request.request(endpoint, headers, HTTPClient.METHOD_POST, body)
	print("Syncing player data to Supabase...")

func fetch_player_data():
	if not is_valid_config():
		return

	var endpoint = supabase_url + "/rest/v1/players?uuid=eq." + player_uuid
	var headers = [
		"apikey: " + supabase_anon_key,
		"Authorization: Bearer " + supabase_anon_key
	]

	http_request.request(endpoint, headers, HTTPClient.METHOD_GET)
	print("Fetching player data from Supabase...")

func sync_game_stats(stats: Dictionary):
	if not is_valid_config():
		return

	var game_data = stats.duplicate()
	game_data["player_uuid"] = player_uuid
	game_data["synced_at"] = Time.get_datetime_string_from_system()

	var endpoint = supabase_url + "/rest/v1/games"
	var headers = [
		"apikey: " + supabase_anon_key,
		"Authorization: Bearer " + supabase_anon_key,
		"Content-Type: application/json"
	]

	var body = JSON.stringify(game_data)

	http_request.request(endpoint, headers, HTTPClient.METHOD_POST, body)
	print("Syncing game stats to Supabase...")

func fetch_leaderboard(limit: int = 10):
	if not is_valid_config():
		return

	# Top joueurs par score total
	var endpoint = supabase_url + "/rest/v1/players?select=name,level,total_slaps,total_damage_dealt&order=level.desc&limit=" + str(limit)
	var headers = [
		"apikey: " + supabase_anon_key,
		"Authorization: Bearer " + supabase_anon_key
	]

	http_request.request(endpoint, headers, HTTPClient.METHOD_GET)
	print("Fetching leaderboard...")

# ===== CALLBACKS =====

func _on_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()

	if response_code >= 200 and response_code < 300:
		print("Supabase request successful: ", response_code)
		is_connected = true
		connection_status_changed.emit(true)

		var json = JSON.new()
		if json.parse(response_text) == OK:
			var data = json.get_data()
			print("Response data: ", data)
			sync_completed.emit()
	else:
		print("Supabase request failed: ", response_code)
		print("Error: ", response_text)
		is_connected = false
		connection_status_changed.emit(false)
		sync_failed.emit(response_text)

# ===== UTILITAIRES =====

func is_valid_config() -> bool:
	return supabase_url != "https://YOUR_PROJECT.supabase.co" and supabase_anon_key != "YOUR_ANON_KEY"

func test_connection():
	if not is_valid_config():
		print("⚠️ Configuration Supabase non définie")
		print("Éditez scripts/autoload/SupabaseManager.gd avec vos credentials")
		return

	fetch_player_data()
