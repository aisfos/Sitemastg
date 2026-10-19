# **Requerimientos – Sistemas TG (versión corregida)** 

Los marcados con _(nuevo)_ o _(modificado)_ son los que cambié. El resto queda igual que en tu documento, solo renumerado. Quedan 98 requerimientos en total. 

## **4.1 General** 

### **_Requerimientos funcionales_** 

1. El sistema debe gestionar el trabajo de grado a lo largo de **seis fases** , cada una con responsables definidos _(modificado)_ : 



<!-- Start of picture text -->
Fase Nombre Quién esta a cargo<br>1 Ideaypago _ Estudiante (carga idea y soporte de pago) > Comité (revisa el pago, aprueba<br>con acta y asigna director y evaluador)<br>2 Propuestal _ Estudiante (carga F-DC-124) > Director<br>3 Propuesta Evaluador > Comité<br>pt<br>4 Informe I Estudiante (carga F-DC-125) > Director<br>5 Informe II Evaluador > Comité<br>6 Cierre Comité (registra el radicado y finaliza el proyecto)<br><!-- End of picture text -->

2. El sistema debe mostrar en cada proyecto un estado con el formato **Fase N | Rol** (por ejemplo, “Fase 2 | Director”), que indica en qué fase está y qué rol debe actuar. Al terminar el proceso el estado debe ser Finalizado. 

3. Cuando un rol aprueba su parte, el sistema debe cambiar automáticamente la fase y el rol responsable (por ejemplo, de “Fase 2 | Director” a “Fase 3 | Evaluador”). 

4. Todo documento revisado por el director, el evaluador o el comité se califica únicamente como Aprobado o Aplazado, con comentarios. “Aplazado” equivale a “correcciones”; no se usan “desaprobado”, “rechazado” ni “sin revisar”. 

5. Cuando un documento se aplaza, el proyecto debe volver al estudiante para que cargue una nueva versión corregida. 

6. El sistema debe mostrar el seguimiento de las fases de cada proyecto: al expandirlo se ven las seis fases, con la fase actual resaltada en verde y las demás en gris o blanco (diseño basado en el software institucional). 

7. El Administrador, el Comité, el Director y el Evaluador deben poder ver el seguimiento de las seis fases de un proyecto, aunque no intervengan en la fase actual. Solo pueden realizar acciones cuando el estado indica que es su turno y el cuadro de esa fase está en verde. 

8. _(nuevo)_ El Comité, el Director y el Evaluador tienen un botón **“Gestionar fases”** en cada proyecto. 

   - a. El botón se habilita solo cuando el estado indica su rol, y da acceso a las acciones de esa fase. 

   - b. En cualquier otro estado el botón aparece deshabilitado, pero el seguimiento de las seis fases sigue visible. 

   - c. El Administrador y el Estudiante no tienen este botón. 

9. _(nuevo)_ En un mismo proyecto, el evaluador no puede ser el director. Un mismo docente sí puede ser director en un proyecto y evaluador en otro. 

### **_Requerimientos no funcionales_** 

### **Tecnología y despliegue** 

10. El proyecto será desarrollado con JSP + JSTL (versión 1.2, año 2006) + JDBC, y JavaScript únicamente del lado del cliente (frontend). No se usa Node.js. 

11. No se permiten Scriptlets (<% %>), Maven ni Servlets. La única excepción es la página de aterrizaje, que puede desarrollarse con un Servlet (una clase Java, archivo .java). 

12. Se deben usar fragmentos reutilizables (JSPF), por ejemplo para el encabezado, el pie de página, el menú y la verificación de sesión. 

13. Entorno de ejecución: Apache Tomcat 8.5.96 y Java (JDK) 21.0.6, compatibles con JSTL 1.2. 

14. Base de datos relacional: MySQL local (XAMPP v3.3.0) para desarrollo y pruebas, y Mysql en la nube para la versión online. La base de datos en la nube es obligatoria. 

15. El proyecto debe estar en GitHub y desplegarse online (por ejemplo, en Render) con la base de datos en la nube, además de poder probarse en local. 

16. La base de datos debe usar llaves foráneas, y el rol debe ser una tabla aparte para que un mismo docente pueda ser director y evaluador desde un solo usuario. 

17. Los archivos se manejan como enlaces URL clicables, no como adjuntos (idea, pago, propuesta, informe y anexos). Estos campos deben guardarse y validarse como URL, no como texto simple. 

### **Datos y consultas** 

