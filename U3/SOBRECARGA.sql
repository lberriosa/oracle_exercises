--demo de package con sobrecraga
CREATE OR REPLACE PROCEDURE pl(
  cadena varchar2
)
AS
BEGIN
  dbms_output.put_line(cadena);
end pl;
/

CREATE OR REPLACE PACKAGE mipkg AS
  --ejemplo de sobrecarga
  PROCEDURE eliminame(r NUMBER, nu out NUMBER);
  PROCEDURE eliminame(n VARCHAR2, nu out NUMBER);
  procedure eliminame(nu out number,e varchar2);
END mipkg;
/
CREATE OR REPLACE PACKAGE BODY mipkg AS
  --implementacion de la sobrecarga 
  PROCEDURE eliminame(
    r number, nu out number
  )
  AS
  BEGIN
    DELETE FROM empleado
    WHERE rut = r;
    nu := sql%rowcount;
  END;
  
  PROCEDURE eliminame(
    n varchar2, nu out number
  )
  AS
  BEGIN
    DELETE FROM empleado
    WHERE numinterno = n;
    nu := SQL%rowcount;
  END;
  
  PROCEDURE eliminame(
    nu out number, e varchar2
  )
  AS
  BEGIN
    DELETE FROM empleado
    WHERE email = e;
    nu := SQL%rowcount;
  END;
END mipkg;
/
show error;

DECLARE
 lnum number;
BEGIN
  mipkg.eliminame(lnum, 'e.browning');
  
  pl(lnum||' filas eliminadas.');
END;
/

rollback;