# Cumplimiento de requerimientos — Sistemas TG

**Fecha:** 2026-10-14 · **Alcance:** los 97 requerimientos de `docs/requerimientos.md` (el encabezado dice "98"; se verifican 97, ver `PLAN.md` §7.1).

**Método.** Cada requerimiento se contrastó contra el **código** (búsquedas en los JSP y fragmentos, `web.xml`, `js/`, `css/`), contra la **base de datos** (consultas SQL de solo lectura a `information_schema` y a las tablas) y contra los **resultados de las suites** de `C:\sistemastg-tests` (`m3`…`m9a` y `guion-verificado.ps1`), no solo contra lo que dice `PLAN.md`.

**Estados posibles:** `Cumple` · `Cumple con ajuste por indicación del docente` · `No aplica por alcance` · `Pendiente de despliegue` · `Requiere revisión humana` · `Incumple`.

---

## Matriz

| # | Resumen (una línea) | Estado | Módulo | Evidencia |
|---|---|---|---|---|
| 1 | Seis fases, cada una con responsables definidos | Cumple | M1, M8 | `docs/sistemas_tg.sql` (tablas `fase`, `fase_rol`, `transicion_fase`); recorrido completo en `m8b-tests.ps1` y `guion-verificado.ps1` |
| 2 | Estado `Fase N \| Rol`, y `Finalizado` al terminar | Cumple | M1, M8 | `v_proyecto.estado` (`sistemas_tg.sql` líneas 300–301); `comite/proyectos.jsp`, `docente/proyectos.jsp`; `m8a`, `m8b`, `guion-verificado.ps1` |
| 3 | Al aprobar, la fase y el rol responsable cambian solos | Cumple | M1, M8 | Triggers de `sistemas_tg.sql` (transición según `revision`); transiciones observadas en `m8b` y `guion-verificado.ps1` |
| 4 | Calificación solo Aprobado o Aplazado, con comentarios | Cumple | M1, M8 | ENUM + `CHECK` en `revision`; `comite/guardar-calificacion.jsp`, `docente/guardar-calificacion.jsp`; `m8a`, `m8b` |
| 5 | Al aplazar, el proyecto vuelve al estudiante | Cumple | M8 | Trigger de transición; `m8b-tests.ps1` (aplaza → 2\|1 y 4\|1) |
| 6 | Seguimiento de las seis fases con la actual en verde (diseño basado en el software institucional) | Requiere revisión humana | M8 | `WEB-INF/fragmentos/seguimiento-fases.jsp` (fase `actual` en verde; `m8a`/`m8b` comprueban una sola fase marcada). El parecido visual con el software institucional solo lo puede valorar una persona |
| 7 | El seguimiento lo ven Administrador, Comité, Director y Evaluador | Cumple | M8 | `seguimiento-fases.jsp` incluido en `admin/proyectos.jsp`, `comite/proyectos.jsp`, `docente/proyectos.jsp`; `m8a`, `m8b` |
| 8 | Botón "Gestionar fases" para Comité, Director y Evaluador | Cumple | M8 | `comite/proyectos.jsp`, `docente/proyectos.jsp` (enlace si es su turno; `<button disabled>` si no); `m8a`, `m8b` |
| 9 | Evaluador ≠ director del mismo proyecto; sí en proyectos distintos | Cumple | M1, M6, M8 | `ck_proy_director_evaluador` + trigger (`SIGNAL` 45000 "El evaluador no puede ser el director del proyecto"); `m6b`, `m8b`, `guion-verificado.ps1` (20h) |
| 10 | JSP + JSTL 1.2 + JDBC y JavaScript solo en el cliente; sin Node.js | Cumple | M2 | `WEB-INF/lib/jstl-1.2.jar`; `conexion.jsp` con etiquetas `sql:`; `js/` propio; no hay `package.json` ni Node |
| 11 | Sin scriptlets, Maven ni Servlets | Cumple | M2 | Auditoría: 0 coincidencias de `<%` real (solo comentarios `<%--`), 0 archivos `.java`, 0 `pom.xml`/`build.gradle`. Aterrizaje hecha como JSP (no servlet). Ver *Hallazgo H4* |
| 12 | Fragmentos reutilizables | Cumple con ajuste por indicación del docente | M2 | `WEB-INF/fragmentos/`: `conexion`, `taglibs`, `encabezado`, `pie`, `menu`, `guardia`, `error-bd`, `url-valida`, `seguimiento-fases`, `documentos-proyecto`, `avatar` (todos **`.jsp`**, no `.jspf`, incluidos de forma estática con `<%@ include %>`). El requisito pedía fragmentos; el docente indicó además **no usar la extensión `.jspf`**, y se cumplió: 0 archivos `*.jspf` en el proyecto |
| 13 | Tomcat 8.5.96 y JDK 21.0.6 (JSTL 1.2) | Requiere revisión humana | M2 | Tomcat 8.5.96 ✔; el JDK instalado es **25.0.2**, no 21.0.6 (ver *Hallazgo H2*) |
| 14 | MySQL local y MySQL en la nube (obligatoria) | Pendiente de despliegue | M1, M10 | Local: `conexion.jsp` + MariaDB 10.4.32 (XAMPP). Nube: tarea de M10 |
| 15 | En GitHub y desplegado online (Render) con base en la nube | Pendiente de despliegue | M10 | — |
| 16 | Llaves foráneas y `rol` como tabla aparte | Cumple | M1 | 25 FKs en `information_schema.REFERENTIAL_CONSTRAINTS`; tabla `rol` con 4 filas; `usuario.id_rol` FK |
| 17 | Archivos como URL clicables y validadas (idea, pago, propuesta, informe, anexos) | Cumple | M1, M7 | `CHECK ck_entrega_url` y `ck_recurso_url`; `WEB-INF/fragmentos/url-valida.jsp`; enlaces `target="_blank" rel="noopener"`; `m7a`, `m7b` (20d) |
| 18 | Listados con datos de varias tablas y solo los registros del rol | Cumple | M4–M8 | `v_proyecto`, `v_idea_docente`, `v_idea_estudiante`, `v_historial_*`; consultas filtradas por el usuario de sesión; `m5`–`m9a` |
| 19 | Nombre completo y número de documento único | Cumple | M1, M4 | `usuario.nombre_completo` NOT NULL y UNIQUE en `numero_documento`; `m4` (20c), `m3` |
| 20 | Mensajes claros en los casos a–i | Cumple | M3–M8 | Ver las filas 20a–20i |
| 20a | Usuario, contraseña o rol incorrectos | Cumple | M3 | `login.jsp` ("Usuario, contraseña o rol incorrectos"); `m3-tests.ps1`, `guion-verificado.ps1` |
| 20b | Campos obligatorios vacíos | Cumple | M3, M4, M7 | Validación en `login.jsp`, `admin/guardar-usuario.jsp`, `docente/guardar-idea.jsp`, `estudiante/guardar-proyecto.jsp`; `m3`, `m4`, `m7a`, `guion-verificado.ps1` |
| 20c | Número de documento ya registrado | Cumple | M4 | `admin/guardar-usuario.jsp` (error 1062) + `error-bd.jsp`; `m4`, `guion-verificado.ps1` |
| 20d | URL con formato inválido | Cumple | M7 | `url-valida.jsp` ("La URL no tiene un formato válido"); `m7a`, `m7b`, `guion-verificado.ps1` |
| 20e | Abrir una página sin sesión o sin permiso del rol | Cumple | M3 | `WEB-INF/fragmentos/guardia.jsp`; `m3`, `m9-matriz.txt`, `guion-verificado.ps1` |
| 20f | Actuar sobre un proyecto fuera de la fase del rol | Cumple | M8 | Checks de turno en `comite/gestionar-fase.jsp`, `comite/guardar-calificacion.jsp`, `docente/gestionar-fase.jsp`, `docente/guardar-calificacion.jsp`; `m8a`, `m8b`, `guion-verificado.ps1` |
| 20g | Eliminar un usuario con proyectos asociados | Cumple | M4 | `admin/eliminar-usuario.jsp` (captura FK 1451); `m4` (proyecto temporal), `guion-verificado.ps1` no lo incluye (a propósito) |
| 20h | Asignar como evaluador al director del mismo proyecto | Cumple | M6, M8 | Trigger (`SIGNAL` 45000); `m6b`, `m8b`, `guion-verificado.ps1` |
| 20i | Estudiante 2 intenta abrir un proyecto que no creó | Cumple | M7 | `estudiante/proyecto.jsp`, `guardar-entrega.jsp`, `guardar-correccion.jsp` ("No tienes permiso para ver este proyecto"); `m7a`, `m7b`, `guion-verificado.ps1` |
| 21 | Trazabilidad con historial de versiones y fechas | Cumple | M1, M7, M8 | Tablas `entrega`/`revision` con `fecha_entrega`/`fecha_revision`; `v_historial_entregas`, `v_historial_revisiones`; `documentos-proyecto.jsp`; `m7b`, `m8a` |
| 22 | Demostración punta a punta con datos de ejemplo | Cumple | M1, M9 | Datos en `sistemas_tg.sql`; `docs/guion-demostracion.md`; `C:\sistemastg-tests\guion-verificado.ps1` (verificado escena por escena); conjunto de demostración `docs/datos_demo.sql` + `docs/quitar_demo.sql` (M9-E parte A: 21 usuarios, 18 ideas y 15 proyectos con los doce estados posibles) |
| 23 | No envía correos ni notificaciones | No aplica por alcance | — | `PLAN.md` §6 |
| 24 | No hay Fase 0, secretarias ni validación de créditos | No aplica por alcance | — | `PLAN.md` §6 |
| 25 | No hay modalidades de grado | No aplica por alcance | — | `PLAN.md` §6 |
| 26 | No se usa el estado "Rechazado" | No aplica por alcance | — | `PLAN.md` §6 (la calificación usa Aprobado/Aplazado) |
| 27 | No se genera el consecutivo institucional | No aplica por alcance | — | `PLAN.md` §6 (el ID es `AUTO_INCREMENT`) |
| 28 | No hay retiros, cambios, prórrogas ni plazo 90→180 | No aplica por alcance | — | `PLAN.md` §6 |
| 29 | No hay sustentación final | No aplica por alcance | — | `PLAN.md` §6 |
| 30 | No hay recuperación de contraseña | No aplica por alcance | — | `PLAN.md` §6 |
| 31 | No hay Turnitin, TyT/Saber Pro, PQRs, chat ni métricas | No aplica por alcance | — | `PLAN.md` §6 |
| 32 | Aterrizaje con mensajes motivadores | Cumple | M2 | `index.jsp` (frases motivadoras y las seis fases) |
| 33 | Botón "Sistemas TG" en el banner | Cumple | M2 | `index.jsp` (banner con botón/enlace "Sistemas TG" a `login.jsp`) |
| 34 | Inicio de sesión con documento, contraseña y rol | Cumple | M3 | `login.jsp` (`WHERE numero_documento=? AND contrasena=? AND id_rol=?`); `m3`, `guion-verificado.ps1` |
| 35 | Cada rol ve solo su menú | Cumple | M3 | `WEB-INF/fragmentos/menu.jsp` (`c:choose` por `rolId`); `m3`, `m9a` |
| 36 | Lista/visualización de los usuarios de prueba y sus claves | Cumple | M3 | `login.jsp` (`<details>` con la tabla de usuario/rol/documento/clave); `m3`, `guion-verificado.ps1` |
| 37 | Cierre de sesión en todos los roles | Cumple | M3 | `logout.jsp` (`invalidate` + redirect); `m3` (cuatro roles), `guion-verificado.ps1` |
| 38 | Control de acceso en cada página (sesión + rol) | Cumple | M3 | `guardia.jsp` en toda página protegida; matriz de 38 JSP × 5 identidades en `m9-matriz.txt` (0 desviaciones); `m3`, `m9a` |
| 39 | Claves en texto plano (limitación aceptada) | Cumple | M1, M3 | `usuario.contrasena` sin hash; visible en `login.jsp`; `m3` |
| 40 | Registrar usuarios (nombre, tipo/número de documento, contraseña, rol y nivel si es estudiante) | Cumple | M4 | `admin/usuario-form.jsp`, `admin/guardar-usuario.jsp`; `m4` (nivel NULL para docente/admin; estudiante sin nivel rechazado) |
| 41 | Editar usuarios sin editar el ID | Cumple | M4 | `admin/usuario-form.jsp`, `admin/guardar-usuario.jsp` (contraseña en blanco se conserva); `m4` |
| 42 | Eliminar usuarios | Cumple | M4 | `admin/eliminar-usuario.jsp`; `m4` |
| 43 | Listado de usuarios | Cumple | M4 | `admin/usuarios.jsp` (sin mostrar la contraseña); `m4` |
| 44 | Calendario académico y formatos de grado como enlaces | Cumple | M4 | `admin/recursos.jsp` (3 enlaces: 1 calendario + 2 formatos); tabla `recurso_institucional`; `m4` |
| 45 | Ver todos los proyectos con fase y rol | Cumple | M4, M8 | `admin/proyectos.jsp` (`v_proyecto`); `m4`, `m8a` |
| 46 | No eliminar un usuario con proyectos (mensaje) | Cumple | M4 | `admin/eliminar-usuario.jsp` + `error-bd.jsp` (FK 1451); `m4` (proyecto temporal sembrado por `mysql.exe`). **Implementado pero fuera del guion** (req. 46) |
| 47 | El administrador solo visualiza proyectos | Cumple | M4 | `admin/proyectos.jsp` sin acciones de gestión; `m4`, `m9a` |
| 48 | Solo el administrador crea usuarios | Cumple | M4 | `rolRequerido=1` + `guardia.jsp`; `admin/guardar-usuario.jsp` y demás páginas admin; `m4`, `m9-matriz.txt` |
| 49 | Consultar las ideas del banco con todos sus campos | Cumple | M6 | `comite/ideas-docentes.jsp` sobre `v_idea_docente`; `m6a` |
| 50 | Aprobar una idea con número de acta y publicarla | Cumple | M6 | `comite/guardar-idea-docente.jsp` (APROBADA + `DISPONIBLE`); `m6a`, `guion-verificado.ps1` |
| 51 | Aplazar una idea con acta y motivo | Cumple | M5, M6 | `comite/guardar-idea-docente.jsp` (APLAZADA + motivo); el docente corrige en `docente/idea-form.jsp`; `m6a`, `m5` |
| 52 | Actualizar estado y disponibilidad de una idea | Cumple | M6 | `comite/idea-docente-editar.jsp` + `guardar-idea-docente.jsp` (reglas respetadas); `m6a` |
| 53 | Eliminar ideas del banco | Cumple | M6 | `comite/eliminar-idea-docente.jsp` (`NOT EXISTS` sobre `proyecto`); `m6a` |
| 54 | El comité solo revisa el banco, no lo crea | Cumple | M6 | `comite/panel.jsp` y `menu.jsp` (sin altas); `m6a` |
| 55 | La idea del docente se aprueba sin soporte de pago | Cumple | M6 | `comite/guardar-idea-docente.jsp` (no exige pago); `m6a` |
| 56 | Ver las ideas de estudiantes con todos sus campos | Cumple | M6 | `comite/ideas-estudiantes.jsp` (`v_idea_estudiante`), soporte de pago como enlace; `m6b` |
| 57 | Revisar el pago; sin pago no se aprueba | Cumple | M6 | Trigger (`SIGNAL` 45000 "No se puede aprobar la idea sin soporte de pago"); `m6b` |
| 58 | Aprobar con acta y asignar director y evaluador (evaluador ≠ director) | Cumple | M6 | `comite/guardar-revision-fase1.jsp` + `comite/idea-estudiante-revisar.jsp` (`js/revision-fase1.js` excluye al director); `m6b` |
| 59 | Aplazar la idea con acta y motivo | Cumple | M6 | `comite/guardar-revision-fase1.jsp` (rama aplazar); `m6b` |
| 60 | Eliminar ideas de estudiantes | Cumple | M6 | `comite/eliminar-idea-estudiante.jsp` (borra `revision`, `entrega`, `proyecto` en una transacción); `m6b` |
| 61 | El comité solo revisa las ideas de estudiantes | Cumple | M6 | Sin altas en las páginas del comité; `m6b` |
| 62 | Listar proyectos con estudiantes, director, evaluador y estado | Cumple | M8 | `comite/proyectos.jsp` (`v_proyecto`); `m8a` |
| 63 | Idea del banco: asignar solo el evaluador (director es el docente de la idea) | Cumple | M6, M8 | `comite/guardar-revision-fase1.jsp` rama `BANCO_DOCENTE`; `m6b`, `m8b`, `guion-verificado.ps1` |
| 64 | Fase 3: aprobar/aplazar; al aprobar pasa a "Fase 4 \| Estudiante" | Cumple | M8 | `comite/guardar-calificacion.jsp`; `m8a`, `guion-verificado.ps1` |
| 65 | Fase 5: aprobar/aplazar; al aprobar pasa a "Fase 6 \| Comité" | Cumple | M8 | `comite/guardar-calificacion.jsp`; `m8a`, `guion-verificado.ps1` |
| 66 | Fase 6: radicado y cierre → Finalizado | Cumple | M8 | `comite/guardar-calificacion.jsp` (rama cierre) + trigger; `m8a`, `m8b`, `guion-verificado.ps1` |
| 67 | Un proyecto finalizado ya no se gestiona | Cumple | M8 | Checks en `comite/gestionar-fase.jsp`, `comite/guardar-calificacion.jsp`, `docente/*`; `m8a`, `m8b`, `guion-verificado.ps1` |
| 68 | Botón por fase en cada fila del comité | Cumple | M8 | `comite/proyectos.jsp`; `m8a`, `m8b` |
| 69 | El ID del proyecto lo genera el sistema | Cumple | M1 | `AUTO_INCREMENT` (AI de `proyecto` = 1; la interfaz nunca asigna ID) |
| 70 | El proyecto se crea en la Fase 1, lo crea el estudiante | Cumple | M7 | `estudiante/guardar-proyecto.jsp`; trigger fija "Fase 1 \| Estudiante"; `m7a`, `guion-verificado.ps1` |
| 71 | Un único usuario de comité | Cumple | M1, M3 | `SELECT COUNT(*) FROM usuario WHERE id_rol=2` = **1**; decisión (c) de M4 lo impide crear otro; `m4` |
| 72 | El comité solo actúa en su turno | Cumple | M8 | Checks de turno en las páginas del comité; `m8a`, `guion-verificado.ps1` |
| 73 | El docente propone ideas con todos sus campos | Cumple | M5 | `docente/idea-form.jsp`, `docente/guardar-idea.jsp`; `m5` |
| 74 | El docente ve estado y disponibilidad de sus ideas | Cumple | M5 | `docente/ideas.jsp`; `m5` |
| 75 | Al aprobarse la idea, el docente queda como director | Cumple | M1, M5 | Trigger `trg_proyecto_ai` (`id_director = docente de la idea`); `m5`, `m6b`, `guion-verificado.ps1` |
| 76 | Vista única "Mis proyectos" con columna "Mi rol" | Cumple | M8 | `docente/proyectos.jsp` (una sola tabla, `CASE` Director/Evaluador); `m8b`, `guion-verificado.ps1` |
| 77 | Acciones por fila según rol y estado; fuera de turno solo lectura | Cumple | M8 | `docente/proyectos.jsp`; `m8b` |
| 78 | Director en Fases 2 y 4: consultar documento e historial | Cumple | M8 | `docente/gestionar-fase.jsp` + `documentos-proyecto.jsp`; `m8b` |
| 79 | Director califica (aprueba → evaluador; aplaza → estudiante) | Cumple | M8 | `docente/guardar-calificacion.jsp`; `m8b`, `guion-verificado.ps1` |
| 80 | Evaluador en fases 3 y 5: consultar documento e historial | Cumple | M8 | `docente/gestionar-fase.jsp`; `m8b` |
| 81 | Evaluador califica con comentarios | Cumple | M8 | `docente/guardar-calificacion.jsp`; `m8b`, `guion-verificado.ps1` |
| 82 | Al aprobar la propuesta (Fase 3) pasa al comité | Cumple | M8 | Triggers; `m8a`, `m8b`, `guion-verificado.ps1` |
| 83 | Al aprobar el informe (Fase 5) pasa al comité para el cierre | Cumple | M8 | Triggers; `m8a`, `m8b`, `guion-verificado.ps1` |
| 84 | El docente solo actúa en sus proyectos y en su turno | Cumple | M8 | Filtro `id_director = ? OR id_evaluador = ?`; `m8b` |
| 85 | Un docente no es director y evaluador del mismo proyecto | Cumple | M8 | `CHECK` + trigger; `m8b` |
| 86 | El estudiante ve el banco aprobado y disponible y elige | Cumple | M7 | `estudiante/banco-ideas.jsp`; `m7a`, `guion-verificado.ps1` |
| 87 | El estudiante propone su propia idea | Cumple | M7 | `estudiante/idea-propia.jsp`, `estudiante/guardar-proyecto.jsp`; `m7a` |
| 88 | Segundo estudiante opcional | Cumple | M7 | `estudiante/idea-propia.jsp`, `estudiante/tomar-idea.jsp` (`id_estudiante2`); `m7a`, `guion-verificado.ps1` |
| 89 | Soporte de pago como URL | Cumple | M7 | `estudiante/guardar-proyecto.jsp` + `url-valida.jsp`; `m7a`, `guion-verificado.ps1` |
| 90 | Propuesta, informe y anexos como URL | Cumple | M7 | `estudiante/enviar-documento.jsp`, `estudiante/guardar-entrega.jsp`; `m7b` |
| 91 | Reenviar la versión corregida | Cumple | M7 | `estudiante/corregir-idea.jsp`, `estudiante/guardar-correccion.jsp`; `m7a`, `m7b` |
| 92 | Historial de versiones con fechas | Cumple | M7 | `v_historial_entregas`; `documentos-proyecto.jsp`; `m7b` |
| 93 | El estudiante ve su estado/fase y el seguimiento | Cumple | M7 | `estudiante/proyecto.jsp`; `m7a`, `guion-verificado.ps1` |
| 94 | El estudiante ve al director | Cumple | M7 | `estudiante/proyecto.jsp`; `m7a`, `m7b` |
| 95 | El estudiante no ve al evaluador | Cumple | M1, M7 | Las páginas del estudiante usan **solo** `v_proyecto_estudiante` (que no expone `id_evaluador`); en el historial sale "Evaluación" sin nombre; `m7a`, `m7b`, `guion-verificado.ps1` |
| 96 | Solo se cargan documentos cuando el turno es Estudiante | Cumple | M1, M7 | Trigger (`SIGNAL` 45000); `m7b` |
| 97 | Solo el estudiante 1 ve y gestiona el proyecto | Cumple | M1, M3, M7 | Filtro `id_estudiante1 = ?`; el estudiante 2 recibe "No tienes permiso para ver este proyecto"; `m7a`, `m7b`, `guion-verificado.ps1` (20i) |

