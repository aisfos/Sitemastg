-- ============================================================================
--  datos_demo.sql - Conjunto de datos de demostracion de Sistemas TG
--  (M9-E parte A; requerimientos 22 y 85).
--
--  Se cargan ENCIMA del baseline (docs/sistemas_tg.sql: 11 usuarios, 5 ideas y
--  0 proyectos) y se quitan con quitar_demo.sql, que deja la base identica al
--  baseline. El guion oficial (docs/guion-demostracion.md) parte del baseline,
--  sin estos datos.
--
--  Todo se inserta igual que lo haria la aplicacion, de modo que los triggers
--  validan y calculan lo mismo:
--    * INSERT en proyecto -> trg_proyecto_bi / trg_proyecto_ai
--    * INSERT en entrega  -> trg_entrega_bi (numero_version automatico)
--    * INSERT en revision -> trg_revision_bi / trg_revision_ai
--    * UPDATE de turno    -> transicion_fase (accion ENVIAR)
--  Nunca se asignan a mano id_fase, id_rol_proceso, estado_idea ni
--  numero_version: los pone la base de datos.
--
--  Cargar (MySQL/MariaDB de XAMPP, desde cmd):
--    cmd /c "C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 sistemas_tg < C:\sistemastg-tests\datos_demo.sql"
--  Quitar:
--    cmd /c "C:\xampp\mysql\bin\mysql.exe -u root sistemas_tg < C:\sistemastg-tests\quitar_demo.sql"
--
--  Si ya hay datos de demostracion cargados, ejecuta primero quitar_demo.sql.
-- ============================================================================

USE sistemas_tg;

-- ---------------------------------------------------------------------------
-- 1. USUARIOS NUEVOS (ids 12 a 32). No se crean administradores ni comite
--    (req. 22 y 71). 6 docentes (12..17) y 15 estudiantes (18..32), todos con
--    cedula (CC). Los estudiantes 18 y 32 son homonimos (req. 88).
-- ---------------------------------------------------------------------------
INSERT INTO usuario (id_usuario, nombre_completo, id_tipo_documento, numero_documento, contrasena, id_rol, id_nivel_academico) VALUES
  (12,'Álvaro José Restrepo Cano',     1,'1090000105','docente123',   3,NULL),
  (13,'Diana Carolina Salazar Ríos',   1,'1090000106','docente123',   3,NULL),
  (14,'Felipe Andrés Ocampo Vélez',    1,'1090000107','docente123',   3,NULL),
  (15,'Mónica Patricia Agudelo Lara',  1,'1090000108','docente123',   3,NULL),
  (16,'Julián Esteban Cárdenas Mora',  1,'1090000109','docente123',   3,NULL),
  (17,'Natalia Andrea Bustamante Gil', 1,'1090000110','docente123',   3,NULL),
  (18,'María Fernanda Quintero Soto',  1,'1100000206','estudiante123',4,2),
  (19,'Andrés Felipe Villalba Ríos',   1,'1100000207','estudiante123',4,1),
  (20,'Laura Valentina Céspedes Mora', 1,'1100000208','estudiante123',4,2),
  (21,'Juan Pablo Herrera Nieto',      1,'1100000209','estudiante123',4,1),
  (22,'Sara Milena Ortega Prada',      1,'1100000210','estudiante123',4,2),
  (23,'Camilo Andrés Beltrán Ruiz',    1,'1100000211','estudiante123',4,1),
  (24,'Ana Sofía Moreno Cadena',       1,'1100000212','estudiante123',4,2),
  (25,'Diego Alejandro Peña Suárez',   1,'1100000213','estudiante123',4,1),
  (26,'Isabella Ramírez Galeano',      1,'1100000214','estudiante123',4,2),
  (27,'Santiago López Villamil',       1,'1100000215','estudiante123',4,1),
  (28,'Valentina Gómez Estrada',       1,'1100000216','estudiante123',4,2),
  (29,'Julián David Castaño Ríos',     1,'1100000217','estudiante123',4,1),
  (30,'Mariana Torres Aguirre',        1,'1100000218','estudiante123',4,2),
  (31,'Sebastián Ruiz Camacho',        1,'1100000219','estudiante123',4,1),
  (32,'María Fernanda Quintero Soto',  1,'1100000220','estudiante123',4,2);

