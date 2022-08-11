--------PL/SQL--------PL: LENGUAJE DE PROGRAMACIÓN
----SQL - LENGUAJE DE CUARTA GENERACIÓN
----PL/SQL - LENGUAJE DE TERCERA GENERACIÓN (NO POSEE MÉTODOS AL SER ESTRUCTURADO)
------
--BLOQUE: BLOQUE ANÓNIMO & BLOQUES NOMINADOS O SUBPROGRAMAS
--PROCEDIMIENTOS ALMACENADOS
--FUNCIONES
--PACKAGES
--TRIGGERS

----BLOQUES ANÓNIMOS 
--SINTAXIS
/*
DECLARE 
  -- REGIÓN DE DECLARACIONES DE BLOQUE
  --SE DECLARAN VARIABLES, SUBPROGRAMAS Y CURSORES
  --REGIÓN OPCIONAL
BEGIN
  -- REGIÓN DE EJECUCIÓN
  -- SE COLOCAN INSTRUCCIONES QUE VAN A EJECUTARSE
  -- NO SE PUEDEN DECLARAR VARIABLES
  -- REGIÓN ES OBLIGATORIA
  EXCEPTION
    WHEN nombre_controlador THEN
      --CODIGO QUE SE EJECUTARÁ EN CASO DE OCURRIR UN ERROR
      --REGIÓN OPCIONAL
    WHEN OTHERS THEN
      --CÓDIGO QUE SE EJECUTARÁ EN CASO DE OCURRIR UN ERROR
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

--BLOQUE QUE MUESTRA EL PRODUCTO DE DOS NÚMEROS
DECLARE
  lnumero1 NUMBER(6) := 200;
  lnumero2 NUMBER(3);
BEGIN
  --ASIGNACIÓN DE VALOR O INICIALIZACIÓN DE VARIABLE
  lnumero2 := 5;
  dbms_output.put_line('El producto de ambos números es ' || 
                       lnumero1 * lnumero2);
  dbms_output.put_line('La suma de ambos números es ' || 
                       (lnumero1 + lnumero2));                     
END;
/

--BLOQUE QUE RECUPERA EL SUELDO DE UN EMPLEADO DETERMINADO
--Y LO MUESTRA POR PANTALLA
DECLARE
  lsueldo NUMBER(10); --VARIABLES COMIENZAN CON L DE LOCAL, YA QUE DESAPARECE LUEGO DE "END"
BEGIN
  --USAMOS UN CURSOR IMPLÍCITO PARA RECUPERAR EL DATO
  --116499640
  SELECT sueldo
  into lsueldo
  FROM empleado
  WHERE rutemp = '116499640';
  dbms_output.put_line('El sueldo es ' || TO_CHAR(lsueldo, '$99g999g999'));
END;  
/

--DEMO DE DECLARACIONES IMPLÍCITAS Y EXPLÍCITAS
DECLARE
  lrut VARCHAR2(10) := '116499640'; --DECLARACIÓN EXPLÍCITA
  lnom VARCHAR2(60); --DECLARACIÓN EXPLÍCITA
  ldir empleado.direccion%TYPE; --DECLARACIÓN IMPLÍCITA
  ldir2 ldir%type; --DECLARACIÓN IMPLÍCITA
  lecivil empleado.ecivil%TYPE; --DECLARACIÓN IMPLÍCITA
BEGIN
  --CURSOR ÍMPLICITO
  SELECT  nombre || ' ' || paterno || ' ' materno, direccion, ecivil
  INTO lnom, ldir, lecivil --MANTENER MISMO ORDEN 
  FROM empleado
  WHERE rutemp = lrut;
  pl('nombre del empleado : ' || lnom);
  pl('dirección : ' || ldir);
  pl('estado civil : ' || lecivil);
END;

--CREAR UN BLOQUE QUE RECUPERE LOS DATOS DE UN CLIENTE
--DETERMINADO (MOSTRAR NOMBRE COMPLETO, DIRECCIÓN,
--FONO1 Y FONO2, ELIMINAR NULOS SI EXISTEN Y RENTA MÁXIMA).


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






