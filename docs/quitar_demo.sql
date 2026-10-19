-- ============================================================================
--  quitar_demo.sql - Quita los datos de demostracion de Sistemas TG
--  (M9-E parte A) y deja la base identica al baseline de docs/sistemas_tg.sql:
--  11 usuarios, 5 ideas, 0 proyectos, 0 entregas y 0 revisiones.
--
--  Borra en orden revision, entrega y proyecto (respetando las llaves foraneas),
--  las ideas con id mayor que 5 y los usuarios con id mayor que 11, y reinicia
--  los AUTO_INCREMENT. Los usuarios 1 a 11 y las ideas 1 a 5 no se tocan.
--
--  Uso (desde cmd):
--    cmd /c "C:\xampp\mysql\bin\mysql.exe -u root sistemas_tg < C:\sistemastg-tests\quitar_demo.sql"
-- ============================================================================

USE sistemas_tg;

DELETE FROM revision;
DELETE FROM entrega;
DELETE FROM proyecto;
DELETE FROM idea_docente WHERE id_idea_docente > 5;
DELETE FROM usuario WHERE id_usuario > 11;

ALTER TABLE revision  AUTO_INCREMENT = 1;
ALTER TABLE entrega   AUTO_INCREMENT = 1;
ALTER TABLE proyecto  AUTO_INCREMENT = 1;
ALTER TABLE idea_docente AUTO_INCREMENT = 6;
ALTER TABLE usuario   AUTO_INCREMENT = 12;