---

## Hallazgos

No toda la auditoría termina en "Cumple": hay puntos que no se pueden cerrar por código o que dependen de una decisión. **No se corrigió nada en silencio**; cada hallazgo espera tu decisión.

**H1 — Requerimiento 6 (diseño basado en el software institucional).** El seguimiento de las seis fases está implementado y probado (`seguimiento-fases.jsp`; fase actual en verde). Que el diseño *coincida con el software institucional* no se puede comprobar por código: requiere una revisión humana (comparar visualmente con el sistema real). Propuesta: revisar en la demostración y, si hace falta, ajustar el CSS del seguimiento.

**H2 — Requerimiento 13 (JDK 21.0.6).** Tomcat 8.5.96 ✔, pero el JDK instalado y usado es **25.0.2**, no 21.0.6. La aplicación compila y ejecuta con JDK 25, pero no es la versión pedida. Propuesta (ya acordada para M10 en `PLAN.md` §7.2): desplegar con una imagen que traiga JDK 21; en local se mantiene el JDK 25 mientras no haya un JDK 21 instalado, o se instala el 21.0.6 si lo exige la entrega.

**H3 — Requerimientos 14 y 15 (base en la nube y despliegue online).** Por ahora solo existe la base local (`conexion.jsp` apunta a MariaDB/XAMPP) y el proyecto no está en GitHub ni desplegado. Propuesta: resolverlos en M10 con `META-INF/context.xml` (credenciales por variables de entorno) y `Dockerfile`.

