CREATE OR REPLACE TABLE tabla_final AS
WITH combinados AS (
    SELECT
        id_reproduccion,
        CAST(fecha AS DATE) AS fecha,
        CAST(id_usuario AS INTEGER) AS id_usuario,
        CAST(plan AS VARCHAR) AS plan,
        CAST(titulo AS VARCHAR) AS titulo,
        CAST(tipo_contenido AS VARCHAR) AS tipo_contenido,
        CAST(genero AS VARCHAR) AS genero,
        CAST(minutos_vistos AS INTEGER) AS minutos_vistos,
        CAST(dispositivo AS VARCHAR) AS dispositivo,
        CAST(pais AS VARCHAR) AS pais,
        1 AS prioridad
    FROM validos
    UNION ALL
    SELECT
        id_reproduccion,
        CAST(fecha AS DATE) AS fecha,
        CAST(id_usuario AS INTEGER) AS id_usuario,
        CAST(plan AS VARCHAR) AS plan,
        CAST(titulo AS VARCHAR) AS titulo,
        CAST(tipo_contenido AS VARCHAR) AS tipo_contenido,
        CAST(genero AS VARCHAR) AS genero,
        CAST(minutos_vistos AS INTEGER) AS minutos_vistos,
        CAST(dispositivo AS VARCHAR) AS dispositivo,
        CAST(pais AS VARCHAR) AS pais,
        2 AS prioridad
    FROM rechazados_limpios
),
deduplicados AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY id_reproduccion ORDER BY prioridad) AS rn
    FROM combinados
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
    pais
FROM deduplicados
WHERE rn = 1;
