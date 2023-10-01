-- Set4.sql
-- BBDD Projecte Clash Sayale - Grup 10
-- Modul 4 - M'agrada la competicio, M'agraden els reptes
-- Fase 4 - Triggers

-- 4.1. Completar una Missio
CREATE OR REPLACE FUNCTION update_user_reward()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
arena VARCHAR := (SELECT nom_arena FROM arena
                 JOIN jugadors_arena ON arena.id_arena = jugadors_arena.id_arena
                 JOIN jugador ON jugadors_arena.id_jugador = jugador.id_jugador
                 WHERE jugador.id_jugador=NEW.id_jugador
                 LIMIT 1);
BEGIN
  IF EXISTS (( SELECT id_missio FROM missions_jugadors AS jm
                     WHERE jm.id_jugador = NEW.id_jugador
                     AND jm.id_missio = ( SELECT missio_requerida FROM missio AS m
                                          WHERE m.id_missio = NEW.id_missio ) ))
  OR EXISTS (SELECT id_missio FROM missio AS m WHERE m.id_missio = NEW.id_missio AND m.missio_requerida IS NULL)
  THEN
  		UPDATE jugador
  		SET experiencia = experiencia + ( (SELECT recompensa_experiencia FROM missio
  										   WHERE missio.id_missio = NEW.id_missio)
  										 * (SELECT multiplicador_missio FROM arena
  										    JOIN jugadors_arena ON arena.id_arena = jugadors_arena.id_arena
  										    JOIN jugador ON jugadors_arena.id_jugador = jugador.id_jugador
  										    WHERE jugador.id_jugador=NEW.id_jugador
  										    LIMIT 1) ),
  		gold = gold + ( (SELECT recompensa_or FROM missio
  										   WHERE missio.id_missio = NEW.id_missio)
  										 * (SELECT multiplicador_missio FROM arena
  										    JOIN jugadors_arena ON arena.id_arena = jugadors_arena.id_arena
  										    JOIN jugador ON jugadors_arena.id_jugador = jugador.id_jugador
  										    WHERE jugador.id_jugador=NEW.id_jugador
  										    LIMIT 1) );
  END IF;
	RETURN NEW;
END;
$$


CREATE OR REPLACE FUNCTION log_mission_warnings()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
titol_missio VARCHAR := (SELECT titol FROM missio WHERE missio.id_missio=NEW.id_missio);
titol_requerida VARCHAR := (SELECT titol FROM missio WHERE id_missio = ( SELECT missio_requerida FROM missio
								WHERE missio.id_missio = NEW.id_missio));
errorMessage VARCHAR := CONCAT('L''entrada de la quest per a ', titol_missio, ' s''ha realitzat sense completar el ', titol_requerida, ' prerequisit');
BEGIN
    IF NOT EXISTS (( SELECT id_missio FROM missions_jugadors AS jm
                       WHERE jm.id_jugador = NEW.id_jugador
                       AND jm.id_missio = ( SELECT missio_requerida FROM missio AS m
                                            WHERE m.id_missio = NEW.id_missio ) ))
    AND NOT EXISTS (SELECT id_missio FROM missio AS m WHERE m.id_missio = NEW.id_missio AND m.missio_requerida IS NULL)
    THEN
      INSERT INTO warnings (affected_table, error_message, date, user_warning)
      SELECT 'jugador_missio', errorMessage, CURRENT_DATE, CURRENT_USER;
      DELETE FROM missions_jugadors
      WHERE id_jugador LIKE NEW.id_jugador AND id_missio=NEW.id_missio;
      END IF;
  RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER update_user_reward_trigger
AFTER INSERT ON missions_jugadors
FOR EACH ROW
EXECUTE FUNCTION update_user_reward();


CREATE OR REPLACE TRIGGER log_mission_warnings_trigger
AFTER INSERT ON missions_jugadors
FOR EACH ROW
EXECUTE FUNCTION log_mission_warnings();

--****************************************************************************************************************************************************



-- 4.2. Batalla amb Jugadors
CREATE OR REPLACE FUNCTION update_stats_after_battle()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
trofeusGuanyador INTEGER := (SELECT trofeus_guanyador FROM batalla
                             WHERE id_batalla = NEW.id_batalla);
trofeusPerdedor INTEGER := (SELECT trofeus_perdedor FROM batalla
                             WHERE id_batalla = NEW.id_batalla);
goldGuanyat INTEGER := (SELECT recompensa_or FROM batalla
                 WHERE id_batalla = NEW.id_batalla);
id_guanyador TEXT := (SELECT jugador.id_jugador FROM jugador
                      JOIN pila ON jugador.id_jugador = pila.id_jugador
                      JOIN piles_batalla ON pila.id_pila = piles_batalla.id_pila_guanyadora
                      WHERE piles_batalla.id_batalla = NEW.id_batalla);
id_perdedor TEXT := (SELECT jugador.id_jugador FROM jugador
                      JOIN pila ON jugador.id_jugador = pila.id_jugador
                      JOIN piles_batalla ON pila.id_pila = piles_batalla.id_pila_perdedora
                      WHERE piles_batalla.id_batalla = NEW.id_batalla);
