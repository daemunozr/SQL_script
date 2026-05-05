/* =========================================================
   LABORATORIO ORACLE - INDICES Y OPTIMIZACION
   ========================================================= */

-- =========================================
-- 1. LIMPIEZA (opcional)
-- =========================================
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ventas';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE clientes';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE productos';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- =========================================
-- 2. CREACION DE TABLAS
-- =========================================

CREATE TABLE clientes (
    id_cliente NUMBER PRIMARY KEY,
    nombre     VARCHAR2(50),
    apellido   VARCHAR2(50),
    rut        VARCHAR2(12),
    ciudad     VARCHAR2(50)
);

CREATE TABLE ventas (
    id_venta   NUMBER PRIMARY KEY,
    id_cliente  NUMBER,
    fecha       DATE,
    total       NUMBER
);

CREATE TABLE productos (
    id       NUMBER PRIMARY KEY,
    nombre   VARCHAR2(50),
    precio   NUMBER
);

-- =========================================
-- 3. INSERCION DE DATOS
-- =========================================

-- CLIENTES
INSERT INTO clientes VALUES (1,'Juan','Perez','11111111-1','Santiago');
INSERT INTO clientes VALUES (2,'Maria','Lopez','22222222-2','Valparaiso');
INSERT INTO clientes VALUES (3,'Pedro','Gomez','33333333-3','Concepcion');
INSERT INTO clientes VALUES (4,'Ana','Diaz','44444444-4','La Serena');

-- VENTAS
INSERT INTO ventas VALUES (100,1,SYSDATE,50000);
INSERT INTO ventas VALUES (101,2,SYSDATE,120000);
INSERT INTO ventas VALUES (102,1,SYSDATE,30000);
INSERT INTO ventas VALUES (103,3,SYSDATE,80000);

-- PRODUCTOS
INSERT INTO productos VALUES (1,'Mouse',10000);
INSERT INTO productos VALUES (2,'Teclado',20000);
INSERT INTO productos VALUES (3,'Monitor',150000);

COMMIT;

-- =========================================
-- 4. CONSULTA SIN INDICE (PRUEBA)
-- =========================================

-- Consulta por RUT (sin índice aún)

SELECT *
FROM 
   clientes
WHERE 
   rut = '11111111-1';

--- EXPLAIN PLAN sin indice

EXPLAIN PLAN FOR
SELECT *
FROM 
   clientes
WHERE 
   rut = '11111111-1';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =========================================
-- 5. CREACION DE INDICES
-- =========================================

-- Índice para búsqueda por RUT

CREATE INDEX idx_clientes_rut ON clientes(rut);

-- Índice para ventas por cliente

CREATE INDEX idx_ventas_clientes ON ventas(id_cliente);

-- Índice para ventas por fecha

CREATE INDEX idx_ventas_fechas ON ventas(fecha);

-- Índice para productos por nombre

CREATE INDEX idx_productos_nombre ON productos(nombre);


-- =========================================
-- 6. CONSULTA OPTIMIZADA
-- =========================================

SELECT *
FROM 
   clientes
WHERE 
   rut = '11111111-1';

--- EXPLAIN PLAN con indice

EXPLAIN PLAN FOR
SELECT *
FROM 
   clientes
WHERE 
   rut = '11111111-1';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- =========================================
-- 7. CONSULTAS DE PRACTICA
-- =========================================

-- PRACTICA 1:
-- ¿Qué hace esta consulta?
SELECT * FROM ventas WHERE id_cliente = 1;

DESCRIBE ventas;

-- PRACTICA 2:
-- ¿Qué índice ayudaría a mejorarla?

CREATE INDEX idx_ventas_clientes ON ventas(id_cliente);

-- PRACTICA 3:
-- Consulta por productos

SELECT * FROM productos WHERE nombre = 'Mouse';

-- =========================================
-- 8. EJERCICIO ALUMNO (SIN RESPUESTA)
-- =========================================

-- Crear tabla:
-- pedidos(id_pedido, id_cliente, monto, fecha)

-- Insertar 5 registros

-- Consultar:
-- SELECT * FROM pedidos WHERE id_cliente = X;

-- Pregunta:
-- ¿Qué índice crearías y por qué?

-- =========================================
-- FIN LABORATORIO
-- =========================================