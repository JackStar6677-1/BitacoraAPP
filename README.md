# 📚 Bitácora de Sala de Computación

Una aplicación web profesional para el registro y gestión del uso de salas de computación en instituciones educativas. Desarrollada con Flask, SQLite y autenticación Google OAuth.

## 🎯 Descripción

Esta aplicación permite a los profesores y personal educativo registrar el uso de salas de computación, incluyendo detalles como curso, asignatura, objetivos, recursos utilizados y observaciones. Todo se almacena en una base de datos SQLite profesional y se pueden enviar notificaciones por correo electrónico.

## ✨ Características Principales

- **🔐 Autenticación Google OAuth**: Acceso seguro con cualquier cuenta de Google
- **💾 Base de datos SQLite**: Almacenamiento robusto y escalable
- **📧 Sistema de correos**: Notificaciones automáticas por email
- **📊 Gestión de registros**: Visualización, búsqueda y administración completa
- **📄 Exportación**: Generación de reportes en PDF y Word
- **🎨 Interfaz moderna**: Diseño responsive con Bootstrap 5
- **⚙️ Configuración incluida**: Sin necesidad de configuración adicional
- **🚀 Instalación automática**: Un solo script hace todo
- **🖥️ Acceso directo profesional**: Icono personalizado en el escritorio
- **📁 Migración automática**: Se instala en Documentos del usuario
- **🔇 Ejecución silenciosa**: Sin ventanas de consola visibles
- **🌐 Inicio automático**: Navegador se abre automáticamente

## 🛠️ Tecnologías Utilizadas

- **Backend**: Python Flask
- **Base de datos**: SQLite
- **Autenticación**: Google OAuth 2.0 (Flask-Dance)
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Correos**: Flask-Mail
- **PDFs**: ReportLab
- **Iconos**: Font Awesome 6
- **Estilos**: CSS personalizado con animaciones

## 📋 Funcionalidades

### Para Usuarios
- **Registro de uso**: Formulario intuitivo para registrar sesiones de computación
- **Autenticación segura**: Login con cualquier cuenta de Google
- **Correos predeterminados**: Sistema de destinatarios frecuentes con un clic
- **Navegación fácil**: Menú desplegable con acceso a todas las funciones
- **Validación en tiempo real**: Verificación de datos antes del envío

### Para Administradores
- **Panel de administración**: Visualización de todos los registros
- **Búsqueda avanzada**: Filtros por rango de fechas
- **Gestión de correos**: Administración de destinatarios predeterminados
- **Estadísticas**: Resumen de uso con métricas importantes
- **Exportación**: Respaldos automáticos en múltiples formatos

## 🛠️ Tecnologías Utilizadas

- **Backend**: Python Flask
- **Base de datos**: SQLite
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Autenticación**: Google OAuth 2.0 (Flask-Dance)
- **Correos**: Flask-Mail
- **PDFs**: ReportLab
- **Iconos**: Font Awesome 6

## 📦 Instalación

### 🚀 Instalación Automática (Recomendada)

**Para Windows:**
1. Descargar o clonar el proyecto
2. Ejecutar `start_bitacora.bat` como administrador
3. La aplicación se instalará automáticamente en Documentos
4. Se creará un acceso directo en el escritorio con icono personalizado
5. ¡Listo! No se requiere configuración adicional

### 🎯 Características de la Instalación

**✅ Migración Automática:**
- El proyecto se copia automáticamente a `Documentos\BitacoraAPP`
- Organización profesional en la ubicación correcta
- No más archivos en Descargas o Escritorio

**✅ Acceso Directo Profesional:**
- Icono personalizado usando `static\imagenes\logo2.ico`
- Nombre descriptivo: "Bitácora de Sala de Computación"
- Ejecución silenciosa sin ventanas de consola

**✅ Experiencia de Usuario:**
- Simula una aplicación nativa de Windows
- Navegador se abre automáticamente
- Sin ventanas de consola visibles al usuario
- Funciona en cualquier PC sin configuración adicional

### 🌐 Aplicación Web

**Características:**
- Aplicación web profesional
- Navegador se abre automáticamente
- Acceso mediante navegador en http://localhost:5000
- Configuración incluida
- Sin necesidad de generar ejecutables

### 📋 Instalación Manual

#### Requisitos previos
- Python 3.8 o superior
- pip (gestor de paquetes de Python)

#### Pasos de instalación

1. **Clonar o descargar el proyecto**
   ```bash
   git clone [URL_DEL_REPOSITORIO]
   cd bitacora-app
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

5. **Configuración automática**
   
   La aplicación incluye configuración predeterminada. No se requiere configuración adicional.

6. **Ejecutar la aplicación**
   ```bash
   python app.py
   ```

7. **Acceder a la aplicación**
   
   Abrir el navegador en: `http://localhost:5000`

