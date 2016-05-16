-- Cautare dupa autori;
SELECT titlu,
  volum,
  nume,
  prenume
FROM opere NATURAL
JOIN opere_autori NATURAL
JOIN autori
WHERE UPPER(nume) LIKE ('SHAKE')
AND UPPER(prenume) LIKE UPPER('%');
-- Cautare dupa titlu opera
SELECT titlu,
  volum,
  MAX(nume
  || ' '
  || prenume)
FROM opere NATURAL
JOIN opere_autori NATURAL
JOIN autori
WHERE UPPER(titlu) LIKE UPPER( 'The Child under Eight')
GROUP BY opID,
  titlu,
  volum;
-- Cautare dupa gen si subgen
SELECT titlu,
  volum,
  nume,
  prenume
FROM opere NATURAL
JOIN opere_autori NATURAL
JOIN autori NATURAL
JOIN abordari NATURAL
JOIN ierarhie
WHERE subgen = 'Matematic?';
---------------------------- INSERTURI ----------------------------------------
CREATE OR REPLACE PROCEDURE insereaza_carte(
    p_titlu       IN opere.titlu%TYPE,
    p_volum       IN opere.volum%TYPE,
    p_isbn        IN carti.isbn%TYPE,
    p_editura     IN carti.editura%TYPE,
    p_calea       IN carti.calea%TYPE,
    p_an_aparitie IN carti.an_aparitie%TYPE,
    p_subgen      IN ierarhie.subgen%TYPE,
    p_nume        IN autori.nume%type,
    p_prenume     IN autori.prenume%type)
IS
  v_opID opere.opID%TYPE;
  v_autID autori.autID%TYPE;
  v_gen ierarhie.gen%type;
BEGIN
  SAVEPOINT inainte;
  SELECT MAX(opID)+1 INTO v_opID FROM opere;
  SELECT MAX(autID)+1 INTO v_autID FROM autori;
  SELECT gen INTO v_gen FROM ierarhie WHERE subgen=p_subgen;
  INSERT INTO opere VALUES
    (v_opID,p_titlu,p_volum
    );
  INSERT INTO autori VALUES
    (v_autID,p_nume,p_prenume
    );
  INSERT INTO opere_autori VALUES
    (v_opID,v_autID
    );
  INSERT
  INTO carti VALUES
    (
      p_isbn,
      p_editura,
      p_calea,
      p_an_aparitie,
      NULL,
      v_opID
    );
  INSERT INTO abordari VALUES
    (v_opID,p_subgen
    );
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
  ROLLBACK TO inainte;
  raise_application_error(-20001,'Eroare la introducere carte! V? rug?m verifica?i ISBN-ul.');
WHEN exceptii.cheie_straina_gresita THEN
  ROLLBACK TO inainte;
  raise_application_error(exceptii.cheie_straina_gresita_nr,'Eroare la introducere carte! V? rug?m verifica?i subgenul.');
WHEN NO_DATA_FOUND THEN
  ROLLBACK TO inainte;
  raise_application_error(-20003,'Eroare la introducere carte! V? rug?m verifica?i subgenul.');
WHEN OTHERS THEN
  ROLLBACK TO inainte;
  raise_application_error(-20004,'Eroare la introducere carte! V? rug?m reîncerca?i.');
END insereaza_carte;
/


CREATE OR REPLACE PROCEDURE insereaza_autor
  (
    p_nume    IN autori.nume%type,
    p_prenume IN autori.prenume%type
  )
IS
  v_autID autori.autID%type;
BEGIN
  SELECT MAX(autID)+1 INTO v_autID FROM autori;
  INSERT INTO autori VALUES
    (v_autID,p_nume,p_prenume
    );
EXCEPTION
WHEN OTHERS THEN
  raise_application_error(-20005,'Eroare la introducere autor! V? rug?m verifica?i autorul.');
END insereaza_autor;
/

CREATE OR REPLACE PROCEDURE insereaza_subgen
  (
    p_subgen IN ierarhie.subgen%type,
    p_gen    IN ierarhie.gen%type
  )
IS
  v_count              NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ierarhie WHERE subgen=p_subgen;
  IF (v_count != 0) THEN
    raise exceptii.subgen_deja_existent;
  END IF;
  INSERT INTO ierarhie VALUES
    (p_subgen,p_gen
    );
