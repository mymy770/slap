# 👋 Slap Game

Un jeu mobile amusant où vous pouvez customiser un avatar et le gifler avec un système de timing précis !

## 🎮 Concept du Jeu

- **Customisation** : Créez votre avatar avec des vêtements, accessoires et couleurs personnalisées
- **Upload de photo** : Importez une photo pour créer un visage unique (à implémenter)
- **Jauge de puissance** : Système de timing style "penalty FIFA" avec zones de précision
- **Animation de gifle** : Des animations réactives selon la force du coup
- **Système de dégâts** : Le visage évolue visuellement selon les coups reçus
- **Barre de vie** : Jusqu'au KO final !

## 🛠️ Technologies

- **Moteur** : Godot 4.6
- **Langage** : GDScript
- **Plateforme** : Mobile (iOS + Android)
- **100% Open Source** : Aucun coût, aucune limitation

## 📁 Structure du Projet

```
slap-game/
├── scenes/               # Scènes Godot (.tscn)
│   ├── main/            # Scène principale
│   ├── customization/   # Écran de customisation
│   ├── game/            # Écran de jeu
│   └── avatar/          # Composants avatar
├── scripts/             # Scripts GDScript (.gd)
│   ├── autoload/        # Singletons (GameManager, AvatarManager)
│   ├── customization/   # Système de vêtements
│   ├── game/            # Logique du jeu (jauge, gifle)
│   └── avatar/          # Rendu et dégâts avatar
├── assets/              # Ressources
│   ├── sprites/         # Images (vêtements, visages, effets)
│   ├── animations/      # Animations
│   ├── sounds/          # Sons et musique
│   └── fonts/           # Polices
└── project.godot        # Configuration Godot
```

## 🚀 Pour Commencer

### 1. Ouvrir le projet dans Godot

```bash
# Depuis le terminal
godot slap-game/project.godot

# Ou double-cliquer sur project.godot
```

### 2. Créer les scènes de base

Le projet a la structure des scripts, mais vous devez créer les scènes (.tscn) dans l'éditeur Godot :

#### Scène principale (Main.tscn)
1. Créer une nouvelle scène avec un Node2D comme racine
2. Ajouter des boutons pour naviguer vers Customization ou Game
3. Sauvegarder dans `scenes/main/Main.tscn`

#### Scène Avatar (Avatar.tscn)
1. Créer une scène avec Node2D comme racine
2. Ajouter un nœud "Layers" avec des Sprite2D enfants :
   - Face (visage)
   - Body (corps)
   - ClothingTop (haut)
   - ClothingBottom (bas)
   - Shoes (chaussures)
   - Accessories (accessoires)
   - DamageOverlay (overlay de dégâts)
3. Attacher le script `scripts/avatar/avatar_renderer.gd`
4. Sauvegarder dans `scenes/avatar/Avatar.tscn`

#### Scène de jeu (GameScreen.tscn)
1. Créer une scène avec Control comme racine
2. Ajouter :
   - Un Camera2D
   - Instance de Avatar.tscn
   - PowerMeter (Node2D avec script `power_meter.gd`)
   - SlapController (Node2D avec script `slap_controller.gd`)
   - Button pour déclencher la gifle
   - ProgressBar pour la santé
3. Sauvegarder dans `scenes/game/GameScreen.tscn`

### 3. Ajouter des assets

Placez vos images dans :
- `assets/sprites/clothing/` : Vêtements
- `assets/sprites/faces/` : Visages par défaut
- `assets/sprites/effects/` : Effets visuels (impact, etc.)
- `assets/sounds/` : Sons de gifle, UI, etc.

## 🎯 Fonctionnalités Implémentées

### ✅ Systèmes de base

- **GameManager** : Gestion de l'état global, score, high score
- **AvatarManager** : Gestion avatar, customisation, santé
- **PowerMeter** : Jauge de puissance avec zones de précision (parfait/bon/ok)
- **SlapController** : Animations de gifle et calcul des dégâts
- **AvatarRenderer** : Rendu avec layers et effets de dégâts visuels
- **ClothingSystem** : Système de customisation des vêtements

### 🎨 Système de dégâts visuels

6 niveaux de dégâts :
- PRISTINE (100-80%)
- LIGHT (80-60%)
- MODERATE (60-40%)
- HEAVY (40-20%)
- CRITICAL (20-0%)
- KO (0%)

### 🎯 Zones de précision

- **Zone parfaite** (45-55%) : Vert, bonus de puissance +20%
- **Zone bonne** (35-65%) : Orange, puissance normale
- **Zone OK** (25-75%) : Jaune, -20% de puissance
- **Raté** (hors zones) : -50% de puissance

## 📱 Export Mobile

### Android
1. Dans Godot : Project → Export
2. Ajouter "Android"
3. Configurer le keystore
4. Export APK

### iOS
1. Nécessite un Mac avec Xcode
2. Dans Godot : Project → Export
3. Ajouter "iOS"
4. Export vers Xcode
5. Builder depuis Xcode

## 🔮 Prochaines Étapes

### À développer dans l'éditeur Godot :

1. **Créer les scènes** (.tscn files)
2. **Interface UI** : Menus, boutons, layouts
3. **Assets graphiques** : Dessiner ou importer sprites
4. **Sons** : Ajouter effets sonores
5. **Upload de photo** : Intégration caméra/galerie
6. **Génération IA** : API pour styliser les visages
7. **Animations avancées** : AnimationPlayer pour gifles
8. **Particules** : Effets d'impact
9. **Tutoriel** : Écran d'intro pour expliquer le jeu

### Fonctionnalités futures :

- 🎨 Plus d'options de customisation (cheveux, tatouages, piercings)
- 🖼️ Génération de visage stylisé via IA
- 🏆 Système de combos et power-ups
- 📊 Statistiques détaillées
- 🎵 Musique de fond
- 🌍 Localisations (FR, EN, ES, etc.)
- 👥 Mode multijoueur local
- 🏅 Achievements

## 💡 Conseils de Développement

### Workflow recommandé :
1. Développer dans l'éditeur Godot
2. Tester sur PC (F5)
3. Tester sur mobile via "Remote Debug"
4. Itérer rapidement

### Debug :
- Console Godot : Voir les prints et erreurs
- Remote Debug : Tester sur appareil réel
- Breakpoints : Dans l'éditeur de script

## 📚 Ressources

- [Documentation Godot](https://docs.godotengine.org/)
- [GDScript Tutorial](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Export Mobile](https://docs.godotengine.org/en/stable/tutorials/export/index.html)
- [Assets gratuits](https://kenney.nl/) : Sprites et sons

## 🤝 Contribution

Projet familial ! N'hésitez pas à expérimenter, ajouter des idées, et vous amuser !

## 📝 Licence

Open Source - Projet personnel sans restrictions

---

**Bon développement ! 🚀**
