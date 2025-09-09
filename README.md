# Bitácora de Sala de Computación

## Descripción

Sistema web profesional para el registro y gestión del uso de salas de computación en instituciones educativas. Desarrollado con Flask, SQLite y autenticación Google OAuth, permite a los profesores registrar sesiones de clases, gestionar recursos utilizados y generar reportes automáticos por correo electrónico.

## Características Principales

### Autenticación y Seguridad
- **Autenticación Google OAuth 2.0**: Acceso seguro con cualquier cuenta de Google autorizada
- **Sesiones seguras**: Manejo robusto de sesiones con Flask
- **Validación de datos**: Verificación completa de todos los campos de entrada
- **Logs detallados**: Registro completo de actividades y errores

### Gestión de Datos
- **Base de datos SQLite**: Almacenamiento robusto y escalable sin configuración de servidor
- **Migración automática**: Actualización automática de esquemas de base de datos
- **Respaldo múltiple**: Almacenamiento en SQLite, JSON y CSV
- **Integridad de datos**: Validaciones y restricciones a nivel de aplicación

### Funcionalidades del Sistema
- **Registro de sesiones**: Formulario intuitivo para capturar información de clases
- **Gestión de correos**: Sistema de destinatarios predeterminados con un clic
- **Búsqueda avanzada**: Filtros por rango de fechas y criterios múltiples
- **Panel de administración**: Visualización completa de todos los registros
- **Exportación de datos**: Generación de reportes en PDF y Word
- **Sistema de correos**: Envío automático de notificaciones con documentos adjuntos

### Interfaz de Usuario
- **Diseño responsive**: Optimizado para dispositivos móviles y escritorio
- **Bootstrap 5**: Framework moderno para interfaz profesional
- **Animaciones fluidas**: Transiciones y efectos visuales mejorados
- **Iconos Font Awesome**: Iconografía consistente y profesional
- **Tema personalizado**: Colores corporativos y diseño institucional

## Arquitectura del Sistema

### Backend
- **Framework**: Python Flask 3.1.1
- **Base de datos**: SQLite con migración automática
- **Autenticación**: Flask-Dance con Google OAuth 2.0
- **Correos**: Flask-Mail con SMTP Gmail
- **PDFs**: ReportLab para generación de documentos
- **Validación**: Validaciones personalizadas en Python

### Frontend
- **HTML5**: Estructura semántica moderna
- **CSS3**: Estilos personalizados con variables CSS
- **JavaScript**: Funcionalidad interactiva y validaciones del lado cliente
- **Bootstrap 5**: Framework CSS responsive
- **Font Awesome 6**: Iconografía profesional

### Base de Datos

#### Estructura de Tablas

