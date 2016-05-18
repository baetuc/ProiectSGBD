-- Trigger care recalculeaza distantele intre utilizatori in momentul in care un anumit utilizator isi modifica ratingul acordat unei carti sau
-- da un rating nou
ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:NONE';

CREATE OR REPLACE TYPE carte IS OBJECT(
  ISBN   NUMBER
);
/

CREATE OR REPLACE TYPE carti_cotate IS TABLE OF carte;
/


CREATE OR REPLACE TYPE nume_utilizator IS OBJECT (
  utilizator      VARCHAR2(100)
  );
/

CREATE OR REPLACE TYPE utilizatori IS TABLE OF nume_utilizator;
/

CREATE OR REPLACE TRIGGER actualizeaza_distante
FOR INSERT OR UPDATE OF rating ON utilizator_carte_rating
COMPOUND TRIGGER
  v_count_global            NUMBER := 1;
  utilizatori_de_modificat  utilizatori := utilizatori();

  FUNCTION calculeaza_similaritate(
    p_u1 IN utilizator_parola.utilizator%TYPE,
    p_u2 IN utilizator_parola.utilizator%TYPE)
  RETURN NUMBER
  IS
    carti_u1 carti_cotate := carti_cotate(); -- cartile care au primit rating de la utilizatorul 1
    carti_u2 carti_cotate := carti_cotate(); -- cartile care au primit rating de la utilizatorul 2
    v_numarator   NUMBER := 0;
    v_numitor1    NUMBER := 0;
    v_numitor2    NUMBER := 0;
    v_rating_u1   NUMBER;
    v_rating_u2   NUMBER;
    v_count       NUMBER;
  BEGIN
    SELECT carte(ISBN) BULK COLLECT INTO carti_u1 FROM utilizator_carte_rating
    WHERE utilizator = p_u1;
    
    SELECT carte(ISBN) BULK COLLECT INTO carti_u2 FROM utilizator_carte_rating
    WHERE utilizator = p_u2;
    -- Calculam numaratorul din formula similaritatii
    FOR c_line IN (
      SELECT t1.ISBN AS ISBN FROM TABLE(carti_u1) t1
      INTERSECT 
      SELECT t2.ISBN AS ISBN FROM TABLE(carti_u2) t2)
    LOOP
      SELECT rating INTO v_rating_u1 FROM utilizator_carte_rating WHERE utilizator = p_u1 AND ISBN = c_line.ISBN;
      SELECT rating INTO v_rating_u2 FROM utilizator_carte_rating WHERE utilizator = p_u2 AND ISBN = c_line.ISBN;
      v_numarator := v_numarator + v_rating_u1 * v_rating_u2;
    END LOOP;
    
    -- Calculam numitorul din formula similaritatii
      FOR c_line IN (
      SELECT t1.ISBN AS ISBN FROM TABLE(carti_u1) t1
      UNION 
      SELECT t2.ISBN AS ISBN FROM TABLE(carti_u2) t2)
    LOOP
      SELECT COUNT('1') INTO v_count FROM utilizator_carte_rating WHERE utilizator = p_u1 AND ISBN = c_line.ISBN;
      IF (v_count > 0) THEN      
        SELECT rating INTO v_rating_u1 FROM utilizator_carte_rating WHERE utilizator = p_u1 AND ISBN = c_line.ISBN;
      ELSE
        v_rating_u1 := 0;
      END IF;
      
      SELECT count('1') INTO v_count FROM utilizator_carte_rating WHERE utilizator = p_u2 AND ISBN = c_line.ISBN;
      IF (v_count > 0) THEN
        SELECT rating INTO v_rating_u2 FROM utilizator_carte_rating WHERE utilizator = p_u2 AND ISBN = c_line.ISBN;
      ELSE
        v_rating_u2 := 0;
      END IF;
      v_numitor1 := v_numitor1 + (v_rating_u1 * v_rating_u1);
      v_numitor2 := v_numitor2 + (v_rating_u2 * v_rating_u2);
    END LOOP;
     --Daca niciunul din cei 2 nu a dat rate la vreo carte => se returneaza 0 similaritatea
    IF(v_numitor1 + v_numitor2 = 0) THEN
      RETURN 0;
      END IF;
    RETURN (v_numarator / (SQRT(v_numitor1) * SQRT(v_numitor2)));
  END calculeaza_similaritate;

  -- Procedura care pentru un anumit utilizator, actualizeaza distanta cu toti ceilalti utilizatori
  PROCEDURE actualizeaza_distanta(p_utilizator IN utilizator_parola.utilizator%TYPE) IS
    v_similaritate   NUMBER;
  BEGIN
    FOR c_line IN (SELECT DISTINCT(utilizator) AS utilizator FROM utilizator_carte_rating WHERE utilizator != p_utilizator) LOOP
      -- Pentru toti utilizatorii diferiti de cel curent, aflam similaritatea cu utilizatorul curent si facem update in tabela distante
      v_similaritate := calculeaza_similaritate(p_utilizator, c_line.utilizator);
      IF (p_utilizator < c_line.utilizator) THEN
        UPDATE distante_utilizatori SET distanta = v_similaritate WHERE u1 = p_utilizator AND u2 = c_line.utilizator;
      ELSE
        UPDATE distante_utilizatori SET distanta = v_similaritate WHERE u1 = c_line.utilizator AND u2 = p_utilizator;
      END IF;
    END LOOP;
  END actualizeaza_distanta;
  
  AFTER EACH ROW IS 
  BEGIN
    utilizatori_de_modificat.extend();
    utilizatori_de_modificat(v_count_global) := nume_utilizator(:NEW.utilizator);
    v_count_global := v_count_global + 1;
  END AFTER EACH ROW;
  
  AFTER STATEMENT IS
  BEGIN
    FOR c_linie IN (SELECT * FROM table(utilizatori_de_modificat)) LOOP
      actualizeaza_distanta(c_linie.utilizator);
    END LOOP;
  END AFTER STATEMENT;