-- ---------------------------------------------------------------------------
-- 2. BANCO DE IDEAS: 13 ideas nuevas (ids 6 a 18) para completar 18.
--    Estado y acta como los dejaria el comite (req. 50, 51). La disponibilidad
--    de las que ya tomo un proyecto la cambia el trigger trg_proyecto_ai; por
--    eso las que se usan mas abajo se insertan DISPONIBLE.
-- ---------------------------------------------------------------------------
INSERT INTO idea_docente
  (id_idea_docente, titulo, objetivo, id_linea, id_nivel_academico, id_periodo, id_docente,
   estado, disponibilidad, acta_numero, motivo_aplazamiento, fecha_propuesta, fecha_revision) VALUES
  (6,'Monitorización de la calidad del enlace inalámbrico en el campus',
     'Implementar un tablero que mida la calidad y la disponibilidad del enlace inalámbrico en las sedes del campus.',
     3,1,2,12,'APROBADA','DISPONIBLE','ACTA-010-2026',NULL,'2026-08-10 08:30:00','2026-08-14 10:00:00'),
  (7,'Aplicación móvil para el reporte de daños en la infraestructura del campus',
     'Desarrollar una aplicación móvil que permita reportar y hacer seguimiento a los daños de la infraestructura del campus.',
     4,2,2,13,'APROBADA','DISPONIBLE','ACTA-011-2026',NULL,'2026-08-11 09:00:00','2026-08-15 10:00:00'),
  (8,'Modelo de predicción de la deserción por asignatura',
     'Construir un modelo que identifique las asignaturas con mayor riesgo de deserción a partir de los datos históricos.',
     6,2,1,13,'APROBADA','DISPONIBLE','ACTA-012-2026',NULL,'2026-08-11 11:00:00','2026-08-15 11:30:00'),
  (9,'Repositorio institucional de trabajos de grado con búsqueda avanzada',
     'Implementar un repositorio que catalogue los trabajos de grado y permita búsquedas por línea, nivel y periodo.',
     1,2,2,16,'APROBADA','DISPONIBLE','ACTA-013-2026',NULL,'2026-08-12 08:00:00','2026-08-16 09:00:00'),
  (10,'Panel de indicadores para el seguimiento de la permanencia estudiantil',
     'Diseñar un panel de indicadores que apoye el seguimiento de la permanencia de los estudiantes.',
     5,1,3,14,'APROBADA','DISPONIBLE','ACTA-014-2026',NULL,'2026-08-12 10:00:00','2026-08-16 11:00:00'),
  (11,'Doble factor de autenticación para los servicios institucionales',
     'Evaluar e implementar un esquema de doble factor de autenticación para los servicios institucionales.',
     2,2,2,15,'APROBADA','DISPONIBLE','ACTA-015-2026',NULL,'2026-08-13 09:00:00','2026-08-17 10:00:00'),
  (12,'Inventario automatizado de equipos de red con monitoreo básico',
     'Automatizar el inventario de los equipos de red y su estado de disponibilidad.',
     3,1,3,17,'APROBADA','DISPONIBLE','ACTA-016-2026',NULL,'2026-08-13 11:00:00','2026-08-17 12:00:00'),
  (13,'Aplicación móvil para la consulta del horario académico y las aulas',
     'Desarrollar una aplicación móvil que consulte el horario académico y la ubicación de las aulas.',
     4,1,2,3,'APROBADA','DISPONIBLE','ACTA-017-2026',NULL,'2026-08-14 08:00:00','2026-08-18 09:00:00'),
  (14,'Análisis de datos para la optimización del consumo energético en laboratorios',
     'Analizar los datos de consumo energético de los laboratorios para proponer recomendaciones de ahorro.',
     6,1,2,4,'APROBADA','DISPONIBLE','ACTA-018-2026',NULL,'2026-08-14 10:00:00','2026-08-18 11:00:00'),
  (15,'Automatización de pruebas para los servicios web institucionales',
     'Proponer una estrategia de pruebas automatizadas para los servicios web institucionales.',
     1,2,2,12,'PENDIENTE','NO_DISPONIBLE',NULL,NULL,'2026-08-18 09:00:00',NULL),
  (16,'Sistema de trazabilidad documental para los procesos académicos',
     'Diseñar un sistema que registre la trazabilidad de los documentos de los procesos académicos.',
     5,2,3,5,'PENDIENTE','NO_DISPONIBLE',NULL,NULL,'2026-08-19 09:30:00',NULL),
  (17,'Buenas prácticas de seguridad para el desarrollo de software académico',
     'Definir una guía de buenas prácticas de seguridad aplicable a los desarrollos académicos.',
     2,1,2,16,'PENDIENTE','NO_DISPONIBLE',NULL,NULL,'2026-08-20 08:30:00',NULL),
  (18,'Sistema de trazabilidad de solicitudes del proceso de grado',
     'Diseñar un sistema que registre la trazabilidad de las solicitudes del proceso de grado.',
     5,2,2,6,'APLAZADA','NO_DISPONIBLE','ACTA-019-2026',
     'El alcance propuesto es demasiado amplio para un solo proyecto: conviene limitarlo a una sola solicitud y volver a presentarlo.',
     '2026-08-17 09:00:00','2026-08-21 10:00:00');

