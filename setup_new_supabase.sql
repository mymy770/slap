-- Script SQL à exécuter dans le SQL Editor du projet SLAP
-- URL: https://galkfztipohmmrsllnft.supabase.co

-- Table des joueurs
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uuid TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL DEFAULT 'Joueur',
    level INTEGER DEFAULT 1,
    experience INTEGER DEFAULT 0,
    coins INTEGER DEFAULT 100,
    total_slaps INTEGER DEFAULT 0,
    total_damage_dealt REAL DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    last_played TIMESTAMP DEFAULT NOW(),
    last_synced TIMESTAMP DEFAULT NOW()
);

-- Table des skins
CREATE TABLE IF NOT EXISTS skins (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL,
    rarity TEXT DEFAULT 'common',
    cost INTEGER DEFAULT 0,
    unlock_level INTEGER DEFAULT 1,
    description TEXT
);

-- Table des skins débloqués par joueur
CREATE TABLE IF NOT EXISTS player_skins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_uuid TEXT NOT NULL REFERENCES players(uuid) ON DELETE CASCADE,
    skin_id INTEGER NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW(),
    is_equipped BOOLEAN DEFAULT FALSE,
    UNIQUE(player_uuid, skin_id)
);

-- Table des parties jouées
CREATE TABLE IF NOT EXISTS games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_uuid TEXT NOT NULL REFERENCES players(uuid) ON DELETE CASCADE,
    score INTEGER DEFAULT 0,
    total_hits INTEGER DEFAULT 0,
    perfect_hits INTEGER DEFAULT 0,
    good_hits INTEGER DEFAULT 0,
    ok_hits INTEGER DEFAULT 0,
    miss_hits INTEGER DEFAULT 0,
    total_damage REAL DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    coins_earned INTEGER DEFAULT 0,
    experience_earned INTEGER DEFAULT 0,
    played_at TIMESTAMP DEFAULT NOW(),
    synced_at TIMESTAMP DEFAULT NOW()
);

-- Table des achievements
CREATE TABLE IF NOT EXISTS achievements (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    type TEXT NOT NULL,
    value INTEGER NOT NULL,
    reward_coins INTEGER DEFAULT 0,
    reward_exp INTEGER DEFAULT 0,
    icon TEXT
);

-- Table des achievements débloqués
CREATE TABLE IF NOT EXISTS player_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_uuid TEXT NOT NULL REFERENCES players(uuid) ON DELETE CASCADE,
    achievement_id INTEGER NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(player_uuid, achievement_id)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_players_uuid ON players(uuid);
CREATE INDEX IF NOT EXISTS idx_games_player_uuid ON games(player_uuid);
CREATE INDEX IF NOT EXISTS idx_games_score ON games(score DESC);
CREATE INDEX IF NOT EXISTS idx_players_level ON players(level DESC);
CREATE INDEX IF NOT EXISTS idx_player_skins_uuid ON player_skins(player_uuid);

-- Insérer les skins par défaut
INSERT INTO skins (id, name, type, rarity, cost, unlock_level, description) VALUES
    -- Hauts
    (0, 'T-shirt Basique', 'top', 'common', 0, 1, 'Le classique'),
    (1, 'Hoodie Rouge', 'top', 'common', 50, 2, 'Confortable et stylé'),
    (2, 'T-shirt Bleu', 'top', 'common', 50, 2, 'Fraîcheur garantie'),
    (3, 'Veste Verte', 'top', 'rare', 150, 4, 'Style militaire'),
    (4, 'Veste en Cuir', 'top', 'rare', 200, 5, 'Look badass'),
    (5, 'Chemise Dorée', 'top', 'epic', 500, 7, 'Brillant de mille feux'),
    (6, 'Armure Légendaire', 'top', 'legendary', 1000, 10, 'Pour les champions'),

    -- Bas
    (7, 'Jean Basique', 'bottom', 'common', 0, 1, 'Indémodable'),
    (8, 'Short Sport', 'bottom', 'common', 40, 2, 'Pour l''agilité'),
    (9, 'Pantalon Cargo', 'bottom', 'rare', 180, 5, 'Plein de poches'),
    (10, 'Jogging Violet', 'bottom', 'epic', 400, 6, 'Confort ultime'),

    -- Chaussures
    (11, 'Sneakers Blanches', 'shoes', 'common', 0, 1, 'Toujours propres'),
    (12, 'Baskets Rouges', 'shoes', 'common', 45, 2, 'Vitesse +10'),
    (13, 'Bottes de Combat', 'shoes', 'rare', 150, 4, 'Robustes'),
    (14, 'Chaussures Dorées', 'shoes', 'legendary', 800, 8, 'Marcher sur l''or'),

    -- Accessoires
    (15, 'Casquette Noire', 'accessory', 'common', 30, 1, 'Style urbain'),
    (16, 'Lunettes de Soleil', 'accessory', 'rare', 120, 3, 'Trop cool'),
    (17, 'Bandeau Rouge', 'accessory', 'rare', 100, 3, 'Esprit guerrier'),
    (18, 'Couronne Royale', 'accessory', 'legendary', 800, 8, 'Le roi du slap')
