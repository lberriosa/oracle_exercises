----PARAMETRO(FORMAL) = DECLARACION // PARAMETRO(ACTUAL) = ARGUMENTO

----MODULARIZAR --> SUBPROGRAMAS:
----------------------PROCEDIMIENTOS (VOID)
----------------------FUNCIONES (MÉTODO TIPADO)
----------------------PACKAGES (CONTENEDOR DLL)
----------------------TRIGGERS

/*
----PROCEDIMIENTO 
CREATE OR REPLACE PROCEDURE nombre_procedimiento ( 
  param1 tipodato, param2 tipodato, param_n tipodato 
) 
AS / IS 
  --REGION DE DECLARACIONES
BEGIN 
  --CODIGO
  --CODIGO
END nombre_procedimiento;  
/

----FUNCION ALMACENADA
CREATE OR REPLACE FUNCTION nombre_funcion (
  param1 tipodato, param2 tipodato, param_n tipo dato   
) RETURN tipo_dato
AS / IS
  --REGION DE DECLARACIONES
BEGIN
  --CODIGO
  --CODIGO
  RETURN valor;
END nombre_funcion;  
/
*/

--PROCEDIMIENTO
CREATE OR REPLACE PROCEDURE pl ( 
  cadena VARCHAR2 
) 
IS 
BEGIN 
  dbms_output.put_line(cadena);
END pl;  
/

--FUNCIÓN QUE RETORNA LA ANTIGÜEDAD EN AÑOS DE UN EMPLEADO
CREATE OR REPLACE FUNCTION fn_antiguedad (
  r VARCHAR2
) RETURN NUMBER
AS
  lingreso DATE;
BEGIN
  SELECT fecing 
  INTO lingreso
  FROM empleado
  WHERE rutemp = r;
  RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM lingreso);
  EXCEPTION
   WHEN no_data_found THEN
    RETURN 0;
END fn_antiguedad;
/
show ERROR;

--FORMAS DE LLAMAR A UNA FUNCIÓN DESDE OTRO BLOQUE
DECLARE
  --FORMA 1: DECLARAR UNA VARIABLE
  lanti NUMBER;
  lrut VARCHAR2(10) := '&lrut';
  lnom VARCHAR2(50);
BEGIN
  SELECT rutemp, paterno||' '||materno||' '||nombre
  INTO lrut, lnom
  FROM empleado
  WHERE rutemp = lrut;
  --FORMA 1: POBLAR LA VARIABLE EN EL SECTOR DE EJECUCIÓN
  lanti := fn_antiguedad(lrut);
  pl('El empleado '||lnom||' tiene una antiguedad de '||lanti||' años.');
  --FORMA 2: LLAMAR A LA FUNCIÓN DESDE LA INSTRUCCIÓN
  pl(lnom||' antigüedad: '||fn_antiguedad(lrut));
END;
/
EXEC pl(fn_antiguedad('116499640'));

SELECT rutemp run, paterno||' '||materno||' '||nombre nombre,
  fecing ingreso, fn_antiguedad(rutemp) antiguedad
FROM empleado
WHERE fn_antiguedad(rutemp) > 30
ORDER BY fn_antiguedad(rutemp) DESC;

--PROCEDIMIENTO QUE LISTA LOS EMPLEADOS DE UNA CATEGORÍA DETERMINADA
--(RUT, NOMBRE COMPLETO, PUNTAJE, SUELDO Y EL MONTO DE UNA ASIGNACIÓN POR ZONA)
--DICHA ASIGNACIÓN LA DEBE CALCULAR UNA FUNCIÓN
CREATE OR REPLACE FUNCTION fn_asignacion (
  z NUMBER, s NUMBER
) RETURN NUMBER
IS
  lpct NUMBER;
BEGIN
  SELECT asignacion
  INTO lpct
  FROM zona
  WHERE idzona = z;
  RETURN ROUND(s * lpct);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
END fn_asignacion;
/

DROP TABLE asignacion;
CREATE TABLE asignacion AS
SELECT rutemp, direccion nombre, puntaje, sueldo, sueldo asignacion, idzona
FROM empleado
WHERE 1 = 2;

CREATE OR REPLACE PROCEDURE salva_datos(
  r VARCHAR2, n VARCHAR2, p NUMBER, s NUMBER, asi NUMBER, z NUMBER
)
AS
BEGIN
  INSERT INTO asignacion  
  VALUES (r, n, p, s, asi, z);
  EXCEPTION 
    WHEN dup_val_on_index THEN
     pl('Fila duplicada');
END salva_datos;
/

CREATE OR REPLACE PACKAGE pkg_mipackage AS
  --VARIABLES PUBLICAS
  lnum NUMBER;
  lasi NUMBER;
  --FUNCIÓN PÚBLICA
  FUNCTION fn_asignacion (z NUMBER, s NUMBER) RETURN NUMBER;
END pkg_mipackage;
/
CREATE OR REPLACE PACKAGE BODY pkg_mipackage AS
  --VARIABLES PUBLICAS
  lnum_contrato NUMBER;
  
  FUNCTION fn_asignacion (z NUMBER, s NUMBER) 
  RETURN NUMBER
  IS
  lpct NUMBER;
  BEGIN
    SELECT asignacion
    INTO lpct
    FROM zona
    WHERE idzona = z;
    RETURN ROUND(s * lpct);
    EXCEPTION
      WHEN no_data_found THEN
        RETURN 0;
  END fn_asignacion;
END pkg_mipackage;
/

CREATE OR REPLACE PROCEDURE procesa_empleados (
  cat VARCHAR2 --NUNCA SE PONE EL TAMAÑO
)
AS
  --CURSOR EXPLÍCITO
  CURSOR c2 IS
  SELECT e.rutemp, e.paterno||' '||e.materno||' '||e.nombre nombre, 
    e.puntaje, e.sueldo, e.idzona
  FROM categoria ct JOIN empleado e
  ON ct.idcategoria = e.idcategoria
  WHERE ct.nomcategoria = cat;
  
  lasi1 NUMBER;
BEGIN
  FOR r2 IN c2 loop
    lasi1 := fn_asignacion(r2.idzona,r2.sueldo);
    pkg_mipackage.lasi := 2400;
    pkg_mipackage.lasi := pkg_mipackage.fn_asignacion(r2.idzona,r2.sueldo);
    
    pl(r2.rutemp||' '||r2.nombre||' '||r2.puntaje||' '||r2.sueldo||' '||fn_asignacion(r2.idzona,r2.sueldo)||' VAR_PKG '||pkg_mipackage.lasi||' FN_PKG '||pkg_mipackage.fn_asignacion(r2.idzona,r2.sueldo));
  END loop;  
END procesa_empleados;
/
EXEC procesa_empleados('Vendedor');
