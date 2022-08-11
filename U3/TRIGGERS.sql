-- DEMO DE DISPARADORES O TRIGGERS (A NIVEL DE SENTECIA O A NIVEL DE FILA)
-- 1.IMPLEMENTAR RESTRICCIONES COMPLEJAS
-- 2.AUDITORIA
-- 3.SALVAR DATOS HISTORICOS

--PSEUDO COLUMNAS --> :NEW --> ACCESO A CAMPOS DE LA INSTRUCCIÓN 
                  --> :OLD --> ACCESO A CAMPOS ALMACENADOS EN LA TABLA
--INSERT SOLO PERMITE :NEW
--OLD SOLO PERMITE :OLD
--UPDATE PERMITE :NEW Y :OLD

-- SINTAXIS DE UN TRIGGER
/*CREATE OR REPLACE TRIGGER TR_NOMBRETRIGGER
CLAUSULA_DE_TIEMPO EVENTO OR EVENTO ON NOMBRETABLA
REFERENCING OLD AS NOMBRE | NEW AS NOMBRE
WHEN (CONDICION)
FOR EACH ROW --A NIVEL DE FILA (NO EXISTE A NIVEL DE SENTENCIA)
DECLARE
BEGIN
END;

CLAUSULA_DE_TIEMPO = BEFORE | AFTER | INSTEAD OF
EVENTO = INSERT | UPDATE | DELETE
NOMBRE_TABLA = TABLA ASOCIADA AL TRIGGER
REFERENCING = ASIGNA UN NUEVO NOMBRE A LAS PSEUDOCOLUMNAS 
              OLD Y NEW
              :NEW DA ACCESO A LOS VALORES DE LA FILA ACTUAL
              :NEW.EMPLOYEE_ID
              :OLD DA ACCESO A LOS VALORES ALMACENADOS EN LA TABLA
              :OLD.EMPLOYEE_ID
WHEN (CONDICION) = EL TRIGGER SE EJECUTA SOLO PARA LAS FILAS
              QUE CUMPLEN LA CONDICION*/


CREATE OR REPLACE PROCEDURE pl (
  cadena VARCHAR2 
)
AS
BEGIN
  dbms_output.put_line(cadena);
END;
/

