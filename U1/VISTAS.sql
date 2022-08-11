--COMANDO CREATE TABLE, TRUNCATE (Y CADA COMANDO DDL) INCLUYE UN COMMIT �MPL�CITO!!

--PRACTICA DE VISTAS
--USOS : MOSTRAR LOS DATOS DE DIVERSAS FORMAS
--       PROTEGER LOS DATOS DE ACCESOS PELIGROSOS
--ESTRUCTURA: 
CREATE [OR REPLACE] [FORCE] [NO FORCE] VIEW nombre_vista [alias1, alias2, alias_n] AS subconsulta]
[WITH CHECK OPTION] [CONSTRAINT nombre_restriccion]
[with read only] [constraint nombre_restriccion];

--VISTAS SIMPLES : TRAEN DATOS DE UNA SOLA TABLA Y NO CONTIENEN FUNCIONES DE NINGUNA NATURALEZA,
--  SE RECUPERAN TODOS LOS DATOS QUE PERMITEN OPERACIONES DML. LAS OPERACIONES DML SE PUEDEN
--  EJECUTAR A TRAVES DE LA VISTA.

--VISTAS COMPLEJAS : RECUPERAN DATOS DE M�S DE UNA TABLA, CONTIENEN FUNCIONES DE TODO TIPO
--  NO SE RECUPERAN DATOS CLAVES. LAS OPERACIONES DML POR TANTO NO SE PUEDEN EJECUTAR A TRAV�S DE LA VISTA


--VISTAS SIMPLES
CREATE VIEW v_empleados1 AS
SELECT *
FROM empleado;
--OBTENER EL DICCIONARIO DE DATOS DE LA VISTA
DESC v_empleados1;
--OBSERVAR LOS DATOS
SELECT *
FROM v_empleados1
WHERE sueldo > 1800000;
--OPERACIONES DML EST�N PERMITIDAS, AFECTAN DIRECTAMENTE A LA TABLA (NO A LA VISTA)
UPDATE v_empleados1
  SET sueldo = sueldo * 1.2
WHERE rutemp = '121133694';
--CREAR UNA VISTA PARA RECUPERAR RUN, NOMBRE COMPLETO DEL EMPLEADO, PUNTAJE Y SUELDO
CREATE OR REPLACE VIEW v_empleados2 (run, nombre, puntaje, sueldo, oficina) AS --SE PUEDEN DEFINIR NOMBRES DE COLUMNAS ANTES DE LA CLAUSULA "AS"
SELECT rutemp,
  paterno || ' ' || materno || ' ' || nombre,
  puntaje,
  sueldo,
  numoficina
FROM empleado
WHERE numoficina = 130;
--
UPDATE v_empleados2
  SET sueldo = sueldo * 1.2
WHERE run = '117452443';
--
UPDATE v_empleados2
  SET oficina = 120
WHERE run = '117452443';



--VISTA COMPLEJA
SELECT * FROM v_empleados3;
--
CREATE OR REPLACE VIEW v_empleados3 AS
SELECT z.nomzona AS zona,
  sum(e.sueldo) "TOTAL SUELDOS",
  trunc(avg(e.sueldo)) "PROMEDIO SUELDOS",
  COUNT(*) "NUMERO EMPLEADOS"
FROM zona z JOIN empleado e
USING (idzona)
GROUP BY z.nomzona
ORDER BY z.nomzona;
--USO DE LA CLAUSULA WITH CHECK OPTION
--GARANTIZA QUE LAS FILAS RECUPERADAS POR LA VISTA
--SIEMPRE ESTEN DISPONIBLES
CREATE OR REPLACE VIEW v_empleados4 AS
SELECT rutemp AS run,
  paterno || ' ' || materno || ' ' || nombre AS nombre,
  puntaje,
  sueldo,
  numoficina
FROM empleado
WHERE numoficina = 120
WITH CHECK OPTION; --LA CREACI�N ORIGINAL DE LA VISTA ESTAR� SIEMPRE DISPONIBLE, SOLO SE PODR� ALTERAR DESDE LA VISTA.
--LA SIGUIENTE INSTRUCCI�N NO PODR� ALTERAR LA VISTA
UPDATE v_empleados4
  SET NUMoficina = 130
WHERE run = '121133694';
--LAS OPERACIONES DML NO EST�N PERMITIDAS CON WITH READ ONLY
CREATE OR REPLACE VIEW v_empleados5 AS
SELECT *
FROM empleado
WITH READ ONLY;
--LA SIGUIENTE INSTRUCCI�N NO PODR� ALTERAR LA VISTA
UPDATE v_empleados5
  SET sueldo = sueldo * 1.5
WHERE rutemp = '121133694';  