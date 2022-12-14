

---------------- APOCALIPTICO -----------------------

CREATE OR REPLACE PROCEDURE PL (CADENA VARCHAR2) AS
BEGIN
 DBMS_OUTPUT.PUT_LINE(CADENA);
END PL;
/

DROP SEQUENCE ERR_CONT;
CREATE SEQUENCE ERR_CONT;

DROP TABLE ERRORES_PKG;
CREATE TABLE ERRORES_PKG(
ID_DE_ERROR NUMBER(10),
NOMBRE_SUBPROGRAMA VARCHAR2(200),
NUM_ERROR VARCHAR2(200),
MSJ_ERRO VARCHAR2(200)
);

DELETE FROM ERRORES_PKG;

-----------------------------------------------

CREATE OR REPLACE PACKAGE PKG_APOCALIPTICO IS
SUELDONOVALIDO EXCEPTION;
FUNCTION FN_TOTAL_MONTO_BOLETA(IDE NUMBER,DIA NUMBER,MES NUMBER)RETURN NUMBER;
--
TYPE BOLETA IS RECORD (
NOMBRE_VENDEDOR VARCHAR2(200),
NUMERO_BOLETA NUMBER,
CANTIDAD NUMBER,
VALOR_UNITARIO NUMBER,
VALOR_TOTAL NUMBER,
DESCRIP_PRODUCTO VARCHAR2(200)
);

TYPE BOLETA_COPIA IS TABLE OF BOLETA;
FUNCTION FN_BOLETA(IDB NUMBER) RETURN BOLETA_COPIA;
--

FUNCTION FN_MONTO_DESCUENTO(CUPON NUMBER)RETURN NUMBER;
FUNCTION FN_MONTO_DESCUENTO(TARJETA VARCHAR2)RETURN NUMBER;

--

FUNCTION FN_AUMENTO_SALARIO(IDE NUMBER,AUMENTO NUMBER) RETURN NUMBER;
PROCEDURE PRO_AUMENTO_SALARIO(IDE NUMBER,AUMENTO NUMBER);
--

FUNCTION FN_VALORTOTAL_VENTAS(IDE NUMBER, DIA NUMBER, MES NUMBER)RETURN NUMBER;
--

PROCEDURE PRO_VENTAS_MES(MES NUMBER, A?O NUMBER);

--
PROCEDURE PRO_BOLETA(IDB NUMBER, RUT NUMBER, CUPON NUMBER);
PROCEDURE PRO_BOLETA(IDB NUMBER, RUT NUMBER, TARJETA VARCHAR2);

END PKG_APOCALIPTICO;
/
-----------------------------------------------



CREATE OR REPLACE PACKAGE BODY PKG_APOCALIPTICO IS

---- FUNCTION FN_TOTAL_MONTO_BOLETA

FUNCTION FN_TOTAL_MONTO_BOLETA(IDE NUMBER,
                               DIA NUMBER,
                               MES NUMBER) RETURN NUMBER IS

L_TOTAL_BOLETA NUMBER;

V_NUM_ERROR VARCHAR2(200);
V_MSG_ERROR VARCHAR2(200);

BEGIN
SELECT SUM(MONTO_BOLETA)
INTO L_TOTAL_BOLETA
FROM BOLETA
WHERE EXTRACT(DAY FROM FECHA_BOLETA) = DIA AND 
      EXTRACT(MONTH FROM FECHA_BOLETA) = MES AND
      ID_VENDEDOR = IDE
GROUP BY ID_VENDEDOR;   
RETURN L_TOTAL_BOLETA;

EXCEPTION
WHEN NO_DATA_FOUND THEN

V_NUM_ERROR := SQLCODE;
V_MSG_ERROR := SQLERRM;

INSERT INTO ERRORES_PKG
VALUES(ERR_CONT.NEXTVAL,'FUNCTION FN.TOTAL_MONTO_BOLETA', V_NUM_ERROR ,V_MSG_ERROR );
RETURN 0;

END FN_TOTAL_MONTO_BOLETA;


---- FUNCTION FN_BOLETA

FUNCTION FN_BOLETA(IDB NUMBER) RETURN BOLETA_COPIA IS
TB_BOLETA BOLETA_COPIA := BOLETA_COPIA();

CURSOR C1 IS
SELECT V.PNOMBRE || ' '|| V.APPATERNO, B.NRO_BOLETA, DE.CANTIDAD, 
       DE.VALOR_UNITARIO,DE.VALOR_TOTAL,
