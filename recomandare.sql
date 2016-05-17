CREATE OR REPLACE PACKAGE recomandare IS
  FUNCTION recomanda_carti(p_utilizator IN utilizator_parola.utilizator%TYPE, p_HTML IN NUMBER) RETURN VARCHAR2; 
END recomandare;
/

CREATE OR REPLACE PACKAGE BODY recomandare IS
  FUNCTION recomanda_bazat_pe_utilizatori(p_utilizator IN utilizator_parola.utilizator%TYPE) 
  RETURN number IS
    v_rezultat              VARCHAR2(32767);
    v_similaritate_maxima   NUMBER;
    v_numar_ut_optimi       NUMBER;
    v_utilizator_optim      utilizator_parola.utilizator%TYPE;
    v_ISBN                  carti.ISBN%TYPE;
  BEGIN
    SELECT MAX(distanta) INTO v_similaritate_maxima FROM distante_utilizatori 
    WHERE u1 = p_utilizator OR u2 = p_utilizator;
    
    SELECT COUNT('1') INTO v_numar_ut_optimi FROM distante_utilizatori
    WHERE u1 = p_utilizator AND distanta = v_similaritate_maxima;
    IF (v_numar_ut_optimi > 0) THEN
      SELECT u2 INTO v_utilizator_optim FROM distante_utilizatori
      WHERE u1 = p_utilizator AND distanta = v_similaritate_maxima;
    ELSE
      SELECT u1 INTO v_utilizator_optim FROM distante_utilizatori
      WHERE u2 = p_utilizator AND distanta = v_similaritate_maxima;
    END IF;
    -- Avem userul cu cea mai mare similaritate. Urmeaza sa luam cartea la care a dat cel mai mare rating, dar userul initial nu a dat (adica nu a citit-o).
    
    SELECT ISBN INTO v_ISBN FROM (
      SELECT ISBN, rating FROM utilizator_carte_rating WHERE utilizator = v_utilizator_optim
      MINUS
      SELECT ISBN, rating FROM utilizator_Carte_rating WHERE utilizator = p_utilizator)
    WHERE ROWNUM <= 1 ORDER BY rating DESC;
    
--    RETURN GESTIONEAZA_CARTE.AFISEAZA_CARTE(v_ISBN, p_HTML);
    return v_isbn;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '';
    when others then
      return null;
  END recomanda_bazat_pe_utilizatori;
  
  FUNCTION recomandare_bazata_pe_continut(
    p_utilizator utilizator_carte_rating.utilizator%type)
  RETURN number
AS
  v_autori vector_number;
  v_subgenuri vector_varchar2;
  v_recom carti.isbn%type;
BEGIN
  select distinct autID bulk collect into v_autori
  from
  (select isbn
  from utilizator_carte_rating
  where utilizator=p_utilizator
  and rating >= 6)
  natural join carti
  natural join opere
  natural join opere_autori
  natural join autori;
  
  select distinct(subgen) bulk collect into v_subgenuri
  from opere_autori natural join opere natural join abordari
  where autId in (select * from table(v_autori));
  
  select isbn into v_recom
  from (
  select isbn
  from abordari natural join opere natural join carti natural join (select isbn, utilizator, rating rating_personal from utilizator_carte_rating)
  where subgen in (select * from table(v_subgenuri))
  and utilizator!=p_utilizator
  order by rating_personal desc
  ) where rownum = 1;
  
  --return gestioneaza_carte.afiseaza_carte(v_recom,p_HTML);
  return v_recom;
  
  exception
  when no_data_found then
    return null;
    when others then
      return null;
END recomandare_bazata_pe_continut;
  
  FUNCTION recomanda_carti(p_utilizator IN utilizator_parola.utilizator%TYPE, p_HTML IN NUMBER) RETURN VARCHAR2 IS
    v_isbn1 carti.isbn%type;
    v_isbn2 carti.isbn%type;
    v_rezultat varchar2(30000) := 'C?r?i: ';
  BEGIN
    v_isbn1 := recomanda_bazat_pe_utilizatori(p_utilizator);
    v_isbn2 := recomandare_bazata_pe_continut(p_utilizator);
    if v_isbn1 != null then
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(v_isbn1,p_HTML);
    end if;
    if v_isbn2 != null then
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(v_isbn2,p_HTML);
    end if;
    if v_rezultat = null then
      v_rezultat := 'Nu avem c?r?i de recomandat pentru dvs. V? rug?m da?i-v? cu p?rerea despre anumite c?r?i ?i reveni?i pe aceast? pagin?.';
    end if;
    return v_rezultat;
  END recomanda_carti;
  
END recomandare;
/

begin
  dbms_output.put_line(recomandare.recomanda_carti('Cip',1));
end;
/