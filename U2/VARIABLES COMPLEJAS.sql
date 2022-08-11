--VARIABLES COMPLEJAS Y DE INTERACCIÓN CON EL SERVER
--%TYPE
--%ROWTYPE: Para asignar la estructura de una fila de una tabla o de un cursor explícito para recuperar datos de una tabla
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
  lnum NUMBER(1) := &lnum; --Declaración explícita
BEGIN
  --RECUPERACIÓN DE DAOTS DE UNA CATEGORÍA
  SELECT *
  INTO lcat
  FROM categoria
  WHERE idcategoria = lnum;
  --PARA EL DESPLIEGUE USAR NOTACION DE PUNTOS
  pl('Id de la categoria: ' || lnum);
  pl('Nombre de la categoria: ' || lcat.nomcategoria);
  pl('Sueldo mínimo: ' || TO_CHAR(lcat.smin, '$99G999G999'));
  pl('Sueldo máximo: ' || TO_CHAR(lcat.smax, '$99G999G999'));
END;
/

--MOSTRAR DATOS BÁSICOS DE UN EMPLEADO (RUN, NOMBRE, PUNTAJE, SUELDO)
--JUNTO CON LA DIRECCIÓN DE LA OFICINA EN LA QUE TRABAJA Y EL NOMBRE
--DEL PUESTO QUE DESEMPEÑA.
DECLARE 
  --DECLARACIÓN DE EL TIPO IS RECORD NECESARIO (RECORD PERSONALIZADO)
  --PERMITE DECLARACIONES IMPLÍCITAS Y EXPLÍCITAS
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
  pl('Dirección: ' || emple.ldir);
  pl('Puntaje: ' || emple.lpunt);
  pl('Sueldo: ' || TO_CHAR(emple.lsueldo, '$99G999G999'));
  pl('Oficina: ' || emple.lofi);
  pl('Categoria: ' || emple.lcat);
  EXCEPTION
  WHEN no_data_found THEN
   pl('Empleado inexistente');
END;
/

--INTERACCIÓN CON EL SERVIDOR, USO DE INSTRUCCIONES DML
--INSERT - UPDATE - DELETE (COMMIT - ROLLBACK)
CREATE TABLE emple AS
SELECT *
FROM empleado;

--DEMO DE BORRADO CON CURSOR IMPLÍCITO
BEGIN 
  DELETE
  FROM emple
  WHERE ecivil = 'Divorciado';
  pl('Se eliminaron ' || SQL%rowcount || ' filas');
END;
/

--DEMO DE ACTUALIZACIÓN
BEGIN
  UPDATE emple
  SET sueldo = sueldo * 1.2
  WHERE puntaje > 250;
  
  DELETE FROM emple WHERE puntaje < 280;
  pl('Se eliminaron ' || SQL%rowcount || ' filas'); --SQL CAPTURA EL ÚLTIMO CAMBIO REALIZADO SOLAMENTE
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

  