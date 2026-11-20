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
    df = con.execute("SELECT * FROM rechazados").df()
    validos = con.execute("SELECT * FROM validos").df()

    df = df.drop_duplicates(subset=["id_reproduccion"])

    df["plan"] = df["plan"].str.strip().str.lower()
    df["tipo_contenido"] = df["tipo_contenido"].str.strip().str.lower()
    df["dispositivo"] = df["dispositivo"].str.strip().str.lower()

    df["dispositivo"] = df["dispositivo"].replace(
        {
            "tv": "smart_tv",
            "smarttv": "smart_tv",
            "smart tv": "smart_tv",
            "cel": "celular",
            "movil": "celular",
            "pc": "notebook",
            "laptop": "notebook",
        }
    )

    fecha_iso = pd.to_datetime(df["fecha"], format="%Y-%m-%d", errors="coerce")
    fecha_arg = pd.to_datetime(df["fecha"], format="%d/%m/%Y", errors="coerce")
    df["fecha"] = fecha_iso.fillna(fecha_arg)

    df["id_usuario"] = pd.to_numeric(df["id_usuario"], errors="coerce")
    df["minutos_vistos"] = pd.to_numeric(df["minutos_vistos"], errors="coerce").abs()

    generos = validos.groupby("titulo")["genero"].first()
    tipos = validos.groupby("titulo")["tipo_contenido"].first()
    df["genero"] = df["genero"].fillna(df["titulo"].map(generos))
    df["tipo_contenido"] = df["tipo_contenido"].fillna(df["titulo"].map(tipos))

    df = df[
        df["fecha"].notna()
        & (df["id_usuario"] > 0)
        & df["plan"].isin(["basico", "estandar", "premium"])
        & df["tipo_contenido"].isin(["pelicula", "serie", "documental"])
        & df["genero"].notna()
        & (df["minutos_vistos"] > 0)
        & df["dispositivo"].isin(["smart_tv", "celular", "tablet", "notebook"])
    ]

    df = df.drop(columns=["motivo_rechazo"])
    con.execute("CREATE OR REPLACE TABLE rechazados_limpios AS SELECT * FROM df")

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
    consultas = leer_sql("consultas.sql").split(";")
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
