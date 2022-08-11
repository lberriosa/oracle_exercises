

------------------ SOLENME 1 ------------------------


--1

/*Se desea pagar las remuneraciones del mes respectivo, por este motivo se le
solicita calcular el sueldo que corresponde pagar a cada profesional, el que
estará constituido por su sueldo más el 40% de los honorarios por las asesorías
realizadas, más la asignación profesional, menos los descuentos
(salud corresponde a un 7% en todos los casos). 
Incluir a todos los empleados hayan o no realizado asesorías*/


SELECT P.APPPRO ||' '|| P.APMPRO ||' '||P.NOMPRO "PROFESIONAL",
       P.SUELDO "SUELDO" , NVL((SUM(A.HONORARIO)*0.4),0) "MONTO HONORARIO",
       (P.SUELDO*(PR.ASIGNACION/100)) "ASIGNACION",
       (P.SUELDO +  NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100)) "IMPONIBLE",
       TRUNC(((P.SUELDO + NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100))*(AFP.PORC/100))) "PREVISION",
       TRUNC((P.SUELDO +  NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100))*0.07)"SALUD",
      (P.SUELDO +  NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100)) - TRUNC(((P.SUELDO +  NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100))*(AFP.PORC/100))) - TRUNC((P.SUELDO +  NVL((SUM(A.HONORARIO)*0.4),0)+
       P.SUELDO*(PR.ASIGNACION/100))*0.07) "LIQUIDO"
       FROM PROFESIONAL P FULL JOIN ASESORIA A 
       ON P.RUTPROF = A.RUTPROF
       JOIN PROFESION PR ON PR.IDPROFESION = P.IDPROFESION
       JOIN AFP AFP ON P.IDAFP = AFP.IDAFP
       GROUP BY P.APPPRO,P.APMPRO,P.NOMPRO,P.SUELDO,A.HONORARIO,PR.ASIGNACION,AFP.PORC
       ORDER BY APPPRO;
       
       
--2

/*La consultora desea desvincular a los empleados menos productivos, 
Por ello, en una primera fase se desea que Ud. elabore una consulta
que muestre rut y nombre de los tres Ingenieros Comerciales que han 
ganado menos dinero por concepto de honorarios totales. 
La salida debe formatearse como muestra la imagen.*/

SELECT *
FROM(
SELECT TO_CHAR(SUBSTR(A.RUTPROF,1,LENGTH(A.RUTPROF)-1),'99g999g999')||'-'||
       SUBSTR(A.RUTPROF,-1)RUT ,
       P.NOMPRO ||' '|| P.APPPRO ||' '|| SUBSTR(P.APMPRO,1,1)||'.' "NOMBRE EMPLEADO",
       TO_CHAR(SUM(A.HONORARIO),'$9g999g999')"HONORARIO"        
FROM PROFESION PR JOIN PROFESIONAL P ON PR.IDPROFESION = P.IDPROFESION
                  JOIN ASESORIA A ON A.RUTPROF = P.RUTPROF
WHERE PR.NOMPROFESION LIKE ('Ingeniero Comercial')
GROUP BY TO_CHAR(SUBSTR(A.RUTPROF,1,LENGTH(A.RUTPROF)-1),'99g999g999')
         ||'-'||SUBSTR(A.RUTPROF,-1),
         P.NOMPRO, P.APPPRO,P.APMPRO
ORDER BY "HONORARIO")
WHERE ROWNUM < 4; 



--3

/*Con el fin de ajustar los honorarios que paga la consultora, 
se desea que elabore una consulta que localice y muestre 
el nombre de todas las personas que ganan 
un total de honorarios menor al honorario promedio.*/



SELECT P.APPPRO ||' '||P.APMPRO||' '||P.NOMPRO "NOMBRE",
       TO_CHAR(SUM(A.HONORARIO),'$999g999') "PROMEDIO HONORARIOS"
FROM PROFESIONAL P JOIN ASESORIA A ON P.RUTPROF = A.RUTPROF
GROUP BY P.NOMPRO,P.APPPRO,P.APMPRO
HAVING SUM(A.HONORARIO) < (SELECT AVG(HONORARIO)
                                   FROM ASESORIA 
                                   GROUP BY P.NOMPRO)
ORDER BY "NOMBRE";


--4

/*Con el fin de premiar al profesional que ha reportado más dinero 
a la consultora, la gerencia desea que elabore una consulta que
localice y muestre el nombre del empleado (profesional)
que recauda más dinero por concepto de honorarios totales. 
Muestre nombre y monto de los honorarios en formato monetario.*/


