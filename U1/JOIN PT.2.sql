-- JOINS POR DESIGUALDAD
-- OBTENER LOS DATOS BASICOS DEL EMPLEADO JUNTO CON LA LISTA
-- QUE LE CORRESPONDE DE ACUERDO A SU PUNTAJE
SELECT E.RUTEMP RUN , E.PATERNO ||' '||E.MATERNO || ' '||E.NOMBRE NOMBRE,
E.PUNTAJE, L.LISTA
FROM EMPLEADO E JOIN LISTA L
ON PUNTAJE BETWEEN L.PUNT_MIN AND L.PUNT_MAX;

--SELF JOIN
SELECT e.rutemp AS run, 
  e.paterno || ' ' || e.materno || ' ' || e.nombre AS nombre,
  e.puntaje,
  e.sueldo,
  e.rutsup AS "RUN JEFE",
  m.paterno || ' ' || m.materno || ' ' || m.nombre AS "NOMBRE JEFE"
FROM empleado e JOIN empleado m
on m.rutemp = e.rutsup;