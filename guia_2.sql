CREATE TABLE clientes (
    id_cliente NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    ciudad VARCHAR2(100)
);

CREATE TABLE cuentas (
    id_cuenta NUMBER PRIMARY KEY,
    id_cliente NUMBER,
    saldo NUMBER,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE transacciones (
    id_transaccion NUMBER PRIMARY KEY,
    id_cuenta NUMBER,
    tipo VARCHAR2(10), -- 'DEPOSITO' o 'RETIRO'
    monto NUMBER,
    fecha DATE,
    FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);

-- Clientes
INSERT INTO clientes VALUES (1, 'Ana Torres', 'Santiago');
INSERT INTO clientes VALUES (2, 'Luis Perez', 'Valparaiso');
INSERT INTO clientes VALUES (3, 'Maria Lopez', 'Santiago');
INSERT INTO clientes VALUES (4, 'Carlos Diaz', 'Concepcion');

-- Cuentas
INSERT INTO cuentas VALUES (101, 1, 5000);
INSERT INTO cuentas VALUES (102, 2, 3000);
INSERT INTO cuentas VALUES (103, 3, 8000);
INSERT INTO cuentas VALUES (104, 4, 2000);

-- Transacciones
INSERT INTO transacciones VALUES (1, 101, 'DEPOSITO', 2000, SYSDATE);
INSERT INTO transacciones VALUES (2, 101, 'RETIRO', 500, SYSDATE);
INSERT INTO transacciones VALUES (3, 102, 'DEPOSITO', 1500, SYSDATE);
INSERT INTO transacciones VALUES (4, 103, 'RETIRO', 1000, SYSDATE);
INSERT INTO transacciones VALUES (5, 103, 'DEPOSITO', 3000, SYSDATE);
INSERT INTO transacciones VALUES (6, 104, 'RETIRO', 700, SYSDATE);

COMMIT;





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



/*
Ejercicio 2 — Subconsulta en SELECT
Enunciado: Se requiere analizar la actividad de cada cuenta bancaria.

Para ello realizar lo siguiente:

Mostrar el ID de cada cuenta.
Indicar la cantidad total de transacciones (depósitos y retiros) asociadas a esa cuenta.

Debes resolverlo usando una subconsulta en el SELECT.
*/



/*
Ejercicio 3 — Subconsulta en WHERE (comparación)
Enunciado: El banco quiere identificar clientes con alto saldo.

Para esto:

Mostrar el nombre del cliente y su saldo.
Considerar solo aquellos clientes cuyo saldo sea mayor que el promedio de saldo de todas las cuentas del banco.

Debes usar una subconsulta en la cláusula WHERE.
*/



/*
Ejercicio 4 — Subconsulta en WHERE con IN
Enunciado: El banco necesita identificar clientes que han realizado retiros.

Para esto:

Mostrar únicamente los nombres de los clientes.
Considerar aquellos clientes que tengan al menos una transacción de tipo 'RETIRO'.

Debes usar una subconsulta con IN en el WHERE.
*/


/*
Ejercicio 5 — Subconsulta en WHERE con EXISTS
Enunciado:

El banco desea detectar clientes que realizan movimientos de alto valor.

Para ello:

Mostrar el nombre de los clientes.
Considerar solo aquellos que tengan al menos una transacción superior a 2000.

Debes usar una subconsulta con EXISTS.
*/



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



/*
Ejercicio 8 — Subconsulta correlacionada
Enunciado: El banco quiere evaluar la relación entre saldo y retiros.

Para ello:

Mostrar las cuentas.
Incluir solo aquellas donde el saldo actual sea mayor que el total de dinero retirado desde esa misma cuenta.

Debes usar una subconsulta correlacionada en el WHERE.
*/


/*
Ejercicio 9 — Subconsulta en SELECT (acumulación)
Enunciado: El banco quiere conocer el patrimonio total de cada cliente dentro de la institución.

Para esto:

Mostrar el nombre del cliente.
Calcular la suma de los saldos de todas sus cuentas.

Debes usar una subconsulta dentro del SELECT.
*/