BEGIN
  UPDATE jugador
  SET trofeus = trofeus + trofeusGuanyador,
      gold = goldGuanyat
  WHERE id_jugador = id_guanyador;

  UPDATE jugador
  SET trofeus = trofeus + trofeusPerdedor,
      gold = goldGuanyat
  WHERE id_jugador = id_perdedor;
  RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER update_stats_after_battle
AFTER INSERT ON piles_batalla
FOR EACH ROW
EXECUTE FUNCTION update_stats_after_battle();



CREATE OR REPLACE FUNCTION update_arena_winner()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
arena_pointer RECORD;
BEGIN
  IF NEW.trofeus >= OLD.trofeus THEN
      FOR arena_pointer IN (SELECT id_arena FROM arena WHERE NEW.trofeus > arena.min_trofeus
         AND NEW.trofeus < arena.max_trofeus
  			 AND id_arena NOT IN (SELECT id_arena FROM jugadors_arena WHERE id_jugador=NEW.id_jugador)) LOOP
      INSERT INTO jugadors_arena (id_jugador, id_arena)
      VALUES (NEW.id_jugador, arena_pointer.id_arena);
  	END LOOP;
  END IF;
	RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER update_arena_winner
AFTER UPDATE OF trofeus ON jugador
FOR EACH ROW
EXECUTE FUNCTION update_arena();


CREATE OR REPLACE FUNCTION update_arena_looser()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
arena_pointer RECORD;
BEGIN
  IF NEW.trofeus < OLD.trofeus THEN
      FOR arena_pointer IN (SELECT id_arena FROM arena WHERE NEW.trofeus < arena.min_trofeus
  			 AND id_arena IN (SELECT id_arena FROM jugadors_arena WHERE id_jugador=NEW.id_jugador)) LOOP
      DELETE FROM jugadors_arena
      WHERE id_jugador=NEW.id_jugador
      AND id_arena=arena_pointer.id_arena;
  	END LOOP;
  END IF;
	RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER update_arena_looser
AFTER UPDATE OF trofeus ON jugador
FOR EACH ROW
EXECUTE FUNCTION update_arena_looser();


--***************************************************************************************************************************************+



-- 4.3. Corrupcio de Dades
CREATE OR REPLACE FUNCTION check_donation()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
errorMessage VARCHAR;
nomClan VARCHAR := (SELECT nom_clan FROM clan WHERE id_clan = NEW.id_clan);
BEGIN
  CASE
      WHEN NEW.quantitat_gold IS NULL THEN
        errorMessage := CONCAT('S''ha intentat donar un valor NULL al clan', nomClan);
        INSERT INTO warnings (affected_table, error_message, date, user_warning)
        SELECT 'dona_gold_a_clan', errorMessage, CURRENT_DATE, CURRENT_USER;
      WHEN NOT EXISTS (SELECT id_jugador FROM jugador_clan WHERE id_jugador = NEW.id_jugador AND id_clan = NEW.id_clan) THEN
        errorMessage := CONCAT('S''ha realitzat una donació de ', NEW.quantitat_gold, ' d''or a ', nomClan, ' sense pertanyer al clan');
        INSERT INTO warnings (affected_table, error_message, date, user_warning)
        SELECT 'dona_gold_a_clan', errorMessage, CURRENT_DATE, CURRENT_USER;
      WHEN EXISTS (SELECT id_jugador FROM jugador_clan
                  JOIN clan ON jugador_clan.id_clan = clan.id_clan
                  WHERE id_jugador = NEW.id_jugador AND clan.id_clan = NEW.id_clan
                  AND data_out IS NOT NULL
                  AND NEW.data_donacio > data_out) THEN
        errorMessage := CONCAT('S''ha realitzat una donació de ', NEW.quantitat_gold, ' d''or a ', nomClan, ' despres d''haver marxat del clan');
        INSERT INTO warnings (affected_table, error_message, date, user_warning)
        SELECT 'dona_gold_a_clan', errorMessage, CURRENT_DATE, CURRENT_USER;
      WHEN EXISTS (SELECT id_jugador FROM jugador_clan
                  JOIN clan ON jugador_clan.id_clan = clan.id_clan
                  WHERE id_jugador = NEW.id_jugador AND clan.id_clan = NEW.id_clan
                  AND NEW.data_donacio < data_in) THEN
        errorMessage := CONCAT('S''ha realitzat una donació de ', NEW.quantitat_gold, ' d''or a ', nomClan, ' abans de pertanyer al clan');
        INSERT INTO warnings (affected_table, error_message, date, user_warning)
        SELECT 'dona_gold_a_clan', errorMessage, CURRENT_DATE, CURRENT_USER;
      ELSE
        UPDATE clan
        SET or_donacions = or_donacions + NEW.quantitat_gold
        WHERE id_clan = NEW.id_clan;
  END CASE;
	RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER check_donation
BEFORE INSERT ON dona_gold_a_clan
FOR EACH ROW
EXECUTE FUNCTION check_donation();
