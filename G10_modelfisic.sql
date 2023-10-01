-- Implementacio del Model Fisic
-- BBDD Projecte Clash Sayale - Fase 2
--------------------------------------
-- Grup 10
-- Alex Cano, Biel Carpi, Rafael Morera, Eduard Santos

--DROP DATABASE clashsayale IF EXISTS;
--CREATE DATABASE clashsayale;
--USE DATABASE clashsayale;


DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


CREATE TABLE jugador (
    ID_jugador TEXT PRIMARY KEY,
    nom TEXT NOT NULL,
    experiencia INT DEFAULT 0,
    gold INT DEFAULT 0,
    gemmes INT DEFAULT 0,
    trofeus INT DEFAULT 0
);


CREATE TABLE arena (
    ID_arena SERIAL PRIMARY KEY,
    nom_arena TEXT NOT NULL,
    min_trofeus INT NOT NULL,
    max_trofeus INT NOT NULL,
    multiplicador_missio NUMERIC
);

CREATE TABLE jugadors_arena (
    ID_jugador TEXT,
    ID_arena INT,
    PRIMARY KEY (ID_jugador, ID_arena),
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_arena)
        REFERENCES arena (ID_arena)
);


CREATE TABLE raresa (
    nom_raresa TEXT PRIMARY KEY,
    multiplicador_or_nivell FLOAT NOT NULL, --Multiplica la quantitat d'or que cal per pujar una carta d'aquesta raresa de nivell
    percentatge_aparicio FLOAT NOT NULL
);


CREATE TABLE carta (
    ID_carta SERIAL PRIMARY KEY,
    nom_carta TEXT NOT NULL,
    dany NUMERIC NOT NULL,
    velocitat_atac NUMERIC NOT NULL,
    nom_raresa TEXT NOT NULL,
    arena_necessaria INT NOT NULL,
    FOREIGN KEY (nom_raresa)
        REFERENCES raresa (nom_raresa),
    FOREIGN KEY (arena_necessaria)
        REFERENCES arena (ID_arena)
);

CREATE TABLE edifici (
    ID_edifici INT PRIMARY KEY,
    vida NUMERIC NOT NULL,
    FOREIGN KEY (ID_edifici)
        REFERENCES carta (ID_carta)
);

CREATE TABLE tropa (
    ID_tropa INT PRIMARY KEY,
    dany_aparicio NUMERIC NOT NULL,
    FOREIGN KEY (ID_tropa)
        REFERENCES carta (ID_carta)
);

CREATE TABLE encanteri (
    ID_encanteri INT PRIMARY KEY,
    radi_efecte NUMERIC NOT NULL,
    FOREIGN KEY (ID_encanteri)
        REFERENCES carta (ID_carta)
);


CREATE TABLE nivell (
    num_nivell SERIAL PRIMARY KEY,
    multiplicador_estadistiques FLOAT NOT NULL,
    cost_or_seguent_nivell INT NOT NULL,
    recompensa_xp INT NOT NULL
);


CREATE TABLE cartes_jugador (
    ID_jugador TEXT,
    ID_carta INT,
    PRIMARY KEY (ID_jugador, ID_carta),
    nivell INT NOT NULL,
    num_cartes INT NOT NULL,
    data_obtencio DATE NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_carta)
        REFERENCES carta (ID_carta),
    FOREIGN KEY (nivell)
        REFERENCES nivell (num_nivell)
);


CREATE TABLE es_amic_de (
    ID_jugador1 TEXT NOT NULL,
    ID_jugador2 TEXT NOT NULL,
    PRIMARY KEY (ID_jugador1, ID_jugador2),
    FOREIGN KEY (ID_jugador1)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_jugador2)
        REFERENCES jugador (ID_jugador)
);


CREATE TABLE clan (
    ID_clan TEXT PRIMARY KEY,
    nom_clan TEXT NOT NULL,
    descripcio TEXT NOT NULL,
    puntuacio INT NOT NULL,
    trofeus INT NOT NULL,
    num_jugadors INT NOT NULL,
    trofeus_min INT NOT NULL,
    or_donacions INT DEFAULT 0
);

