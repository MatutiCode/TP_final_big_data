-- Etapa 6: Preguntas de negocio sobre tabla_final

-- 1. ¿Cuantos minutos se vieron por genero?
SELECT
    genero,
    SUM(minutos_vistos) AS total_minutos_vistos
FROM tabla_final
GROUP BY genero
ORDER BY total_minutos_vistos DESC;

-- 2. ¿Cuales son los 5 titulos mas vistos (por cantidad de reproducciones)?
SELECT
    titulo,
    COUNT(*) AS cantidad_reproducciones
FROM tabla_final
GROUP BY titulo
ORDER BY cantidad_reproducciones DESC
LIMIT 5;

-- 3. ¿Cuantos usuarios distintos hay por plan?
SELECT
    plan,
    COUNT(DISTINCT id_usuario) AS usuarios_distintos
FROM tabla_final
GROUP BY plan
ORDER BY usuarios_distintos DESC;

-- 4. ¿Cual es el dispositivo mas usado?
SELECT
    dispositivo,
    COUNT(*) AS total_reproducciones
FROM tabla_final
GROUP BY dispositivo
ORDER BY total_reproducciones DESC
LIMIT 1;

-- 5. ¿Cual es el promedio de minutos vistos por tipo de contenido?
SELECT
    tipo_contenido,
    ROUND(AVG(minutos_vistos), 2) AS promedio_minutos_vistos
FROM tabla_final
GROUP BY tipo_contenido
ORDER BY promedio_minutos_vistos DESC;
