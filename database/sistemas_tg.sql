-- ============================================================================
--  SISTEMAS TG - Base de datos de gestión del trabajo de grado
--  Motor: MySQL 8.0.16+ o MariaDB 10.4 (XAMPP). Los CHECK solo se aplican
--  desde MySQL 8.0.16 / MariaDB 10.2; en versiones anteriores se ignoran.
--  ATENCIÓN: el script borra y vuelve a crear la base "sistemas_tg".
--  Incluye triggers (sección 10) escritos con DELIMITER: impórtalo con
--  phpMyAdmin (pestaña Importar) o con el cliente mysql, no por JDBC.
-- ============================================================================

DROP DATABASE IF EXISTS sistemas_tg;
CREATE DATABASE sistemas_tg CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sistemas_tg;

-- ============================================================================
-- 1. CATÁLOGOS
-- ============================================================================

-- Rol de inicio de sesión (un usuario tiene un solo rol).
-- Director y Evaluador NO son roles de usuario: se asignan por proyecto
-- (tabla proyecto), así un mismo docente puede ser director en un proyecto
-- y evaluador en otro desde un solo usuario.
CREATE TABLE rol (
  id_rol  TINYINT UNSIGNED NOT NULL,
  nombre  VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_rol),
  UNIQUE KEY uq_rol_nombre (nombre)
) ENGINE=InnoDB;

-- Rol que debe actuar en el proceso (la parte "Rol" de "Fase N | Rol").
CREATE TABLE rol_proceso (
  id_rol_proceso TINYINT UNSIGNED NOT NULL,
  nombre         VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_rol_proceso),
  UNIQUE KEY uq_rol_proceso_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE tipo_documento (
  id_tipo_documento TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  sigla             VARCHAR(10) NOT NULL,
  nombre            VARCHAR(60) NOT NULL,
  PRIMARY KEY (id_tipo_documento),
  UNIQUE KEY uq_tipo_documento_sigla (sigla)
) ENGINE=InnoDB;

CREATE TABLE nivel_academico (
  id_nivel_academico TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre             VARCHAR(30) NOT NULL,
  PRIMARY KEY (id_nivel_academico),
  UNIQUE KEY uq_nivel_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE periodo_academico (
  id_periodo INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(10) NOT NULL,           -- ej. 2026-2
  PRIMARY KEY (id_periodo),
  UNIQUE KEY uq_periodo_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE linea_investigacion (
  id_linea INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre   VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_linea),
  UNIQUE KEY uq_linea_nombre (nombre)
) ENGINE=InnoDB;

-- Calendario académico y formatos de grado (enlaces URL, requerimiento 44).
CREATE TABLE recurso_institucional (
  id_recurso INT UNSIGNED NOT NULL AUTO_INCREMENT,
  tipo       ENUM('CALENDARIO_ACADEMICO','FORMATO_GRADO') NOT NULL,
  nombre     VARCHAR(150) NOT NULL,
  url        VARCHAR(500) NOT NULL,
  PRIMARY KEY (id_recurso),
  CONSTRAINT ck_recurso_url CHECK (url LIKE 'http://%' OR url LIKE 'https://%')
) ENGINE=InnoDB;

-- ============================================================================
-- 2. USUARIOS
--    Inicio de sesión: número de documento + contraseña + rol.
--    Contraseña en texto plano (limitación aceptada, requerimiento 39).
--    Si el usuario es estudiante (rol 4) el nivel académico es obligatorio;
--    para los demás roles debe ser NULL.
--    Sin ON DELETE: por defecto RESTRICT, así un usuario con proyectos o
--    ideas asociadas no se puede eliminar (requerimiento 46).
-- ============================================================================
CREATE TABLE usuario (
  id_usuario         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre_completo    VARCHAR(150) NOT NULL,
  id_tipo_documento  TINYINT UNSIGNED NOT NULL,
  numero_documento   VARCHAR(20) NOT NULL,
  contrasena         VARCHAR(100) NOT NULL,
  id_rol             TINYINT UNSIGNED NOT NULL,
  id_nivel_academico TINYINT UNSIGNED NULL,
  fecha_creacion     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuario_documento (numero_documento),
  CONSTRAINT fk_usuario_tipo_doc FOREIGN KEY (id_tipo_documento) REFERENCES tipo_documento (id_tipo_documento),
  CONSTRAINT fk_usuario_rol      FOREIGN KEY (id_rol)             REFERENCES rol (id_rol),
  CONSTRAINT fk_usuario_nivel    FOREIGN KEY (id_nivel_academico) REFERENCES nivel_academico (id_nivel_academico),
  CONSTRAINT ck_usuario_nivel CHECK (
    (id_rol = 4 AND id_nivel_academico IS NOT NULL) OR (id_rol <> 4 AND id_nivel_academico IS NULL)
  )
) ENGINE=InnoDB;

-- ============================================================================
-- 3. BANCO DE IDEAS DOCENTE (4.4)
--    El docente que propone la idea queda como director del proyecto.
-- ============================================================================
CREATE TABLE idea_docente (
  id_idea_docente     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  titulo              VARCHAR(200) NOT NULL,
  objetivo            TEXT NOT NULL,
  id_linea            INT UNSIGNED NOT NULL,
  id_nivel_academico  TINYINT UNSIGNED NOT NULL,
  id_periodo          INT UNSIGNED NOT NULL,
  id_docente          INT UNSIGNED NOT NULL,
  estado              ENUM('PENDIENTE','APROBADA','APLAZADA') NOT NULL DEFAULT 'PENDIENTE',
  disponibilidad      ENUM('DISPONIBLE','NO_DISPONIBLE') NOT NULL DEFAULT 'NO_DISPONIBLE',
  acta_numero         VARCHAR(30) NULL,
  motivo_aplazamiento TEXT NULL,
  fecha_propuesta     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_revision      DATETIME NULL,
  PRIMARY KEY (id_idea_docente),
  CONSTRAINT fk_ideadoc_linea   FOREIGN KEY (id_linea)           REFERENCES linea_investigacion (id_linea),
  CONSTRAINT fk_ideadoc_nivel   FOREIGN KEY (id_nivel_academico) REFERENCES nivel_academico (id_nivel_academico),
  CONSTRAINT fk_ideadoc_periodo FOREIGN KEY (id_periodo)         REFERENCES periodo_academico (id_periodo),
  CONSTRAINT fk_ideadoc_docente FOREIGN KEY (id_docente)         REFERENCES usuario (id_usuario),
  -- Solo una idea aprobada puede estar disponible.
  CONSTRAINT ck_ideadoc_disponible CHECK (disponibilidad = 'NO_DISPONIBLE' OR estado = 'APROBADA'),
  -- Aprobar o aplazar exige número de acta; aplazar exige el motivo.
  CONSTRAINT ck_ideadoc_acta   CHECK (estado = 'PENDIENTE' OR acta_numero IS NOT NULL),
  CONSTRAINT ck_ideadoc_motivo CHECK (estado <> 'APLAZADA' OR motivo_aplazamiento IS NOT NULL)
) ENGINE=InnoDB;

-- ============================================================================
-- 4. FASES, TURNOS Y TRANSICIONES
--    fase:           las 6 fases.
--    fase_rol:       quién puede tener el turno en cada fase (estados válidos).
--    transicion_fase: a qué estado pasa el proyecto según quién actúa y qué
--                    hace (enviar, aprobar o aplazar). Así el cambio
--                    automático de fase (req. 3) se resuelve con una consulta.
-- ============================================================================
CREATE TABLE fase (
  id_fase TINYINT UNSIGNED NOT NULL,
  nombre  VARCHAR(40) NOT NULL,
  PRIMARY KEY (id_fase)
) ENGINE=InnoDB;

CREATE TABLE fase_rol (
  id_fase        TINYINT UNSIGNED NOT NULL,
  id_rol_proceso TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_fase, id_rol_proceso),
  CONSTRAINT fk_faserol_fase FOREIGN KEY (id_fase)        REFERENCES fase (id_fase),
  CONSTRAINT fk_faserol_rol  FOREIGN KEY (id_rol_proceso) REFERENCES rol_proceso (id_rol_proceso)
) ENGINE=InnoDB;

