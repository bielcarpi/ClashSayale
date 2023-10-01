-- DROP ALL TEMPORARY TABLES IF EXISTS ----------------------------
DROP TABLE IF EXISTS arena_pack_tmp;
DROP TABLE IF EXISTS arenas_tmp;
DROP TABLE IF EXISTS battles_tmp;
DROP TABLE IF EXISTS buildings_tmp;
DROP TABLE IF EXISTS cards_tmp;
DROP TABLE IF EXISTS clan_battles_tmp;
DROP TABLE IF EXISTS clan_tech_structures_tmp;
DROP TABLE IF EXISTS clans_tmp;
DROP TABLE IF EXISTS friends_tmp;
DROP TABLE IF EXISTS messages_between_players_tmp;
DROP TABLE IF EXISTS messages_to_clans_tmp;
DROP TABLE IF EXISTS player_purchases_tmp;
DROP TABLE IF EXISTS players_quests_tmp;
DROP TABLE IF EXISTS players_tmp;
DROP TABLE IF EXISTS players_achievements_tmp;
DROP TABLE IF EXISTS players_badge_tmp;
DROP TABLE IF EXISTS players_cards_tmp;
DROP TABLE IF EXISTS players_clans_tmp;
DROP TABLE IF EXISTS players_clans_donations_tmp;
DROP TABLE IF EXISTS quests_arenas_tmp;
DROP TABLE IF EXISTS seasons_tmp;
DROP TABLE IF EXISTS shared_decks_tmp;
DROP TABLE IF EXISTS technologies_tmp;
----------------------------------------------------------------




-- CREATE TEMPORARY TABLES -------------------------------------
CREATE TABLE arena_pack_tmp (
    id_arena_pack INT,
    arena INT,
    PRIMARY KEY (id_arena_pack, arena),
    gold INT NOT NULL
);
COPY arena_pack_tmp FROM '/Users/Shared/datasets/arena_pack.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE arenas_tmp (
    id INT PRIMARY KEY,
    name_arena TEXT NOT NULL,
    min_trophies INT NOT NULL,
    max_trophies INT NOT NULL
);
COPY arenas_tmp FROM '/Users/Shared/datasets/arenas.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE battles_tmp (
    id SERIAL PRIMARY KEY,
    winner INT NOT NULL,
    loser INT NOT NULL,
    winner_score INT NOT NULL,
    loser_score INT NOT NULL,
    date_battle DATE NOT NULL,
    duration INTERVAL NOT NULL,
    clan_battle INT
);
COPY battles_tmp (winner, loser, winner_score, loser_score, date_battle, duration, clan_battle) FROM '/Users/Shared/datasets/battles.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE buildings_tmp (
    building TEXT PRIMARY KEY,
    cost INT NOT NULL,
    trophies INT NOT NULL,
    prerequisite TEXT,
    mod_damage INT,
    mod_hit_speed INT,
    mod_radius INT,
    mod_spawn_damage INT,
    mod_lifetime INT,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (prerequisite)
        REFERENCES buildings_tmp (building)
);
COPY buildings_tmp FROM '/Users/Shared/datasets/buildings.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE cards_tmp (
    name_card TEXT PRIMARY KEY,
    rarity TEXT NOT NULL,
    arena INT NOT NULL,
    damage INT NOT NULL,
    hit_speed INT NOT NULL,
    spawn_damage INT,
    life_time INT,
    radious INT,
    aux SERIAL
);
COPY cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage, life_time, radious) FROM '/Users/Shared/datasets/cards.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE clan_battles_tmp (
    battle INT,
    clan TEXT,
    PRIMARY KEY (battle, clan),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);
