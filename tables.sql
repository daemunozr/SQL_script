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