CREATE TABLE transicion_fase (
  id_transicion   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_fase_origen  TINYINT UNSIGNED NOT NULL,
  id_rol_origen   TINYINT UNSIGNED NOT NULL,
  accion          ENUM('ENVIAR','APROBADO','APLAZADO') NOT NULL,
  id_fase_destino TINYINT UNSIGNED NULL,
  id_rol_destino  TINYINT UNSIGNED NULL,
  finaliza        TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id_transicion),
  UNIQUE KEY uq_transicion_origen (id_fase_origen, id_rol_origen, accion),
  CONSTRAINT fk_trans_origen  FOREIGN KEY (id_fase_origen,  id_rol_origen)  REFERENCES fase_rol (id_fase, id_rol_proceso),
  CONSTRAINT fk_trans_destino FOREIGN KEY (id_fase_destino, id_rol_destino) REFERENCES fase_rol (id_fase, id_rol_proceso),
  CONSTRAINT ck_trans_final CHECK (
    (finaliza = 1 AND id_fase_destino IS NULL AND id_rol_destino IS NULL)
    OR (finaliza = 0 AND id_fase_destino IS NOT NULL AND id_rol_destino IS NOT NULL)
  )
) ENGINE=InnoDB;

-- ============================================================================
-- 5. PROYECTOS
--    Estado = (id_fase, id_rol_proceso) + finalizado.
--    Texto mostrado: "Fase N | Rol" o "Finalizado" (ver vista v_proyecto).
--    El estudiante 1 es quien crea el proyecto y el único que lo ve;
--    el estudiante 2 (opcional) queda solo como integrante.
-- ============================================================================
CREATE TABLE proyecto (
  id_proyecto       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  origen            ENUM('BANCO_DOCENTE','PROPIA') NOT NULL,
  id_idea_docente   INT UNSIGNED NULL,
  titulo            VARCHAR(200) NOT NULL,
  descripcion       TEXT NOT NULL,
  id_linea          INT UNSIGNED NOT NULL,
  id_estudiante1    INT UNSIGNED NOT NULL,
  id_estudiante2    INT UNSIGNED NULL,
  id_director       INT UNSIGNED NULL,
  id_evaluador      INT UNSIGNED NULL,
  estado_idea       ENUM('PENDIENTE','APROBADA','APLAZADA') NOT NULL DEFAULT 'PENDIENTE',
  id_fase           TINYINT UNSIGNED NOT NULL DEFAULT 1,
  id_rol_proceso    TINYINT UNSIGNED NOT NULL DEFAULT 1,
  finalizado        TINYINT(1) NOT NULL DEFAULT 0,
  radicado          VARCHAR(50) NULL,
  fecha_cierre      DATETIME NULL,
  fecha_creacion    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_proyecto),
  UNIQUE KEY uq_proyecto_idea_docente (id_idea_docente),   -- una idea del banco = un proyecto
  CONSTRAINT fk_proy_idea_docente FOREIGN KEY (id_idea_docente) REFERENCES idea_docente (id_idea_docente),
  CONSTRAINT fk_proy_linea        FOREIGN KEY (id_linea)        REFERENCES linea_investigacion (id_linea),
  CONSTRAINT fk_proy_est1         FOREIGN KEY (id_estudiante1)  REFERENCES usuario (id_usuario),
  CONSTRAINT fk_proy_est2         FOREIGN KEY (id_estudiante2)  REFERENCES usuario (id_usuario),
  CONSTRAINT fk_proy_director     FOREIGN KEY (id_director)     REFERENCES usuario (id_usuario),
  CONSTRAINT fk_proy_evaluador    FOREIGN KEY (id_evaluador)    REFERENCES usuario (id_usuario),
  CONSTRAINT fk_proy_estado       FOREIGN KEY (id_fase, id_rol_proceso) REFERENCES fase_rol (id_fase, id_rol_proceso),
  -- Origen coherente con la idea del banco.
  CONSTRAINT ck_proy_origen CHECK (
    (origen = 'BANCO_DOCENTE' AND id_idea_docente IS NOT NULL AND id_director IS NOT NULL)
    OR (origen = 'PROPIA' AND id_idea_docente IS NULL)
  ),
  -- Los dos estudiantes deben ser distintos.
  CONSTRAINT ck_proy_estudiantes CHECK (id_estudiante2 IS NULL OR id_estudiante2 <> id_estudiante1),
  -- El evaluador no puede ser el director del mismo proyecto.
  CONSTRAINT ck_proy_director_evaluador CHECK (
    id_director IS NULL OR id_evaluador IS NULL OR id_director <> id_evaluador
  ),
  -- Para pasar de la fase 1 deben estar asignados director y evaluador.
  CONSTRAINT ck_proy_asignados CHECK (
    id_fase = 1 OR (id_director IS NOT NULL AND id_evaluador IS NOT NULL)
  ),
  -- Para finalizar se exige el radicado (fase 6).
  CONSTRAINT ck_proy_cierre CHECK (
    finalizado = 0 OR (radicado IS NOT NULL AND fecha_cierre IS NOT NULL)
  )
) ENGINE=InnoDB;

