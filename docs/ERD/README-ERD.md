# Modelo Entidad-Relación (ERD) - Bitácora de Sala de Computación

## Resumen del Dominio

La aplicación **Bitácora de Sala de Computación** es un sistema web desarrollado en Flask que permite a los profesores registrar el uso de la sala de computación de una institución educativa. El sistema gestiona información sobre las sesiones de clases, los recursos utilizados, observaciones técnicas y el envío automático de reportes por correo electrónico.

El modelo de datos está diseñado para capturar la relación entre usuarios (profesores) y sus registros de uso de la sala, manteniendo un historial completo de actividades educativas y problemas técnicos reportados.

## Mapa de Entidades

### Entidades Principales

| Entidad Lógica | Entidad Física | Descripción |
|----------------|----------------|-------------|
| Usuario | `usuarios` | Profesores que utilizan la sala de computación |
| Registro de Bitácora | `bitacora` | Registros individuales de uso de la sala |
| Secuencia SQLite | `sqlite_sequence` | Tabla del sistema para manejo de AUTOINCREMENT |

### Tabla de Entidades Detallada

#### USUARIOS
- **Propósito**: Almacena información de los profesores autorizados
- **Campos**:
  - `id`: Identificador único (PK, INTEGER, AUTOINCREMENT)
  - `correo`: Correo electrónico único del usuario (UNIQUE, NOT NULL)
  - `nombre`: Nombre del profesor (NOT NULL)
  - `fecha_creacion`: Timestamp de creación del registro

#### BITACORA
- **Propósito**: Registra cada sesión de uso de la sala de computación
- **Campos**:
  - `id`: Identificador único (PK, INTEGER, AUTOINCREMENT)
  - `fecha`: Fecha de la sesión en formato YYYY-MM-DD (NOT NULL)
  - `curso`: Curso que utilizó la sala (NOT NULL)
  - `asignatura`: Asignatura impartida (NOT NULL)
  - `objetivo`: Objetivo de la sesión (NOT NULL)
  - `recursos`: Recursos y software utilizados (NOT NULL)
  - `observaciones`: Observaciones técnicas y problemas (NOT NULL)
  - `correo`: Correo del profesor (duplicado para compatibilidad)
  - `destinatario`: Lista de correos destinatarios del reporte
  - `fecha_creacion`: Timestamp de creación del registro
  - `usuario_id`: Referencia al usuario (FK, TEXT - inconsistencia detectada)

## Tabla de Relaciones

| Origen | Destino | Columnas | Tipo | Cardinalidad | Acción ON DELETE/UPDATE |
|--------|---------|----------|------|--------------|------------------------|
| bitacora | usuarios | usuario_id → id | Lógica | 1:N | No implementada |
| usuarios | bitacora | id ← usuario_id | Lógica | 1:N | No implementada |

### Detalles de Relaciones

#### Relación USUARIOS → BITACORA
- **Tipo**: Relación lógica (no implementada como FK en la DB)
- **Cardinalidad**: 1:N (Un usuario puede crear múltiples registros)
- **Implementación**: LEFT JOIN en consultas SQL
- **Estado**: Funcional pero sin integridad referencial

## Diferencias Detectadas y Recomendaciones

### ⚠️ Diferencias Críticas

1. **Tipo de Datos Inconsistente**
   - **Problema**: `usuario_id` es TEXT en lugar de INTEGER
   - **Impacto**: Pérdida de integridad referencial y rendimiento
   - **Recomendación**: Migrar a INTEGER con clave foránea

2. **Falta de Claves Foráneas**
   - **Problema**: No hay FK entre `bitacora.usuario_id` y `usuarios.id`
   - **Impacto**: Posibles registros huérfanos
   - **Recomendación**: Agregar FK con ON DELETE SET NULL

3. **Falta de Índices de Rendimiento**
   - **Problema**: No hay índices en campos de consulta frecuente
   - **Impacto**: Consultas lentas por fecha y usuario
   - **Recomendación**: Agregar índices en `fecha` y `usuario_id`

### 🔧 Acciones Sugeridas

#### Migración de Datos (Recomendada)
```sql
-- 1. Crear tabla temporal con estructura correcta
CREATE TABLE bitacora_new (
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
    usuario_id INTEGER REFERENCES usuarios(id) ON DELETE SET NULL
);

-- 2. Migrar datos existentes
INSERT INTO bitacora_new SELECT * FROM bitacora;

-- 3. Reemplazar tabla original
DROP TABLE bitacora;
ALTER TABLE bitacora_new RENAME TO bitacora;

-- 4. Agregar índices
CREATE INDEX idx_bitacora_fecha ON bitacora(fecha);
CREATE INDEX idx_bitacora_usuario_id ON bitacora(usuario_id);
CREATE INDEX idx_bitacora_asignatura ON bitacora(asignatura);
```

#### Mejoras de Seguridad
- Agregar validación CHECK para formato de correo
- Implementar enmascaramiento de datos sensibles
- Agregar auditoría de cambios

#### Normalización Opcional
- Crear tabla `destinatarios` para normalizar correos múltiples
- Crear tabla `asignaturas` para catálogo de materias
- Crear tabla `cursos` para catálogo de cursos

## Supuestos y Justificación

### Supuestos Adoptados

1. **Compatibilidad con Código Existente**
   - Se mantiene la estructura actual para no romper la aplicación
   - Las mejoras se documentan como recomendaciones futuras

2. **Relación Lógica vs. Física**
   - Se documenta la relación lógica implementada en el código
   - Se identifica la falta de implementación física en la DB

3. **Campos Duplicados**
   - Se acepta la duplicación de `correo` por compatibilidad
   - Se recomienda normalización futura

### Justificación de Decisiones

- **Prioridad a la DB Real**: Se documenta el estado actual, no el ideal
- **Trazabilidad Completa**: Cada campo se rastrea a su origen en el código
- **Recomendaciones Prácticas**: Se sugieren mejoras implementables

## Mantenimiento del Diagrama

### Cuándo Actualizar
- Al modificar la estructura de tablas
- Al agregar nuevas entidades o relaciones
- Al cambiar tipos de datos o constraints

### Cómo Actualizar
1. Ejecutar `python inspect_db.py` para obtener estado actual
2. Actualizar `ERD.mmd` con nuevos cambios
3. Regenerar `schema.sqlite.ddl.sql`
4. Actualizar este README con nuevas diferencias

### Herramientas Recomendadas
- **Inspección**: Scripts Python personalizados
- **Diagramas**: Mermaid (compatible con GitHub/GitLab)
- **Validación**: PRAGMA de SQLite para verificar integridad

---

**Última actualización**: 2025-01-27  
**Versión de la aplicación**: Flask con SQLite  
**Estado de la DB**: Funcional con mejoras recomendadas
