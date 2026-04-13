
/*
Basic Oracle SQL query structure. Order of evaluation FROM -> JOIN -> WHERE -> GOURP BY -> HAVING -> SELECT -> DISTINT -> ORDER BY -> FETCH
*/

SELECT column1, SUM(column2) AS total  -- Choose columns and aggregates
FROM table_a                           -- Main table
JOIN table_b ON table_a.id = table_b.id -- Combine tables based on a condition
WHERE table_a.status = 'ACTIVE'        -- Filter raw rows before grouping
GROUP BY column1                       -- Group rows for aggregation
HAVING SUM(column2) > 100              -- Filter groups (optional)
ORDER BY total DESC;                   -- Sort final results (optional)

/*
Guía de Subconsultas en Oracle SQL

Contexto general

Un banco necesita analizar la información de sus clientes, cuentas y movimientos financieros (depósitos y retiros). Para ello, se requiere desarrollar consultas SQL utilizando subconsultas en distintas partes de la sentencia (SELECT, WHERE y FROM).

*/

/*
Ejercicio 1 — Subconsulta en SELECT
Enunciado: El banco desea conocer cuánto dinero ha depositado cada cliente en total.

Para esto, debes:

Mostrar el nombre del cliente.
Calcular el total acumulado de depósitos realizados en todas sus cuentas.
Si un cliente no tiene depósitos, el resultado puede aparecer como NULL.

La solución debe usar una subconsulta dentro del SELECT.
*/

select clientes.nombre , --solucion mala
(select sum(transacciones.monto )
from cuentas
join transacciones on cuentas.id_cuenta = transacciones.id_cuenta
and transacciones.tipo = 'DEPOSITO') as total_depositos
from clientes;

--subtable temporal
select cuentas.id_cuenta, 
sum(transacciones.monto) as total_depositos
from transacciones
join cuentas on cuentas.id_cuenta = transacciones.id_cuenta
where transacciones.tipo = 'DEPOSITO'
group by transacciones.id_cuenta;

--solucion sin IA
with tmp_query as 
(select cuentas.id_cuenta,
sum(transacciones.monto) as total_depositos
from transacciones
join cuentas on cuentas.id_cuenta = transacciones.id_cuenta
where transacciones.tipo = 'DEPOSITO'
group by transacciones.id_cuenta)
select clientes.nombre, tmp_query.total_depositos
from clientes
left join cuentas on cuentas.id_cliente = clientes.id_cliente
left join tmp_query on tmp_query.id_cuenta = cuentas.id_cuenta;

--solucion con IA. Orden de ejecucion es FROM -> JOIN -> SELECT -> WHERE
select clientes.nombre, 
(select sum(transacciones.monto)
from transacciones
join cuentas on transacciones.id_cuenta = cuentas.id_cuenta
where cuentas.id_cliente = clientes.id_cliente
and transacciones.tipo = 'DEPOSITO'
) as total_depositos
from clientes;

/*
Ejercicio 2 — Subconsulta en SELECT
Enunciado: Se requiere analizar la actividad de cada cuenta bancaria.

Para ello realizar lo siguiente:

Mostrar el ID de cada cuenta.
Indicar la cantidad total de transacciones (depósitos y retiros) asociadas a esa cuenta.

Debes resolverlo usando una subconsulta en el SELECT.
*/

select cuentas.id_cuenta,
(select count(*)
from transacciones
where transacciones.id_cuenta = cuentas.id_cuenta
) as cantidad_transacciones
from cuentas;

--- Muestra en vez de id_cuentas, nombre de clientes

select clientes.nombre,
(select count(*)
from transacciones
where transacciones.id_cuenta = cuentas.id_cuenta
) as cantidad_transacciones
from clientes
join cuentas on clientes.id_cliente = cuentas.id_cliente;

/*
Ejercicio 3 — Subconsulta en WHERE (comparación)
Enunciado: El banco quiere identificar clientes con alto saldo.

Para esto:

Mostrar el nombre del cliente y su saldo.
Considerar solo aquellos clientes cuyo saldo sea mayor que el promedio de saldo de todas las cuentas del banco.

Debes usar una subconsulta en la cláusula WHERE.
*/

select clientes.nombre,
cuentas.saldo
from clientes
join cuentas on cuentas.id_cliente = clientes.id_cliente
where cuentas.saldo > (select avg(saldo) from cuentas);

/*
Ejercicio 4 — Subconsulta en WHERE con IN
Enunciado: El banco necesita identificar clientes que han realizado retiros.

Para esto:

Mostrar únicamente los nombres de los clientes.
Considerar aquellos clientes que tengan al menos una transacción de tipo 'RETIRO'.

Debes usar una subconsulta con IN en el WHERE.
*/

select clientes.nombre
from clientes
join cuentas on clientes.id_cliente = cuentas.id_cliente
where cuentas.id_cuenta in (
select transacciones.id_cuenta
from transacciones
where transacciones.tipo = 'RETIRO');

/*
Ejercicio 5 — Subconsulta en WHERE con EXISTS
Enunciado:

El banco desea detectar clientes que realizan movimientos de alto valor.

Para ello:

Mostrar el nombre de los clientes.
Considerar solo aquellos que tengan al menos una transacción superior a 2000.

Debes usar una subconsulta con EXISTS.
*/

select clientes.nombre
from clientes
where exists (
select cuentas.id_cliente
from transacciones
join cuentas on cuentas.id_cuenta = transacciones.id_cuenta
where clientes.id_cliente = cuentas.id_cliente and transacciones.monto >= 2000);