-- ============================================================================
-- 6. ENTREGAS (documentos como URL, con historial de versiones)
-- ============================================================================
CREATE TABLE entrega (
  id_entrega     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_proyecto    INT UNSIGNED NOT NULL,
  id_fase        TINYINT UNSIGNED NOT NULL,
  tipo           ENUM('IDEA','SOPORTE_PAGO','PROPUESTA','INFORME',
                      'MANUAL_USUARIO','MANUAL_TECNICO','REPOSITORIO') NOT NULL,
  url            VARCHAR(500) NOT NULL,
  numero_version INT UNSIGNED NOT NULL DEFAULT 1,
  id_usuario     INT UNSIGNED NOT NULL,          -- quién la cargó
  fecha_entrega  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_entrega),
  UNIQUE KEY uq_entrega_version (id_proyecto, tipo, numero_version),
  CONSTRAINT fk_entrega_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto),
  CONSTRAINT fk_entrega_fase     FOREIGN KEY (id_fase)     REFERENCES fase (id_fase),
  CONSTRAINT fk_entrega_usuario  FOREIGN KEY (id_usuario)  REFERENCES usuario (id_usuario),
  CONSTRAINT ck_entrega_url CHECK (url LIKE 'http://%' OR url LIKE 'https://%')
) ENGINE=InnoDB;

-- ============================================================================
-- 7. REVISIONES (Aprobado / Aplazado con comentarios, trazabilidad)
--    id_rol_proceso solo puede ser 2 (Director), 3 (Evaluador) o 4 (Comité).
--    acta_numero: obligatorio para el comité en la fase 1 (lo valida un trigger).
--    radicado: obligatorio al aprobar el cierre en la fase 6 (lo valida un trigger).
-- ============================================================================
CREATE TABLE revision (
  id_revision    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_proyecto    INT UNSIGNED NOT NULL,
  id_fase        TINYINT UNSIGNED NOT NULL,
  id_rol_proceso TINYINT UNSIGNED NOT NULL,
  id_revisor     INT UNSIGNED NOT NULL,
  id_entrega     INT UNSIGNED NULL,               -- documento revisado
  resultado      ENUM('APROBADO','APLAZADO') NOT NULL,
  comentarios    TEXT NOT NULL,
  acta_numero    VARCHAR(30) NULL,
  radicado       VARCHAR(50) NULL,
  fecha_revision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_revision),
  CONSTRAINT fk_rev_proyecto FOREIGN KEY (id_proyecto) REFERENCES proyecto (id_proyecto),
  CONSTRAINT fk_rev_revisor  FOREIGN KEY (id_revisor)  REFERENCES usuario (id_usuario),
  CONSTRAINT fk_rev_entrega  FOREIGN KEY (id_entrega)  REFERENCES entrega (id_entrega),
  CONSTRAINT fk_rev_turno    FOREIGN KEY (id_fase, id_rol_proceso) REFERENCES fase_rol (id_fase, id_rol_proceso),
  CONSTRAINT ck_rev_rol CHECK (id_rol_proceso IN (2, 3, 4))
) ENGINE=InnoDB;

-- ============================================================================
-- 8. VISTAS (datos de varias tablas, requerimiento 16)
-- ============================================================================

-- Última versión de cada tipo de entrega por proyecto.
CREATE VIEW v_ultima_entrega AS
SELECT e.*
FROM entrega e
WHERE e.numero_version = (
  SELECT MAX(x.numero_version) FROM entrega x
  WHERE x.id_proyecto = e.id_proyecto AND x.tipo = e.tipo
);

-- Proyectos con nombres y estado "Fase N | Rol" / "Finalizado".
-- Para admin, comité, director y evaluador (filtrar por id_director / id_evaluador).
CREATE VIEW v_proyecto AS
SELECT p.id_proyecto, p.origen, p.titulo, p.descripcion,
       li.nombre          AS linea_investigacion,
       p.id_estudiante1, e1.nombre_completo AS estudiante1,
       p.id_estudiante2, e2.nombre_completo AS estudiante2,
       p.id_director,    d.nombre_completo  AS director,
       p.id_evaluador,   ev.nombre_completo AS evaluador,
       p.id_fase, f.nombre AS fase, p.id_rol_proceso, rp.nombre AS rol_turno,
       CASE WHEN p.finalizado = 1 THEN 'Finalizado'
            ELSE CONCAT('Fase ', p.id_fase, ' | ', rp.nombre) END AS estado,
       p.estado_idea, p.finalizado, p.radicado,
       pago.url AS soporte_pago_url,
       p.fecha_creacion, p.fecha_cierre
