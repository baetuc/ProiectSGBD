DROP INDEX nume_prenume_autor;
/
DROP INDEX titlu_volum;
/
DROP INDEX rating_ISBN;
/
drop index isbn_opID;
/

CREATE INDEX nume_prenume_autor ON autori
  (UPPER(nume), UPPER(prenume)
  );
/
CREATE INDEX titlu_volum ON opere
  (UPPER(titlu), volum 
  );
/
CREATE INDEX rating_ISBN ON carti
  (rating, ISBN
  );
/

CREATE INDEX isbn_opID ON carti
  (isbn,opID
  );
/
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'AUTORI', METHOD_OPT=>'for all indexed columns', CASCADE => true);
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'OPERE', METHOD_OPT=>'for all indexed columns', CASCADE => true);
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'CARTI', METHOD_OPT=>'for all indexed columns', CASCADE => true);
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'OPERE_AUTORI', METHOD_OPT=>'for all indexed columns', CASCADE => true);
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'IERARHIE', METHOD_OPT=>'for all indexed columns', CASCADE => true);
  DBMS_STATS.GATHER_TABLE_STATS(NULL, 'ABORDARI', METHOD_OPT=>'for all indexed columns', CASCADE => true);
END;
       /
--SELECT *
--FROM
--  (SELECT *
--  FROM carti
--  WHERE rating   <= 10
--  AND NOT (rating = 10
--  AND isbn       >= 1000000)
--  ORDER BY rating DESC,
--    isbn DESC
--  )
--WHERE rownum <=10; 