END actualizeaza_distante;
/

-- Table care introduce un utilizator nou introdus si in tabela de distante, a.i. pt. orice pereche (u,v) din tabela distante,
-- avem: u < v.

CREATE OR REPLACE TRIGGER insereaza_utilizator_distante 
FOR INSERT ON utilizator_parola
COMPOUND TRIGGER
  utilizatori_vechi  utilizatori;
BEFORE STATEMENT IS
BEGIN
  SELECT nume_utilizator(utilizator) BULK COLLECT INTO utilizatori_vechi FROM utilizator_parola;
END BEFORE STATEMENT;

AFTER EACH ROW IS
BEGIN
  FOR c_linie IN (SELECT tab.utilizator AS utilizator FROM TABLE(utilizatori_vechi) tab) LOOP
    IF (:NEW.utilizator < c_linie.utilizator) THEN
      INSERT INTO distante_utilizatori(u1, u2, distanta) 
      VALUES (:NEW.utilizator, c_linie.utilizator, null);
    ELSE 
      INSERT INTO distante_utilizatori(u1, u2, distanta) 
      VALUES (c_linie.utilizator,:NEW.utilizator, null);
      END IF;
    END LOOP;
END AFTER EACH ROW;
END insereaza_utilizator_distante;
/

-- Trigger care actualizeaza media ratingurilor unei carti

create or replace trigger medie_rating
after update of rating or insert on utilizator_carte_rating
for each row
declare
  v_isbn carti.isbn%type;
  v_nr_rating number;
  v_rating number;
  v_medie number;
  v_suma number;
begin
  v_isbn := :new.isbn;
  select nr_rating,rating into v_nr_rating,v_rating
  from carti
  where isbn = v_isbn;
  v_suma := v_rating * v_nr_rating;
  if inserting then
    v_suma := v_suma + :new.rating;
    v_nr_rating := v_nr_rating + 1;
    v_medie := v_suma / v_nr_rating;
    update carti set nr_rating = v_nr_rating, rating = v_medie where isbn=v_isbn;
  else
    v_suma := v_suma - :old.rating + :new.rating;
    v_medie := v_suma / v_nr_rating;
    update carti set rating = v_medie where isbn=v_isbn;
  end if;
end medie_rating;
/

ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:ALL';
--declare
--  v_mesaj VARCHAR(32767);
--begin
--  RATE('Marcel', 2, 7, v_mesaj);
--  dbms_output.put_line(v_mesaj);
--end;
--/
--insert into utilizator_parola values('Sec','sec');
--select * from distante_utilizatori;
--select * from utilizator_carte_rating;