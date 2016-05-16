CREATE OR REPLACE FUNCTION login(
    p_utilizator IN utilizator_parola.utilizator%TYPE,
    p_parola     IN utilizator_parola.parola%TYPE)
  RETURN VARCHAR2
IS
  v_corect NUMBER(1);
BEGIN
  SELECT COUNT(*) INTO v_corect FROM utilizator_parola WHERE utilizator = p_utilizator AND parola = p_parola;
  IF (v_corect = 0) THEN
    RETURN 'F';
  ELSE 
    RETURN 'T';
  END IF;
END login;
/

-- Hidden in the package
CREATE OR REPLACE FUNCTION marcheaza_continut(
    p_HTML        IN NUMBER,
    p_tag_inceput IN VARCHAR2,
    p_tag_final   IN VARCHAR2,
    p_continut    IN VARCHAR2)
  RETURN VARCHAR2
AS
BEGIN
  IF (p_HTML > 0) THEN
    RETURN p_tag_inceput || p_continut || p_tag_final;
  ELSE
    RETURN p_continut || ', ';
  END IF;
END marcheaza_continut;
/

CREATE OR REPLACE FUNCTION afiseaza_carte(
    p_ISBN IN carti.ISBN%TYPE,
    p_HTML IN NUMBER)
  RETURN VARCHAR2
AS
  v_rezultat           VARCHAR2(32767);
  v_titlu              opere.titlu%TYPE;
  v_volum              opere.volum%TYPE;
  v_editura            carti.editura%TYPE;
  v_an_aparitie        carti.an_aparitie%TYPE;
  v_calea              carti.calea%TYPE;
  v_rating             carti.rating%TYPE;
  v_opID               carti.opID%TYPE;
  v_autori             VARCHAR2(32767);
  v_subgenuri_abordate VARCHAR2(32767);
BEGIN
  SELECT editura, an_aparitie, calea, rating, opID
  INTO v_editura, v_an_aparitie, v_calea, v_rating, v_opID 
  FROM carti 
  WHERE ISBN = p_ISBN;
  
  SELECT titlu, volum
  INTO v_titlu, v_volum
  FROM opere
  WHERE opID = v_opID;
  
  v_rezultat := marcheaza_continut(p_HTML, '<p>', '</p>', 'Opera: ' || v_titlu);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'Volum: ' || v_volum);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'ISBN: ' || p_ISBN);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'Editura: ' || v_editura);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'An aparitie: ' || v_an_aparitie);
  
  FOR c_linie IN (SELECT nume, prenume FROM autori NATURAL JOIN opere_autori WHERE opID = v_opID) LOOP
    v_autori := v_autori || marcheaza_continut(p_HTML, '<li>', '</li>', c_linie.nume || ' ' || c_linie.prenume);
  END LOOP;
  v_autori := marcheaza_continut(p_HTML, '<ol>', '</ol>', v_autori);
  v_autori := marcheaza_continut(p_HTML, '<p>', '</p>', 'Autori: ' || v_autori);
  v_rezultat := v_rezultat || v_autori;
  
  FOR c_linie IN (SELECT subgen, gen FROM abordari NATURAL JOIN ierarhie WHERE opID = v_opID) LOOP
    v_subgenuri_abordate := v_subgenuri_abordate || marcheaza_continut(p_HTML, '<li>', '</li>', c_linie.subgen || ' (' || c_linie.gen || ')');
  END LOOP;
  v_subgenuri_abordate := marcheaza_continut(p_HTML, '<ol>', '</ol>', v_subgenuri_abordate);
  v_subgenuri_abordate := marcheaza_continut(p_HTML, '<p>', '</p>', 'Subgenuri abordate: ' || v_subgenuri_abordate);
  v_rezultat := v_rezultat || v_subgenuri_abordate;
  
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'Rating: ' || v_rating);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<a href="', '"> Calea </a>', v_calea);
  
  RETURN v_rezultat;
  
END afiseaza_carte;
/


select isbn from carti natural join opere natural join opere_autori group by isbn having count(*) > 1;