-- ---------------------------------------------------------------------------
-- 3. PROYECTOS (14 estados distintos). Cada bloque reproduce el recorrido real
--    por la aplicacion: crear proyecto, cargar documentos en el turno del
--    estudiante, enviar a revision y calificar con revision. Los destinos de la
--    transicion ENVIAR se leen de la tabla transicion_fase.
-- ---------------------------------------------------------------------------
SET @f1=NULL, @r1=NULL, @f2=NULL, @r2=NULL, @f3=NULL, @r3=NULL, @f4=NULL, @r4=NULL, @f5=NULL, @r5=NULL;
SELECT id_fase_destino, id_rol_destino INTO @f1, @r1 FROM transicion_fase WHERE id_fase_origen=1 AND id_rol_origen=1 AND accion='ENVIAR';
SELECT id_fase_destino, id_rol_destino INTO @f2, @r2 FROM transicion_fase WHERE id_fase_origen=2 AND id_rol_origen=1 AND accion='ENVIAR';
SELECT id_fase_destino, id_rol_destino INTO @f3, @r3 FROM transicion_fase WHERE id_fase_origen=3 AND id_rol_origen=1 AND accion='ENVIAR';
SELECT id_fase_destino, id_rol_destino INTO @f4, @r4 FROM transicion_fase WHERE id_fase_origen=4 AND id_rol_origen=1 AND accion='ENVIAR';
SELECT id_fase_destino, id_rol_destino INTO @f5, @r5 FROM transicion_fase WHERE id_fase_origen=5 AND id_rol_origen=1 AND accion='ENVIAR';

-- P1 - "Fase 1 | Comité" (idea propia). Estudiante 18 con segundo estudiante 19.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Plataforma web para el control de préstamos de equipos de laboratorio',
   'Desarrollar una plataforma web que registre y controle el préstamo y la devolución de los equipos de laboratorio.',
   5,18,19,'2026-08-25 09:15:00');
SET @p1 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p1,1,'SOPORTE_PAGO','https://example.com/demo/p1-pago',18,'2026-08-25 09:40:00');
SET @sp1 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p1;

