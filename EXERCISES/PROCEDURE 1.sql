CREATE OR REPLACE PROCEDURE pl ( 
  cadena VARCHAR2
)
AS
BEGIN
   dbms_output.put_line(cadena);
END;
/


DROP TABLE reg_errores;
DROP SEQUENCE sq_errores;

--------------------------------------------------------
--  DDL for Table reg_errores
--------------------------------------------------------
CREATE SEQUENCE sq_errores;
CREATE TABLE reg_errores (
  numero_error NUMBER (6),
  id_empleado NUMBER,
  descripcion varchar2(300),
  numeroymensajedeerror VARCHAR2 (300),
  CONSTRAINT pk_reg_errores PRIMARY KEY (numero_error)
);

-- CASO 1
DECLARE
   lid NUMBER(6) := &lid;
   lfname VARCHAR2(20) := '&lfname';
   llname VARCHAR2(20) := '&llname';
   lemail VARCHAR2(20) := '&lemail';
   lphone VARCHAR2(20) := '&lphone';
   lhdate DATE := '&lhdate';
   ltrab VARCHAR2(10) := '&ltrab';
   lsueldo NUMBER(8,2) := &lsueldo;
   lcomis NUMBER(3,1) := &lcomis;
   lmanager NUMBER := &lmanager;
   ldepto NUMBER := &ldepto;
   e_msg VARCHAR2(300);
   descr VARCHAR2(300);
BEGIN
   BEGIN
      INSERT INTO employees VALUES (lid, lfname, llname, lemail, lphone,
      lhdate, ltrab, lsueldo, lcomis, lmanager, ldepto);
   EXCEPTION
      WHEN OTHERS THEN
        e_msg := sqlerrm;     
        IF SQLCODE = -1 THEN
           descr := 'Se intentó insertar un valor de clave primaria existente';
        ELSIF SQLCODE = -2291 THEN
           descr := 'Se intentó insertar un valor de clave foránea inexistente';
        ELSIF SQLCODE = -2290 THEN
           descr := 'Se intentó insertar un sueldo inferior al requerido';
        ELSIF SQLCODE = -1400 THEN
           descr := 'Se intentó insertar un nulo en una columna obligatoria';
        END IF;
        INSERT INTO REG_ERRORES
        VALUES (sq_errores.nextval, lid, descr, e_msg); 
   END;      
END;
/

-- DATOS PARA LA PRUEBA:
/*(100,'HARRISON','BLOOM','HABLOOM','12457893','17/01/2014','AD_PRES',2500,0.2,101,90);

(666,'HARRISON','BLOOM','HABLOOM','12457893','17/01/2014','AD_PRES',2500,NULL,101,99);

(666,'HARRISON','BLOOM',NULL,'12457893','17/01/2014','AD_PRES',2500,NULL,101,99);

(666,'HARRISON','BLOOM','HABLOOM','12457893','17/01/2014','AD_PRES',0,NULL,101,90);
*/

-- CASO 2

DROP TABLE errores_oracle;
CREATE TABLE errores_oracle (
  code NUMBER,
  message VARCHAR2(350)
);

DECLARE
   msg VARCHAR2(400);
BEGIN
   FOR i IN -33420..0 LOOP
      msg := sqlerrm(i);
      IF msg NOT LIKE '%Message%not found%' THEN
          INSERT INTO ERRORES_ORACLE
          VALUES (i, msg);
      END IF;    
   END LOOP;
END;
/

-- CASO 3

DECLARE
   CURSOR c1 IS
   SELECT *
   FROM employees
   WHERE salary <= 4500;
   lpct NUMBER;
   laumento NUMBER;
   lsueldoaumentado NUMBER;
BEGIN
   -- procesamos la filas del cursor
   DELETE FROM ERRORES_AUMENTO_SALARIOS;
   DELETE FROM aumento_salario;
   FOR r1 IN c1 LOOP
      BEGIN       
        SELECT porc_aumento
        INTO lpct
        FROM rango_aumento
        WHERE r1.salary BETWEEN salario_inferior AND salario_superior;      
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             INSERT INTO ERRORES_AUMENTO_SALARIOS
             VALUES (r1.employee_id, 
                     'El salario ' || r1.salary || 
                     'no existe entre los rangos de la tabla RANGO_AUMENTO');                     
      END;      
      laumento := r1.salary * lpct;
      lsueldoaumentado := r1.salary + laumento;
/*      pl(r1.employee_id 
         || ' ' || r1.last_name || ' ' || r1.first_name
         || ' ' || r1.salary
         || ' ' || laumento
         || ' ' || lsueldoaumentado         
         );
*/
     INSERT INTO aumento_salario
     VALUES (r1.employee_id,
             r1.salary,
             laumento,
             lsueldoaumentado);
   END LOOP;
END;
/

-- CASO 4

