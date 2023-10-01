-- Set2.sql
-- BBDD Projecte Clash Sayale - Grup 10
-- Modul 2 Jugador - No soc un jugador, soc un jugador de videojocs
-- Fase 4 - Triggers

-- 2.1. Proces de Compra
DROP FUNCTION IF EXISTS proces_compra_trigger cascade;
CREATE OR REPLACE FUNCTION proces_compra_trigger() 
RETURNS trigger 
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF NEW.ID_producte IN (SELECT ID_bundle FROM bundle) THEN
        UPDATE jugador SET
        gold = gold + (SELECT recompensa_gold FROM bundle WHERE ID_bundle = NEW.ID_producte),
        gemmes = gemmes + (SELECT recompensa_gemmes FROM bundle WHERE ID_bundle = NEW.ID_producte)
        WHERE jugador.ID_jugador = NEW.ID_jugador;
    ELSIF NEW.ID_producte IN (SELECT ID_gemmes FROM gemmes) THEN
        UPDATE jugador SET
        gemmes = gemmes + (SELECT quantitat_gemmes FROM gemmes WHERE ID_gemmes = NEW.ID_producte)
        WHERE jugador.ID_jugador = NEW.ID_jugador;
    ELSIF NEW.ID_producte IN (SELECT ID_gold FROM gold) THEN
        UPDATE jugador SET
        gold = gold + (SELECT quantitat_gold FROM gold WHERE ID_gold = NEW.ID_producte)
        WHERE jugador.ID_jugador = NEW.ID_jugador;
    ELSIF NEW.ID_producte IN (SELECT ID_cofre FROM cofre) THEN
        INSERT INTO cofre_desbloqueig (ID_jugador, ID_cofre)
        VALUES (NEW.ID_jugador, NEW.ID_producte);
    ELSIF NEW.ID_producte IN (SELECT ID_paquet FROM paquet_arena) THEN
        UPDATE jugador SET
        gold = gold + 
            (SELECT recompensa_gold FROM recompensa_paquet_arena
            WHERE ID_paquet = NEW.ID_producte
            AND ID_arena IN (SELECT ID_arena FROM jugadors_arena WHERE ID_jugador = NEW.ID_jugador)
            ORDER BY recompensa_gold DESC
            LIMIT 1)
        WHERE jugador.ID_jugador = NEW.ID_jugador;
    END IF;

    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS proces_compra ON compra;
CREATE OR REPLACE TRIGGER proces_compra AFTER INSERT ON compra
FOR EACH ROW 
    EXECUTE FUNCTION proces_compra_trigger();




-- 2.2. Jugadors Prohibits
-- (la taula ja esta creada en el model fisic, i el insert en la importacio)
DROP TABLE IF EXISTS paraules_ofensives;
CREATE TABLE paraules_ofensives (
    ID_paraula SERIAL PRIMARY KEY,
    paraula TEXT NOT NULL
);
INSERT INTO paraules_ofensives (paraula) VALUES ('cabron'), ('maricon'), ('inutil'), 
    ('puta'), ('gordo'), ('mierda'), ('subnormal'); --List should be increased in a real implementation


DROP FUNCTION IF EXISTS comprovar_misssatge_ofensiu_trigger cascade;
CREATE OR REPLACE FUNCTION comprovar_misssatge_ofensiu_trigger() 
RETURNS trigger 
LANGUAGE PLPGSQL
AS $$
DECLARE
    paraules_ofensives TEXT[];
    missatge TEXT;
