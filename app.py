import os
import traceback
import json
import csv
import sqlite3
from datetime import datetime
from flask import Flask, redirect, url_for, session, render_template, request, flash
from flask_dance.contrib.google import make_google_blueprint, google
from flask_mail import Mail, Message
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

# Cargar configuración desde archivo JSON o usar configuración predeterminada
def load_config():
    """Carga la configuración desde archivo o usa valores predeterminados"""
    try:
        # Intentar cargar desde archivo
        with open("config.json", "r", encoding="utf-8") as config_file:
            return json.load(config_file)
    except FileNotFoundError:
        # Si no existe el archivo, usar configuración predeterminada
        return {
            "SECRET_KEY": "04292003@Zi",
            "MAIL_SERVER": "smtp.gmail.com",
            "MAIL_PORT": 587,
            "MAIL_USE_TLS": True,
            "MAIL_USERNAME": "pablo.elias.miranda.292003@gmail.com",
            "MAIL_PASSWORD": "jiyn qwpy soku ghfd",
            "OAUTH_CLIENT_ID": "331433147905-nt49eb3bna6mqk093qnl3essotaaa0q8.apps.googleusercontent.com",
            "OAUTH_CLIENT_SECRET": "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",
            "AUTHORIZED_EMAILS": [
                "laboratorio.computacion.sca@redcohen.cl",
                "pablo.elias.miranda.292003@gmail.com",
                "leya.armijo.cra@redcohen.cl"
            ],
            "DEFAULT_EMAILS": [
                "pablo.elias.miranda.292003@gmail.com",
                "laboratorio.computacion.sca@redcohen.cl",
                "leya.armijo.cra@redcohen.cl"
            ]
        }

config = load_config()

# Permitir HTTP sin SSL (solo para desarrollo local)
os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'

app = Flask(__name__)
app.secret_key = config.get("SECRET_KEY", "super_secreto")

# Configuración Flask-Mail desde config.json
app.config.update(
    MAIL_SERVER=config.get("MAIL_SERVER", "smtp.gmail.com"),
    MAIL_PORT=config.get("MAIL_PORT", 587),
    MAIL_USE_TLS=config.get("MAIL_USE_TLS", True),
    MAIL_USERNAME=config.get("MAIL_USERNAME", ""),
    MAIL_PASSWORD=config.get("MAIL_PASSWORD", ""),
)

mail = Mail(app)

# OAuth config desde config.json
blueprint = make_google_blueprint(
    client_id=config.get("OAUTH_CLIENT_ID", ""),
    client_secret=config.get("OAUTH_CLIENT_SECRET", ""),
    scope=[
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email",
        "openid"
    ]
)
app.register_blueprint(blueprint, url_prefix="/login")

# Lista de correos predeterminados para el formulario
CORREOS_PREDETERMINADOS = config.get("DEFAULT_EMAILS", [
    "admin@institucion.com",
    "coordinador@institucion.com",
    "laboratorio@institucion.com"
])

# Configuración de base de datos
DATABASE = 'app.db'