-- P2 - "Fase 1 | Comité" (idea del banco, idea 6). Estudiante 19.
INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director, fecha_creacion) VALUES
  ('BANCO_DOCENTE',6,'Monitorización de la calidad del enlace inalámbrico en el campus',
   'Implementar un tablero que mida la calidad y la disponibilidad del enlace inalámbrico en las sedes del campus.',
   3,19,NULL,12,'2026-08-26 10:05:00');
SET @p2 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p2,1,'SOPORTE_PAGO','https://example.com/demo/p2-pago',19,'2026-08-26 10:30:00');
SET @sp2 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p2;

-- P3 - "Fase 1 | Estudiante" con la idea aplazada por el comité. Estudiante 20.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Sistema de reserva de salas de estudio para la biblioteca',
   'Desarrollar un sistema que permita reservar las salas de estudio de la biblioteca y controlar su ocupación.',
   5,20,NULL,'2026-08-27 08:50:00');
SET @p3 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p3,1,'SOPORTE_PAGO','https://example.com/demo/p3-pago',20,'2026-08-27 09:10:00');
SET @sp3 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p3;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p3,1,4,2,@sp3,'APLAZADO',
   'La idea es pertinente, pero el alcance debe acotarse y el soporte de pago debe volver a cargarse antes de asignar director y evaluador.',
   'ACTA-020-2026',NULL,'2026-08-29 11:00:00');

-- P4 - "Fase 2 | Estudiante" recién aprobado (idea del banco, idea 7). Estudiante 21.
INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director, fecha_creacion) VALUES
  ('BANCO_DOCENTE',7,'Aplicación móvil para el reporte de daños en la infraestructura del campus',
   'Desarrollar una aplicación móvil que permita reportar y hacer seguimiento a los daños de la infraestructura del campus.',
   4,21,NULL,13,'2026-08-28 09:00:00');
SET @p4 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p4,1,'SOPORTE_PAGO','https://example.com/demo/p4-pago',21,'2026-08-28 09:20:00');
SET @sp4 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p4;
UPDATE proyecto SET id_evaluador=14 WHERE id_proyecto=@p4 AND id_fase=1 AND id_rol_proceso=4 AND finalizado=0;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p4,1,4,2,@sp4,'APROBADO','Idea aprobada. Se asigna como evaluadora a la docente Diana Carolina Salazar.','ACTA-021-2026',NULL,'2026-08-30 10:30:00');

-- P5 - "Fase 2 | Estudiante" tras un aplazamiento del director. Estudiante 22 con estudiante 23.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Herramienta de gestión de semilleros de investigación',
   'Construir una herramienta que registre los semilleros de investigación, sus integrantes y sus productos.',
   1,22,23,'2026-08-29 10:00:00');
SET @p5 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p5,1,'SOPORTE_PAGO','https://example.com/demo/p5-pago',22,'2026-08-29 10:20:00');
SET @sp5 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p5;
UPDATE proyecto SET id_director=12, id_evaluador=13 WHERE id_proyecto=@p5;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p5,1,4,2,@sp5,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-022-2026',NULL,'2026-08-31 09:30:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p5,2,'PROPUESTA','https://example.com/demo/p5-propuesta-v1',22,'2026-09-02 10:00:00');
SET @pr5 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p5;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p5,2,2,12,@pr5,'APLAZADO','El alcance no coincide con el objetivo: precisa reorganizar los objetivos específicos y la metodología.',
   NULL,NULL,'2026-09-05 11:00:00');

-- P6 - "Fase 2 | Director". Estudiante 23.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Aplicación web para el seguimiento de prácticas empresariales',
   'Implementar una aplicación que haga seguimiento a las prácticas empresariales de los estudiantes.',
   3,23,NULL,'2026-08-30 09:00:00');
