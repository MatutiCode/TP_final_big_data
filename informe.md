# Informe TP Final de Big Data

## Integrantes:

* Matias Barrios
* Resquin Vanina

## Tema
Streaming

## Problemas que tuvimos

1. Habia dispositivos escritos de manera diferente
2. Minutos vistos en negativo
3. Filas repetidas
4. Registros sin genero

## Preguntas de negocio

El género con más minutos vistos es acción (49320), seguido de comedia (44070). Después vienen terror (25453), ciencia ficción (24188), suspenso (21886), naturaleza (21618), tecnología (20502) y romance (19262).
Los 5 títulos más vistos son Stranger Cosas (268 reproducciones), Comedia Familiar y La Casa de Papel (267 cada uno), Noche de Terror (266) y El Gran Heist (256).
Hay 433 usuarios distintos en el plan básico, 413 en el estándar y 368 en el premium.
El dispositivo más usado es smart_tv con 634 reproducciones, aunque tablet está muy cerca con 631.
El promedio de minutos vistos es 91,77 en películas, 89,81 en documentales y 89,66 en series.

## Rechazados por regla

1. R9_dispositivo_invalido: 289
2. R2_fecha_formato: 243
3. R4_plan_invalido: 198
4. R1_id_duplicado: 150
5. R7_genero_nulo: 142
6. R6_tipo_contenido_invalido: 119
7. R8_minutos_no_positivos: 100
8. R3_id_usuario_invalido: 0
9. R5_titulo_vacio: 0
10. R10_pais_vacio: 0