ON CONFLICT (id) DO NOTHING;

-- Insérer les achievements par défaut
INSERT INTO achievements (id, name, description, type, value, reward_coins, reward_exp, icon) VALUES
    (0, 'Première Gifle', 'Donner votre première gifle', 'total_slaps', 1, 10, 50, '🥊'),
    (1, 'Amateur', 'Donner 10 gifles', 'total_slaps', 10, 50, 100, '👊'),
    (2, 'Professionnel', 'Donner 100 gifles', 'total_slaps', 100, 200, 500, '💪'),
    (3, 'Maître du Slap', 'Donner 1000 gifles', 'total_slaps', 1000, 1000, 2000, '👑'),
    (4, 'Perfectionniste', '10 coups parfaits en une partie', 'perfect_hits_game', 10, 100, 200, '🎯'),
    (5, 'Précision Extrême', '20 coups parfaits en une partie', 'perfect_hits_game', 20, 300, 500, '🎖️'),
    (6, 'Destructeur', 'Infliger 500 de dégâts total', 'total_damage', 500, 200, 400, '💥'),
    (7, 'Annihilateur', 'Infliger 2000 de dégâts total', 'total_damage', 2000, 600, 1000, '⚡'),
    (8, 'Niveau 5', 'Atteindre le niveau 5', 'level', 5, 150, 0, '⭐'),
    (9, 'Niveau 10', 'Atteindre le niveau 10', 'level', 10, 500, 0, '🌟'),
    (10, 'Niveau 20', 'Atteindre le niveau 20', 'level', 20, 1500, 0, '✨'),
    (11, 'Marathonien', 'Jouer 50 parties', 'games_played', 50, 300, 600, '🏃'),
    (12, 'Collectionneur', 'Débloquer 10 skins', 'skins_unlocked', 10, 500, 1000, '👕')
ON CONFLICT (id) DO NOTHING;

-- Policies RLS (Row Level Security)
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_skins ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_achievements ENABLE ROW LEVEL SECURITY;

-- Policies pour permettre lecture/écriture
CREATE POLICY "Allow public read access to players" ON players FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to players" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update access to players" ON players FOR UPDATE USING (true);

CREATE POLICY "Allow public read access to games" ON games FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to games" ON games FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public read access to skins" ON skins FOR SELECT USING (true);

CREATE POLICY "Allow public read access to player_skins" ON player_skins FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to player_skins" ON player_skins FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public read access to achievements" ON achievements FOR SELECT USING (true);

CREATE POLICY "Allow public read access to player_achievements" ON player_achievements FOR SELECT USING (true);
CREATE POLICY "Allow public insert access to player_achievements" ON player_achievements FOR INSERT WITH CHECK (true);

-- Vue pour le leaderboard
CREATE OR REPLACE VIEW leaderboard AS
SELECT
    name,
    level,
    total_slaps,
    total_damage_dealt,
    games_played,
    ROW_NUMBER() OVER (ORDER BY level DESC, total_slaps DESC) as rank
FROM players
ORDER BY level DESC, total_slaps DESC
LIMIT 100;

COMMENT ON VIEW leaderboard IS 'Top 100 joueurs classés par niveau et nombre de gifles';
