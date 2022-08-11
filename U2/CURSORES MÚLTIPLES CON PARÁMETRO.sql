--USO DE PARÁMETROS EN CURSORES, TRABAJANDO CON MÁS DE UN CURSOR 

CREATE OR REPLACE PROCEDURE PL (cadena VARCHAR2) AS 
BEGIN
  dbms_output.put_line(cadena);
END;
/

DROP TABLE sueldos_mes; 
CREATE TABLE sueldos_mes (
  rutemp varchar2(10),
  nombre VARCHAR2(50),
  fecingreso DATE,
  sueldo_mes NUMBER(10),
  comision NUMBER(6),
  total_a_pago NUMBER(10)
);

--BLOQUE QUE LISTA LOS EMPLEADOS DE CADA UNA DE LAS EMPRESAS EXISTENTES
DECLARE 
  --CURSOR 1
  CURSOR c1 IS
  SELECT *
  FROM empresa;
  --CURSOR 2 (RECIBIRÁ COMO PARAMETRO LA ID DE LA EMPRESA)
  CURSOR c2 (p_rempre NUMBER) IS
  SELECT *
  FROM empleado
  WHERE rutempresa = p_rempre
  ORDER BY apellidos, nombres;
  vcounter NUMBER;
  vcounterTotal NUMBER := 0;
BEGIN
  FOR r1 IN c1 loop
    PL(LPAD(' ',71,'-'));
    PL('LISTA DE LA EMPRESA ' || UPPER(R1.razonsocial));
    PL(LPAD(' ',71,'-'));
    PL('NUM. NOMBRE EMPLEADO     CORREO     PUNTEJE   SUELDO    SUELDO AUMENTADO');
    FOR r2 IN c2 (r1.rut) loop
      PL(TO_CHAR(c2%ROWCOUNT, '999') 
        || ' ' || RPAD(r2.apellidos || ' ' || r2.nombres, 20 , ' ')
        || ' ' || RPAD(r2.email, 12, ' ')
        || ' ' || TO_CHAR(r2.puntaje, '999')
        || ' ' || TO_CHAR(r2.sueldo, '$9G999G999')
        || ' ' || TO_CHAR(r2.sueldo*1.7, '$9G999G999')
        );
        vcounter := C2%ROWCOUNT;
        INSERT INTO sueldos_mes
        VALUES (r2.rut || '-' || r2.dv, r2.apellidos ||' '||r2.nombres,
               r2.fecingreso, r2.sueldo, TRUNC(r2.sueldo * .2),
               r2.sueldo + TRUNC(r2.sueldo * .2));  
    END loop;
    vcounterTotal := vcounterTotal + vcounter;
    PL('NÚMERO DE EMPLEADOS: ' || vcounter);
    PL(chr(13)); --LLAMADA A ELEMENTO DE LA TABLA ASCII
    PL(chr(12));
  END loop;
  PL('NÚMERO TOTAL DE EMPLEADOS: ' ||  vcounterTotal);
END;
/
  
SELECT * FROM sueldos_mes;
