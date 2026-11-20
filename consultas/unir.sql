CREATE OR REPLACE TABLE tabla_final AS
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
FROM validos

UNION

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
FROM rechazados_limpios;