CREATE TABLE rol (
    nom_rol TEXT PRIMARY KEY,
    descripcio TEXT NOT NULL
);

CREATE TABLE jugador_clan (
    ID_jugador TEXT,
    ID_clan TEXT,
    PRIMARY KEY (ID_jugador, ID_clan),
    nom_rol TEXT NOT NULL,
    data_in DATE NOT NULL,
    data_out DATE,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan),
    FOREIGN KEY (nom_rol)
        REFERENCES rol (nom_rol)
);

CREATE TABLE dona_gold_a_clan (
    ID_donacio SERIAL PRIMARY KEY,
    ID_jugador TEXT NOT NULL,
    ID_clan TEXT NOT NULL,
    quantitat_gold INT NOT NULL,
    data_donacio DATE NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan)
);


CREATE TABLE modificador (
    nom_modificador TEXT PRIMARY KEY,
    cost_or INT NOT NULL,
    descripcio TEXT NOT NULL,
    dany_extra INT,
    velocitat_atac_extra INT,
    radi_atac_extra INT,
    temps_vida_extra INT,
    dany_aparicio_extra INT
);


CREATE TABLE estructura (
    nom_estructura TEXT PRIMARY KEY,
    num_min_trofeus INT NOT NULL,
    FOREIGN KEY (nom_estructura)
        REFERENCES modificador (nom_modificador)
);

CREATE TABLE tecnologia (
    nom_tecnologia TEXT PRIMARY KEY,
    nivell_maxim INT NOT NULL,
    FOREIGN KEY (nom_tecnologia)
        REFERENCES modificador (nom_modificador)
);

CREATE TABLE requeriment_estructura (
    nom_estructura TEXT,
    nom_estructura_requerida TEXT,
    PRIMARY KEY (nom_estructura, nom_estructura_requerida),
    FOREIGN KEY (nom_estructura)
        REFERENCES estructura (nom_estructura),
    FOREIGN KEY (nom_estructura_requerida)
        REFERENCES estructura (nom_estructura)
);

CREATE TABLE requeriment_tecnologia (
    nom_tecnologia TEXT,
    nom_tecnologia_requerida TEXT,
    PRIMARY KEY (nom_tecnologia, nom_tecnologia_requerida),
    nivell_tecnologia_requerida INT DEFAULT 1,
    FOREIGN KEY (nom_tecnologia)
        REFERENCES tecnologia (nom_tecnologia),
    FOREIGN KEY (nom_tecnologia_requerida)
        REFERENCES tecnologia (nom_tecnologia)
);

CREATE TABLE modificadors_clan (
    ID_clan TEXT,
    nom_modificador TEXT,
    PRIMARY KEY (ID_clan, nom_modificador),
    data_obtencio DATE NOT NULL,
    nivell_modificador INT NOT NULL,
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan),
    FOREIGN KEY (nom_modificador)
        REFERENCES modificador (nom_modificador)
);

CREATE TABLE modificador_afecta (
    nom_modificador TEXT,
    ID_carta INT,
    PRIMARY KEY (nom_modificador, ID_carta),
    FOREIGN KEY (nom_modificador)
        REFERENCES modificador (nom_modificador),
    FOREIGN KEY (ID_carta)
        REFERENCES carta (ID_carta)
);


CREATE TABLE batalla_clan (
    ID_batalla_clan INT PRIMARY KEY,
    data_inici DATE NOT NULL,
    data_final DATE NOT NULL
);

CREATE TABLE competicio_clans (
    ID_clan TEXT,
    ID_batalla_clan INT,
    PRIMARY KEY (ID_clan, ID_batalla_clan),
    puntuacio INT DEFAULT 0,
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan),
    FOREIGN KEY (ID_batalla_clan)
        REFERENCES batalla_clan (ID_batalla_clan)
); 


CREATE TABLE missatge (
    ID_missatge SERIAL PRIMARY KEY,
    text_missatge TEXT NOT NULL,
    data_enviat DATE NOT NULL,
    ID_missatge_respos INT,
    FOREIGN KEY (ID_missatge_respos)
        REFERENCES missatge (ID_missatge)
);

