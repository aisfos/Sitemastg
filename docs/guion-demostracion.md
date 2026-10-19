# Guion de demostración — Sistemas TG

Recorrido completo de punta a punta (req. 22) partiendo de la **base en baseline**. Cada escena indica quién actúa, en qué pantalla, qué escribe exactamente y qué debe verse en pantalla. En todas las pantallas de proyecto se muestra el **seguimiento de las seis fases** (fase actual en verde) y, cuando corresponde, el botón **"Gestionar fases"** habilitado o deshabilitado.

> Todos los enlaces de ejemplo (`https://example.com/...`) valen tal cual: el sistema solo valida el formato `http://` o `https://`, no que existan.

---

## (a) Preparación

1. **Encender MySQL y Tomcat** desde el panel de control de XAMPP (botones *Start* de **MySQL** y **Tomcat**). Comprobar que `http://localhost:8080/sistemastg/` abre la página de aterrizaje.
2. **Dejar la base en baseline antes de cada demostración.** Desde `C:\sistemastg-tests`:
   ```powershell
   Get-Content sistemas_tg.sql | & C:\xampp\mysql\bin\mysql.exe -u root   # solo si hay que reimportar (DESTRUCTIVO)
   ```
   Lo normal es **no reimportar**: basta con ejecutar la limpieza del guion, que borra proyectos, usuarios e ideas temporales y restaura los contadores:
   ```powershell
   cmd /c "C:\xampp\mysql\bin\mysql.exe -u root sistemas_tg < C:\sistemastg-tests\guion_cleanup.sql"
   ```
3. **Comprobar el baseline** (debe dar exactamente esto):
   ```powershell
   & C:\xampp\mysql\bin\mysql.exe -u root -B -N sistemas_tg -e "SELECT CONCAT((SELECT COUNT(*) FROM usuario),' usuarios, ',(SELECT COUNT(*) FROM idea_docente),' ideas, ',(SELECT COUNT(*) FROM proyecto),' proyectos, ',(SELECT COUNT(*) FROM entrega),' entregas, ',(SELECT COUNT(*) FROM revision),' revisiones')"
   ```
   Resultado esperado: **`11 usuarios, 5 ideas, 0 proyectos, 0 entregas, 0 revisiones`** (usuarios con `AUTO_INCREMENT` 12, ideas 6, y 1 en proyecto/entrega/revisión).
4. **Usuarios de prueba** (los mismos que lista el bloque desplegable del login, req. 36):

   | Documento | Contraseña | Rol | Nombre |
   |---|---|---|---|
   | 1000000001 | `admin123` | Administrador | Carlos Andrés Mejía Ruiz |
   | 9000000001 | `comite123` | Comité | Comité de Trabajos de Grado |
   | 1090000101 | `docente123` | Docente | Laura Marcela Gómez Prada |
   | 1090000102 | `docente123` | Docente | Jorge Iván Rueda Castillo |
   | 1090000103 | `docente123` | Docente | Sandra Milena Ortiz Duarte |
   | 1090000104 | `docente123` | Docente | Andrés Felipe Cáceres León |
   | 1100000201 | `estudiante123` | Estudiante | Juan Camilo Pérez Torres |
   | 1100000202 | `estudiante123` | Estudiante | María Fernanda Suárez Díaz |
   | 1100000203 | `estudiante123` | Estudiante | Daniel Esteban Prada Rojas |
   | 1100000204 | `estudiante123` | Estudiante | Valentina Mantilla Cruz |
   | 1100000205 | `estudiante123` | Estudiante | Juan Camilo Pérez Torres |

---

## (a.1) Modo exploración con datos de demostración

El guion oficial parte **siempre de cero proyectos** (el baseline del paso 2): con la base limpia se recorren a mano las seis fases. Si solo quieres *explorar* la aplicación con datos ya cargados (todas las pantallas y los doce estados posibles, req. 85), carga el conjunto de demostración y, al terminar, quítalo: deja la base idéntica al baseline.

Cargar el conjunto de demostración (desde `C:\sistemastg-tests`):
```powershell
cmd /c "C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 sistemas_tg < C:\sistemastg-tests\datos_demo.sql"
```

