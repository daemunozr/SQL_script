--- req 1
SELECT
    nombre_tipo_moto AS "Tipo Moto",
    placa AS "Placa",
    color AS "Color",
    modelo AS "Modelo",
    cilindrada || ' ' || 'cc' AS "Cilindrada",
    anio_fab AS "Año Fab.",
    TO_CHAR(valor_arriendo_dia,'$999G999G999') AS "Arriendo/Dia",
    TO_CHAR(valor_garantia_dia,'$999G999G999') AS "Garantia/Dia",
    TO_CHAR(valor_arriendo_dia + valor_garantia_dia,'$999G999G999') AS "Total/Dia",
    SUBSTR(TO_CHAR(empleado.numrun_emp), 3, 1) || CASE
        WHEN nombre_tipo_moto = 'Deportiva' THEN UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 1, 1)) || UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 3, 1))
        WHEN nombre_tipo_moto = 'Naked' THEN UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 2, 1)) || UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), -1, 1))
        WHEN nombre_tipo_moto = 'Scooter' THEN UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 1, 1)) || UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 2, 1))
        ELSE UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 2, 1)) || UPPER(SUBSTR(TRIM(empleado.apmaterno_emp), 3, 1))
    END 
    || '@motornet.cl' AS "Correo"
FROM
    motocicleta
JOIN
    tipo_moto ON motocicleta.id_tipo_moto = tipo_moto.id_tipo_moto
JOIN
    empleado ON motocicleta.numrun_emp = empleado.numrun_emp
ORDER BY
    nombre_tipo_moto ASC,
    valor_arriendo_dia DESC,
    valor_garantia_dia ASC,
    placa ASC;
    
--- req 2

SELECT
    numrun_emp || '-' || dvrun_emp AS "RUN",
    TRIM(appaterno_emp) || ' ' || TRIM(apmaterno_emp) || ' ' || TRIM(pnombre_emp) || ' ' || nvl(TRIM(snombre_emp) || ' ' , '') AS "Nombre Completo",
    TO_CHAR(fecha_contrato, 'DD/MM/YYYY') AS "Fecha Contrato",
    TRIM(estado_civil.nombre_estado_civil) AS "Estado Civil",
    TO_CHAR(sueldo_base,'$999G999G999') AS "Sueldo Base",
    TO_CHAR(sueldo_base *(
        SELECT 
            porc_bonif_annos.porcentaje/100
        FROM 
            porc_bonif_annos
        WHERE 
            (porc_bonif_annos.sueldo_desde <= empleado.sueldo_base) and (empleado.sueldo_base <= porc_bonif_annos.sueldo_hasta))
    ,'$999G999G999')
    AS "Monto Bono 30 años",
    (SELECT
        porc_bonif_annos.porcentaje
    FROM 
        porc_bonif_annos
    WHERE 
        (porc_bonif_annos.sueldo_desde <= empleado.sueldo_base) and (empleado.sueldo_base <= porc_bonif_annos.sueldo_hasta))
    || '%' AS "% Sueldo Base"
FROM
    empleado
JOIN
    estado_civil on estado_civil.id_estado_civil = empleado.id_estado_civil
WHERE
    TO_CHAR(SYSDATE, 'YYYY') - TO_CHAR (empleado.fecha_contrato, 'YYYY')  <= 25
ORDER BY
   fecha_contrato ASC, appaterno_emp ASC; 

--- req 3
DROP TABLE HIST_ARRIENDO_ANUAL_MOTO CASCADE CONSTRAINTS;

CREATE TABLE HIST_ARRIENDO_ANUAL_MOTO AS (
SELECT
    motocicleta.placa AS PLACA,
    motocicleta.modelo AS MODELO,
    TO_CHAR(SYSDATE, 'YYYY') AS ANNO_PRCESO, 
    (SELECT 
        count(*)
    FROM 
        arriendo_moto
    WHERE 
        arriendo_moto.placa = motocicleta.placa and (TO_CHAR(SYSDATE, 'YYYY') = TO_CHAR(arriendo_moto.fecha_ini_arriendo, 'YYYY')) ) AS CANT_ARRIENDO,
    (SELECT 
        SUM(arriendo_moto.dias_solicitados)
    FROM 
        arriendo_moto
    WHERE 
        arriendo_moto.placa = motocicleta.placa AND (TO_CHAR(SYSDATE, 'YYYY') = TO_CHAR(arriendo_moto.fecha_ini_arriendo, 'YYYY')) ) AS TOTAL_DIAS
    FROM motocicleta
    WHERE 
        (SELECT
            COUNT(*)
        FROM
            arriendo_moto
        WHERE
            arriendo_moto.placa = motocicleta.placa AND (TO_CHAR(SYSDATE, 'YYYY') = TO_CHAR(arriendo_moto.fecha_ini_arriendo, 'YYYY'))) >= 2);
            
--- SELECT * FROM HIST_ARRIENDO_ANUAL_MOTO;
    