COPY clan_battles_tmp FROM '/Users/Shared/datasets/clan_battles.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE clan_tech_structures_tmp (
    id SERIAL PRIMARY KEY,
    clan TEXT NOT NULL,
    tech TEXT,
    structure TEXT,
    date_obtained DATE NOT NULL,
    level_structure INT NOT NULL
);
COPY clan_tech_structures_tmp (clan, tech, structure, date_obtained, level_structure) FROM '/Users/Shared/datasets/clan_tech_structures.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE clans_tmp (
    tag TEXT PRIMARY KEY,
    name_clan TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    required_trophies INT NOT NULL,
    score INT NOT NULL,
    trophies INT NOT NULL
);
COPY clans_tmp FROM '/Users/Shared/datasets/clans.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE friends_tmp (
    requester TEXT,
    requested TEXT,
    PRIMARY KEY (requester, requested)
);
COPY friends_tmp FROM '/Users/Shared/datasets/friends.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE messages_between_players_tmp (
    id INT PRIMARY KEY,
    sender TEXT NOT NULL,
    receiver TEXT NOT NULL,
    message_text TEXT NOT NULL,
    date_sent DATE NOT NULL,
    answer INT
);
COPY messages_between_players_tmp FROM '/Users/Shared/datasets/messages_between_players.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE messages_to_clans_tmp (
    id INT PRIMARY KEY,
    sender TEXT NOT NULL,
    receiver TEXT NOT NULL,
    message_text TEXT NOT NULL,
    date_sent DATE NOT NULL,
    answer INT
);
COPY messages_to_clans_tmp FROM '/Users/Shared/datasets/messages_to_clans.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE player_purchases_tmp (
    purchase_id SERIAL PRIMARY KEY,
    player_id TEXT NOT NULL,
    credit_card TEXT NOT NULL,
    buy_id INT, -- No te sentit que l'ID d'una compra es repeteixi. Aquest atribut no l'utilitzarem
    buy_name TEXT, -- No te sentit un nom a la compra, aquest atribut no l'utilitzarem
    buy_cost NUMERIC NOT NULL,
    buy_stock INT NOT NULL,
    date_purchase DATE NOT NULL,
    discount FLOAT DEFAULT 0,
    arenapack_id INT,
    chest_name TEXT,
    chest_rarity TEXT,
    chest_unlock_time INT, -- En minuts
    chest_num_cards INT,
    bundle_gold INT,
    bundle_gems INT,
    emote_name TEXT,
    emote_path TEXT
);
COPY player_purchases_tmp (player_id, credit_card, buy_id, buy_name, buy_cost, buy_stock, date_purchase, discount, arenapack_id, chest_name, chest_rarity, chest_unlock_time, chest_num_cards, bundle_gold, bundle_gems, emote_name, emote_path) FROM '/Users/Shared/datasets/player_purchases.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE players_quests_tmp (
    id_players_quests SERIAL PRIMARY KEY,
    player_tag TEXT NOT NULL,
    quest_id INT NOT NULL,
    quest_title TEXT NOT NULL,
    quest_description TEXT NOT NULL,
    quest_requirement TEXT NOT NULL,
    quest_depends INT,
    unlock DATE
);
COPY players_quests_tmp (player_tag, quest_id, quest_title, quest_description, quest_requirement, quest_depends, unlock) FROM '/Users/Shared/datasets/players_quests.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE players_tmp (
    id_player TEXT PRIMARY KEY,
    player_name TEXT NOT NULL,
    player_experience INT DEFAULT 0,
    player_trophies INT DEFAULT 0,
    player_cardnumber TEXT NOT NULL,
    player_card_expiry DATE NOT NULL
);
COPY players_tmp FROM '/Users/Shared/datasets/players.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE players_achievements_tmp (
    id_player TEXT,
    achievement_name TEXT,
    achievement_description TEXT NOT NULL,
    id_arena INT NOT NULL,
    date_obtained DATE NOT NULL,
    gems_obtained INT DEFAULT 0,
    PRIMARY KEY (id_player, achievement_name) 
);
COPY players_achievements_tmp FROM '/Users/Shared/datasets/playersachievements.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE players_badge_tmp (
    id_player TEXT,
    badge_name TEXT,
    PRIMARY KEY (id_player, badge_name),
    id_arena INT,
    date_obtained  DATE NOT NULL,
    badge_img TEXT NOT NULL
);
COPY players_badge_tmp FROM '/Users/Shared/datasets/playersbadge.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE players_cards_tmp (
    id_player TEXT,
    id_card INT,
    PRIMARY KEY (id_player, id_card),
    name_card TEXT NOT NULL,
    level_card INT NOT NULL,
    amount INT NOT NULL,
    date_obtained DATE NOT NULL
);
COPY players_cards_tmp FROM '/Users/Shared/datasets/playerscards.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE players_clans_tmp (
    player TEXT,
    clan TEXT,
    player_role TEXT NOT NULL, 
    date_in DATE,
    PRIMARY KEY (player,clan)
);
COPY players_clans_tmp FROM '/Users/Shared/datasets/playersClans.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE players_clans_donations_tmp (
    id_donacio SERIAL PRIMARY KEY,
    player TEXT NOT NULL,
    clan TEXT NOT NULL,
    gold INT NOT NULL, 
    donation_date DATE NOT NULL
);
COPY players_clans_donations_tmp(player, clan, gold, donation_date) FROM '/Users/Shared/datasets/playersCLansdonations.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE players_deck_tmp (
    player TEXT NOT NULL,
    deck INT,
    title TEXT, --Falta añadir NOT NULL
    description TEXT,
    creation_date DATE,
    id_card INT,
    level INT,
    PRIMARY KEY (deck, id_card)
);
COPY players_deck_tmp FROM '/Users/Shared/datasets/playersdeck.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE quests_arenas_tmp (
    quest_id INT,
    arena_id INT,
    gold INT NOT NULL,
    experience INT NOT NULL,
    PRIMARY KEY (quest_id, arena_id)
);
COPY quests_arenas_tmp FROM '/Users/Shared/datasets/quests_arenas.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE seasons_tmp (
    name TEXT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);
