create or replace type vector_number is table of number;
/

create or replace type vector_varchar2 is table of varchar2(50);
/

CREATE OR REPLACE PACKAGE recomandare
IS
  FUNCTION recomanda_carti(
      p_utilizator IN utilizator_parola.utilizator%TYPE,
      p_HTML       IN NUMBER)
    RETURN VARCHAR2;
END recomandare;
/
CREATE OR REPLACE PACKAGE BODY recomandare
IS
  FUNCTION recomanda_bazat_pe_utilizatori(
      p_utilizator IN utilizator_parola.utilizator%TYPE)
    RETURN NUMBER
  IS
    v_rezultat            VARCHAR2(32767);
    v_similaritate_maxima NUMBER;
    v_numar_ut_optimi     NUMBER;
    v_utilizator_optim utilizator_parola.utilizator%TYPE;
    v_ISBN carti.ISBN%TYPE;
  BEGIN
    SELECT MAX(distanta)
    INTO v_similaritate_maxima
    FROM distante_utilizatori
    WHERE u1 = p_utilizator
    OR u2    = p_utilizator;
    SELECT COUNT('1')
    INTO v_numar_ut_optimi
    FROM distante_utilizatori
    WHERE u1              = p_utilizator
    AND distanta          = v_similaritate_maxima;
    IF (v_numar_ut_optimi > 0) THEN
      SELECT u2
      INTO v_utilizator_optim
      FROM distante_utilizatori
      WHERE u1     = p_utilizator
      AND distanta = v_similaritate_maxima;
    ELSE
      SELECT u1
      INTO v_utilizator_optim
      FROM distante_utilizatori
      WHERE u2     = p_utilizator
      AND distanta = v_similaritate_maxima;
    END IF;
    -- Avem userul cu cea mai mare similaritate. Urmeaza sa luam cartea la care a dat cel mai mare rating, dar userul initial nu a dat (adica nu a citit-o).
    SELECT ISBN
    INTO v_ISBN
    FROM
      (SELECT ISBN,
        rating
      FROM utilizator_carte_rating
      WHERE utilizator = v_utilizator_optim
      MINUS
      SELECT ISBN,
        rating
      FROM utilizator_Carte_rating
      WHERE utilizator = p_utilizator
      )
    WHERE ROWNUM <= 1
    ORDER BY rating DESC;
    RETURN v_isbn;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN '';
  WHEN OTHERS THEN
    RETURN NULL;
  END recomanda_bazat_pe_utilizatori;
  
  FUNCTION recomandare_bazata_pe_continut(
      p_utilizator utilizator_carte_rating.utilizator%type)
    RETURN NUMBER
  AS
    v_autori vector_number;
    v_subgenuri vector_varchar2;
    v_recom carti.isbn%type;
  BEGIN
    SELECT DISTINCT autID bulk collect
    INTO v_autori
    FROM
      (SELECT isbn
      FROM utilizator_carte_rating
      WHERE utilizator=p_utilizator
      AND rating     >= 6
      ) NATURAL
    JOIN carti NATURAL
    JOIN opere NATURAL
    JOIN opere_autori NATURAL
    JOIN autori;
    SELECT DISTINCT(subgen) bulk collect
    INTO v_subgenuri
    FROM opere_autori NATURAL
    JOIN opere NATURAL
    JOIN abordari
    WHERE autId IN
      (SELECT * FROM TABLE(v_autori)
      );
    SELECT isbn
    INTO v_recom
    FROM
      (SELECT isbn
      FROM abordari NATURAL
      JOIN opere NATURAL
      JOIN carti NATURAL
      JOIN
        (SELECT isbn, utilizator, rating rating_personal FROM utilizator_carte_rating
        )
      WHERE subgen IN
        (SELECT * FROM TABLE(v_subgenuri)
        )
      AND utilizator!=p_utilizator
      ORDER BY rating_personal DESC
      )
    WHERE rownum = 1;
    RETURN v_recom;
  EXCEPTION
  WHEN no_data_found THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RETURN NULL;
  END recomandare_bazata_pe_continut;
  FUNCTION recomanda_carti(
      p_utilizator IN utilizator_parola.utilizator%TYPE,
      p_HTML       IN NUMBER)
    RETURN VARCHAR2
  IS
    v_isbn1 carti.isbn%type;
    v_isbn2 carti.isbn%type;
    v_rezultat VARCHAR2(30000);
  BEGIN
    v_isbn1      := recomanda_bazat_pe_utilizatori(p_utilizator);
    v_isbn2      := recomandare_bazata_pe_continut(p_utilizator);
    IF v_isbn1   IS NOT NULL THEN
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(v_isbn1,p_HTML);
    END IF;
    IF v_isbn2   IS NOT NULL THEN
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(v_isbn2,p_HTML);
    END IF;
    IF v_rezultat IS NULL THEN
      v_rezultat  := 'Nu avem c?r?i de recomandat pentru dvs. V? rug?m da?i-v? cu p?rerea despre anumite c?r?i ?i reveni?i pe aceast? pagin?.';
    END IF;
    RETURN v_rezultat;
  END recomanda_carti;
END recomandare;
/