### 🚀 Aplicación Oficial (Ejecutable)

El script `start_bitacora.bat` crea automáticamente una aplicación ejecutable independiente:

**Proceso Automático:**
1. Ejecutar `start_bitacora.bat`
2. El script instala dependencias, crea la aplicación y la ejecuta
3. Se genera automáticamente el ejecutable oficial

**Resultado:**
- `dist/BitacoraSala.exe` - Aplicación principal con icono
- `Iniciar_Bitacora.bat` - Script de inicio
- Sin ventana de consola
- Icono personalizado
- Ejecutable independiente

### 🎯 Ventajas de la Aplicación Oficial

- **Sin dependencias**: No requiere Python instalado en el sistema
- **Icono personalizado**: Usa el logo de la institución
- **Sin consola**: Se ejecuta en segundo plano sin ventana de comandos
- **Portable**: Se puede copiar a cualquier computadora
- **Profesional**: Se ve como una aplicación oficial
- **Fácil distribución**: Un solo archivo ejecutable
- **Inicio rápido**: Se abre directamente sin configuración

### 🔧 Script de Instalación

- **`start_bitacora.bat`**: Script único que instala, configura y crea la aplicación oficial automáticamente

## ⚙️ Configuración

### Configuración Incluida

La aplicación incluye configuración predeterminada con:
- ✅ Credenciales de Google OAuth ya configuradas
- ✅ Configuración de Gmail ya establecida
- ✅ Correos predeterminados ya configurados
- ✅ Sin necesidad de configuración adicional

### Personalización Opcional

Si deseas personalizar la configuración:
1. Crear un archivo `config.json` en la carpeta de la aplicación
2. La aplicación usará tu configuración personalizada
3. Si no existe, usará la configuración predeterminada incluida

## 💾 Base de Datos SQLite

### ¿Por qué SQLite?
- **✅ Sin configuración**: No requiere servidor de base de datos
- **✅ Portátil**: Un solo archivo contiene toda la información
- **✅ Robusto**: Maneja miles de registros sin problemas
- **✅ Seguro**: Transacciones ACID y integridad de datos
- **✅ Rápido**: Optimizado para aplicaciones web