COPY seasons_tmp FROM '/Users/Shared/datasets/seasons.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE shared_decks_tmp (
    deck INT,
    player TEXT,
    PRIMARY KEY (deck, player)
);
COPY shared_decks_tmp FROM '/Users/Shared/datasets/shared_decks.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE technologies_tmp (
    technology TEXT PRIMARY KEY,
    cost INT NOT NULL,
    max_level INT NOT NULL,
    prerequisite TEXT,
    prereq_level INT,
    mod_damage INT,
    mod_hit_speed INT,
    mod_radius INT,
    mod_spawn_damage INT,
    mod_lifetime INT,
    descripcion TEXT NOT NULL,
    FOREIGN KEY (prerequisite)
        REFERENCES technologies_tmp (technology)
);
COPY technologies_tmp FROM '/Users/Shared/datasets/technologies.csv' DELIMITER ',' CSV HEADER;


-- csv's Propis ------------------------------------------------------------------------------------------------------
CREATE TABLE gold_gemmes_tmp (
    id_aux SERIAL,
    gold INT,
    gemmes INT
);
COPY gold_gemmes_tmp (gold, gemmes) FROM '/Users/Shared/datasets/gold_gemmes.csv' DELIMITER ',' CSV HEADER;    

CREATE TABLE nivell_tmp (
    id_aux INT,
    multiplicador_estadistiques NUMERIC,
    cost_or_seguent_nivell INT,
    recompensa_xp INT
);
COPY nivell_tmp FROM '/Users/Shared/datasets/nivell_aux.csv' DELIMITER ',' CSV HEADER;    

CREATE TABLE clan2_tmp (
    id SERIAL,
    num_jugadors INT,
    or_donacions INT
);
COPY clan2_tmp FROM '/Users/Shared/datasets/clan_aux.csv' DELIMITER ',' CSV HEADER;    
-------------------------------------------------------------------------------------------------------



-- COPY VALUES FROM TEMPORARY TABLES TO TABLES
-- Taula Jugador --------------------------------------------------------------------------------------
ALTER TABLE jugador 
ADD COLUMN aux_id SERIAL;

INSERT INTO jugador (ID_jugador, nom, experiencia, trofeus) 
    (SELECT id_player, player_name, player_experience, player_trophies FROM players_tmp);

UPDATE jugador 
    SET gold = gold_gemmes_tmp.gold, gemmes = gold_gemmes_tmp.gemmes
    FROM gold_gemmes_tmp
    WHERE jugador.aux_id = gold_gemmes_tmp.id_aux;
    
ALTER TABLE jugador 
DROP COLUMN aux_id;


-- Taula Arena --------------------------------------------------------------------------------------
INSERT INTO arena (ID_arena, nom_arena, min_trofeus, max_trofeus)
    (SELECT id, name_arena, min_trophies, max_trophies FROM arenas_tmp);


-- Taula jugadors_arena -----------------------------------------------------------------------------
INSERT INTO jugadors_arena (ID_jugador, ID_arena)
    (SELECT jugador.ID_jugador, arena.ID_arena 
    FROM jugador, arena 
    WHERE jugador.trofeus >= arena.min_trofeus
    AND jugador.trofeus <= arena.max_trofeus);


-- Taula raresa -------------------------------------------------------------------------------------
INSERT INTO raresa (nom_raresa, multiplicador_or_nivell, percentatge_aparicio)
    (SELECT DISTINCT chest_rarity, 0, 0
    FROM player_purchases_tmp
    WHERE chest_rarity IS NOT NULL);

UPDATE raresa 
    SET multiplicador_or_nivell = 1,
    percentatge_aparicio = 0.45
    WHERE nom_raresa = 'Common';
UPDATE raresa 
    SET multiplicador_or_nivell = 1.25,
    percentatge_aparicio = 0.25
    WHERE nom_raresa = 'Rare';
UPDATE raresa 
    SET multiplicador_or_nivell = 1.5,
    percentatge_aparicio = 0.15
    WHERE nom_raresa = 'Epic';
UPDATE raresa 
    SET multiplicador_or_nivell = 1.75,
    percentatge_aparicio = 0.10
    WHERE nom_raresa = 'Legendary';
UPDATE raresa 
    SET multiplicador_or_nivell = 2,
    percentatge_aparicio = 0.05
    WHERE nom_raresa = 'Champion';


-- Taula Carta -------------------------------------------------------------------------------------
-- Modificamos tabla cards_tmp y le añadimos un atributo SERIAL (hecho en el CREATE TABLE)
-- Añadimos columna SERIAL a carta
 ALTER TABLE carta 
 ADD COLUMN aux_id SERIAL;

 -- Le metemos los 106 id a carta + valores harcoded para que no se queje 
 INSERT INTO carta ( ID_carta, nom_carta, dany, velocitat_atac, nom_raresa, arena_necessaria )
    (SELECT DISTINCT id_card, '', 0, 0, 'Common', 54000000
    FROM players_deck_tmp
    ORDER BY id_card ASC); 

