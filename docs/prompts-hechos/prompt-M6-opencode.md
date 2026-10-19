# Prompt M6 para opencode: Comité, ideas (4.4 y 4.5)

Uso: guarda este archivo en la carpeta docs/ del proyecto (C:\xampp\tomcat\webapps\sistemastg\docs\). MySQL y Tomcat deben estar encendidos en XAMPP. Abre una sesión NUEVA de opencode en la carpeta sistemastg y escribe solo esto:

    Lee docs/prompt-M6-opencode.md y ejecuta SOLO la PARTE A, desde la línea "RETOMAR" hasta el final de la PARTE A. Espera mi confirmación antes de la PARTE B.

Cuando la PARTE A esté aprobada, en la misma sesión (o en una nueva) escribe:

    Lee docs/prompt-M6-opencode.md y ejecuta SOLO la PARTE B.

---

RETOMAR. Esta es una sesión nueva: no tienes memoria de las anteriores. Lee primero, completos y en este orden: AGENTS.md (reglas y convenciones, incluida la sección 13), PLAN.md (estado, resultados de M1 a M5 y decisiones) y, de docs/requerimientos.md, los requerimientos que menciona cada parte.

Comprobación previa (no modifiques nada todavía): confirma que M1 a M5 están marcados [x] en PLAN.md y que la base está limpia: usuario 11, idea_docente 5, proyecto 0, entrega 0, revision 0, AUTO_INCREMENT de idea_docente = 6. Si algo no coincide, detente y avísame. Si todo coincide, guarda en un archivo un SELECT * de las 5 filas de idea_docente para compararlas al final.

REGLAS COMUNES A TODO EL M6
- Páginas en comite/, todas con el guardia de rol Comité (rolId 2). Modificaciones solo por POST con manejadores POST-only (un GET al manejador muestra "Acción no permitida"), redirigir-después-de-enviar, mensajes flash y la convención de errores de error-bd.jspf (los mensajes de los triggers se muestran; los demás errores salen genéricos o mapeados).
- El revisor (id_revisor) es SIEMPRE el usuario de la sesión, nunca un campo del formulario. Los ids se validan como numéricos antes de usarlos. Los valores de acción (aprobar, aplazar, etc.) se validan contra una lista fija. Toda salida con c:out y toda consulta con sql:param.
- Agrega al menú del Comité las entradas "Banco de ideas docente" e "Ideas de estudiantes" (la segunda en la PARTE B) y enlaces desde comite/panel.jsp.
- Estados con insignias de color, igual que en docente/ideas.jsp.
- Usa sql:transaction cuando una operación tenga varias sentencias, y comprueba el número de filas afectadas de los UPDATE y DELETE condicionados.
- Para sembrar datos de prueba usa mysql.exe con archivos .sql (no comillas en cmd), con --default-character-set=utf8mb4.

==================================================
PARTE A. BANCO DE IDEAS DOCENTE (4.4: req. 49 a 55, 18, 20b, 20e, 35)
==================================================
Lista antes los requerimientos y los archivos. Archivos sugeridos: comite/ideas-docentes.jsp (listado), comite/idea-docente-revisar.jsp (formulario de aprobar o aplazar), comite/idea-docente-editar.jsp (req. 52), comite/guardar-idea-docente.jsp (POST: aprobar, aplazar y editar) y comite/eliminar-idea-docente.jsp (POST).