FROM proyecto p
JOIN linea_investigacion li ON li.id_linea = p.id_linea
JOIN usuario e1 ON e1.id_usuario = p.id_estudiante1
LEFT JOIN usuario e2 ON e2.id_usuario = p.id_estudiante2
LEFT JOIN usuario d  ON d.id_usuario  = p.id_director
LEFT JOIN usuario ev ON ev.id_usuario = p.id_evaluador
JOIN fase f ON f.id_fase = p.id_fase
JOIN rol_proceso rp ON rp.id_rol_proceso = p.id_rol_proceso
LEFT JOIN v_ultima_entrega pago ON pago.id_proyecto = p.id_proyecto AND pago.tipo = 'SOPORTE_PAGO';

-- Vista del estudiante: NO incluye al evaluador (requerimiento 95).
-- Filtrar siempre con WHERE id_estudiante1 = ? (solo el estudiante 1 ve el proyecto).
CREATE VIEW v_proyecto_estudiante AS
SELECT id_proyecto, titulo, descripcion, linea_investigacion,
       id_estudiante1, estudiante1, estudiante2, director,
       id_fase, fase, rol_turno, estado, estado_idea, finalizado, radicado,
       fecha_creacion
FROM v_proyecto;

-- Pantalla 4.4: ideas de docentes para el comité y para el banco de estudiantes.
CREATE VIEW v_idea_docente AS
SELECT i.id_idea_docente, i.titulo, i.objetivo,
       li.nombre AS linea_investigacion, na.nombre AS nivel_academico,
       pe.nombre AS periodo_academico,
       i.id_docente, u.nombre_completo AS docente,
       i.estado, i.disponibilidad, i.acta_numero, i.motivo_aplazamiento,
       i.fecha_propuesta, i.fecha_revision
FROM idea_docente i
JOIN linea_investigacion li ON li.id_linea = i.id_linea
JOIN nivel_academico na ON na.id_nivel_academico = i.id_nivel_academico
JOIN periodo_academico pe ON pe.id_periodo = i.id_periodo
JOIN usuario u ON u.id_usuario = i.id_docente;

-- Pantalla 4.5: ideas propuestas por estudiantes (proyectos de origen PROPIA).
CREATE VIEW v_idea_estudiante AS
SELECT p.id_proyecto, p.titulo, p.descripcion,
       li.nombre AS linea_investigacion,
       e1.nombre_completo AS estudiante1, e2.nombre_completo AS estudiante2,
       na.nombre AS nivel_academico,
       pago.url AS soporte_pago_url,
       p.estado_idea, p.id_director, p.id_evaluador, p.fecha_creacion
FROM proyecto p
JOIN linea_investigacion li ON li.id_linea = p.id_linea
JOIN usuario e1 ON e1.id_usuario = p.id_estudiante1
LEFT JOIN usuario e2 ON e2.id_usuario = p.id_estudiante2
JOIN nivel_academico na ON na.id_nivel_academico = e1.id_nivel_academico
LEFT JOIN v_ultima_entrega pago ON pago.id_proyecto = p.id_proyecto AND pago.tipo = 'SOPORTE_PAGO'
WHERE p.origen = 'PROPIA';

-- Historial de versiones (requerimientos 19 y 91).
CREATE VIEW v_historial_entregas AS
SELECT en.id_entrega, en.id_proyecto, en.id_fase, f.nombre AS fase,
       en.tipo, en.numero_version, en.url, en.fecha_entrega,
       u.nombre_completo AS cargado_por
FROM entrega en
JOIN fase f ON f.id_fase = en.id_fase
JOIN usuario u ON u.id_usuario = en.id_usuario;

-- Historial de revisiones con comentarios.
CREATE VIEW v_historial_revisiones AS
SELECT r.id_revision, r.id_proyecto, r.id_fase, f.nombre AS fase,
       rp.nombre AS rol, u.nombre_completo AS revisor,
       r.resultado, r.comentarios, r.acta_numero, r.id_entrega, r.fecha_revision
FROM revision r
JOIN fase f ON f.id_fase = r.id_fase
JOIN rol_proceso rp ON rp.id_rol_proceso = r.id_rol_proceso
JOIN usuario u ON u.id_usuario = r.id_revisor;

-- ============================================================================
-- 9. DATOS DE EJEMPLO (requerimiento 22)
--    Un administrador, un comité, cuatro docentes y cinco estudiantes
--    (dos con el mismo nombre para probar homónimos). Sin proyectos, para
--    recorrer el sistema completo desde la fase 1.
-- ============================================================================
INSERT INTO rol (id_rol, nombre) VALUES
  (1,'Administrador'), (2,'Comité'), (3,'Docente'), (4,'Estudiante');

INSERT INTO rol_proceso (id_rol_proceso, nombre) VALUES
  (1,'Estudiante'), (2,'Director'), (3,'Evaluador'), (4,'Comité');

INSERT INTO fase (id_fase, nombre) VALUES
  (1,'Idea y pago'), (2,'Propuesta I'), (3,'Propuesta II'),
  (4,'Informe I'), (5,'Informe II'), (6,'Cierre');

-- Turnos válidos por fase.
INSERT INTO fase_rol (id_fase, id_rol_proceso) VALUES
  (1,1),(1,4),
  (2,1),(2,2),
  (3,1),(3,3),(3,4),
  (4,1),(4,2),
  (5,1),(5,3),(5,4),
  (6,4);

