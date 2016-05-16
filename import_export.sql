SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE import_export
IS
  PROCEDURE export_database;
  PROCEDURE import_BD;
END import_export;
/

CREATE OR REPLACE PACKAGE BODY import_export
IS
  g_fisierID_import utl_file.file_type;
  g_linie_citita VARCHAR2(1000);
  
  PROCEDURE export_abordari
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'abordariExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'opID,subgen');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM abordari
    )
    LOOP
      Utl_File.Put_Line(out_file , '' || c_linie.opID || ',' || c_linie.subgen);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_abordari;
  
  PROCEDURE export_opere
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'opereExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'opID,titlu,volum');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM opere
    )
    LOOP
      Utl_File.Put_Line(out_file , '' || c_linie.opID || ',' || c_linie.titlu || ',' || c_linie.volum);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_opere;
  
  PROCEDURE export_carti
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'cartiExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'ISBN,editura,calea,an_aparitie,rating,opID');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM carti
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.ISBN || ',' || c_linie.editura || ',' || c_linie.calea || ',' || c_linie.an_aparitie || ',' || c_linie.rating || ',' || c_linie.opID);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_carti;
  
  PROCEDURE export_autori
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'autoriExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'autID,nume,prenume');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM autori
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.autID || ',' || c_linie.nume || ',' || c_linie.prenume);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_autori;
  
  PROCEDURE export_opere_autori
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'opere_autoriExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'opID,autID');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM opere_autori
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.opID || ',' || c_linie.autID);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_opere_autori;
  
  PROCEDURE export_ierarhie
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'ierarhieExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'subgen,gen');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM ierarhie
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.subgen || ',' || c_linie.gen);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_ierarhie;
  
  PROCEDURE export_utilizatori_parola
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'utilizator_parolaExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'utilizator,parola');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM utilizator_parola
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.utilizator || ',' || c_linie.parola);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_utilizatori_parola;

  PROCEDURE export_citate
  IS
    out_file UTL_FILE.FILE_TYPE;
  BEGIN
    out_file := Utl_File.FOpen('EXPORT', 'citateExport.csv' , 'W');
    Utl_File.Put_Line(out_file , 'id,text');
    UTL_FILE.FFLUSH (out_file);
    FOR c_linie IN
    (SELECT * FROM citate
    )
    LOOP
      Utl_File.Put_Line(out_file, '' || c_linie.id || ',' || c_linie.text);
      UTL_FILE.FFLUSH (out_file);
    END LOOP;
    UTL_FILE.FCLOSE(out_file);
  END export_citate;
  
  PROCEDURE export_database
  IS
  BEGIN
    export_abordari();
    export_opere();
    export_carti();
    export_autori();
    export_opere_autori();
    export_ierarhie();
    export_utilizatori_parola();
    export_citate();
  END export_database;
  
  PROCEDURE import_BD_tabel(
      p_fisier     VARCHAR2,
      p_nume_tabel VARCHAR2)
  AS
    v_insert VARCHAR2(2500);
    v_antet  VARCHAR2(1000);
  BEGIN
    g_fisierID_import := utl_file.fopen ('EXPORT', p_fisier, 'R');
    utl_file.get_line(g_fisierID_import,v_antet);
    LOOP
      utl_file.get_line(g_fisierID_import,g_linie_citita);
      g_linie_citita := '''' || REPLACE(REPLACE(g_linie_citita,'''',''''''),',',''',''') || '''';
      v_insert       := 'insert into ' || p_nume_tabel || '(' || v_antet || ') values(' || g_linie_citita || ')';
      --      dbms_output.put_line(v_insert);
      EXECUTE immediate v_insert;
      EXECUTE immediate 'commit';
    END LOOP;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    utl_file.fclose(g_fisierID_import);
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(v_insert);
    utl_file.fclose(g_fisierID_import);
  END import_BD_tabel;
  
  PROCEDURE import_BD
  AS
  BEGIN
    import_BD_tabel('opereExport.csv','opere');
    import_BD_tabel('cartiExport.csv','carti');
    import_BD_tabel('autoriExport.csv','autori');
    import_BD_tabel('opere_autoriExport.csv','opere_autori');
    import_BD_tabel('ierarhieExport.csv','ierarhie');
    import_BD_tabel('abordariExport.csv','abordari');
    import_BD_tabel('utilizator_parolaExport.csv', 'utilizator_parola');
    import_BD_tabel('citateExport.csv','citate');
  END import_BD;
END import_export;
/
BEGIN
  import_export.import_BD();
END;
/