-- Hacer 7 insert a la tabla auxiliar cards_tmp de 7 nuevas cartas 
-- del mismo tipo (hacemos que estas cartas tengan el campo dany_aparicio lleno
-- y asi hacemos que estas 7 cartas sean 'Tropa')

-- (añadimos 7 cartas pq en players_deck hay 106 ids diferentes de cartas pero en cards 
-- solo nos dan 99 cartas)
INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('ElMoyas', 'Common', 54000016, 10, 24, 8);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('Bielsito', 'Epic', 54000027, 30, 44, 170);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('Alexito', 'Legendary', 54000058, 79, 180, 280);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('Rafoti', 'Rare', 54000013, 60, 20, 80);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('CR7', 'Legendary', 54000005, 70, 28, 135);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('Ronaldinho', 'Rare', 54000032, 90, 56, 97);

INSERT INTO cards_tmp (name_card, rarity, arena, damage, hit_speed, spawn_damage)
VALUES ('Male', 'Legendary', 54000007, 120, 104, 198);

-- Hacer update de carta añadiendo todos los datos de cards_tmp igualando SERIALS
UPDATE carta 
    SET nom_carta = cards_tmp.name_card,
    dany = cards_tmp.damage,
    velocitat_atac = cards_tmp.hit_speed,
    nom_raresa = cards_tmp.rarity,
    arena_necessaria = cards_tmp.arena 
    FROM cards_tmp
    WHERE aux_id = cards_tmp.aux;

-- Eliminamos columna SERIAL a carta
ALTER TABLE carta
DROP COLUMN aux_id;

--En cards_tmp distinguimos de que tipo es cada carta
--Entonces la idea es coger todos los ids de la tabla cards
--y atributo 'x' de la tabla cards_tmp donde atributo 'x' no sea null en
--cards_tmp y el nombre de cards_tmp coincida con el nombre de cards para saber que 
--id coger

INSERT INTO edifici (ID_edifici, vida)
    (SELECT c.ID_carta, ct.life_time 
    FROM carta AS c JOIN cards_tmp AS ct
    ON c.nom_carta = ct.name_card
    WHERE ct.life_time IS NOT NULL);

INSERT INTO tropa (ID_tropa, dany_aparicio)
    (SELECT c.ID_carta, ct.spawn_damage 
    FROM carta AS c JOIN cards_tmp AS ct
    ON c.nom_carta = ct.name_card
    WHERE ct.spawn_damage IS NOT NULL);

INSERT INTO encanteri (ID_encanteri, radi_efecte)
    (SELECT c.ID_carta, ct.radious 
    FROM carta AS c JOIN cards_tmp AS ct
    ON c.nom_carta = ct.name_card
    WHERE ct.radious IS NOT NULL);


-- Taula Nivell -------------------------------------------------------------------------------------
INSERT INTO nivell (num_nivell, multiplicador_estadistiques, cost_or_seguent_nivell, recompensa_xp)
    (SELECT DISTINCT level_card, 0.0, 0, 0 
    FROM players_cards_tmp
    ORDER BY level_card);

UPDATE nivell 
    SET multiplicador_estadistiques = nivell_tmp.multiplicador_estadistiques,
    cost_or_seguent_nivell = nivell_tmp.cost_or_seguent_nivell,
    recompensa_xp = nivell_tmp.recompensa_xp
    FROM nivell_tmp
    WHERE num_nivell = nivell_tmp.id_aux;


-- Taula Cartes Jugador -----------------------------------------------------------------------------
INSERT INTO cartes_jugador (ID_jugador, ID_carta, nivell, num_cartes, data_obtencio)
    (SELECT id_player, id_card, level_card, amount, date_obtained
    FROM players_cards_tmp);


-- Taula Es Amic De --------------------------------------------------------------------------------
INSERT INTO es_amic_de (ID_jugador1, ID_jugador2)
    (SELECT requester, requested FROM friends_tmp);


-- Clan ---------------------------------------------------------------------------------------------
--Aqui si que tendremos que generar un SERIAL auxiliar
ALTER TABLE clan
ADD COLUMN id_aux SERIAL;

INSERT INTO clan (ID_clan, nom_clan, descripcio, puntuacio, trofeus, num_jugadors, trofeus_min)
    (SELECT tag, name_clan, descripcion, trophies, score, 0, required_trophies
    FROM clans_tmp);

UPDATE clan 
    SET or_donacions = clan2_tmp.or_donacions
    FROM clan2_tmp
    WHERE id_aux = clan2_tmp.id;

ALTER TABLE clan 
DROP COLUMN id_aux;


-- Rol ---------------------------------------------------------------------------------------------
INSERT INTO rol (nom_rol, descripcio)
    (SELECT DISTINCT SPLIT_PART(player_role, ': ', 1), SPLIT_PART(player_role, ': ', 2) 
    FROM players_clans_tmp);