CREATE TABLE missatges_jugadors (
    ID_missatge INT PRIMARY KEY,
    ID_emissor TEXT NOT NULL,
    ID_receptor TEXT NOT NULL,
    FOREIGN KEY (ID_missatge)
        REFERENCES missatge (ID_missatge),
    FOREIGN KEY (ID_emissor)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_receptor)
        REFERENCES jugador (ID_jugador)
);

CREATE TABLE missatges_clans (
    ID_missatge INT PRIMARY KEY,
    ID_emissor TEXT NOT NULL,
    ID_clan TEXT NOT NULL,
    FOREIGN KEY (ID_missatge)
        REFERENCES missatge (ID_missatge),
    FOREIGN KEY (ID_emissor)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan)
);


CREATE TABLE insignia (
    titol_insignia TEXT PRIMARY KEY,
    imatge TEXT NOT NULL
);

CREATE TABLE insignia_arena (
    titol_insignia TEXT,
    arena_necessaria INT,
    PRIMARY KEY (titol_insignia, arena_necessaria),
    FOREIGN KEY (arena_necessaria)
        REFERENCES arena (ID_arena),
    FOREIGN KEY (titol_insignia)
        REFERENCES insignia (titol_insignia)
);

CREATE TABLE insignies_jugadors (
    ID_jugador TEXT,
    titol_insignia TEXT,
    PRIMARY KEY (ID_jugador, titol_insignia),
    data_obtencio DATE NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (titol_insignia)
        REFERENCES insignia (titol_insignia) 
);

CREATE TABLE insignies_clans (
    ID_clan TEXT,
    titol_insignia TEXT,
    PRIMARY KEY (ID_clan, titol_insignia),
    data_obtencio DATE NOT NULL,
    FOREIGN KEY (ID_clan)
        REFERENCES clan (ID_clan),
    FOREIGN KEY (titol_insignia)
        REFERENCES insignia (titol_insignia) 
);



CREATE TABLE temporada (
    nom_temporada TEXT PRIMARY KEY,
    data_inici DATE NOT NULL,
    data_final DATE NOT NULL
);

CREATE TABLE batalla (
    ID_batalla SERIAL PRIMARY KEY,
    data_batalla DATE NOT NULL,
    durada_batalla INTERVAL NOT NULL,
    recompensa_or INT DEFAULT 25,
    trofeus_guanyador INT NOT NULL,
    trofeus_perdedor INT NOT NULL,
    ID_batalla_clan INT,
    FOREIGN KEY (ID_batalla_clan)
        REFERENCES batalla_clan (ID_batalla_clan)
);


CREATE TABLE pila (
    ID_pila SERIAL PRIMARY KEY,
    nom_pila TEXT NOT NULL,
    ID_jugador TEXT NOT NULL,
    data_creacio DATE NOT NULL,
    descripcio TEXT NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador)
);

CREATE TABLE cartes_pila (
    ID_pila INT,
    ID_carta INT,
    PRIMARY KEY (ID_pila, ID_carta),
    FOREIGN KEY (ID_pila)
        REFERENCES pila (ID_pila),
    FOREIGN KEY (ID_carta)
        REFERENCES carta (ID_carta)
);

CREATE TABLE pila_compartida (
    ID_pila INT,
    ID_jugador_receptor TEXT,
    PRIMARY KEY (ID_pila, ID_jugador_receptor),
    FOREIGN KEY (ID_pila)
        REFERENCEs pila (ID_pila),
    FOREIGN KEY (ID_jugador_receptor)
        REFERENCES jugador (ID_jugador)
);

CREATE TABLE piles_batalla (
    ID_batalla INT PRIMARY KEY,
    ID_pila_guanyadora INT NOT NULL,
    ID_pila_perdedora INT NOT NULL,
    FOREIGN KEY (ID_batalla)
        REFERENCES batalla (ID_batalla),
    FOREIGN KEY (ID_pila_guanyadora)
        REFERENCES pila (ID_pila),
    FOREIGN KEY (ID_pila_perdedora)
        REFERENCES pila (ID_pila)
);