CASE P.DESC_PRODUCTO WHEN 'CAFE EN GRANO NESCAF?' THEN 'CAFE'
                     WHEN 'ACEITE DE MARAVILLA CHEF' THEN 'ACEITE'
                     WHEN 'ACEITE VEGETAL MIRAFLORES' THEN 'ACEITE'
                     WHEN 'ARROZ BANQUETE PREMIUM GRADO 1' THEN 'ARROZ'
                     END 
FROM VENDEDOR V JOIN BOLETA B ON V.ID_VENDEDOR = B.ID_VENDEDOR 
                JOIN DETALLE_BOLETA DE ON B.NRO_BOLETA = DE.NRO_BOLETA
                JOIN PRODUCTO P ON DE.COD_PRODUCTO = P.COD_PRODUCTO
WHERE B.NRO_BOLETA = IDB               
ORDER BY  B.NRO_BOLETA;

BEGIN 
FOR R1 IN C1 LOOP
TB_BOLETA.EXTEND;
TB_BOLETA(TB_BOLETA.COUNT) := R1;
END LOOP;
RETURN TB_BOLETA;
END FN_BOLETA;


---- FUNCTION FN_MONTO_DESCUENTO CUPON 
FUNCTION FN_MONTO_DESCUENTO(CUPON NUMBER)RETURN NUMBER IS
DESCUENTO NUMBER;

BEGIN
IF CUPON = 1 THEN
DESCUENTO := 0.1;
ELSIF CUPON = 2 THEN
DESCUENTO := 0.07;
ELSIF CUPON = 3 THEN
DESCUENTO := 0.05;
ELSE
DESCUENTO := 0;
END IF;

RETURN DESCUENTO;
END FN_MONTO_DESCUENTO;

---- FUNCTION FN_MONTO_DESCUENTO TARJETA 

FUNCTION FN_MONTO_DESCUENTO(TARJETA VARCHAR2)RETURN NUMBER IS
DESCUENTO NUMBER;

BEGIN
IF TARJETA = 'Platinum' THEN
DESCUENTO := 0.2;
ELSIF TARJETA = 'Gold' THEN
DESCUENTO := 0.15;
ELSIF TARJETA = 'Silver' THEN
DESCUENTO := 0.1;
ELSE
DESCUENTO := 0;
END IF;

RETURN DESCUENTO;
END FN_MONTO_DESCUENTO;


---- FUNCTION FN_AUMENTO_SALARIO

FUNCTION FN_AUMENTO_SALARIO(IDE NUMBER,AUMENTO NUMBER) RETURN NUMBER IS

L_SUELDO NUMBER;
L_SUELDO_AUMENTADO NUMBER;
L_CATEGORIA CHAR(1);
L_SUELDO_MINIMO NUMBER;
L_SUELDO_MAXIMO NUMBER;

V_NUM_ERROR VARCHAR2(200);

BEGIN

SELECT SUELDO_BASE, SUELDO_BASE+AUMENTO, CAT_VENDEDOR
INTO L_SUELDO, L_SUELDO_AUMENTADO,L_CATEGORIA
FROM VENDEDOR
WHERE ID_VENDEDOR = IDE;


SELECT SMIN, SMAX
INTO L_SUELDO_MINIMO,L_SUELDO_MAXIMO
FROM CATEGORIA
WHERE CAT = L_CATEGORIA;

IF L_SUELDO_AUMENTADO BETWEEN L_SUELDO_MINIMO AND L_SUELDO_MAXIMO THEN 
RETURN L_SUELDO_AUMENTADO;
ELSE
RAISE SUELDONOVALIDO;
END IF;

EXCEPTION 
WHEN SUELDONOVALIDO THEN 
V_NUM_ERROR := SQLCODE;

INSERT INTO ERRORES_PKG
VALUES(ERR_CONT.NEXTVAL,'FUNCTION FN_AUMENTO_SALARIO', V_NUM_ERROR,'El sueldo esta fuera de rango para esta categoria.' );
RETURN L_SUELDO;

END FN_AUMENTO_SALARIO;

---- PROCEDURE PRO_AUMENTO_SALARIO

PROCEDURE PRO_AUMENTO_SALARIO(IDE NUMBER,AUMENTO NUMBER) IS
SALARIO_FINAL NUMBER;