18. Los listados deben mostrar datos de varias tablas relacionadas (por ejemplo, al mostrar un proyecto se muestran los nombres del estudiante, el director y el evaluador, en vez de sus IDs), y cada rol solo ve sus registros (el director, solo los proyectos donde él es el director). 

19. Todos los usuarios se registran con nombre completo, para distinguir homónimos, y con un número de documento único. 

### **Calidad** 

20. _(modificado)_ El sistema debe mostrar mensajes claros ante los errores, como mínimo en estos casos: 

   - a. Usuario, contraseña o rol incorrectos al iniciar sesión. 

   - b. Campos obligatorios vacíos. 

   - c. Número de documento ya registrado. 

   - d. URL con formato inválido. 

   - e. Intento de abrir una página sin sesión o sin permiso del rol. 

   - f. Intento de actuar sobre un proyecto fuera de la fase del rol. 

   - g. Intento de eliminar un usuario que tiene proyectos asociados. 

   - h. _(nuevo)_ Intento de asignar como evaluador al director del mismo proyecto. 

   - i. _(nuevo)_ Intento de un estudiante vinculado (estudiante 2) de abrir un proyecto que no creó. 

21. Trazabilidad: todo el proceso queda registrado, con historial de versiones y fechas. 

22. Demostración del software funcionando: el sistema debe poder recorrerse completo, de punta a punta, siguiendo el guion de usuario. Para eso debe haber datos de ejemplo: un administrador, varios estudiantes, varios docentes (con rol de director y evaluador) y un único usuario de comité. 

### **_Alcance investigado y no implementado_** 

23. Correos y notificaciones: este software no envía correos ni notificaciones. 

24. Fase 0, secretarias y validación de créditos: no hay fase 0 ni rol de secretaria. El administrador, al registrar a un estudiante, da por hecho que cumple los requisitos para iniciar el trabajo de grado. 

25. Modalidades de grado: no se utilizan, para no meterse con créditos y mantener el software simplificado. 

26. Estado “Rechazado”: por recomendación del profesor no se utiliza. 

27. Consecutivo de proyecto: no se genera el consecutivo del software institucional. 

28. Retiros, cambios y prórrogas: no se implementan el retiro de un estudiante o del proyecto, el cambio de director o evaluador, la prórroga ni el plazo de 90 a 180 días para el informe final. 

29. Sustentación: no se incluye la sustentación final del software institucional. 

30. Recuperación de contraseña: no se implementa. 

31. Otras funciones del software institucional: informe de similitud (Turnitin), exención por pruebas TyT o Saber Pro, PQRs, asistente de chat, panel de métricas y enlace con el repositorio institucional. 

## **4.2 Autenticación y acceso** 

### **_Requerimientos funcionales_** 

32. El sistema debe tener una página de aterrizaje antes del inicio de sesión, con mensajes motivadores para el estudiante (puede ser un portal informativo), por ejemplo: “Estudiante, es tu oportunidad para desarrollar el mejor proyecto y destacar”. 

33. La página de aterrizaje debe tener un botón llamado “Sistemas TG” (en el banner superior) para ingresar al sistema. 

34. El inicio de sesión debe validar usuario y contraseña, y también el rol, para redirigir al panel (dashboard) que corresponde. 

35. Cada rol debe ver solo las opciones que le corresponden. 

36. Debe existir una lista o botón con los usuarios de prueba y sus claves, para facilitar las pruebas. 

37. El cierre de sesión debe funcionar en todos los roles. En la demostración de 2022 este botón falló, por eso se exige expresamente. 

### **_Requerimientos no funcionales_** 

38. Control de acceso en cada página. Si un estudiante escribe a mano la dirección de una página de administrador (/admin/usuarios.jsp), la página no debe abrir. Cada página debe revisar al inicio la sesión y el rol (con JSTL, c:if y c:redirect, o un JSPF común). Ocultar opciones del menú no es suficiente. 

39. Claves en texto plano (limitación). Como la lista de pruebas muestra las claves, estas van en texto plano. 

## **4.3 Administrador** 

### **_Requerimientos funcionales_** 

40. Registrar usuarios con nombre completo, tipo de documento, número de documento, contraseña y rol. Si el usuario es estudiante, también su nivel académico (Tecnología o Ingeniería). 

41. Actualizar usuarios (nombre, tipo de documento, número de documento, contraseña, nivel académico si es estudiante, y rol). El ID no es editable. 

42. Eliminar usuarios (con la restricción del req. 46). 

43. Listar todos los usuarios. 

