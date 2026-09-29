import os

import mysql.connector
from dotenv import load_dotenv
from flask import Flask, abort, flash, redirect, render_template, request, url_for
from flask_wtf.csrf import CSRFProtect

load_dotenv()

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "cambia-esta-clave-para-desarrollo")
CSRFProtect(app)

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "juegos_6A"),
    "charset": "utf8mb4",
    "connection_timeout": 5,
}


def conectar_db():
    return mysql.connector.connect(**DB_CONFIG)


def consultar(sql, parametros=(), uno=False):
    conexion = conectar_db()
    cursor = conexion.cursor(dictionary=True)
    try:
        cursor.execute(sql, parametros)
        return cursor.fetchone() if uno else cursor.fetchall()
    finally:
        cursor.close()
        conexion.close()


def ejecutar(sql, parametros=()):
    conexion = conectar_db()
    cursor = conexion.cursor()
    try:
        cursor.execute(sql, parametros)
        conexion.commit()
        return cursor.lastrowid, cursor.rowcount
    except Exception:
        conexion.rollback()
        raise
    finally:
        cursor.close()
        conexion.close()


def datos_del_formulario():
    datos = {
        "usu_usuario": request.form.get("usu_usuario", "").strip(),
        "usu_nombre": request.form.get("usu_nombre", "").strip(),
        "usu_apellido": request.form.get("usu_apellido", "").strip(),
    }
    etiquetas = {
        "usu_usuario": "Usuario",
        "usu_nombre": "Nombre",
        "usu_apellido": "Apellido",
    }
    for campo, valor in datos.items():
        if not valor:
            raise ValueError(f"El campo {etiquetas[campo]} es obligatorio.")
        if len(valor) > 50:
            raise ValueError(f"El campo {etiquetas[campo]} no puede superar 50 caracteres.")
    return datos


@app.get("/")
def inicio():
    try:
        usuarios = consultar(
            """SELECT usu_id, usu_usuario, usu_nombre, usu_apellido
               FROM usuarios ORDER BY usu_id"""
        )
        error_db = None
    except mysql.connector.Error:
        app.logger.exception("No se pudo consultar la tabla usuarios")
        usuarios = []
        error_db = "No se pudo conectar a la base de datos. Revisá la configuración y que MySQL esté iniciado."
    return render_template("index.html", usuarios=usuarios, error_db=error_db)


@app.post("/usuarios/crear")
def crear_usuario():
    try:
        datos = datos_del_formulario()
        ejecutar(
            """INSERT INTO usuarios (usu_usuario, usu_nombre, usu_apellido)
               VALUES (%s, %s, %s)""",
            (datos["usu_usuario"], datos["usu_nombre"], datos["usu_apellido"]),
        )
        flash("Usuario creado correctamente.", "success")
    except ValueError as error:
        flash(str(error), "error")
    except mysql.connector.Error:
        app.logger.exception("No se pudo crear el usuario")
        flash("No se pudo guardar el usuario. Verificá la conexión con MySQL.", "error")
    return redirect(url_for("inicio"))


@app.route("/usuarios/<int:usuario_id>/editar", methods=["GET", "POST"])
def editar_usuario(usuario_id):
    if request.method == "POST":
        try:
            datos = datos_del_formulario()
            _, filas = ejecutar(
                """UPDATE usuarios
                   SET usu_usuario = %s, usu_nombre = %s, usu_apellido = %s
                   WHERE usu_id = %s""",
                (datos["usu_usuario"], datos["usu_nombre"], datos["usu_apellido"], usuario_id),
            )
            if filas == 0:
                flash("No se encontró el usuario o no hubo cambios.", "error")
            else:
                flash("Usuario actualizado correctamente.", "success")
            return redirect(url_for("inicio"))
        except ValueError as error:
            flash(str(error), "error")
        except mysql.connector.Error:
            app.logger.exception("No se pudo actualizar el usuario")
            flash("No se pudo actualizar el usuario. Verificá la conexión con MySQL.", "error")
            return redirect(url_for("inicio"))

    try:
        usuario = consultar(
            """SELECT usu_id, usu_usuario, usu_nombre, usu_apellido
               FROM usuarios WHERE usu_id = %s""",
            (usuario_id,),
            uno=True,
        )
    except mysql.connector.Error:
        app.logger.exception("No se pudo cargar el usuario")
        flash("No se pudo conectar a la base de datos.", "error")
        return redirect(url_for("inicio"))

    if usuario is None:
        abort(404)
    return render_template("editar.html", usuario=usuario)


@app.post("/usuarios/<int:usuario_id>/eliminar")
def eliminar_usuario(usuario_id):
    try:
        _, filas = ejecutar("DELETE FROM usuarios WHERE usu_id = %s", (usuario_id,))
        if filas:
            flash("Usuario eliminado correctamente.", "success")
        else:
            flash("El usuario ya no existe.", "error")
    except mysql.connector.Error:
        app.logger.exception("No se pudo eliminar el usuario")
        flash("No se pudo eliminar el usuario. Verificá la conexión con MySQL.", "error")
    return redirect(url_for("inicio"))


@app.errorhandler(404)
def no_encontrado(_error):
    return render_template("404.html"), 404


if __name__ == "__main__":
    app.run(host=os.getenv("APP_HOST", "127.0.0.1"), port=int(os.getenv("APP_PORT", "5000")), debug=True)