BEGIN
SALARIO_FINAL := PKG_APOCALIPTICO.FN_AUMENTO_SALARIO(IDE,AUMENTO);
UPDATE VENDEDOR
SET SUELDO_BASE = SALARIO_FINAL
WHERE ID_VENDEDOR = IDE;
END PRO_AUMENTO_SALARIO;


---- FUNCTION FN_VALORTOTAL_VENTAS
FUNCTION FN_VALORTOTAL_VENTAS(IDE NUMBER, DIA NUMBER, MES NUMBER)RETURN NUMBER IS

L_CONT_VENTAS NUMBER;

V_NUM_ERROR VARCHAR2(200);
V_MSG_ERROR VARCHAR2(200);


BEGIN
SELECT COUNT(NRO_BOLETA)
INTO L_CONT_VENTAS
FROM BOLETA
WHERE EXTRACT(DAY FROM FECHA_BOLETA) = DIA AND
      EXTRACT(MONTH FROM FECHA_BOLETA) = MES AND
      ID_VENDEDOR = IDE
GROUP BY ID_VENDEDOR;

RETURN L_CONT_VENTAS;

EXCEPTION
WHEN NO_DATA_FOUND THEN 
V_NUM_ERROR := SQLCODE;
V_MSG_ERROR := SQLERRM;

INSERT INTO ERRORES_PKG
VALUES(ERR_CONT.NEXTVAL,'FUNCTION FN_VALORTOTAL_VENTAS', V_NUM_ERROR ,V_MSG_ERROR );
RETURN 0;

END FN_VALORTOTAL_VENTAS;


---- PROCEDURE PRO_VENTAS_MES

PROCEDURE PRO_VENTAS_MES(MES NUMBER, A?O NUMBER) IS 


CURSOR C1 IS
SELECT FECHA_BOLETA
FROM BOLETA
WHERE EXTRACT(MONTH FROM FECHA_BOLETA) = MES AND
      EXTRACT(YEAR FROM FECHA_BOLETA) = A?O
GROUP BY FECHA_BOLETA
ORDER BY FECHA_BOLETA;

CURSOR C2 IS 
SELECT ID_VENDEDOR 
FROM VENDEDOR
ORDER BY ID_VENDEDOR;

CURSOR C3 IS
SELECT FECHA_VENTA ,SUM(TOTAL_VENTAS) TOTALCOUNT ,SUM(MONTO_TOTAL_VENTAS) TOTALVENTA
FROM VENTAS_DIARIAS_VENDEDOR 
GROUP BY FECHA_VENTA 
ORDER BY FECHA_VENTA;

L_DIA NUMBER;
L_MES NUMBER;

L_VALT NUMBER;
L_CONT NUMBER;


BEGIN 

DELETE FROM VENTAS_DIARIAS_VENDEDOR;
DELETE FROM RESUMEN_VENTAS_DIARIAS;

FOR R1 IN C1 LOOP
L_DIA := EXTRACT(DAY FROM R1.FECHA_BOLETA);
L_MES := EXTRACT(MONTH FROM R1.FECHA_BOLETA);

   FOR R2 IN C2 LOOP
    L_VALT := PKG_APOCALIPTICO.FN_TOTAL_MONTO_BOLETA(R2.ID_VENDEDOR,L_DIA,L_MES);
    L_CONT := PKG_APOCALIPTICO.FN_VALORTOTAL_VENTAS(R2.ID_VENDEDOR,L_DIA,L_MES);
    
    INSERT INTO VENTAS_DIARIAS_VENDEDOR
    VALUES(R2.ID_VENDEDOR,R1.FECHA_BOLETA,L_CONT,L_VALT);
   END LOOP;   
END LOOP; 

FOR R3 IN C3 LOOP
INSERT INTO RESUMEN_VENTAS_DIARIAS
VALUES(R3.FECHA_VENTA,R3.TOTALCOUNT,R3.TOTALVENTA);

END LOOP;
END PRO_VENTAS_MES;

----------------- PROCEDURE PRO_BOLETA CUPON ---------------------------

PROCEDURE PRO_BOLETA(IDB NUMBER, RUT NUMBER, CUPON NUMBER)IS

ARR PKG_APOCALIPTICO.BOLETA_COPIA;
ARR2 PKG_APOCALIPTICO.BOLETA_COPIA;

L_SUBTOTAL NUMBER;
L_DESCUENTO NUMBER;
L_TOTAL NUMBER;
L_NOMBRE VARCHAR2(200);
L_PORCENTAJE NUMBER;