-- Flujo del proceso. Al aplazar, el proyecto vuelve al estudiante en la misma fase.
INSERT INTO transicion_fase (id_fase_origen, id_rol_origen, accion, id_fase_destino, id_rol_destino, finaliza) VALUES
  (1,1,'ENVIAR',  1,4,0),
  (1,4,'APROBADO',2,1,0),
  (1,4,'APLAZADO',1,1,0),
  (2,1,'ENVIAR',  2,2,0),
  (2,2,'APROBADO',3,3,0),
  (2,2,'APLAZADO',2,1,0),
  (3,1,'ENVIAR',  3,3,0),
  (3,3,'APROBADO',3,4,0),
  (3,3,'APLAZADO',3,1,0),
  (3,4,'APROBADO',4,1,0),
  (3,4,'APLAZADO',3,1,0),
  (4,1,'ENVIAR',  4,2,0),
  (4,2,'APROBADO',5,3,0),
  (4,2,'APLAZADO',4,1,0),
  (5,1,'ENVIAR',  5,3,0),
  (5,3,'APROBADO',5,4,0),
  (5,3,'APLAZADO',5,1,0),
  (5,4,'APROBADO',6,4,0),
  (5,4,'APLAZADO',5,1,0),
  (6,4,'APROBADO',NULL,NULL,1);

INSERT INTO tipo_documento (sigla, nombre) VALUES
  ('CC','Cédula de ciudadanía'), ('CE','Cédula de extranjería'),
  ('TI','Tarjeta de identidad'), ('PAS','Pasaporte');

INSERT INTO nivel_academico (nombre) VALUES ('Tecnología'), ('Ingeniería');

INSERT INTO periodo_academico (nombre) VALUES ('2026-1'), ('2026-2'), ('2027-1');

INSERT INTO linea_investigacion (nombre) VALUES
  ('Ingeniería de software'),
  ('Seguridad informática'),
  ('Redes y telecomunicaciones'),
  ('Desarrollo móvil'),
  ('Sistemas de información'),
  ('Ciencia de datos e inteligencia artificial');

INSERT INTO recurso_institucional (tipo, nombre, url) VALUES
  ('CALENDARIO_ACADEMICO','Calendario académico 2026-2','https://example.com/calendario-academico-2026-2'),
  ('FORMATO_GRADO','F-DC-124 Propuesta de trabajo de grado','https://example.com/formatos/F-DC-124'),
  ('FORMATO_GRADO','F-DC-125 Informe final de trabajo de grado','https://example.com/formatos/F-DC-125');

-- Usuarios de prueba (contraseñas en texto plano).
INSERT INTO usuario (id_usuario, nombre_completo, id_tipo_documento, numero_documento, contrasena, id_rol, id_nivel_academico) VALUES
  (1,'Carlos Andrés Mejía Ruiz',        1,'1000000001','admin123',   1,NULL),
  (2,'Comité de Trabajos de Grado',     1,'9000000001','comite123',  2,NULL),
  (3,'Laura Marcela Gómez Prada',       1,'1090000101','docente123', 3,NULL),
  (4,'Jorge Iván Rueda Castillo',       1,'1090000102','docente123', 3,NULL),
  (5,'Sandra Milena Ortiz Duarte',      1,'1090000103','docente123', 3,NULL),
  (6,'Andrés Felipe Cáceres León',      1,'1090000104','docente123', 3,NULL),
  (7,'Juan Camilo Pérez Torres',        1,'1100000201','estudiante123',4,1),
  (8,'María Fernanda Suárez Díaz',      1,'1100000202','estudiante123',4,2),
  (9,'Daniel Esteban Prada Rojas',      1,'1100000203','estudiante123',4,2),
  (10,'Valentina Mantilla Cruz',        1,'1100000204','estudiante123',4,1),
  (11,'Juan Camilo Pérez Torres',       1,'1100000205','estudiante123',4,2);

-- Banco de ideas docente: dos disponibles, dos pendientes y una aplazada.
INSERT INTO idea_docente
  (titulo, objetivo, id_linea, id_nivel_academico, id_periodo, id_docente, estado, disponibilidad, acta_numero, motivo_aplazamiento, fecha_revision) VALUES
  ('Sistema de gestión de inventarios con códigos QR',
   'Desarrollar una aplicación web que controle entradas y salidas de inventario mediante lectura de códigos QR.',
   1,1,2,3,'APROBADA','DISPONIBLE','ACTA-001-2026',NULL,NOW()),
  ('Detección de intrusos en redes universitarias con aprendizaje automático',
   'Diseñar un prototipo que identifique tráfico anómalo en la red del campus usando modelos de aprendizaje automático.',
   2,2,2,4,'APROBADA','DISPONIBLE','ACTA-001-2026',NULL,NOW()),
  ('Aplicación móvil para el seguimiento de rutas del transporte universitario',
   'Construir una app móvil que muestre en tiempo real la ubicación de las rutas del transporte universitario.',
   4,1,2,5,'PENDIENTE','NO_DISPONIBLE',NULL,NULL,NULL),
  ('Plataforma web de gestión de prácticas empresariales',
   'Implementar una plataforma para registrar y hacer seguimiento a las prácticas empresariales de los estudiantes.',
   5,2,2,6,'APLAZADA','NO_DISPONIBLE','ACTA-002-2026',
   'El objetivo no es medible; reformular el alcance y los resultados esperados.',NOW()),
  ('Analítica de datos para la deserción estudiantil',
   'Analizar datos académicos para identificar factores asociados a la deserción y proponer alertas tempranas.',
   6,2,2,3,'PENDIENTE','NO_DISPONIBLE',NULL,NULL,NULL);

-- ============================================================================
-- 10. TRIGGERS (reglas del proceso dentro de la base de datos)
--     Los mensajes de error (SQLSTATE 45000) están pensados para mostrarse
--     tal cual en las JSP (requerimiento 18).
--     Nota: en los INSERT hay que enviar siempre las columnas NOT NULL sin
--     valor por defecto (por ejemplo id_fase en entrega, o titulo, descripcion
--     e id_linea en proyecto); el trigger las reemplaza por el valor correcto.
-- ============================================================================
DELIMITER $$