EXCEPTION
WHEN exceptii.subgen_deja_existent THEN
  raise_application_error(exceptii.subgen_deja_existent_nr,exceptii.subgen_deja_existent_text);
WHEN OTHERS THEN
  raise_application_error(-20007,'Eroare la introducere subgen! V? rug?m verifica?i (sub)genul.');
END insereaza_subgen;
/

CREATE OR REPLACE PROCEDURE insereaza_opera
  (
    p_titlu opere.titlu%type,
    p_volum opere.volum%type,
    p_nume autori.nume%type,
    p_prenume autori.prenume%type
  )
IS
  v_opID opere.opID%type;
  v_autID autori.autID%type;
BEGIN
  SELECT MAX(opID)+1 INTO v_opID FROM opere;
  SELECT MAX(autID)+1 INTO v_autID FROM autori;
  INSERT INTO opere VALUES
    (v_opID,p_titlu,p_volum
    );
  INSERT INTO autori VALUES
    (v_autID,p_nume,p_prenume
    );
  INSERT INTO opere_autori VALUES
    (v_opID,v_autID
    );
EXCEPTION
WHEN OTHERS THEN
  raise_application_error(-20008,'Eroare la introducere opera! V? rug?m încerca?i din nou.');
END insereaza_opera;
/
---------------------------- DELETE-URI ----------------------------------------

CREATE OR REPLACE PROCEDURE sterge_carte
  (
    p_isbn carti.isbn%type
  )
IS
  v_count         NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM carti WHERE p_isbn=isbn;
  IF v_count != 1 THEN
    raise exceptii.isbn_inexistent;
  END IF;
  DELETE FROM carti WHERE p_isbn=isbn;
EXCEPTION
WHEN exceptii.isbn_inexistent THEN
  raise_application_error(exceptii.isbn_inexistent_nr,exceptii.isbn_inexistent_text);
WHEN OTHERS THEN
  raise_application_error(-20010,'Eroare la ?tergere carte! V? rug?m s? încerca?i din nou.');
END sterge_carte;
/

CREATE OR REPLACE PROCEDURE sterge_autor(
    p_autID autori.autID%type)
IS
  v_count          NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM autori WHERE p_autID=autID;
  IF v_count != 1 THEN
    raise exceptii.autor_inexistent;
  END IF;
  DELETE FROM autori WHERE p_autID=autID;
EXCEPTION
WHEN exceptii.autor_inexistent THEN
  raise_application_error(exceptii.autor_inexistent_nr,exceptii.autor_inexistent_text);
WHEN OTHERS THEN
  raise_application_error(-20012,'Eroare la ?tergere autor! V? rug?m s? încerca?i din nou.');
END sterge_autor;
/
CREATE OR REPLACE PROCEDURE sterge_opera(
    p_opID opere.opID%type)
IS
  v_count           NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM opere WHERE p_opID=opID;
  IF v_count != 1 THEN
    raise exceptii.opera_inexistenta;
  END IF;
  DELETE FROM opere WHERE p_opID=opID;
EXCEPTION
WHEN exceptii.opera_inexistenta THEN
  raise_application_error(exceptii.opera_inexistenta_nr,exceptii.opera_inexistenta_text);
WHEN OTHERS THEN
  raise_application_error(-20014,'Eroare la ?tergere oper?! V? rug?m s? încerca?i din nou.');
END sterge_opera;
/
CREATE OR REPLACE PROCEDURE sterge_subgen(
    p_subgen ierarhie.subgen%type,
    p_mesaj_succes out varchar2)
IS
  v_count           NUMBER;
  v_count_carti number;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ierarhie WHERE p_subgen=subgen;
  IF v_count != 1 THEN
    raise exceptii.subgen_inexistent;
  END IF;
  select count(*) into v_count_carti 
  from opere natural join abordari natural join ierarhie
  where subgen=p_subgen;
  DELETE FROM ierarhie WHERE p_subgen=subgen;
  p_mesaj_succes := 'Au fost ?terse '||v_count_carti||' .';
EXCEPTION
WHEN exceptii.subgen_inexistent THEN
  raise_application_error(exceptii.subgen_inexistent_nr,exceptii.subgen_inexistent_text);
WHEN OTHERS THEN
  raise_application_error(-20016,'Eroare la ?tergere oper?! V? rug?m s? încerca?i din nou.');
END sterge_subgen;
/
