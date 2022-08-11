--VARRAY : SIN NOMBRES DE CAMPO (UNIDIMENSIONAL), ALMACENA DATOS DEL MISMO TIPO Y SU LONGITUD SE DECLARA.
--ARREGLOS --> RECORD (FILA)
           --> TABLE OF (COLUMNA)

--ROWTYPE : TABLA, RECORD, CURSOR.


--TODOS LOS PARAMETROS DE UNA PROCEDURE SON DE ENTRADA
CREATE OR REPLACE PROCEDURE pl 
(
cadena VARCHAR2
)
AS
BEGIN 
  dbms_output.put_line(cadena);
END pl;
/

--PÚBLICO
CREATE OR REPLACE PACKAGE miprimer_pkg AS
  --CREACION DE UN RECORD CON LA ESTRUCTUTRA QUE TENDRÁ EL ARREGLO POR DEVOLVER
  TYPE edet IS record (
    rutemp VARCHAR2(10),
    nombre VARCHAR2(50),
    punt NUMBER,
    correo empleado.email%TYPE,
    sueldo NUMBER
  );
  --ARREGLOS BIDIMENSIONALES
  TYPE emple_1 IS TABLE OF edet INDEX BY binary_integer; --INDEXADO --pls_integer --binary_integer. Arreglo dinamico variable.
  TYPE emple_2 IS TABLE OF edet; --ANIDADO (para crear un arreglo dentro de otro arreglo). Se puede almacenar. Parte en 0 con elementos consecutivos hasta 4kMillones.
  --FUNCION QUE DEVUELVE ARREGLO INDEXADO
  FUNCTION fn_dev1 (z VARCHAR2) RETURN emple_1;
  FUNCTION fn_dev2 (z VARCHAR2) RETURN emple_2;
  
  --SOBRECARGA 
  --IMPLEMENTACION DE SOBRE CARGA
  PROCEDURE eliminame(r NUMBER, nu out NUMBER);
  PROCEDURE eliminame(n VARCHAR2, nu out NUMBER);
  PROCEDURE eliminame(nu out NUMBER, e VARCHAR2);
END miprimer_pkg;
/

--PRIVADO
CREATE OR REPLACE PACKAGE BODY miprimer_pkg AS
  --IMPLEMENTACIÓN DE FUNCIÓN PÚBLICA QUE DEVUELVE ARREGLO INDEXADO
  FUNCTION fn_dev1 (
    z VARCHAR2
  ) RETURN emple_1
  AS
    tblemp emple_1;
    CURSOR c1 IS
    SELECT rut||'-'||dv, apellidos||' '||nombres, puntaje, email, sueldo
    FROM empleado
    WHERE zona = z;
  BEGIN
    FOR r1 IN c1 loop
      tblemp(tblemp.count) := r1;
    END loop;
    RETURN tblemp;
  END fn_dev1;
  
  PROCEDURE eliminame(r NUMBER, nu out NUMBER) AS
  BEGIN
    DELETE FROM empleado
    WHERE rut = r;
    nu := SQL%rowcount;
  END eliminame;
  PROCEDURE eliminame(n VARCHAR2, nu out NUMBER) AS
  BEGIN
    DELETE FROM empleado
    WHERE numinterno = n;
    nu := SQL%rowcount;
  END eliminame;
  PROCEDURE eliminame(nu out NUMBER, e VARCHAR2) AS
  BEGIN
    DELETE FROM empleado
    WHERE email = e;
    nu := SQL%rowcount;
  END eliminame;
  
  --IMPLEMENTACIÓN DE FUNCIÓN PÚBLICA QUE DEVUELVE ARREGLO ANIDADO
  FUNCTION fn_dev2 (
    z VARCHAR2
  ) RETURN emple_2
  AS
    --SE DEBE INICIALIZAR.
    tblemp emple_2 := emple_2();
    CURSOR c1 IS
    SELECT rut||'-'||dv, apellidos||' '||nombres, puntaje, email, sueldo
    FROM empleado
    WHERE zona = z;
  BEGIN
    FOR r1 IN c1 loop
      --EL ARREGLO SE CREA SIN ELEMENTOS, POR LO QUE SE DEBE EXTENDER POR CADA INSERCIÓN
      tblemp.EXTEND;
      tblemp(tblemp.count) := r1;
    END loop;
    RETURN tblemp;
  END fn_dev2;
END miprimer_pkg;
/

CREATE OR REPLACE PROCEDURE muestrame (
  z varchar2
)
AS
  arr miprimer_pkg.emple_1;
BEGIN
  arr := miprimer_pkg.fn_dev1(z);
  --USO DE FOR PARA RECCORRER EL ARREGLO DE VUELTO
  FOR i IN arr.FIRST..arr.LAST loop
    pl(arr(I).rutemp ||' '||
       arr(I).nombre ||' '||
       arr(I).punt ||' '||
       arr(I).correo ||' '||
       arr(I).sueldo);
  END loop;
END muestrame;
/

CREATE OR REPLACE PROCEDURE muestrame_v2 (
  z varchar2
)
AS
  arr miprimer_pkg.emple_2;
BEGIN
  arr := miprimer_pkg.fn_dev2(z);
  --USO DE FOR PARA RECCORRER EL ARREGLO DE VUELTO
  FOR i IN arr.FIRST..arr.LAST loop
    pl(arr(I).rutemp ||' '||
       arr(I).nombre ||' '||
       arr(I).punt ||' '||
       arr(I).correo ||' '||
       arr(I).sueldo);
  END loop;
END muestrame_v2;
/

exec muestrame('Norte');
exec muestrame_v2('Norte');

DECLARE
  lnum NUMBER;
BEGIN
  miprimer_pkg.eliminame(17264208,lnum);
  pl('se eliminaron '||lnum||' filas.');
END;
/

DECLARE
  lnum NUMBER;
BEGIN
  miprimer_pkg.eliminame('EM0247',lnum);
  pl('se eliminaron '||lnum||' filas.');
END;
/

DECLARE
  lnum NUMBER;
BEGIN
  miprimer_pkg.eliminame(lnum,'e.browning');
  pl('se eliminaron '||lnum||' filas.');
END;
/




