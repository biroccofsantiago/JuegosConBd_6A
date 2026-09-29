# CRUD web de usuarios — Juegos 6A

Aplicación web en Python con Flask y MySQL para crear, listar, editar y eliminar registros de la tabla `usuarios`.

## Requisitos

- Python 3.10 o posterior
- En Ubuntu/Debian, el paquete `python3-venv` para crear el entorno virtual
- MySQL Server en ejecución
- La base `juegos_6A` y la tabla `usuarios` del archivo `base.sql`

## Preparar la base de datos

Si todavía no importaste el esquema, desde la carpeta del proyecto ejecutá:

```bash
mysql -u root -p < base.sql
```

El comando solicita la contraseña de MySQL. Si la base o las tablas ya existen, tené en cuenta que `base.sql` contiene instrucciones `DROP TABLE` y volver a importarlo las reemplazará.

## Instalar y configurar

Si `python3 -m venv` informa que falta `ensurepip`, instalá el paquete de entorno virtual del sistema (`sudo apt install python3-venv`) y repetí estos pasos:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Después, la manera más sencilla de configurar MySQL es ejecutar `bash configurar_mysql.sh`. El script solicita permisos de administrador, crea un usuario MySQL para la aplicación, genera credenciales locales y las guarda en `.env`. Si la tabla `usuarios` no existe, importa `base.sql`; si ya existe, la conserva sin borrarla.

## Iniciar el servidor

```bash
.venv/bin/python app.py
```

Abrí <http://127.0.0.1:5000> en el navegador. El servidor usa el modo de desarrollo de Flask; está configurado para escuchar solo en `127.0.0.1`, no para publicarse directamente en Internet.

## Operaciones disponibles

- Crear un usuario con usuario, nombre y apellido.
- Ver el directorio de usuarios.
- Editar un usuario existente.
- Eliminar un usuario con confirmación.

Las consultas SQL usan parámetros para evitar inyección SQL. Las operaciones de escritura realizan `commit` y revierten la transacción ante errores.
