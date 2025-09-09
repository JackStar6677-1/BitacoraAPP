-- =====================================================
-- DDL SQLite - Base de Datos Bitácora de Sala de Computación
-- =====================================================
-- Generado automáticamente basado en la inspección de app.db
-- Fecha: 2025-01-27
-- 
-- NOTA: Este DDL refleja el estado ACTUAL de la base de datos
-- Incluye las diferencias detectadas entre el código y la implementación real
-- =====================================================

-- Configuraciones de SQLite
PRAGMA foreign_keys=ON;
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;

-- =====================================================
-- TABLA: usuarios
-- =====================================================
-- Descripción: Almacena información de usuarios del sistema
-- Origen: Código fuente app.py líneas 107-114
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    correo TEXT UNIQUE NOT NULL,
    nombre TEXT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice único automático para correo (creado por SQLite)
-- sqlite_autoindex_usuarios_1

-- =====================================================
-- TABLA: bitacora
-- =====================================================
-- Descripción: Registra el uso de la sala de computación
-- Origen: Código fuente app.py líneas 90-103 + migraciones dinámicas
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

-- =====================================================
-- TABLA: sqlite_sequence
-- =====================================================
-- Descripción: Tabla del sistema SQLite para manejar AUTOINCREMENT
-- Origen: SQLite automático
CREATE TABLE sqlite_sequence(name,seq);

-- =====================================================
-- ÍNDICES RECOMENDADOS (NO IMPLEMENTADOS EN LA DB ACTUAL)
-- =====================================================
-- Estos índices mejorarían el rendimiento pero no están presentes en la DB real

-- Índice para consultas por fecha
-- CREATE INDEX idx_bitacora_fecha ON bitacora(fecha);

-- Índice para JOINs con usuarios
-- CREATE INDEX idx_bitacora_usuario_id ON bitacora(usuario_id);

-- Índice para consultas por asignatura
-- CREATE INDEX idx_bitacora_asignatura ON bitacora(asignatura);

-- =====================================================
-- CLAVES FORÁNEAS RECOMENDADAS (NO IMPLEMENTADAS EN LA DB ACTUAL)
-- =====================================================
-- Estas claves foráneas mejorarían la integridad referencial pero no están presentes

-- Clave foránea entre bitacora y usuarios
-- ALTER TABLE bitacora ADD CONSTRAINT fk_bitacora_usuario 
--     FOREIGN KEY (usuario_id) REFERENCES usuarios(id) 
--     ON DELETE SET NULL ON UPDATE CASCADE;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- 
-- 1. DIFERENCIAS DETECTADAS:
--    - usuario_id es TEXT en lugar de INTEGER (inconsistencia de tipos)
--    - No hay claves foráneas implementadas (solo relaciones lógicas en el código)
--    - No hay índices adicionales para optimización
--
-- 2. RELACIONES LÓGICAS:
--    - bitacora.usuario_id -> usuarios.id (implementada en código, no en DB)
--    - Cardinalidad: 1 usuario puede tener muchas bitácoras (1:N)
--
-- 3. CAMPOS SENSIBLES:
--    - correo: contiene información personal, debería tener validación
--    - destinatario: puede contener múltiples correos separados por comas
--
-- 4. RECOMENDACIONES DE MEJORA:
--    - Cambiar usuario_id de TEXT a INTEGER
--    - Agregar claves foráneas para integridad referencial
--    - Agregar índices para mejorar rendimiento
--    - Normalizar tabla de destinatarios si se requiere
--    - Agregar validaciones CHECK para formatos de fecha y correo
