--------PL/SQL--------PL: LENGUAJE DE PROGRAMACI�N
----SQL - LENGUAJE DE CUARTA GENERACI�N
----PL/SQL - LENGUAJE DE TERCERA GENERACI�N (NO POSEE M�TODOS AL SER ESTRUCTURADO)
------
--BLOQUE: BLOQUE AN�NIMO & BLOQUES NOMINADOS O SUBPROGRAMAS
--PROCEDIMIENTOS ALMACENADOS
--FUNCIONES
--PACKAGES
--TRIGGERS

----BLOQUES AN�NIMOS 
--SINTAXIS
/*
DECLARE 
  -- REGI�N DE DECLARACIONES DE BLOQUE
  --SE DECLARAN VARIABLES, SUBPROGRAMAS Y CURSORES
  --REGI�N OPCIONAL
BEGIN
  -- REGI�N DE EJECUCI�N
  -- SE COLOCAN INSTRUCCIONES QUE VAN A EJECUTARSE
  -- NO SE PUEDEN DECLARAR VARIABLES
  -- REGI�N ES OBLIGATORIA
  EXCEPTION
    WHEN nombre_controlador THEN
      --CODIGO QUE SE EJECUTAR� EN CASO DE OCURRIR UN ERROR
      --REGI�N OPCIONAL
    WHEN OTHERS THEN
      --C�DIGO QUE SE EJECUTAR� EN CASO DE OCURRIR UN ERROR
      --INTERCEPTA DE FORMA UNIVERSAL, PERO, SIN INFORMAR SOBRE EL ERROR
      --INCLUYE CONTROLADORES DE ORACLE Y CONTROLADORES CREADOS.
END;  
*/
--------------------------------------------------------------------------------

----PRODEDIMIENTO:
CREATE OR REPLACE PROCEDURE pl
(
  cadena varchar2
)
AS 
BEGIN
  dbms_output.putline(cadena);
END;
/

----TODAS LAS INSTRUCCIONES EN PL/SQL FINALIZAN CON ;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Hola.');
END; ----VER/SALIDA DE DBMS (PARA VISUALIZAR SALIDA)
/
--SLASH SEPARA UNA INSTRUCCION DE OTRA
  
DECLARE 
  lsaludo varchar2(12) := 'Hola Mundo';
BEGIN
  dbms_output.put_line(lsaludo);
END;
/

--BLOQUE QUE MUESTRA EL PRODUCTO DE DOS N�MEROS
DECLARE
  lnumero1 NUMBER(6) := 200;
  lnumero2 NUMBER(3);
BEGIN
  --ASIGNACI�N DE VALOR O INICIALIZACI�N DE VARIABLE
  lnumero2 := 5;
  dbms_output.put_line('El producto de ambos n�meros es ' || 
                       lnumero1 * lnumero2);
  dbms_output.put_line('La suma de ambos n�meros es ' || 
                       (lnumero1 + lnumero2));                     
END;
/

--BLOQUE QUE RECUPERA EL SUELDO DE UN EMPLEADO DETERMINADO
--Y LO MUESTRA POR PANTALLA
DECLARE
  lsueldo NUMBER(10); --VARIABLES COMIENZAN CON L DE LOCAL, YA QUE DESAPARECE LUEGO DE "END"
BEGIN
  --USAMOS UN CURSOR IMPL�CITO PARA RECUPERAR EL DATO
  --116499640
  SELECT sueldo
  into lsueldo
  FROM empleado
  WHERE rutemp = '116499640';
  dbms_output.put_line('El sueldo es ' || TO_CHAR(lsueldo, '$99g999g999'));
END;  
/

--DEMO DE DECLARACIONES IMPL�CITAS Y EXPL�CITAS
DECLARE
  lrut VARCHAR2(10) := '116499640'; --DECLARACI�N EXPL�CITA
  lnom VARCHAR2(60); --DECLARACI�N EXPL�CITA
  ldir empleado.direccion%TYPE; --DECLARACI�N IMPL�CITA
  ldir2 ldir%type; --DECLARACI�N IMPL�CITA
  lecivil empleado.ecivil%TYPE; --DECLARACI�N IMPL�CITA
BEGIN
  --CURSOR �MPLICITO
  SELECT  nombre || ' ' || paterno || ' ' materno, direccion, ecivil
  INTO lnom, ldir, lecivil --MANTENER MISMO ORDEN 
  FROM empleado
  WHERE rutemp = lrut;
  pl('nombre del empleado : ' || lnom);
  pl('direcci�n : ' || ldir);
  pl('estado civil : ' || lecivil);
END;

--CREAR UN BLOQUE QUE RECUPERE LOS DATOS DE UN CLIENTE
--DETERMINADO (MOSTRAR NOMBRE COMPLETO, DIRECCI�N,
--FONO1 Y FONO2, ELIMINAR NULOS SI EXISTEN Y RENTA M�XIMA).


--BLOQUE QUE RECUPERA EL SUELDO DE UN EMPLAEDO Y LO MODIFICA
--EN LA BASE DE DATOS.
DECLARE
  lrut empleado.rutemp%TYPE := '&prut';
  lnom empleado.direccion%TYPE;
  lsueldo empleado.sueldo%TYPE;  
BEGIN
  --CURSOR PARA RECUPERAR DATOS
  SELECT paterno || ' ' || materno || ' ' || nombre, sueldo
  INTO lnom, lsueldo
  FROM empleado
  WHERE rutemp = lrut;
  pl('El sueldo del empleado ' || INITCAP(lnom) || ' es: ' || lsueldo);
END;