1. Listado (req. 49, 18): consulta v_idea_docente. Columnas: ID, título, objetivo, línea de investigación, nivel académico, periodo académico, docente que la propuso (nombre, no id), estado y disponibilidad; para las revisadas, también acta y motivo. Filtro simple por estado (Todas, Pendientes, Aprobadas, Aplazadas) con un parámetro GET validado contra lista fija. Botones por fila según el estado: Aprobar y Aplazar solo en PENDIENTE; Editar y Eliminar en todas.
2. Aprobar (req. 50, 55): solo desde PENDIENTE. Pide el número de acta (obligatorio, máximo 30). Un UPDATE condicionado a estado = 'PENDIENTE' que ponga estado APROBADA, acta_numero, disponibilidad DISPONIBLE, fecha_revision = NOW(). No se pide soporte de pago (req. 55). Si afecta 0 filas, mensaje claro (por ejemplo "La idea ya no está pendiente").
3. Aplazar (req. 51): solo desde PENDIENTE. Pide acta (obligatoria) y motivo (obligatorio, máximo 1000). Un UPDATE condicionado que ponga estado APLAZADA, acta_numero, motivo_aplazamiento, disponibilidad NO_DISPONIBLE y fecha_revision = NOW(). El texto de la pantalla no debe usar la palabra "rechazar".
4. Editar estado y disponibilidad (req. 52): formulario con estado, disponibilidad, acta y motivo. Reglas validadas en el servidor (no dejes que sea el CHECK de la BD quien las detecte): APROBADA exige acta y deja el motivo en NULL; APLAZADA exige acta y motivo y fuerza NO_DISPONIBLE (rechaza DISPONIBLE); PENDIENTE fuerza NO_DISPONIBLE y deja acta, motivo y fecha_revision en NULL; DISPONIBLE solo con APROBADA. Si algún proyecto usa la idea, NO se puede modificar su estado ni su disponibilidad (mensaje claro). El comité nunca cambia título, objetivo, línea, nivel, periodo ni docente (req. 54: solo revisa, no crea ni redacta).
5. Eliminar (req. 53): por POST con confirmación en el cliente. Solo si ningún proyecto usa la idea: DELETE condicionado con NOT EXISTS sobre proyecto, comprobando filas afectadas, y captura del error 1451 como respaldo, con mensaje claro ("No se puede eliminar una idea que ya fue tomada por un proyecto").
6. Decisiones mías que no están en los requerimientos; anótalas en PLAN.md en una sección nueva "Decisiones del módulo M6": (a) aprobar y aplazar solo desde PENDIENTE; (b) reglas de edición del punto 4; (c) una idea ya tomada por un proyecto no se edita ni se elimina; (d) el motivo máximo es 1000 caracteres.

VERIFICACIÓN PARTE A (curl como comité 9000000001/comite123; evidencia real)
Siembra con mysql.exe: una idea temporal (docente 4, pendiente, se creará con id 6) y un proyecto temporal de origen BANCO_DOCENTE sobre la idea 1 (estudiante 11, director 3; el trigger la marca NO_DISPONIBLE).
- Listado con las 5 ideas originales más la temporal, con nombres de docente (no ids) y todas las columnas; el filtro por estado funciona y un valor de filtro inválido se ignora.
- Aprobar la idea 3 con acta: queda APROBADA, DISPONIBLE, con acta y fecha. Aprobar la idea 1 (ya aprobada): rechazado sin cambios. Aprobar sin acta y con acta de 31 caracteres: error.
- Aplazar la idea 5 con acta y motivo: queda APLAZADA, NO_DISPONIBLE. Sin motivo o sin acta: error. Aplazar una ya aprobada: rechazado.
- Editar: la idea 3 a APLAZADA con acta y motivo funciona; APLAZADA con DISPONIBLE se rechaza; a PENDIENTE limpia acta, motivo y fecha; la idea 1 (usada por el proyecto temporal) no se puede editar.
- Eliminar: la idea temporal se elimina; la idea 1 (usada por el proyecto) da el mensaje claro y no cambia.
- Seguridad: título con <script> sale escapado; inyección SQL en acta y motivo se guarda como texto o se rechaza sin efectos; ids no numéricos y acciones fuera de lista se rechazan; campos enviados a mano (id_docente, titulo, disponibilidad con la acción aplazar) se ignoran.
- Guardias: sin sesión redirige a login.jsp; admin, docente y estudiante en cada página de comite/ redirigen con el mensaje de falta de permiso; GET a los manejadores POST-only muestra "Acción no permitida".
LIMPIEZA PARTE A: borra el proyecto y la idea temporales, restaura las 5 ideas originales (incluida la disponibilidad de la idea 1), reinicia AUTO_INCREMENT de idea_docente a 6 y de proyecto a 1, y compara el SELECT * contra el archivo guardado (SHA-256 y fc /b: deben ser idénticos). Confirma usuario 11, proyecto 0, entrega 0, revision 0.
AL TERMINAR LA PARTE A: marca "M6 parte A" en PLAN.md con resultados reales, muestra el árbol de archivos de comite/ y espera mi confirmación. No empieces la PARTE B.