SET @p6 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p6,1,'SOPORTE_PAGO','https://example.com/demo/p6-pago',23,'2026-08-30 09:20:00');
SET @sp6 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p6;
UPDATE proyecto SET id_director=13, id_evaluador=12 WHERE id_proyecto=@p6;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p6,1,4,2,@sp6,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-023-2026',NULL,'2026-09-01 10:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p6,2,'PROPUESTA','https://example.com/demo/p6-propuesta-v1',23,'2026-09-03 09:30:00');
SET @pr6 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p6;

-- P7 - "Fase 3 | Evaluador". Estudiante 24.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Sistema de alertas tempranas para el rendimiento académico',
   'Diseñar un sistema que genere alertas tempranas con base en el rendimiento académico de los estudiantes.',
   4,24,NULL,'2026-08-31 09:00:00');
SET @p7 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p7,1,'SOPORTE_PAGO','https://example.com/demo/p7-pago',24,'2026-08-31 09:20:00');
SET @sp7 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p7;
UPDATE proyecto SET id_director=14, id_evaluador=15 WHERE id_proyecto=@p7;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p7,1,4,2,@sp7,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-024-2026',NULL,'2026-09-02 10:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p7,2,'PROPUESTA','https://example.com/demo/p7-propuesta-v1',24,'2026-09-04 09:30:00');
SET @pr7 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p7;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p7,2,2,14,@pr7,'APROBADO','La propuesta es clara y viable; se aprueba para la revisión del evaluador.',
   NULL,NULL,'2026-09-08 10:30:00');

-- P8 - "Fase 3 | Comité" con la propuesta corregida (v2). Estudiante 25 con segundo estudiante 26.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Portal de proyectos de aula con seguimiento del docente',
   'Desarrollar un portal que registre los proyectos de aula y permita al docente hacer su seguimiento.',
   6,25,26,'2026-09-01 09:00:00');
SET @p8 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p8,1,'SOPORTE_PAGO','https://example.com/demo/p8-pago',25,'2026-09-01 09:20:00');
SET @sp8 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p8;
UPDATE proyecto SET id_director=15, id_evaluador=14 WHERE id_proyecto=@p8;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p8,1,4,2,@sp8,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-025-2026',NULL,'2026-09-03 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p8,2,'PROPUESTA','https://example.com/demo/p8-propuesta-v1',25,'2026-09-05 09:30:00');
SET @pr8a = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p8;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p8,2,2,15,@pr8a,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-09 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p8,3,3,14,@pr8a,'APLAZADO','Falta precisar los indicadores de resultado y el cronograma; se solicita una version corregida.',
   NULL,NULL,'2026-09-11 10:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p8,3,'PROPUESTA','https://example.com/demo/p8-propuesta-v2',25,'2026-09-13 09:30:00');
SET @pr8b = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f3, id_rol_proceso=@r3 WHERE id_proyecto=@p8;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p8,3,3,14,@pr8b,'APROBADO','La versión corregida atiende las observaciones; se aprueba.',
   NULL,NULL,'2026-09-16 10:00:00');

-- P9 - "Fase 4 | Estudiante" (idea del banco, idea 9). Estudiante 26.
INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director, fecha_creacion) VALUES
  ('BANCO_DOCENTE',9,'Repositorio institucional de trabajos de grado con búsqueda avanzada',
   'Implementar un repositorio que catalogue los trabajos de grado y permita búsquedas por línea, nivel y periodo.',
   1,26,NULL,16,'2026-09-02 09:00:00');
SET @p9 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p9,1,'SOPORTE_PAGO','https://example.com/demo/p9-pago',26,'2026-09-02 09:20:00');
SET @sp9 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p9;
UPDATE proyecto SET id_evaluador=17 WHERE id_proyecto=@p9;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p9,1,4,2,@sp9,'APROBADO','Idea aprobada; se asigna la evaluación.',
   'ACTA-026-2026',NULL,'2026-09-04 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p9,2,'PROPUESTA','https://example.com/demo/p9-propuesta-v1',26,'2026-09-06 09:30:00');