BEGIN

L_SUBTOTAL := 0;
L_DESCUENTO :=0;
L_TOTAL :=0;

ARR := PKG_APOCALIPTICO.FN_BOLETA(IDB);
ARR2 := PKG_APOCALIPTICO.FN_BOLETA(IDB);

FOR I IN ARR.FIRST..ARR.FIRST LOOP
PL('Supermercado El R?pido');
PL(CHR(32));
PL('Boleta N?  '|| ARR(I).NUMERO_BOLETA);
PL('Rut Cliente:  ' || RUT);
PL('Vendedor:  '|| ARR(I).NOMBRE_VENDEDOR);
PL(RPAD('-',45,'-'));
PL('PRODUCTO       |     CANTIDAD |  MONTO');
PL(RPAD('-',45,'-'));
END LOOP;

FOR I IN ARR.FIRST..ARR.LAST LOOP
PL(ARR(I).DESCRIP_PRODUCTO || CHR(9)||'       |          ' || ARR(I).CANTIDAD ||'  |  ' ||TO_CHAR(ARR(I).VALOR_TOTAL,'999G999'));
L_SUBTOTAL := L_SUBTOTAL +ARR(I).VALOR_TOTAL;
END LOOP;

L_PORCENTAJE := PKG_APOCALIPTICO.FN_MONTO_DESCUENTO(CUPON);
L_DESCUENTO := ROUND(L_SUBTOTAL*L_PORCENTAJE);
L_TOTAL := L_SUBTOTAL - L_DESCUENTO;


PL(RPAD('-',45,'-'));
PL('Subtotal Boleta               $     '|| L_SUBTOTAL);
PL(RPAD('-',45,'-'));

IF CUPON = 1 THEN
L_NOMBRE:= 'Cupon 1';
PL('Descuento con         '|| L_NOMBRE  ||' $     '|| L_DESCUENTO);
ELSIF CUPON = 2 THEN
L_NOMBRE:= 'Cupon 2';
PL('Descuento con         '|| L_NOMBRE  ||' $     '|| L_DESCUENTO);
ELSIF CUPON = 3 THEN
L_NOMBRE:= 'Cupon 3';
PL('Descuento con         '|| L_NOMBRE  ||' $     '|| L_DESCUENTO);
ELSE L_NOMBRE:= ' ';
PL('Descuento con         '|| L_NOMBRE  ||'       $     '|| L_DESCUENTO);
END IF;


PL('Total boleta                  $    '|| L_TOTAL);


END PRO_BOLETA;



----------------- PROCEDURE PRO_BOLETA TARJETA ---------------------------


PROCEDURE PRO_BOLETA(IDB NUMBER, RUT NUMBER, TARJETA VARCHAR2)IS

ARR PKG_APOCALIPTICO.BOLETA_COPIA;
ARR2 PKG_APOCALIPTICO.BOLETA_COPIA;

L_SUBTOTAL NUMBER;
L_DESCUENTO NUMBER;
L_TOTAL NUMBER;
L_NOMBRE VARCHAR2(200);
L_PORCENTAJE NUMBER;

BEGIN
L_SUBTOTAL := 0;
L_DESCUENTO :=0;
L_TOTAL :=0;

ARR := PKG_APOCALIPTICO.FN_BOLETA(IDB);
ARR2 := PKG_APOCALIPTICO.FN_BOLETA(IDB);

FOR I IN ARR.FIRST..ARR.FIRST LOOP
PL('Supermercado El R?pido');
PL(CHR(32));
PL('Boleta N?  '|| ARR(I).NUMERO_BOLETA);
PL('Rut Cliente: '|| RUT);
PL('Vendedor:  '|| ARR(I).NOMBRE_VENDEDOR);
PL(RPAD('-',45,'-'));
PL('PRODUCTO       |     CANTIDAD  |  MONTO');
PL(RPAD('-',45,'-'));
END LOOP;

FOR I IN ARR.FIRST..ARR.LAST LOOP
PL(ARR(I).DESCRIP_PRODUCTO || CHR(9)||'       |          ' || ARR(I).CANTIDAD ||'   |  ' ||TO_CHAR(ARR(I).VALOR_TOTAL,'999G999'));
L_SUBTOTAL := L_SUBTOTAL +ARR(I).VALOR_TOTAL;
END LOOP;

