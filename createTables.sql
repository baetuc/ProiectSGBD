DROP TABLE opere_autori;
/
DROP TABLE abordari;
/
DROP TABLE utilizator_carte_rating;
/
DROP TABLE carti;
/
DROP TABLE ierarhie;
/
DROP TABLE autori;
/
DROP TABLE opere;
/
DROP TABLE distante_utilizatori;
/
DROP TABLE utilizator_parola;
/
DROP TABLE citate;
/


CREATE TABLE opere (
  opID INTEGER PRIMARY KEY CHECK(opID > 0),
  titlu VARCHAR2(1000) NOT NULL,
  volum INTEGER CHECK(volum > 0)
);
/

CREATE TABLE carti (
  ISBN NUMBER PRIMARY KEY,
  editura VARCHAR2(50) NOT NULL,
  calea VARCHAR2(200),
  an_aparitie INTEGER NOT NULL,
  rating NUMBER CHECK(rating >= 1 AND rating <= 10),
  nr_rating NUMBER CHECK(nr_rating >= 0),
  opID INTEGER REFERENCES opere(opID) ON DELETE CASCADE NOT NULL
);
/

CREATE TABLE autori (
  autID INTEGER PRIMARY KEY,
  nume VARCHAR2(200),
  prenume VARCHAR2(200)
);
/

CREATE TABLE opere_autori (
  opID INTEGER REFERENCES opere(opID) ON DELETE CASCADE NOT NULL,
  autID INTEGER REFERENCES autori(autID) ON DELETE CASCADE NOT NULL,
  PRIMARY KEY (opID, autID)
);
/

CREATE TABLE ierarhie (
  subgen VARCHAR2(50) PRIMARY KEY,
  gen VARCHAR2(50) NOT NULL
);
/

CREATE TABLE abordari (
  opID INTEGER REFERENCES opere(opID) ON DELETE CASCADE NOT NULL,
  subgen VARCHAR2(50) REFERENCES ierarhie(subgen) ON DELETE CASCADE NOT NULL,
  PRIMARY KEY (opID, subgen)
);
/

CREATE TABLE utilizator_parola (
  utilizator VARCHAR2(100) PRIMARY KEY,
  parola VARCHAR2(100)
);
/

CREATE TABLE citate
  ( id NUMBER PRIMARY KEY, 
    text VARCHAR2(4000),
    autor varchar2(1000)
  );
  
CREATE TABLE distante_utilizatori (
  u1        VARCHAR2(100) REFERENCES utilizator_parola(utilizator) ON DELETE CASCADE,
  u2        VARCHAR2(100) REFERENCES utilizator_parola(utilizator) ON DELETE CASCADE,
  distanta  NUMBER,
  PRIMARY KEY (u1, u2)
  );
/

create table utilizator_carte_rating (
  utilizator varchar2(100) references utilizator_parola(utilizator),
  isbn number references carti(isbn),
  rating number check(rating>=1 and rating<=10) not null,
  primary key(utilizator,isbn)
);
/