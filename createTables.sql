DROP TABLE opere_autori;
/
DROP TABLE abordari;
/
DROP TABLE carti;
/
DROP TABLE ierarhie;
/
DROP TABLE autori;
/
DROP TABLE opere;
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
  opID INTEGER REFERENCES opere(opID) ON DELETE CASCADE NOT NULL
);

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
    text VARCHAR2(1000)
  );
/