**Tabla: usuarios**
```sql
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    correo TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Tabla: bitacora**
```sql
CREATE TABLE bitacora (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha TEXT NOT NULL,
    curso TEXT NOT NULL,
    asignatura TEXT NOT NULL,
    objetivo TEXT NOT NULL,
    recursos TEXT NOT NULL,
    observaciones TEXT NOT NULL,
    correo TEXT NOT NULL,
    destinatario TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id TEXT NOT NULL DEFAULT "usuario_ejemplo"
);
```

#### Relaciones de Datos
- **Relación lógica**: Un usuario puede crear múltiples registros de bitácora (1:N)
- **Implementación**: LEFT JOIN en consultas SQL para mantener compatibilidad
- **Integridad**: Validaciones a nivel de aplicación

#### Características de la Base de Datos
- **Sin configuración**: No requiere servidor de base de datos separado
- **Portabilidad**: Un solo archivo contiene toda la información
- **Robustez**: Maneja miles de registros sin problemas de rendimiento
- **Seguridad**: Transacciones ACID y integridad de datos
- **Escalabilidad**: Optimizado para aplicaciones web educativas

## Instalación y Configuración

### Requisitos del Sistema
- Python 3.8 o superior
- pip (gestor de paquetes de Python)
- Navegador web moderno
- Conexión a internet (para autenticación OAuth)

### Instalación Automática (Recomendada)

**Para Windows:**
1. Descargar o clonar el proyecto
2. Ejecutar `start_bitacora.bat` como administrador
3. La aplicación se instalará automáticamente en Documentos
4. Se creará un acceso directo en el escritorio con icono personalizado
5. El sistema está listo para usar sin configuración adicional

### Instalación Manual

1. **Clonar el proyecto**
   ```bash
   git clone https://github.com/JackStar6677-1/BitacoraAPP.git
   cd BitacoraAPP
   ```

2. **Crear entorno virtual**
   ```bash
   python -m venv venv
   ```

3. **Activar entorno virtual**
   
   En Windows:
   ```bash
   venv\Scripts\activate
   ```
   
   En Linux/Mac:
   ```bash
   source venv/bin/activate
   ```

4. **Instalar dependencias**
   ```bash
   pip install -r requirements.txt
   ```

5. **Ejecutar la aplicación**
   ```bash
   python app.py
   ```

6. **Acceder a la aplicación**
   
   Abrir el navegador en: `http://localhost:5000`

### Configuración

La aplicación incluye configuración predeterminada completa:
- Credenciales de Google OAuth ya configuradas
- Configuración de Gmail ya establecida
- Correos predeterminados ya configurados
- Sin necesidad de configuración adicional

Para personalización opcional, crear un archivo `config.json`:
```json
{
  "SECRET_KEY": "tu_clave_secreta",
  "MAIL_SERVER": "smtp.gmail.com",
  "MAIL_PORT": 587,
  "MAIL_USE_TLS": true,
  "MAIL_USERNAME": "tu_correo@gmail.com",
  "MAIL_PASSWORD": "tu_contraseña_de_aplicacion",
  "OAUTH_CLIENT_ID": "tu_client_id",
  "OAUTH_CLIENT_SECRET": "tu_client_secret",
  "AUTHORIZED_EMAILS": ["correo1@institucion.com", "correo2@institucion.com"],
  "DEFAULT_EMAILS": ["admin@institucion.com", "coordinador@institucion.com"]
}
```

## Uso de la Aplicación

### Flujo de Trabajo Principal

1. **Acceso inicial**
   - Abrir la aplicación en el navegador
   - Hacer clic en "Iniciar Sesión con Google"
   - Autorizar la aplicación con una cuenta de Google autorizada

2. **Crear un registro**
   - Completar el formulario con la información de la sesión
   - Especificar los destinatarios del correo
   - Hacer clic en "Guardar y Enviar"

3. **Administrar registros**
   - Usar el menú desplegable para acceder a "Ver Registros"
   - Visualizar todos los registros en formato de tabla
   - Ver estadísticas de uso y métricas importantes

4. **Buscar registros**
   - Acceder a "Buscar" desde el menú
   - Seleccionar rango de fechas
   - Hacer clic en "Buscar" para filtrar resultados

5. **Gestionar correos predeterminados**
   - Acceder a "Gestionar Correos" desde el menú
   - Agregar nuevos correos frecuentes
   - Eliminar correos que ya no se usen

### Funcionalidades Avanzadas

#### Sistema de Correos
- **Envío automático**: Cada registro genera un correo con PDF adjunto
- **Formato profesional**: Mensajes estructurados con información completa
- **Múltiples destinatarios**: Soporte para listas de correos separados por comas
- **Documentos adjuntos**: Generación automática de PDFs con formato institucional

#### Gestión de Usuarios
- **Registro automático**: Los usuarios se crean automáticamente al iniciar sesión
- **Historial completo**: Seguimiento de todas las actividades por usuario
- **Sesiones seguras**: Manejo robusto de autenticación y autorización