CREATE TABLE assoliment (
    ID_assoliment SERIAL PRIMARY KEY,
    titol_assoliment TEXT NOT NULL,
    recompensa_gemmes INT NOT NULL,
    condicions TEXT NOT NULL
);

CREATE TABLE assoliment_arena (
    ID_arena INT,
    ID_assoliment INT,
    PRIMARY KEY (ID_assoliment, ID_arena),
    FOREIGN KEY (ID_arena)
        REFERENCES arena (ID_arena),
    FOREIGN KEY (ID_assoliment)
        REFERENCES assoliment (ID_assoliment)
);

CREATE TABLE jugador_assoliment (
    ID_jugador TEXT,
    ID_assoliment INT,
    data_aconseguit DATE NOT NULL,
    PRIMARY KEY(ID_jugador, ID_assoliment),
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_assoliment)
        REFERENCES assoliment (ID_assoliment)
);


CREATE TABLE targeta_credit (
    num_targeta TEXT PRIMARY KEY,
    data_caducitat DATE NOT NULL
);


CREATE TABLE targeta_credit_jugador (
    num_targeta TEXT,
    ID_jugador TEXT,
    PRIMARY KEY (num_targeta, ID_jugador),
    FOREIGN KEY (num_targeta) 
        REFERENCES targeta_credit (num_targeta),
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador)
);


CREATE TABLE producte (
    ID_producte SERIAL PRIMARY KEY,
    quantitat_max INT DEFAULT 1,
    descompte_actual FLOAT DEFAULT 0
);


CREATE TABLE recompensa ( -- guanyar trofeus desbloqueja recompenses
    ID_recompensa SERIAL PRIMARY KEY,
    num_trofeus INT NOT NULL, 
    ID_producte_recompensa INT NOT NULL,
    FOREIGN KEY (ID_producte_recompensa)
        REFERENCES producte (ID_producte)
);

CREATE TABLE jugador_recompensa (
    ID_jugador TEXT,
    ID_recompensa INT,
    PRIMARY KEY (ID_jugador, ID_recompensa),
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_recompensa)
        REFERENCES recompensa (ID_recompensa)
);


CREATE TABLE compra (
    ID_compra SERIAL PRIMARY KEY,
    data_compra DATE NOT NULL,
    ID_jugador TEXT NOT NULL,
    ID_producte INT NOT NULL,
    quantitat INT DEFAULT 1,
    descompte FLOAT DEFAULT 0,
    num_targeta TEXT NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES  jugador (ID_jugador),
    FOREIGN KEY (ID_producte)
        REFERENCES producte (ID_producte),
    FOREIGN KEY (num_targeta)
        REFERENCES targeta_credit (num_targeta)
);


CREATE TABLE bundle (
    ID_bundle INT PRIMARY KEY,
    preu_diners NUMERIC NOT NULL,
    recompensa_gold INT NOT NULL,
    recompensa_gemmes INT NOT NULL,
    FOREIGN KEY (ID_bundle)
        REFERENCES producte (ID_producte)
);

CREATE TABLE gemmes (
    ID_gemmes INT PRIMARY KEY,
    preu_diners NUMERIC NOT NULL,
    quantitat_gemmes INT NOT NULL,
    FOREIGN KEY (ID_gemmes)
        REFERENCES producte (ID_producte)
);

CREATE TABLE paquet_arena (
    ID_paquet INT PRIMARY KEY,
    preu_diners NUMERIC NOT NULL,
    ID_paquet_arena INT UNIQUE NOT NULL,
    FOREIGN KEY (ID_paquet)
        REFERENCES producte (ID_producte)
);

CREATE TABLE gold (
    ID_gold INT PRIMARY KEY,
    preu_gemmes INT NOT NULL,
    quantitat_gold INT NOT NULL,
    FOREIGN KEY (ID_gold)
        REFERENCES producte (ID_producte)    
);

CREATE TABLE emoticona (
    ID_emoticona INT PRIMARY KEY,
    preu_gold INT NOT NULL,
    nom_emoticona TEXT NOT NULL,
    ruta_emoticona TEXT DEFAULT 'sfx/emotes/default.ogg',
    FOREIGN KEY (ID_emoticona)
        REFERENCES producte (ID_producte)
);