-- jugador_clan ------------------------------------------------------------------------------------
INSERT INTO jugador_clan (ID_jugador, ID_clan, nom_rol, data_in)
    (SELECT player, clan, SPLIT_PART(player_role, ': ', 1), date_in FROM players_clans_tmp);

UPDATE clan
    SET num_jugadors = (SELECT COUNT(ID_jugador) FROM jugador_clan WHERE clan.ID_clan = jugador_clan.ID_clan)
    FROM jugador_clan
    WHERE clan.ID_clan = jugador_clan.ID_clan;


-- dona_gold_a_clan ------------------------------------------------------------------------------------
INSERT INTO dona_gold_a_clan (ID_jugador, ID_clan, quantitat_gold, data_donacio)
    (SELECT player, clan, gold, donation_date FROM players_clans_donations_tmp);


-- modificador ----------------------------------------------------------------------------------------
INSERT INTO modificador (nom_modificador, cost_or, descripcio, dany_extra, velocitat_atac_extra, radi_atac_extra,temps_vida_extra, dany_aparicio_extra)
    (SELECT building, cost, descripcion, mod_damage, mod_hit_speed, mod_radius, mod_lifetime, mod_spawn_damage FROM buildings_tmp);

INSERT INTO modificador (nom_modificador, cost_or, descripcio, dany_extra, velocitat_atac_extra, radi_atac_extra,temps_vida_extra, dany_aparicio_extra)
    (SELECT technology, cost, descripcion, mod_damage, mod_hit_speed, mod_radius, mod_lifetime, mod_spawn_damage FROM technologies_tmp);


-- estructura ----------------------------------------------------------------------------------------
INSERT INTO estructura (nom_estructura, num_min_trofeus)
    (SELECT building, trophies FROM buildings_tmp);


-- tecnologia ----------------------------------------------------------------------------------------
INSERT INTO tecnologia ( nom_tecnologia, nivell_maxim )
    (SELECT technology, max_level FROM technologies_tmp);


-- requeriment_estructura ----------------------------------------------------------------------------
INSERT INTO requeriment_estructura (nom_estructura, nom_estructura_requerida)
    (SELECT building, prerequisite FROM buildings_tmp WHERE prerequisite IS NOT NULL);


-- requeriment_tecnologia ----------------------------------------------------------------------------
INSERT INTO requeriment_tecnologia (nom_tecnologia, nom_tecnologia_requerida, nivell_tecnologia_requerida)
    (SELECT technology, prerequisite, prereq_level FROM technologies_tmp WHERE prerequisite IS NOT NULL);


-- modificadors_clan ----------------------------------------------------------------------------
INSERT INTO modificadors_clan (ID_clan, nom_modificador, data_obtencio, nivell_modificador)
    (SELECT clan, tech, date_obtained, level_structure FROM clan_tech_structures_tmp WHERE tech IS NOT NULL);

INSERT INTO modificadors_clan (ID_clan, nom_modificador, data_obtencio, nivell_modificador)
    (SELECT clan, structure, date_obtained, level_structure FROM clan_tech_structures_tmp WHERE structure IS NOT NULL);


-- batalla_clan -----------------------------------------------------------------------------------
INSERT INTO batalla_clan (ID_batalla_clan, data_inici, data_final)
    (SELECT DISTINCT battle, start_date, end_date FROM clan_battles_tmp
    ORDER BY battle ASC);


-- missatge -----------------------------------------------------------------------------------------
-- messages_to_clans i messages_to_players tenen IDs repetits (els dos son missatge, i han de tenir PKs diferents)
--  per tant, no tindrem en compte l'ID dels csv i crearem un id nou per cada missatge
CREATE TABLE msg_aux (
    id SERIAL,
    sender TEXT,
    receiver TEXT,
    msg TEXT,
    fecha DATE,
    answer INT,
    es_clan INT
);

INSERT INTO msg_aux (sender, receiver, msg, fecha, answer, es_clan)
    (SELECT sender, receiver, message_text, date_sent, answer, 0 FROM messages_between_players_tmp);

WITH constants (num_messages_between_players) AS (
    SELECT COUNT(*) FROM messages_between_players_tmp
)
INSERT INTO msg_aux (sender, receiver, msg, fecha, answer, es_clan)
    (SELECT sender, receiver, message_text, date_sent, (answer + num_messages_between_players), 1 FROM messages_to_clans_tmp, constants);   

INSERT INTO missatge (ID_missatge, text_missatge, data_enviat, ID_missatge_respos)
    (SELECT id, msg, fecha, answer FROM msg_aux);

INSERT INTO missatges_jugadors (ID_missatge, ID_emissor, ID_receptor)
    (SELECT id, sender, receiver FROM msg_aux WHERE es_clan = 0 );

INSERT INTO missatges_clans (ID_missatge, ID_emissor, ID_clan)
    (SELECT id, sender, receiver FROM msg_aux WHERE es_clan = 1 );

DROP TABLE msg_aux;


