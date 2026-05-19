---REQ 1

-- 1. Creación de Tablespaces para MARINE_SQL y REPORTE_MARINE
CREATE TABLESPACE data_marine DATAFILE 'data_marine_01.dbf' SIZE 120M;
CREATE TEMPORARY TABLESPACE temp_marine TEMPFILE 'temp_marine_01.dbf' SIZE 80M;

CREATE TABLESPACE data_reporte DATAFILE 'data_reporte_01.dbf' SIZE 55M;
CREATE TEMPORARY TABLESPACE temp_reporte TEMPFILE 'temp_reporte_01.dbf' SIZE 55M;

-- 2. Creación de Usuarios
CREATE USER MARINE_SQL IDENTIFIED BY "MarineSql.2026"
    DEFAULT TABLESPACE data_marine
    TEMPORARY TABLESPACE temp_marine
    QUOTA UNLIMITED ON data_marine;

CREATE USER REPORTE_MARINE IDENTIFIED BY "ReporteMarine.2026"
    DEFAULT TABLESPACE data_reporte
    TEMPORARY TABLESPACE temp_reporte
    QUOTA UNLIMITED ON data_reporte;

-- 3. Asignación de Permisos de Sistema (Roles y Privilegios directos)
-- Permisos para MARINE_SQL (Dueño del modelo)
GRANT CREATE SESSION TO MARINE_SQL;
GRANT CREATE TABLE TO MARINE_SQL;
GRANT CREATE VIEW TO MARINE_SQL;
GRANT CREATE INDEX TO MARINE_SQL;
GRANT CREATE PUBLIC SYNONYM TO MARINE_SQL;

-- Permisos para REPORTE_MARINE (Generador de reportes)
GRANT CREATE SESSION TO REPORTE_MARINE;
GRANT CREATE VIEW TO REPORTE_MARINE;

-- 4. Asignación de Permisos sobre Objetos (Ejecutar conectado como MARINE_SQL o SYSTEM)
-- Accesos de Solo Lectura
GRANT SELECT ON MARINE_SQL.CLIENTE TO REPORTE_MARINE;
GRANT SELECT ON MARINE_SQL.EMPLEADO TO REPORTE_MARINE;
GRANT SELECT ON MARINE_SQL.REGION TO REPORTE_MARINE;
GRANT SELECT ON MARINE_SQL.ARRIENDO_EMBARCACION TO REPORTE_MARINE;

-- Accesos DML completos (Insert, Update, Delete + Select)
GRANT SELECT, INSERT, UPDATE, DELETE ON MARINE_SQL.EMBARCACION TO REPORTE_MARINE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MARINE_SQL.TIPO_EMBARCACION TO REPORTE_MARINE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MARINE_SQL.FABRICANTE TO REPORTE_MARINE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MARINE_SQL.ESTADO_CIVIL TO REPORTE_MARINE;
GRANT SELECT, INSERT, UPDATE, DELETE ON MARINE_SQL.PORC_BONIF_30_ANNOS TO REPORTE_MARINE;

-- REQ 2


UPDATE EMBARCACION
SET valor_arriendo_dia = (SELECT MAX(valor_arriendo_dia) FROM EMBARCACION)
WHERE id_tipo_emb = 'M' 
  AND anio_fab >= 2020;

COMMIT;

-- REQ 3

CREATE OR REPLACE VIEW VIEW_ARRIENDOS_VIGENTES AS
SELECT 
    a.id_arriendo,
    a.matricula,
    e.motor,
    e.eslora AS eslora_mts,
    te.nombre_tipo_emb AS tipo_embarcacion,
    c.appaterno_cli || ' ' || c.apmaterno_cli || ', ' || c.pnombre_cli AS cliente,
    tc.nombre_tipo_cli AS tipo_cliente,
    a.fecha_ini_arriendo AS fecha_inicio,
    a.dias_solicitados,
    a.fecha_devolucion,
    e.valor_arriendo_dia AS valor_dia,
    NVL(e.valor_garantia_dia, 0) AS valor_garantia_dia,
    -- Calculo del total: (días * arriendo) + (días * garantía)
    (a.dias_solicitados * e.valor_arriendo_dia) + 
    (a.dias_solicitados * NVL(e.valor_garantia_dia, 0)) AS monto_total
FROM MARINE_SQL.ARRIENDO_EMBARCACION a
INNER JOIN MARINE_SQL.EMBARCACION e 
    ON a.matricula = e.matricula
INNER JOIN MARINE_SQL.TIPO_EMBARCACION te 
    ON e.id_tipo_emb = te.id_tipo_emb
INNER JOIN MARINE_SQL.CLIENTE c 
    ON a.numrun_cli = c.numrun_cli
INNER JOIN MARINE_SQL.TIPO_CLIENTE tc 
    ON c.id_tipo_cli = tc.id_tipo_cli
WHERE a.fecha_devolucion >= SYSDATE 
   OR a.fecha_devolucion IS NULL
ORDER BY a.fecha_ini_arriendo DESC, c.appaterno_cli ASC;

-- REQ 4

-- CASO A

-- Índice 1: Para optimizar el filtro principal de la tabla cliente
CREATE INDEX IDX_CLIENTE_TIPO_CLI ON CLIENTE(id_tipo_cli);

-- Índice 2: Para optimizar el cruce de Embarcación con el Fabricante filtrado
CREATE INDEX IDX_EMBARCACION_FABRICANTE ON EMBARCACION(id_fabricante);

-- CASO B

-- Índice 1: Agiliza la búsqueda por el rango del periodo específico
CREATE INDEX IDX_ARRIENDO_FECHA_INI ON ARRIENDO_EMBARCACION(fecha_ini_arriendo);

-- Índice 2: Índice compuesto opcional para optimizar simultáneamente el filtro y el Join
CREATE INDEX IDX_ARRIENDO_MAT_FECHA ON ARRIENDO_EMBARCACION(matricula, fecha_ini_arriendo);