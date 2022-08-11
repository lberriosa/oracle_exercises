----CURSORES EXPL�CITOS
CREATE OR REPLACE PROCEDURE pl (
  cadena VARCHAR2
) AS
BEGIN
   dbms_output.put_line(cadena);
END pl;
/

--RECUPERAR TODOS LOS DATOS DE EMPLEADOS QUE POSEEN M�S DE TRES CARGAS FAMILIARES
--SI UN CURSOR IMPL�CITO DEVUELVE M�S DE UNA FILA, LA INSTRUCCI�N FALLA.
--EN ESTE CASO DEBE CREARSE UN CURSOR EXPL�CITO, ESTA ACCION SE REALIZA EN LA PARTE DE DECLARACIONES.
--FETCH RECUPERA LOS RESULTADOS DE LA LISTA DE RESULTADOS
DECLARE
  lemp empleado%ROWTYPE;
  --DECLARACI�N DEL CURSOR
  CURSOR emple IS
  SELECT *
  FROM empleado
  WHERE numcargas > 4;
BEGIN
  --ABRIR CURSOR
  OPEN emple;
  LOOP
    FETCH emple INTO lemp;
    --EXIT WHEN emple%NOTFOUND;
    EXIT WHEN emple%ROWCOUNT > 4;
    pl(lemp.nombres || ' ' || lemp.apellidos || ' posee ' || lemp.numcargas || ' cargas.' );
  END LOOP;
  CLOSE emple; --CLOSE DEBE IR FUERA DE LA ITERACI�N  
END;
/

DECLARE
  lemp empleado%ROWTYPE;
  --DECLARACI�N DEL CURSOR
  CURSOR emple IS
  SELECT *
  FROM empleado
  WHERE numcargas > 4;
BEGIN
  --ABRIR CURSOR
  OPEN emple;
  FETCH emple INTO lemp;
  WHILE emple%FOUND LOOP
    pl(lemp.nombres || ' ' || lemp.apellidos || ' posee ' || lemp.numcargas || ' cargas.' );
    FETCH emple INTO lemp;
  END LOOP;
  CLOSE emple; --CLOSE DEBE IR FUERA DE LA ITERACI�N  
END;
/

--CREAR UUN BLOQUE AN�NIMO QUE RECUPERE TODOS LOS DATOS DE LOS EMPLEDOS ASIGNADOS A UNA ZONA DETERMINADA.
--PASAR LA ZONA MEDIANTE UNA VARIABLE DE SUSTITUCI�N.
SET VERIFY OFF;
DECLARE
  lzone empleado.zona%TYPE := '&ZONA';
  lemp empleado%ROWTYPE;
  CURSOR emple IS
  SELECT *
  FROM empleado
  WHERE zona = lzone;
BEGIN
  OPEN emple;
  FETCH emple INTO lemp;
  WHILE emple%FOUND LOOP
    pl(lemp.nombres || ' ' || lemp.apellidos || ' es parte de la zona ' || lemp.zona || '.' );
    FETCH emple INTO lemp;
  END LOOP;
  CLOSE emple; 
END;
/

--RECUPERAR NOMBRE COMPLETO, PUNTAJE, ZONA Y SUELDO DE TODOS LOS EMPLEADOS CON PUNTAJE MAYOR QUE 300.
--PROCESAR LAS FILAS PARA OTORGAR UN AUMENTO DE SUELDO CORRESPONDIENTE A UN 20%
--MOSTRAR LOS DATOS RECUPERADOS M�S EL SUELDO AUMENTADO
DECLARE
  lpuntaje empleado.puntaje%type;
  lemp empleado%ROWTYPE;
  CURSOR emple IS
  SELECT *
  FROM empleado
  WHERE puntaje > 300;
BEGIN
  OPEN emple;
  FETCH emple INTO lemp;
  WHILE emple%FOUND LOOP
    pl(lemp.nombres || ' ' || lemp.apellidos || ' tiene un sueldo de ' || to_char(lemp.sueldO, '$9G999G999') 
    || ' y con el aumento de 20% queda en ' || to_char(ROUND(lemp.sueldO*1.2), '$9G999G999'));
    FETCH emple INTO lemp;
  END LOOP;
  CLOSE EMPLE;
END;
/

--OBTENER TODOS LOS DATOS DE LOS EMPLEADOS INGRESADOS A LA EMPRESA ANTES DE UNA A�O DETERMINADO
DECLARE
  lfecha NUMBER := &lfecha;
  CURSOR c1 IS
  SELECT *
  FROM empleado
  WHERE EXTRACT(YEAR FROM fecingreso) = lfecha;
BEGIN
  --EL BUCLE FOR ADMINISTRA EL CURSOR
  --NO ES NECESARIO ABRIR, NI OBTENER, NI CERRAR EL CURSOR (ORACLE LO HACE AUTOMATICAMENTE).
  FOR remp IN c1 LOOP
    pl(remp.nombres || ' ' || remp.apellidos 
    || ' ' || remp.email
    || ' ' || remp.puntaje
    || ' ' || remp.fecingreso
    || ' ' || remp.sueldo);
  END LOOP;
END;
/

--AGREGUE EL CAMPO categoria(VARCHAR2(12)) A LA TABLA empleado CONSTRUYA UN BLOQUE QUE PERMITA
--CATEGORIZAR A CADA EMPLEADO DEPENDIENDO DE SU PUNTAJE. SI EL PUNTAJE ES MAYOR QUE 450 EN EL 
--CAMPO CATEGORIA SE DEBE ALMACENAR "LISTA A", SI ES MAYOR QUE 350 "LISTA B", SI ES MAYOR QUE 250 "LISTA C",
--SI ES MAYOR QUE 100 "LISTA D" Y EN CASO CONTRARIO "LISTA E".
ALTER TABLE empleado
  ADD categoria VARCHAR2(12);
  
DECLARE
  
BEGIN
END;