Quitarlo (vuelve al baseline: 11 usuarios, 5 ideas, 0 proyectos):
```powershell
cmd /c "C:\xampp\mysql\bin\mysql.exe -u root --default-character-set=utf8mb4 sistemas_tg < C:\sistemastg-tests\quitar_demo.sql"
```

Qué trae (fuente: `docs/datos_demo.sql`):
- **21 usuarios nuevos** (ids 12 a 32): 6 docentes y 15 estudiantes, con las mismas claves de prueba (`docente123` y `estudiante123`). No crea administradores ni comité.
- **13 ideas nuevas** (el banco queda en 18): 5 aprobadas sin tomar, 4 que ya tomó un proyecto, 3 pendientes y 1 aplazada.
- **15 proyectos** que cubren los doce estados posibles (`Fase 1 | Comité`, `Fase 1 | Estudiante`, `Fase 2 | Director`, `Fase 2 | Estudiante`, `Fase 3 | Evaluador`, `Fase 3 | Comité`, `Fase 4 | Director`, `Fase 4 | Estudiante`, `Fase 5 | Evaluador`, `Fase 5 | Comité`, `Fase 6 | Comité` y `Finalizado`), con propuestas, informes, anexos, versiones corregidas (v2) y calificaciones aprobadas y aplazadas.
- Dos proyectos **finalizados** con radicado `RAD-2026-0001` y `RAD-2026-0002`.

> `run-all.ps1` detecta y quita estos datos automáticamente (usuarios con id mayor que 11) antes de comprobar el baseline, así que las pruebas nunca arrancan con ellos cargados.

Con la demo cargada, `powershell -NoProfile -ExecutionPolicy Bypass -File C:\sistemastg-tests\m9e-demo-verify.ps1` la comprueba por la aplicación (curl con sesiones reales de los usuarios nuevos): 108 comprobaciones (Mis proyectos del docente, privacidad del estudiante, botones del comité y del administrador, y banco de ideas).

### Usuarios para explorar la demo

Los números de proyecto (`#4`, `#5`, …) son los de la columna **ID** de los listados. Todas las cuentas usan las claves de prueba (`admin123`, `comite123`, `docente123`, `estudiante123`).

| Rol | Documento | Clave | Nombre | Qué verás (y dónde está "tu turno") |
|---|---|---|---|---|
| Administrador | 1000000001 | `admin123` | Carlos Andrés Mejía Ruiz | Los **15 proyectos** en solo lectura: **sin** "Gestionar fases" ni ninguna acción (req. 8c, 47). |
| Comité | 9000000001 | `comite123` | Comité de Trabajos de Grado | Los **15 proyectos**. **Tu turno** (botón habilitado) en **#1** y **#2** (Fase 1 \| Comité), **#8** (Fase 3 \| Comité), **#12** (Fase 5 \| Comité) y **#13** (Fase 6 \| Comité); los otros diez salen deshabilitados. |
| Docente | 1090000106 | `docente123` | Diana Carolina Salazar Ríos | Cuatro proyectos: **#4** *Director* (Fase 2 \| Estudiante), **#5** *Evaluador* (Fase 2 \| Estudiante), **#6** *Director* (Fase 2 \| Director → **tu turno**) y **#15** *Director* (Finalizado). |
| Docente | 1090000105 | `docente123` | Álvaro José Restrepo Cano | Cuatro proyectos: director de **#2** (Fase 1 \| Comité) y **#5** (Fase 2 \| Estudiante); evaluador de **#6** (Fase 2 \| Director) y **#15** (Finalizado). **Ninguno** es tu turno. |
| Docente | 1090000103 | `docente123` | Sandra Milena Ortiz Duarte | Dos proyectos: **#11** *Evaluador* (Fase 5 \| Evaluador → **tu turno**) y **#12** *Director* (Fase 5 \| Comité). |
| Estudiante | 1100000208 | `estudiante123` | Laura Valentina Céspedes Mora | **#3** (Fase 1 \| Estudiante) con la **idea aplazada** por el comité → **tu turno**: corregir la idea y reenviarla. |
| Estudiante | 1100000210 | `estudiante123` | Sara Milena Ortega Prada | **#5** (Fase 2 \| Estudiante) → **tu turno**: enviar la propuesta. Ve a su director y **nunca** al evaluador (req. 95). |
| Estudiante | 1100000219 | `estudiante123` | Sebastián Ruiz Camacho | **#14 Finalizado** con radicado `RAD-2026-0001` (solo lectura, sin acciones). |