-- 10.1 proyecto, antes de insertar: valida estudiantes, copia los datos de la
--      idea del banco y fija el estado inicial "Fase 1 | Estudiante".
CREATE TRIGGER trg_proyecto_bi BEFORE INSERT ON proyecto
FOR EACH ROW
BEGIN
  DECLARE v_rol      TINYINT UNSIGNED;
  DECLARE v_titulo   VARCHAR(200);
  DECLARE v_objetivo TEXT;
  DECLARE v_linea    INT UNSIGNED;
  DECLARE v_docente  INT UNSIGNED;
  DECLARE v_estado   VARCHAR(20);
  DECLARE v_disp     VARCHAR(20);

  SELECT id_rol INTO v_rol FROM usuario WHERE id_usuario = NEW.id_estudiante1;
  IF v_rol IS NULL OR v_rol <> 4 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estudiante 1 debe ser un usuario con rol Estudiante';
  END IF;

  IF NEW.id_estudiante2 IS NOT NULL THEN
    SET v_rol = NULL;
    SELECT id_rol INTO v_rol FROM usuario WHERE id_usuario = NEW.id_estudiante2;
    IF v_rol IS NULL OR v_rol <> 4 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estudiante 2 debe ser un usuario con rol Estudiante';
    END IF;
  END IF;

  IF NEW.origen = 'BANCO_DOCENTE' THEN
    SELECT titulo, objetivo, id_linea, id_docente, estado, disponibilidad
      INTO v_titulo, v_objetivo, v_linea, v_docente, v_estado, v_disp
      FROM idea_docente WHERE id_idea_docente = NEW.id_idea_docente;
    IF v_estado IS NULL OR v_estado <> 'APROBADA' OR v_disp <> 'DISPONIBLE' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La idea del banco no está aprobada y disponible';
    END IF;
    -- El director es el docente que propuso la idea.
    SET NEW.titulo = v_titulo;
    SET NEW.descripcion = v_objetivo;
    SET NEW.id_linea = v_linea;
    SET NEW.id_director = v_docente;
  ELSE
    SET NEW.id_director = NULL;   -- lo asigna el comité al aprobar la idea
  END IF;

  SET NEW.id_evaluador = NULL;    -- siempre lo asigna el comité
  SET NEW.estado_idea = 'PENDIENTE';
  SET NEW.id_fase = 1;
  SET NEW.id_rol_proceso = 1;
  SET NEW.finalizado = 0;
  SET NEW.radicado = NULL;
  SET NEW.fecha_cierre = NULL;
END$$

-- 10.2 proyecto, después de insertar: la idea del banco deja de estar disponible.
CREATE TRIGGER trg_proyecto_ai AFTER INSERT ON proyecto
FOR EACH ROW
BEGIN
  IF NEW.origen = 'BANCO_DOCENTE' THEN
    UPDATE idea_docente SET disponibilidad = 'NO_DISPONIBLE'
    WHERE id_idea_docente = NEW.id_idea_docente;
  END IF;
END$$

-- 10.3 proyecto, antes de actualizar: proyecto finalizado, docentes,
--      evaluador distinto del director, cambios de fase válidos y pago.
CREATE TRIGGER trg_proyecto_bu BEFORE UPDATE ON proyecto
FOR EACH ROW
BEGIN
  DECLARE v_rol TINYINT UNSIGNED;
  DECLARE v_n   INT;

  IF OLD.finalizado = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto está finalizado y no puede gestionarse';
  END IF;

  IF NEW.id_director IS NOT NULL AND NOT (NEW.id_director <=> OLD.id_director) THEN
    SET v_rol = NULL;
    SELECT id_rol INTO v_rol FROM usuario WHERE id_usuario = NEW.id_director;
    IF v_rol IS NULL OR v_rol <> 3 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El director debe ser un usuario con rol Docente';
    END IF;
  END IF;

  IF NEW.id_evaluador IS NOT NULL AND NOT (NEW.id_evaluador <=> OLD.id_evaluador) THEN
    SET v_rol = NULL;
    SELECT id_rol INTO v_rol FROM usuario WHERE id_usuario = NEW.id_evaluador;
    IF v_rol IS NULL OR v_rol <> 3 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El evaluador debe ser un usuario con rol Docente';
    END IF;
  END IF;

  IF NEW.id_evaluador IS NOT NULL AND NEW.id_director IS NOT NULL
     AND NEW.id_evaluador = NEW.id_director THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El evaluador no puede ser el director del proyecto';
  END IF;

  -- La fase y el turno solo cambian siguiendo la tabla transicion_fase.
  IF NEW.id_fase <> OLD.id_fase OR NEW.id_rol_proceso <> OLD.id_rol_proceso THEN
    SELECT COUNT(*) INTO v_n FROM transicion_fase
    WHERE id_fase_origen = OLD.id_fase AND id_rol_origen = OLD.id_rol_proceso
      AND id_fase_destino = NEW.id_fase AND id_rol_destino = NEW.id_rol_proceso;
    IF v_n = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cambio de fase no permitido desde el estado actual';
    END IF;
  END IF;

  -- Al reenviar la idea al comité vuelve a quedar pendiente.
  IF OLD.id_fase = 1 AND OLD.id_rol_proceso = 1 AND NEW.id_rol_proceso = 4 THEN
    SET NEW.estado_idea = 'PENDIENTE';
  END IF;

  -- Una idea solo se aprueba si tiene soporte de pago.
  IF NEW.estado_idea = 'APROBADA' AND OLD.estado_idea <> 'APROBADA' THEN
    SELECT COUNT(*) INTO v_n FROM entrega
    WHERE id_proyecto = OLD.id_proyecto AND tipo = 'SOPORTE_PAGO';
    IF v_n = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede aprobar la idea sin soporte de pago';
    END IF;
  END IF;
END$$

