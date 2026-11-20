CREATE OR REPLACE TABLE rechazados_limpios AS
WITH catalogo_titulos AS (
    SELECT
        titulo,
        MAX(CASE WHEN tipo_contenido IN ('pelicula', 'serie', 'documental') THEN tipo_contenido END) AS tipo_ref,
        MAX(CASE WHEN genero IS NOT NULL AND TRIM(genero) <> '' THEN genero END) AS genero_ref
    FROM raw_reproducciones
    GROUP BY titulo
),
sin_duplicados AS (
    SELECT
        r.*,
        ROW_NUMBER() OVER (PARTITION BY r.id_reproduccion ORDER BY r.rowid) AS rn_dup
    FROM rechazados r
    WHERE r.id_reproduccion NOT IN (SELECT id_reproduccion FROM validos)
),
normalizados AS (
    SELECT
        TRIM(s.id_reproduccion) AS id_reproduccion,
        COALESCE(
            TRY_CAST(s.fecha AS DATE),
            TRY_CAST(TRY_STRPTIME(s.fecha, '%d/%m/%Y') AS DATE)
        ) AS fecha,
        TRY_CAST(s.id_usuario AS INTEGER) AS id_usuario,
        LOWER(TRIM(s.plan)) AS plan,
        TRIM(s.titulo) AS titulo,
        COALESCE(
            CASE WHEN LOWER(TRIM(s.tipo_contenido)) IN ('pelicula', 'serie', 'documental')
                 THEN LOWER(TRIM(s.tipo_contenido)) END,
            c.tipo_ref
        ) AS tipo_contenido,
        COALESCE(
            CASE WHEN s.genero IS NOT NULL AND TRIM(s.genero) <> ''
                 THEN LOWER(TRIM(s.genero)) END,
            c.genero_ref
        ) AS genero,
        ABS(TRY_CAST(s.minutos_vistos AS INTEGER)) AS minutos_vistos,
        CASE LOWER(TRIM(s.dispositivo))
            WHEN 'smart_tv' THEN 'smart_tv'
            WHEN 'smarttv'  THEN 'smart_tv'
            WHEN 'smart tv' THEN 'smart_tv'
            WHEN 'tv'       THEN 'smart_tv'
            WHEN 'celular'  THEN 'celular'
            WHEN 'cel'      THEN 'celular'
            WHEN 'movil'    THEN 'celular'
            WHEN 'tablet'   THEN 'tablet'
            WHEN 'notebook' THEN 'notebook'
            WHEN 'pc'       THEN 'notebook'
            WHEN 'laptop'   THEN 'notebook'
            ELSE NULL
        END AS dispositivo,
        TRIM(s.pais) AS pais
    FROM sin_duplicados s
    LEFT JOIN catalogo_titulos c ON TRIM(s.titulo) = c.titulo
    WHERE s.rn_dup = 1
)
SELECT *
FROM normalizados
WHERE id_reproduccion IS NOT NULL
  AND fecha IS NOT NULL
  AND id_usuario > 0
  AND plan IN ('basico', 'estandar', 'premium')
  AND titulo <> ''
  AND tipo_contenido IN ('pelicula', 'serie', 'documental')
  AND genero IS NOT NULL AND genero <> ''
  AND minutos_vistos > 0
  AND dispositivo IN ('smart_tv', 'celular', 'tablet', 'notebook')
  AND pais <> '';
