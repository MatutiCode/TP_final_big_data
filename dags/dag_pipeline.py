from datetime import datetime
from pathlib import Path
import sys
import pendulum


from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator

PROJECT_DIR = Path(__file__).resolve().parent.parent
if str(PROJECT_DIR) not in sys.path:
    sys.path.insert(0, str(PROJECT_DIR))

from pipeline import (
    extraer_y_cargar,
    validar,
    limpiar_rechazados,
    unir_tabla_final,
    responder_preguntas,
)

with DAG(
    dag_id="etl_streamplus_reproducciones",
    description="Pipeline ETL diario de reproducciones de StreamPlus (Tema 06)",
    start_date=pendulum.datetime(2026, 1, 1, tz="America/Argentina/Buenos_Aires"),
    schedule="0 2 * * *",
    catchup=False,
    tags=["etl", "streamplus", "tema_06"],
) as dag:
    tarea_extraer = PythonOperator(
        task_id="extraer_y_cargar_raw",
        python_callable=extraer_y_cargar,
    )

    tarea_validar = PythonOperator(
        task_id="validar_reglas",
        python_callable=validar,
    )

    tarea_limpiar = PythonOperator(
        task_id="limpiar_rechazados",
        python_callable=limpiar_rechazados,
    )

    tarea_unir = PythonOperator(
        task_id="unir_tabla_final",
        python_callable=unir_tabla_final,
    )

    tarea_preguntas = PythonOperator(
        task_id="responder_preguntas_negocio",
        python_callable=responder_preguntas,
    )

    tarea_extraer >> tarea_validar >> tarea_limpiar >> tarea_unir >> tarea_preguntas