-- 10.4 entrega, antes de insertar: solo el estudiante 1, solo en su turno,
--      tipo de documento acorde a la fase, y versión automática.
CREATE TRIGGER trg_entrega_bi BEFORE INSERT ON entrega
FOR EACH ROW
BEGIN
  DECLARE v_fase TINYINT UNSIGNED;
  DECLARE v_rol  TINYINT UNSIGNED;
  DECLARE v_fin  TINYINT(1);
  DECLARE v_est1 INT UNSIGNED;
  DECLARE v_ver  INT UNSIGNED;

  SELECT id_fase, id_rol_proceso, finalizado, id_estudiante1
    INTO v_fase, v_rol, v_fin, v_est1
    FROM proyecto WHERE id_proyecto = NEW.id_proyecto;

  IF v_fin IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto no existe';
  END IF;
  IF v_fin = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto está finalizado y no admite documentos';
  END IF;
  IF v_rol <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden cargar documentos cuando el estado del proyecto indica Estudiante';
  END IF;
  IF NEW.id_usuario <> v_est1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el estudiante que creó el proyecto puede cargar documentos';
  END IF;

  IF (NEW.tipo IN ('IDEA','SOPORTE_PAGO') AND v_fase <> 1)
     OR (NEW.tipo = 'PROPUESTA' AND v_fase NOT IN (2,3))
     OR (NEW.tipo IN ('INFORME','MANUAL_USUARIO','MANUAL_TECNICO','REPOSITORIO') AND v_fase NOT IN (4,5)) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este tipo de documento no corresponde a la fase actual del proyecto';
  END IF;

  SELECT COALESCE(MAX(numero_version), 0) + 1 INTO v_ver
    FROM entrega WHERE id_proyecto = NEW.id_proyecto AND tipo = NEW.tipo;
  SET NEW.id_fase = v_fase;
  SET NEW.numero_version = v_ver;
END$$

-- 10.5 revision, antes de insertar: turno, revisor correcto, comentarios,
--      acta en la fase 1 y radicado en la fase 6.
CREATE TRIGGER trg_revision_bi BEFORE INSERT ON revision
FOR EACH ROW
BEGIN
  DECLARE v_fase  TINYINT UNSIGNED;
  DECLARE v_rol   TINYINT UNSIGNED;
  DECLARE v_fin   TINYINT(1);
  DECLARE v_dir   INT UNSIGNED;
  DECLARE v_eva   INT UNSIGNED;
  DECLARE v_rolu  TINYINT UNSIGNED;
  DECLARE v_n     INT;

  SELECT id_fase, id_rol_proceso, finalizado, id_director, id_evaluador
    INTO v_fase, v_rol, v_fin, v_dir, v_eva
    FROM proyecto WHERE id_proyecto = NEW.id_proyecto;

  IF v_fin IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto no existe';
  END IF;
  IF v_fin = 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proyecto está finalizado y no puede gestionarse';
  END IF;
  IF NEW.id_fase <> v_fase OR NEW.id_rol_proceso <> v_rol THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No es el turno de este rol en la fase actual del proyecto';
  END IF;

  IF NEW.id_rol_proceso = 2 AND (v_dir IS NULL OR NEW.id_revisor <> v_dir) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el director asignado puede calificar en este turno';
  END IF;
  IF NEW.id_rol_proceso = 3 AND (v_eva IS NULL OR NEW.id_revisor <> v_eva) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el evaluador asignado puede calificar en este turno';
  END IF;
  IF NEW.id_rol_proceso = 4 THEN
    SELECT id_rol INTO v_rolu FROM usuario WHERE id_usuario = NEW.id_revisor;
    IF v_rolu IS NULL OR v_rolu <> 2 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo el usuario Comité puede calificar en este turno';
    END IF;
  END IF;

  SELECT COUNT(*) INTO v_n FROM transicion_fase
  WHERE id_fase_origen = NEW.id_fase AND id_rol_origen = NEW.id_rol_proceso
    AND accion = CASE WHEN NEW.resultado = 'APROBADO' THEN 'APROBADO' ELSE 'APLAZADO' END;
  IF v_n = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta calificación no está permitida en la fase actual';
  END IF;

  IF NEW.comentarios IS NULL OR TRIM(NEW.comentarios) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los comentarios son obligatorios';
  END IF;

  IF NEW.id_fase = 1 AND NEW.id_rol_proceso = 4 THEN
    IF NEW.acta_numero IS NULL OR TRIM(NEW.acta_numero) = '' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de acta es obligatorio';
    END IF;
    IF NEW.resultado = 'APROBADO' AND (v_dir IS NULL OR v_eva IS NULL) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Asigne el director y el evaluador antes de aprobar la idea';
    END IF;
  END IF;

  IF NEW.id_fase = 6 AND NEW.resultado = 'APROBADO'
     AND (NEW.radicado IS NULL OR TRIM(NEW.radicado) = '') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El radicado es obligatorio para cerrar el proyecto';
  END IF;
END$$

-- 10.6 revision, después de insertar: cambia solo la fase y el turno
--      (requerimiento 3), actualiza el estado de la idea en la fase 1 y cierra
--      el proyecto en la fase 6.
CREATE TRIGGER trg_revision_ai AFTER INSERT ON revision
FOR EACH ROW
BEGIN
  DECLARE v_fase TINYINT UNSIGNED;
  DECLARE v_rol  TINYINT UNSIGNED;
  DECLARE v_fin  TINYINT(1);

  SELECT id_fase_destino, id_rol_destino, finaliza
    INTO v_fase, v_rol, v_fin
    FROM transicion_fase
   WHERE id_fase_origen = NEW.id_fase AND id_rol_origen = NEW.id_rol_proceso
     AND accion = CASE WHEN NEW.resultado = 'APROBADO' THEN 'APROBADO' ELSE 'APLAZADO' END;

  IF v_fin = 1 THEN
    UPDATE proyecto
       SET finalizado = 1, radicado = NEW.radicado, fecha_cierre = NOW()
     WHERE id_proyecto = NEW.id_proyecto;
  ELSE
    UPDATE proyecto
       SET id_fase = v_fase,
           id_rol_proceso = v_rol,
           estado_idea = CASE
             WHEN NEW.id_fase = 1 AND NEW.id_rol_proceso = 4
               THEN CASE WHEN NEW.resultado = 'APROBADO' THEN 'APROBADA' ELSE 'APLAZADA' END
             ELSE estado_idea END
     WHERE id_proyecto = NEW.id_proyecto;
  END IF;
