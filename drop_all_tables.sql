BEGIN
   FOR cur_rec IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE "' || cur_rec.table_name || '" CASCADE CONSTRAINTS PURGE';
   END LOOP;
END;
/
