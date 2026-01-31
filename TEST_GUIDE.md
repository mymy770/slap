# 🧪 Guide de Test - Slap Game

## ✅ Configuration Terminée

La base de données SLAP est maintenant configurée et connectée:
- **URL**: https://galkfztipohmmrsllnft.supabase.co
- **Tables créées**: 6 tables + 1 vue
- **Données insérées**: 19 skins + 13 achievements

## 🎮 Comment Tester le Jeu

### 1. Ouvrir le Projet dans Godot

```bash
open -a Godot /Users/jeremy/Desktop/jeux/slap-game
```

Ou double-cliquer sur `project.godot`

### 2. Lancer le Jeu

Dans Godot:
- Appuyer sur **F5** (ou cliquer sur le bouton Play)
- Ou cliquer sur le bouton ▶️ en haut à droite

### 3. Vérifier la Console

Dans la console Godot (en bas), vous devriez voir:
```
Player UUID: 1234567890_12345
Supabase request successful: 200
```

### 4. Test du Menu Principal

Sur l'écran principal:
- ✅ Bouton "JOUER" visible
- ✅ Bouton "PERSONNALISER" visible
- Cliquer sur "JOUER" pour démarrer

### 5. Test du GamePlay

Dans le jeu:
- ✅ PowerMeter apparaît (barre avec curseur)
- ✅ Cliquer quand le curseur est dans la zone verte = bon timing
- ✅ Score s'affiche
- ✅ Santé de l'avatar diminue
- ✅ Après KO, retour au menu

### 6. Vérifier la Synchronisation Supabase

#### 6.1 Aller sur Supabase
https://supabase.com/dashboard/project/galkfztipohmmrsllnft

#### 6.2 Cliquer sur "Table Editor"

#### 6.3 Ouvrir la table `players`
Vous devriez voir votre joueur:
- `uuid`: Votre identifiant unique
- `name`: "Joueur" (par défaut)
- `level`: 1
- `coins`: 100
- `experience`: 0

#### 6.4 Jouer une partie complète

Faire au moins 5 clics dans le jeu.

#### 6.5 Recharger la table `players`
Vos stats doivent avoir augmenté:
- `total_slaps`: nombre de clics
- `total_damage_dealt`: dégâts infligés
- `games_played`: +1

#### 6.6 Ouvrir la table `games`
Vous devriez voir l'historique de votre partie:
- `score`: Score obtenu
- `total_hits`: Nombre de coups
- `perfect_hits`, `good_hits`, `ok_hits`, `miss_hits`: Détails
- `coins_earned`: Pièces gagnées
- `experience_earned`: XP gagnée
- `played_at`: Date/heure

## 🔍 Tests Spécifiques

### Test 1: Vérifier les Skins
```bash
curl -s 'https://galkfztipohmmrsllnft.supabase.co/rest/v1/skins?select=*' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhbGtmenRpcG9obW1yc2xsbmZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NzgwMzksImV4cCI6MjA4NTQ1NDAzOX0.6Ufy-lFujePbHHIqahSbD1tSTWi2y7LgwtKmiRTbIbo'
```
Devrait retourner 19 skins (4 catégories: top, bottom, shoes, accessory)

### Test 2: Vérifier les Achievements
```bash
curl -s 'https://galkfztipohmmrsllnft.supabase.co/rest/v1/achievements?select=*' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhbGtmenRpcG9obW1yc2xsbmZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NzgwMzksImV4cCI6MjA4NTQ1NDAzOX0.6Ufy-lFujePbHHIqahSbD1tSTWi2y7LgwtKmiRTbIbo'
```
Devrait retourner 13 achievements

### Test 3: Vérifier le Leaderboard
```bash
curl -s 'https://galkfztipohmmrsllnft.supabase.co/rest/v1/leaderboard?select=*' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhbGtmenRpcG9obW1yc2xsbmZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NzgwMzksImV4cCI6MjA4NTQ1NDAzOX0.6Ufy-lFujePbHHIqahSbD1tSTWi2y7LgwtKmiRTbIbo'
```
Après avoir joué, vous devriez apparaître dans le classement.

## 📊 Dashboard Supabase

Pour voir toutes les données en temps réel:
1. https://supabase.com/dashboard/project/galkfztipohmmrsllnft
2. Table Editor → Sélectionner une table
3. Actualiser pour voir les nouvelles données après avoir joué

## 🎯 Checklist de Test

- [ ] Le jeu se lance sans erreur
- [ ] La console affiche "Player UUID: ..."
- [ ] La console affiche "Supabase request successful: 200"
- [ ] Le menu principal s'affiche
- [ ] Le bouton "JOUER" fonctionne
- [ ] Le PowerMeter apparaît et bouge
- [ ] Les clics sont détectés
- [ ] Le score augmente
- [ ] La santé de l'avatar diminue
- [ ] Après KO, retour au menu
- [ ] Les données apparaissent dans Supabase table `players`
- [ ] Les parties apparaissent dans Supabase table `games`
- [ ] Le leaderboard se remplit

## 🐛 Troubleshooting

### Erreur "invalid API key"
Vérifier dans `scripts/autoload/SupabaseManager.gd` lignes 10-11:
```gdscript
var supabase_url = "https://galkfztipohmmrsllnft.supabase.co"
var supabase_anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Pas de synchronisation
1. Vérifier la connexion internet
2. Regarder la console Godot pour les erreurs
3. Vérifier que les tables existent dans Supabase

### Le jeu ne démarre pas
1. Vérifier que Godot 4.6 est installé
2. Ouvrir le projet dans Godot
3. Regarder les erreurs dans la console

## 🎉 Prochaines Étapes

Une fois les tests validés:
1. Créer l'écran de personnalisation
2. Ajouter les sprites graphiques
3. Implémenter l'upload de photo
4. Ajouter les sons
5. Tester sur mobile (iOS/Android)

---

**Tout fonctionne? Parfait! La base du jeu est opérationnelle.**
