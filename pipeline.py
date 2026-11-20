import duckdb
import pandas as pd
from pathlib import Path

# Rutas
BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "datos" / "reproducciones.csv"
SQL_DIR = BASE_DIR / "consultas"
DB_PATH = BASE_DIR / "pipeline.duckdb"


def leer_sql(nombre_archivo: str):
    ruta = SQL_DIR / nombre_archivo
    return ruta.read_text(encoding="utf-8")


def contar(tabla: str, con):
    return con.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]


def extraer_y_cargar():
    print("Extraccion")
    con = duckdb.connect(str(DB_PATH))
    con.execute(leer_sql("extract.sql"), [str(DATA_PATH)])
    print("Registros extraidos:", contar("raw_reproducciones", con))
    con.close()


def validar():
    print("Validaciones")
    con = duckdb.connect(str(DB_PATH))
    con.execute(leer_sql("validar.sql"))
    print("Validos:", contar("validos", con))
    print("Rechazados:", contar("rechazados", con))
    con.close()


def limpiar_rechazados():
    print("Limpieza")
    con = duckdb.connect(str(DB_PATH))
    con.execute(leer_sql("limpiar.sql"))
    print("Rechazados recuperados:", contar("rechazados_limpios", con))
    con.close()


def unir_tabla_final():
    print("Union")
    con = duckdb.connect(str(DB_PATH))
    con.execute(leer_sql("unir.sql"))
    print("Registros en tabla_final:", contar("tabla_final", con))
    con.close()


def responder_preguntas():
    print("Preguntas de negocio")
    con = duckdb.connect(str(DB_PATH))
    consultas = leer_sql("preguntas.sql").split(";")
    numero = 1
    for consulta in consultas:
        if consulta.strip() != "":
            print("\nPregunta", numero)
            print(con.execute(consulta).df())
            numero += 1
    con.close()


def main():
    extraer_y_cargar()
    validar()
    limpiar_rechazados()
    unir_tabla_final()
    responder_preguntas()


if __name__ == "__main__":
    main()