SET @pr9 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p9;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p9,2,2,16,@pr9,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-09 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p9,3,3,17,@pr9,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-12 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p9,3,4,2,@pr9,'APROBADO','La propuesta cumple los criterios; se aprueba el paso a la fase de informe.',
   'ACTA-027-2026',NULL,'2026-09-14 11:00:00');

-- P10 - "Fase 4 | Director". Estudiante 27.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Control de inventario de activos fijos de la institución',
   'Implementar un control de inventario para los activos fijos con códigos de identificación.',
   3,27,NULL,'2026-09-03 09:00:00');
SET @p10 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p10,1,'SOPORTE_PAGO','https://example.com/demo/p10-pago',27,'2026-09-03 09:20:00');
SET @sp10 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p10;
UPDATE proyecto SET id_director=17, id_evaluador=16 WHERE id_proyecto=@p10;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p10,1,4,2,@sp10,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-028-2026',NULL,'2026-09-05 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p10,2,'PROPUESTA','https://example.com/demo/p10-propuesta-v1',27,'2026-09-07 09:30:00');
SET @pr10 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p10;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p10,2,2,17,@pr10,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-10 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p10,3,3,16,@pr10,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-13 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p10,3,4,2,@pr10,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-029-2026',NULL,'2026-09-15 11:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p10,4,'INFORME','https://example.com/demo/p10-informe-v1',27,'2026-09-17 09:30:00');
SET @in10 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p10;

-- P11 - "Fase 5 | Evaluador". Estudiante 28.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Sistema de encuestas académicas con tablero de resultados',
   'Construir un sistema de encuestas académicas que presente un tablero con los resultados.',
   4,28,NULL,'2026-09-02 09:00:00');
SET @p11 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p11,1,'SOPORTE_PAGO','https://example.com/demo/p11-pago',28,'2026-09-02 09:20:00');
SET @sp11 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p11;
UPDATE proyecto SET id_director=3, id_evaluador=5 WHERE id_proyecto=@p11;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p11,1,4,2,@sp11,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-030-2026',NULL,'2026-09-04 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p11,2,'PROPUESTA','https://example.com/demo/p11-propuesta-v1',28,'2026-09-06 09:30:00');
SET @pr11 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p11;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p11,2,2,3,@pr11,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-09 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p11,3,3,5,@pr11,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-12 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p11,3,4,2,@pr11,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-031-2026',NULL,'2026-09-14 11:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p11,4,'INFORME','https://example.com/demo/p11-informe-v1',28,'2026-09-16 09:30:00');
SET @in11 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p11;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p11,4,2,3,@in11,'APROBADO','El informe cumple; se remite al evaluador.',
   NULL,NULL,'2026-09-19 10:00:00');

-- P12 - "Fase 5 | Comité" con el informe corregido (v2). Estudiante 29.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Gestión documental del proceso de matrícula',
   'Diseñar una solución que organice y dé trazabilidad a los documentos del proceso de matrícula.',
   6,29,NULL,'2026-09-02 10:00:00');
SET @p12 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p12,1,'SOPORTE_PAGO','https://example.com/demo/p12-pago',29,'2026-09-02 10:20:00');
SET @sp12 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p12;
UPDATE proyecto SET id_director=5, id_evaluador=3 WHERE id_proyecto=@p12;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,1,4,2,@sp12,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-032-2026',NULL,'2026-09-04 09:30:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p12,2,'PROPUESTA','https://example.com/demo/p12-propuesta-v1',29,'2026-09-06 10:00:00');
SET @pr12 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p12;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,2,2,5,@pr12,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-09 10:30:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,3,3,3,@pr12,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-12 10:30:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,3,4,2,@pr12,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-033-2026',NULL,'2026-09-14 11:30:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p12,4,'INFORME','https://example.com/demo/p12-informe-v1',29,'2026-09-16 10:00:00');
SET @in12a = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p12;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,4,2,5,@in12a,'APROBADO','Informe aprobado por el director.',
   NULL,NULL,'2026-09-19 10:30:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,5,3,3,@in12a,'APLAZADO','Faltan los anexos de manual técnico y la discusión de resultados; se solicita una versión corregida.',
   NULL,NULL,'2026-09-21 10:30:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p12,5,'INFORME','https://example.com/demo/p12-informe-v2',29,'2026-09-23 10:00:00');
