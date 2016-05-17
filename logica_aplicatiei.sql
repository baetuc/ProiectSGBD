CREATE OR REPLACE PACKAGE logica_aplicatiei AS 
  FUNCTION login(
    p_utilizator IN utilizator_parola.utilizator%TYPE,
    p_parola     IN utilizator_parola.parola%TYPE)
  RETURN VARCHAR2;
  
  procedure citat_random(v_text out varchar2, v_autor out varchar2);
  
  -- Paginarea??
END logica_aplicatiei;
/

CREATE OR REPLACE PACKAGE BODY logica_aplicatiei AS
  FUNCTION login(
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
  
procedure citat_random(v_text out varchar2, v_autor out varchar2)
as
  v_max_id number;
  v_id number;
  v_count number;
begin
  select max(id) into v_max_id from citate;
  loop
    v_id:=trunc(DBMS_RANDOM.VALUE(1,v_max_id+1));
    select count(id) into v_count from citate where id=v_id;
    if v_count = 1 then
      select text,autor into v_text,v_autor from citate where id=v_id;
      return;
    end if;
  end loop;
end citat_random;


END logica_aplicatiei;
/