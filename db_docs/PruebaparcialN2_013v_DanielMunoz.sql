--- Daniel Muñoz Prueba 2 Seccion 013V

--- REQ 1.1
ALTER SESSION SET CONTAINER = XEPDB1;

CREATE TABLESPACE data_aprendiendo DATAFILE 'data_aprendiendo.dbf' SIZE 160M;
CREATE TEMPORARY TABLESPACE tmp_aprendiendo TEMPFILE 'tmp_aprendiendo.dbf' SIZE 90M;

CREATE USER aprendiendo_sql
IDENTIFIED BY "aprendiendo123"
DEFAULT TABLESPACE data_aprendiendo
TEMPORARY TABLESPACE tmp_aprendiendo
QUOTA 160M ON data_aprendiendo;

GRANT CREATE SESSION        TO aprendiendo_sql;
GRANT CREATE TABLE          TO aprendiendo_sql;
GRANT DELETE ON ALL_TABLES  TO aprendiendo_sql;
GRANT UPDATE ON All_TABLES  TO aprendiendo_sql;
GRANT CREATE SEQUENCE       TO aprendiendo_sql;
GRANT CREATE VIEW           TO aprendiendo_sql;
GRANT CREATE INDEXTYPE      TO aprendiendo_sql;
GRANT CREATE PUBLIC SYNONYM TO aprendiendo_sql;

CREATE TABLESPACE data_reporte DATAFILE 'data_reporte.dbf' SIZE 40M;
CREATE TEMPORARY TABLESPACE tmp_reporte TEMPFILE 'tmp_reporte.dbf' SIZE 40M;

CREATE USER reporte_sql
IDENTIFIED BY "reporte123"
DEFAULT TABLESPACE data_reporte
TEMPORARY TABLESPACE tmp_reporte
QUOTA 40M ON data_reporte;

GRANT 
    CREATE SESSION,  
    CREATE SYNONYM    
TO reporte_sql;

--- REQ 1.2

GRANT SELECT ON aprendiendo_sql.empleado_capacitaciON   TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.capacitaciON            TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.empleado_proyecto       TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.detalle_sueldo          TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.empleado                TO reporte_sql;

GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.empleado_capacitaciON TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.capacitaciON TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.telefONo TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.cONtacto_emergencia TO reporte_sql; 


--- REQ 1.3

CREATE ROLE rol_admin;

GRANT 
    CREATE SESSION,
    CREATE TABLE,
    CREATE SEQUENCE,
    CREATE VIEW,
    CREATE INDEXTYPE,
    CREATE PUBLIC SYNONYM
TO rol_admin;

GRANT 
    DELETE, 
    UPDATE 
ON ALL_TABLES  TO rol_admin;

CREATE ROLE rol_reportes;

GRANT 
    CREATE SESSION,
    CREATE SYNONYM
TO rol_admin;

--- REQ 2

UPDATE empleado
SET salario_bruto = ROUND(
  salario_bruto *
  CASE
    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) >= 20 THEN 1.12
    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) BETWEEN 10 AND 19 THEN 1.08
    WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecha_contrato)/12) BETWEEN 5 AND 9 THEN 1.05
    ELSE 1.02
  END
);

--- REQ 3


CREATE OR REPLACE VIEW VIEW_EMPLEADOS_PROYECTOS_VIGENTES AS
WITH empleado_asignado AS (
    SELECT
        empleado_proyecto.codigo_proyecto AS codigo_proyecto,
        persONa.apellido_pat || ' ' || persONa.apellido_mat || ', '|| persONa.nombres AS nombre,
        empleado_proyecto.rol_proyecto AS rol_en_proyecto,
        empleado_proyecto.horAS_semanales AS horAS_semanales
    FROM empleado_proyecto
    JOIN empleado ON empleado.codigo = empleado_proyecto.codigo_empleado
    JOIN persONa ON persONa.rut = empleado.rut_persONa
)
SELECT 
    proyecto.codigo AS CODIGO_PROYECTO,
    proyecto.nombre AS NOMBRE_PROYECTO,
    departamento.nombre AS DEPARTAMENTO,
    persONa.apellido_pat || ' ' || persONa.apellido_mat || ', '|| persONa.nombres AS JEFE_PROYECTO,
    empleado_asignado.nombre AS EMPLEADO_ASIGNADO,
    empleado_asignado.rol_en_proyecto,
    empleado_aSignado.horAS_semanales,
    SUM(empleado_asignado.horaS_semanales) OVER (PARTITION BY proyecto.codigo) AS total_horas
FROM proyecto
JOIN departamento ON proyecto.codigo_departamento = departamento.codigo
JOIN empleado ON empleado.codigo = proyecto.codigo_jefe_proyecto
JOIN persONa ON persONa.rut = empleado.rut_persONa
JOIN empleado_ASignado  ON empleado_ASignado.codigo_proyecto = proyecto.codigo
WHERE proyecto.estado = 'EN_CURSO'
ORDER BY proyecto.nombre ASC, total_horas ASC
WITH READ ONLY;

--- REQ 4.1

CREATE INDEX idx_tarea_estado_prioridad 
ON tarea(estado, prioridad);

--- REQ 4.2

CREATE INDEX idx_asistencia_fecha_empleado 
ON asistencia(fecha, codigo_empleado);