### Estructura de la Tabla `bitacora`
```sql
CREATE TABLE bitacora (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id TEXT NOT NULL,
    fecha TEXT NOT NULL,
    curso TEXT NOT NULL,
    asignatura TEXT NOT NULL,
    objetivo TEXT NOT NULL,
    recursos TEXT NOT NULL,
    observaciones TEXT NOT NULL,
    correo TEXT NOT NULL,
    destinatario TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Características de la Base de Datos
- **Migración automática**: Se actualiza automáticamente al agregar nuevas columnas
- **Respaldo automático**: Se crean respaldos en JSON y CSV
- **Integridad**: Validaciones y restricciones de datos
- **Escalabilidad**: Maneja desde pocos hasta miles de registros

## 📁 Estructura del Proyecto

```
bitacora-app/
├── app.py                 # Aplicación principal Flask
├── app.db               # Base de datos SQLite
├── requirements.txt     # Dependencias de Python
├── README.md           # Documentación
├── start_bitacora.bat  # Script de instalación y migración
├── limpiar_archivos.bat # Script de limpieza de archivos temporales
├── static/             # Archivos estáticos
│   ├── css/
│   │   └── styles.css  # Estilos personalizados
│   └── imagenes/
│       ├── logo.jpg    # Logo de la aplicación
│       └── logo2.ico   # Icono para acceso directo
├── templates/          # Plantillas HTML
│   ├── login.html      # Página de login
│   ├── formulario.html # Formulario principal
│   ├── admin.html      # Panel de administración
│   ├── buscar.html     # Página de búsqueda
│   └── correos.html    # Gestión de correos
└── venv/              # Entorno virtual
```

### 📂 Estructura en Documentos (Después de la Instalación)

```
Documentos/BitacoraAPP/
├── app.py                 # Aplicación principal
├── iniciar_bitacora.bat   # Script de inicio silencioso
├── static/               # Recursos estáticos
├── templates/            # Plantillas HTML
├── venv/                # Entorno virtual
└── app.db               # Base de datos SQLite
```

## 🔧 Uso de la Aplicación

### 1. Acceso inicial
- Abrir la aplicación en el navegador
- Hacer clic en "Iniciar Sesión con Google"
- Autorizar la aplicación con una cuenta de Google autorizada

### 2. Crear un registro
- Completar el formulario con la información de la sesión
- Especificar los destinatarios del correo
- Hacer clic en "Guardar y Enviar"

### 3. Administrar registros
- Usar el menú desplegable para acceder a "Ver Registros"
- Visualizar todos los registros en formato de tabla
- Ver estadísticas de uso

### 4. Buscar registros
- Acceder a "Buscar" desde el menú
- Seleccionar rango de fechas
- Hacer clic en "Buscar" para filtrar resultados

### 5. Gestionar correos predeterminados
- Acceder a "Gestionar Correos" desde el menú
- Agregar nuevos correos frecuentes
- Eliminar correos que ya no se usen
- Los correos aparecerán como opciones en el formulario principal

## 📊 Base de Datos SQLite

### ¿Por qué SQLite?

La aplicación utiliza **SQLite** como base de datos principal por las siguientes ventajas:

- **Sin configuración**: No requiere servidor de base de datos separado
- **Portabilidad**: El archivo de base de datos se puede mover fácilmente
- **Confiabilidad**: Base de datos probada y estable
- **Rendimiento**: Excelente para aplicaciones de escritorio y web pequeñas/medianas
- **Compatibilidad**: Funciona en cualquier sistema operativo
- **Respaldo**: El archivo `app.db` contiene todos los datos

### Estructura de la Base de Datos

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
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Características de la Base de Datos

- **ID único**: Cada registro tiene un identificador único autoincremental
- **Timestamps**: Registro automático de fecha y hora de creación
- **Integridad**: Validación de datos a nivel de base de datos
- **Consultas optimizadas**: Búsquedas rápidas por fecha y otros campos
- **Escalabilidad**: Puede manejar miles de registros eficientemente

### Gestión de la Base de Datos

- **Creación automática**: Se crea automáticamente al iniciar la aplicación
- **Respaldo automático**: Se mantienen respaldos en JSON y CSV
- **Migración**: Fácil migración de datos entre versiones
- **Mantenimiento**: No requiere mantenimiento manual

## 📧 Sistema de Correos Predeterminados

### Características

- **Lista actualizable**: Administra correos frecuentes desde la interfaz web
- **Acceso rápido**: Un clic para agregar correos al formulario
- **Persistencia**: Los correos se guardan en el archivo de configuración
- **Validación**: Verificación automática de formato de correo
- **Gestión visual**: Interfaz intuitiva para agregar/eliminar correos

### Cómo usar

1. **Acceder a gestión**: Menú → "Gestionar Correos"
2. **Agregar correos**: Ingresar email y hacer clic en "Agregar"
3. **Usar en formulario**: Hacer clic en cualquier correo para agregarlo
4. **Agregar todos**: Botón "Correos Predeterminados" para agregar todos

### Configuración

Los correos predeterminados se configuran en `config.json`:

```json
{
  "DEFAULT_EMAILS": [
    "admin@institucion.com",
    "coordinador@institucion.com",
    "laboratorio@institucion.com"
  ]
}
```

## 🔒 Seguridad

- **Autenticación OAuth**: Solo usuarios autorizados pueden acceder
- **Validación de datos**: Verificación de todos los campos de entrada
- **Manejo de errores**: Logs detallados y mensajes informativos
- **Respaldo múltiple**: Datos almacenados en múltiples formatos

## 🚀 Despliegue en Producción

### Usando Gunicorn

1. **Instalar Gunicorn**
   ```bash
   pip install gunicorn
   ```

2. **Ejecutar en producción**
   ```bash
   gunicorn -w 4 -b 0.0.0.0:8000 app:app
   ```

### Variables de entorno

Para producción, configurar las siguientes variables:
- `FLASK_ENV=production`
- `SECRET_KEY=clave_secreta_muy_segura`
- `DATABASE_URL=sqlite:///app.db`

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📞 Soporte

Para soporte técnico o preguntas:
- Crear un issue en el repositorio
- Contactar al administrador del sistema
- Revisar la documentación de Flask y las dependencias utilizadas

## 🔄 Actualizaciones

### Versión 2.0 - Mejoras Implementadas
- ✅ Base de datos SQLite profesional
- ✅ Interfaz moderna con Bootstrap 5
- ✅ Panel de administración completo
- ✅ Sistema de búsqueda avanzada
- ✅ Sistema de correos predeterminados
- ✅ Acceso sin restricciones de lista blanca
- ✅ Validaciones robustas
- ✅ Mejor manejo de errores
- ✅ Diseño responsive
- ✅ Animaciones y efectos visuales
- ✅ Documentación completa
- ✅ Script de instalación automática

---

**Desarrollado con ❤️ para instituciones educativas**