==================================================
PARTE B. IDEAS DE ESTUDIANTES (4.5: req. 56 a 61, 9, 20f, 20h, 4)
==================================================
Lista antes los requerimientos y los archivos. Archivos sugeridos: comite/ideas-estudiantes.jsp (listado), comite/idea-estudiante-revisar.jsp (formulario), comite/guardar-revision-fase1.jsp (POST) y comite/eliminar-idea-estudiante.jsp (POST).

Contexto del flujo (ya está en la BD): una idea propia es un proyecto con origen PROPIA. El estudiante la crea en "Fase 1 | Estudiante", sube el pago y la envía; entonces pasa a "Fase 1 | Comité" y solo ahí el comité puede revisarla. El comité califica insertando una fila en revision (id_fase 1, id_rol_proceso 4): los triggers validan el turno, el acta, los comentarios y que haya director y evaluador, y cambian solos la fase, el turno y el estado de la idea.

1. Listado (req. 56): sobre v_idea_estudiante, unida a v_proyecto por id_proyecto para traer el estado "Fase N | Rol", el rol en turno, el director y el evaluador. Columnas: ID, título, descripción, línea, estudiante(s) (nombres), nivel académico, soporte de pago (URL clicable con target="_blank" rel="noopener noreferrer", o "Sin soporte de pago"), estado de la idea y estado del proyecto. Filtro por estado de la idea como en la PARTE A. Botones Aprobar y Aplazar habilitados SOLO si el proyecto está en "Fase 1 | Comité"; en cualquier otro estado aparecen deshabilitados con una pista visible. Eliminar según el punto 5.
2. Aprobar (req. 57, 58, 9): formulario con acta (obligatoria, máximo 30), director (lista de docentes), evaluador (lista de docentes que EXCLUYE al director elegido, con JS del lado cliente que la actualiza al cambiar el director) y comentarios (obligatorios, porque toda calificación lleva comentarios, req. 4). Validaciones en el servidor con mensajes claros: el proyecto está en "Fase 1 | Comité" (si no, mensaje del req. 20f), el proyecto tiene soporte de pago (req. 57), director y evaluador existen y son docentes, y el evaluador no es el director (req. 20h). Operación en una sola sql:transaction: UPDATE proyecto SET id_director, id_evaluador y luego INSERT INTO revision (id_proyecto, id_fase, id_rol_proceso, id_revisor, id_entrega, resultado, comentarios, acta_numero, radicado) con id_fase 1, id_rol_proceso 4, resultado 'APROBADO', id_entrega = la última entrega SOPORTE_PAGO, radicado NULL. Si el INSERT falla por un trigger, la asignación de director y evaluador debe quedar revertida.
3. Aplazar (req. 59): formulario con acta (obligatoria) y motivo (obligatorio; se guarda en revision.comentarios). INSERT en revision con resultado 'APLAZADO' en la misma fase y turno. No hace falta asignar director ni evaluador. El proyecto vuelve al estudiante ("Fase 1 | Estudiante", idea APLAZADA) por los triggers. Sin la palabra "rechazar".
4. Reutilización: el manejador comite/guardar-revision-fase1.jsp debe contemplar también los proyectos de origen BANCO_DOCENTE (el director ya viene de la idea y no se puede cambiar; solo se asigna el evaluador, que no puede ser ese director), porque el M8 lo reutilizará desde "Gestionar fases". El listado de esta parte sigue mostrando solo ideas propias (v_idea_estudiante).
5. Eliminar (req. 60): solo ideas de origen PROPIA que sigan en la Fase 1. Por POST con confirmación en el cliente, en una sola sql:transaction y en este orden: DELETE de revision, DELETE de entrega y DELETE de proyecto, llevando CADA delete la condición (origen PROPIA, id_fase 1, no finalizado; con subconsulta sobre proyecto en los de revision y entrega) para que, si el estado cambió, no se borre nada. Si no se cumple la condición, mensaje claro y sin cambios.
6. Decisiones mías; agrégalas a "Decisiones del módulo M6" en PLAN.md: (e) el comité solo califica proyectos en "Fase 1 | Comité"; (f) el motivo del aplazamiento y los comentarios de la aprobación van en revision.comentarios; (g) el manejador de la Fase 1 sirve a los dos orígenes; (h) la eliminación solo en Fase 1 y origen PROPIA.

