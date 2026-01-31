# 📋 Notes Techniques - Slap Game

## Architecture du Code

### Singletons (Autoload)

#### GameManager.gd
Gère l'état global du jeu :
- États : MENU, CUSTOMIZATION, PLAYING, GAME_OVER
- Score et high score
- Sauvegarde/chargement des scores

#### AvatarManager.gd
Gère l'avatar et sa santé :
- Configuration de l'avatar (vêtements, couleurs, accessoires)
- Système de santé (0-100)
- 6 niveaux de dégâts visuels
- Sauvegarde/chargement de l'avatar

### Systèmes de Jeu

#### PowerMeter (power_meter.gd)
Jauge de puissance style "penalty FIFA" :
- Vitesse augmente avec la difficulté
- 4 zones de précision :
  - **Parfaite** (45-55%) : Vert, +20% bonus
  - **Bonne** (35-65%) : Orange, 100% puissance
  - **OK** (25-75%) : Jaune, -20%
  - **Raté** (hors zones) : -50%
- Retourne : power (0-1.2), accuracy (0-1), zone

#### SlapController (slap_controller.gd)
Contrôle les animations de gifle :
- 3 animations selon puissance : weak, medium, strong
- Calcul des dégâts : `base_damage * power * (0.5 + accuracy * 0.5)`
- Vibration haptique sur mobile
- Screen shake pour feedback

#### AvatarRenderer (avatar_renderer.gd)
Rendu de l'avatar avec système de layers :
- 7 layers : Face, Body, ClothingTop, ClothingBottom, Shoes, Accessories, DamageOverlay
- Changement visuel selon santé
- Animation de KO

## Formules de Calcul

### Dégâts
```gdscript
base_damage = 15.0
damage = base_damage * power * (0.5 + accuracy * 0.5)
```

Exemples :
- Parfait (power=1.2, accuracy=1.0) : 22.5 dégâts
- Bon (power=1.0, accuracy=0.75) : 16.9 dégâts
- OK (power=0.8, accuracy=0.5) : 12.0 dégâts
- Raté (power=0.5, accuracy=0.2) : 5.25 dégâts

### Vitesse de la Jauge
```gdscript
current_speed = min_speed + (level - 1) * speed_increase_rate
current_speed = clamp(current_speed, 200, 800)
```

### Niveaux de Santé
- PRISTINE : 100-80%
- LIGHT : 80-60%
- MODERATE : 60-40%
- HEAVY : 40-20%
- CRITICAL : 20-0%
- KO : 0%

## Signaux (Events)

### GameManager
- `game_started` : Émis quand le jeu démarre
- `game_paused` : Émis quand le jeu est en pause
- `game_over(final_score)` : Émis au game over

### AvatarManager
- `avatar_updated` : Émis quand l'avatar change
- `health_changed(new_health)` : Émis quand la santé change
- `avatar_ko` : Émis au KO (santé = 0)

### PowerMeter
- `power_locked(power, accuracy)` : Émis quand jauge stoppée

### SlapController
- `slap_completed(damage)` : Émis après animation de gifle

## Système de Sauvegarde

### Fichiers
- `user://high_score.save` : High score (int32)
- `user://avatar.save` : Configuration avatar (Dictionary)

### Chemin
- Windows : `%APPDATA%/Godot/app_userdata/Slap Game/`
- macOS : `~/Library/Application Support/Godot/app_userdata/Slap Game/`
- Linux : `~/.local/share/godot/app_userdata/Slap Game/`
- Android : `/data/data/[package]/files/`
- iOS : `Documents/`

## Performance

### Mobile Optimization
- Rendering method : "mobile" (Vulkan Mobile)
- VRAM compression : ETC2/ASTC
- Orientation : Portrait verrouillé
- Résolution : 1080x2400 (adaptatif)

### Draw Calls
Le PowerMeter utilise `_draw()` pour un rendering custom efficient :
- 1 draw call pour le fond
- 3-5 draw calls pour les zones colorées
- 1 draw call pour le curseur
- 1 draw call pour la bordure

## Optimisations Futures

### Code
- [ ] Object pooling pour effets de particules
- [ ] Texture atlas pour sprites
- [ ] Compression audio (OGG Vorbis)
- [ ] Cache des calculs de dégâts

### Gameplay
- [ ] Système de combos (coups consécutifs)
- [ ] Power-ups temporaires
- [ ] Achievements locaux
- [ ] Replay système

### UI/UX
- [ ] Animations de transition entre scènes
- [ ] Feedback sonore
- [ ] Particules d'impact
- [ ] Trails visuels

## Upload Photo (À implémenter)

### Options

#### Option 1 : Simple Upload
```gdscript
var image = Image.load_from_file(photo_path)
var texture = ImageTexture.create_from_image(image)
AvatarManager.set_face_texture(texture)
```

#### Option 2 : IA Génération (Externe)
```gdscript
# Appel API REST (Replicate, Stability AI, etc.)
var http_request = HTTPRequest.new()
add_child(http_request)
http_request.request("https://api.replicate.com/...", headers, method, body)
```

#### Option 3 : IA Locale (ComfyUI)
- Self-host ComfyUI sur serveur
- API REST locale
- Coût initial mais 0€ récurrent

## Génération de Visage Stylisé

### Prompt Stable Diffusion
```
"cartoon style portrait, simple 2D game character,
flat colors, clean lines, expressive face,
front view, neutral expression,
suitable for mobile game avatar"
```

### Post-processing
1. Crop/resize pour ratio carré
2. Appliquer masque circulaire
3. Créer versions avec dégâts (overlays rouge/bleu)
4. Sauvegarder 6 versions (pristine → critical)

## Extensions Possibles

### Multijoueur
- Mode "Battle" : 2 joueurs tour par tour
- Backend : Supabase ou Firebase
- Matchmaking simple
- Leaderboard global

### Monétisation (Optionnelle)
- Pas de pub (100% gratuit)
- Dons optionnels (Ko-fi, Patreon)
- Ou IAP cosmétiques uniquement

### Accessibilité
- Mode daltonien (changer couleurs zones)
- Ralentir jauge (mode facile)
- Audio cues (bips pour zones)
- Contraste élevé

## Debug Commands

### Console
```gdscript
# Dans GameScreen.gd
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D:  # Debug
				print("Health: ", AvatarManager.current_health)
				print("Score: ", GameManager.score)
			KEY_R:  # Reset health
				AvatarManager.reset_health()
			KEY_K:  # Instant KO
				AvatarManager.current_health = 0
				AvatarManager.avatar_ko.emit()
```

## Configuration Mobile

### Android (export_presets.cfg)
```ini
[preset.0]
name="Android"
platform="Android"
runnable=true
custom_features=""
export_filter="all_resources"
```

### iOS (export_presets.cfg)
```ini
[preset.1]
name="iOS"
platform="iOS"
runnable=true
custom_features=""
export_filter="all_resources"
```

## Notes d'Implémentation

### Priorités
1. ✅ Système de base fonctionnel
2. 🔄 Interface UI complète
3. 🔄 Assets graphiques
4. ⏳ Upload photo
5. ⏳ Customisation avancée
6. ⏳ Génération IA

### Décisions Techniques
- **Godot 4.6** : Plus moderne, meilleures perfs mobile
- **GDScript** : Plus simple que C# pour débuter
- **Pas de plugins externes** : Rester vanilla pour éviter dépendances

---

**Dernière mise à jour : 2026-01-31**