-- TRIGGER QUE IMPIDE LA CONTRATACION DE PERSONAS LOS 
-- DIAS MARTES Y JUEVES Y EN HORARIO NO LABORABLE 
-- (ANTES DE LAS 8 y DESPUES DE LAS 18:00)
CREATE OR REPLACE TRIGGER tr_anulatransa
BEFORE INSERT ON employees 
DECLARE
BEGIN
  IF TO_CHAR(SYSDATE, 'fmday') IN ('MARTES','JUEVES') OR
  (TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00') THEN
    --ANULACIÓN DE TRANSACCIÓN (-20000 hasta -20999 RANGO RAISE_APPLICATION_ERROR) 
    RAISE_APPLICATION_ERROR(-20001,'NO ES POSIBLE CONTRATAR EN DÍAS Y HORARIOS NO LABORALES.');
  END IF;   
END tr_anulatransa;
/
INSERT INTO EMPLOYEES
VALUES (EMPLOYEES_SEQ.NEXTVAL, 'GUERRA', 'PAZ', 'PGUERRA', '987655672', '01022000', 'IT_PROG', 10000, NULL, 120, 50);        

-- TRIGGER QUE AUDITA LAS ACCIONES DML EN LA TABLA EMPLOYEES
-- USO DE LOS PREDICADOS BOOLEANOS
DROP TABLE AUDITA_EMPLOYEES;
CREATE TABLE AUDITA_EMPLOYEES (
  FECHA TIMESTAMP,
  USUARIO VARCHAR2(30),
  ACCION CHAR
);

CREATE OR REPLACE TRIGGER tr_sapo
AFTER INSERT OR UPDATE OR DELETE ON employees
DECLARE
  laccion CHAR(1);
BEGIN
  IF inserting THEN 
    laccion := 'I';
  ELSIF deleting THEN
    laccion := 'D';
  ELSE
    laccion := 'U';
  END IF;
  INSERT INTO audita_employees
  VALUES (SYSDATE, USER, laccion);
END tr_sapo;
/
ALTER TRIGGER tr_anulatransa DISABLE;

INSERT INTO EMPLOYEES
VALUES (EMPLOYEES_SEQ.NEXTVAL, 'GUERRA', 'PAZ', 'PGUERRA', '987655672', '01022000', 'IT_PROG', 10000, NULL, 120, 50);

UPDATE employees
SET salary = salary * 1.2
WHERE email = 'PGUERRA';

DELETE FROM employees
WHERE email = 'PGUERRA';

-- TRIGGER QUE AUDITA LAS ACCIONES DML EN LA TABLA EMPLOYEES
-- USO DE LOS PREDICADOS BOOLEANOS 
-- Y DE LAS PSEUDOCOLUMNAS NEW Y OLD
DROP TABLE audit_changes;
CREATE TABLE audit_changes (
   fecha TIMESTAMP,
   usuario VARCHAR2(30),
   accion CHAR,
   cambio_efectuado varchar2(500)
);
CREATE OR REPLACE TRIGGER tr_sapo2
AFTER INSERT OR UPDATE OF salary OR DELETE ON employees
FOR EACH ROW
DECLARE
  v_accion CHAR(1);
  v_obs VARCHAR2(500);
BEGIN
  IF inserting THEN
    v_accion := 'I';
    v_obs := 'SE INSERTÓ EL EMPLEADO ' || :NEW.last_name || ' ' || :NEW.first_name || ' CUYA ID ES '|| :NEW.employee_id;
  ELSIF updating THEN
    v_accion := 'U';
    v_obs := 'SE MODIFICÓ EL EMPLEADO CON ID' || :OLD.EMPLOYEE_ID || ' DESDE EL VALOR $'||:OLD.salary||' AL VALOR $'||:NEW.salary;
  ELSE
    v_accion := 'D';
    v_obs := 'SE ELIMINÓ EL EMPLEADO ' || :OLD.last_name || ' ' || :OLD.first_name || ' CUYA ID ES '|| :OLD.employee_id;
  END IF;
  INSERT INTO audit_changes
  VALUES (sysdate, user, v_accion, v_obs);
END tr_sapo2;
/

INSERT INTO employees 
VALUES (employees_seq.nextval, 'Costa', 'Enrique', 'ECOSTA',
    '56735233', SYSDATE, 'SA_REP', 8500, .14, 145, 80);

UPDATE employees
SET salary = 9300
WHERE email = 'ECOSTA';

DELETE 
FROM EMPLOYEES 
WHERE EMAIL = 'ECOSTA';


-- TRIGGER QUE MODIFICA LA TABLA SUPERVISOR 
-- SI SE AGREGA UN EMPLEADO AL SUPERVISOR SE DEBE SUMAR 1 AL CAMPO EMPLEADOS
-- Y U$150 AL CAMPO BONIFICACION. SE DEBE PROCEDER AL REVES SI SE BORRA UN EMPLEADO
-- SI SE MODIFICA EL SUPERVISOR DE UN EMPLEADO SE DEBE QUITAR A QUIEN LO PIERDE Y
-- AGREGAR A QUIEN LO ASUME
DROP TABLE supervisor;
CREATE TABLE supervisor AS
SELECT manager_id, count(*) empleados, count(*) * 150 bonificacion
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id;

CREATE OR REPLACE TRIGGER tr_supervisor
AFTER INSERT OR DELETE OR UPDATE OF manager_id ON employees
FOR EACH ROW
DECLARE
BEGIN
  IF inserting THEN
    UPDATE supervisor
    SET empleados = empleados + 1,
        bonificacion = bonificacion  + 150
    WHERE manager_id = :NEW.manager_id;
  ELSIF deleting THEN
    UPDATE supervisor
    SET empleados = empleados - 1,
        bonificacion = bonificacion - 150
    WHERE manager_id = :OLD.manager_id;
  ELSE
    UPDATE supervisor
    SET empleados = empleados + 1,
        bonificacion = bonificacion + 150
    WHERE manager_id = :NEW.manager_id;
    UPDATE supervisor
    SET empleados = empleados - 1,
        bonificacion = bonificacion - 150
    WHERE manager_id = :OLD.manager_id;
  END IF;    
END tr_supervisor;
/
-- testeo del trigger
-- esta vez no debes desactivas el triger anterior
-- el supervisor 114 tiene 5 empleados a cargo y U$750 de bonificación
-- debe incrementarlos con esta inserción
INSERT INTO employees 
VALUES (employees_seq.nextval, 'Costa', 'Enrique', 'ECOSTA',
    '56735233', SYSDATE, 'SA_REP', 8500, .14, 114, 50);
-- luego de la inserción sube a 6 y U$900

-- una eliminación debe producir el efecto contrario
DELETE FROM employees
WHERE email = 'ECOSTA';
-- después de la eliminación el supervisor queda con 5 y U$150

-- en la actualización se debe agregar a quien se hace cargo del empleado
-- y rebajar en el caso de quien deja de ser su manager
-- el empleado con ID 184 tiene como jefe al supervisor con id 121 y se lo
-- pasaremos al supervisor con ID 114. Uno debe rebajar y el otro agregar
 
UPDATE employees
  SET manager_id = 114
WHERE employee_id = 184;


-- LOS EMPLEADOS GANAN UNA ASIGNACION ESPECIAL. CUANDO SE INSERTE UNA ASIGNACION
-- SE DEBE AGREGAR AL SUELDO EL MONTO DE ESA ASIGNACION. CUANDO SE ELIMINE
-- LA ASIGNACION SE DEBE QUITAR DEL SUELDO EL MONTO DE LA ASIGNACION
-- SI EL MONTO DE LA ASIGNACION SE MODIFICA SE DEBE RESTAR O SUMAR AL SUELDO LA DIFERENCIA
--ENTRE LA NUEVA Y LA VIEJA ASIGNACION
DROP TABLE honorarios;
CREATE TABLE HONORARIOS AS
SELECT EMPLOYEE_ID, department_id,  salary  asignacion 
FROM employees
WHERE 1 = 2;

CREATE OR REPLACE TRIGGER tr_honorario
AFTER INSERT OR UPDATE OF asignacion OR DELETE ON honorarios
FOR EACH ROW
DECLARE
BEGIN 
  IF inserting THEN
    UPDATE employees
    SET salary = salary + :NEW.asignacion
    WHERE employee_id = :NEW.employee_id;
  ELSIF deleting THEN
    UPDATE employees
    SET salary = salary - :OLD.asignacion
    WHERE employee_id = :OLD.employee_id;
  ELSE
    UPDATE employees
    SET salary = salary + (:NEW.asignacion - :OLD.asignacion)
    WHERE employee_id = :NEW.employee_id;
  END IF;
END tr_honorario;
/
-- testeo del trigger
SELECT * FROM honorarios;
SELECT employee_id, salary FROM employees WHERE employee_id IN (105,120);

INSERT INTO HONORARIOS
VALUES (105, 60, 300);

INSERT INTO HONORARIOS
VALUES (120, 50, 1000);

DELETE FROM HONORARIOS
WHERE EMPLOYEE_ID = 105;

SELECT employee_id, salary FROM employees WHERE employee_id IN (105,120);

UPDATE HONORARIOS 
  SET asignacion = 700
WHERE EMPLOYEE_ID = 120;

UPDATE HONORARIOS 
  SET asignacion = 1500
WHERE EMPLOYEE_ID = 120;



