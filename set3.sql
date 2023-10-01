-- Set3.sql
-- BBDD Projecte Clash Sayale - Grup 10
-- Modul 3 Clans
-- Fase 4 - Triggers

-- 3.1. Cop d'Efecte
DROP FUNCTION IF EXISTS ascens_lider_trigger cascade;
CREATE OR REPLACE FUNCTION ascens_lider_trigger()
RETURNS trigger
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF NEW.nom_rol IN (SELECT jc.nom_rol FROM jugador_clan AS jc
                       JOIN Clan AS c ON jc.ID_clan = c.ID_clan
                       WHERE ((OLD.num_jugadors - 5) > NEW.num_jugadors)) THEN
        INSERT INTO jugador_clan(nom_rol)
        VALUES ('leader');
    ELSIF NEW.nom_rol IN (SELECT jc.nom_rol FROM jugador_clan AS jc
                          JOIN Clan AS c ON jc.ID_clan = c.ID_clan
                          WHERE ((OLD.num_jugadors - 5) < NEW.num_jugadors)) THEN
        UPDATE jugador_clan SET
        nom_rol = '%leader%'
        WHERE jugador_clan.nom_rol = '%coLeader%';
    ELSIF NEW.nom_rol IN (SELECT jc.nom_rol FROM jugador_clan AS jc
                          JOIN Clan AS c ON jc.ID_clan = c.ID_clan
                          WHERE ((OLD.num_jugadors - 5) < NEW.num_jugadors)) THEN
        UPDATE jugador_clan SET
        nom_rol = '%leader%'
        WHERE jugador_clan.nom_rol != '%coLeader%';
    END IF;

    RETURN NULL;
END;
$$;


DROP TRIGGER IF EXISTS ascens_lider ON jugador_clan;
CREATE OR REPLACE TRIGGER ascens_lider AFTER INSERT ON jugador_clan
FOR EACH ROW
    EXECUTE FUNCTION ascens_lider_trigger();




-- 3.2. Hipocresia de Trofeus Minims
CREATE OR REPLACE FUNCTION update_clan_members()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
min_trophies INTEGER := (SELECT min_trofeus FROM clan 
                         JOIN jugador_clan ON clan.id_clan=jugador_clan.id_clan
                         WHERE NEW.id_jugador=jugador_clan.id_jugador
                         AND data_out IS NOT NULL);
ident_clan VARCHAR := (SELECT id_clan FROM clan
                       JOIN jugador_clan ON clan.id_clan=jugador_clan.id_clan
                       WHERE NEW.id_jugador=jugador_clan.id_jugador
                       AND data_out IS NOT NULL);
num_coliders INTEGER := (SELECT COUNT(id_jugador) FROM jugador_clan
                        WHERE jugador_clan.id_clan=ident_clan
                        AND nom_rol LIKE 'coLeader');

BEGIN
  CASE
    WHEN NEW.trofeus < OLD.trofeus AND NEW.trofeus < min_trophies AND NEW.nom_rol NOT LIKE 'leader' THEN
      DELETE FROM jugador_clan
      WHERE id_jugador=NEW.id_jugador
      AND id_clan=ident_clan;
    WHEN NEW.trofeus < OLD.trofeus AND NEW.trofeus < min_trophies AND NEW.nom_rol LIKE 'leader'
      IF num_coliders=0 THEN
        DELETE FROM jugador_clan
        WHERE id_jugador=NEW.id_jugador
        AND id_clan=ident_clan;
        UPDATE jugador_clan
        SET nom_rol='leader'
        WHERE id_jugador=(SELECT id_jugador FROM jugador_clan WHERE id_clan LIKE ident_clan
                          ORDER BY RANDOM() LIMIT 1);
      END IF;
      IF num_coliders>0 THEN
        DELETE FROM jugador_clan
        WHERE id_jugador=NEW.id_jugador
        AND id_clan=ident_clan;
        UPDATE jugador_clan
        SET nom_rol='leader'
        WHERE id_jugador=(SELECT id_jugador FROM jugador_clan WHERE id_clan LIKE ident_clan
                          AND nom_rol LIKE 'coLeader' ORDER BY RANDOM() LIMIT 1);
      END IF;    
  END CASE;
  
	RETURN NEW;
END;
$$


CREATE OR REPLACE TRIGGER update_clan_members
AFTER UPDATE OF trofeus ON jugador
FOR EACH ROW
EXECUTE FUNCTION update_clan_members();






-- 3.3. Mals Perdedors
DROP RULE IF EXISTS comprovar_delete ON batalla;
CREATE RULE comprovar_delete AS ON DELETE
TO batalla 
WHERE (SELECT current_user) <> 'admin'
DO INSTEAD
    INSERT INTO Warnings VALUES ('batalla', 'S''ha intentat esborrar la batalla ' ||
    OLD.ID_batalla || ' on l''usuari ' || 
        (SELECT p.ID_jugador FROM batalla AS b
        INNER JOIN piles_batalla AS pb ON pb.ID_batalla = b.ID_batalla
        INNER JOIN pila AS p ON p.ID_pila = pb.ID_pila_perdedora
        WHERE b.ID_batalla = OLD.ID_batalla
        )
    || ' va perdre ' || OLD.trofeus_perdedor || ' trofeus', (SELECT CURRENT_DATE), 
    (SELECT current_user));