VERIFICACIÓN PARTE B (curl como comité; evidencia real)
Siembra con mysql.exe (los INSERT deben enviar siempre las columnas NOT NULL, como indica el SQL): 
  proyecto: INSERT INTO proyecto (origen, titulo, descripcion, id_linea, id_estudiante1) VALUES ('PROPIA', ..., ..., 1, <id estudiante>);
  pago: INSERT INTO entrega (id_proyecto, id_fase, tipo, url, id_usuario) VALUES (<id>, 1, 'SOPORTE_PAGO', 'https://example.com/pago-x', <id estudiante>);
  enviar al comité: UPDATE proyecto SET id_rol_proceso = 4 WHERE id_proyecto = <id>;
Proyectos temporales: A (estudiante 7, con pago, en Fase 1 | Comité), B (estudiante 8, con pago, en Comité), C (estudiante 9, SIN pago, en Comité), D (estudiante 10, con pago, todavía en Fase 1 | Estudiante), E (origen BANCO_DOCENTE sobre la idea 1, estudiante 11, director 3, con pago, en Comité) y F (propia con título <script>alert(1)</script>, en Comité).
- Listado: muestra solo los propios (A, B, C, D, F), con nombres y no ids, el enlace de pago clicable en los que lo tienen, "Sin soporte de pago" en C, estado "Fase N | Rol", y botones habilitados solo en los que están en Comité.
- Aprobar A con director 3, evaluador 4, acta y comentarios: el proyecto pasa a "Fase 2 | Estudiante", idea APROBADA, director y evaluador asignados, y existe una fila en revision con revisor = 2 (el comité de la sesión), acta y fecha.
- Aprobar B con el mismo docente como director y evaluador: rechazado con el mensaje del req. 20h y director y evaluador de B siguen en NULL.
- Aprobar C (sin pago): rechazado y C queda sin director ni evaluador asignados (comprueba que la transacción revirtió el UPDATE).
- Aprobar D (en Fase 1 | Estudiante): rechazado con el mensaje del req. 20f, sin cambios.
- Aprobar con evaluador que no es docente (id de un estudiante), con comentarios vacíos, con acta vacía o de 31 caracteres, e ids no numéricos: rechazados sin efectos.
- Aprobar E (origen BANCO): el director sigue siendo 3 aunque envíes otro director por POST; se asigna solo el evaluador; no puede ser el 3.
- Aplazar B con acta y motivo: B queda en "Fase 1 | Estudiante" con idea APLAZADA y el motivo en revision. Sin acta o sin motivo: error.
- Eliminar: B (propia, Fase 1) se elimina con sus entregas y revisiones; A (ya en Fase 2) se rechaza; E (origen BANCO) se rechaza por esta página; confirma con consultas que no quedan filas huérfanas de B.
- Seguridad: el título con <script> de F sale escapado; id_revisor, id_fase o resultado enviados a mano con valores raros se ignoran o se rechazan, y la revisión siempre queda a nombre del comité de la sesión; inyección SQL en acta y comentarios se guarda como texto o se rechaza sin efectos.
- Guardias: sin sesión → login.jsp; admin, docente y estudiante → mensaje de falta de permiso; GET a los manejadores → "Acción no permitida".
LIMPIEZA PARTE B (obligatoria): borra todas las filas temporales en el orden revision, entrega, proyecto; restaura idea_docente a su estado original (la idea 1 vuelve a DISPONIBLE y APROBADA); reinicia AUTO_INCREMENT de proyecto, entrega y revision a 1 y de idea_docente a 6; compara el SELECT * de idea_docente contra el archivo guardado (SHA-256 y fc /b idénticos). Confirma usuario 11 (AUTO_INCREMENT 12), idea_docente 5, proyecto 0, entrega 0, revision 0.

AL TERMINAR LA PARTE B: marca M6 completo en PLAN.md con resultados reales y las decisiones (e) a (h), muestra el árbol de archivos de comite/ y no avances al M7. Espera mi confirmación.