SET @in12b = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f5, id_rol_proceso=@r5 WHERE id_proyecto=@p12;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p12,5,3,3,@in12b,'APROBADO','La versión corregida atiende las observaciones; se aprueba.',
   NULL,NULL,'2026-09-25 10:30:00');

-- P13 - "Fase 6 | Comité". Estudiante 30 con segundo estudiante 31.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Aplicación móvil para la orientación en el campus',
   'Desarrollar una aplicación móvil que oriente a los visitantes y estudiantes dentro del campus.',
   1,30,31,'2026-09-03 09:00:00');
SET @p13 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p13,1,'SOPORTE_PAGO','https://example.com/demo/p13-pago',30,'2026-09-03 09:20:00');
SET @sp13 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p13;
UPDATE proyecto SET id_director=4, id_evaluador=6 WHERE id_proyecto=@p13;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,1,4,2,@sp13,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-034-2026',NULL,'2026-09-05 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p13,2,'PROPUESTA','https://example.com/demo/p13-propuesta-v1',30,'2026-09-07 09:30:00');
SET @pr13 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p13;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,2,2,4,@pr13,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-10 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,3,3,6,@pr13,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-13 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,3,4,2,@pr13,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-035-2026',NULL,'2026-09-15 11:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p13,4,'INFORME','https://example.com/demo/p13-informe-v1',30,'2026-09-17 10:00:00');
SET @in13 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p13;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,4,2,4,@in13,'APROBADO','Informe aprobado por el director.',
   NULL,NULL,'2026-09-20 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,5,3,6,@in13,'APROBADO','Informe aprobado por el evaluador.',
   NULL,NULL,'2026-09-22 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p13,5,4,2,@in13,'APROBADO','El trabajo cumple los requisitos; se autoriza el cierre.',
   'ACTA-036-2026',NULL,'2026-09-24 11:00:00');

-- P14 - "Finalizado" con radicado RAD-2026-0001. Estudiante 31 con segundo estudiante 32.
INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, fecha_creacion) VALUES
  ('PROPIA','Sistema de gestión de la investigación formativa',
   'Implementar un sistema que registre y haga seguimiento a los proyectos de investigación formativa.',
   2,31,32,'2026-09-04 09:00:00');
SET @p14 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p14,1,'SOPORTE_PAGO','https://example.com/demo/p14-pago',31,'2026-09-04 09:20:00');
SET @sp14 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p14;
UPDATE proyecto SET id_director=6, id_evaluador=4 WHERE id_proyecto=@p14;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,1,4,2,@sp14,'APROBADO','Idea aprobada; se asigna director y evaluador.',
   'ACTA-037-2026',NULL,'2026-09-06 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p14,2,'PROPUESTA','https://example.com/demo/p14-propuesta-v1',31,'2026-09-08 09:30:00');
SET @pr14 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p14;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,2,2,6,@pr14,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-11 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,3,3,4,@pr14,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-14 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,3,4,2,@pr14,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-038-2026',NULL,'2026-09-16 11:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p14,4,'INFORME','https://example.com/demo/p14-informe-v1',31,'2026-09-18 10:00:00');
SET @in14 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p14,4,'MANUAL_USUARIO','https://example.com/demo/p14-manual-usuario',31,'2026-09-18 10:05:00'),
  (@p14,4,'MANUAL_TECNICO','https://example.com/demo/p14-manual-tecnico',31,'2026-09-18 10:10:00'),
  (@p14,4,'REPOSITORIO','https://example.com/demo/p14-repositorio',31,'2026-09-18 10:15:00');
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p14;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,4,2,6,@in14,'APROBADO','Informe y anexos aprobados por el director.',
   NULL,NULL,'2026-09-21 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,5,3,4,@in14,'APROBADO','Informe y anexos aprobados por el evaluador.',
   NULL,NULL,'2026-09-23 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,5,4,2,@in14,'APROBADO','El trabajo cumple los requisitos; se autoriza el cierre.',
   'ACTA-039-2026',NULL,'2026-09-25 11:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p14,6,4,2,@in14,'APROBADO','Cierre del trabajo de grado; se registra el radicado.',
   NULL,'RAD-2026-0001','2026-09-29 10:00:00');