DECLARE
   CURSOR c1 IS
   SELECT *
   FROM employees;
   
   CURSOR c2 (n number) IS
   SELECT * 
   FROM cargas_familiares
   WHERE employee_id = n;
   lasicostovida NUMBER := 0;
   lanti NUMBER;
   lcomis NUMBER;
   lmontocargas NUMBER;
   lacum_cargas NUMBER := 0;
   ledad NUMBER;
   lcolacion constant NUMBER(3) := 700;
   lmovi constant NUMBER(3) := 300;   
   lpctasi NUMBER;
   lasignacion NUMBER := 0;
   lpais COUNTRIES.COUNTRY_NAME%TYPE;
   lhaberes NUMBER := 0;
   ldescuentos NUMBER := 0;
   ltotal NUMBER := 0;
   lprevi NUMBER := 0;
   lsalud NUMBER := 0;
BEGIN
   DELETE FROM haber_calc_mes;
   DELETE FROM descuento_calc_mes;
   DELETE FROM total_calc_mes;
   DELETE FROM error_calc_remun;
   
   FOR r1 IN c1 LOOP
      lcomis := r1.salary * nvl(r1.commission_pct,0);     
      lacum_cargas := 0;
      FOR r2 IN c2(r1.employee_id) LOOP
        ledad := EXTRACT(YEAR FROM SYSDATE) -
                 EXTRACT(YEAR FROM r2.fecha_nacimiento);       
        BEGIN
          SELECT valor_carga
          INTO lmontocargas
          FROM tramo_pago_cargas
          WHERE ledad BETWEEN edad_inferior AND edad_superior;
          lacum_cargas := lacum_cargas + lmontocargas;
          EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               INSERT INTO ERROR_CALC_REMUN
               VALUES (SEQ_ERROR_CALC_REMUN.NEXTVAL,
                       R1.EMPLOYEE_ID,
                       'Se encontró más de un valor en la tabla tramo_pago_cargas para la carga consultada');            
               lacum_cargas := 0;
        END;        
      END LOOP;     
      
      -- calcula asignacion por antiguedad
      lanti := EXTRACT(YEAR FROM SYSDATE) -
               EXTRACT(YEAR FROM r1.hire_date);   
               
      IF lanti > 9 AND r1.salary <= 10000 THEN
         BEGIN
           SELECT porcentaje
           INTO lpctasi
           FROM asignacion
           WHERE r1.salary BETWEEN salario_inferior AND salario_superior
           AND antiguedad = lanti;         
           lasignacion := round(r1.salary * lpctasi);
         EXCEPTION 
           WHEN NO_DATA_FOUND THEN
              INSERT INTO error_calc_remun
              VALUES (seq_error_calc_remun.nextval, r1.employee_id,
                    'No se encontró porcentaje en la tabla ASIGNACION ' ||
                    'para la combinación de antiguedad v/s salario');           
         END;
      END IF;

      BEGIN
        SELECT co.country_name
        INTO lpais
        FROM employees e JOIN departments d ON d.department_id = e.department_id
        JOIN locations l ON d.location_id = l.location_id
        JOIN countries co ON l.country_id = co.country_id
        WHERE e.employee_id = r1.employee_id;
        IF lpais = 'Germany' THEN
           lasicostovida := r1.salary * .8;
          ELSIF lpais = 'Canadá' THEN
           lasicostovida := r1.salary * .5;
        ELSE
           lasicostovida := r1.salary * .3;
        END IF;       
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
           INSERT INTO error_calc_remun
           VALUES (seq_error_calc_remun.nextval, r1.employee_id,
                 'No se encontró departamento para el empleado '
                 || r1.first_name || ' ' || r1.last_name);   
           lasicostovida := 0;           
     END;
      lhaberes := r1.salary + lcomis + lacum_cargas + lcolacion + lmovi +
                  lasignacion + lasicostovida;
      lprevi := (r1.salary + lcomis) * .062;
      lsalud := (r1.salary + lcomis) * .0145;
      ldescuentos := lprevi + lsalud;
      ltotal := lhaberes - ldescuentos;
      pl(r1.employee_id
         || ' ' || r1.salary
         || ' ' || lcomis
         || ' ' || lacum_cargas
         || ' ' || lcolacion
         || ' ' || lmovi
         || ' ' || lasignacion
         || ' ' || lasicostovida
      );
      INSERT INTO haber_calc_mes 
      VALUES(r1.employee_id, r1.salary, lcomis, lacum_cargas, lcolacion, lmovi,
             lasignacion, lasicostovida);
      INSERT INTO descuento_calc_mes
      VALUES (r1.employee_id, lprevi, lsalud);
      INSERT INTO total_calc_mes
      VALUES (r1.employee_id, lhaberes, ldescuentos, lhaberes-ldescuentos);
   END LOOP;    
END;



