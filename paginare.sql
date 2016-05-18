SELECT *
FROM
  (SELECT *
  FROM carti
  WHERE rating   <= :1
  AND NOT (rating = :1
  AND isbn       >= :2)
  ORDER BY rating DESC,
    isbn DESC
  )
WHERE rownum <=5;
SELECT *
FROM
  (SELECT isbn,
    rating
  FROM carti
  WHERE rating   >= :1
  AND NOT (rating = :1
  AND isbn        <= :2)
  ORDER BY rating asc,
    isbn asc
  )
WHERE rownum <=5 order by rating desc,isbn desc;
SELECT *
FROM
  (SELECT isbn
  FROM carti NATURAL
  JOIN opere
  WHERE upper(titlu) LIKE :1
  AND isbn >=:2
  ORDER BY isbn
  )
WHERE rownum <=5;
SELECT *
FROM
  (SELECT isbn
  FROM carti NATURAL
  JOIN opere
  WHERE upper(titlu) LIKE :1
  AND isbn <:2
  ORDER BY isbn desc
  )
WHERE rownum <=5
order by isbn asc;
SELECT *
FROM
  (SELECT isbn
  FROM carti NATURAL
  JOIN opere NATURAL
  JOIN opere_autori NATURAL
  JOIN autori
  WHERE upper(nume) LIKE :1
  AND upper(prenume) LIKE :2
  AND isbn >=:3
  ORDER BY isbn
  )
WHERE rownum <=5;
SELECT *
FROM
  (SELECT isbn
  FROM carti NATURAL
  JOIN opere NATURAL
  JOIN opere_autori NATURAL
  JOIN autori
  WHERE upper(nume) LIKE :1
  AND upper(prenume) LIKE :2
  AND isbn <:3
  ORDER BY isbn desc
  )
WHERE rownum <=5 order by isbn asc;
set serveroutput on;
declare
   p_rating_out  carti.rating%type;
  p_isbn_out  carti.isbn%type;
begin
  dbms_output.put_line(paginare.paginare_carti_back(10, 51994, 1, p_rating_out, p_isbn_out));
