from pathlib import Path
import duckdb

BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "datos" / "reproducciones.csv"
SQL_DIR = BASE_DIR / "consultas"
DB_PATH = BASE_DIR / "pipeline.duckdb"


def leer_sql(nombre_archivo: str) -> str:
    ruta = SQL_DIR / nombre_archivo
    return ruta.read_text(encoding="utf-8")


def extraer_y_cargar(db_path: Path = DB_PATH, data_path: Path = DATA_PATH) -> int:
    with duckdb.connect(str(db_path)) as con:
        con.execute(leer_sql("extract.sql"), [str(data_path)])
        total = con.execute("SELECT COUNT(*) FROM raw_reproducciones").fetchone()[0]
    print(f"[EXTRACT] raw_reproducciones cargada: {total} filas.")
    return total


def validar(db_path: Path = DB_PATH) -> tuple[int, int]:
    with duckdb.connect(str(db_path)) as con:
        con.execute(leer_sql("validar.sql"))
        cant_validos = con.execute("SELECT COUNT(*) FROM validos").fetchone()[0]
        cant_rechazados = con.execute("SELECT COUNT(*) FROM rechazados").fetchone()[0]
    print(f"[VALIDATE] validos: {cant_validos} | rechazados: {cant_rechazados}")
    return cant_validos, cant_rechazados


def limpiar_rechazados(db_path: Path = DB_PATH) -> int:
    with duckdb.connect(str(db_path)) as con:
        con.execute(leer_sql("limpiar.sql"))
        cant_limpios = con.execute(
            "SELECT COUNT(*) FROM rechazados_limpios"
        ).fetchone()[0]
    print(f"[CLEAN] rechazados_limpios recuperados: {cant_limpios}")
    return cant_limpios


def unir_tabla_final(db_path: Path = DB_PATH) -> int:
    with duckdb.connect(str(db_path)) as con:
        con.execute(leer_sql("unir.sql"))
        total_final = con.execute("SELECT COUNT(*) FROM tabla_final").fetchone()[0]
    print(f"[LOAD] tabla_final consolidada: {total_final} filas.")
    return total_final


def responder_preguntas(db_path: Path = DB_PATH) -> None:
    sql_texto = leer_sql("consultas.sql")
    consultas = [q.strip() for q in sql_texto.split(";") if q.strip()]
    with duckdb.connect(str(db_path)) as con:
        for idx, query in enumerate(consultas, start=1):
            print(f"\nPregunta de negocio {idx} ")
            print(con.execute(query).df().to_string(index=False))


def ejecutar_pipeline() -> None:
    extraer_y_cargar()
    validar()
    limpiar_rechazados()
    unir_tabla_final()
    responder_preguntas()


if __name__ == "__main__":
    ejecutar_pipeline()