**H4 — Requerimiento 11 (comentario inexacto en `web.xml`).** El código cumple: la auditoría no encontró ningún scriptlet real (solo comentarios `<%--`), ni archivos `.java`, ni `pom.xml`/`build.gradle`. Pero el comentario de `web.xml` dice que los scriptlets quedan "prohibidos por configuración de Jasper", y el `<jsp-property-group>` actual no contiene ningún elemento que los prohíba (JSP no tiene un elemento estándar para eso; el cumplimiento es por disciplina y por la auditoría). Propuesta: corregir el comentario para que no prometa una garantía que no existe (cambio de documentación, sin efecto en la ejecución). Este hallazgo **no** cambia el estado del requerimiento (sigue en Cumple).

---

## Resumen

| Estado | Requerimientos | Cantidad |
|---|---|---|
| Cumple | 1–5, 7–11, 16–22, 32–97 (con los subcasos 20a–20i) | 83 |
| Cumple con ajuste por indicación del docente | 12 | 1 |
| Requiere revisión humana | 6, 13 | 2 |
| Pendiente de despliegue | 14, 15 | 2 |
| No aplica por alcance | 23–31 | 9 |
| Incumple | — | 0 |
| **Total** | | **97** |

Ningún requerimiento del alcance acordado queda **Incumple**. La matriz se apoya en las suites de `C:\sistemastg-tests` (`m3` 45, `m4` 79, `m5` 62, `m6a` 82, `m6b` 94, `m7a` 152, `m7b` 104, `m7c` 65, `m8a` 92, `m8b` 130, `m9a` 705 y `guion-verificado.ps1`) y en el guion verificado de punta a punta (req. 22).
