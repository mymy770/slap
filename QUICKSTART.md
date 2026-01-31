# 🚀 Guide de Démarrage Rapide - Slap Game

## ✅ Ce qui est déjà fait

1. ✅ **Godot 4.6 installé** sur votre Mac
2. ✅ **Structure du projet créée** avec tous les dossiers
3. ✅ **Scripts GDScript écrits** pour toute la logique du jeu :
   - GameManager (gestion du jeu)
   - AvatarManager (avatar et santé)
   - PowerMeter (jauge de puissance)
   - SlapController (animation de gifle)
   - AvatarRenderer (affichage avec dégâts)
   - ClothingSystem (customisation)

## 🎯 Prochaines Étapes

### 1. Ouvrir Godot et le projet

```bash
# Option 1 : Depuis le terminal
cd /Users/jeremy/Desktop/jeux
godot project.godot

# Option 2 : Double-cliquer sur project.godot dans le Finder
```

### 2. Créer votre première scène (5 minutes)

Dans l'éditeur Godot :

#### A. Scène principale simple
1. Cliquer "New Scene" (Scène 2D)
2. Renommer le nœud racine en "Main"
3. Ajouter un ColorRect (plein écran) pour le fond
4. Ajouter un Label avec "Slap Game" en titre
5. Sauvegarder : `scenes/main/Main.tscn`

#### B. Tester que ça marche
1. Project → Project Settings → General → Run
2. Définir Main Scene : `res://scenes/main/Main.tscn`
3. Appuyer sur F5 pour lancer !

### 3. Créer la scène de l'avatar (10 minutes)

1. Scene → New Scene → 2D Scene
2. Renommer racine en "Avatar"
3. Ajouter un nœud "Node2D" enfant appelé "Layers"
4. Sous "Layers", ajouter ces Sprite2D :
   - Face
   - Body
   - ClothingTop
   - ClothingBottom
   - Shoes
   - Accessories
   - DamageOverlay

5. Sélectionner "Avatar" (racine) → Attach Script
6. Choisir le script existant : `scripts/avatar/avatar_renderer.gd`
7. Sauvegarder : `scenes/avatar/Avatar.tscn`

### 4. Créer la scène de jeu (15 minutes)

1. Scene → New Scene → User Interface (Control)
2. Renommer en "GameScreen"
3. Ajouter ces nœuds :
   ```
   GameScreen (Control)
   ├── Camera2D
   ├── Avatar (instance de Avatar.tscn)
   ├── PowerMeter (Node2D)
   │   └── Attach script: scripts/game/power_meter.gd
   ├── SlapController (Node2D)
   │   ├── Hand (Sprite2D)
   │   └── AnimationPlayer
   │   └── Attach script: scripts/game/slap_controller.gd
   ├── UI (Control)
   │   ├── SlapButton (Button)
   │   └── HealthBar (ProgressBar)
   ```

4. Connecter le bouton au code :
   - Sélectionner SlapButton → Node → Signals
   - Double-cliquer "pressed"
   - Créer une fonction qui appelle la logique de jeu

5. Sauvegarder : `scenes/game/GameScreen.tscn`

### 5. Premier test complet (5 minutes)

1. Ouvrir `scenes/main/Main.tscn`
2. Ajouter un Button "Jouer"
3. Script du bouton :
   ```gdscript
   get_tree().change_scene_to_file("res://scenes/game/GameScreen.tscn")
   ```
4. F5 pour tester !

## 📦 Assets à ajouter

Pour rendre le jeu visuel, vous aurez besoin de :

### Images minimales
- Une image de main (main.png) → `assets/sprites/effects/`
- Une image de visage par défaut → `assets/sprites/faces/`
- Des rectangles colorés pour les vêtements (ou juste des couleurs)

### Sons (optionnel)
- Slap1.wav, Slap2.wav → `assets/sounds/`

### Où trouver des assets gratuits ?
- [Kenney.nl](https://kenney.nl/) - Sprites gratuits
- [Freesound.org](https://freesound.org/) - Sons gratuits
- [OpenGameArt.org](https://opengameart.org/) - Assets de jeu

## 🎨 Version Minimale Sans Assets

Vous pouvez commencer sans aucune image ! Godot peut dessiner :

```gdscript
# Dans _draw() ou _ready()
# Dessiner un cercle pour la tête
draw_circle(Vector2(500, 400), 100, Color.BEIGE)

# Dessiner un rectangle pour le corps
draw_rect(Rect2(450, 500, 100, 200), Color.BLUE)
```

## 🐛 Debug et Test

### Voir les logs
- Output panel en bas de Godot
- `print("Mon message")` dans le code

### Tester sur mobile
1. Activer "Remote Debug" dans Godot
2. Connecter votre téléphone en USB
3. Project → Export → Android
4. "One Click Deploy"

## 💡 Astuces

1. **Ctrl+S** : Sauvegarder souvent !
2. **F5** : Lancer le jeu
3. **F6** : Lancer la scène actuelle
4. **Ctrl+D** : Dupliquer un nœud
5. **Ctrl+Z** : Annuler

## 📞 Aide

Si vous êtes bloqués :
1. Documentation Godot : https://docs.godotengine.org/
2. Discord Godot FR : https://discord.gg/godotfr
3. Tutos YouTube : "Godot 4 tutorial français"

## 🎉 Prochaines Sessions

Une fois le jeu de base qui marche :
1. Améliorer les animations
2. Ajouter plus de vêtements
3. Implémenter l'upload de photo
4. Créer des menus stylés
5. Ajouter des sons
6. Export vers Android/iOS

---

**Amusez-vous bien ! 🎮**