L_PORCENTAJE := PKG_APOCALIPTICO.FN_MONTO_DESCUENTO(TARJETA);
L_DESCUENTO := ROUND(L_SUBTOTAL*L_PORCENTAJE);
L_TOTAL := L_SUBTOTAL - L_DESCUENTO;


PL(RPAD('-',45,'-'));
PL('Subtotal Boleta                $     '|| L_SUBTOTAL);
PL(RPAD('-',45,'-'));

IF TARJETA = 'Platinum' THEN
L_NOMBRE:= 'Platinum';
PL('Descuento con tarjeta '|| L_NOMBRE ||' $     '|| L_DESCUENTO);

ELSIF TARJETA = 'Gold' THEN
L_NOMBRE:= 'Gold';
PL('Descuento con tarjeta '|| L_NOMBRE || CHR(9) ||'   $     '|| L_DESCUENTO);

ELSIF TARJETA = 'Silver' THEN
L_NOMBRE:= 'Silver';
PL('Descuento con tarjeta '|| L_NOMBRE || '   $     '|| L_DESCUENTO);

ELSE L_NOMBRE:= ' ';
PL('Descuento con tarjeta '|| L_NOMBRE || CHR(9) ||'       $     '|| L_DESCUENTO);
END IF;

PL('Total boleta                   $     '|| L_TOTAL);


END PRO_BOLETA;


END PKG_APOCALIPTICO;
/
-----------------------------------------------
-----------------------------------------------


----------------- TRIGGER TR_ANULAR_TRANSACCION ---------------------------

