CREATE OR REPLACE PACKAGE gestioneaza_carte
IS
  FUNCTION carte_random(
      p_HTML IN NUMBER)
    RETURN VARCHAR2;
  PROCEDURE rate(
      p_utilizator utilizator_carte_rating.utilizator%type,
      p_isbn utilizator_carte_rating.isbn%type,
      p_rating utilizator_carte_rating.rating%type,
      p_mesaj_succes OUT VARCHAR2);
  FUNCTION afiseaza_carte(
      p_ISBN IN carti.ISBN%TYPE,
      p_HTML IN NUMBER)
    RETURN VARCHAR2;
  FUNCTION afiseaza_opera(
      p_opID IN opere.opID%TYPE,
      p_HTML IN NUMBER)
    RETURN VARCHAR2;
END gestioneaza_carte;
/

CREATE OR REPLACE PACKAGE BODY gestioneaza_carte IS

function carte_random(p_HTML IN NUMBER) return VARCHAR2
as
  v_max_isbn number;
  v_isbn number;
  v_count number;
begin
  select max(isbn) into v_max_isbn from carti;
  loop
    v_isbn:=trunc(DBMS_RANDOM.VALUE(1,v_max_isbn+1));
    select count(isbn) into v_count from carti where isbn=v_isbn;
    if v_count = 1 then
      return afiseaza_carte(v_isbn, p_HTML);
    end if;
  end loop;
end carte_random;


procedure rate (p_utilizator utilizator_carte_rating.utilizator%type,
  p_isbn utilizator_carte_rating.isbn%type, p_rating utilizator_carte_rating.rating%type,
  p_mesaj_succes out varchar2)
as
  v_count number;
begin
  select count(*) into v_count from utilizator_carte_rating 
  where p_utilizator=utilizator and isbn=p_isbn;
  if v_count = 0 then
    insert into utilizator_carte_rating values(p_utilizator,p_isbn,p_rating);
    p_mesaj_succes := 'Felicit?ri! Primul dvs rating la aceast? carte a fost înregistrat!';
    elsif v_count = 1 then
      update utilizator_carte_rating set rating=p_rating
      where utilizator=p_utilizator and isbn=p_isbn;
      p_mesaj_succes := 'Felicit?ri! Ratingul dvs pentru aceast? carte a fost actualizat!';
  end if;
  
  exception
  when exceptii.cheie_straina_gresita then
    raise_application_error(exceptii.cheie_straina_gresita_nr,'Eroare la introducere rating! V? rug?m s? verifica?i utilizatorul ?i isbn-ul s? fie valide.');
  when exceptii.constrangere then
    raise_application_error(exceptii.constrangere_nr,exceptii.constrangere_text || '''rating''.');
  when others then
    raise_application_error(-20017,'Eroare la introducere rating! V? rug?m încerca?i din nou!');
end rate;

FUNCTION marcheaza_continut(
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

FUNCTION afiseaza_carte(
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

FUNCTION afiseaza_opera(p_opID IN opere.opID%TYPE, p_HTML IN NUMBER) RETURN VARCHAR2
AS
  v_rezultat           VARCHAR2(32767);
  v_titlu              opere.titlu%TYPE;
  v_volum              opere.volum%TYPE;
  v_autori             VARCHAR2(32767);
  
BEGIN
  SELECT titlu, volum INTO v_titlu, v_volum FROM opere WHERE opID = p_opID;
  v_rezultat := marcheaza_continut(p_HTML, '<p>', '</p>', 'Opera: ' || v_titlu);
  v_rezultat := v_rezultat || marcheaza_continut(p_HTML, '<p>', '</p>', 'Volum: ' || v_volum);
  FOR c_linie IN (SELECT nume, prenume FROM autori NATURAL JOIN opere_autori WHERE opID = p_opID) LOOP
    v_autori := v_autori || marcheaza_continut(p_HTML, '<li>', '</li>', c_linie.nume || ' ' || c_linie.prenume);
  END LOOP;
  v_autori := marcheaza_continut(p_HTML, '<ol>', '</ol>', v_autori);
  v_autori := marcheaza_continut(p_HTML, '<p>', '</p>', 'Autori: ' || v_autori);
  v_rezultat := v_rezultat || v_autori;

  RETURN v_rezultat;
END afiseaza_opera;

END gestioneaza_carte;
/

--select opID from opere natural join opere_autori group by opID having count(*) > 1;
--
--begin
--  dbms_output.put_line(gestioneaza_carte.afiseaza_opera(745, 1));
--end;
--/