BEGIN
    missatge = (SELECT text_missatge FROM missatge WHERE ID_missatge = NEW.ID_missatge);
    paraules_ofensives = (SELECT array_agg(paraula::TEXT) FROM paraules_ofensives WHERE missatge LIKE '%' || paraula || '%');

    IF array_length(paraules_ofensives, 1) > 0 THEN
        UPDATE jugador SET nom = '_banned_' || nom
        WHERE ID_jugador = NEW.ID_emissor;

        IF NEW.ID_missatge IN (SELECT ID_missatge FROM missatges_jugadors) THEN
            INSERT INTO Warnings (affected_table, error_message, date, user_name)
            VALUES ('missatges_jugadors', 'Missatge d''odi enviat amb paraula/s ' || array_to_string(paraules_ofensives, ', ') || 
            ' a l''usuari ' || NEW.ID_receptor, (SELECT CURRENT_DATE), NEW.ID_emissor);

        ELSIF NEW.ID_missatge IN (SELECT ID_missatge FROM missatges_clans) THEN
            INSERT INTO Warnings (affected_table, error_message, date, user_name)
            VALUES ('missatges_clans', 'Missatge d''odi enviat amb paraula/s ' || array_to_string(paraules_ofensives, ', ') || 
            ' al clan ' || NEW.ID_clan, (SELECT CURRENT_DATE), NEW.ID_emissor);
        END IF;
    END IF;

    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS comprovar_misssatge_jugadors_ofensiu ON missatges_jugadors;
CREATE OR REPLACE TRIGGER comprovar_misssatge_jugadors_ofensiu AFTER INSERT ON missatges_jugadors
FOR EACH ROW 
    EXECUTE FUNCTION comprovar_misssatge_ofensiu_trigger();

DROP TRIGGER IF EXISTS comprovar_misssatge_clans_ofensiu ON missatges_clans;
CREATE OR REPLACE TRIGGER comprovar_misssatge_clans_ofensiu AFTER INSERT ON missatges_clans
FOR EACH ROW 
    EXECUTE FUNCTION comprovar_misssatge_ofensiu_trigger();




-- 2.3. Final de Temporada
-- (la taula ja esta creada en el model fisic)
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


DROP FUNCTION IF EXISTS final_temporada_trigger cascade;
CREATE OR REPLACE FUNCTION final_temporada_trigger() 
RETURNS trigger 
LANGUAGE PLPGSQL
AS $$
DECLARE
    jugador_tmp TEXT;
    nom_temporada TEXT = (SELECT nom_temporada FROM temporada WHERE data_final = NEW.data_inici - 1);
    inici_temporada DATE = (SELECT data_inici FROM temporada WHERE data_final = NEW.data_inici - 1);
    final_temporada DATE = (SELECT data_final FROM temporada WHERE data_final = NEW.data_inici - 1);
BEGIN
    IF nom_temporada IS NOT NULL THEN
        FOR jugador_tmp IN SELECT ID_jugador FROM jugador
        LOOP
            INSERT INTO ranquing (ID_jugador, ID_temporada, arena_classificat, num_trofeus)
            VALUES (jugador_tmp, nom_temporada, (SELECT ID_arena FROM arena ORDER BY max_trofeus LIMIT 1),
                (SELECT SUM(trofeus_guanyador) 
                FROM batalla AS b
                INNER JOIN piles_batalla AS pb ON pb.ID_batalla = b.ID_batalla
                INNER JOIN pila AS p ON p.ID_pila = pb.ID_pila_guanyadora
                WHERE p.ID_jugador = jugador_tmp
                AND b.data_batalla >= inici_temporada AND b.data_batalla <= final_temporada
                ) - 
                (SELECT ABS(SUM(trofeus_perdedor))
                FROM batalla AS b
                INNER JOIN piles_batalla AS pb ON pb.ID_batalla = b.ID_batalla
                INNER JOIN pila AS p ON p.ID_pila = pb.ID_pila_perdedora
                WHERE p.ID_jugador = jugador_tmp
                AND b.data_batalla >= inici_temporada AND b.data_batalla <= final_temporada
                ));
            
            IF (SELECT num_trofeus FROM ranquing 
                WHERE ID_jugador = jugador_tmp AND ID_temporada = nom_temporada) IS NULL THEN
                UPDATE ranquing SET num_trofeus = 0 
                WHERE ID_jugador = jugador_tmp AND ID_temporada = nom_temporada;
            END IF;
        END LOOP;
    END IF;

    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS final_temporada ON temporada;
CREATE OR REPLACE TRIGGER final_temporada AFTER INSERT ON temporada
FOR EACH ROW 
    EXECUTE FUNCTION final_temporada_trigger();