44. Consultar el calendario académico y los formatos de grado, que son enlaces URL. 

45. Visualizar todo el proceso: todos los proyectos, con su fase y el rol que debe actuar. 

### **_Requerimientos no funcionales_** 

46. No se pueden eliminar usuarios que ya tengan proyectos, porque la universidad conserva el registro de todos los trabajos de grado. Se implementa pero no se prueba en el guion. 

47. El administrador solo puede visualizar los proyectos. No puede enviar documentos ni modificar el avance del proceso. 

48. Solo el administrador crea usuarios: el estudiante no se registra por sí mismo. 

## **4.4 Comité – Banco de Ideas Docente** 

Pantalla donde el comité revisa las ideas que suben los docentes directores. 

### **_Requerimientos funcionales_** 

49. _(modificado)_ Consultar las ideas registradas por los docentes directores en el Banco de Ideas, con: ID, título, objetivo, línea de investigación, nivel académico (Tecnología o Ingeniería), periodo académico, docente que la propuso, estado (Pendiente, Aprobada o Aplazada) y disponibilidad (Disponible o No disponible). 

50. _(modificado)_ Aprobar una idea pendiente, registrando el número de acta. Al aprobarse, la idea se publica y queda disponible para que los estudiantes la tomen. 

51. _(modificado)_ Aplazar una idea, registrando el número de acta y el motivo, para que el docente la corrija. No se usa “rechazar”. 

52. Actualizar el estado y la disponibilidad de una idea. 

53. Eliminar ideas. 

### **_Requerimientos no funcionales_** 

54. El comité solo revisa las ideas del banco; no las crea. 

55. La idea de un docente se aprueba directamente, sin soporte de pago, porque quien paga es el estudiante. 

## **4.5 Comité – Propuesta de Ideas Estudiante** 

Pantalla donde el comité revisa las ideas que proponen los estudiantes (el nombre puede ajustarse). 

### **_Requerimientos funcionales_** 

56. Ver las ideas propuestas por estudiantes, con: título, descripción, línea de investigación, estudiante(s), nivel académico, soporte de pago (URL clicable) y estado (Pendiente, Aprobada o Aplazada). 

57. Revisar el soporte de pago que el estudiante carga junto con la idea. Una idea de estudiante solo puede aprobarse si tiene soporte de pago. 

58. _(modificado)_ Aprobar una idea, registrando el número de acta y asignando el director y el evaluador. El evaluador no puede ser el director (req. 9): la lista de evaluadores excluye al director elegido. 

59. Aplazar una idea, registrando el número de acta y el motivo, para que el estudiante la corrija. 

60. Eliminar ideas. 

### **_Requerimientos no funcionales_** 

61. El comité solo revisa estas ideas; no las crea. 

## **4.6 Comité – Proyectos** 

**_Requerimientos funcionales_** 

62. Listar todos los proyectos con: ID, estudiante 1, estudiante 2 (si lo hay), título de la idea, director, evaluador y estado (Fase N | Rol o Finalizado). 

63. _(modificado)_ Cuando un estudiante toma una idea del Banco de Ideas Docente y sube el pago, revisar el pago y asignar solo el evaluador. El director es el docente que propuso la idea, por lo que la lista de evaluadores lo excluye. 

64. En la Fase 3 (Propuesta II), aprobar o aplazar la propuesta que aprobó el evaluador. Si la aprueba, el estado pasa a “Fase 4 | Estudiante”. 

65. En la Fase 5 (Informe II), aprobar o aplazar el informe que aprobó el evaluador. Si lo aprueba, el estado pasa a “Fase 6 | Comité”. 

66. En la Fase 6 (Cierre), registrar el radicado y cerrar el proyecto. Si lo aprueba, el estado pasa a Finalizado para todos los roles. 

67. Un proyecto finalizado no puede volver a gestionarse: se muestra con el estado “Finalizado”. 

68. _(nuevo)_ Cada proyecto del listado tiene el botón **“Gestionar fases”** (req. 8). Se habilita solo en los estados “Comité” (fases 1, 3, 5 y 6) y abre las acciones de esa fase: revisar el pago y asignar evaluador, aprobar o aplazar con número de acta, o registrar el radicado. Fuera de su turno el botón está deshabilitado, pero el comité puede ver el seguimiento de las seis fases. 

### **_Requerimientos no funcionales_** 

69. El ID del proyecto lo genera el sistema automáticamente. 

70. El proyecto se crea en la Fase 1, cuando el estudiante sube la idea; el comité no registra proyectos manualmente. 

