CREATE OR REPLACE PROCEDURE PL (CADENA VARCHAR2) AS
BEGIN
 DBMS_OUTPUT.PUT_LINE(CADENA);
END PL;
/

DROP TABLE  REG_ERRORES;
CREATE TABLE  REG_ERRORES(
SEC_ERROR NUMBER(5) CONSTRAINT PK_SEC_ERROR PRIMARY KEY,
ID_EMPLEADO NUMBER(6),
DESCRIPCION VARCHAR2(300),
MENSAJEORACLE VARCHAR2(300)
); 

CREATE SEQUENCE ERR_CONT
  MINVALUE 1
  MAXVALUE 999999999999999999999999999
  START WITH 1
  INCREMENT BY 1
  CACHE 20;


DECLARE
LEMP_ID EMPLOYEES.EMPLOYEE_ID%TYPE    :=&ID_DE_EMPLEADO;
LFIR_NA EMPLOYEES.FIRST_NAME%TYPE     :='&NOMBRE_EMPLEADO';
LLAS_NA EMPLOYEES.LAST_NAME%TYPE      :='&APELLIDO_EMPLEADO';
lema_il employees.email%TYPE          :='&EMAIL_EMPLEADO';
LPHO_NE EMPLOYEES.PHONE_NUMBER%TYPE   :='&FONO_EMPLEADO';
LHIR_DT EMPLOYEES.HIRE_DATE%TYPE      :='&FECHA_CONTRATO_EMPLEADO';
LJOB_ID EMPLOYEES.JOB_ID%TYPE         :='&ID_DE_TRABAJO';
LSAL_RY EMPLOYEES.SALARY%TYPE         :=&SALARIO;
LCOM_PC EMPLOYEES.COMMISSION_PCT%TYPE :=&COMISION;
lman_id employees.manager_id%TYPE     :=&ID_DE_JEFE;
ldep_id employees.department_id%TYPE :=&ID_DE_DEPARTAMENTO;

ERR_NOT_NULL EXCEPTION;
PRAGMA EXCEPTION_INIT (ERR_NOT_NULL, -1400);

ERR_LLV_FOR EXCEPTION;
PRAGMA EXCEPTION_INIT (ERR_LLV_FOR, -2291);

ERR_SAL_MAY EXCEPTION;
ERR_SAL_CER EXCEPTION;

V_NUMERROR VARCHAR2(15);
V_MSGERROR VARCHAR2(200); 


BEGIN
IF LSAL_RY > 24000 THEN
RAISE err_sal_may;
elsif LSAL_RY <= 0 THEN
RAISE err_sal_cer;
ELSE

INSERT INTO employees 
VALUES (LEMP_ID,
        LFIR_NA,
        LLAS_NA,
        LEMA_IL,
        LPHO_NE,
        LHIR_DT,
        LJOB_ID,
        LSAL_RY,
        LCOM_PC,
        lman_id,
        LDEP_ID);
         
END IF;

EXCEPTION  
WHEN DUP_VAL_ON_INDEX THEN 
     V_NUMERROR := SQLCODE;
     V_MSGERROR := SQLERRM;
     INSERT INTO REG_ERRORES
     VALUES(ERR_CONT.NEXTVAL,
            LEMP_ID,
           'Se intento insertar un valor de clave primaria existente',
           V_NUMERROR ||' '||V_MSGERROR);
           
       PL('Se intento insertar un valor de clave primaria existente');    
           
WHEN ERR_NOT_NULL THEN
     V_NUMERROR := SQLCODE;
     V_MSGERROR := SQLERRM;
     INSERT INTO REG_ERRORES
     VALUES(ERR_CONT.NEXTVAL,
            LEMP_ID,
           'Intento insertar un nulo en una columna obligatoria',
           V_NUMERROR ||' '||V_MSGERROR);
           
      PL('Intento insertar un nulo en una columna obligatoria');     
           
WHEN ERR_LLV_FOR THEN
     V_NUMERROR := SQLCODE;
     V_MSGERROR := SQLERRM;
     INSERT INTO REG_ERRORES
     VALUES(ERR_CONT.NEXTVAL,
            LEMP_ID,
           'Intento insertar un valor de clave foranea inexistente',
           V_NUMERROR ||' '||V_MSGERROR);
           
      PL('Intento insertar un valor de clave foranea inexistente');     
           
WHEN ERR_SAL_MAY THEN 
    V_NUMERROR := SQLCODE;
    V_MSGERROR := SQLERRM;
     INSERT INTO REG_ERRORES
     VALUES(ERR_CONT.NEXTVAL,
            LEMP_ID,
           'Se intento insertar un sueldo superior al requerido',
           V_NUMERROR ||' '||V_MSGERROR);
           
       PL('Se intento insertar un sueldo superior al requerido');     
           
WHEN ERR_SAL_CER THEN 
    V_NUMERROR := SQLCODE;
    V_MSGERROR := SQLERRM;
     INSERT INTO REG_ERRORES
     VALUES(ERR_CONT.NEXTVAL,
            LEMP_ID,
           'Se intento insertar un sueldo inferior al requerido',
           V_NUMERROR ||' '||V_MSGERROR);
     
      PL('Se intento insertar un sueldo inferior al requerido');      
             
END;
/