/*
Ejercicio 6 — Subconsulta en FROM (tabla derivada)
Enunciado: Se requiere analizar los depósitos por cuenta.

Para ello:

Calcular el total de depósitos por cada cuenta.
Mostrar solo aquellas cuentas cuyo total de depósitos sea mayor a 2000.

Debes realizar:

Crear una subconsulta en el FROM (tabla derivada).
Luego filtrar el resultado en la consulta externa.
*/

select clientes.nombre, resumen.mov_total
from
(select transacciones.id_cuenta, nvl(sum(
case when transacciones.tipo = 'DEPOSITO' then transacciones.monto
when transacciones.tipo = 'RETIRO' then 0
end) ,0) as mov_total
from transacciones
group by transacciones.id_cuenta) resumen
join cuentas on cuentas.id_cuenta = resumen.id_cuenta
join clientes on clientes.id_cliente = cuentas.id_cliente
where resumen.mov_total > 2000;

--- sunquery
select transacciones.id_cuenta, nvl(sum(
case when transacciones.tipo = 'DEPOSITO' then transacciones.monto
when transacciones.tipo = 'RETIRO' then 0
end) ,0) as mov_total
from transacciones
group by transacciones.id_cuenta;

/*
Ejercicio 7 — Subconsulta en FROM con JOIN
Enunciado: El banco necesita conocer el total de dinero retirado por cada cliente.

Para esto:

Mostrar el nombre del cliente.
Calcular el total de retiros considerando todas sus cuentas.

Debes realizar:

Usar una subconsulta en el FROM para calcular los retiros por cuenta.
Luego relacionarla con clientes mediante JOIN.
*/

select clientes.nombre, retiros
from(
select cuentas.id_cliente, nvl(sum(transacciones.monto),0) as retiros
from cuentas
left join transacciones on cuentas.id_cuenta = transacciones.id_cuenta
and transacciones.tipo = 'RETIRO'
group by cuentas.id_cliente) resumen
left join clientes on clientes.id_cliente = resumen.id_cliente;

--- subquery
select cuentas.id_cliente, nvl(sum(transacciones.monto),0) as retiros
from cuentas
left join transacciones on cuentas.id_cuenta = transacciones.id_cuenta 
and transacciones.tipo = 'RETIRO'
group by cuentas.id_cliente;

/*
Ejercicio 8 — Subconsulta correlacionada
Enunciado: El banco quiere evaluar la relación entre saldo y retiros.

Para ello:

Mostrar las cuentas.
Incluir solo aquellas donde el saldo actual sea mayor que el total de dinero retirado desde esa misma cuenta.

Debes usar una subconsulta correlacionada en el WHERE.
*/

select cuentas.id_cliente
from cuentas
where saldo > 
(select nvl(sum(transacciones.monto),0)
from transacciones
where cuentas.id_cuenta = transacciones.id_cuenta 
and transacciones.tipo = 'RETIRO');

--- subquery 1 no correlacionada
select saldo >  nvl(sum(transacciones.monto),0)
from transacciones
join cuentas on cuentas.id_cuenta = transacciones.id_cuenta 
and transacciones.tipo = 'RETIRO';

/*
Ejercicio 9 — Subconsulta en SELECT (acumulación)
Enunciado: El banco quiere conocer el patrimonio total de cada cliente dentro de la institución.

Para esto:

Mostrar el nombre del cliente.
Calcular la suma de los saldos de todas sus cuentas.

Debes usar una subconsulta dentro del SELECT.
*/

select clientes.nombre,
(select sum(cuentas.saldo) + nvl(
sum(
case
when transacciones.tipo = 'DEPOSITO' then transacciones.monto
when transacciones.tipo = 'RETIRO' then -transacciones.monto
end), 0)
from cuentas
left join transacciones on cuentas.id_cuenta = transacciones.id_cuenta
where cuentas.id_cliente = clientes.id_cliente) as 'total cuenta'
from clientes;

--- query with two common table expresion (cte)
with 
tmp_deposito as 
(
select transacciones.id_cuenta,
sum(transacciones.monto) as total_depositos
from transacciones
where transacciones.tipo = 'DEPOSITO'
group by transacciones.id_cuenta
),
tmp_retiro as
(
select transacciones.id_cuenta,
sum(transacciones.monto) as total_retiros
from transacciones
where transacciones.tipo = 'RETIRO'
group by transacciones.id_cuenta
)
select clientes.nombre,
cuentas.saldo + nvl(tmp_deposito.total_depositos, 0) - nvl(tmp_retiro.total_retiros, 0) as saldo
from clientes
left join cuentas on cuentas.id_cliente = clientes.id_cliente
left join tmp_deposito on cuentas.id_cuenta = tmp_deposito.id_cuenta
left join tmp_retiro on cuentas.id_cuenta = tmp_retiro.id_cuenta;

--- query with SUM optimize
select clientes.nombre, cuentas.saldo + resumen.mov_total as saldo_actual
from clientes
left join cuentas on clientes.id_cliente = cuentas.id_cliente
left join (
select transacciones.id_cuenta, nvl(sum(
case when transacciones.tipo = 'DEPOSITO' then transacciones.monto
when transacciones.tipo = 'RETIRO' then -transacciones.monto
end) ,0) as mov_total
from transacciones
group by transacciones.id_cuenta) resumen on resumen.id_cuenta = cuentas.id_cuenta;