-- P15 - "Finalizado" con radicado RAD-2026-0002 (idea del banco, idea 8). Estudiante 32.
INSERT INTO proyecto (origen, id_idea_docente, titulo, descripcion, id_linea, id_estudiante1, id_estudiante2, id_director, fecha_creacion) VALUES
  ('BANCO_DOCENTE',8,'Modelo de predicción de la deserción por asignatura',
   'Construir un modelo que identifique las asignaturas con mayor riesgo de deserción a partir de los datos históricos.',
   6,32,NULL,13,'2026-09-05 09:00:00');
SET @p15 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p15,1,'SOPORTE_PAGO','https://example.com/demo/p15-pago',32,'2026-09-05 09:20:00');
SET @sp15 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f1, id_rol_proceso=@r1 WHERE id_proyecto=@p15;
UPDATE proyecto SET id_evaluador=12 WHERE id_proyecto=@p15;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,1,4,2,@sp15,'APROBADO','Idea aprobada; se asigna la evaluación.',
   'ACTA-040-2026',NULL,'2026-09-07 09:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p15,2,'PROPUESTA','https://example.com/demo/p15-propuesta-v1',32,'2026-09-09 09:30:00');
SET @pr15 = LAST_INSERT_ID();
UPDATE proyecto SET id_fase=@f2, id_rol_proceso=@r2 WHERE id_proyecto=@p15;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,2,2,13,@pr15,'APROBADO','Propuesta aprobada por el director.',
   NULL,NULL,'2026-09-12 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,3,3,12,@pr15,'APROBADO','Propuesta aprobada por el evaluador.',
   NULL,NULL,'2026-09-15 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,3,4,2,@pr15,'APROBADO','Propuesta aprobada; continúa al informe final.',
   'ACTA-041-2026',NULL,'2026-09-17 11:00:00');
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p15,4,'INFORME','https://example.com/demo/p15-informe-v1',32,'2026-09-19 10:00:00');
SET @in15 = LAST_INSERT_ID();
INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario, fecha_entrega) VALUES
  (@p15,4,'REPOSITORIO','https://example.com/demo/p15-repositorio',32,'2026-09-19 10:05:00');
UPDATE proyecto SET id_fase=@f4, id_rol_proceso=@r4 WHERE id_proyecto=@p15;
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,4,2,13,@in15,'APROBADO','Informe aprobado por el director.',
   NULL,NULL,'2026-09-22 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,5,3,12,@in15,'APROBADO','Informe aprobado por el evaluador.',
   NULL,NULL,'2026-09-24 10:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,5,4,2,@in15,'APROBADO','El trabajo cumple los requisitos; se autoriza el cierre.',
   'ACTA-042-2026',NULL,'2026-09-26 11:00:00');
INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado, fecha_revision) VALUES
  (@p15,6,4,2,@in15,'APROBADO','Cierre del trabajo de grado; se registra el radicado.',
   NULL,'RAD-2026-0002','2026-09-30 10:00:00');

-- ---------------------------------------------------------------------------
-- 4. RESUMEN (consulta de solo lectura; descomenta para ver la distribucion):
--
--   SELECT finalizado, estado, COUNT(*) AS proyectos
--   FROM v_proyecto
--   GROUP BY finalizado, estado
--   ORDER BY finalizado, estado;
-- ---------------------------------------------------------------------------
