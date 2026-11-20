CREATE OR REPLACE TABLE rechazados_limpios AS
SELECT * FROM (
    SELECT
        r.id_reproduccion,

        COALESCE(
            TRY_CAST(r.fecha AS DATE),
            CAST(TRY_STRPTIME(r.fecha, '%d/%m/%Y') AS DATE)
        ) AS fecha,
        TRY_CAST(r.id_usuario AS INTEGER) AS id_usuario,

        LOWER(TRIM(r.plan)) AS plan,
        TRIM(r.titulo) AS titulo,

        COALESCE(LOWER(TRIM(r.tipo_contenido)), t.tipo_ref) AS tipo_contenido,
        COALESCE(LOWER(TRIM(r.genero)), t.genero_ref) AS genero,

        ABS(TRY_CAST(r.minutos_vistos AS INTEGER)) AS minutos_vistos,

        CASE
            WHEN LOWER(TRIM(r.dispositivo)) IN ('tv', 'smarttv', 'smart tv') THEN 'smart_tv'
            WHEN LOWER(TRIM(r.dispositivo)) IN ('cel', 'movil') THEN 'celular'
            WHEN LOWER(TRIM(r.dispositivo)) IN ('pc', 'laptop') THEN 'notebook'
            ELSE LOWER(TRIM(r.dispositivo))
        END AS dispositivo,
        TRIM(r.pais) AS pais
    FROM (SELECT DISTINCT * FROM rechazados) AS r
    LEFT JOIN (
        SELECT titulo,
               MAX(tipo_contenido) AS tipo_ref,
               MAX(genero) AS genero_ref
        FROM validos
        GROUP BY titulo
    ) AS t
    ON r.titulo = t.titulo
)
WHERE fecha IS NOT NULL
  AND id_usuario > 0
  AND plan IN ('basico', 'estandar', 'premium')
  AND tipo_contenido IN ('pelicula', 'serie', 'documental')
  AND genero IS NOT NULL
  AND minutos_vistos > 0
  AND dispositivo IN ('smart_tv', 'celular', 'tablet', 'notebook')
  AND pais IS NOT NULL;