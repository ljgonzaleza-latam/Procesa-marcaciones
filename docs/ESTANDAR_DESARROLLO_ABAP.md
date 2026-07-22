# Estándar de Desarrollos SAP S/4

**Grupo LATAM Airlines — Estándar de Desarrollo SAP**

| Campo | Valor |
|---|---|
| Versión | 1.0 |
| Fecha de Creación | 13.02.2024 |
| Fecha de última Publicación | 19.04.2024 |
| Tipo de documento | Estándar de Desarrollo SAP S/4 |

---

## Índice

1. Introducción
2. Objetivo
3. Alcance
4. Responsabilidades
   - 4.1. Arquitectura de Ciberseguridad
   - 4.2. Arquitectura Empresarial
   - 4.3. Infraestructura
5. Levantamiento de Solicitudes de Desarrollo
6. Ambientes de Trabajo
   - 6.1. Desarrollo
   - 6.2. Calidad
   - 6.3. Producción
7. Seguridad SAP
8. Transporte a Ambiente de Producción
9. Seguimiento
10. Formato de Código (Pretty Printer)
11. Convenciones Generales
    - 11.1. Variables
    - 11.2. Copias de programas estándar SAP
    - 11.3. Actualizaciones directas a Tablas
    - 11.4. Código reutilizable
    - 11.5. Textos Hardcodes
    - 11.6. Manejo de errores
    - 11.7. Comentarios
    - 11.8. Comentarios para modificaciones
    - 11.9. Programas ABAP
    - 11.10. Código Reusable
    - 11.11. Dictionary Objects
12. Transacciones ABAP
13. Traducciones
14. S4Hana
    - 14.1. Core Data Services (CDS)
    - 14.2. Data Definition Language (DDL)
    - 14.3. Data Control Language (DCL)
15. Dynpro – Webdynpro ABAP
16. Workflow
17. Web Services
18. Select Correctos para HANA
19. Carga y Descarga de Archivos
20. Advance List View (ALV)
21. Lectura y Generación de Archivo en Servidor Unix
22. Controles en Operaciones Matemáticas
23. Mantenedores de tablas no estándares
24. Envío de correos desde SAP
25. Programa con ejecución de fondo Latam
26. Control de ejecución de procesos de fondo duplicados
27. Restricciones
28. Consideraciones de Optimización
29. Recomendaciones
    - 29.1. Clean Code
30. Anexos
    - 30.1. Anexo 1 – Frente Funcional
    - 30.2. Anexo 2 – Módulos

---

## 1. Introducción

El presente documento describe el estándar de desarrollo, con su respectiva convención de nombre, que se debe considerar al momento de realizar cualquier desarrollo o mantención en el lenguaje de programación ABAP/4 en cualquiera de las plataformas SAP en LATAM.

## 2. Objetivo

El objetivo es establecer directrices de programación, desarrollo y estándares de testeo que deberán ser estrictamente cumplidas por todos los involucrados en desarrollos SAP, sean internos o externos de LATAM.

## 3. Alcance

Toda utilización de servicios en la nube debe considerar los conceptos de seguridad, protección de datos, cumplimiento de las leyes de los diversos países y regiones donde operamos, así como también los costos y estándares de uso definidos para estos.

Es imperativo resguardar la propiedad intelectual de las experiencias del cliente, los procesos de negocio e innovaciones implementadas en las diversas plataformas, así como los activos de códigos y datos generados para garantizar que los proyectos lleguen a su destino.

Es fundamental distinguir claramente entre los activos creados por la compañía y los servicios ofrecidos por la nube, para permitir la debida portabilidad de estos activos en las diversas plataformas disponibles en el mercado. Aquellos servicios propietarios de nubes que generen dependencia del proveedor deben ser identificados y son excepcionales.