-- insignia -----------------------------------------------------------------------------------------
INSERT INTO insignia (titol_insignia, imatge)
    (SELECT DISTINCT badge_name, badge_img FROM players_badge_tmp);


-- insignia_arena -----------------------------------------------------------------------------------------
INSERT INTO insignia_arena (titol_insignia, arena_necessaria)
    (SELECT DISTINCT badge_name, id_arena FROM players_badge_tmp);


-- insignies_jugadors -------------------------------------------------------------------------------
INSERT INTO insignies_jugadors (ID_jugador, titol_insignia, data_obtencio)
    (SELECT id_player, badge_name, date_obtained FROM players_badge_tmp);


-- insignies_clans -------------------------------------------------------------------------------
-- No se'ns dona la informacio, i tampoc es gaire rellevant. Fem uns quants inserts de forma manual.
INSERT INTO insignies_clans (ID_clan, titol_insignia, data_obtencio)
VALUES ('#8LGRYC', 'Classic12Wins', '2020-04-29');

INSERT INTO insignies_clans (ID_clan, titol_insignia, data_obtencio)
VALUES ('#2CQQVQCU', 'LadderTournamentTop1000_3', '2020-04-14');

INSERT INTO insignies_clans (ID_clan, titol_insignia, data_obtencio)
VALUES ('#QCJ0J9UP', 'Played5Years', '2020-09-26');

INSERT INTO insignies_clans (ID_clan, titol_insignia, data_obtencio)
VALUES ('#9QY9JG09', 'LadderTop1000_2', '2020-04-21');

INSERT INTO insignies_clans (ID_clan, titol_insignia, data_obtencio)
VALUES ('#9GUCJRL0', 'Played1Year', '2020-10-21');


-- batalla ------------------------------------------------------------------------------------------
INSERT INTO batalla (ID_batalla, data_batalla, durada_batalla, trofeus_guanyador, trofeus_perdedor, ID_batalla_clan)
  (SELECT id, date_battle, duration, winner_score, loser_score, clan_battle FROM battles_tmp);


-- pila ----------------------------------------------------------------------------------------------
INSERT INTO pila ( ID_pila, nom_pila, ID_jugador, data_creacio, descripcio)
    (SELECT DISTINCT deck, title, player, creation_date, description FROM players_deck_tmp);

INSERT INTO cartes_pila (ID_pila, ID_carta)
    (SELECT deck, id_card FROM players_deck_tmp);

INSERT INTO pila_compartida (ID_pila, ID_jugador_receptor)
    (SELECT deck, player FROM shared_decks_tmp);

INSERT INTO piles_batalla (ID_batalla, ID_pila_guanyadora, ID_pila_perdedora)
    (SELECT id, winner, loser FROM battles_tmp);


-- temporada -----------------------------------------------------------------------------------------
INSERT INTO temporada ( nom_temporada, data_inici, data_final)
    (SELECT name, start_date, end_date FROM seasons_tmp );


-- Assoliment -------------------------------------------------------------------------------------------
INSERT INTO assoliment (titol_assoliment, recompensa_gemmes, condicions)
    (SELECT DISTINCT achievement_name, gems_obtained, achievement_description FROM players_achievements_tmp);

INSERT INTO assoliment_arena (ID_assoliment, ID_arena)
    (SELECT DISTINCT (SELECT ID_assoliment FROM assoliment WHERE titol_assoliment = achievement_name AND condicions = achievement_description), 
    id_arena FROM players_achievements_tmp);

INSERT INTO jugador_assoliment (ID_jugador, ID_assoliment, data_aconseguit)
    (SELECT id_player, (SELECT ID_assoliment FROM assoliment WHERE titol_assoliment = achievement_name AND condicions = achievement_description), 
    date_obtained FROM players_achievements_tmp);



-- Targeta de Credit ------------------------------------------------------------------------------------
  INSERT INTO targeta_credit (num_targeta, data_caducitat)
    (SELECT player_cardnumber, player_card_expiry FROM players_tmp);

  INSERT INTO targeta_credit_jugador (num_targeta, ID_jugador)
      (SELECT player_cardnumber, id_player FROM players_tmp);


-- producte ----------------------------------------------------------------------------------------------
CREATE TABLE products_aux (
    id_product SERIAL PRIMARY KEY,
    buy_cost FLOAT,
    buy_stock INT,
    arenapack_id INT,
    chest_name TEXT,
    chest_rarity TEXT,
    chest_unlock_time INT,
    chest_num_cards INT,
    bundle_gold INT,
    bundle_gems INT,
    emote_name TEXT,
    emote_path TEXT,
    amount_gold INT,
    amount_gems INT
);

-- Agafem el buy_cost i buy_stock maxim d'un producte (el mateix producte quan es repeteix no te la mateixa informacio...) 
--  i, per tal de que els IDs de producte siguin unics, ajuntem tots els productes a la taula auxiliar products_aux.
-- Despres ja passarem la informacio de la taula auxiliar cap a la taula producte i les seves subentitats (paquet_arena, cofre...)
INSERT INTO products_aux (buy_cost, buy_stock, arenapack_id)
    (SELECT MAX(buy_cost), MAX(buy_stock), arenapack_id FROM player_purchases_tmp WHERE arenapack_id IS NOT NULL GROUP BY arenapack_id);

