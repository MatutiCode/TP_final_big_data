CREATE OR REPLACE TABLE rechazados AS
SELECT * FROM (
    SELECT
        *,
        CASE
            WHEN id_reproduccion IN (
                SELECT id_reproduccion
                FROM raw_reproducciones
                GROUP BY id_reproduccion
                HAVING COUNT(*) > 1
            ) THEN 'R1_id_duplicado'
            WHEN TRY_CAST(fecha AS DATE) IS NULL THEN 'R2_fecha_formato'
            WHEN TRY_CAST(id_usuario AS INTEGER) IS NULL
                 OR TRY_CAST(id_usuario AS INTEGER) <= 0 THEN 'R3_id_usuario_invalido'
            WHEN plan IS NULL
                 OR plan NOT IN ('basico', 'estandar', 'premium') THEN 'R4_plan_invalido'
            WHEN titulo IS NULL OR TRIM(titulo) = '' THEN 'R5_titulo_vacio'
            WHEN tipo_contenido IS NULL
                 OR tipo_contenido NOT IN ('pelicula', 'serie', 'documental') THEN 'R6_tipo_contenido_invalido'
            WHEN genero IS NULL OR TRIM(genero) = '' THEN 'R7_genero_nulo'
            WHEN TRY_CAST(minutos_vistos AS INTEGER) IS NULL
                 OR TRY_CAST(minutos_vistos AS INTEGER) <= 0 THEN 'R8_minutos_no_positivos'
            WHEN dispositivo IS NULL
                 OR dispositivo NOT IN ('smart_tv', 'celular', 'tablet', 'notebook') THEN 'R9_dispositivo_invalido'
            WHEN pais IS NULL OR TRIM(pais) = '' THEN 'R10_pais_vacio'
        END AS motivo_rechazo
    FROM raw_reproducciones
)
WHERE motivo_rechazo IS NOT NULL;

CREATE OR REPLACE TABLE validos AS
SELECT *
FROM raw_reproducciones
WHERE id_reproduccion NOT IN (SELECT id_reproduccion FROM rechazados);