def init_db():
    """Inicializa la base de datos SQLite"""
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    # Crear tabla si no existe
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS bitacora (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            curso TEXT NOT NULL,
            asignatura TEXT NOT NULL,
            objetivo TEXT NOT NULL,
            recursos TEXT NOT NULL,
            observaciones TEXT NOT NULL,
            correo TEXT NOT NULL,
            destinatario TEXT NOT NULL,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Crear tabla de usuarios si no existe
    print("Creando tabla usuarios...")
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            correo TEXT UNIQUE NOT NULL,
            nombre TEXT NOT NULL,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    print("✅ Tabla usuarios creada/verificada")
    
    # Verificar si las columnas necesarias existen, si no, agregarlas
    cursor.execute("PRAGMA table_info(bitacora)")
    columns = [column[1] for column in cursor.fetchall()]
    
    if 'fecha_creacion' not in columns:
        print("Agregando columna fecha_creacion a la base de datos existente...")
        cursor.execute('ALTER TABLE bitacora ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP')
    
    if 'correo' not in columns:
        print("Agregando columna correo a la base de datos existente...")
        cursor.execute('ALTER TABLE bitacora ADD COLUMN correo TEXT NOT NULL DEFAULT "usuario@institucion.com"')
    
    if 'destinatario' not in columns:
        print("Agregando columna destinatario a la base de datos existente...")
        cursor.execute('ALTER TABLE bitacora ADD COLUMN destinatario TEXT NOT NULL DEFAULT "admin@institucion.com"')
    
    if 'usuario_id' not in columns:
        print("Agregando columna usuario_id a la base de datos existente...")
        cursor.execute('ALTER TABLE bitacora ADD COLUMN usuario_id TEXT NOT NULL DEFAULT "usuario_ejemplo"')
    
    conn.commit()
    conn.close()

def save_to_db(datos):
    """Guarda los datos en la base de datos SQLite"""
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    # Obtener o crear usuario_id basado en el correo
    correo = datos.get('correo')
    print(f"Buscando usuario con correo: {correo}")
    cursor.execute('SELECT id FROM usuarios WHERE correo = ?', (correo,))
    usuario = cursor.fetchone()
    
    if usuario:
        usuario_id = usuario[0]
    else:
        # Crear nuevo usuario si no existe
        cursor.execute('INSERT INTO usuarios (correo, nombre) VALUES (?, ?)', (correo, correo))
        usuario_id = cursor.lastrowid
    
    cursor.execute('''
        INSERT INTO bitacora (fecha, curso, asignatura, objetivo, recursos, observaciones, correo, destinatario, usuario_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        datos.get('fecha'),
        datos.get('curso'),
        datos.get('asignatura'),
        datos.get('objetivo'),
        datos.get('recursos'),
        datos.get('observaciones'),
        datos.get('correo'),
        datos.get('destinatario'),
        usuario_id
    ))
    
    conn.commit()
    conn.close()

def get_all_records():
    """Obtiene todos los registros de la bitácora"""
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT b.id, b.fecha, b.curso, b.asignatura, b.objetivo, b.recursos, 
               b.observaciones, b.correo, b.destinatario, b.fecha_creacion,
               COALESCE(u.nombre, b.correo) as nombre_usuario
        FROM bitacora b
        LEFT JOIN usuarios u ON b.usuario_id = u.id
        ORDER BY b.fecha_creacion DESC
    ''')
    
    records = cursor.fetchall()
    conn.close()
    return records

def get_records_by_date_range(fecha_inicio, fecha_fin):
    """Obtiene registros por rango de fechas"""
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT b.id, b.fecha, b.curso, b.asignatura, b.objetivo, b.recursos, 
               b.observaciones, b.correo, b.destinatario, b.fecha_creacion,
               COALESCE(u.nombre, b.correo) as nombre_usuario
        FROM bitacora b
        LEFT JOIN usuarios u ON b.usuario_id = u.id
        WHERE b.fecha BETWEEN ? AND ? 
        ORDER BY b.fecha_creacion DESC
    ''', (fecha_inicio, fecha_fin))
    
    records = cursor.fetchall()
    conn.close()
    return records

def get_default_emails():
    """Obtiene la lista de correos predeterminados"""
    return CORREOS_PREDETERMINADOS

def update_default_emails(new_emails):
    """Actualiza la lista de correos predeterminados en config.json"""
    try:
        global config
        config['DEFAULT_EMAILS'] = new_emails
        with open("config.json", "w", encoding="utf-8") as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        log_error_detallado(e)
        # Si no se puede escribir el archivo, actualizar solo en memoria
        config['DEFAULT_EMAILS'] = new_emails
        return True

def crear_datos_ejemplo():
    """Crea datos de ejemplo para demostrar la aplicación"""
    datos_ejemplo = [
        # Matemáticas - GeoGebra
        {
            "fecha": "2024-08-01",
            "curso": "8°A",
            "asignatura": "Matemáticas",
            "objetivo": "Aplicar conceptos de geometría analítica usando GeoGebra",
            "recursos": "Uso de GeoGebra para graficar funciones lineales y cuadráticas",
            "observaciones": "Todos los computadores funcionando correctamente",
            "correo": "profesor.matematicas@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        {
            "fecha": "2024-08-05",
            "curso": "7°B",
            "asignatura": "Matemáticas",
            "objetivo": "Resolver problemas de porcentajes y proporciones",
            "recursos": "Calculadora online y ejercicios interactivos en GeoGebra",
            "observaciones": "PC03 con problema de conexión a internet",
            "correo": "profesor.matematicas@institucion.com",
            "destinatario": "coordinador@institucion.com"
        },
        {
            "fecha": "2024-08-08",
            "curso": "6°A",
            "asignatura": "Matemáticas",
            "objetivo": "Aprender fracciones equivalentes",
            "recursos": "Juegos educativos online y GeoGebra para visualizar fracciones",
            "observaciones": "Excelente participación de los estudiantes",
            "correo": "profesor.matematicas@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        
        # Ciencias
        {
            "fecha": "2024-08-02",
            "curso": "5°A",
            "asignatura": "Ciencias Naturales",
            "objetivo": "Estudiar el sistema solar y planetas",
            "recursos": "Simulador del sistema solar, videos educativos de la NASA",
            "observaciones": "PC07 no enciende, necesita revisión técnica",
            "correo": "profesor.ciencias@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-06",
            "curso": "4°B",
            "asignatura": "Ciencias Naturales",
            "objetivo": "Aprender sobre el ciclo del agua",
            "recursos": "Animaciones interactivas y experimentos virtuales",
            "observaciones": "Todas las computadoras funcionando perfectamente",
            "correo": "profesor.ciencias@institucion.com",
            "destinatario": "coordinador@institucion.com"
        },
        {
            "fecha": "2024-08-12",
            "curso": "3°A",
            "asignatura": "Ciencias Naturales",
            "objetivo": "Identificar diferentes tipos de plantas",
            "recursos": "Base de datos de plantas, enciclopedia virtual",
            "observaciones": "PC02 con pantalla parpadeante",
            "correo": "profesor.ciencias@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        
        # Artes - Canva
        {
            "fecha": "2024-08-03",
            "curso": "2°A",
            "asignatura": "Artes Visuales",
            "objetivo": "Crear afiches publicitarios usando Canva",
            "recursos": "Canva para diseño gráfico, plantillas educativas",
            "observaciones": "Estudiantes muy creativos, excelentes resultados",
            "correo": "profesor.artes@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        {
            "fecha": "2024-08-07",
            "curso": "1°B",
            "asignatura": "Artes Visuales",
            "objetivo": "Diseñar tarjetas de cumpleaños digitales",
            "recursos": "Canva, herramientas de diseño gráfico básico",
            "observaciones": "PC05 con problema de audio",
            "correo": "profesor.artes@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-14",
            "curso": "Kínder A",
            "asignatura": "Artes Visuales",
            "objetivo": "Crear dibujos digitales simples",
            "recursos": "Paint online, herramientas de dibujo básico",
            "observaciones": "Necesitamos más mouse para los niños",
            "correo": "profesor.artes@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        
        # Lenguaje
        {
            "fecha": "2024-08-09",
            "curso": "6°B",
            "asignatura": "Lenguaje y Comunicación",
            "objetivo": "Escribir cuentos digitales",
            "recursos": "Procesador de texto, diccionario online",
            "observaciones": "PC01 con teclado que no responde bien",
            "correo": "profesor.lenguaje@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-13",
            "curso": "5°B",
            "asignatura": "Lenguaje y Comunicación",
            "objetivo": "Crear presentaciones sobre libros leídos",
            "recursos": "PowerPoint online, imágenes de internet",
            "observaciones": "Excelente trabajo en equipo de los estudiantes",
            "correo": "profesor.lenguaje@institucion.com",
            "destinatario": "coordinador@institucion.com"
        },
        
        # Historia
        {
            "fecha": "2024-08-15",
            "curso": "7°A",
            "asignatura": "Historia y Geografía",
            "objetivo": "Investigar sobre la independencia de Chile",
            "recursos": "Enciclopedia virtual, videos históricos",
            "observaciones": "PC04 con problema de conexión a internet",
            "correo": "profesor.historia@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-19",
            "curso": "8°B",
            "asignatura": "Historia y Geografía",
            "objetivo": "Crear línea de tiempo interactiva",
            "recursos": "Herramientas de línea de tiempo online",
            "observaciones": "Todas las computadoras funcionando correctamente",
            "correo": "profesor.historia@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        
        # Educación Física
        {
            "fecha": "2024-08-16",
            "curso": "4°A",
            "asignatura": "Educación Física",
            "objetivo": "Aprender sobre alimentación saludable",
            "recursos": "Videos educativos, calculadora de calorías",
            "observaciones": "PC06 con pantalla muy pequeña para los videos",
            "correo": "profesor.edfisica@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        
        # Tecnología
        {
            "fecha": "2024-08-20",
            "curso": "3°B",
            "asignatura": "Tecnología",
            "objetivo": "Aprender programación básica con Scratch",
            "recursos": "Scratch online, tutoriales interactivos",
            "observaciones": "Estudiantes muy motivados con la programación",
            "correo": "profesor.tecnologia@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        {
            "fecha": "2024-08-22",
            "curso": "2°B",
            "asignatura": "Tecnología",
            "objetivo": "Aprender a usar el mouse y teclado",
            "recursos": "Juegos educativos de mecanografía",
            "observaciones": "PC08 con mouse que no funciona",
            "correo": "profesor.tecnologia@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        
        # Inglés
        {
            "fecha": "2024-08-21",
            "curso": "1°A",
            "asignatura": "Inglés",
            "objetivo": "Aprender vocabulario básico en inglés",
            "recursos": "Aplicaciones de vocabulario, videos en inglés",
            "observaciones": "PC09 con problema de audio",
            "correo": "profesor.ingles@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-26",
            "curso": "Kínder B",
            "asignatura": "Inglés",
            "objetivo": "Aprender colores en inglés",
            "recursos": "Juegos de colores online, canciones en inglés",
            "observaciones": "Excelente participación de los niños",
            "correo": "profesor.ingles@institucion.com",
            "destinatario": "coordinador@institucion.com"
        },
        
        # Más ejemplos de agosto
        {
            "fecha": "2024-08-23",
            "curso": "6°A",
            "asignatura": "Matemáticas",
            "objetivo": "Resolver problemas de geometría",
            "recursos": "GeoGebra, calculadora científica online",
            "observaciones": "PC10 con pantalla rota, necesita reparación",
            "correo": "profesor.matematicas@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-27",
            "curso": "5°A",
            "asignatura": "Ciencias Naturales",
            "objetivo": "Estudiar los ecosistemas",
            "recursos": "Simulador de ecosistemas, documentales online",
            "observaciones": "Todas las computadoras funcionando perfectamente",
            "correo": "profesor.ciencias@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        },
        {
            "fecha": "2024-08-28",
            "curso": "4°B",
            "asignatura": "Artes Visuales",
            "objetivo": "Crear collage digital",
            "recursos": "Canva, banco de imágenes gratuito",
            "observaciones": "Estudiantes muy creativos",
            "correo": "profesor.artes@institucion.com",
            "destinatario": "coordinador@institucion.com"
        },
        {
            "fecha": "2024-08-29",
            "curso": "7°B",
            "asignatura": "Lenguaje y Comunicación",
            "objetivo": "Crear blog personal",
            "recursos": "Plataforma de blogs educativos",
            "observaciones": "PC11 con problema de conexión lenta",
            "correo": "profesor.lenguaje@institucion.com",
            "destinatario": "coordinador@institucion.com, tecnico@institucion.com"
        },
        {
            "fecha": "2024-08-30",
            "curso": "8°A",
            "asignatura": "Historia y Geografía",
            "objetivo": "Crear mapa interactivo de Chile",
            "recursos": "Google Maps, herramientas de cartografía",
            "observaciones": "Última sesión del mes, todo funcionando bien",
            "correo": "profesor.historia@institucion.com",
            "destinatario": "coordinador@institucion.com, jefe.utp@institucion.com"
        }
    ]
    
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    for dato in datos_ejemplo:
        cursor.execute('''
            INSERT INTO bitacora (usuario_id, fecha, curso, asignatura, objetivo, recursos, observaciones, correo, destinatario, fecha_creacion)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ''', (
            'usuario_ejemplo',
            dato['fecha'],
            dato['curso'],
            dato['asignatura'],
            dato['objetivo'],
            dato['recursos'],
            dato['observaciones'],
            dato['correo'],
            dato['destinatario']
        ))
    
    conn.commit()
    conn.close()
    print(f"Se crearon {len(datos_ejemplo)} registros de ejemplo para agosto 2024")


def log_error_detallado(e):
    """Registra errores detallados en el log"""
    app.logger.error("Exception: %s", e)
    tb_str = traceback.format_exc()
    app.logger.error(tb_str)

def validar_datos_formulario(datos):
    """Valida los datos del formulario"""
    errores = []
    
    # Validar campos requeridos
    campos_requeridos = ['fecha', 'curso', 'asignatura', 'objetivo', 'recursos', 'observaciones', 'destinatario']
    for campo in campos_requeridos:
        if not datos.get(campo) or not datos.get(campo).strip():
            errores.append(f"El campo '{campo}' es requerido")
    
    # Validar formato de fecha
    if datos.get('fecha'):
        try:
            datetime.strptime(datos.get('fecha'), "%Y-%m-%d")
        except ValueError:
            errores.append("Formato de fecha inválido")
    
    # Validar correos destinatarios
    if datos.get('destinatario'):
        destinatarios = [email.strip() for email in datos.get('destinatario').split(",") if email.strip()]
        for email in destinatarios:
            if '@' not in email or '.' not in email.split('@')[1]:
                errores.append(f"Correo inválido: {email}")
    
    return errores


def crear_pdf(datos, filename):
    from reportlab.lib import colors
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    from reportlab.lib.units import inch
    from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
    
    # Crear documento
    doc = SimpleDocTemplate(filename, pagesize=letter,
                          rightMargin=72, leftMargin=72,
                          topMargin=72, bottomMargin=18)
    
    # Estilos
    styles = getSampleStyleSheet()
    
    # Estilo personalizado para el título
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=18,
        spaceAfter=30,
        alignment=TA_CENTER,
        textColor=colors.darkblue
    )
    
    # Estilo para subtítulos
    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Heading2'],
        fontSize=14,
        spaceAfter=12,
        spaceBefore=20,
        textColor=colors.darkblue
    )
    
    # Estilo para texto normal
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=11,
        spaceAfter=8,
        alignment=TA_JUSTIFY
    )
    
    # Estilo para información de contacto
    footer_style = ParagraphStyle(
        'CustomFooter',
        parent=styles['Normal'],
        fontSize=9,
        alignment=TA_CENTER,
        textColor=colors.grey
    )
    
    # Contenido del documento
    story = []
    
    # Formatear fecha
    fecha_formato = "sin fecha"
    try:
        if datos.get("fecha"):
            fecha_formato = datetime.strptime(datos.get("fecha"), "%Y-%m-%d").strftime("%d de %B de %Y")
    except Exception:
        pass
    
    # Título principal
    titulo = f"BITÁCORA DE SALA DE COMPUTACIÓN"
    story.append(Paragraph(titulo, title_style))
    story.append(Spacer(1, 12))
    
    # Fecha
    fecha_texto = f"Fecha: {fecha_formato}"
    story.append(Paragraph(fecha_texto, subtitle_style))
    story.append(Spacer(1, 20))
    
    # Información básica en tabla
    info_data = [
        ['Curso:', datos.get('curso', 'No especificado')],
        ['Asignatura:', datos.get('asignatura', 'No especificada')],
        ['Profesor:', datos.get('correo', 'No especificado')]
    ]
    
    info_table = Table(info_data, colWidths=[1.5*inch, 4*inch])
    info_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.lightgrey),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))
    
    story.append(info_table)
    story.append(Spacer(1, 20))
    
    # Objetivo
    story.append(Paragraph("OBJETIVO DE LA SESIÓN", subtitle_style))
    objetivo_texto = datos.get('objetivo', 'No especificado')
    story.append(Paragraph(objetivo_texto, normal_style))
    story.append(Spacer(1, 15))
    
    # Recursos
    story.append(Paragraph("RECURSOS UTILIZADOS", subtitle_style))
    recursos_texto = datos.get('recursos', 'No especificados')
    story.append(Paragraph(recursos_texto, normal_style))
    story.append(Spacer(1, 15))
    
    # Observaciones
    story.append(Paragraph("OBSERVACIONES", subtitle_style))
    observaciones_texto = datos.get('observaciones', 'Sin observaciones')
    story.append(Paragraph(observaciones_texto, normal_style))
    story.append(Spacer(1, 30))
    
    # Pie de página
    footer_texto = """
    <b>Colegio Polivalente San Cristóbal Apóstol</b><br/>
    Sistema de Bitácora de Sala de Computación<br/>
    Documento generado automáticamente
    """
    story.append(Paragraph(footer_texto, footer_style))
    
    # Construir PDF
    doc.build(story)


@app.route("/")
def index():
    """Página principal - muestra login si no está autenticado"""
    if not google.authorized:
        app.logger.info("Usuario no autorizado. Mostrando página de login.")
        return render_template("login.html")
    try:
        resp = google.get("/oauth2/v2/userinfo")
        if not resp.ok:
            app.logger.error(f"Error al obtener userinfo: {resp.text}")
            return "No se pudo obtener la información del usuario", 403
        correo = resp.json().get("email")
        app.logger.info(f"Usuario autenticado: {correo}")
    except Exception as e:
        log_error_detallado(e)
        return "Error interno durante autenticación", 500

    # Permitir acceso a cualquier usuario autenticado con Google
    app.logger.info(f"Acceso autorizado para: {correo}")

    session['user_email'] = correo
    return redirect(url_for("formulario"))


@app.route("/formulario", methods=["GET", "POST"])
def formulario():
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    if request.method == "POST":
        datos = request.form.to_dict()
        datos["correo"] = session['user_email']
        app.logger.info(f"Recibidos datos del formulario: {datos}")

        # Validar datos del formulario
        errores = validar_datos_formulario(datos)
        if errores:
            for error in errores:
                flash(f"Error: {error}")
            return render_template("formulario.html", correo=session['user_email'])

        # Guardar en base de datos SQLite
        try:
            save_to_db(datos)
            app.logger.info("Datos guardados en base de datos SQLite exitosamente.")
        except Exception as e:
            log_error_detallado(e)
            flash("Error guardando el registro en la base de datos.")
            return render_template("formulario.html", correo=session['user_email'])

        # Mantener respaldo en JSON y CSV
        archivo_json = "bitacora_backup.json"
        registros = []
        try:
            if os.path.exists(archivo_json):
                with open(archivo_json, "r", encoding="utf-8") as f:
                    registros = json.load(f)
            registros.append(datos)
            with open(archivo_json, "w", encoding="utf-8") as f:
                json.dump(registros, f, indent=4, ensure_ascii=False)
            app.logger.info("Datos guardados en JSON exitosamente.")
        except Exception as e:
            log_error_detallado(e)
            flash("Error guardando el registro localmente.")

        archivo_csv = "bitacora_backup.csv"
        campos = list(datos.keys())
        try:
            archivo_existe = os.path.exists(archivo_csv)
            with open(archivo_csv, "a", newline='', encoding="utf-8") as f:
                writer = csv.DictWriter(f, fieldnames=campos)
                if not archivo_existe:
                    writer.writeheader()
                writer.writerow(datos)
            app.logger.info("Datos guardados en CSV exitosamente.")
        except Exception as e:
            log_error_detallado(e)
            flash("Error guardando el registro localmente.")

        # Enviar correo con PDF
        try:
            fecha_formato = "sin_fecha"
            if datos.get("fecha"):
                try:
                    fecha_formato = datetime.strptime(datos.get("fecha"), "%Y-%m-%d").strftime("%d-%m-%Y")
                except:
                    fecha_formato = "sin_fecha"

            archivo_pdf = f"bitacora_{fecha_formato.replace('-', '')}.pdf"
            crear_pdf(datos, archivo_pdf)

            # Crear mensaje profesional para el correo
            cuerpo = f"""Estimado/a destinatario,

Se hace envío de la bitácora del día {fecha_formato} para su conocimiento y registro mediante este correo automático.

INFORMACIÓN DEL REGISTRO:
• Fecha: {fecha_formato}
• Curso: {datos.get('curso', 'No especificado')}
• Asignatura: {datos.get('asignatura', 'No especificada')}
• Profesor: {datos['correo']}

OBJETIVO DE LA SESIÓN:
{datos.get('objetivo', 'No especificado')}

RECURSOS UTILIZADOS:
{datos.get('recursos', 'No especificados')}

OBSERVACIONES:
{datos.get('observaciones', 'Sin observaciones')}

Este documento ha sido generado automáticamente por el Sistema de Bitácora de Sala de Computación.

Para consultas o aclaraciones, contactar al profesor responsable: {datos['correo']}

Atentamente,
Sistema de Bitácora de Sala de Computación
Colegio Polivalente San Cristóbal Apóstol"""

            app.logger.debug(f"Cuerpo correo (raw): {repr(cuerpo)}")

            # Obtener destinatarios del formulario, separados por coma
            destinatarios = [email.strip() for email in request.form.get("destinatario", "").split(",") if email.strip()]

            if not destinatarios:
                raise ValueError("No se especificaron destinatarios válidos")

            msg = Message(
                subject=f"Bitácora Sala de Computación - {fecha_formato}",
                sender=app.config['MAIL_USERNAME'],
                recipients=destinatarios,
            )
            msg.body = cuerpo

            with open(archivo_pdf, "rb") as f:
                msg.attach(
                    archivo_pdf,
                    "application/pdf",
                    f.read()
                )

            mail.send(msg)
            app.logger.info(f"Correo con documento PDF enviado exitosamente a {len(destinatarios)} destinatarios.")
            os.remove(archivo_pdf)

        except Exception as e:
            log_error_detallado(e)
            flash(f"Error enviando el correo: {str(e)}. El registro se guardó correctamente en la base de datos.")
            # Limpiar archivo PDF si existe
            if 'archivo_pdf' in locals() and os.path.exists(archivo_pdf):
                os.remove(archivo_pdf)

        flash("Registro creado exitosamente - Formulario guardado y correo enviado correctamente", "success")
        return redirect(url_for("formulario"))

    correos_predeterminados = get_default_emails()
    return render_template("formulario.html", correo=session['user_email'], correos_predeterminados=correos_predeterminados)


@app.route("/admin")
def admin():
    """Página de administración para ver todos los registros"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    try:
        registros = get_all_records()
        return render_template("admin.html", registros=registros, correo=session['user_email'])
    except Exception as e:
        log_error_detallado(e)
        flash("Error al cargar los registros.")
        return redirect(url_for("formulario"))

@app.route("/eliminar_registros", methods=["POST"])
def eliminar_registros():
    """Elimina uno o múltiples registros de la base de datos"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    try:
        # Obtener los IDs de los registros a eliminar
        registro_ids = request.form.getlist('registro_ids')
        
        if not registro_ids:
            flash("No se seleccionaron registros para eliminar.", "warning")
            return redirect(url_for("admin"))
        
        # Conectar a la base de datos
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        
        # Eliminar cada registro
        eliminados = 0
        for registro_id in registro_ids:
            cursor.execute("DELETE FROM bitacora WHERE id = ?", (registro_id,))
            if cursor.rowcount > 0:
                eliminados += 1
        
        conn.commit()
        conn.close()
        
        # Mensaje de confirmación
        if eliminados == 1:
            flash(f"✅ Se eliminó {eliminados} registro correctamente.", "success")
        else:
            flash(f"✅ Se eliminaron {eliminados} registros correctamente.", "success")
        
        app.logger.info(f"Usuario {session['user_email']} eliminó {eliminados} registros: {registro_ids}")
        
    except Exception as e:
        log_error_detallado(e)
        flash("❌ Error al eliminar los registros.", "error")
    
    return redirect(url_for("admin"))

@app.route("/buscar", methods=["GET", "POST"])
def buscar():
    """Página para buscar registros por rango de fechas"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    if request.method == "POST":
        fecha_inicio = request.form.get("fecha_inicio")
        fecha_fin = request.form.get("fecha_fin")
        
        if fecha_inicio and fecha_fin:
            try:
                registros = get_records_by_date_range(fecha_inicio, fecha_fin)
                return render_template("buscar.html", registros=registros, correo=session['user_email'], 
                                     fecha_inicio=fecha_inicio, fecha_fin=fecha_fin)
            except Exception as e:
                log_error_detallado(e)
                flash("Error al buscar registros.")
    
    return render_template("buscar.html", registros=[], correo=session['user_email'])

@app.route("/correos", methods=["GET", "POST"])
def gestionar_correos():
    """Página para gestionar correos predeterminados"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    if request.method == "POST":
        accion = request.form.get("accion")
        
        if accion == "agregar":
            nuevo_correo = request.form.get("nuevo_correo", "").strip()
            if nuevo_correo and "@" in nuevo_correo:
                correos_actuales = get_default_emails()
                if nuevo_correo not in correos_actuales:
                    correos_actuales.append(nuevo_correo)
                    if update_default_emails(correos_actuales):
                        flash(f"Correo {nuevo_correo} agregado exitosamente")
                    else:
                        flash("Error al agregar el correo")
                else:
                    flash("El correo ya existe en la lista")
            else:
                flash("Correo inválido")
        
        elif accion == "eliminar":
            correo_eliminar = request.form.get("correo_eliminar", "").strip()
            if correo_eliminar:
                correos_actuales = get_default_emails()
                if correo_eliminar in correos_actuales:
                    correos_actuales.remove(correo_eliminar)
                    if update_default_emails(correos_actuales):
                        flash(f"Correo {correo_eliminar} eliminado exitosamente")
                    else:
                        flash("Error al eliminar el correo")
                else:
                    flash("El correo no existe en la lista")
    
    correos_predeterminados = get_default_emails()
    return render_template("correos.html", correos=correos_predeterminados, correo=session['user_email'])

@app.route("/crear_ejemplos", methods=['GET', 'POST'])
def crear_ejemplos():
    """Crea datos de ejemplo para demostrar la aplicación"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    try:
        crear_datos_ejemplo()
        flash("Datos de ejemplo creados exitosamente para agosto 2024")
    except Exception as e:
        log_error_detallado(e)
        flash("Error al crear datos de ejemplo")
    
    return redirect(url_for("admin"))

@app.route("/enviar_correo_prueba")
def enviar_correo_prueba():
    """Enviar correo de prueba a pablo.elias.miranda.292003@gmail.com"""
    if 'user_email' not in session:
        app.logger.warning("Intento de acceso sin sesión válida")
        return redirect(url_for("index"))
    
    try:
        msg = Message(
            subject="🧪 Correo de Prueba - Bitácora de Sala de Computación",
            sender=app.config['MAIL_USERNAME'],
            recipients=["pablo.elias.miranda.292003@gmail.com"]
        )
        
        msg.body = """
¡Hola Pablo!

Este es un correo de prueba desde la aplicación Bitácora de Sala de Computación.

✅ La aplicación está funcionando correctamente
✅ El sistema de correos está configurado
✅ La base de datos SQLite está operativa
✅ Todas las funcionalidades están disponibles

La aplicación incluye:
• Formulario de registro de uso de sala
• Gestión de correos predeterminados
• Visualización de registros
• Búsqueda por fechas
• Exportación a PDF y Word
• Autenticación con Google OAuth

¡Todo listo para usar!

Saludos,
Sistema Bitácora de Sala de Computación
        """
        
        mail.send(msg)
        flash("✅ Correo de prueba enviado exitosamente a pablo.elias.miranda.292003@gmail.com", "success")
        app.logger.info("Correo de prueba enviado exitosamente")
        
    except Exception as e:
        log_error_detallado(e)
        flash("❌ Error al enviar el correo de prueba", "error")
    
    return redirect(url_for("admin"))

@app.route("/logout")
def logout():
    """Cierra sesión y limpia todas las cookies y datos de sesión"""
    # Limpiar sesión de Flask
    session.clear()
    
    # Limpiar sesión de Google OAuth
    if google.authorized:
        try:
            # Revocar token de Google
            google.post("https://oauth2.googleapis.com/revoke", 
                       data={"token": google.token.get("access_token")})
        except Exception as e:
            app.logger.warning(f"Error al revocar token de Google: {e}")
    
    app.logger.info("Sesión cerrada completamente.")
    
    # Redirigir a login con parámetros para limpiar cookies
    response = redirect(url_for("index"))
    
    # Limpiar cookies del navegador
    response.set_cookie('session', '', expires=0)
    response.set_cookie('google_oauth_token', '', expires=0)
    
    return response


if __name__ == "__main__":
    init_db()  # Inicializar la base de datos
    
    # Abrir navegador automáticamente
    import webbrowser
    import threading
    import time
    
    def open_browser():
        time.sleep(1.5)  # Esperar a que el servidor inicie
        # Intentar abrir en modo incógnito para evitar sesiones anteriores
        try:
            import subprocess
            import platform
            
            if platform.system() == "Windows":
                # Chrome en modo incógnito
                subprocess.Popen(['chrome', '--incognito', 'http://localhost:5000'], 
                               shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                webbrowser.open('http://localhost:5000')
        except:
            # Fallback a navegador normal si no se puede abrir en incógnito
            webbrowser.open('http://localhost:5000')
    
    # Iniciar hilo para abrir navegador
    browser_thread = threading.Thread(target=open_browser)
    browser_thread.daemon = True
    browser_thread.start()
    
    print("=" * 50)
    print("🚀 BITACORA DE SALA DE COMPUTACION")
    print("=" * 50)
    print("✅ Servidor iniciado en: http://localhost:5000")
    print("✅ Navegador se abrirá automáticamente")
    print("✅ Presiona Ctrl+C para detener el servidor")
    print("=" * 50)
    
    app.run(debug=False, host='0.0.0.0', port=5000)