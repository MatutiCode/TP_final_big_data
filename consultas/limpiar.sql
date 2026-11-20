def limpiar_rechazados():
    con = duckdb.connect(str(DB_PATH))
    df = con.execute("SELECT * FROM rechazados").df()
    validos = con.execute("SELECT * FROM validos").df()

    df = df.drop_duplicates(subset=["id_reproduccion"])

    df["plan"] = df["plan"].str.strip().str.lower()
    df["tipo_contenido"] = df["tipo_contenido"].str.strip().str.lower()
    df["dispositivo"] = df["dispositivo"].str.strip().str.lower()

    df["dispositivo"] = df["dispositivo"].replace({
        "tv": "smart_tv",
        "smarttv": "smart_tv",
        "smart tv": "smart_tv",
        "cel": "celular",
        "movil": "celular",
        "pc": "notebook",
        "laptop": "notebook"
    })

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

    print("Rechazados recuperados:", len(df))
    con.close()