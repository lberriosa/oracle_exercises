--VARIABLES COMPLEJAS Y DE INTERACCI�N CON EL SERVER
--%TYPE
--%ROWTYPE: Para asignar la estructura de una fila de una tabla o de un cursor expl�cito para recuperar datos de una tabla
--TYPE nomvar IS RECORD: Para datos que provienen de varias tablas.

CREATE OR REPLACE PROCEDURE pl
(
  cadena varchar2
)
AS
BEGIN
  dbms_output.put_line(cadena);
END pl;
/

--DEMO DE %ROWTYPE
DECLARE 
  lcat categoria%ROWTYPE; --lcat asume como propios todos los datos y sus tipos desde la entidad categoria
  lnum NUMBER(1) := &lnum; --Declaraci�n expl�cita
BEGIN
  --RECUPERACI�N DE DAOTS DE UNA CATEGOR�A
  SELECT *
  INTO lcat
  FROM categoria
  WHERE idcategoria = lnum;
  --PARA EL DESPLIEGUE USAR NOTACION DE PUNTOS
  pl('Id de la categoria: ' || lnum);
  pl('Nombre de la categoria: ' || lcat.nomcategoria);
  pl('Sueldo m�nimo: ' || TO_CHAR(lcat.smin, '$99G999G999'));
  pl('Sueldo m�ximo: ' || TO_CHAR(lcat.smax, '$99G999G999'));
END;
/

--MOSTRAR DATOS B�SICOS DE UN EMPLEADO (RUN, NOMBRE, PUNTAJE, SUELDO)
--JUNTO CON LA DIRECCI�N DE LA OFICINA EN LA QUE TRABAJA Y EL NOMBRE
--DEL PUESTO QUE DESEMPE�A.
DECLARE 
  --DECLARACI�N DE EL TIPO IS RECORD NECESARIO (RECORD PERSONALIZADO)
  --PERMITE DECLARACIONES IMPL�CITAS Y EXPL�CITAS
  TYPE lemp IS record
  (
    lnom VARCHAR2(60),
    ldir empleado.direccion%TYPE,
    lpunt empleado.puntaje%TYPE,
    lsueldo NUMBER(10),
    lofi oficina.diroficina%TYPE,
    lcat categoria.nomcategoria%TYPE
  );
  --INSTANCIA DEL TIPO CREADO
  emple lemp;
  lrun varchar2(10) := '&lrun';
BEGIN
  --CURSOR PARA RECUPERAR DATOS
  SELECT e.nombre || ' ' || e.paterno || ' ' || e.materno,
    e.direccion,
    e.puntaje,
    e.sueldo,
    o.diroficina,
    ct.nomcategoria
  INTO emple
  FROM categoria ct JOIN empleado e ON e.idcategoria = ct.idcategoria
    JOIN oficina o ON o.numoficina = e.numoficina 
  WHERE e.rutemp = lrun;
  --DESPLEGANDO DATOS
  pl('Nombre del empleado: ' || emple.lnom);
  pl('Direcci�n: ' || emple.ldir);
  pl('Puntaje: ' || emple.lpunt);
  pl('Sueldo: ' || TO_CHAR(emple.lsueldo, '$99G999G999'));
  pl('Oficina: ' || emple.lofi);
  pl('Categoria: ' || emple.lcat);
  EXCEPTION
  WHEN no_data_found THEN
   pl('Empleado inexistente');
END;
/

--INTERACCI�N CON EL SERVIDOR, USO DE INSTRUCCIONES DML
--INSERT - UPDATE - DELETE (COMMIT - ROLLBACK)
CREATE TABLE emple AS
SELECT *
FROM empleado;

--DEMO DE BORRADO CON CURSOR IMPL�CITO
BEGIN 
  DELETE
  FROM emple
  WHERE ecivil = 'Divorciado';
  pl('Se eliminaron ' || SQL%rowcount || ' filas');
END;
/

--DEMO DE ACTUALIZACI�N
BEGIN
  UPDATE emple
  SET sueldo = sueldo * 1.2
  WHERE puntaje > 250;
  
  DELETE FROM emple WHERE puntaje < 280;
  pl('Se eliminaron ' || SQL%rowcount || ' filas'); --SQL CAPTURA EL �LTIMO CAMBIO REALIZADO SOLAMENTE
END;
/
ROLLBACK;

CREATE TABLE emple2 AS
SELECT e.nombre || ' ' || e.paterno || ' ' || e.materno as nombre,
    e.direccion,
    e.puntaje,
    e.sueldo,
    o.diroficina,
    ct.nomcategoria
FROM categoria ct JOIN empleado e 
ON e.idcategoria = ct.idcategoria
  JOIN oficina o ON o.numoficina = e.numoficina 
WHERE 1 = 2;
/

BEGIN
  INSERT INTO emple2
  SELECT e.nombre || ' ' || e.paterno || ' ' || e.materno as nombre,
    e.direccion,
    e.puntaje,
    e.sueldo,
    o.diroficina,
    ct.nomcategoria
  FROM categoria ct JOIN empleado e 
  ON e.idcategoria = ct.idcategoria
    JOIN oficina o ON o.numoficina = e.numoficina 
  WHERE e.ecivil = 'Divorciado';
  pl('Se insertaron ' || SQL%rowcount || ' filas.');
END;
/

  