CREATE TABLE cofre (
    ID_cofre INT PRIMARY KEY,
    nom_cofre TEXT NOT NULL,
    preu_gold INT NOT NULL,
    temps_desbloqueig INT NOT NULL,
    cost_desbloqueig FLOAT DEFAULT 0.05, -- En gemmes/s
    num_cartes INT DEFAULT 10,
    recompensa_or INT DEFAULT 100,
    nom_raresa TEXT NOT NULL,
    FOREIGN KEY (nom_raresa)
        REFERENCES raresa (nom_raresa)
);


CREATE TABLE cofre_desbloqueig (
    ID_desbloqueig SERIAL PRIMARY KEY,
    ID_jugador TEXT NOT NULL,
    ID_cofre INT NOT NULL,
    temps_comencat_a_desbloquejar TIMESTAMP, --Si es null, vol dir que encara no s'ha comencat a desbloquejar
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_cofre)
        REFERENCES cofre (ID_cofre)
);


CREATE TABLE recompensa_paquet_arena (
    ID_paquet INT,
    ID_arena INT,
    PRIMARY KEY (ID_paquet, ID_arena),
    recompensa_gold INT NOT NULL,
    FOREIGN KEY (ID_paquet)
        REFERENCES paquet_arena (ID_paquet),
    FOREIGN KEY (ID_arena)
        REFERENCES arena (ID_arena)
);


CREATE TABLE missio (
    ID_missio SERIAL PRIMARY KEY,
    titol TEXT NOT NULL,
    descripcio TEXT NOT NULL,
    tasques TEXT NOT NULL,
    missio_requerida INT,
    ID_cofre_recompensa INT,
    recompensa_experiencia INT,
    recompensa_or INT,
    FOREIGN KEY (missio_requerida)
        REFERENCES missio (ID_missio),
    FOREIGN KEY (ID_cofre_recompensa)
        REFERENCES cofre (ID_cofre)
);

CREATE TABLE recompensa_missio (
    ID_missio INT,
    ID_arena INT,
    PRIMARY KEY (ID_missio, ID_arena),
    recompensa_xp INT NOT NULL,
    recompensa_gold INT NOT NULL,
    FOREIGN KEY (ID_missio)
        REFERENCES missio (ID_missio),
    FOREIGN KEY (ID_arena)
        REFERENCES arena (ID_arena)
);

CREATE TABLE missions_jugadors (
    ID_missions_jugador SERIAL PRIMARY KEY,
    ID_jugador TEXT NOT NULL,
    ID_missio INT NOT NULL,
    data_completada DATE NOT NULL,
    FOREIGN KEY (ID_jugador)
        REFERENCES jugador (ID_jugador),
    FOREIGN KEY (ID_missio)
        REFERENCES missio (ID_missio)
);



-- Noves Taules pels Triggers ----------------------------------------------------------------------
CREATE TABLE Warnings ( 
    affected_table VARCHAR(255),
    error_message VARCHAR(255),
    date DATE,
    user_name VARCHAR(255)
);

-- Trigger 1.3
CREATE TABLE OPCardBlackList (
    ID_carta INT PRIMARY KEY,
    date1 DATE NOT NULL,
    date2 DATE NOT NULL,
    FOREIGN KEY (ID_carta)
        REFERENCES carta (ID_carta)
);

-- Trigger 2.2
DROP TABLE IF EXISTS paraules_ofensives;
CREATE TABLE paraules_ofensives (
    ID_paraula SERIAL PRIMARY KEY,
    paraula TEXT NOT NULL
);

-- Trigger 2.3
DROP TABLE IF EXISTS ranquing;
CREATE TABLE ranquing (
    ID_jugador TEXT,
    ID_temporada TEXT,
    arena_classificat INT NOT NULL,
    num_trofeus INT,
    PRIMARY KEY (ID_jugador, ID_temporada),
    FOREIGN KEY (arena_classificat)
        REFERENCES arena (ID_arena)
);