end;
/
CREATE OR REPLACE PACKAGE paginare
AS
  FUNCTION paginare_carti_next(
      p_rating_in carti.rating%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_rating_out OUT carti.rating%type,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
  FUNCTION paginare_carti_back(
      p_rating_in carti.rating%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_rating_out OUT carti.rating%type,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
  FUNCTION paginare_opere_next(
      p_format VARCHAR2,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
  FUNCTION paginare_opere_back(
      p_format VARCHAR2,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
  FUNCTION paginare_autori_next(
      p_nume_in autori.nume%type,
      p_prenume_in autori.prenume%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
  FUNCTION paginare_autori_back(
      p_nume_in autori.nume%type,
      p_prenume_in autori.prenume%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2;
END paginare;
/
CREATE OR REPLACE PACKAGE body paginare
IS
  FUNCTION paginare_carti_next(
      p_rating_in carti.rating%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_rating_out OUT carti.rating%type,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_rating_in carti.rating%type, p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn,
          rating
        FROM carti
        WHERE rating   <= p_rating_in
        AND NOT (rating = p_rating_in
        AND isbn       >= p_isbn_in)
        ORDER BY rating DESC,
          isbn DESC
        )
    WHERE rownum <=5;
    v_rezultat      VARCHAR2(32000);
    v_rating_limita NUMBER := p_rating_in;
    v_isbn_limita   NUMBER := p_isbn_in;
  BEGIN
    IF v_rating_limita IS NULL THEN
      SELECT MAX(rating) INTO v_rating_limita FROM carti;
    END IF;
    IF v_isbn_limita IS NULL THEN
      SELECT MAX(isbn)+1 INTO v_isbn_limita FROM carti;
    END IF;
    FOR carte IN pagina(v_rating_limita,v_isbn_limita)
    LOOP
      p_rating_out := carte.rating;
      p_isbn_out   := carte.isbn;
      v_rezultat   := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    RETURN v_rezultat;
  END paginare_carti_next;
  FUNCTION paginare_carti_back(
      p_rating_in carti.rating%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_rating_out OUT carti.rating%type,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_rating_in carti.rating%type, p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn,
          rating
        FROM carti
        WHERE rating   >= p_rating_in
        AND NOT (rating = p_rating_in
        AND isbn        < p_isbn_in)
        ORDER BY rating ASC,
          isbn ASC
        )
    WHERE rownum <=5 ORDER BY rating DESC, ISBN DESC;
    v_rezultat      VARCHAR2(32000);
    v_rating_limita NUMBER := p_rating_in;
    v_isbn_limita   NUMBER := p_isbn_in;
    v_count number :=0;
  BEGIN
    FOR carte IN pagina(v_rating_limita,v_isbn_limita)
    LOOP
      v_count := v_count+1;
      if v_count = 1 then
        p_rating_out := carte.rating;
        p_isbn_out   := carte.isbn+1;
      end if;
      v_rezultat   := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    RETURN v_rezultat;
  END paginare_carti_back;
  
  FUNCTION paginare_opere_next(
      p_format VARCHAR2,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn
        FROM carti NATURAL
        JOIN opere
        WHERE upper(titlu) LIKE upper(p_format)
        AND isbn >=p_isbn_in
        ORDER BY isbn
        )
    WHERE rownum <=5;
    v_rezultat    VARCHAR2(32000);
    v_isbn_limita NUMBER := p_isbn_in;
  BEGIN
    IF v_isbn_limita IS NULL THEN
      SELECT MIN(isbn) INTO v_isbn_limita FROM carti;
    END IF;
    FOR carte IN pagina(v_isbn_limita)
    LOOP
      p_isbn_out := carte.isbn;
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    p_isbn_out := p_isbn_out + 1;
    RETURN v_rezultat;
  END paginare_opere_next;
  FUNCTION paginare_opere_back(
      p_format VARCHAR2,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn
        FROM carti NATURAL
        JOIN opere
        WHERE upper(titlu) LIKE upper(p_format)
        AND isbn < p_isbn_in
        ORDER BY isbn desc
        )
    WHERE rownum <=5 order by isbn asc;
    v_rezultat    VARCHAR2(32000);
    v_isbn_limita NUMBER := p_isbn_in;
    v_count       NUMBER :=0;
  BEGIN
    FOR carte IN pagina(v_isbn_limita)
    LOOP
      v_count      :=v_count+1;
      IF v_count    = 1 THEN
        p_isbn_out := carte.isbn;
      END IF;
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    p_isbn_out := p_isbn_out - 1;
    RETURN v_rezultat;
  END paginare_opere_back;
  FUNCTION paginare_autori_next(
      p_nume_in autori.nume%type,
      p_prenume_in autori.prenume%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn
        FROM carti NATURAL
        JOIN opere NATURAL
        JOIN opere_autori NATURAL
        JOIN autori
        WHERE upper(nume) LIKE upper(p_nume_in)
        AND upper(prenume) LIKE upper(p_prenume_in)
        AND isbn >=p_isbn_in
        ORDER BY isbn
        )
    WHERE rownum <=5;
    v_rezultat    VARCHAR2(32000);
    v_isbn_limita NUMBER := p_isbn_in;
  BEGIN
    IF v_isbn_limita IS NULL THEN
      SELECT MIN(isbn) INTO v_isbn_limita FROM carti;
    END IF;
    FOR carte IN pagina(v_isbn_limita)
    LOOP
      p_isbn_out := carte.isbn;
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    p_isbn_out := p_isbn_out + 1;
    RETURN v_rezultat;
  END paginare_autori_next;
  FUNCTION paginare_autori_back(
      p_nume_in autori.nume%type,
      p_prenume_in autori.prenume%type,
      p_isbn_in carti.isbn%type,
      p_HTML NUMBER,
      p_isbn_out OUT carti.isbn%type)
    RETURN VARCHAR2
  AS
    CURSOR pagina (p_isbn_in carti.isbn%type)
    IS
      SELECT *
      FROM
        (SELECT isbn
        FROM carti NATURAL
        JOIN opere NATURAL
        JOIN opere_autori NATURAL
        JOIN autori
        WHERE upper(nume) LIKE upper(p_nume_in)
        AND upper(prenume) LIKE upper(p_prenume_in)
        AND isbn <p_isbn_in
        ORDER BY isbn desc
        )
    WHERE rownum <=5 order by isbn asc;
    v_rezultat    VARCHAR2(32000);
    v_isbn_limita NUMBER := p_isbn_in;
    v_count       NUMBER :=0;
  BEGIN
    FOR carte IN pagina(v_isbn_limita)
    LOOP
      v_count      :=v_count+1;
      IF v_count    = 1 THEN
        p_isbn_out := carte.isbn;
      END IF;
      v_rezultat := v_rezultat || gestioneaza_carte.afiseaza_carte(carte.isbn,p_HTML);
    END LOOP;
    RETURN v_rezultat;
  END paginare_autori_back;
END paginare;
/
DECLARE
  v_isbn NUMBER;
BEGIN
  dbms_output.put_line(paginare.paginare_autori_next('A%','B%',NULL,1,v_isbn));
  dbms_output.put_line(v_isbn);
  dbms_output.put_line(paginare.paginare_autori_back('A%','B%',6706,1,v_isbn));
  dbms_output.put_line(v_isbn);
END;
/
DECLARE
  v_isbn NUMBER;
BEGIN
  dbms_output.put_line(paginare.paginare_opere_next('S%',NULL,1,v_isbn));
  dbms_output.put_line(v_isbn);
  dbms_output.put_line(paginare.paginare_opere_back('S%',49,1,v_isbn));
  dbms_output.put_line(v_isbn);
END;
/
DECLARE
  v_isbn   NUMBER;
  v_rating NUMBER;
BEGIN
  dbms_output.put_line(paginare.paginare_carti_next(10,null,1,v_rating,v_isbn));
  dbms_output.put_line(paginare.paginare_carti_next(10,v_isbn,1,v_rating,v_isbn));
  dbms_output.put_line(v_isbn|| ' ' ||v_rating);
  dbms_output.put_line(paginare.paginare_carti_back(10,v_isbn,1,v_rating,v_isbn));
  dbms_output.put_line(v_isbn|| ' ' ||v_rating);
END;
/

commit;