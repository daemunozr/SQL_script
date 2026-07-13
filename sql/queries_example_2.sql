SELECT
  -- Se concatena el RUN con su dígito verificador
  e.numrun_emp || '-' || e.dvrun_emp AS "RUN",
  -- Formateo del nombre completo: ApPaterno ApMaterno PNombre SNombre
  e.appaterno_emp || ' ' || e.apmaterno_emp || ' ' || e.pnombre_emp || NVL(' ' || e.snombre_emp, '') AS "Nombre Completo",
  TO_CHAR(e.fecha_contrato, 'DD/MM/YYYY') AS "Fecha Contrato",
  ec.nombre_estado_civil AS "Estado Civil",
  TO_CHAR(e.sueldo_base, '$999G999G999') AS "Sueldo Base",
  -- Cálculo del bono según la fórmula entregada
  TO_CHAR(ROUND(e.sueldo_base * p.porcentaje / 100), '$999G999G999') AS "Monto Bono",
  
  p.porcentaje || '%' AS "Porcentaje"
FROM EMPLEADO e
JOIN ESTADO_CIVIL ec
  ON e.id_estado_civil = ec.id_estado_civil
JOIN PORC_BONIF_ANNOS p
  ON e.sueldo_base BETWEEN p.sueldo_desde AND p.sueldo_hasta
-- Filtro: Menos de 25 años calculados al último día del mes actual
WHERE TRUNC(MONTHS_BETWEEN(LAST_DAY(SYSDATE), e.fecha_contrato) / 12) < 25
-- Orden de los datos solicitados
ORDER BY e.fecha_contrato ASC, e.appaterno_emp ASC;



SELECT
  -- Se concatena el RUN con su dígito verificador
  e.numrun_emp || '-' || e.dvrun_emp AS "RUN",
  -- Formateo del nombre completo: ApPaterno ApMaterno PNombre SNombre
  e.appaterno_emp || ' ' || e.apmaterno_emp || ' ' || e.pnombre_emp ||
  NVL(' ' || e.snombre_emp, '') AS "Nombre Completo",
  TO_CHAR(e.fecha_contrato, 'DD/MM/YYYY') AS "Fecha Contrato",
  ec.nombre_estado_civil AS "Estado Civil",
  TO_CHAR(e.sueldo_base, '$999G999G999') AS "Sueldo Base",
  -- Cálculo del bono según la fórmula entregada
  TO_CHAR(ROUND(e.sueldo_base * p.porcentaje / 100), '$999G999G999') AS "Monto Bono",
  p.porcentaje || '%' AS "Porcentaje"
FROM EMPLEADO e
JOIN ESTADO_CIVIL ec
  ON e.id_estado_civil = ec.id_estado_civil
JOIN PORC_BONIF_ANNOS p
  ON e.sueldo_base BETWEEN p.sueldo_desde AND p.sueldo_hasta

-- Filtro: Menos de 25 años calculados al último día del mes actual
WHERE TRUNC(MONTHS_BETWEEN(LAST_DAY(SYSDATE), e.fecha_contrato) / 12) < 25
-- Orden de los datos solicitados
ORDER BY e.fecha_contrato ASC, e.appaterno_emp ASC;

-- 1. Creación de la tabla requerida
CREATE TABLE HIST_ARRIENDO_ANUAL_MOTO (
  placa VARCHAR2(8) NOT NULL,
  modelo VARCHAR2(30) NOT NULL,
  anno_proceso NUMBER(4) NOT NULL,
  cant_arriendos NUMBER(5) NOT NULL,
  total_dias NUMBER(5) NOT NULL
);

-- 2. Inserción de los datos calculados a partir del historial del año actual
INSERT INTO HIST_ARRIENDO_ANUAL_MOTO (placa, modelo, anno_proceso, cant_arriendos, total_dias)
SELECT 
  m.placa AS "PLACA",
  m.modelo AS "MODELO",
  EXTRACT(YEAR FROM SYSDATE) AS "ANNO_PROCESO",
  COUNT(a.id_arriendo) AS "CANT_ARRIENDOS",
  SUM(a.dias_solicitados) AS "TOTAL_DIAS"
FROM MOTOCICLETA m
JOIN ARRIENDO_MOTO a 
  ON m.placa = a.placa

-- Filtramos estrictamente por el año de inicio actual
WHERE EXTRACT(YEAR FROM a.fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE)
-- Agrupamos por los campos principales de la moto
GROUP BY m.placa, m.modelo
-- Se deben considerar motos arrendadas 2 o más veces
HAVING COUNT(a.id_arriendo) >= 2;

-- 3. (Opcional) Consultamos la tabla para confirmar que los datos se migraron correctamente
SELECT * FROM HIST_ARRIENDO_ANUAL_MOTO
ORDER BY cant_arriendos DESC, total_dias DESC;



