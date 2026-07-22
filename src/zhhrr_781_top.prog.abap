*&============================================================*
*& Include ZHHRR_781_TOP                                      *
*& Declaración de tablas, infotipos, tipos, constantes y      *
*& variables globales del programa ZHHRR_781                  *
*&============================================================*

*--------------------------------------------------------------------*
* Tablas / BD lógica PNP
*--------------------------------------------------------------------*
" Nodo de la BD lógica PNP (requiere asignar la LDB "PNP" en los
" atributos del programa - SE38 -> Atributos -> Base de datos lógica)
NODES: pernr.

TABLES: pcl1,    " Cluster de datos HR
        pcl2.    " Cluster de resultados (B2: tiempos)

" Infotipos provistos por la LDB PNP
INFOTYPES: 0001,   " Asignación organizativa (agrupadores de horario)
           0007,   " Horario de trabajo teórico
           2003.   " Suplencias (prevalece sobre IT0007)

*--------------------------------------------------------------------*
* Cluster B2 (resultados de la evaluación de tiempos)
* RPC2B200 declara las tablas del cluster, incluida FEHLER
*--------------------------------------------------------------------*
INCLUDE rpc2b200.

" Buffer estándar para importación de clusters PCLx
INCLUDE rpppxd00.
DATA: BEGIN OF COMMON PART buffer.
INCLUDE rpppxd10.
DATA: END OF COMMON PART buffer.

*--------------------------------------------------------------------*
* Declaración diferida de clases (definidas en ZHHRR_781_CLA)
*--------------------------------------------------------------------*
CLASS lcl_log DEFINITION DEFERRED.
CLASS lcl_depurador DEFINITION DEFERRED.

*--------------------------------------------------------------------*
* Tipos globales
*--------------------------------------------------------------------*
TYPES: BEGIN OF gty_horario,
         beguz  TYPE beguz,        " Hora entrada del horario vigente
         enduz  TYPE enduz,        " Hora salida del horario vigente
         fuente TYPE char6,        " IT2003 | IT0007
       END OF gty_horario.

TYPES: BEGIN OF gty_marca,
         pernr TYPE pernr_d,
         ldate TYPE ldate,         " Fecha lógica
         ltime TYPE ltime,         " Hora lógica
         pdsnr TYPE pdsnr_d,       " Clave unívoca del evento
         satza TYPE retyp,         " P10 entrada / P20 salida
         terid TYPE terid,         " 0 = reloj control / PORT = Portal
       END OF gty_marca.
TYPES: gty_t_marcas TYPE STANDARD TABLE OF gty_marca WITH EMPTY KEY.

TYPES: gty_t_fechas TYPE STANDARD TABLE OF datum WITH EMPTY KEY.

TYPES: BEGIN OF gty_resultado,
         pernr   TYPE pernr_d,
         ldate   TYPE ldate,
         ltime   TYPE ltime,
         pdsnr   TYPE pdsnr_d,
         accion  TYPE char20,      " CORRECCION / ELIM.LOGICA / NO PROCESADA
         detalle TYPE char80,
       END OF gty_resultado.

*--------------------------------------------------------------------*
* Constantes
*--------------------------------------------------------------------*
CONSTANTS:
  gc_satza_entrada TYPE retyp      VALUE 'P10',   " Marca de entrada
  gc_satza_salida  TYPE retyp      VALUE 'P20',   " Marca de salida
  gc_idt_portal    TYPE terid      VALUE 'PORT',  " Origen Portal
  gc_idt_reloj     TYPE terid      VALUE '0',     " Origen reloj control
  gc_cltyp_b2      TYPE pcl2-srtfd VALUE '1',     " Tipo cluster eval.tiempos
  gc_fuente_supl   TYPE char6      VALUE 'IT2003',
  gc_fuente_teor   TYPE char6      VALUE 'IT0007',
  gc_tcode         TYPE sy-tcode   VALUE 'ZHHRT_781', " TODO [SDD 8] confirmar Tx
  " TODO [SDD 8]: confirmar objeto/subobjeto SLG1 definitivos
  gc_log_objeto    TYPE balobj_d   VALUE 'ZHR',
  gc_log_subobjeto TYPE balsubobj  VALUE 'ZDEPURA_MARCAS'.

*--------------------------------------------------------------------*
* Variables globales
*--------------------------------------------------------------------*
DATA: gt_resultado TYPE STANDARD TABLE OF gty_resultado WITH EMPTY KEY,
      go_log       TYPE REF TO lcl_log,
      go_depurador TYPE REF TO lcl_depurador.
