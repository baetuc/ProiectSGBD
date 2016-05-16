CREATE OR REPLACE PACKAGE exceptii IS
  constrangere EXCEPTION;
  constrangere_nr number := -20020;
  constrangere_text varchar2(1000) :='Eroare! V? rug?m s? verifica?i valoarea introdus? pentru ';
  PRAGMA EXCEPTION_INIT(constrangere, -2290);

  cheie_straina_gresita EXCEPTION;
  cheie_straina_gresita_nr number := -20019;
  pragma exception_init(cheie_straina_gresita, -2291);
  
  subgen_deja_existent EXCEPTION;
  subgen_deja_existent_nr number := -20006;
  subgen_deja_existent_text varchar2(1000) :='Eroare la introducere subgen! Subgenul exist? deja.';
  PRAGMA EXCEPTION_INIT(subgen_deja_existent, -20006);
  
  isbn_inexistent EXCEPTION;
  isbn_inexistent_nr number := -20009;
  isbn_inexistent_text varchar2(1000) := 'Eroare! V? rug?m s? verifica?i ISBN-ul.';
  PRAGMA EXCEPTION_INIT(isbn_inexistent, -20009);
  
  autor_inexistent EXCEPTION;
  autor_inexistent_nr number := -20011;
  autor_inexistent_text varchar2(1000) :='Eroare la ?tergere autor! V? rug?m s? verifica?i ID-ul autorului.';
  PRAGMA EXCEPTION_INIT(autor_inexistent, -20011);
  
  opera_inexistenta EXCEPTION;
  opera_inexistenta_nr number := -20013;
  opera_inexistenta_text varchar2(1000) := 'Eroare la ?tergere oper?! V? rug?m s? verifica?i ID-ul operei.';
  PRAGMA EXCEPTION_INIT(opera_inexistenta, -20013);
  
  subgen_inexistent EXCEPTION;
  subgen_inexistent_nr number := -20015;
  subgen_inexistent_text varchar2(1000) :='Eroare la ?tergere subgen! V? rug?m s? verifica?i subgenul.';
  PRAGMA EXCEPTION_INIT(subgen_inexistent, -20015);
END;
/
