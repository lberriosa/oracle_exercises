create user alumno identified bu duoc;
grant connect, resource to alumno;
alter user hr account unlock;
alter user hr identified by hr;

--PRACTICA DE FUNCIONES DE UNA FILA

----FUNCIONES DE CARACTERES----
--LOWER - UPER - INITCAP (FUNCIONES DE CONVERSIÓN)
SELECT last_name || ' ' || first_name AS nombre,
  lower(last_name || ' ' || first_name) AS minusculas,
  upper(last_name || ' ' || first_name) AS mayusculas,
  initcap(last_name || ' ' || first_name) AS capitalizado
from employees;  

--CONCAT
SELECT concat(last_name, first_name) AS nombre
FROM employees;

--SUBSTR(EXTRAE UNA CADENA DE OTRA CADENA)
SELECT last_name || ' ' || first_name AS nombre,
  SUBSTR(last_name || ' ' || first_name, 3, 4 ) AS EXTRACCION_1,
  SUBSTR(last_name || ' ' || first_name, -3 ) AS EXTRACCION_1
FROM employees;  

--LENGTH(DEVUELVE UN ENTERO CON EL LARGO DE UNA CADENA)
SELECT last_name || ' ' || first_name AS nombre,
  LENGTH(last_name || ' ' || first_name) AS LARGO
FROM employees;  

--RTRIM --LTRIM (QUITAR ESPACIOS A LA IZQUERDA O LA DERECHA)
SELECT '      HUGO RIVERA       ',
  ltrim('      HUGO RIVERA       ') AS ESP_A_LA_IZQ,
  rtrim('      HUGO RIVERA       ') AS ESP_A_LA_DER,
  trim('      HUGO RIVERA       ') AS AMBOS,
  trim('H' from 'HUGO RIVERA') as SIN_H --SOLO SI SE ENCUENTRA AL PRINCIPIO O AL FINAL
FROM dual;  

--REPLACE (PERMITE REEMPLAZAR UNA CADENA POR OTRA)
SELECT last_name || ' ' || first_name AS nombre,
  REPLACE(last_name || ' ' || first_name, 'ar', 'ol') AS REEMPLAZO
FROM employees;  

--LPAD --RPAD
--PERMITEN RELLENAR UNA CADENA CON EL CARACTER ESPECIFICADO
--HASTA COMPLETAR LA CANTIDAD DE CARACTERES QUE SE INDIQUE
SELECT SALARY,
  LPAD(SALARY, 15, 0) AS RELLENO_IZQ,
  RPAD(SALARY, 15, 0) AS RELLENO_DER,
  LPAD(LAST_NAME, 15, '*') AS RELLENO_IZQ,
  RPAD(LAST_NAME, 15, '*') AS RELLENO_DER
FROM employees;  

--INSTR (PERMITE ENCONTRAR UNA CADENA DENTRO DE OTRA)
--DEVUELVE UN ENTERO CON LA POSICIÓN LOCALIZADA
SELECT last_name || ' ' || first_name AS nombre,
  INSTR(lower(last_name || ' ' || first_name), 'a', 1) AS BUSCA_PRIMERA_A,
  INSTR(lower(last_name || ' ' || first_name), 'a',
  INSTR(lower(last_name || ' ' || first_name),'a',1) + 1) AS BUSCA_A
FROM employees;  


----FUNCIONES DE NÚMERO----
-- ROUND -- TRUNC -- MOD
SELECT 912839182.612,
  TRUNC(912839182.612) T_SIN_DEC,
  ROUND(912839182.612) R_SIN_DEC,
  TRUNC(912839182.612, 1) T_CON_UN_DEC,
  ROUND(912839182.612, 1) R_CON_UN_DEC
FROM DUAL;

----FUNCIONES DE FECHA----
--MONTHS_BETWEEN (DEVUELVE EL NÚMERO DE MESES ENTRE FECHAS)
SELECT MONTHS_BETWEEN(SYSDATE, to_date('20-03-2015')) AS meses
FROM dual;

--ADD_MONTHS (AGREGA O RESTA MESES A UNA FECHA)
SELECT SYSDATE,
  add_months(SYSDATE, + 5) AS MAS_CINCO,
  add_months(SYSDATE, - 5) AS MENOS_CINCO
FROM DUAL;

--NEXT_DAY (DEVUELVE LA FECHA DEL DIA SIGUIENTE CONSULTADO)
--A PARTIR DE LA FECHA INDICADA
SELECT next_day(SYSDATE, 'domingo'),
  next_day(SYSDATE, 7),
  next_day(SYSDATE, 'miércoles')
FROM dual;  

--LAST_DAY
SELECT last_day(SYSDATE)
FROM dual;

----FUNCIONES DE CONVERSIÓN
--TO_CHAR (CONVIERTE NÚMERS Y FECHAS EN LITERALES DE FECHA)
SELECT SYSDATE,
  TO_CHAR(SYSDATE, 'dd-mm-yyyy') año_4_dig,
  TO_CHAR(SYSDATE, 'dd.mm.yyyy') año_4_dig_2,
  TO_CHAR(SYSDATE, 'd'),
  TO_CHAR(SYSDATE, 'dd'),
  TO_CHAR(SYSDATE, 'dy'),
  TO_CHAR(SYSDATE, 'ddd'),
  TO_CHAR(SYSDATE, 'day'),
  TO_CHAR(SYSDATE, 'DAY'),
  TO_CHAR(SYSDATE, 'Day'),
  TO_CHAR(SYSDATE, 'day dd "de" month "de" yyyy'),
  TO_CHAR(SYSDATE, 'fmday dd "de" month "de" yyyy')
FROM dual;

--TO_NUMBER
SELECT 19238 + '40' AS CONV_IMPLICITA,
  19238 + TO_NUMBER('40') AS CONV_EXPLICITA
FROM DUAL;

--TO_DATE
SELECT '01032017',
  to_date('01032017') + 4
FROM DUAL;  

--FORMATO DE NUMEROS
SELECT 9834764823.67,
  TO_CHAR(9834764823.67, '9g999g999g999d99'),
  TO_CHAR(9834764823.67, '$9g999g999g999d99'),
  TO_CHAR(9834764823.67, 'l9g999g999g999d99'),
  TO_CHAR(9834764823.67, '9,999,999,999.99')
FROM dual;  

----EXPRESIONES CONDICIONALES----
-- SE DESEA AUMENTAR EL SUELDO DE LOS EMPPLEADOS, SI EL EMPLEADO
-- ES DEL DEPARTAMENTO 30 EL AUMENTO SERÁ DE UN 20 %
-- DE UN 15% SI ES DEL DEPARTAMENTO 20, 
-- DE UN 10% SI ES DEL DEPARTAMENTO 50,
-- DE UN 5% SI ES DEL 80 Y
-- SIN AUMENTO EN CASO CONTRARIO.
SELECT last_name || ' ' || first_name AS nombre, salary AS sueldo,
  CASE department_id
    WHEN 30 THEN salary*1.2
    WHEN 20 THEN salary*1.15
    WHEN 50 THEN salary*1.1
    WHEN 80 THEN salary*1.05
    ELSE salary
  END "SUELDO AUMNETADO"
FROM employees;  
  
SELECT last_name || ' ' || first_name AS nombre, salary AS sueldo,
  DECODE (department_id,
    30, salary*1.2,
    20, salary*1.15,
    50, salary*1.1,
    80, salary*1.05,
    salary) "SUELDO AUMENTADO"
FROM employees;  
  


  
     