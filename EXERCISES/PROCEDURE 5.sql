CREATE OR REPLACE PROCEDURE PL (CADENA VARCHAR2) AS
BEGIN
 DBMS_OUTPUT.PUT_LINE(CADENA);
END PL;
/





DECLARE

CURSOR C1 IS 
SELECT E.EMPLOYEE_ID, E.SALARY, C.FECHA_NACIMIENTO
FROM EMPLOYEES E LEFT JOIN CARGAS_FAMILIARES C ON 
    E.EMPLOYEE_ID = C.EMPLOYEE_ID
ORDER BY E.EMPLOYEE_ID;
    

CURSOR C2 IS 
SELECT *
FROM TRAMO_PAGO_CARGAS;

ED_CARGA NUMBER(10);
CARGA NUMBER(10);
CARGATRAMOID NUMBER(10);

BEGIN
FOR R1 IN C1 LOOP
IF R1.FECHA_NACIMIENTO IS NULL 
     THEN ED_CARGA :=0; 
ELSIF R1.FECHA_NACIMIENTO IS NOT NULL 
      THEN ED_CARGA := ROUND((TO_DATE('01/01/2014')- R1.FECHA_NACIMIENTO)/365);
END IF;

FOR R2 IN C2 LOOP
    CASE ED_CARGA
    WHEN R2.EDAD_INFERIOR <0 
    
    
    THEN PL();
    
    
    END CASE;
  
END LOOP;
   PL(CARGATRAMOID || ' ' ||R1.EMPLOYEE_ID || ' ' || CARGA || ' ' || ED_CARGA);
    
END LOOP; 
END;
/

SELECT *
FROM TRAMO_PAGO_CARGAS;

    IF ED_CARGA = R2.EDAD_INFERIOR  AND R2.EDAD_SUPERIOR 
               AND R1.FECHA_NACIMIENTO IS NOT NULL THEN 
     CARGA := R2.VALOR_CARGA;
     CARGATRAMOID := R2.ID_TRAMO_PAGO;
   ELSIF R1.FECHA_NACIMIENTO IS NULL 
         THEN CARGA :=0; 
  END IF;
  
    