- Otras cuentas útiles: **1100000220** (María Fernanda Quintero Soto) es **homónima** de 1100000206 y tiene el otro proyecto finalizado (**#15**, `RAD-2026-0002`); **1100000214** (Isabella Ramírez Galeano) tiene **tu turno** en **#9** (Fase 4 \| Estudiante) para enviar el informe.
- El **banco de ideas** ofrece **7 ideas** aprobadas, disponibles y sin proyecto (**#1, #2, #10, #11, #12, #13 y #14**): son las únicas con "Tomar esta idea".

---

## (b) Escenas

### Escena 1 — Aterrizaje y botón "Sistemas TG" (req. 32, 33)
- **Quién:** nadie (sin sesión).
- **Pantalla:** `http://localhost:8080/sistemastg/` (`index.jsp`).
- **Qué hacer:** leer las frases motivadoras y pulsar el botón **"Sistemas TG"** del banner superior.
- **Resultado esperado:** se ve "Sistemas TG", la lista de las seis fases y frases como *"Estudiante, es tu oportunidad para desarrollar el mejor proyecto y destacar."* Al pulsar el botón se abre el **login**.

### Escena 2 — Errores de inicio de sesión y usuarios de prueba (req. 20a, 20b, 36)
- **Quién:** nadie (sin sesión).
- **Pantalla:** `http://localhost:8080/sistemastg/login.jsp`.
- **Qué hacer y qué debe verse:**
  1. Documento `1000000001`, contraseña `clave-mala`, rol **Administrador** → **"Usuario, contraseña o rol incorrectos"** (req. 20a).
  2. Documento `1000000001`, contraseña `admin123`, rol **Docente** → el **mismo** mensaje (el rol también cuenta, req. 20a).
  3. Documento `9999999999`, contraseña `x`, rol **Administrador** → el **mismo** mensaje.
  4. Dejar campos vacíos y pulsar el botón → **"Debes completar el número de documento, la contraseña y el rol"** (req. 20b).
  5. Desplegar **"Usuarios de prueba"** y comprobar que aparecen los 11 usuarios con su documento y su clave (req. 36).

### Escena 3 — Administrador: usuarios, recurso y proyectos (req. 40, 43, 20c, 44, 45, 47)
- **Quién:** Administrador `1000000001` / `admin123`.
- **Pantalla:** panel del administrador → **Usuarios** → **Nuevo usuario**.
- **Qué hacer y qué debe verse:**
  1. Tras entrar, se abre **`/admin/panel.jsp`**. El menú muestra *Mi panel · Usuarios · Calendario y formatos · Proyectos* (req. 35, 48).
  2. Crear un usuario: documento `5012345678`, nombre `Usuario Demo Guion`, tipo *Cédula*, contraseña `demo123`, rol **Estudiante**, nivel **Tecnología** → mensaje **"Usuario creado correctamente"** y aparece en el listado.
  3. Intentar crear **otro** usuario con el mismo documento `5012345678` → **"El número de documento ya está registrado"** (req. 20c).
  4. Abrir **Calendario y formatos**: se ven 3 enlaces clicables (calendario académico y los formatos F-DC-124 y F-DC-125), que abren en pestaña nueva (req. 44, 17).
  5. Abrir **Proyectos**: todavía **no hay proyectos**; el listado aparece vacío y **no hay ningún botón "Gestionar fases"** (req. 45, 47).
  6. **Limpiar:** eliminar `Usuario Demo Guion` desde el listado → desaparece. (El req. 46, borrar un usuario **con** proyectos, está implementado pero **no** forma parte de este guion.)

### Escena 4 — Docente: proponer una idea (req. 73, 74)
- **Quién:** Docente 3 (Laura Marcela Gómez) `1090000101` / `docente123`.
- **Pantalla:** **Mis ideas** → **Proponer idea**.
- **Qué hacer:** completar:
  - Título: `Analítica de datos para el seguimiento académico (demo)`
  - Objetivo: `Construir un tablero que apoye el seguimiento académico de los estudiantes.`
  - Línea: *Ingeniería de software*; Nivel: *Tecnología*; Periodo: *2026-1*.
- **Resultado esperado:** mensaje **"Idea propuesta correctamente"** y la idea aparece como **Pendiente / No disponible** en "Mis ideas" (req. 74).

### Escena 5 — Comité: aprobar la idea con acta (req. 49, 50, 54, 55)
- **Quién:** Comité `9000000001` / `comite123`.
- **Pantalla:** **Banco de ideas docente** → **Aprobar** de la idea de la escena 4.
- **Qué hacer:** número de acta `ACTA-GUION-01` → **Aprobar**.
- **Resultado esperado:** mensaje de aprobación; la idea queda **Aprobada / Disponible** y ya se ofrece a los estudiantes. (El comité **no** tiene opción de crear ideas, req. 54; la idea del docente se aprueba sin soporte de pago, req. 55.)

### Escena 6 — Estudiante: tomar la idea del banco con un segundo estudiante (req. 86, 88, 89 y 20d)
- **Quién:** Estudiante 7 (Juan Camilo Pérez Torres) `1100000201` / `estudiante123`.
- **Pantalla:** **Banco de ideas** → **Tomar esta idea**.
- **Qué hacer y qué debe verse:**
  1. En el banco se ve la idea de la escena 4 con su título, docente, línea y nivel (req. 86).
  2. Pulsar **Tomar esta idea**; en el formulario, elegir como segundo estudiante a **María Fernanda Suárez Díaz** (estudiante 8, req. 88).
  3. Escribir como soporte de pago `pago-demo` (sin `https://`) → **"La URL no tiene un formato válido"** (req. 20d).
  4. Escribir el soporte de pago correcto `https://example.com/pago-demo` → se crea el proyecto.
- **Resultado esperado:** el proyecto se crea y pasa **directamente al comité**: estado **"Fase 1 | Comité"** (req. 70). El **director es la docente que propuso la idea** (Laura Marcela Gómez), porque la idea venía del banco (req. 75, 63). El seguimiento marca la fase 1 en verde. El estudiante **no** ve ningún evaluador (req. 95).

### Escena 7 — El segundo estudiante intenta abrir el proyecto por URL (req. 20i, 97)
- **Quién:** Estudiante 8 (María Fernanda Suárez Díaz) `1100000202` / `estudiante123`.
- **Pantalla:** escribir a mano `http://localhost:8080/sistemastg/estudiante/proyecto.jsp?id=1`.
- **Resultado esperado:** **"No tienes permiso para ver este proyecto"** y vuelta a "Mis proyectos" (el segundo estudiante no ve el proyecto: `id_estudiante1` filtra todo).

### Escena 8 — Comité en la Fase 1: error del evaluador igual al director y aprobación (req. 20h, 57, 58, 63)
- **Quién:** Comité `9000000001` / `comite123`.
- **Pantalla:** **Ideas de estudiantes** → **Aprobar** del proyecto de la escena 6.
- **Qué hacer y qué debe verse:**
  1. Se ve el **soporte de pago** como enlace clicable (req. 57). El desplegable de director aparece **deshabilitado** con la docente autora (en las ideas del banco el director viene de la idea, req. 63).
  2. Acta `ACTA-GUION-02`, comentarios `Aprobación de la Fase 1 (demo)` y elegir como evaluador al **mismo docente director** (Laura Marcela Gómez) → **"El evaluador no puede ser el director del proyecto"** (req. 20h, 9).
  3. Corregir: elegir como evaluador a **Jorge Iván Rueda Castillo** (docente 4) → **Aprobar**.
- **Resultado esperado:** el estado pasa a **"Fase 2 | Estudiante"**; director = Laura Marcela Gómez, evaluador = Jorge Iván Rueda.

### Escena 9 — Estudiante: enviar la propuesta (req. 90, 17)
- **Quién:** Estudiante 7 `1100000201` / `estudiante123`.
- **Pantalla:** **Mis proyectos** → abrir el proyecto. Observar el seguimiento (fase 1 verde) y el estado **"Fase 2 | Estudiante"**.
- **Qué hacer:** **Enviar documento a revisión** con la URL `https://example.com/propuesta-demo`.
- **Resultado esperado:** mensaje **"Propuesta enviada a revisión"** y estado **"Fase 2 | Director"**. En la pantalla del estudiante **sigue sin aparecer el evaluador** (req. 95).

### Escena 10 — Director: aplazar y el estudiante reenvía (req. 5, 78, 79)
- **Quién (aplaza):** Docente 3 (directora) `1090000101` / `docente123`.
- **Pantalla:** **Mis proyectos** (columna "Mi rol" = *Director*; el botón **"Gestionar fases"** está **habilitado**) → **Gestionar fases** → calificar **Aplazado** con comentarios `Corregir la formulación del alcance (demo).`
- **Resultado esperado:** el proyecto vuelve a **"Fase 2 | Estudiante"** y el director ve el historial de versiones y sus observaciones (req. 78).
- **Quién (reenvía):** Estudiante 7 → **Subir versión corregida** con `https://example.com/propuesta-demo-v2`.
- **Resultado esperado:** el estado vuelve a **"Fase 2 | Director"** (historial con la versión 1 y la 2, req. 91, 92).

### Escena 11 — Director: aprobar la propuesta (req. 79, 3)
- **Quién:** Docente 3 `1090000101` / `docente123`.
- **Pantalla:** **Gestionar fases** (botón habilitado) → **Aprobado**, comentarios `Propuesta aprobada (demo).`
- **Resultado esperado:** el estado pasa a **"Fase 3 | Evaluador"** (el cambio de fase es automático, req. 3). El docente 3 ahora ve el botón **deshabilitado**.

### Escena 12 — Evaluador: aprobar la propuesta (req. 80, 81, 82)
- **Quién:** Docente 4 (Jorge Iván Rueda) `1090000102` / `docente123`.
- **Pantalla:** **Mis proyectos** (columna "Mi rol" = *Evaluador*, botón **habilitado**) → **Gestionar fases** → **Aprobado**, comentarios `Propuesta aprobada por el evaluador (demo).`
- **Resultado esperado:** el estado pasa a **"Fase 3 | Comité"** (req. 82).

### Escena 13 — Comité: aprobar la propuesta (req. 64, 68)
- **Quién:** Comité `9000000001` / `comite123`.
- **Pantalla:** **Proyectos** → la fila del proyecto muestra **"Fase 3 | Comité"** y el botón **"Gestionar fases"** **habilitado** → **Aprobado** con acta `ACTA-GUION-03`, comentarios `Propuesta aprobada por el comité (demo).`
- **Resultado esperado:** el estado pasa a **"Fase 4 | Estudiante"**. El seguimiento marca la fase 3 como completada y la 4 en verde.

### Escena 14 — Estudiante: enviar el informe con anexos (req. 90, 92)
- **Quién:** Estudiante 7 `1100000201` / `estudiante123`.
- **Pantalla:** abrir el proyecto (estado **"Fase 4 | Estudiante"**) → **Enviar a revisión**.
- **Qué hacer:** rellenar
  - Informe F-DC-125: `https://example.com/informe-demo`
  - Manual de usuario: `https://example.com/manual-usuario-demo`
  - Manual técnico: `https://example.com/manual-tecnico-demo`
  - Repositorio: `https://example.com/repositorio-demo`
- **Resultado esperado:** mensaje **"Informe y anexos enviados a revisión"** y estado **"Fase 4 | Director"**.

### Escena 15 — Director: aprobar el informe (req. 83)
- **Quién:** Docente 3 `1090000101` / `docente123`.
- **Pantalla:** **Gestionar fases** (habilitado) → **Aprobado**, comentarios `Informe aprobado por el director (demo).`
- **Resultado esperado:** estado **"Fase 5 | Evaluador"**.

### Escena 16 — Evaluador: aprobar el informe (req. 83)
- **Quién:** Docente 4 `1090000102` / `docente123`.
- **Pantalla:** **Gestionar fases** (habilitado) → **Aprobado**, comentarios `Informe aprobado por el evaluador (demo).`
- **Resultado esperado:** estado **"Fase 5 | Comité"**.

### Escena 17 — Comité: aprobar el informe (req. 65)
- **Quién:** Comité `9000000001` / `comite123`.
- **Pantalla:** **Proyectos** (estado **"Fase 5 | Comité"**, botón habilitado) → **Aprobado** con acta `ACTA-GUION-04`, comentarios `Informe aprobado por el comité (demo).`
- **Resultado esperado:** estado **"Fase 6 | Comité"**.

### Escena 18 — Comité: cerrar con radicado (req. 66, 67, 2)
- **Quién:** Comité `9000000001` / `comite123`.
- **Pantalla:** **Gestionar fases** de la fase 6.
- **Qué hacer:** radicado `RAD-GUION-2026`, comentarios `Cierre del proyecto (demo).` → **Cerrar proyecto**.
- **Resultado esperado:** el proyecto queda **"Finalizado"** para todos los roles; el seguimiento muestra las **seis fases en verde**. El botón **"Gestionar fases"** queda **deshabilitado** (req. 67).

### Escena 18b — Intento de actuar fuera de turno por URL (req. 20f)
- **Quién:** Comité `9000000001` (u otro rol) con el proyecto ya finalizado.
- **Pantalla:** escribir a mano `http://localhost:8080/sistemastg/comite/gestionar-fase.jsp?id=1`.
- **Resultado esperado:** **"El proyecto está finalizado y no puede gestionarse"** (req. 67). Para ver el mensaje de **fuera de turno** (req. 20f) basta con que, en cualquier momento anterior, un rol distinto del que tiene el turno abra su pantalla de gestión: por ejemplo, con el proyecto en **"Fase 2 | Estudiante"**, el director abre `docente/gestionar-fase.jsp?id=1` y recibe **"No es el turno de tu rol en la fase actual del proyecto"**.

### Escena 18-bis — Un estudiante intenta abrir una página de administrador (req. 20e, 38)
- **Quién:** Estudiante 7 `1100000201` / `estudiante123`.
- **Pantalla:** escribir a mano `http://localhost:8080/sistemastg/admin/panel.jsp`.
- **Resultado esperado:** **"No tienes permiso para acceder a esta página"** y vuelta a su panel. Sin sesión, cualquier página protegida redirige al login con **"Debes iniciar sesión"**.

### Escena 19 — Cierre de sesión en los cuatro roles (req. 37)
- **Quién:** Administrador, Comité, Docente y Estudiante, uno tras otro.
- **Pantalla:** enlace **"Cerrar sesión"** del menú (o `logout.jsp`).
- **Resultado esperado:** los cuatro vuelven al **login**; si se intenta abrir una página protegida con el enlace/cookie anterior, vuelve a pedir sesión (la sesión quedó invalidada).

---

## Si algo falla

1. **Reiniciar Tomcat** desde el panel de XAMPP (botón *Stop* y *Start*).
2. Si Jasper da `ClassNotFoundException: org.apache.jsp.<Pagina>_jsp` o "instancia de aplicación web ya ha sido detenida", **borrar** la carpeta de trabajo y volver a abrir:
   ```powershell
   Remove-Item -Recurse -Force C:\xampp\tomcat\work\Catalina\localhost\sistemastg
   ```
3. Si la base quedó a medias, **volver al baseline**:
   ```powershell
   cmd /c "C:\xampp\mysql\bin\mysql.exe -u root sistemas_tg < C:\sistemastg-tests\guion_cleanup.sql"
   ```
   y comprobar de nuevo `11 usuarios, 5 ideas, 0 proyectos, 0 entregas, 0 revisiones`.
4. Revisar el log del día en `C:\xampp\tomcat\logs\catalina.<yyyy-MM-dd>.log` (buscar `SEVERE` o `Exception`).

## Duración estimada

Entre **8 y 12 minutos** si solo se pulsa y se escribe lo indicado. Cada escena de calificación es de menos de un minuto; la creación de usuario, la idea y el proyecto (escenas 3 a 6) son las que más texto piden. El guion automatizado (`C:\sistemastg-tests\guion-verificado.ps1`) recorre las mismas escenas sin intervención.

> **Nota (req. 46):** el borrado de un usuario **con** proyectos asociados (con su mensaje de error) está implementado y probado en la suite M4, pero **no** forma parte de este guion, tal como se pidió.