END$$

DELIMITER ;

-- ============================================================================
-- 11. CONSULTAS DE EJEMPLO PARA LAS PÁGINAS JSP (comentadas; ? = parámetro)
-- ============================================================================
-- Inicio de sesión (documento + contraseña + rol):
--   SELECT u.id_usuario, u.nombre_completo, r.nombre AS rol
--   FROM usuario u JOIN rol r ON r.id_rol = u.id_rol
--   WHERE u.numero_documento = ? AND u.contrasena = ? AND u.id_rol = ?;
--
-- Lista de usuarios de prueba y sus claves:
--   SELECT r.nombre AS rol, u.nombre_completo, u.numero_documento, u.contrasena
--   FROM usuario u JOIN rol r ON r.id_rol = u.id_rol ORDER BY u.id_rol, u.id_usuario;
--
-- Administrador: listar usuarios con tipo de documento, rol y nivel:
--   SELECT u.id_usuario, u.nombre_completo, td.sigla, u.numero_documento, r.nombre AS rol, na.nombre AS nivel
--   FROM usuario u JOIN tipo_documento td ON td.id_tipo_documento = u.id_tipo_documento
--   JOIN rol r ON r.id_rol = u.id_rol LEFT JOIN nivel_academico na ON na.id_nivel_academico = u.id_nivel_academico;
--
-- Eliminar usuario: DELETE FROM usuario WHERE id_usuario = ?;
--   Si tiene proyectos o ideas, MySQL devuelve el error 1451 (llave foránea):
--   mostrar "No se puede eliminar un usuario que tiene proyectos asociados".
--
-- Estudiante: banco de ideas disponibles:
--   SELECT * FROM v_idea_docente WHERE estado = 'APROBADA' AND disponibilidad = 'DISPONIBLE';
-- Estudiante: segundo estudiante (lista desplegable, sin el estudiante 1):
--   SELECT id_usuario, nombre_completo, numero_documento FROM usuario WHERE id_rol = 4 AND id_usuario <> ?;
-- Estudiante: su proyecto (solo el estudiante 1 lo ve; sin evaluador):
--   SELECT * FROM v_proyecto_estudiante WHERE id_estudiante1 = ?;
-- Puede cargar documentos solo si el turno es del estudiante:
--   SELECT 1 FROM proyecto WHERE id_proyecto = ? AND id_estudiante1 = ? AND id_rol_proceso = 1 AND finalizado = 0;
-- Crear proyecto con una idea del banco (el trigger copia título, objetivo, línea
-- y director de la idea y la marca como No disponible; aun así envía esos campos):
--   INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director)
--   VALUES ('BANCO_DOCENTE', ?, ?, ?, ?, ?, ?, ?);
-- Crear proyecto con idea propia (director y evaluador quedan vacíos hasta que el comité los asigne):
--   INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2)
--   VALUES ('PROPIA', ?, ?, ?, ?, ?);
-- Nueva versión de un documento (el trigger valida el turno y calcula la versión):
--   INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (?, ?, ?, ?, ?);
-- El estudiante envía a revisión (siguiente estado según transicion_fase con accion 'ENVIAR'):
--   SELECT id_fase_destino, id_rol_destino FROM transicion_fase
--   WHERE id_fase_origen = ? AND id_rol_origen = 1 AND accion = 'ENVIAR';
--   UPDATE proyecto SET id_fase = ?, id_rol_proceso = ? WHERE id_proyecto = ?;
--
-- Docente: vista única "Mis proyectos" con la columna "Mi rol":
--   SELECT v.*, CASE WHEN v.id_director = ? THEN 'Director' ELSE 'Evaluador' END AS mi_rol
--   FROM v_proyecto v WHERE v.id_director = ? OR v.id_evaluador = ?;
--   Botón "Gestionar fases" habilitado si finalizado = 0 y rol_turno = mi_rol.
-- Docente: ideas que propuso:
--   SELECT * FROM v_idea_docente WHERE id_docente = ?;
-- Evaluadores elegibles al asignar (excluye al director del proyecto):
--   SELECT id_usuario, nombre_completo FROM usuario WHERE id_rol = 3 AND id_usuario <> ?;
--
-- Comité: ideas de docentes pendientes, ideas de estudiantes y proyectos:
--   SELECT * FROM v_idea_docente WHERE estado = 'PENDIENTE';
--   SELECT * FROM v_idea_estudiante;
--   SELECT * FROM v_proyecto;       -- botón habilitado si rol_turno = 'Comité' y finalizado = 0
--
-- Comité (fase 1): asignar director y evaluador antes de aprobar la idea:
--   UPDATE proyecto SET id_director = ?, id_evaluador = ? WHERE id_proyecto = ?;
--   (en ideas del banco el director ya viene de la idea: asigna solo el evaluador)
-- Al calificar solo se inserta la revisión: los triggers validan el turno y el
-- revisor, y cambian la fase, el turno, el estado de la idea y el cierre solos:
--   INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado)
--   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
--   (acta_numero solo en la fase 1; radicado solo al aprobar el cierre en la fase 6;
--    en las demás fases van como NULL)
--
-- Seguimiento de fases (las seis, con la actual resaltada):
--   SELECT f.id_fase, f.nombre, (f.id_fase = p.id_fase) AS actual
--   FROM fase f CROSS JOIN proyecto p WHERE p.id_proyecto = ? ORDER BY f.id_fase;
-- Historial:
--   SELECT * FROM v_historial_entregas WHERE id_proyecto = ? ORDER BY fecha_entrega;
--   SELECT * FROM v_historial_revisiones WHERE id_proyecto = ? ORDER BY fecha_revision;