CREATE OR REPLACE TRIGGER TR_ANULAR_TRANSACCION
BEFORE INSERT OR DELETE OR UPDATE ON DETALLE_BOLETA 
DECLARE
BEGIN
  IF (TO_CHAR(SYSDATE, 'fmday') NOT BETWEEN 'LUNES' AND 'VIERNES') AND
  (TO_CHAR(SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00') THEN 
    RAISE_APPLICATION_ERROR(-20001,'NO ES POSIBLE ALTERAR TABLA DETALLE_BOLETA EN D?AS Y HORARIOS NO LABORALES.');
  END IF;   
END TR_ANULAR_TRANSACCION;
/

----------------- TRIGGER TR_BOLETA ---------------------------------------


DROP TABLE TR_DETALLE_BOLETA;

CREATE TABLE TR_DETALLE_BOLETA (
FECHA DATE,
HORA VARCHAR2(8),
TABLA VARCHAR2(30),
TRANSACCION CHAR(1),
OBSERVACIONES VARCHAR2(500),
USUARIO_ORACLE VARCHAR2(30),
IP VARCHAR2(15),
OS_USER VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER TR_BOLETA 
AFTER INSERT OR UPDATE OR DELETE OF CANTIDAD ,VALOR_UNITARIO ON DETALLE_BOLETA
FOR EACH ROW

DECLARE
L_TRANSACCION CHAR(1);
L_OBSERVACION VARCHAR2(500);
L_TABLA VARCHAR2(30);

BEGIN 
IF INSERTING THEN 
L_TRANSACCION := 'I';
L_OBSERVACION := 'SE INSERTO UN DETALLE NUEVO PARA LA BOLETA '|| :NEW.NRO_BOLETA || ' CON UNA CANTIDAD DE: ' || :NEW.CANTIDAD || ' Y UN VALOR UNITARIO DE '|| :NEW.VALOR_UNITARIO;
L_TABLA := 'DETALLE BOLETA';
ELSIF DELETING THEN
L_TRANSACCION := 'D';
L_OBSERVACION := 'SE BORRO UN DETALLE CORRESPONDIENTE A LA BOLETA '|| :OLD.NRO_BOLETA || ' POSEIA UNA CANTIDAD DE: ' || :OLD.CANTIDAD || ' Y UN VALOR UNITARIO DE '|| :OLD.VALOR_UNITARIO;
L_TABLA := 'DETALLE BOLETA';
ELSIF UPDATING AND :NEW.CANTIDAD <> :OLD.CANTIDAD THEN 
L_TRANSACCION := 'U';
L_OBSERVACION := 'SE ACTUALIZO EL DETALLE CORRESPONDIENTE A LA BOLETA '|| :OLD.NRO_BOLETA || ' POSEIA UNA CANTIDAD DE : ' || :OLD.CANTIDAD || ' QUEDANDO CON UNA CANTIDAD DE  '|| :NEW.CANTIDAD;
L_TABLA := 'DETALLE BOLETA-CANTIDAD';
ELSIF UPDATING AND :NEW.VALOR_UNITARIO <> :OLD.VALOR_UNITARIO THEN 
L_TRANSACCION := 'U';
L_OBSERVACION := 'SE ACTUALIZO EL DETALLE CORRESPONDIENTE A LA BOLETA '|| :OLD.NRO_BOLETA || ' POSEIA UN VALOR UNITARIO DE : ' || :OLD.VALOR_UNITARIO || ' QUEDANDO CON UN VALOR DE  '|| :NEW.VALOR_UNITARIO;
L_TABLA := 'DETALLE BOLETA-PRECIO_UNITARIO';
END IF;

INSERT INTO TR_DETALLE_BOLETA
VALUES(SYSDATE,TO_CHAR(SYSDATE,'HH24:MI'),L_TABLA,L_TRANSACCION,L_OBSERVACION,USER,SYS_CONTEXT ('USERENV', 'IP_ADDRESS'),SYS_CONTEXT ('USERENV', 'OS_USER'));

END TR_BOLETA ;
/
-----------------  TRIGGER TR_STOCK ---------------------------------------

CREATE OR REPLACE TRIGGER TR_STOCK
AFTER INSERT OR UPDATE OR DELETE OF CANTIDAD ON DETALLE_BOLETA 
FOR EACH ROW
DECLARE
BEGIN 
IF INSERTING THEN
UPDATE STOCK
SET STOCK_ACTUAL = STOCK_ACTUAL - :NEW.CANTIDAD
WHERE COD_PRODUCTO = :NEW.COD_PRODUCTO;

ELSIF DELETING THEN
UPDATE STOCK
SET STOCK_ACTUAL = STOCK_ACTUAL + :OLD.CANTIDAD
WHERE COD_PRODUCTO = :OLD.COD_PRODUCTO;

ELSIF UPDATING THEN
UPDATE STOCK
SET STOCK_ACTUAL =  STOCK_ACTUAL + (:NEW.CANTIDAD - :OLD.CANTIDAD)
WHERE COD_PRODUCTO = :OLD.COD_PRODUCTO;
END IF;

END TR_STOCK;
/
-----------------  TRIGGER TR_SUPERVISOR_EMPLEADO ------------------------

CREATE OR REPLACE TRIGGER TR_SUPERVISOR_EMPLEADO
BEFORE INSERT OR UPDATE OF RUTSUP ON ADMINISTRATIVO
FOR EACH ROW
DECLARE
L_EMPLEADOS SUPERVISOR.EMPLEADOS%TYPE;
BEGIN 

SELECT EMPLEADOS
INTO L_EMPLEADOS
FROM SUPERVISOR
WHERE RUTSUP = :NEW.RUTSUP;

IF INSERTING AND L_EMPLEADOS >= 9 THEN 
RAISE_APPLICATION_ERROR(-20002,'NO ES POSIBLE INSERTAR EL EMPLEADO. EL SUPERVISOR YA CUENTA CON SU MAXIMO DE EMPLEADOS A CARGO.');
ELSIF UPDATING AND L_EMPLEADOS >= 9 THEN
RAISE_APPLICATION_ERROR(-20002,'NO ES POSIBLE ACTUALIZAR EL EMPLEADO. EL SUPERVISOR YA CUENTA CON SU MAXIMO DE EMPLEADOS A CARGO.');
END IF;
END TR_SUPERVISOR_EMPLEADO;
/



--PRUEBA PACKAGE

EXEC PKG_APOCALIPTICO.PRO_BOLETA(102,111111,1);
EXEC PKG_APOCALIPTICO.PRO_BOLETA(102,111111,'Silver');

EXEC PKG_APOCALIPTICO.PRO_VENTAS_MES(5,2017);
SELECT *
FROM VENTAS_DIARIAS_VENDEDOR;
SELECT *
FROM RESUMEN_VENTAS_DIARIAS;

EXEC PKG_APOCALIPTICO.PRO_AUMENTO_SALARIO(1111111,50);
SELECT SUELDO_BASE,ID_VENDEDOR
FROM VENDEDOR
WHERE ID_VENDEDOR = 1111111;

EXEC PKG_APOCALIPTICO.PRO_AUMENTO_SALARIO(1111111,750000);
SELECT *
FROM ERRORES_PKG;

ROLLBACK;






