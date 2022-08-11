CREATE OR REPLACE PROCEDURE pl (
  cadena VARCHAR2
) AS
BEGIN
   dbms_output.put_line(cadena);
END pl;
/

-- EJEMPLO DE BLOQUES ANIDADOS
<<externo>>
 DECLARE
   current_block VARCHAR2(10) := 'Outer';
   outer_block   VARCHAR2(10) := 'Outer';
   num NUMBER(8) := 2000; 
 BEGIN
   pl('[Bloque actual]['||current_block||']');
   pl('[Numero en el Bloque actual]['|| num ||']');
   DECLARE
     current_block VARCHAR2(10) := 'Inner';
     inner_block VARCHAR2(10) := 'Inner';
     num NUMBER(8) := 2000 * 30; 
   BEGIN
     pl('[Bloque actual]['||current_block||']');
     pl('[Bloque externo]['||outer_block||']');
     pl('[Numero en el Bloque actual]['|| num ||']');
     -- usamos un calificador para llamar a la variable externa
     pl('[Numero en el Bloque externo]['|| externo.num ||']');
   END;
   pl('[Bloque actual]['||current_block||']');
   pl('[Bloque actual]['||inner_block||']');
 END;
 /
 
-- determina las horas de sobretiempo de un empleado
-- demo de un IF SIMPLE
SET VERIFY OFF;
DECLARE
  lhoraslimite NUMBER := 180;
  lhorastrabajadas NUMBER;
  lsobretiempo NUMBER := 0;
BEGIN
  SELECT s.horastrabajadas
  INTO lhorastrabajadas
  FROM empleado e JOIN sobretiempo s USING (rutemp)
  WHERE rutemp = '&RUT_DEL_EMPLEADO';
  IF lhorastrabajadas > lhoraslimite THEN
    lsobretiempo := lhorastrabajadas - lhoraslimite;
       pl('Horas de sobtretiempo = ' || lsobretiempo);
  END IF;
END;
/
-- IF CON CASO CONTRARIO
DECLARE
  v_cargas NUMBER;
  v_nombre VARCHAR2(50);
  v_bono NUMBER;
BEGIN
  SELECT nombres || ' ' || apellidos, cargas INTO v_nombre, v_cargas
  FROM empleado WHERE rutemp = '&RUT_DEL_EMPLEADO';   
  IF v_cargas > 3 THEN  
     v_bono := 50000;
  ELSE 
     v_bono := 70000;  
  END IF;
  pl('El empleado ' || v_nombre || '  tiene ' || v_cargas || ' cargas ' 
     || ' y recibirá un bono de $' ||  to_char(v_bono * v_cargas,'999g999'));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       pl('Empleado inexistente');
END;
/

-- Usando IF...ELSIF para determinar la evaluación del empleado
DECLARE
   lpuntaje NUMBER;
   lcat CHAR(1);
BEGIN
   SELECT puntaje INTO lpuntaje
   FROM empleado WHERE rutemp = '&RUT_DEL_EMPLEADO';
   IF lpuntaje >= 500 THEN lcat := 'A';
     ELSIF lpuntaje >= 400 THEN lcat := 'B';
     ELSIF lpuntaje >= 300 THEN lcat := 'C';
     ELSIF lpuntaje >= 100 THEN lcat := 'D';
   ELSE lcat := 'E';
   END IF;
   pl('Tú estás categorizado en LISTA: ' || lcat);
END;
/

-- USANDO CASE COMO EXPRESION
DECLARE
   lpuntaje NUMBER;
   lcat CHAR(1);
BEGIN
   SELECT puntaje INTO lpuntaje
   FROM empleado WHERE rutemp = '&INGRESE_RUT_DEL_EMPLEADO';
   lcat := 
   CASE 
     WHEN lpuntaje >= 500 THEN 'A'
     WHEN lpuntaje >= 400 THEN 'B'
     WHEN lpuntaje >= 300 THEN 'C'
     WHEN lpuntaje >= 100 THEN 'D'       
     ELSE 'E'
   END;     
   pl('Tú estás categorizado en LISTA: ' || lcat);
END;
/

-- SENTENCIA CASE
DECLARE
   lpuntaje NUMBER;
   lrut VARCHAR2(10) := '&RUT_DEL_EMPLEADO';
BEGIN
   SELECT puntaje INTO lpuntaje
   FROM empleado WHERE rutemp = lrut;
   CASE 
     WHEN lpuntaje >= 500 THEN 
         UPDATE empleado SET sueldo = ROUND(sueldo * 1.5)
         WHERE rutemp = lrut;
     WHEN lpuntaje >= 400 THEN 
         UPDATE empleado SET sueldo = ROUND(sueldo * 1.3)
         WHERE rutemp = lrut;
     ELSE 
        dbms_output.put_line('No corresponde reajuste');
   END CASE;     
END;
/

-- INSTRUCCIONES ITERATIVAS
-- DEMO DE UN LOOP BASICO
DECLARE
  vcounter NUMBER := 1;
BEGIN
  DELETE FROM PROYECTO;
  LOOP 
    EXIT WHEN vcounter > 10;
    INSERT INTO proyecto
    VALUES (vcounter, 'Proyecto ' || vcounter);
    vcounter := vcounter + 1; 
  END LOOP;
END;
/
-- USO DE LA INSTRUCCION WHILE
DECLARE
  vcounter NUMBER := 1;
BEGIN
  DELETE FROM TAREA;
  WHILE vcounter <= 50 LOOP 
    INSERT INTO tarea
    VALUES (vcounter, 'Tarea ' || vcounter, SYSDATE,
            trunc(dbms_random.VALUE(0,200)),
            trunc(dbms_random.VALUE(0,100)),
            trunc(dbms_random.VALUE(0,2000000)),
            1
            );
    vcounter := vcounter + 1; 
  END LOOP;
END;
/
-- DEMO DE LA INSTRUCCION FOR
BEGIN
  DELETE FROM TAREA;
  FOR i IN 1..50 LOOP 
    INSERT INTO tarea
    VALUES (i, 'Tarea ' || i, SYSDATE,
            trunc(dbms_random.VALUE(0,200)),
            trunc(dbms_random.VALUE(0,100)),
            trunc(dbms_random.VALUE(0,2000000)),
            1
            );
  END LOOP;
END;
/

--- for anidado
BEGIN
   FOR i IN REVERSE 1..10 LOOP
      FOR j IN  REVERSE 1..10 LOOP
         pl (i || ' X ' || j || ' = ' || i * j);
      END LOOP ;
   END LOOP;   
END;
/



















 
 
 
 
 
 
 
 