INSERT INTO products_aux (buy_cost, buy_stock, chest_name, chest_rarity, chest_unlock_time, chest_num_cards)
    (SELECT MAX(buy_cost), MAX(buy_stock), chest_name, chest_rarity, chest_unlock_time, chest_num_cards FROM player_purchases_tmp WHERE chest_name IS NOT NULL GROUP BY chest_name, chest_rarity, chest_unlock_time, chest_num_cards);

INSERT INTO products_aux (buy_cost, buy_stock, bundle_gold, bundle_gems)
    (SELECT MAX(buy_cost), MAX(buy_stock), bundle_gold, bundle_gems FROM player_purchases_tmp WHERE bundle_gold IS NOT NULL GROUP BY bundle_gold, bundle_gems);

INSERT INTO products_aux (buy_cost, buy_stock, emote_name, emote_path)
    (SELECT MAX(buy_cost), MAX(buy_stock), emote_name, emote_path FROM player_purchases_tmp WHERE emote_name IS NOT NULL GROUP BY emote_name, emote_path);

-- Generem uns quants productes Gold i Gemes de forma manual
INSERT INTO products_aux (buy_cost, buy_stock, amount_gold) VALUES (250, 50, 10000);
INSERT INTO products_aux (buy_cost, buy_stock, amount_gold) VALUES (500, 20, 30000);
INSERT INTO products_aux (buy_cost, buy_stock, amount_gold) VALUES (1000, 10, 80000);
INSERT INTO products_aux (buy_cost, buy_stock, amount_gems) VALUES (4.99, 25, 500);
INSERT INTO products_aux (buy_cost, buy_stock, amount_gems) VALUES (9.99, 50, 1000);
INSERT INTO products_aux (buy_cost, buy_stock, amount_gems) VALUES (49.99, 10, 2000);


INSERT INTO producte (ID_producte, quantitat_max)
    (SELECT id_product, buy_stock FROM products_aux); -- descompte_actual de producte sempre sera 0 (no cal modificar-lo)

INSERT INTO bundle (ID_bundle, preu_diners, recompensa_gold, recompensa_gemmes)
    (SELECT id_product, CAST(buy_cost AS NUMERIC), bundle_gold, bundle_gems FROM products_aux WHERE bundle_gold IS NOT NULL);

INSERT INTO gemmes (ID_gemmes, preu_diners, quantitat_gemmes)
    (SELECT id_product, CAST(buy_cost AS NUMERIC), amount_gems FROM products_aux WHERE amount_gems IS NOT NULL);

-- Ojo amb paquet_arena! El csv que se'ns dona no esta be.
-- Eliminem totes les files de arena_pack_tmp les quals l'id_arena_pack no estigui en products_aux.
-- (arena_pack es un producte i, per tant, ignorem totes les files del csv arena_pack que no continguin un ID d'un arena_pack
--   que estigui com a producte)
DELETE FROM arena_pack_tmp WHERE id_arena_pack NOT IN (SELECT arenapack_id FROM products_aux WHERE arenapack_id IS NOT NULL);
INSERT INTO paquet_arena (ID_paquet, preu_diners, ID_paquet_arena)
    (SELECT id_product, CAST(buy_cost AS NUMERIC), arenapack_id FROM products_aux WHERE arenapack_id IS NOT NULL);
INSERT INTO recompensa_paquet_arena (ID_paquet, ID_arena, recompensa_gold)
    (SELECT (SELECT paquet_arena.ID_paquet FROM paquet_arena WHERE paquet_arena.ID_paquet_arena = arena_pack_tmp.id_arena_pack), arena, gold FROM arena_pack_tmp);

INSERT INTO gold (ID_gold, preu_gemmes, quantitat_gold)
    (SELECT id_product, CAST(buy_cost AS INT), amount_gold FROM products_aux WHERE amount_gold IS NOT NULL);

INSERT INTO emoticona (ID_emoticona, preu_gold, nom_emoticona, ruta_emoticona)
    (SELECT id_product, CAST(buy_cost AS INT), emote_name, emote_path FROM products_aux WHERE emote_name IS NOT NULL);
UPDATE emoticona SET ruta_emoticona = 'sfx/emotes/default.ogg' WHERE ruta_emoticona IS NULL;

INSERT INTO cofre (ID_cofre, nom_cofre, preu_gold, temps_desbloqueig, num_cartes, nom_raresa)
    (SELECT id_product, chest_name, CAST(buy_cost AS INT), chest_unlock_time, chest_num_cards, chest_rarity FROM products_aux WHERE chest_name IS NOT NULL);

    
