
DROP TABLESPACE data_aprendiendo 
INCLUDING CONTENTS 
AND DATAFILES 
CASCADE CONSTRAINTS;

DROP TABLESPACE tmp_aprendiendo 
INCLUDING CONTENTS 
AND DATAFILES 
CASCADE CONSTRAINTS;

DROP TABLESPACE data_reporte_sql 
INCLUDING CONTENTS 
AND DATAFILES 
CASCADE CONSTRAINTS;

DROP TABLESPACE tmp_reporte_sql 
INCLUDING CONTENTS 
AND DATAFILES 
CASCADE CONSTRAINTS;

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

GRANT SELECT ON aprendiendo_sql.empleado_capacitacion   TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.capacitacion            TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.empleado_proyecto       TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.detalle_sueldo          TO reporte_sql;
GRANT SELECT ON aprendiendo_sql.empleado                TO reporte_sql;

GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.empleado_capacitacion TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.capacitacion TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.telefono TO reporte_sql; 
GRANT UPDATE, INSERT, DELETE ON aprendiendo_sql.contacto_emergencia TO reporte_sql; 


--- REQ 1.3

CREATE ROLE rol_admin;

GRANT CREATE SESSION        TO rol_admin;
GRANT CREATE TABLE          TO rol_admin;
GRANT DELETE ON ALL_TABLES  TO rol_admin;
GRANT UPDATE ON All_TABLES  TO rol_admin;
GRANT CREATE SEQUENCE       TO rol_admin;
GRANT CREATE VIEW           TO rol_admin;
GRANT CREATE INDEXTYPE      TO rol_admin;
GRANT CREATE PUBLIC SYNONYM TO rol_admin;

CREATE ROLE rol_reportes;

GRANT CREATE SESSION        TO rol_admin;
GRANT CREATE SYNONYM        TO rol_admin;

--- REQ 2


--- REQ 3

--- CREATE OR REPLACE VIEW VIEW_EMPLEADOS_PROYECTOS_VIGENTES AS
WITH empleado_asignado as (
    SELECT
        proyecto.codigo as codigo_proyecto,
        persona.apellido_pat || ' ' || persona.apellido_mat || ', '|| persona.nombres AS nombre
    FROM proyecto
    JOIN empleado on empleado.codigo_jefatura = proyecto.codigo_jefe_proyecto
    JOIN persona on persona.rut = empleado.rut_persona
);
SELECT 
    proyecto.codigo AS CODIGO_PROYECTO,
    proyecto.nombre AS NOMBRE_PROYECTO,
    departamento.nombre AS DEPARTAMENTO,
    persona.apellido_pat || ' ' || persona.apellido_mat || ', '|| persona.nombres AS JEFE_PROYECTO
  ---  empleado_asignado.nombre as EMPLEADO_ASIGNADO
    
--     AS EMPLEADO_ASIGNADO,
--     AS ROL_EN_PROYECTO
    FROM proyecto
    JOIN departamento ON proyecto.codigo_departamento = proyecto.codigo
    JOIN empleado ON empleado.codigo = proyecto.codigo_jefe_proyecto
    JOIN persona ON persona.rut = empleado.rut_persona
  ---  JOIN empleado_asignado ON empleado_asignado.codigo_proyecto = proyecto.codigo
    WHERE proyecto.estado = 'EN_CURSO';
  
SELECT * 
FROM PROYECTO 
JOIN departamento ON proyecto.codigo_departamento = proyecto.codigo
WHERE ESTADO = 'EN_CURSO';
    
select * from empleado;

select * from proyecto;

select * from persona;

select * from tipo_empleado;

