----FUNCIONES GENERALES----
--NVL (PERMITE REEMPLAZAR UN VALOR NULO POR UN VALOR VÁLIDO)
--DICHO VALOR DEBE SER DEL MISMO TIPO DE DATO DEL CAMPO RESPECTIVO.
SELECT last_name || ' ' || first_name AS nombre,
  NVL(manager_id, 0) AS jefe,
  NVL(TO_CHAR(manager_id), 'SIN JEFE') as jefe_2
FROM employees;

--PRÁCTICA FUNCIONES DE GRUPO
--Cantidad de empleados que trabajan en la empresa
SELECT count(*) as cantidad_empleados
FROM employees;

SELECT count(NVL(commission_pct,0)) --count no considera los valores nulos.
FROM employees;

--Cantidad empleados trabajando en el depto 50
SELECT count(*)
FROM employees
WHERE department_id = 50;

--Cuanto ganan en total los empleados de los departamento 30, 40, 50 y 60
SELECT sum(salary)
FROM employees
WHERE department_id IN(30,40,50,60); --IN equilavale al uso de OR

--Determinar sueldo mínimo. sueldo máximo,
--sueldo promedio y numero de empleados
--en los departamentos que no sean 50, 80 y 90
SELECT MIN(salary) AS sueldo_minimo,
  MAX(salary) AS sueldo_maximo,
  avg(salary) AS sueldo_promedio,
  count(*) AS cantidad_empleados
FROM employees
WHERE department_id NOT IN (50,80,90);

--Número de empleados en cada departamento
SELECT NVL(TO_CHAR(department_id), 'SIN DEPARTAMENTO') AS departamento,
  count(*) AS empleado
FROM employees
GROUP BY department_id
ORDER BY department_id;  

--Determinar el número de empleados, el sueldo promedio
--y el total de los sueldos para cada departamento
--y trabajo existente.
SELECT department_id AS departamento,
  job_id AS trabajo_existente,
  count(*) AS numero_empleados,
  TRUNC(avg(salary)) AS sueldo_promedio,
  sum(salary) AS total_sueldo
FROM employees
GROUP BY department_id, job_id --No es necesario que esté escrito en el SELECT
ORDER BY sum(salary); --Se puede ordenar solo por los datos de salida.

-- Suma de los sueldos en cada uno de los departamentos
SELECT department_id AS department_id,
  sum(salary) AS "SUMA DE SUELDOS"
FROM employees
GROUP BY department_id
ORDER BY department_id;

--Departamento en que los empleados tienen mayor sueldo
SELECT MAX(sum(salary))
FROM employees
group by department_id;

--Departamento en que los números de empleados son superior a 3 
SELECT department_id AS departamento,
  count(*) empleados
FROM employees
GROUP BY department_id
HAVING count(*) > 3; --es necesario having count, ya que 'WHERE' solo trabaja con datos físicos.