71. Hay un único usuario de comité, compartido por los seis profesores que lo integran. Los profesores acceden a él además de su usuario de docente (lógica de negocio). 

72. El comité solo puede actuar cuando el estado del proyecto indica “Comité” (fases 1, 3, 5 y 6). 

## **4.7 Docente (director y evaluador)** 

### **_Requerimientos funcionales_** 

73. Proponer ideas en el Banco de Ideas Docente, con: título, objetivo, línea de investigación, nivel académico (Tecnología o Ingeniería) y periodo académico. 

74. Ver el estado de las ideas que propuso (Pendiente, Aprobada o Aplazada) y su disponibilidad. 

75. Al proponer una idea, el docente queda automáticamente como director del proyecto de la idea. 

76. _(modificado)_ El docente tiene una **vista única, “Mis proyectos”** , con todos los proyectos en los que participa, su estado y una columna **“Mi rol”** (Director o Evaluador). No hay secciones desplegables, pestañas ni menús separados por función. 

77. _(modificado)_ En cada fila, las acciones dependen del rol del docente en ese proyecto y del estado. Con el estado de su rol, el botón “Gestionar fases” (req. 8) se habilita. Fuera de su turno, la fila es de solo lectura y el seguimiento de las seis fases sigue visible. 

78. Cuando es director y el estado es “Fase 2 | Director” o “Fase 4 | Director”, consultar el documento (propuesta F-DC-124 o informe F-DC-125) y el historial de versiones. 

79. Como director, calificar con Aprobado o Aplazado, con comentarios. Al aprobar, el proyecto pasa al evaluador (“Fase 3 | Evaluador” o “Fase 5 | Evaluador”). Al aplazar, vuelve al estudiante. 

80. Cuando es evaluador y el estado es “Fase 3 | Evaluador” o “Fase 5 | Evaluador”, consultar el documento y el historial de versiones. 

81. Como evaluador, calificar con Aprobado o Aplazado, con comentarios. 

82. Al aprobar la propuesta (Fase 3), el proyecto pasa al comité. Si el comité lo aprueba, el estudiante continúa con el informe y el ciclo vuelve a comenzar. 

83. Al aprobar el informe (Fase 5), el proyecto pasa al comité para el cierre. 

### **_Requerimientos no funcionales_** 

84. El docente solo puede actuar como director o evaluador sobre los proyectos que tiene asignados, y solo cuando el estado muestra su rol. 

85. _(nuevo)_ Un docente no puede ser director y evaluador del mismo proyecto (req. 9). Sí puede serlo en proyectos distintos, desde un mismo usuario y una misma sesión. 

## **4.8 Estudiante** 

### **_Requerimientos funcionales_** 

86. Ver el Banco de Ideas Docente (solo las ideas aprobadas y disponibles) y elegir una. 

87. Proponer una idea propia desde “Mis Proyectos”, con título, descripción, línea de investigación y el soporte de pago (URL clicable). 

88. _(modificado)_ Al crear el proyecto, elegir opcionalmente a un segundo estudiante mediante una lista desplegable (el estudiante 1 es obligatorio y el estudiante 2 es opcional). El estudiante 2 queda registrado solo como integrante del equipo. 

89. Subir el soporte de pago como URL clicable, tanto para una idea propia como para una idea del banco. 

90. Subir el enlace URL de la propuesta (F-DC-124), del informe (F-DC-125) y los anexos del informe final (manual de usuario, manual técnico y repositorio), todos como URL clicables. 

91. Volver a subir un documento corregido (también una URL clicable) cuando el director, el evaluador o el comité lo aplazan. 

92. Mantener un historial de entregas o versiones, con ID del proyecto, enlace y fecha de cada versión. 

93. Ver el estado y la fase actual de su proyecto, con el seguimiento de las fases. 

94. Ver el director asignado. 

### **_Requerimientos no funcionales_** 

95. El estudiante no puede ver quién es el evaluador, para que no lo confunda con el director. Quien hace el seguimiento del trabajo es el director. 

96. El estudiante solo puede cargar documentos cuando el estado del proyecto indica “Estudiante”. 

97. _(modificado)_ El proyecto lo visualiza únicamente el estudiante que lo creó (estudiante 1). Al estudiante 2 no le aparece en su cuenta ni puede actuar sobre él; si intenta abrirlo escribiendo la dirección a mano, el sistema muestra el mensaje de “sin permiso” (req. 20 y 38). 

