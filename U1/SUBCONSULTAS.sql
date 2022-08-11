--Práctica de Subconsultas
--UNA SUBCONSULTA PUEDE APARECER EN CUALQUIERA DE LAS CLAUSULAS
--DE LA CONSULTA DE EXCEPCIÓN DE ORDER BY Y GROUP BY
--SIRVEN PARA RESOLVER UNA INCOGNITA Y RETORNAN UN VALOR.

/*SELECT lista_de AS campos
FROM tabla
WHERE campo operador (SELECT campo
                      FROM tabla
                      where condicion);
*/      
                      
--Empleados que viven en la misma comuna que marta galvez castro
SELECT rutemp AS run,
  paterno || ' ' || materno || ' ' || nombre AS nombre,
  puntaje, sueldo
FROM empleado
WHERE idcomuna = (SELECT idcomuna
                  FROM empleado
                  WHERE paterno || ' ' || materno || ' ' || nombre = 
                    'GALVEZ CASTRO MARTA');
                    
--empleados que perciben un sueldo mayor que el sueldo promedio entre los empleados
SELECT rutemp AS run,
  paterno || ' ' || materno || ' ' || nombre AS nombre,
  puntaje, sueldo
FROM empleado
WHERE sueldo > (SELECT avg(sueldo)
                  FROM empleado);
                          
--TIPOS DE SUBCONSULTA
--Consulta de fila única: retornan una fila, usar con ellos operadores tradicionales (< > <= => != <> =)
--Subconsulta de multiples filas: usar con ellos operadores de conjunto (ANY/SOME - ALL - IN/NOT IN)
--IN - ANY - SOME equivalen a un OR || ALL equivale a un AND

--Propiedades administradas por empleados que trabajan en la oficina de Calama 150
SELECT *
FROM propiedad
WHERE rutemp IN (SELECT rutemp
                FROM empleado
                WHERE numoficina = (SELECT numoficina
                                    FROM oficina
                                    WHERE diroficina = 'Calama 150'));
SELECT *
FROM propiedad
WHERE rutemp = ANY (SELECT rutemp
                FROM empleado
                WHERE numoficina = (SELECT numoficina
                                    FROM oficina
                                    WHERE diroficina = 'Calama 150'));                                  
SELECT *
FROM propiedad
WHERE rutemp = SOME (SELECT rutemp
                FROM empleado
                WHERE numoficina = (SELECT numoficina
                                    FROM oficina
                                    WHERE diroficina = 'Calama 150'));                                    

--Empleados que poseen un puntaje mayor a todos los puntajes de los empleados de la oficina 130.
SELECT rutemp AS run,
  paterno || ' ' || materno || ' ' || nombre AS nombre,
  puntaje, sueldo
FROM empleado
WHERE puntaje > ALL (SELECT puntaje
                FROM empleado
                WHERE numoficina = 130);
                
--Oficinas en que el numero de empleados es mayor que el promedio de empleados por oficina
SELECT o.diroficina AS oficina, count(*) as empleados
FROM oficina o JOIN empleado e
ON o.numoficina = e.numoficina
GROUP BY o.diroficina
HAVING count(*) > (SELECT avg(count(*))
                   FROM empleado
                   group by numoficina);

--Oficina con el total de sueldos más alto
SELECT o.diroficina AS oficina, sum(sueldo) as "TOTAL SUELDOS "
FROM oficina o JOIN empleado e
ON o.numoficina = e.numoficina
GROUP BY o.diroficina
HAVING sum(sueldo) = (SELECT MAX(sum(sueldo))
                     FROM empleado
                     GROUP BY numoficina);

--Uso del operador EXISTS
--Sirve para verificar si una tabla posee registros relacionados en otra tabla

--Oficinas que poseen empleados
SELECT diroficina AS oficina
FROM oficina o
WHERE EXISTS (SELECT *
              FROM empleado e
              WHERE e.numoficina = o.numoficina);
              
--Clientes que no han efectuado visitas
SELECT rutcli AS run,
  paterno || ' ' || materno || ' ' || nombre AS cliente
FROM cliente cl
WHERE NOT EXISTS (SELECT *
              FROM visita v
              where v.rutcli = cl.rutcli);
              
                
                
                
                
                