SELECT 
 -- 1. Datos básicos de la motocicleta
 tm.nombre_tipo_moto AS tipo_moto,
 m.placa       AS placa,
 m.modelo       AS modelo,
 m.cilindrada     AS cilindrada,
 m.color       AS color,
 m.anio_fab      AS ano_fabricacion,
 -- 2. Dinero (Matemática simple, sin formatos raros)
 m.valor_arriendo_dia AS valor_arriendo,
 m.valor_garantia_dia AS valor_garantia,
 (m.valor_arriendo_dia + NVL(m.valor_garantia_dia, 0)) AS total_por_dia,

 -- 3. Creación del Correo (Uniendo 3 partes)
 LOWER(
  SUBSTR(emp.numrun_emp, 1, 2) -- Parte 1: Los dos primeros números del RUT
  || 
  CASE emp.id_estado_civil   -- Parte 2: Letras del apellido según estado civil
   WHEN 20 THEN SUBSTR(emp.apmaterno_emp, 1, 2)
   WHEN 10 THEN SUBSTR(emp.apmaterno_emp, 1, 1) || SUBSTR(emp.apmaterno_emp, -1, 1)
   WHEN 30 THEN SUBSTR(emp.apmaterno_emp, 1, 1) || SUBSTR(emp.apmaterno_emp, -1, 1)
   WHEN 40 THEN SUBSTR(emp.apmaterno_emp, 2, 2)
   ELSE SUBSTR(emp.apmaterno_emp, 3, 2)
  END 
  || 
  '@motorent.cl'        -- Parte 3: El dominio de la empresa
 ) AS correo_encargado
-- 4. Las tablas que estamos cruzando
FROM MOTOCICLETA m
JOIN TIPO_MOTO tm 
 ON m.id_tipo_moto = tm.id_tipo_moto
LEFT JOIN EMPLEADO emp 
 ON m.numrun_emp = emp.numrun_emp
-- 5. El orden de los resultados
ORDER BY
 tipo_moto ASC,
 valor_arriendo DESC,
 valor_garantia ASC,
 placa ASC;


---esta la 4 , disen :
SELECT
 TO_CHAR(e.numrun_emp, '99G999G999') || '-' || e.dvrun_emp AS "RUN del encargado",
 e.pnombre_emp || ' ' || e.appaterno_emp || ' ' || e.apmaterno_emp AS "Nombre completo",
 v.total_arriendos AS "Total arriendos gestionados",
 v.total_arriendos || '%' AS "Porc. Bonificación",
 TO_CHAR(e.sueldo_base * (v.total_arriendos / 100), '$999G999G999') AS "Monto de bonificación"
FROM EMPLEADO e
JOIN (
 -- Subconsulta: Cuenta los arriendos por empleado usando las motos
 SELECT
  m.numrun_emp,
  COUNT(am.id_arriendo) AS total_arriendos
 FROM ARRIENDO_MOTO am
 JOIN MOTOCICLETA m ON am.placa = m.placa
 WHERE EXTRACT(YEAR FROM am.fecha_ini_arriendo) = EXTRACT(YEAR FROM SYSDATE) - 1
 GROUP BY m.numrun_emp
 HAVING COUNT(am.id_arriendo) > 1
) v ON e.numrun_emp = v.numrun_emp
ORDER BY e.appaterno_emp DESC;

---req 2
SELECT
    numrun_emp || '-' || dvrun_emp AS "RUN",
    appaterno_emp || ' ' || apmaterno_emp || ' ' || pnombre_emp || ' ' || nvl(snombre_emp || ' ' , '') AS "Nombre Completo",
    TO_CHAR(fecha_contrato, 'DD/MM/YYYY') AS "Fecha Contrato",
    estado_civil.nombre_estado_civil AS "Estado Civil",
    sueldo_base AS "Sueldo Base",
    sueldo_base *(
        SELECT 
            porc_bonif_annos.porcentaje/100
        FROM 
            porc_bonif_annos
        WHERE 
            (porc_bonif_annos.sueldo_desde <= empleado.sueldo_base) and (empleado.sueldo_base <= porc_bonif_annos.sueldo_hasta))
    AS "Monto Bono 30 años",
    (SELECT
        porc_bonif_annos.porcentaje
    FROM 
        porc_bonif_annos
    WHERE 
        (porc_bonif_annos.sueldo_desde <= empleado.sueldo_base) and (empleado.sueldo_base <= porc_bonif_annos.sueldo_hasta))
    AS "% Sueldo Base"
FROM
    empleado
JOIN
    estado_civil on estado_civil.id_estado_civil = empleado.id_estado_civil
WHERE
    TO_CHAR(SYSDATE, 'YYYY') - TO_CHAR (empleado.fecha_contrato, 'YYYY')  <= 25
ORDER BY
   appaterno_emp ASC, fecha_contrato ASC; 

--- req 3
SELECT
    motocicleta.placa,
    motocicleta.modelo,
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
            arriendo_moto.placa = motocicleta.placa AND (TO_CHAR(SYSDATE, 'YYYY') = TO_CHAR(arriendo_moto.fecha_ini_arriendo, 'YYYY'))) >= 2; 