SELECT P.NOMPRO ||' '||P.APPPRO||' '||P.APMPRO "NOMBRE EMPLEADO",
       SUM(A.HONORARIO)"TOTAL HONORARIOS"
FROM PROFESIONAL P JOIN ASESORIA A ON P.RUTPROF = A.RUTPROF
GROUP BY P.NOMPRO,P.APPPRO,P.APMPRO
HAVING SUM(A.HONORARIO) = (SELECT MAX(SUM(HONORARIO))
                                FROM ASESORIA
                                GROUP BY RUTPROF);


--5

/*Se acerca el nuevo año y la consultora desea dar un bono a sus empleados,
equivalente a un 55% del total de los honorarios correspondientes
a las asesorías finalizadas en 2016. Elabore una vista que muestre 
el nombre de la persona, el monto total de los honorarios percibidos
y el monto del bono.*/


CREATE OR REPLACE VIEW V_BONO_EMPLEADOS AS 
SELECT P.APPPRO ||' '||P.APMPRO||' '||P.NOMPRO "NOMBRE",
SUM(A.HONORARIO)"HONORARIOS", SUM(A.HONORARIO)*0.55 "BONO"
FROM PROFESIONAL P JOIN ASESORIA A 
ON P.RUTPROF = A.RUTPROF
WHERE A.FIN BETWEEN '01/01/16' AND '31/12/16' 
GROUP by P.APPPRO,P.APMPRO,P.NOMPRO
ORDER BY"NOMBRE";

SELECT * FROM V_BONO_EMPLEADOS; 


--6

/*Con el fin de proyectar los ingresos que percibirá la corredora,
la Gerencia le ha solicitado un informe que detalle el número de 
asesorías que finalizan mes a mes durante el año en curso
(se consideró el 2016 para dicho efecto) además de detallar 
los ingresos totales por el concepto de honorarios, los que
para la consultora corresponden a un 60% del monto de los honorarios totales. 
El informe se debe mostrar con el formato de la imagen 
y ordenado por mes en forma ascendente.*/


SELECT TO_CHAR(FIN,'MONTH') "MES AÑO 2016", COUNT(*)"ASESORIAS", 
TO_CHAR(SUM(HONORARIO)*0.6,'$99G999G999')  "TOTAL HONORARIOS"
FROM ASESORIA
WHERE FIN BETWEEN '01/01/16' AND '31/12/16'
GROUP BY TO_CHAR(FIN,'MONTH'),EXTRACT(MONTH FROM FIN)
ORDER BY EXTRACT(MONTH FROM FIN);


--7

/* Se tienen algunas sospechas de que existen funcionarios de la consultora
cuya productividad ha bajado considerablemente en el último tiempo. 
Por esta razón le han solicitado elaborar un informe que detalle
cuáles son los Contadores Auditores 
que no han realizado asesorías durante el año en curso.*/
     
       
SELECT P.RUTPROF,
       P.APPPRO ||' '||P.APMPRO||' '||P.NOMPRO "PROFESIONAL",
       NVL(COUNT(A.HONORARIO),0)"ASESORÍAS"
       FROM ASESORIA A RIGHT JOIN PROFESIONAL P 
       ON A.RUTPROF = P.RUTPROF
       JOIN PROFESION PR ON PR.IDPROFESION = P.IDPROFESION
       WHERE PR.NOMPROFESION = 'Contador Auditor'
       GROUP BY P.RUTPROF,P.APPPRO,P.APMPRO,P.NOMPRO
       HAVING COUNT(A.HONORARIO)=0
       ORDER BY P.RUTPROF;


--8

/*Para fines financieros propios de la consultora,
le han solicitado un informe que detalle fecha de inicio,
fecha de fin, sector de la empresa y profesional que 
la efectúa de todas las asesorías del período,
efectuadas por Contadores Auditores en los sectores Banca y Servicios.*/

SELECT A.INICIO "INICIO",
       A.FIN "FIN",
       C.NOMSECTOR "SECTOR",
       P.APPPRO ||' '||P.APMPRO||' '||P.NOMPRO "PROFESIONAL"
       FROM SECTOR C JOIN EMPRESA E ON C.CODSECTOR = E.CODSECTOR
       JOIN ASESORIA A ON A.IDEMPRESA = E.IDEMPRESA
       JOIN PROFESIONAL P ON P.RUTPROF = A.RUTPROF
       JOIN PROFESION PR ON PR.IDPROFESION = P.IDPROFESION
       WHERE C.NOMSECTOR IN ('Banca','Servicios')AND 
       PR.NOMPROFESION = 'Contador Auditor'
       ORDER BY C.NOMSECTOR,APPPRO DESC;
       
       
       