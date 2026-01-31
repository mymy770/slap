# 🗄️ Configuration Supabase pour Slap Game

## Pourquoi Supabase ?

- ✅ **100% Gratuit** pour votre usage (500MB + 50k requêtes/mois)
- ✅ **Sync Cloud** : Progression sauvegardée entre appareils
- ✅ **Leaderboard global** : Comparez-vous aux autres joueurs
- ✅ **Backup automatique** : Jamais de perte de données
- ✅ **Open source** : Pas de vendor lock-in

## 📝 Étape 1 : Créer un Nouveau Projet Supabase

### 1.1 Aller sur Supabase
1. Ouvrir https://supabase.com/
2. Cliquer "Start your project"
3. Se connecter avec GitHub (si pas déjà fait)

### 1.2 Créer le projet
1. Cliquer "New Project"
2. Choisir votre organisation
3. Remplir :
   - **Name** : `slap-game`
   - **Database Password** : Générer un mot de passe fort (le sauvegarder !)
   - **Region** : Choisir le plus proche (ex: `Europe West (Frankfurt)`)
   - **Pricing Plan** : Gratuit
4. Cliquer "Create new project"
5. ⏳ Attendre ~2 minutes que le projet se crée

## 📊 Étape 2 : Créer les Tables

### 2.1 Ouvrir le SQL Editor
1. Dans votre projet Supabase, cliquer sur "SQL Editor" dans le menu gauche
2. Cliquer "New query"

### 2.2 Copier-Coller le Schema
1. Ouvrir le fichier `supabase_schema.sql` dans ce repo
2. Copier TOUT le contenu
3. Coller dans le SQL Editor de Supabase
4. Cliquer "Run" (en bas à droite)
5. ✅ Vous devriez voir "Success. No rows returned"

### 2.3 Vérifier les Tables
1. Cliquer sur "Table Editor" dans le menu gauche
2. Vous devriez voir ces tables :
   - `players`
   - `skins`
   - `player_skins`
   - `games`
   - `achievements`
   - `player_achievements`

## 🔑 Étape 3 : Récupérer les Credentials

### 3.1 Trouver les Clés
1. Cliquer sur "Project Settings" (icône engrenage en bas à gauche)
2. Cliquer sur "API" dans le menu
3. Vous verrez :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon public** key : Une longue clé commençant par `eyJ...`

### 3.2 Copier les Credentials
Copiez ces deux valeurs, vous en aurez besoin à l'étape suivante.

## ⚙️ Étape 4 : Configurer le Jeu

### 4.1 Ouvrir le Fichier de Configuration
Dans Godot, ouvrir :
```
scripts/autoload/SupabaseManager.gd
```

### 4.2 Remplacer les Credentials
Aux lignes 9-10, remplacer :

```gdscript
# AVANT
var supabase_url = "https://YOUR_PROJECT.supabase.co"
var supabase_anon_key = "YOUR_ANON_KEY"

# APRÈS (avec VOS vraies valeurs)
var supabase_url = "https://xxxxx.supabase.co"  # Votre Project URL
var supabase_anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # Votre anon key
```

⚠️ **IMPORTANT** : Ne committez JAMAIS ces clés sur GitHub public !

### 4.3 Sauvegarder
Sauvegarder le fichier (Ctrl+S)

## 🧪 Étape 5 : Tester la Connexion

### 5.1 Lancer le Jeu
1. Dans Godot, appuyer sur F5
2. Regarder la console en bas

### 5.2 Vérifier les Logs
Vous devriez voir :
```
Player UUID: 1234567890_12345
Supabase request successful: 200
```

### 5.3 Vérifier dans Supabase
1. Retourner sur Supabase
2. Cliquer "Table Editor"
3. Ouvrir la table `players`
4. Vous devriez voir votre joueur créé ! 🎉

## 📈 Utilisation des Données

### Voir les Joueurs
```sql
SELECT * FROM players ORDER BY level DESC;
```

### Voir les Parties Jouées
```sql
SELECT * FROM games ORDER BY played_at DESC LIMIT 10;
```

### Leaderboard
```sql
SELECT * FROM leaderboard;
```

### Top 10 Meilleurs Scores
```sql
SELECT
    p.name,
    p.level,
    p.total_slaps,
    p.total_damage_dealt
FROM players p
ORDER BY p.level DESC, p.total_slaps DESC
LIMIT 10;
```

## 🔒 Sécurité

### Row Level Security (RLS)
Les policies sont déjà configurées dans le schema pour :
- ✅ Permettre la lecture publique (leaderboard)
- ✅ Permettre l'écriture publique (progression)

### Pour Production
Si vous voulez plus de sécurité :
1. Activer l'authentification Supabase
2. Modifier les policies RLS
3. Utiliser les JWT tokens

## 🚀 Fonctionnalités Activées

### Sauvegarde Auto
- ✅ Progression sauvegardée après chaque partie
- ✅ Skins débloqués synchronisés
- ✅ Achievements synchronisés

### Leaderboard
- ✅ Classement global des joueurs
- ✅ Mise à jour en temps réel
- ✅ Top 100 joueurs

### Statistiques
- ✅ Historique des parties
- ✅ Stats globales par joueur
- ✅ Analyse des performances

## 🔄 Mode Offline

Le jeu fonctionne aussi **sans connexion** :
- Données sauvegardées localement
- Sync automatique quand connexion revient
- Pas de perte de progression

## 📊 Dashboard Supabase

### Voir les Stats
1. Cliquer sur "Dashboard" dans Supabase
2. Vous verrez :
   - Nombre de joueurs
   - Nombre de parties
   - Requêtes API
   - Utilisation stockage

### Quotas Gratuits
- 500 MB de stockage
- 50,000 requêtes/mois
- 2 Go de bande passante

**Pour ce jeu, c'est largement suffisant !**

## 🐛 Troubleshooting

### Erreur "invalid API key"
- Vérifier que vous avez copié la bonne clé **anon public**
- Ne pas utiliser la clé "service_role" (trop dangereuse)

### Erreur "relation does not exist"
- Vous avez oublié d'exécuter le SQL schema
- Retourner à l'Étape 2

### Pas de synchronisation
- Vérifier la console Godot pour les erreurs
- Vérifier votre connexion internet
- Vérifier les credentials dans SupabaseManager.gd

## 📚 Documentation

- [Supabase Docs](https://supabase.com/docs)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## ✅ Checklist Finale

- [ ] Projet Supabase créé
- [ ] Tables créées (SQL schema exécuté)
- [ ] Credentials copiés dans SupabaseManager.gd
- [ ] Jeu testé et connexion OK
- [ ] Premier joueur visible dans la table `players`

---

**Une fois configuré, tout est automatique ! 🎉**
