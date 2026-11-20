CREATE OR REPLACE TABLE evaluacion_reglas AS
WITH base AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id_reproduccion ORDER BY rowid) AS rn
    FROM raw_reproducciones
),
reglas AS (
    SELECT
        *,
        CASE WHEN id_reproduccion IS NULL OR TRIM(id_reproduccion) = '' OR rn > 1
             THEN 'R1_id_duplicado' END AS r1,
        CASE WHEN fecha IS NULL OR NOT regexp_matches(fecha, '^\d{4}-\d{2}-\d{2}$') OR TRY_CAST(fecha AS DATE) IS NULL
             THEN 'R2_fecha_formato' END AS r2,
        CASE WHEN id_usuario IS NULL OR TRY_CAST(id_usuario AS INTEGER) IS NULL OR TRY_CAST(id_usuario AS INTEGER) <= 0
             THEN 'R3_id_usuario_invalido' END AS r3,
        CASE WHEN plan IS NULL OR plan NOT IN ('basico', 'estandar', 'premium')
             THEN 'R4_plan_invalido' END AS r4,
        CASE WHEN titulo IS NULL OR TRIM(titulo) = ''
             THEN 'R5_titulo_vacio' END AS r5,
        CASE WHEN tipo_contenido IS NULL OR tipo_contenido NOT IN ('pelicula', 'serie', 'documental')
             THEN 'R6_tipo_contenido_invalido' END AS r6,
        CASE WHEN genero IS NULL OR TRIM(genero) = ''
             THEN 'R7_genero_nulo' END AS r7,
        CASE WHEN minutos_vistos IS NULL OR TRY_CAST(minutos_vistos AS INTEGER) IS NULL OR TRY_CAST(minutos_vistos AS INTEGER) <= 0
             THEN 'R8_minutos_no_positivos' END AS r8,
        CASE WHEN dispositivo IS NULL OR dispositivo NOT IN ('smart_tv', 'celular', 'tablet', 'notebook')
             THEN 'R9_dispositivo_invalido' END AS r9,
        CASE WHEN pais IS NULL OR TRIM(pais) = ''
             THEN 'R10_pais_vacio' END AS r10
    FROM base
)
SELECT
    id_reproduccion,
    fecha,
    id_usuario,
    plan,
    titulo,
    tipo_contenido,
    genero,
    minutos_vistos,
    dispositivo,
    pais,
    concat_ws('; ', r1, r2, r3, r4, r5, r6, r7, r8, r9, r10) AS motivo_rechazo
FROM reglas;

CREATE OR REPLACE TABLE validos AS
SELECT
    id_reproduccion,
    CAST(fecha AS DATE) AS fecha,
    CAST(id_usuario AS INTEGER) AS id_usuario,
    plan,
    titulo,
    tipo_contenido,
    genero,
    CAST(minutos_vistos AS INTEGER) AS minutos_vistos,
    dispositivo,
    pais
FROM evaluacion_reglas
WHERE motivo_rechazo = '';

CREATE OR REPLACE TABLE rechazados AS
SELECT
    id_reproduccion,
    fecha,
    id_usuario,
    plan,
    titulo,
    tipo_contenido,
    genero,
    minutos_vistos,
    dispositivo,
    pais,
    motivo_rechazo
FROM evaluacion_reglas
WHERE motivo_rechazo <> '';