-- Cofre Desbloqueig ------------------------------------------------------------------------------------
-- Com que no tenim csv amb aquesta informacio, generarem dades random
INSERT INTO cofre_desbloqueig (ID_jugador, ID_cofre)
    (SELECT ID_jugador, ID_cofre FROM jugador CROSS JOIN cofre ORDER BY RANDOM() LIMIT 20);


-- Recompensa -------------------------------------------------------------------------------------------
INSERT INTO recompensa (num_trofeus, ID_producte_recompensa)
    (SELECT trofeus, ID_producte FROM jugador CROSS JOIN producte ORDER BY RANDOM() LIMIT 20);


-- Jugador Recompensa -----------------------------------------------------------------------------------
INSERT INTO jugador_recompensa
    (SELECT ID_jugador, ID_recompensa FROM jugador CROSS JOIN recompensa ORDER BY RANDOM() LIMIT 50);


-- Compra -----------------------------------------------------------------------------------------------
INSERT INTO compra (data_compra, ID_jugador, ID_producte, descompte, num_targeta)
    (SELECT date_purchase, player_id, 
    (SELECT id_product FROM products_aux WHERE products_aux.arenapack_id = player_purchases_tmp.arenapack_id 
        OR products_aux.chest_name = player_purchases_tmp.chest_name OR (products_aux.bundle_gold = player_purchases_tmp.bundle_gold
        AND products_aux.bundle_gems = player_purchases_tmp.bundle_gems) OR products_aux.emote_name = player_purchases_tmp.emote_name),
    discount, credit_card
    FROM player_purchases_tmp);


-- Missio ------------------------------------------------------------------------------------------------
INSERT INTO missio (ID_missio, titol, descripcio, tasques, missio_requerida)
    (SELECT DISTINCT quest_id, quest_title, quest_description, quest_requirement, quest_depends FROM players_quests_tmp);

INSERT INTO recompensa_missio (ID_missio, ID_arena, recompensa_xp, recompensa_gold)
    (SELECT quest_id, arena_id, experience, gold FROM quests_arenas_tmp);

INSERT INTO missions_jugadors (ID_jugador, ID_missio, data_completada)
    (SELECT player_tag, quest_id, unlock FROM players_quests_tmp);


-- competicio_clans ----------------------------------------------------------------------------------
INSERT INTO competicio_clans (ID_clan, ID_batalla_clan, puntuacio)
  (SELECT clan, battle, (SELECT SUM(b.trofeus_guanyador)
  FROM clan AS c 
  INNER JOIN jugador_clan AS jc ON jc.ID_clan = c.ID_clan
  INNER JOIN jugador AS j ON j.ID_jugador = jc.ID_jugador
  INNER JOIN pila AS p ON p.ID_jugador = j.ID_jugador
  INNER JOIN piles_batalla AS pb ON pb.ID_pila_guanyadora = p.ID_pila
  INNER JOIN batalla AS b ON b.ID_batalla = pb.ID_batalla
  WHERE clan = c.ID_clan AND b.ID_batalla_clan = battle)
   FROM clan_battles_tmp ORDER BY clan);


---------------------------------------------------------------------------------------------------------




-- Actualitzacions Triggers -----------------------------------------------------------------------------
INSERT INTO paraules_ofensives (paraula) VALUES ('cabron'), ('maricon'), ('inutil'), 
    ('puta'), ('gordo'), ('mierda'), ('subnormal');

UPDATE arena
SET multiplicador_missio = trunc((random() * 1 + 1)::NUMERIC, 1);

UPDATE missio
SET recompensa_experiencia = floor(random() * (8000-2000)) + 2000;

UPDATE missio
SET recompensa_or = floor(random() * (300-10)) + 10;
---------------------------------------------------------------------------------------------------------




-- DROP ALL TEMPORARY TABLES -----------------------------------
DROP TABLE arena_pack_tmp;
DROP TABLE arenas_tmp;
DROP TABLE battles_tmp;
DROP TABLE buildings_tmp;
DROP TABLE cards_tmp;
DROP TABLE clan_battles_tmp;
DROP TABLE clan_tech_structures_tmp;
DROP TABLE clans_tmp;
DROP TABLE friends_tmp;
DROP TABLE messages_between_players_tmp;
DROP TABLE messages_to_clans_tmp;
DROP TABLE player_purchases_tmp;
DROP TABLE players_quests_tmp;
DROP TABLE players_tmp;
DROP TABLE players_achievements_tmp;
DROP TABLE players_badge_tmp;
DROP TABLE players_cards_tmp;
DROP TABLE players_clans_tmp;
DROP TABLE players_clans_donations_tmp;
DROP TABLE players_deck_tmp;
DROP TABLE quests_arenas_tmp;
DROP TABLE seasons_tmp;
DROP TABLE shared_decks_tmp;
DROP TABLE technologies_tmp;

DROP TABLE gold_gemmes_tmp;
DROP TABLE nivell_tmp;
DROP TABLE clan2_tmp;

DROP TABLE products_aux;
----------------------------------------------------------------