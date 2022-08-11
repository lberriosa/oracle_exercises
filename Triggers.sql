-- DEMO DE DISPARADORES O TRIGGERS
-- SINTAXIS DE UN TRIGGER

/*
1.- IMPLEMENTAR RESTRICCIONES COMPLEJAS
2.- AUDITORIA
3.- SALVAR DATOS HISTORICOS

*/

/*
CREATE OR REPLACE TRIGGER TR_NOMBRETRIGGER
CLAUSULA_DE_TIEMPO EVENTO OR EVENTO ON NOMBRETABLA
REFERENCING OLD AS NOMBRE | NEW AS NOMBRE
:NEW. -------> ACCESO A CAMPOS DE LA INSTRUCCION(INSERT,UPDATE)
:OLD. -------> ACCESO A CAMPOS ALMACENADOS EN LA TABLA (DELETE, UPDATE) 

WHEN (CONDICION)
FOR EACH ROW
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
              QUE CUMPLEN LA CONDICION

*/

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

CREATE OR REPLACE TRIGGER TR_ANULATRANSA
BEFORE INSERT ON EMPLOYEES
-- QUEDA ASOCIADO A EMPLEADOS
DECLARE 

BEGIN
IF TO_CHAR(SYSDATE, 'FMDAY') IN ('MARTES','JUEVES') OR 
   (TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00') THEN 
 --ANULAMOS LA TRANSACCION
 RAISE_APPLICATION_ERROR(-20001,'CHUPALO AWEONAO NO PODI HACER ESTO BASTARDO JOLAPEEERRRA');
 END IF;
END TR_ANULATRANSA;
/


INSERT INTO EMPLOYEES
VALUES (EMPLOYEES_SEQ.NEXTVAL, 'GUERRA', 'PAZ',
        'PGUERRA', '987655672', '01022000',
        'IT_PROG', 10000, NULL, 120, 50);

-- TRIGGER QUE AUDITA LAS ACCIONES DML EN LA TABLA EMPLOYEES
-- USO DE LOS PREDICADOS BOOLEANOS
DROP TABLE AUDITA_EMPLOYEES;
CREATE TABLE AUDITA_EMPLOYEES (
  FECHA TIMESTAMP,
  USUARIO VARCHAR2(30),
  ACCION CHAR
);


CREATE OR REPLACE TRIGGER TR_ENTEROSAPO1
AFTER INSERT OR UPDATE OR DELETE ON EMPLOYEES
DECLARE
L_ACCION CHAR(1);

BEGIN
IF INSERTING THEN
L_ACCION := 'I';
ELSIF DELETING THEN
L_ACCION := 'D';
ELSE 
L_ACCION := 'U';
END IF;
INSERT INTO AUDITA_EMPLOYEES 
VALUES(SYSDATE,USER,L_ACCION);
END TR_ENTEROSAPO1;
/

ALTER TRIGGER TR_ANULATRANSA DISABLE;


INSERT INTO EMPLOYEES
VALUES (EMPLOYEES_SEQ.NEXTVAL, 'GUERRA', 'PAZ',
        'PGUERRA', '987655672', '01022000',
        'IT_PROG', 10000, NULL, 120, 50);
        
        
UPDATE EMPLOYEES
SET SALARY = SALARY * 1.2 
WHERE EMAIL = 'PGUERRA';

DELETE FROM EMPLOYEES
WHERE EMAIL ='PGUERRA';

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


CREATE OR REPLACE TRIGGER TR_ENTEROSAPO2
AFTER INSERT OR UPDATE OR DELETE ON EMPLOYEES
FOR EACH ROW

DECLARE
V_ACCION CHAR(1);
V_OBS VARCHAR2(500);
BEGIN 
IF INSERTING THEN 
V_ACCION := 'I';
V_OBS := 'SE INSERTO EL EMPLEADO '|| :NEW.LAST_NAME|| ' '|| :NEW.FIRST_NAME ||' CUYA ID ES '|| :NEW.EMPLOYEE_ID;
ELSIF UPDATING THEN 
V_ACCION := 'U';
V_OBS := 'SE MODIFICO EL SALARIO DEL EMPLEADO CON ID  '|| :NEW.EMPLOYEE_ID || ' DESDE EL VALOR $'|| :OLD.SALARY || ' AL VALOR $  ' || :NEW.SALARY;
ELSE
V_ACCION := 'D';
V_OBS := 'SE ELIMINO EL EMPLEADO '|| :NEW.LAST_NAME|| ' '|| :NEW.FIRST_NAME ||' CUYA ID ES '|| :NEW.EMPLOYEE_ID;
END IF;

INSERT INTO AUDIT_CHANGES
VALUES(SYSDATE,USER,V_ACCION,V_OBS);

END TR_ENTEROSAPO2;
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


CREATE OR REPLACE TRIGGER TR_SUPERVISOR 
AFTER INSERT OR DELETE OR UPDATE OF MANAGER_ID ON EMPLOYEES
FOR EACH ROW
DECLARE 
BEGIN 
IF INSERTING THEN 
UPDATE SUPERVISOR 
SET EMPLEADOS = EMPLEADOS + 1,
    BONIFICACION = BONIFICACION+150
WHERE MANAGER_ID = :NEW.MANAGER_ID;

ELSIF DELETING THEN 
UPDATE SUPERVISOR 
SET EMPLEADOS = EMPLEADOS - 1,
    BONIFICACION = BONIFICACION - 150
WHERE MANAGER_ID = :OLD.MANAGER_ID;

ELSE
UPDATE SUPERVISOR 
SET EMPLEADOS = EMPLEADOS + 1,
    BONIFICACION = BONIFICACION+150
WHERE MANAGER_ID = :NEW.MANAGER_ID;

UPDATE SUPERVISOR 
SET EMPLEADOS = EMPLEADOS - 1,
    BONIFICACION = BONIFICACION - 150
WHERE MANAGER_ID = :OLD.MANAGER_ID;
END IF;
END TR_SUPERVISOR;
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

------------------------------------------------------------------------------

------------------------------------------------------------------------------

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


CREATE OR REPLACE TRIGGER TR_HONORARIOS
AFTER INSERT OR UPDATE OF ASIGNACION OR DELETE ON HONORARIOS
FOR EACH ROW 
DECLARE
BEGIN 
IF INSERTING THEN 
UPDATE EMPLOYEES 
SET SALARY = SALARY + :NEW.ASIGNACION
WHERE EMPLOYEE_ID = :NEW.EMPLOYEE_ID;

ELSIF DELETING THEN 
UPDATE EMPLOYEES 
SET SALARY = SALARY - :OLD.ASIGNACION
WHERE EMPLOYEE_ID = :OLD.EMPLOYEE_ID;

ELSE 
UPDATE EMPLOYEES 
SET SALARY = SALARY + (:NEW.ASIGNACION - :OLD.ASIGNACION)
WHERE EMPLOYEE_ID = :OLD.EMPLOYEE_ID;
END IF;

END;
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



