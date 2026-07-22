*&============================================================*
*& Report ZHHRR_781                                           *
*&============================================================*
*& Descripción: Depuración de marcaciones duplicadas en TEVEN *
*&              Lee FEHLER (cluster B2) para identificar días *
*&              con marca duplicada, valida contra IT0007 /   *
*&              IT2003 (suplencia prevalece), corrige tipo de *
*&              marca (P10<->P20) y elimina lógicamente la    *
*&              marca duplicada de Portal (TERID = PORT).     *
*&              Todo cambio se registra en SLG1.              *
*&              NO calcula horas. Ref.: SDD.md v0.3           *
*& Base de datos lógica: PNP (asignar en atributos programa)  *
*& Fecha Creación = 13.07.2026                                *
*& Creador        = XX                                        *
*& Empresa        = LATAM                                     *
*&============================================================*
*& Histórico de modificaciones                                *
*&============================================================*
*& Marca  Fecha       Autor  Descripción de la Modificación   *
*& @001   2026.07.13  XX     Versión inicial                  *
*&============================================================*
REPORT zhhrr_781.

INCLUDE zhhrr_781_top.   " Declaraciones globales / cluster B2
INCLUDE zhhrr_781_sel.   " Pantalla de selección
INCLUDE zhhrr_781_cla.   " Clases locales (lógica del proceso)

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.
  " Chequeo de autorización de transacción al inicio (estándar LATAM 7.1)
  " TODO [SDD 8]: reemplazar por la transacción Z definitiva (ZHHRT_xxx)
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD gc_tcode.
  IF sy-subrc <> 0.
    MESSAGE 'Sin autorización para ejecutar el programa'(m01) TYPE 'E'.
    LEAVE PROGRAM.
  ENDIF.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.
  " Instancia del log SLG1 y del depurador
  CREATE OBJECT go_log
    EXPORTING
      pi_test = p_test.
  CREATE OBJECT go_depurador
    EXPORTING
      pi_test    = p_test
      pi_ventana = p_venta
      pi_log     = go_log.

*--------------------------------------------------------------------*
* GET PERNR - bucle estándar de la BD lógica PNP
*--------------------------------------------------------------------*
GET pernr.
  " Procesa cada empleado entregado por la LDB PNP según selección
  go_depurador->procesar_empleado(
    pu_pernr = pernr-pernr
    pu_begda = pn-begda
    pu_endda = pn-endda ).

*--------------------------------------------------------------------*
* END-OF-SELECTION
*--------------------------------------------------------------------*
END-OF-SELECTION.
  " Graba el log de aplicación (SLG1) y muestra el resultado
  go_log->guardar( ).
  go_depurador->mostrar_resultado( ).

*--------------------------------------------------------------------*
* Rutinas estándar de buffer para clusters PCLx (macros RP-IMP/EXP)
*--------------------------------------------------------------------*
  INCLUDE rpppxm00.