#### Exportación de Datos
- **Múltiples formatos**: SQLite, JSON y CSV
- **Respaldo automático**: Cada registro se guarda en los tres formatos
- **Migración fácil**: Datos portables entre diferentes instalaciones

## Estructura del Proyecto

```
BitacoraAPP/
├── app.py                 # Aplicación principal Flask
├── app.db                # Base de datos SQLite
├── requirements.txt      # Dependencias de Python
├── README.md            # Documentación principal
├── start_bitacora.bat   # Script de instalación automática
├── static/              # Archivos estáticos
│   ├── css/
│   │   └── styles.css   # Estilos personalizados
│   └── imagenes/
│       ├── logo.jpg     # Logo de la aplicación
│       └── logo2.ico    # Icono para acceso directo
├── templates/           # Plantillas HTML
│   ├── login.html       # Página de login
│   ├── formulario.html  # Formulario principal
│   ├── admin.html       # Panel de administración
│   ├── buscar.html      # Página de búsqueda
│   └── correos.html     # Gestión de correos
├── docs/                # Documentación técnica
│   └── ERD/            # Modelo de base de datos
│       ├── ERD.mmd     # Diagrama entidad-relación
│       ├── ERD.png     # Imagen del diagrama
│       ├── ERD.svg     # Vector del diagrama
│       ├── schema.sqlite.ddl.sql # DDL de la base de datos
│       └── README-ERD.md # Documentación del modelo
└── venv/               # Entorno virtual
```

## Despliegue en Producción

### Configuración de Producción

1. **Instalar Gunicorn**
   ```bash
   pip install gunicorn
   ```

2. **Ejecutar en producción**
   ```bash
   gunicorn -w 4 -b 0.0.0.0:8000 app:app
   ```

### Variables de Entorno

Para producción, configurar las siguientes variables:
- `FLASK_ENV=production`
- `SECRET_KEY=clave_secreta_muy_segura`
- `DATABASE_URL=sqlite:///app.db`

### Consideraciones de Seguridad

- **HTTPS obligatorio**: Usar certificado SSL válido
- **Credenciales seguras**: Cambiar todas las credenciales predeterminadas
- **Backup regular**: Respaldar la base de datos regularmente
- **Monitoreo**: Implementar logs de acceso y errores

## Mantenimiento y Soporte

### Tareas de Mantenimiento

- **Respaldos regulares**: Exportar base de datos SQLite
- **Limpieza de logs**: Rotar archivos de log grandes
- **Actualizaciones**: Mantener dependencias actualizadas
- **Monitoreo**: Verificar funcionamiento del sistema de correos

### Resolución de Problemas

#### Problemas Comunes
1. **Error de autenticación**: Verificar credenciales OAuth
2. **Correos no enviados**: Verificar configuración SMTP
3. **Base de datos corrupta**: Restaurar desde respaldo
4. **Rendimiento lento**: Verificar índices de base de datos

#### Logs y Debugging
- **Logs de aplicación**: Revisar salida de consola
- **Logs de base de datos**: Verificar integridad con PRAGMA
- **Logs de correos**: Verificar configuración SMTP

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Soporte Técnico

Para soporte técnico o preguntas:
- Crear un issue en el repositorio
- Contactar al administrador del sistema
- Revisar la documentación de Flask y las dependencias utilizadas

## Historial de Versiones

### Versión 2.0 - Mejoras Implementadas
- Base de datos SQLite profesional
- Interfaz moderna con Bootstrap 5
- Panel de administración completo
- Sistema de búsqueda avanzada
- Sistema de correos predeterminados
- Acceso sin restricciones de lista blanca
- Validaciones robustas
- Mejor manejo de errores
- Diseño responsive
- Animaciones y efectos visuales
- Documentación completa
- Script de instalación automática

---

**Desarrollado para instituciones educativas**

*Sistema de Bitácora de Sala de Computación - Gestión profesional del uso de recursos tecnológicos educativos*