Las versiones de cada software, framework y lenguaje de programación se detallarán en el [Roadmap Tecnológico](https://lookerstudio.google.com/u/0/reporting/ceb9aca9-cab2-464b-a9b0-3c368d3876fb/page/p_qx89rblazc).

## 4. Responsabilidades

Para mantener el correcto funcionamiento de este procedimiento y su cumplimiento en el tiempo, se definen los siguientes áreas/departamentos, roles y responsabilidades:

### 4.1. Arquitectura de Ciberseguridad

Toda solicitud de proyecto debe ser comunicada y validada previamente con el equipo de Arquitectura de Ciberseguridad, comunicándose con este equipo a la casilla `grp_arquitectura.ciberseguridad@latam.com`, donde el propósito será conocer de qué forma se están considerando los lineamientos expresados en este documento.

- Los entornos de desarrollo, pruebas y producción deben estar separados para evitar la contaminación cruzada y el acceso no autorizado.
- Se debe documentar de forma detallada lo siguiente:
  - Diagrama de arquitectura de la solución donde se implementará.
  - Persona responsable del proyecto.
  - Persona backup del proyecto.
  - Identificar a qué área o squad.
- Se debe verificar que el código utilizado esté libre de vulnerabilidades.
- El proyecto debe ser auditable, de forma que LATAM Airlines sea capaz de verificar qué acciones realizó (en el caso de que se detecte una violación de seguridad). Para ello se debe habilitar un registro de actividades (tareas y subtareas) ejecutadas en un archivo de LOG (o sistema equivalente adoptado por LATAM) que deje evidencia de las acciones ejecutadas con detalle de fecha, hora, acción y resultado de la acción.
- La cantidad y calidad (tasa de error, tiempo de procesamiento, feedback usuario/cliente) de transacciones mensuales por solicitudes debe ser medible (reporte); esto ayudará a que el software sea más eficiente y eficaz.
- El proyecto no debe almacenar credenciales del usuario; el proyecto debe tener su propia cuenta de servicio única. No se deben almacenar ningún tipo de credenciales. En caso de existir la factibilidad de ser gestionado con una solución de PAM (Privilege Access Management, ej: CyberArk), deberá ser gestionada por este tipo de soluciones con el fin de tener una rotación de contraseña frecuente.
- Es fundamental que las credenciales entregadas para uso sean compatibles con la matriz de segregación de funciones, incluidos los accesos del responsable.

### 4.2. Arquitectura Empresarial

El equipo de Arquitectura Empresarial debe:

- Ser parte del equipo del dominio responsable de implementar una solución propuesta, evaluando que responda a una necesidad de negocio específica y viable, que se utilice la herramienta adecuada, que tenga un diseño adecuado, que cumpla con las directrices técnicas definidas por el equipo de Arquitectura y aprobar la propuesta final en consecuencia.

### 4.3. Infraestructura

Determinar las consideraciones técnicas para desarrollar, proporcionar los entornos como la creación de las cuentas que determine arquitectura de ciberseguridad.

Se debe documentar de forma detallada lo siguiente:

- Diagrama de infraestructura de la solución donde se implementará.
- Identificar / etiquetar los recursos que sean desplegados para cubrir con la necesidad.
- Debe estar monitoreado el recurso implementado en GCP.
- Definir los roles y quiénes van a mantener la infraestructura asociada (proveedor / DevSecOps).

## 5. Levantamiento de Solicitudes de Desarrollo

Será responsabilidad del Funcional documentar fielmente el requerimiento del usuario solicitante. Los requerimientos deben enviarse al área responsable del dominio. También se debe indicar una lista de todos los requerimientos que serán probados. Cualquier requerimiento no incluido en esta lista estará fuera del alcance de desarrollo y pruebas.

## 6. Ambientes de Trabajo

### 6.1. Desarrollo

Es el ambiente donde se desarrolla y configura el sistema SAP. Toda creación o modificación de un objeto SAP deberá estar en una orden de transporte que luego debe ser transportada a Calidad y Producción por el área Basis de LATAM.

### 6.2. Calidad

Es el ambiente en donde se realizan todas las pruebas de los objetos SAP creados o modificados. En este ambiente se dispone de datos reales ya que es una copia del ambiente productivo a cierta fecha. Las órdenes de transporte deben importarse a este ambiente para hacer las pruebas y, una vez aprobadas por el funcional y el usuario solicitante del requerimiento, se puede pasar al ambiente de producción.

### 6.3. Producción

Es el ambiente de explotación de los procesos SAP; en él se encuentran los datos reales y su acceso está restringido a los Ingenieros TI y Usuarios finales. Las órdenes de transporte se pasarán a este ambiente una vez aprobadas y validadas satisfactoriamente y será realizado exclusivamente por SAP Producción una vez solicitado por el Ingeniero TI con el visto bueno del usuario final.

## 7. Seguridad SAP

El concepto de autorización de SAP se desarrolló para proteger las operaciones, programas y servicios de los sistemas SAP del acceso no autorizado. En este sentido, en LATAM se utilizan sólo objetos de autorización estándar, y si es necesaria la habilitación o modificación de alguno de estos se debe validar previamente con el área de seguridad encargada de esto.

Para la utilización de `AUTHORITY-CHECK`, solo se deben utilizar objetos autorizados por LATAM y que es posible visualizar a través de las transacciones definidas por SAP para este fin.

En LATAM la utilización de transacciones Z se ha hecho una práctica debido a la necesidad de cubrir requerimientos que la funcionalidad estándar de SAP no provee; por esta razón es común incluir transacciones de este tipo en roles. La inclusión de transacciones Z en los roles debe cumplir con lo siguiente:

- Cada una de las transacciones Z creadas deberá contar como mínimo con un `AUTHORITY-CHECK` asociado al objeto `S_TCODE` y otro asociado a un objeto funcional, en la medida que sea posible. Lo que debe ser validado por seguridad SAP.
- Cada una de las transacciones Z creadas para visualizar o modificar tablas: la tabla Z referenciada debe tener asociado un grupo de autorización de tablas válido, para así poder segmentar el acceso. En este sentido no se podrán utilizar valores del tipo `&NA&` como valores de autorización dentro de los roles.

El código ABAP de la transacción se ejecuta hasta que dentro del mismo aparezca la instrucción `AUTHORITY-CHECK`; a través de esta instrucción el programa verifica que los valores especificados para cada campo se encuentren en el buffer del usuario que la ejecuta. En LATAM se deberá incluir este valor al inicio de la transacción, de manera que se validen los accesos en una primera instancia antes de iniciar todo el proceso del programa.

### 7.1. AUTHORITY-CHECK

Este código permite asignar un objeto de autorización en la definición de la transacción, con los valores asignados en la programación. Sin estos objetos de autorización, el usuario no podrá ejecutar la transacción y/o programa.

- Si el programa NO contiene esta instrucción, NO se justifica un control en el Rol.
- En la medida que no exista `AUTHORITY-CHECK` en los programas, no cabe la construcción de un rol.
- Dentro del parámetro `ACTVT` nunca debe ser completado con `'*'`; solo en casos de no ser necesario un valor se aceptará `'DUMMY'`.
- Nunca será aceptado el valor `'DUMMY'` dentro de campos de autorización importantes.
- Todos los desarrollos deben incluir los objetos de autorización suficientes y necesarios para proteger el proceso y los datos relacionados, considerando en lo posible unidades organizativas tales como sociedad, organización de ventas, organización de compras, centro, etc., según corresponda de acuerdo a la naturaleza del desarrollo.
- Incluir la validación de código de retorno (`SY-SUBRC`); en caso de que no sea igual a `0`, denegar la autorización.
- En caso de desarrollos que llamen a módulos de funciones remotas (RFC) que sean críticas, se debe utilizar `AUTHORITY-CHECK` al objeto `S_RFC`. Sin embargo, ese objeto solo valida que el usuario que está ejecutando el programa pueda llamar a un módulo de función remota, pero en sí no agrega seguridad al módulo de función que se ejecutará. Por tal motivo se deben agregar los objetos de autorización pertinentes a los módulos de funciones invocados.
- La sentencia `CALL TRANSACTION` no verifica la autorización del usuario para llamar a dicha transacción de manera automática; debe agregar el correspondiente `AUTHORITY-CHECK` por transacción llamada.
- Verifique siempre el resultado de `SY-SUBRC` tras haber ejecutado `AUTHORITY-CHECK`. Un `SY-SUBRC` con valor cero significa una autorización suficiente; en caso de ser diferente se requiere una salida del desarrollo, y se recomienda el uso de `LEAVE PROGRAM`.
- El uso del comando `SY-SUBRC` debe ser llamado inmediatamente tras una ejecución de `AUTHORITY-CHECK`, y no debe estar anidado a ningún otro tipo de ejecución.

### 7.2. Grupo de Autorización para Tablas Z

Los Grupos de Autorización para tablas Z son requeridos para el control de accesos a la tabla. Se debe asignar un Grupo de Autorización según corresponda a módulo y/o función.

## 8. Transporte a Ambiente de Producción

Queda estrictamente prohibido modificar objetos estándar de SAP (programas, includes, formularios, tablas, etc.). Por lo tanto, no se autorizará transportar al mandante de Producción órdenes que incluyan objetos estándares de SAP modificados.

Todas las órdenes de transporte generadas serán revisadas rigurosamente antes de autorizar su paso al mandante de producción, y el listado de órdenes se debe entregar en la secuencia de transporte. Debe tener especial cuidado con los transportes de órdenes que tocan objetos muy recurrentes de modificación, porque puede arrastrar cambios previos que aún están en revisión (ejemplo: objeto `MV45AFZZ`).

Todos los textos (parámetros de entrada, títulos de reportes, títulos de columnas de reportes, textos en dynpros, formularios SAPscript, Smartforms, etc.) deben tener obligatoriamente sus respectivas traducciones al idioma inglés y portugués. No pasarán a productivo los objetos que no cumplan con esta norma.

Siempre debe enviar el resultado del Code Inspector para cada objeto creado.

## 9. Seguimiento

La entrega del desarrollo al Funcional especificador se hará una vez que apruebe los tests de Control de Calidad a los cuales será sometido para detección de errores y depuración, según los datos de prueba entregados, y cumplimiento de los resultados esperados que también serán entregados por el Funcional.

Una vez que el desarrollo es aprobado para ser transportado al mandante productivo, el desarrollador deberá supervisar que sus órdenes generadas pasen sin errores y deberá estar disponible para corregir cualquier error que se produzca al momento del transporte o errores posteriores durante su ejecución.

Es estrictamente necesario que los desarrolladores generen las órdenes de transporte en el formato definido y mantengan la correlación para cada cambio. Esto ayudará al seguimiento y legibilidad.

El seguimiento finalizará cuando el desarrollo esté trabajando a satisfacción por parte del usuario final en el ambiente productivo. Cualquier modificación posterior será agendada de acuerdo a la lista de requerimientos que administra el área de Desarrollos SAP.

Cada nuevo desarrollo deberá incluir los requerimientos expuestos en esta política. El encargado de los desarrollos SAP deberá velar por el cumplimiento de esta.

## 10. Formato de Código (Pretty Printer)

Los códigos ABAP deben estar formateados de una manera consistente y organizada. El formateo estándar debe ser utilizado para todos los programas, funciones, etc.

Para setear el formato, ingrese a la transacción `SE38` y vaya a **Utilidades / Parametrizaciones / Pestaña Editor ABAP / Pestaña Pretty Printer** y seleccione las opciones:

- Sangrar
- Efectuar conversión mayúsc./minúsc.
- Palabra clave mayúsc.

> **Nota importante:** Cuando esté modificando un objeto que ya exista y tenga otro formato, puede presionar el botón Pretty Printer y configurar en **Utilidades / Parametrizaciones / Pestaña Editor ABAP / Pestaña SplitScreen** las opciones de comparación:
> - Ignorar sangrados
> - Ignorar mayúsc./minúsc.
>
> Con estas opciones, al comparar la nueva versión con la anterior se reflejarán los cambios reales y no los cambios producidos al utilizar el Pretty Printer.

## 11. Convenciones Generales

### 11.1. Variables

| Objeto de Programación | Ámbito | Valor |
|---|---|---|
| Variable | global | `g_<nombre_variable>` |
| Variable | local | `l_<nombre_variable>` |
| Tabla interna | global | `gt_<nombre_variable>` |
| Tabla interna | local | `lt_<nombre_variable>` |
| Work area | global | `gwa_<nombre_variable>` |
| Work area | local | `lwa_<nombre_variable>` |
| Parámetros (rutina FORM o Clase Local) | using | `pu_<nombre_variable>` |
| Parámetros (rutina FORM o Clase Local) | changing | `pc_<nombre_variable>` |
| Parámetros (rutina FORM o Clase Local) | tables | `pt_<nombre_variable>` |
| Rangos | global | `gr_<nombre_variable>` |
| Rangos | local | `lr_<nombre_variable>` |
| Constantes | global | `gc_<nombre_variable>` |
| Constantes | local | `lc_<nombre_variable>` |
| Field Symbol | global | `<gfs_nombre_variable>` |
| Field Symbol | local | `<lfs_nombre_variable>` |
| Tipos | global | `gty_<nombre_variable>` |
| Tipos | local | `lty_<nombre_variable>` |
| Clases | global | `gcl_<nombre_variable>` |
| Clases | local | `lcl_<nombre_variable>` |
| Objetos | global | `go_<nombre_variable>` |
| Objetos | local | `lo_<nombre_variable>` |
| Parámetros de Módulo de Funciones | import | `pi_<nombre_variable>` |
| Parámetros de Módulo de Funciones | export | `pe_<nombre_variable>` |
| Parámetros de Módulo de Funciones | changing | `pc_<nombre_variable>` |
| Parámetros de Módulo de Funciones | tables | `pt_<nombre_variable>` |
| Parámetros de Métodos de Clases | import | `pi_<nombre_variable>` |
| Parámetros de Métodos de Clases | export | `pe_<nombre_variable>` |
| Parámetros de Métodos de Clases | changing | `pc_<nombre_variable>` |
| Parámetros de Métodos de Clases | returning | `pr_<nombre_variable>` |

### 11.2. Copias de programas estándar SAP

Las copias de programas estándar SAP no son recomendables. Estos programas utilizan generalmente rutinas comunes con muchos otros programas. Los cambios de versiones y las actualizaciones del sistema pueden modificar la funcionalidad de estas rutinas y del programa original. Esto puede conducir a errores en el programa copiado, tanto de funcionamiento como de compilación, y el mantenimiento de los mismos puede ser extremadamente complejo.

Por estos motivos es recomendable no copiar programas estándares a menos que no haya otras alternativas. Solo bajo determinadas circunstancias será justificable la copia de estos programas.

En caso de realizarse la copia, debe documentarse en el programa la versión del sistema al momento de la misma, para tener un mejor control y documentación del programa.

### 11.3. Actualizaciones directas a Tablas

Las modificaciones a tablas estándar SAP deben evitarse a toda costa y no están permitidas. Estas solo pueden ser actualizadas mediante transacciones SAP estándar. Para actualizar estas tablas mediante programas, deben utilizarse BAPIs o, en última instancia, el comando `CALL TRANSACTION` (ejecución on-line sin intervención de Tx. SM35) o crear un BDC (Batch Input – Tx. SM35 de R/3).

Las actualizaciones directas a tablas Z se harán bajo las siguientes condiciones:

- **Debe haber un bloqueo apropiado.** Esto incluye generar el bloqueo mediante el comando `ENQUEUE` e incluir una lógica para manejar bloqueos incorrectos (salir, o esperar y reintentar). La lógica de esperar y reintentar debe tener algún tipo de condición de finalización para que no continúe indefinidamente.
- **La unidad de trabajo (Unit of Work - UOW) debe ser considerada.** Cualquier rutina que haga actualización directa de tablas Z necesita considerar cuidadosamente la unidad de trabajo en la que opera y proveer un bloqueo adecuado. Debe ser considerada en la decisión de hacer un `DEQUEUE` y/o un `COMMIT WORK`.

### 11.4. Código reutilizable

Si una porción del código es ejecutada más de una vez, debe ser incluida en un método de una clase dentro del programa. Si esta porción del código puede ser utilizada por varios programas, es conveniente crear una clase por la `TX:SE24`. Esto hace que el código sea más entendible y más fácil de debuggear.

Cuando sea posible, deben pasarse parámetros en las subrutinas para entender más fácilmente el propósito del método y reducir la declaración de variables globales. Cuando sea posible, utilizar la sentencia `TYPE` al especificar parámetros en una subrutina; es un buen estilo de programación y permite al compilador de ABAP ser más eficiente (incrementando su performance).

### 11.5. Textos Hardcodes

El uso de Textos Fijos (Hardcodes) no está permitido.

### 11.6. Manejo de errores

Todos los programas deben hacer un tratamiento de errores. Todas las sentencias que modifiquen el valor del sistema `SY-SUBRC` deben tener una validación en caso de errores para evitar terminaciones no deseadas del programa. Las sentencias `CATCH`/`ENDCATCH` deben utilizarse para evitar errores en tiempo de ejecución.

### 11.7. Comentarios

Por cada bloque de proceso relevante deberá comentarlo al inicio:

```abap
*--------------------------------------------------------------------*
* Búsqueda de información
*--------------------------------------------------------------------*
" Se recomienda comentar las búsquedas para futuras modificaciones

" Búsqueda maestro de clientes
SELECT …

" Búsqueda maestro de materiales
SELECT ...
```

Los códigos relevantes, como por ejemplo llamadas a BAPIs, ciclos, etc., deben ser comentados descriptivamente:

```abap
" Se simula el pedido para la obtención del pricing
CALL FUNCTION 'BAPI_SALESORDER_SIMULATE'
  EXPORTING
    order_header_in ...
```

Siempre debe hacer una verificación con Code Inspector del objeto (transacción `SCI`) a fin de detectar problemas de interfaces, dynpros, sentencias obsoletas y todo lo que no esté según la norma LATAM.

### 11.8. Comentarios para modificaciones

Siempre se debe especificar en el historial del programa el motivo de la mantención. Adicionalmente, al comentar o cambiar cualquier línea de código, se deberá incluir una línea en la cual se identifique el autor, la fecha y una explicación de la corrección.

Las líneas comentadas o corregidas no deben ser eliminadas, a menos que ocupen una porción muy grande del programa. En este caso se deberá respaldar el programa antes de eliminar las instrucciones de código.

Casos contemplados:

- **Caso 1:** Agregar varias líneas de código.
- **Caso 2:** Modificar varias líneas de código.
- **Caso 3:** Eliminar/Comentar varias líneas de código.
- **Caso 4:** Agregar una línea de código.
- **Caso 5:** Modificar una línea de código.
- **Caso 6:** Eliminar/Comentar una línea de código.

### 11.9. Programas ABAP

Cada comando ABAP/4 consiste en una sentencia que termina con un punto. Múltiples comandos pueden estar en una línea; sin embargo, como estándar cada nuevo comando estará en una nueva línea. Esto permitirá borrar, comentar y hacer debug más adecuadamente.

#### 11.9.1. Convención de Nombres Reportes y Programas

Todo reporte o programa desarrollado debe comenzar con la letra "Z", excepto los del tipo Module Pool, que tiene un tratamiento especial. Esto con el objetivo de identificar y diferenciar los desarrollos de Clientes de los desarrollos estándar de SAP.

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Indicador de Cliente | Z | Desarrollo ABAP de Cliente |
| 2 | Frente Funcional | Carácter | Anexo 1 – Frentes Funcionales |
| 3 | Módulo | — | Anexo 2 – Módulos |
| 4 | Tipo Programa | Alfanumérico | B - Batch input, C - Call transaction, L - IncLude, M - Menú, R - Reportes, I - Interfaz, F - Formularios, D - Desarrollo, U - Funciones |
| 5 | Separador de Correlativo | `_` | Carácter que separa |
| 6 | Correlativo | 000 al 999 | Número secuencial que identifica unívocamente el desarrollo |

Formato: `Z<FrenteFuncional><Modulo><TipoPrograma>_<NumCorrelativo>`

Ejemplos:

- `ZPMMB_001` = Es el primer Batch-Input de Materiales.
- `ZFSDD_003` = Es el tercer desarrollo del módulo SD.

#### 11.9.2. Programa Include

Un programa include se utiliza para definir tipos de datos en común o lógica algorítmica que se puede utilizar o referenciar en más de un programa.

El nombre estándar para los desarrollos de programas include se basa en la misma lógica de los nombres de los desarrollos de programas ABAP más un sufijo:

- `TOP` = Contiene la declaración de DATA de un reporte.
- `SEL` = Contiene la declaración del SELECTION-SCREEN de un programa.
- `FORM` = Contiene los Forms que son llamados por el programa.
- `F00` a `F99` = Contiene lógica y subrutinas de un programa.
- `CLA` = Contiene la definición de la clase y sus métodos.

Ejemplos:

- `ZFARD_001_TOP` = Contiene la declaración de variables, tablas internas, work area y constantes del programa `ZFARD_001`.
- `ZFARD_001_SEL` = Contiene todo lo relacionado con la construcción de la pantalla de ingreso de parámetros del programa `ZFARD_001`.
- `ZFARD_001_CLA` = Contiene definición de clase y su implementación, con funcionalidades que serán utilizadas por el programa `ZFARD_001`.
- `ZFARD_001_F00` = Contiene funcionalidades que serán utilizadas tanto por el programa `ZFARD_001` como en otros.

#### 11.9.3. Documentación Código

Todo desarrollo debe ser autodocumentado, es decir, contener en él la información necesaria y suficiente para ser entendido por cualquier otro programador. El idioma oficial es el Español.

Como norma, cada desarrollo debe partir con una descripción del requerimiento; en caso de existir alguna fórmula o algoritmo especial, se deberá detallar en la misma descripción. También se debe especificar la fecha, empresa y usuario Creador o Modificador.

```abap
*&============================================================*
*& Report ZARD_005                                           *
*&============================================================*
*& Descripción: Reporte de Cuentas Por Cobrar Clasificando   *
*&              las partidas Abiertas en Largo y Corto Plazo *
*& Fecha Creación = 25.06.2024                               *
*& Creador        = XX                                       *
*& Empresa        = LATAM                                    *
*&============================================================*
*& Histórico de modificaciones                               *
*&============================================================*
*& Marca  Fecha       Autor  Descripción la Modificación     *
*& @001   2024.01.01  XX     Agregar columna de fecha        *
*& @002   2024.01.02  XX     Modificar lógica de mensaje     *
*&============================================================*
```

#### 11.9.4. Modificación Programa ABAP's Estándar

**NUNCA SE DEBE** modificar un programa estándar de SAP. En caso de ser estrictamente requerido, se deberá copiar el código fuente anteponiendo la letra "Z". Esto se realizará solo con la autorización del Jefe de Desarrollo SAP.

Ejemplo: `RGGBR000` → `ZRGGBR000`

#### 11.9.5. Programas Temporales ABAPs

Se denomina programa temporal a los desarrollos que sirven para analizar una potencial solución o para probar algunas instrucciones específicas. Por lo cual, no deberían ser transportados a Productivo.

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Indicador de Cliente | Y | Indica que el desarrollo es de Cliente |
| 2-4 | Iniciales Programador | Alfabético | — |
| 5-40 | Texto Explicativo | Alfanumérico | — |

Ejemplo: `YCPG_AM_TestCargaBienesConIdoc`

#### 11.9.6. Module Pool

La convención del nombre para los desarrollos Module Pool es la siguiente:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `SAPMZ` | — |
| 2 | Separador | `_` | — |
| 3 | Módulo | — | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5 | Secuencia | 000 al 999 | Número secuencial que identifica unívocamente el desarrollo |

Ejemplo: `SAPMZ_MM_001` = Primer Desarrollo Module Pool de Materiales.

#### 11.9.7. Selection Screen

Las sentencias ABAP más usadas en el Include de Selection Screen son:

- `Parameters`
- `Select-Options`
- `Selection-Screen`

##### 11.9.7.1. Parameters

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1-2 | Prefijo | `P_` | Identificador de Parámetros |
| 3-8 | Nombre | Alfanumérico | El nombre del parámetro tiene que ser el nombre de una estructura o tabla, si es que existe |

Ejemplo:

```abap
PARAMETERS: P_BUKRS TYPE BKPF-BUKRS.
```

##### 11.9.7.2. Select-Options

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1-2 | Prefijo | `S_` | Identificador de Selección |
| 3-8 | Nombre | Alfanumérico | El nombre del parámetro tiene que ser el nombre de una estructura o tabla, si es que existe |

Ejemplo:

```abap
SELECT-OPTIONS: S_PERNR FOR WA_RANGOS-PERNR.
```

#### 11.9.8. Grupo de Funciones

La convención para el código de Grupo de Función es la siguiente:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `Z` | Transacción del Cliente |
| 2 | Frente Funcional | Carácter | Anexo 1 – Frentes Funcionales |
| 3 | Módulo | — | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5 | Secuencia | 000 al 999 | Número secuencial que identifica unívocamente el grupo de Función |

Ejemplos:

- `ZFMM_001` = Grupo de Función de MM.
- `ZFFI_001` = Grupo de Función de FI.

#### 11.9.9. Funciones ABAP

Como norma, cada desarrollo debe partir con una descripción del requerimiento; en caso de existir alguna fórmula o algoritmo especial, se deberá detallar en la misma descripción. También se debe especificar la fecha, empresa y usuario Creador o Modificador (ver ejemplo de cabecera en 11.9.3).

La convención para el nombre del módulo de función es la siguiente:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `Z` | Transacción del Cliente |
| 2 | Área de Negocio | Carácter | Anexo 1 – Frentes Funcionales |
| 3 | Módulo | — | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5 | Texto Descriptivo | Alfanumérico | — |

Ejemplo: `ZHHR_BUSCA_UNIDAD_ORGANIZATIVA` – Función de HR.

### 11.10. Código Reusable

Si un bloque de código se ejecuta más de una vez, debe ser colocado en una subrutina en la parte inferior del código. Esto hace que el código sea más legible, requiera menos sangrado y sea más fácil de depurar. Asimismo, cuando sea posible, los parámetros pueden ser pasados a subrutinas con la finalidad de hacer más fácil su comprensión y reducir la necesidad de variables globales. Siempre se deberá documentar el propósito de cada parámetro.

#### 11.10.1. Paquete de Desarrollo

Los paquetes de desarrollo sirven para organizar todos los objetos que se crean en SAP, clasificándolos generalmente por módulos. A modo de ejemplo, un objeto sería un archivo y la clase de desarrollo sería la carpeta donde guardamos el archivo.

Cuando nos disponemos, en el ambiente de desarrollo, a crear nuevos objetos con las herramientas de desarrollo apropiadas, el sistema, antes de asignarle una orden de transporte, nos pedirá asociar el nuevo objeto a un Paquete de Desarrollo.

Existen dos tipos de paquetes de desarrollo dentro del sistema SAP:

- Paquete de desarrollo estándares del sistema.
- Paquete de desarrollo creados por los usuarios, que son los llamados Z.

Existe el Paquete de Desarrollo `$TMP`, que se utiliza para los objetos temporales que no se van a transportar entre ambientes, es decir, para pruebas.

Al asociar un objeto a un paquete de desarrollo estaremos, implícitamente, asignándole la ruta de transporte a seguir cuando la orden de transporte asociada a ese objeto sea transportada desde el ambiente de desarrollo a los ambientes de pruebas o producción.

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Indicador de Cliente | Z | Paquete de Cliente |
| 2 | Módulo | — | Anexo 2 – Módulos |
| [3] | Separador | `_` | — |
| [4] | Secuencia | 000 al 999 | Número secuencial |

Las posiciones 3 y 4 son opcionales, reservadas para cuando el Jefe de Proyecto junto con el Arquitecto de Negocio consideren que los objetos a ser generados, dada la criticidad y/o tipo de proyecto, requieran un paquete de desarrollo propio.

### 11.11. Dictionary Objects

#### 11.11.1. Creación de Tabla de Base de Datos

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de Tabla Creada por el Cliente |
| 2-3 | Módulo | Alfanumérico | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5-16 | Sufijo | Alfanumérico | Nombre nemotécnico que se utiliza para diferenciar tablas de un mismo módulo |

Ejemplo: `ZMM_PARAM_FEE` – Parámetros del Legacy FEE.

La definición de una TABLA en ABAP contiene los siguientes componentes:

- **Campo de Tablas:** Define el nombre y tipo de campos que contiene la tabla. Para ampliaciones de tablas estándar, los campos de clientes deberán comenzar con "ZZ".

Convención de campos:

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Ámbito | Alfanumérico | Abreviación que representa el valor del campo |
| 3 | Separador | `_` | — |
| 4-16 | Sufijo | Alfanumérico | Indica mayor información acerca del valor del campo |

Ámbitos para creación de campos:

| Ámbito | Abreviación |
|---|---|
| Número | NMR |
| Fecha | FCH |
| Estado | EST |
| Empresa | EMP |
| Código | CDG |
| Valor | VLR |
| Total | TTL |
| Descripción | DSC |
| Glosa | GLS |
| Nombre | NMB |
| Teléfono | TLF |
| Porcentaje | PCT |
| Precio | PRC |
| Plazo | PLZ |
| Tipo | TPO |
| Correlativo | CRR |

Ejemplo: `ZFCH_VUELO` – Indica fecha de vuelo.

Otros componentes de la tabla:

- **Primary Key:** Identifica la unicidad de un registro de una tabla. Toda tabla debe contener como primer campo el "mandante", el cual debe ser denominado `MANDT` y que debe formar parte de la PK.
- **Foreign Keys:** Define la relación de la tabla con otras tablas. Se debe incluir una tabla de verificación, la que permitirá validar el dato ingresado y será útil además para la creación de matchcode en programas.
- **Seteo Técnico:** Control del "cómo" debe ser creada la tabla en la Base de Datos.
- **Indexes:** Para mejorar la performance de selección de datos.

#### 11.11.2. Índices de Tablas

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de Índice Creado por el Cliente |
| 2-3 | Indicador | 00-99 | Identificador único del índice |

Ejemplo: `Z01` – Índice Z01.

#### 11.11.3. Creación de Vistas

El nombre de la vista puede tener hasta 16 caracteres.

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de Vista Creada por el Cliente |
| 2 | Tipo de Vista | H, D, P, S, C | Help View, Database View, Projection View, Structure View, Customizing View |

Ejemplo: `ZS_A100` – Vista de una tabla de contabilización de Activo.

#### 11.11.4. Estructuras

La definición de una estructura en el Diccionario de ABAP contiene componentes que pueden ser campos (data element), INCLUDE o estructura APPEND.

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de Estructura Creada por el Cliente |
| 2 | Sufijo | `S` | — |
| 3 | Separador | `_` | — |
| 4-* | Sufijo | Alfanumérico | Nombre nemotécnico que identifica a esta estructura de otras en el mismo módulo |

Ejemplo: `ZS_A100` – Vista de una tabla de contabilización de Activo.

#### 11.11.5. Data Elements

La definición de un Data Element no tiene una estructura específica. Lo que hay que considerar es que el nombre de un Data Element describa la funcionalidad del negocio para el cual fue creado. Sin embargo, hay que considerar que si existe un Data Element de SAP, este deberá ser usado.

Si se debe crear un data element, este debe tener un largo máximo de 30 caracteres y debe comenzar con `ZDE_` para distinguirlo de los de SAP.

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1-4 | Prefijo | `ZDE_` | Data Element de Cliente |
| 5-30 | Descripción Única | Alfanumérico | El significado del nombre debe describir el Data Element |

Ejemplos: `ZDE_Bancos`, `ZDE_Cuentas`.

#### 11.11.6. Dominios

El número de caracteres permitido para el nombre es de 30. Como SAP usa todas las letras para sus dominios, incluidas 'Y' y 'Z', el nombre debe comenzar con `ZDO_` para distinguirlos de los dominios de SAP.

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1-4 | Prefijo | `ZDO_` | Dominio de Cliente |
| 5-30 | Descripción Única | Alfanumérico | El significado del nombre debe describir el Dominio |

Ejemplos: `ZDO_Bancos`, `ZDO_Cuentas`.

## 12. Transacciones ABAP

La convención para el código de la transacción es la siguiente:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `Z` | Transacción del Cliente |
| 2 | Frente Funcional | Carácter | Anexo 1 – Frentes Funcionales |
| 3 | Módulo | — | Anexo 2 – Módulos |
| 4 | Indicador de Transacción | `T` | Transacción |
| 5 | Separador | `_` | — |
| 6 | Secuencia | 000 al 999 | Número secuencial que identifica unívocamente la transacción |

Ejemplo: `ZFAPT_001` = Transacción #1 desarrollada para el módulo AP del frente Finanzas.

## 13. Traducciones

Todo desarrollo debe contar con la traducción en los 3 idiomas (español, inglés y portugués).

## 14. S4Hana

### 14.1. Core Data Services (CDS)

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de objeto Creado por el Cliente |
| 2-3 | Módulo | Alfanumérico | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5-7 | Indicador CDS | `CDS` | Core Data Services |
| 8 | Separador | `_` | — |
| 9-12 | Secuencia | 0001 al 9999 | Número secuencial que identifica unívocamente el objeto |

Ejemplos: `ZMM_CDS_0001`, `ZCO_CDS_0001`.

### 14.2. Data Definition Language (DDL)

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de objeto Creado por el Cliente |
| 2-3 | Módulo | Alfanumérico | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5-7 | Indicador DDL | `DDL` | Data Definition Language |
| 8 | Separador | `_` | — |
| 9-12 | Secuencia | 0001 al 9999 | Número secuencial que identifica unívocamente el objeto |

Ejemplos: `ZMM_DDL_0001`, `ZCO_DDL_0001`.

### 14.3. Data Control Language (DCL)

| Pos. | Descripción | Valor | Descripción |
|---|---|---|---|
| 1 | Prefijo | `Z` | Indicador de objeto Creado por el Cliente |
| 2-3 | Módulo | Alfanumérico | Anexo 2 – Módulos |
| 4 | Separador | `_` | — |
| 5-7 | Indicador DCL | `DCL` | Data Control Language |
| 8 | Separador | `_` | — |
| 9-12 | Secuencia | 0001 al 9999 | Número secuencial que identifica unívocamente el objeto |

Ejemplos: `ZMM_DCL_0001`, `ZCO_DCL_0001`.

## 15. Dynpro – Webdynpro ABAP

Para crear la interfaz de usuario se puede usar Dynpro o Webdynpros ABAP. En el caso de usar Dynpro, se usa la transacción `SE51` y se relaciona a un programa Z. Este programa Z (ABAP) se debe desarrollar en base a los detalles indicados en los apartados anteriores de este documento.

En el caso de Webdynpro ABAP, para desarrollar la interfaz de usuario se pueden utilizar los controladores, vistas, ventanas, componentes y aplicaciones. Para crear interfaces de usuario Web Dynpro que corresponden a las pantallas clásicas de los programas de ABAP, se pueden usar las funciones de la pantalla de diseño de tiempo de conversión.

Ejemplo: `Z_WD_DESCRIPCION` – Web Dynpro ABAP.

## 16. Workflow

Definiciones:

- **Workflow:** Es el set de reglas que determina la ruta que el proceso toma.
- **Tarea:** Son los pasos en el proceso, las cuales deben ser ejecutadas ya sea por personas o automáticamente por el software.
- **Container:** Es el lugar donde todos los datos usados por el workflow son almacenados.

Para un nuevo requerimiento, se debe validar si el flujo que se desea implementar se encuentra disponible dentro de las soluciones estándares propuestas por SAP. A través de la transacción `PFTC` se revisan los Workflows estándares de SAP propuestos por módulo. Se debe revisar que el flujo propuesto sea el requerido por los usuarios; de lo contrario, se debe realizar una copia de este para comenzar a adaptarlo al requerimiento.

Convención para el **número** de copia de Workflow:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `999` | Cliente |
| 2 | Secuencia | 00000 al 99999 | Número correlativo que identifica el workflow |

Convención para el **nombre** de la copia de Workflow:

| Posición | Descripción | Valor | Significado |
|---|---|---|---|
| 1 | Prefijo | `Z` | Transacción del Cliente |
| 2 | Módulo | — | Anexo 2 – Módulos |
| 3 | Nombre explicativo | Alfanumérico | Nombre que describe el objetivo del workflow |

Ejemplo:

- Workflow original: `20000001`
- Workflow copia: `999000051`
- Sigla: `ZSD_order_check_SO` (indicaría que es un documento de venta para chequear una orden)
- Denominación: Descripción objetivo del workflow.

En el caso de OBJETOS, se deberá anteponer "Z". Ejemplo: el objeto `ZBUS2012` será extensión del objeto estándar `BUS2012`. De la misma forma que se revisan los Workflows estándares, se deben revisar los Objetos de Negocios disponibles que se asocian a una transacción, función o programa ABAP y que permiten lanzar un workflow. Con la transacción `SWO1` se pueden revisar los objetos disponibles.

Una vez identificado el objeto, se debe validar que las transacciones usadas invocan a este Objeto y sus métodos y eventos, y por lo tanto se puede usar como evento desencadenante del nuevo workflow a implementar. Además, se debe diseñar la tarea que se necesita en cada paso del workflow. Para la construcción del workflow se debe usar la herramienta Workflow Builder (`SWDD`), dentro de la cual se crean todos los componentes de un workflow, incluyendo todos los containers que se necesiten para tomar datos desde un paso a otro.

## 17. Web Services

Todo Web Service debe ser validado por el Gobierno SOA, con el objetivo de mantener el Catálogo de Servicios actualizado, evaluar los posibles impactos del cambio y ayudar en la determinación de si el servicio a construir/modificar es Punto a Punto o SOA.

Para apoyar esta gestión, el Equipo de Proyecto o Mantención debe comunicarse con el Arquitecto correspondiente al Área de Negocio.

### 17.1. Convención de Nombres para Web Services

- **Servicios Punto a Punto:** `ZXX_PPP_NombreFunción_VNNN`
- **Servicios SOA:** `ZXX_MM_NombreFunción_VNNN`

Donde:

- `XX` = `WS` si SAP expone un servicio web, o `CO` si SAP consume un servicio expuesto por otros.
- `PPP` = 3 siglas del Proyecto. Ejemplo: TVC (Travel Voucher), ORA (One RA), etc.
- `MM` = 2 siglas para el Módulo SAP. Ejemplo: FI, SD, HR.
- `VNNN` = Regla de generación de la versión (V) de los elementos de software; se contará con tres dígitos (NNN):
  - **Primer dígito – Cambio Mayor:** el servicio sufre cambios importantes y mejoras sustanciales en su implementación, con lo que el comportamiento es distinto a su predecesor.
  - **Segundo dígito – Cambio Menor:** el servicio sufre cambios pequeños en su implementación y/o interfaz.
  - **Tercer dígito – Parche:** el servicio sufre correcciones de errores en su implementación.

Ejemplo: `V110` corresponde a la versión 1.1.0, es decir, un cambio pequeño en su implementación o interfaz.

### 17.2. Convención de Nombres elementos de Web Services

- **Exposición** — Endpoint: `ZEP_NombreFunción`
- **Consumo** — Clase: `ZCL_IdentificadorSistemaFuente`; Puerta Lógica: `ZLP_IdentificadorSistemaFuente`

Ejemplo: Si el servicio es `ZWS_ORA_CREATE_DOC_V120`, el endpoint será `ZEP_CREATE_DOC`.

### 17.3. Ajustes de seguridad

Para asegurar la transferencia segura de datos, para todas las configuraciones del servicio web se debe elegir "Transport Guarantee" en la definición del servicio Web y luego elegir Integrity.

La definición de si el servicio se debe exponer vía HTTP o HTTPS se debe tomar en conjunto con el Arquitecto de Negocio. En caso de que el servicio se deba exponer vía HTTPS, la llamada de servicios web proxy debe soportar SSL y contener una URL que comience con `https`.

En el caso de requerir seguridad con usuario y contraseña, se debe tener la siguiente consideración:

- **Nombre de usuario:** Se debe solicitar un usuario de comunicación por cada aplicativo que acceda a consumir el servicio expuesto por SAP.
- El usuario debe tener autorizaciones para los objetos SAP a los que invoca; por lo tanto, se debe indicar al área de seguridad el nombre de los objetos que debe tener autorización.

> Para más detalles de los temas relacionados con Web Services SAP, referirse a los documentos: *"Estandar_WebServices_SAP_ABAP v2"* y *"Estándar de WebServices v1.1.3"*.

## 18. Select Correctos para HANA

El nuevo enfoque de HANA consiste en enviar nuestro código a la capa de la base de datos donde residen todos los datos, hacer los cálculos en la capa de la base de datos y llevar solo los registros relevantes al servidor de presentación (cambio de paradigma).

Nuevas consideraciones S4Hana: mantenga pequeños los sets de datos. El modelo a utilizar es el Top-Down: con este enfoque, los desarrolladores pueden desarrollar objetos con el enfoque habitual de trabajar con objetos de desarrollo ABAP, lo que significa que desarrollarán basado en HANA principalmente artefactos ABAP dentro del propio servidor de aplicaciones ABAP e implementarlos (activarlos) en la base de datos HANA.

### 18.1. Performance

Al desarrollar un programa, no solo debemos tomar en cuenta la estandarización de los objetos, sino también mejorar la interacción con la base de datos. Esto lo logramos mejorando la extracción de información y logrando una muy buena codificación.

La creación de CDS ayuda en una BD HANA en la extracción de datos; la creación depende del Funcional y el ABAP. Es un tema de criterio: si se detecta que hay muchas consultas a tablas continuamente, es posible crear un CDS que ayude a mejorar el performance del programa.

La creación de AMDP ayuda en una BD HANA y permite crearlo para validar procesos repetitivos.

#### 18.1.1. Criterios de Creación de CDS

Al realizar un CDS se deben tener en cuenta las siguientes características:

- **Por volumen de datos:** si el volumen de datos en las tablas seleccionadas es muy grande, por ejemplo las tablas `ACDOCA`/`MKPF`/`MSEG`/`MATDOC`/`VBAK`/`VBAP`, etc.
- **Por el número de tablas:** se deben realizar los CDS con 3 tablas como mínimo. Un ejemplo claro es `FOR ALL ENTRIES` consecutivos; si se detecta este posible escenario, es mejor crear un CDS.
- **Por el número de campos a seleccionar:** tomar en cuenta que el número mínimo para crear un CDS es de 15 campos.

> **NOTA:** Preguntar siempre si un CDS ha sido creado.

### 18.2. Criterios de Creación de AMDPs

Al realizar un AMDP se deben tener en cuenta las siguientes características:

- **Por procesos repetitivos:** si se definen procesos repetitivos en los programas, es posible crear un AMDP para controlarlo.

> **NOTA:** Preguntar siempre si un AMDP ha sido creado.

## 19. Carga y Descarga de Archivos

Utilice los métodos `GUI_UPLOAD` y `GUI_DOWNLOAD` de la clase `CL_GUI_FRONTEND_SERVICES`.

## 20. Advance List View (ALV)

Todo ALV debe ser confeccionado con programación orientada a objetos utilizando el contenedor que referencia la clase `CL_GUI_CUSTOM_CONTAINER`.

Debe considerar que esta clase no genera spool en procesos de fondo (JOB); por lo tanto, si necesita ejecutar el reporte en fondo y revisar el resultado impreso, debe utilizar un contenedor que referencie la clase `CL_GUI_DOCKING_CONTAINER` y controlar la utilización de uno u otro así:

```abap
IF cl_gui_alv_grid=>offline( ) IS INITIAL.
  " Crear contenedor referenciado a clase CL_GUI_CUSTOM_CONTAINER.
ELSE.
  " Crear contenedor referenciado a clase CL_GUI_DOCKING_CONTAINER.
ENDIF.
```

## 21. Lectura y Generación de Archivo en Servidor Unix

Siempre que lea o escriba archivos en Unix, controle las operaciones con `CATCH` utilizando las clases `CX_SY_FILE_*` del paquete `S_ABAP_EXCEPTIONS`.

## 22. Controles en Operaciones Matemáticas

Todo desarrollador debe hacer validaciones en las operaciones matemáticas que permitan evitar DUMPs durante la ejecución de las transacciones. Los controles se deben hacer con la instrucción `CATCH`.

## 23. Mantenedores de tablas no estándares

Cada vez que necesite generar un mantenedor a una tabla de cliente, debe hacerlo desde la transacción `SE11` generando el mantenedor estándar. Para efectos de seguridad debe asignar un grupo de autorización. Si tiene dudas sobre el grupo de autorización a asignar, debe consultar con el área de seguridad SAP.

## 24. Envío de correos desde SAP

Cada vez que necesite enviar un correo desde SAP deberá hacerlo con los métodos disponibles en la clase `CL_BCS`. Puede buscar la referencia de utilización Z para obtener ejemplos de uso.

## 25. Programa con ejecución de fondo Latam

En LATAM existen varios programas que permiten la ejecución en fondo con la opción de visualizar los resultados más tarde en un ALV. Para el caso de la ejecución del Job debe ocupar la función `BP_START_DATE_EDITOR` para dar opciones de ejecución (para el uso puede revisar la referencia de utilización de la función). Además, los botones Diálogo, Fondo y Ver Resultados Jobs serán incluidos en la barra de comando estándar, con el fin de poder ejecutar el Diálogo con la opción estándar de SAP (F8).

## 26. Control de ejecución de procesos de fondo duplicados

En LATAM, para cada desarrollo que deba tener una ejecución en fondo, se debe incorporar un control para restringir la cantidad de veces que un usuario puede ejecutar una transacción, cliente o estándar, en forma paralela. El objetivo de este desarrollo es disminuir la sobrecarga del sistema, especialmente en los días de cierre.

## 27. Restricciones

- Nunca usar/dejar "breakpoint" en el código.
- Nunca realizar `update`, `insert` y/o `delete` a las tablas estándar de SAP.
- Nunca usar `SELECT * FROM database`.
- No usar datos en duro; puede usarse tipos de datos constantes.
- Para el ambiente productivo, nunca utilizar el DNS de un nodo para web services o ftp; siempre utilizar `sapr3ascs.cl.lan.com`.

## 28. Consideraciones de Optimización

- No utilizar la instrucción `SELECT *`. Debe especificar los campos que seleccionará. Ya no podrá justificar su uso: NUNCA debe utilizarlo.
- No utilizar campos que no sean parte de la llave o un índice de la tabla.
- Para reducir los accesos a la base de datos, es mejor hacer una consulta y dejar los registros en una tabla interna que hacer `SELECT-ENDSELECT`.
- Evite la instrucción `MOVE-CORRESPONDING`. En vez de eso, mueva campo por campo cuando quiera asignar valores de una estructura a otra.
- Haga un chequeo del rendimiento del programa con la transacción `SE30`.
- La estructura de la tabla interna debe coincidir con la selección de campos para el `SELECT`, y así evita hacer `INTO CORRESPONDING FIELDS`.
- Evite los `SELECT` anidados.
- Tenga cuidado con la instrucción `CHECK`, ya que puede cortar el proceso si no la utiliza correctamente.
- Utilice el TRACE SQL (`ST05`) para analizar el tiempo de ejecución del programa.

## 29. Recomendaciones

- Para validar los desarrollos en ABAP, deberán ser transportados al ambiente QA mediante órdenes de transporte a dicho sistema. Una vez que QA valide, las órdenes de transporte serán autorizadas y aplicadas para pasar al sistema productivo en el menor número de órdenes posible.
- Tener un plan adecuado para planear las pruebas que se van a hacer al programa.
- Se debe realizar control de calidad (QA) de las aplicaciones ABAP realizando las actividades de Trace y Tunning.
- Es necesario documentar los programas o insertar comentarios en los programas.
- Importante también notificar los cambios que se realicen en el programa.

### 29.1. Clean Code

El CLEAN CODE se trata de un código fácil de entender que se puede ajustar fácilmente. La productividad de un equipo, la calidad y adaptabilidad de un producto están fuertemente correlacionadas con la legibilidad, mantenibilidad y capacidad de prueba del código.

#### 29.1.1. Nomenclatura

**Usar nombres descriptivos** — Usa nombres que muestren el contenido y significado de las cosas.

```abap
CONSTANTS max_wait_time_in_seconds TYPE i.
DATA customizing_entries TYPE STANDARD TABLE …
METHODS read_user_preferences ...
CLASS /clean/user_preference_reader ...
```

**Usar plural** — Hay una práctica antigua en SAP en la que se nombran las tablas de las entidades en singular. Por ejemplo, `country` para una "tabla de países". Se recomienda elegir `countries` en su lugar.

**Usar nombres pronunciables** — Pensamos y hablamos mucho de objetos, así que usa nombres que puedas pronunciar. Es preferible `tipos_de_objeto_de_detección` a algo ininteligible como `tipobjdet`.

**Evita abreviaciones** — Si tienes suficiente espacio, escribe los nombres completos. Comienza a abreviar únicamente si excedes el límite de caracteres. Si tienes que abreviar, comienza con las palabras de poca importancia. Abreviar puede parecer eficiente inicialmente, pero se vuelve ambiguo muy rápido. Por ejemplo, nombrar una variable como `cust`: ¿significa "customizing", "customer" o "custom"? Las tres son muy comunes en aplicaciones SAP.

**Usar las mismas abreviaciones en todas partes** — Las personas buscan usando palabras clave para encontrar código relevante. Apoya esto usando la misma abreviación para el mismo concepto. Por ejemplo, siempre abrevia "tipo de objeto de detección" a "tipobjdet", en lugar de mezclar "tod", "tipod", "tipobjd", etc.

**Usar sustantivos para las clases y verbos para los métodos** — Usa sustantivos o frases con sustantivos para nombrar clases, interfaces y objetos:

```abap
CLASS /clean/account
CLASS /clean/user_preferences
INTERFACE /clean/customizing_reader
```

Usa verbos o frases de verbos para nombrar métodos:

```abap
METHODS withdraw
METHODS add_message
METHODS read_entries
```

Iniciar métodos booleanos con verbos como `is_` y `has_` provee un flujo de lectura agradable: `IF is_empty( table ).` Se recomienda nombrar las funciones como a los métodos: `FUNCTION /clean/read_alerts`.

**Evite palabras poco específicas** — Omita las palabras que generan ruido, como "data", "info", "object". Reemplácelas con algo específico que realmente agregue valor:

- `account` en lugar de `account_data`
- `alert` en lugar de `alert_object`
- `user_preferences` en lugar de `user_info`
- `response_time_in_seconds` en lugar de `response_time_variable`

**Elige una palabra por concepto** — Elige un término para un concepto y apégate a él; no lo mezcles usando otros sinónimos, ya que harán al lector perder el tiempo buscando una diferencia que no existe.

```abap
" Correcto
METHODS read_this.
METHODS read_that.
METHODS read_those.

" Anti-pattern
METHODS read_this.
METHODS retrieve_that.
METHODS query_those.
```

**Usa nombres de patrones solo si los estás usando** — No uses los nombres de patrones de diseño de software para clases e interfaces a menos que de verdad los estés usando. Por ejemplo, no llames a tu clase `file_factory` a menos que realmente implemente el patrón de diseño de fábrica. Los patrones más comunes son: [Singleton](https://en.wikipedia.org/wiki/Singleton_pattern), [factory](https://en.wikipedia.org/wiki/Factory_method_pattern), [fachada](https://en.wikipedia.org/wiki/Facade_pattern), [composite](https://en.wikipedia.org/wiki/Composite_pattern), [decorador](https://en.wikipedia.org/wiki/Decorator_pattern), [iterador](https://en.wikipedia.org/wiki/Iterator_pattern), [observador](https://en.wikipedia.org/wiki/Observer_pattern) y [estrategia](https://en.wikipedia.org/wiki/Strategy_pattern).

**Evita codificaciones, como notación Húngara y prefijos** — Deshazte de todas las codificaciones con prefijos.

```abap
" Correcto
METHOD add_two_numbers.
  result = a + b.
ENDMETHOD.

" Anti-pattern (innecesariamente largo)
METHOD add_two_numbers.
  rv_result = iv_a + iv_b.
ENDMETHOD.
```

#### 29.1.2. Constantes

**Usa constantes en lugar de números mágicos** — Es más claro:

```abap
IF abap_type = cl_abap_typedescr=>typekind_date.

" Anti-pattern
IF abap_type = 'D'.
```

**Prefiere clases de enumeración a interfaces de constantes:**

```abap
CLASS /clean/message_severity DEFINITION PUBLIC ABSTRACT FINAL.
  PUBLIC SECTION.
    CONSTANTS:
      warning TYPE symsgty VALUE 'W',
      error   TYPE symsgty VALUE 'E'.
ENDCLASS.
```

O bien:

```abap
CLASS /clean/message_severity DEFINITION PUBLIC CREATE PRIVATE FINAL.
  PUBLIC SECTION.
    CLASS-DATA:
      warning TYPE REF TO /clean/message_severity READ-ONLY,
      error   TYPE REF TO /clean/message_severity READ-ONLY.
    " ...
ENDCLASS.
```

En lugar de mezclar conceptos no relacionados o llevar erróneamente a la conclusión de que las colecciones de constantes pueden ser "implementadas":

```abap
" Anti-pattern
INTERFACE /dirty/common_constants.
  CONSTANTS:
    warning      TYPE symsgty VALUE 'W',
    transitional TYPE i       VALUE 1,
    error        TYPE symsgty VALUE 'E',
    persisted    TYPE i       VALUE 2.
ENDINTERFACE.
```

**Si no usas clases de enumeración, agrupa tus constantes** — Hace la relación más clara:

```abap
CONSTANTS:
  BEGIN OF message_severity,
    warning TYPE symsgty VALUE 'W',
    error   TYPE symsgty VALUE 'E',
  END OF message_severity,
  BEGIN OF message_lifespan,
    transitional TYPE i VALUE 1,
    persisted    TYPE i VALUE 2,
  END OF message_lifespan.
```

En lugar del anti-pattern:

```abap
" Anti-pattern
CONSTANTS:
  warning      TYPE symsgty VALUE 'W',
  transitional TYPE i       VALUE 1,
  error        TYPE symsgty VALUE 'E',
  persisted    TYPE i       VALUE 2.
```

El grupo también permite acceder a las constantes en conjunto, por ejemplo para validación de entradas:

```abap
DO.
  ASSIGN COMPONENT sy-index OF STRUCTURE message_severity TO FIELD-SYMBOL(<constant>).
  IF sy-subrc IS INITIAL.
    IF input = <constant>.
      DATA(is_valid) = abap_true.
      RETURN.
    ENDIF.
  ELSE.
    RETURN.
  ENDIF.
ENDDO.
```

#### 29.1.3. Variables

**Prefiere declaraciones en línea que al inicio** — Si sigues esta guía, tus métodos se volverán tan cortos (3-5 sentencias) que declarar variables en línea será más natural.

```abap
METHOD do_something.
  DATA(name) = 'something'.
  DATA(reader) = /clean/reader=>get_instance_for( name ).
  result = reader->read_it( ).
ENDMETHOD.

" Anti-pattern
METHOD do_something.
  DATA:
    name   TYPE seoclsname,
    reader TYPE REF TO /dirty/reader.
  name = 'something'.
  reader = /dirty/reader=>get_instance_for( name ).
  result = reader->read_it( ).
ENDMETHOD.
```

**No declares variables en ramas opcionales** — Esto funciona porque ABAP maneja las declaraciones en línea como si estuvieran al inicio del método. Sin embargo, es extremadamente confuso para los lectores, especialmente si el método es largo. En este caso, no uses in-line y coloca la declaración al inicio.

```abap
DATA value TYPE i.
IF has_entries = abap_true.
  value = 1.
ELSE.
  value = 2.
ENDIF.
```

**No encadenes declaraciones** — El encadenamiento sugiere que las variables definidas están relacionadas a nivel lógico. Para usarlo consistentemente, tendrías que asegurarte de que todas las variables encadenadas pertenecen juntas e introducir grupos encadenados adicionales para agregar variables; aunque es posible, el esfuerzo rara vez vale la pena. Además, complica reformatear y refactorizar el código.

```abap
" Anti-pattern
DATA:
  name   TYPE seoclsname,
  reader TYPE REF TO reader.
```

**Prefiere REF a un SÍMBOLO DE CAMPO:**

```abap
LOOP AT components REFERENCE INTO DATA(component).

" Anti-pattern
LOOP AT components ASSIGNING FIELD-SYMBOL(<component>).
```

Excepto cuando se necesitan los field-symbols:

```abap
ASSIGN generic->* TO FIELD-SYMBOL(<generic>).
ASSIGN COMPONENT name OF STRUCTURE structure TO FIELD-SYMBOL(<component>).
ASSIGN (class_name)=>(static_member) TO FIELD-SYMBOL(<member>).
```

#### 29.1.4. Tablas

**Usa el tipo correcto de tabla:**

- Típicamente se usan tablas del tipo `HASHED` para tablas grandes que son llenadas en un solo paso, nunca se modifican y son leídas seguido por su llave. Su sobrecosto en memoria y procesamiento hace a las tablas hash únicamente valiosas cuando se tienen grandes cantidades de datos y muchos accesos de lectura. Cada cambio al contenido de la tabla requiere costosos recálculos del hash, así que no utilices este tipo para tablas que son modificadas muy frecuentemente.
- Típicamente se usan tablas del tipo `SORTED` para tablas grandes que necesitan estar ordenadas en todo momento, que son llenadas poco a poco, o que necesitan ser modificadas y leídas por una o más claves parciales o completas o procesadas en cierto orden. Agregar, cambiar o quitar contenido requiere encontrar el punto de inserción adecuado, pero no requiere reajustar los índices de la tabla completa. Las tablas ordenadas valen la pena únicamente para grandes cantidades de accesos de lectura.
- Usa tablas del tipo `STANDARD` para tablas pequeñas, donde el indexado genera más costo que beneficio, y para arreglos, donde no te interesa el orden de las filas o quieres procesarlas exactamente en el orden en que se agregaron. Además, si se requieren diferentes tipos de acceso a la tabla (por ejemplo, acceso por índice y acceso ordenado vía `SORT` y `BINARY SEARCH`).

**Evitar usar CLAVE PREDETERMINADA** — Las claves por defecto combinadas solo son agregadas a las sentencias funcionales nuevas para que funcionen. Las claves en sí mismas son usualmente superfluas y desperdician recursos sin motivo. Pueden incluso llevar a errores difíciles de detectar porque ignoran los tipos de datos numéricos. Las sentencias `SORT` y `DELETE ADJACENT` sin una lista explícita de campos van a utilizar la clave primaria de la tabla interna, que en el caso de `DEFAULT KEY` puede provocar resultados inesperados cuando se tienen campos numéricos como componentes de la clave, en particular en combinación con `READ TABLE ... BINARY`, etc.

Especifica los componentes de la llave explícitamente:

```abap
DATA itab2 TYPE STANDARD TABLE OF row_type WITH NON-UNIQUE KEY comp1 comp2.
```

Recurre a usar `EMPTY KEY` si no necesitas la clave para nada:

```abap
DATA itab1 TYPE STANDARD TABLE OF row_type WITH EMPTY KEY.
```

**Prefiere INSERT INTO TABLE y APPEND TO** — `INSERT INTO TABLE` funciona con todos los tipos de tabla y de clave, por lo tanto hace más fácil refactorizar el tipo de tabla y las definiciones de clave si los requisitos de rendimiento cambian. Utiliza `APPEND TO` únicamente si usas una tabla `STANDARD` en modo de arreglo, cuando quieres dejar claro que el registro añadido será el último.

**Prefiere LINE_EXISTS a READ TABLE o LOOP AT:**

```abap
IF line_exists( my_table[ key = 'A' ] ).

" Anti-pattern
READ TABLE my_table TRANSPORTING NO FIELDS WITH KEY key = 'A'.
IF sy-subrc = 0.

" Anti-pattern
LOOP AT my_table REFERENCE INTO DATA(line) WHERE key = 'A'.
  line_exists = abap_true.
  EXIT.
ENDLOOP.
```

**Prefiere READ TABLE a LOOP AT** — Expresa la intención más clara y corta que:

```abap
" Anti-pattern
LOOP AT my_table REFERENCE INTO DATA(line) WHERE key = 'A'.
  EXIT.
ENDLOOP.

" Anti-pattern
LOOP AT my_table REFERENCE INTO DATA(line).
  IF line->key = 'A'.
    EXIT.
  ENDIF.
ENDLOOP.
```

**Prefiere LOOP AT WHERE a IF anidado** — Expresa la intención más clara y corta que:

```abap
" Anti-pattern
LOOP AT my_table REFERENCE INTO DATA(line).
  IF line->key = 'A'.
    EXIT.
  ENDIF.
ENDLOOP.
```

**Evita lecturas innecesarias de tablas** — En caso de que esperes que un registro esté ahí, lee una vez y reacciona a la excepción:

```abap
TRY.
    DATA(row) = my_table[ key = input ].
  CATCH cx_sy_itab_line_not_found.
    RAISE EXCEPTION NEW /clean/my_data_not_found( ).
ENDTRY.
```

En lugar de contaminar el flujo de control principal con una lectura doble:

```abap
" Anti-pattern
IF NOT line_exists( my_table[ key = input ] ).
  RAISE EXCEPTION NEW /clean/my_data_not_found( ).
ENDIF.
DATA(row) = my_table[ key = input ].
```

#### 29.1.5. Strings (Instrumentos de cuerda)

**Usa `` ` `` para definir literales** — Evita usar `'`, ya que hace una conversión de tipo superflua y confunde al lector sobre si está lidiando con un `CHAR` o un `STRING`:

```abap
DATA(some_string) = `ABC`.

" Anti-pattern
DATA some_string TYPE string.
some_string = 'ABC'.
```

El uso de `| |` está generalmente bien, pero no puede ser usado para `CONSTANTS` y agrega costo innecesario cuando se especifica un valor fijo:

```abap
" Anti-pattern
DATA(some_string) = |ABC|.
```

**Usa `| |` para construir textos** — Las plantillas de cadena resaltan mejor qué es un literal y qué es una variable, especialmente si colocas múltiples variables en un texto:

```abap
DATA(message) = |Received an unexpected HTTP { status_code } with message { text }|.

" Anti-pattern
DATA(message) = `Received an unexpected HTTP ` && status_code && ` with message ` && text.
```

#### 29.1.6. Booleanos

**Usa los booleanos sabiamente** — Frecuentemente encontramos casos donde los booleanos naturalmente parecen ser la opción, hasta que un cambio de punto de vista sugiere que deberíamos haber elegido una enumeración. Generalmente, los booleanos son una mala elección para distinguir tipos de cosas porque casi siempre encontrarás casos que no son exclusivamente uno u otro.

```abap
" Anti-pattern
is_archived = abap_true.

" Mejor
archiving_status = /clean/archivation_status=>archiving_in_process.
```

Ejemplo de uso adecuado:

```abap
assert_true( xsdbool( document->is_archived( ) = abap_true AND
                      document->is_partially_archived( ) = abap_true ) ).
```

**Usa ABAP_BOOL para booleanos** — No utilices el tipo genérico `char 1`. Aunque es técnicamente compatible, esconde el hecho de que estamos lidiando con una variable booleana. También evita otros tipos de booleanos, ya que a menudo tienen efectos secundarios; por ejemplo, el tipo `boolean` usa un tercer valor llamado "indefinido" que resulta en sutiles errores de programación.

En algunos casos puede necesitar un elemento de diccionario de datos, por ejemplo para campos de DynPro. `abap_bool` no puede ser usado en este caso porque está definido en el type pool `abap`, no en el diccionario de datos. En este caso, utilice `boole_d` o `xfeld`. Cree su propio elemento de datos si necesita una descripción personalizada.

**Usa ABAP_TRUE y ABAP_FALSE para hacer comparaciones** — No uses los equivalentes en carácter `'X'` y `' '` o `space`, ya que hacen más difícil identificar que es una expresión booleana:

```abap
has_entries = abap_true.
IF has_entries = abap_false.

" Anti-pattern
has_entries = 'X'.
IF has_entries = space.
```

Evita comparaciones con `INITIAL`, ya que fuerza al lector a recordar que el default de `abap_bool` es `abap_false`:

```abap
" Anti-pattern
IF has_entries IS NOT INITIAL.
```

**Usa XSDBOOL para asignar variables booleanas** — El equivalente `IF-THEN-ELSE` es mucho más largo sin sentido:

```abap
DATA(has_entries) = xsdbool( line IS NOT INITIAL ).

" Anti-pattern
IF line IS INITIAL.
  has_entries = abap_false.
ELSE.
  has_entries = abap_true.
ENDIF.
```

## 30. Anexos

### 30.1. Anexo 1 – Frente Funcional

| Código | Descripción |
|---|---|
| P | Producción |
| F | Finanzas |
| G | Gestión |
| H | Recursos Humanos |
| C | CRM |

### 30.2. Anexo 2 – Módulos

| Código | Descripción |
|---|---|
| FI | Desarrollo Cross Finanzas |
| HR | Recursos Humanos |
| MM | Materiales |
| SD | Documentos Ventas |
| AP | Cuentas Por Pagar |
| AR | Cuentas Por Cobrar |
| AM | Activo Fijo |
| SL | Special Ledger |
| CO | Controlling |
| XX | Cross Application |
| BP | Business Partner |

---

## Control de versiones del documento

| Rol | Área / Departamento | Fecha |
|---|---|---|
| Elaborador | Arquitectura Empresarial — Departamento Arquitectura Empresarial | 13/02/2024 |
| Revisor | Arquitectura Ciberseguridad — Departamento Arquitectura Ciberseguridad | 15/04/2024 |
| Aprobador | Arquitectura Empresarial — Departamento Arquitectura Empresarial | 17/04/2024 |
