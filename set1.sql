
-- Set1.sql
-- BBDD Projecte Clash Sayale - Grup 10
-- Modul 1 Jugador - Les cartes són la guerra, disfressada d'esport
-- Fase 4 - Triggers

-- 1.1. Proporcions de rareses
CREATE OR REPLACE FUNCTION check_rarity_cards()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
    IF (((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Common' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer != 31) THEN 
        INSERT INTO warnings (affected_table, error_message, date, user_name)
        SELECT 'carta', CONCAT('Proporcions de raresa no respectades: Common la proporció actual és ', 
        ((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Common' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer,
        ' quan hauria de ser 31'), 
        CURRENT_DATE, CURRENT_USER;
        END IF;

    IF (((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Rare' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer != 26) THEN
        INSERT INTO warnings (affected_table, error_message, date, user_name)
        SELECT 'carta', CONCAT('Proporcions de raresa no respectades: Rare la proporció actual és ', 
        ((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Rare' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer,
        ' quan hauria de ser 26'), 
        CURRENT_DATE, CURRENT_USER;
        END IF;

    IF (((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Epic' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer != 23) THEN
        INSERT INTO warnings (affected_table, error_message, date, user_name)
        SELECT 'carta', CONCAT('Proporcions de raresa no respectades: Epic la proporció actual és ', 
        ((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Epic' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer,
        ' quan hauria de ser 23'), 
        CURRENT_DATE, CURRENT_USER;
        END IF;

    IF (((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Legendary' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer != 17) THEN
        INSERT INTO warnings (affected_table, error_message, date, user_name)
        SELECT 'carta', CONCAT('Proporcions de raresa no respectades: Legendary la proporció actual és ', 
        ((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Legendary' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer,
        ' quan hauria de ser 17'), 
        CURRENT_DATE, CURRENT_USER;
        END IF;

    IF (((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Champion' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer != 3) THEN
        INSERT INTO warnings (affected_table, error_message, date, user_name)
        SELECT 'carta', CONCAT('Proporcions de raresa no respectades: Champion la proporció actual és ',
         ((SELECT count(ID_carta) FROM carta WHERE nom_raresa = 'Champion' )/(SELECT count(ID_carta) FROM carta)::float * 100)::numeric::integer,
         ' quan hauria de ser 3'), 
        CURRENT_DATE, CURRENT_USER;
        END IF;
        RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER check_rarity_cards_trigger
AFTER INSERT OR UPDATE OR DELETE ON carta
EXECUTE FUNCTION check_rarity_cards();




-- 1.2. Regal d'actualització de cartes
CREATE OR REPLACE FUNCTION mkt_max_lvl()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
    UPDATE cartes_jugador
    SET nivell = 14
    WHERE ID_carta = NEW.ID_carta AND ID_jugador = NEW.ID_jugador;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER mkt_max_lvl_trigger
AFTER INSERT ON cartes_jugador
FOR EACH ROW
EXECUTE FUNCTION mkt_max_lvl();




-- 1.3. Targetes OP que necessiten revisió
-- (la taula ja esta creada en el model fisic)
CREATE OR REPLACE FUNCTION check_OP_card()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE 
carta_pointer RECORD;
BEGIN
    FOR carta_pointer IN (SELECT ID_carta FROM cartes_pila WHERE ID_pila = NEW.ID_pila_guanyadora) LOOP
        IF (((SELECT COUNT(ID_batalla) FROM piles_batalla AS pb 
            JOIN cartes_pila AS pc ON pc.ID_pila = pb.ID_pila_guanyadora
            WHERE pc.ID_carta = carta_pointer.ID_carta) / (
            (SELECT COUNT(ID_batalla) FROM piles_batalla AS pb 
            JOIN cartes_pila AS pc ON pc.ID_pila = pb.ID_pila_guanyadora
            WHERE pc.ID_carta = carta_pointer.ID_carta) +
            (SELECT COUNT(ID_batalla) FROM piles_batalla AS pb 
            JOIN cartes_pila AS pc ON pc.ID_pila = pb.ID_pila_perdedora
            WHERE pc.ID_carta = carta_pointer.ID_carta))::float)*100)::numeric::integer > 90 THEN
                IF EXISTS (SELECT ID_carta FROM OPCardBlackList WHERE ID_carta = carta_pointer.ID_carta) THEN
                    UPDATE OPCardBlackList
                    SET date2 = CURRENT_DATE
                    WHERE ID_carta = carta_pointer.ID_carta;
                ELSE 
                    INSERT INTO OPCardBlackList(ID_carta, date1, date2)
                    VALUES (carta_pointer.ID_carta, CURRENT_DATE, CURRENT_DATE);
                END IF;

        END IF;
    END LOOP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER check_OP_card_trigger
AFTER INSERT ON piles_batalla
FOR EACH ROW
EXECUTE FUNCTION check_OP_card();





CREATE OR REPLACE FUNCTION check_nerf_card()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
BEGIN

    IF (OLD.date2::date - NEW.date1::date) > 6 THEN 

        UPDATE OPCardBlackList
        SET date1 = NEW.date2
        WHERE ID_carta = NEW.ID_carta;

        UPDATE carta 
        SET dany = dany - dany*0.01,
        velocitat_atac = velocitat_atac - velocitat_atac*0.01
        WHERE ID_carta = NEW.ID_carta;

        IF EXISTS (SELECT ID_edifici FROM edifici WHERE ID_edifici = NEW.ID_carta) THEN
            UPDATE edifici
            SET vida = vida - vida*0.01
            WHERE ID_edifici = NEW.ID_carta;

        ELSIF EXISTS (SELECT ID_tropa FROM tropa WHERE ID_tropa = NEW.ID_carta) THEN
            UPDATE tropa
            SET dany_aparicio = dany_aparicio - dany_aparicio*0.01
            WHERE ID_tropa = NEW.ID_carta;

        ELSIF EXISTS (SELECT ID_encanteri FROM encanteri WHERE ID_encanteri = NEW.ID_carta) THEN
            UPDATE encanteri
            SET radi_efecte = radi_efecte - radi_efecte*0.01
            WHERE ID_encanteri = NEW.ID_carta;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE TRIGGER nerf_card_trigger
AFTER UPDATE ON OPCardBlackList
FOR EACH ROW
EXECUTE FUNCTION check_nerf_card();