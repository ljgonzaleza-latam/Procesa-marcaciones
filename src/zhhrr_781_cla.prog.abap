*&============================================================*
*& Include ZHHRR_781_CLA                                      *
*& Clases locales del programa ZHHRR_781                      *
*&   - LCL_LOG:       registro en log de aplicación (SLG1)    *
*&   - LCL_DEPURADOR: lógica de depuración (SDD 4.1)          *
*&============================================================*

*--------------------------------------------------------------------*
* CLASS lcl_log DEFINITION
*--------------------------------------------------------------------*
CLASS lcl_log DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING pi_test TYPE abap_bool,
      " Agrega un mensaje de texto libre al log
      agregar
        IMPORTING pi_tipo  TYPE symsgty
                  pi_texto TYPE string,
      " Graba el log en base de datos (visible por SLG1)
      guardar.

  PRIVATE SECTION.
    DATA: l_handle TYPE balloghndl,
          l_test   TYPE abap_bool.
ENDCLASS.

*--------------------------------------------------------------------*
* CLASS lcl_log IMPLEMENTATION
*--------------------------------------------------------------------*
CLASS lcl_log IMPLEMENTATION.

  METHOD constructor.
    DATA: lwa_log TYPE bal_s_log.

    l_test = pi_test.

    " Creación del log de aplicación (framework BAL / SLG1)
    lwa_log-object    = gc_log_objeto.
    lwa_log-subobject = gc_log_subobjeto.
    lwa_log-extnumber = |{ sy-repid } { sy-datum } { sy-uzeit }|.
    lwa_log-aluser    = sy-uname.
    lwa_log-alprog    = sy-repid.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = lwa_log
      IMPORTING
        e_log_handle            = l_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      " Objeto/subobjeto no dados de alta en SLG0: se reintenta sin
      " ellos para no abortar (el log queda visible en SLG1 filtrando
      " por programa). TODO [SDD 8]: crear ZHR/ZDEPURA_MARCAS en SLG0.
      CLEAR: lwa_log-object, lwa_log-subobject.
      CALL FUNCTION 'BAL_LOG_CREATE'
        EXPORTING
          i_s_log                 = lwa_log
        IMPORTING
          e_log_handle            = l_handle
        EXCEPTIONS
          log_header_inconsistent = 1
          OTHERS                  = 2.
      IF sy-subrc <> 0.
        MESSAGE 'Error al crear el log de aplicación'(m02) TYPE 'E'.
        LEAVE PROGRAM.
      ENDIF.
      MESSAGE 'Objeto de log no existe en SLG0; log sin clasificar'(m06)
        TYPE 'S' DISPLAY LIKE 'W'.
    ENDIF.
  ENDMETHOD.

  METHOD agregar.
    DATA: l_texto TYPE char200.

    l_texto = pi_texto.

    CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
      EXPORTING
        i_log_handle     = l_handle
        i_msgty          = pi_tipo
        i_text           = l_texto
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      " El fallo del log no debe abortar el proceso; se informa
      MESSAGE 'No fue posible registrar mensaje en el log'(m03) TYPE 'I'.
    ENDIF.
  ENDMETHOD.

  METHOD guardar.
    DATA: lt_handles TYPE bal_t_logh.

    " En modo simulación no se persiste el log
    IF l_test = abap_true.
      RETURN.
    ENDIF.

    INSERT l_handle INTO TABLE lt_handles.

    " Se graba SOLO el log propio: con I_SAVE_ALL el framework
    " intenta persistir también los logs temporales que crean
    " internamente los módulos estándar (p.ej. HR_INFOTYPE_OPERATION)
    " y la grabación completa falla con SAVE_NOT_ALLOWED
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_handles
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      " Detalle de la excepción para facilitar el diagnóstico:
      " 1 = log no encontrado / 2 = grabación no permitida (típico:
      " objeto/subobjeto no dados de alta en SLG0) / 3 = error de
      " rango de números del log de aplicación
      MESSAGE |{ 'Error al grabar el log de aplicación'(m04) } | &&
              |(BAL_DB_SAVE subrc { sy-subrc })| TYPE 'I'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

*--------------------------------------------------------------------*
* CLASS lcl_depurador DEFINITION
*--------------------------------------------------------------------*
CLASS lcl_depurador DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING pi_test TYPE abap_bool
                  pi_log  TYPE REF TO lcl_log,
      " Procesa un empleado entregado por la LDB PNP (SDD 4.1)
      procesar_empleado
        IMPORTING pi_pernr TYPE pernr_d
                  pi_begda TYPE begda
                  pi_endda TYPE endda,
      " Muestra el resultado consolidado en ALV
      mostrar_resultado.

  PRIVATE SECTION.
    DATA: l_test TYPE abap_bool,
          lo_log TYPE REF TO lcl_log.

    METHODS:
      " Paso 1: lee FEHLER del cluster B2 y devuelve días con
      " mensaje de marca duplicada (filtro de entrada del proceso)
      leer_dias_con_duplicados
        IMPORTING pi_pernr        TYPE pernr_d
                  pi_begda        TYPE begda
                  pi_endda        TYPE endda
        RETURNING VALUE(pr_dias)  TYPE gty_t_fechas,

      " Pasos 2-6: procesa las marcas de un día concreto
      procesar_dia
        IMPORTING pi_pernr TYPE pernr_d
                  pi_datum TYPE datum,

      " Paso 3 (SDD 4.2): horario vigente; IT2003 prevalece sobre IT0007
      obtener_horario_vigente
        IMPORTING pi_datum          TYPE datum
        RETURNING VALUE(pr_horario) TYPE gty_horario,

      " Obtiene entrada/salida del plan de horario diario (T552A/T550A)
      leer_horario_teorico
        IMPORTING pi_datum          TYPE datum
        RETURNING VALUE(pr_horario) TYPE gty_horario,

      " Paso 4 (SDD 4.3): corrige clase de hecho P10 <-> P20 en TEVEN
      corregir_tipo_marca
        IMPORTING pi_marca TYPE gty_marca
                  pi_nuevo TYPE retyp,

      " Paso 5 (SDD 4.4): eliminación lógica de la marca de Portal
      eliminar_marca_portal
        IMPORTING pi_marca TYPE gty_marca,

      " Registra un resultado en la tabla de salida y en SLG1
      registrar
        IMPORTING pi_marca   TYPE gty_marca
                  pi_accion  TYPE char20
                  pi_detalle TYPE char80
                  pi_tipo    TYPE symsgty DEFAULT 'S'.
ENDCLASS.

*--------------------------------------------------------------------*
* CLASS lcl_depurador IMPLEMENTATION
*--------------------------------------------------------------------*
CLASS lcl_depurador IMPLEMENTATION.

  METHOD constructor.
    l_test = pi_test.
    lo_log = pi_log.
  ENDMETHOD.

  METHOD procesar_empleado.
    DATA: lt_dias TYPE gty_t_fechas.

    " Paso 1: días con mensaje de marca duplicada según FEHLER
    lt_dias = leer_dias_con_duplicados( pi_pernr = pi_pernr
                                        pi_begda = pi_begda
                                        pi_endda = pi_endda ).
    IF lt_dias IS INITIAL.
      RETURN.   " Sin error de duplicados: el empleado no se procesa
    ENDIF.

    LOOP AT lt_dias REFERENCE INTO DATA(lr_dia).
      procesar_dia( pi_pernr = pi_pernr
                    pi_datum = lr_dia->* ).
    ENDLOOP.
  ENDMETHOD.

  METHOD leer_dias_con_duplicados.
    DATA: l_fecha TYPE datum,
          l_pabrj TYPE pabrj,
          l_pabrp TYPE pabrp.

    " Recorre los períodos mensuales del rango e importa el cluster B2.
    " La importación se delega a una FORM (include ZHHRR_781_F00)
    " porque las macros RP-IMP-* no están soportadas en contexto OO.
    l_fecha = pi_begda.
    WHILE l_fecha <= pi_endda.
      l_pabrj = l_fecha(4).
      l_pabrp = l_fecha+4(2).

      PERFORM f_leer_fehler_b2 USING pi_pernr
                                     l_pabrj
                                     l_pabrp
                                     pi_begda
                                     pi_endda
                            CHANGING pr_dias.

      " Avanza al primer día del mes siguiente
      l_fecha+6(2) = '01'.
      l_fecha      = l_fecha + 32.
      l_fecha+6(2) = '01'.
    ENDWHILE.
  ENDMETHOD.

  METHOD procesar_dia.
    DATA: lt_marcas  TYPE gty_t_marcas,
          l_esperado TYPE retyp,
          l_dif_ent  TYPE i,
          l_dif_sal  TYPE i.

    "----------------------------------------------------------------
    " Lectura de las marcaciones del día en TEVEN (solo lectura)
    "----------------------------------------------------------------
    " Lectura por día dentro del GET PERNR: el volumen es acotado
    " (solo días con error de duplicado según FEHLER)
    SELECT pernr, ldate, ltime, pdsnr, satza, terid
      FROM teven
      INTO CORRESPONDING FIELDS OF TABLE @lt_marcas
      WHERE pernr = @pi_pernr
        AND ldate = @pi_datum
        AND ( satza = @gc_satza_entrada OR satza = @gc_satza_salida )
      ORDER BY ltime.                            "#EC CI_SEL_NESTED
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "----------------------------------------------------------------
    " Paso 3: horario vigente (IT2003 prevalece SIEMPRE sobre IT0007)
    "----------------------------------------------------------------
    DATA(lwa_horario) = obtener_horario_vigente( pi_datum ).
    IF lwa_horario-beguz IS INITIAL AND lwa_horario-enduz IS INITIAL.
      registrar( pi_marca   = VALUE #( pernr = pi_pernr ldate = pi_datum )
                 pi_accion  = 'NO PROCESADA'(a03)
                 pi_detalle = 'Sin horario vigente determinable'(d01)
                 pi_tipo    = 'W' ).
      RETURN.
    ENDIF.

    "----------------------------------------------------------------
    " Paso 4: discernimiento del tipo de marca (SDD 4.3)
    "----------------------------------------------------------------
    " Sin ventana de proximidad: la marca se clasifica según la hora
    " del horario vigente más cercana (entrada o salida)
    " (pocas marcas por día: el acceso secuencial no impacta)
    LOOP AT lt_marcas REFERENCE INTO DATA(lr_marca). "#EC CI_STDSEQ
      l_dif_ent = abs( lr_marca->ltime - lwa_horario-beguz ).
      l_dif_sal = abs( lr_marca->ltime - lwa_horario-enduz ).

      l_esperado = COND #( WHEN l_dif_ent <= l_dif_sal
                           THEN gc_satza_entrada
                           ELSE gc_satza_salida ).

      IF lr_marca->satza <> l_esperado.
        corregir_tipo_marca( pi_marca = lr_marca->*
                             pi_nuevo = l_esperado ).
        lr_marca->satza = l_esperado.   " Refleja la corrección en memoria
      ENDIF.
    ENDLOOP.

    "----------------------------------------------------------------
    " Paso 5: deduplicación por origen (SDD 4.4)
    " Dos marcas del mismo tipo: se elimina lógicamente la de Portal
    "----------------------------------------------------------------
    DO 2 TIMES.
      DATA(l_tipo) = COND retyp( WHEN sy-index = 1
                                 THEN gc_satza_entrada
                                 ELSE gc_satza_salida ).

      DATA(lt_evento) = VALUE gty_t_marcas( FOR lwa_marca IN lt_marcas
                                            WHERE ( satza = l_tipo )
                                            ( lwa_marca ) ). "#EC CI_STDSEQ "#EC CI_NESTED
      IF lines( lt_evento ) < 2.
        CONTINUE.   " Sin duplicado para este evento
      ENDIF.

      " Verifica la casuística: una marca de reloj y una de Portal.
      " Se considera "reloj" toda marca cuyo terminal NO sea PORT
      " (el reloj control puede informar 0 u otro ID de terminal)
      DATA(l_hay_reloj) = abap_false.
      LOOP AT lt_evento TRANSPORTING NO FIELDS
           WHERE terid <> gc_idt_portal. "#EC CI_STDSEQ "#EC CI_NESTED
        l_hay_reloj = abap_true.
        EXIT.
      ENDLOOP.
      DATA(l_hay_portal) = xsdbool( line_exists( lt_evento[ terid = gc_idt_portal ] ) ).

      IF l_hay_reloj = abap_true AND l_hay_portal = abap_true.
        " Regla fija: SIEMPRE prevalece la marca que no es PORT
        LOOP AT lt_evento REFERENCE INTO DATA(lr_portal)
             WHERE terid = gc_idt_portal. "#EC CI_STDSEQ "#EC CI_NESTED
          eliminar_marca_portal( lr_portal->* ).
        ENDLOOP.
      ELSE.
        " Duplicado del mismo origen: fuera de alcance de esta fase
        LOOP AT lt_evento REFERENCE INTO DATA(lr_dup). "#EC CI_STDSEQ "#EC CI_NESTED
          registrar( pi_marca   = lr_dup->*
                     pi_accion  = 'NO PROCESADA'(a03)
                     pi_detalle = 'Duplicado del mismo origen'(d04)
                     pi_tipo    = 'W' ).
        ENDLOOP.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD obtener_horario_vigente.
    "----------------------------------------------------------------
    " Suplencia (IT2003): prevalece SIEMPRE sobre el horario teórico
    "----------------------------------------------------------------
    LOOP AT p2003 REFERENCE INTO DATA(lr_supl)
         WHERE begda <= pi_datum AND endda >= pi_datum. "#EC CI_STDSEQ

      IF lr_supl->beguz IS NOT INITIAL OR lr_supl->enduz IS NOT INITIAL.
        " La suplencia trae horas explícitas
        pr_horario-beguz  = lr_supl->beguz.
        pr_horario-enduz  = lr_supl->enduz.
        pr_horario-fuente = gc_fuente_supl.
        RETURN.
      ENDIF.

      " Suplencia por plan de horario diario (TPROG) -> T550A
      " (SOBEG/SOEND: inicio/fin del horario de trabajo teórico)
      IF lr_supl->tprog IS NOT INITIAL.
        " T550A es tabla con buffer genérico y clave parcial: lectura
        " puntual de baja frecuencia (1 por suplencia con TPROG)
        SELECT sobeg, soend
          FROM t550a
          INTO TABLE @DATA(lt_t550a)
          UP TO 1 ROWS
          WHERE tprog = @lr_supl->tprog
            AND endda >= @pi_datum
            AND begda <= @pi_datum
          ORDER BY motpr, varia, seqno. "#EC CI_GENBUFF "#EC CI_SEL_NESTED
        IF sy-subrc = 0.
          pr_horario-beguz  = lt_t550a[ 1 ]-sobeg.
          pr_horario-enduz  = lt_t550a[ 1 ]-soend.
          pr_horario-fuente = gc_fuente_supl.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "----------------------------------------------------------------
    " Sin suplencia: horario teórico del IT0007
    "----------------------------------------------------------------
    pr_horario = leer_horario_teorico( pi_datum ).
  ENDMETHOD.

  METHOD leer_horario_teorico.
    DATA: l_schkz  TYPE schkn,
          l_zeity  TYPE dzeity,
          l_mosid  TYPE mosid,
          l_mofid  TYPE hident,
          l_tprog  TYPE tprog,
          l_campo  TYPE fieldname.

    " Regla de plan de horario del IT0007 vigente en la fecha
    LOOP AT p0007 REFERENCE INTO DATA(lr_p0007)
         WHERE begda <= pi_datum AND endda >= pi_datum. "#EC CI_STDSEQ
      l_schkz = lr_p0007->schkz.
      EXIT.
    ENDLOOP.
    IF l_schkz IS INITIAL.
      RETURN.
    ENDIF.

    " Agrupadores desde la asignación organizativa (IT0001)
    LOOP AT p0001 REFERENCE INTO DATA(lr_p0001)
         WHERE begda <= pi_datum AND endda >= pi_datum. "#EC CI_STDSEQ

      " Agrupador de subdivisión de personal para planes de horario
      " y calendario de festivos (ambos parte de la clave de T552A)
      SELECT SINGLE mosid, mofid
        FROM t001p
        INTO ( @l_mosid, @l_mofid )
        WHERE werks = @lr_p0001->werks
          AND btrtl = @lr_p0001->btrtl.

      " Agrupador de grupo/área de personal para horarios
      SELECT SINGLE zeity
        FROM t503
        INTO @l_zeity
        WHERE persg = @lr_p0001->persg
          AND persk = @lr_p0001->persk.
      EXIT.
    ENDLOOP.

    " Plan de horario mensual generado (T552A): TPROG del día.
    " Lectura dinámica del campo TPRnn correspondiente al día del
    " mes (evita SELECT * según estándar LATAM)
    l_campo = |TPR{ pi_datum+6(2) }|.
    SELECT SINGLE (l_campo)
      FROM t552a
      WHERE zeity = @l_zeity
        AND mofid = @l_mofid
        AND mosid = @l_mosid
        AND schkz = @l_schkz
        AND kjahr = @pi_datum(4)
        AND monat = @pi_datum+4(2)
      INTO @l_tprog.
    IF sy-subrc <> 0 OR l_tprog IS INITIAL.
      RETURN.
    ENDIF.

    " Horas de entrada/salida del plan de horario diario (T550A)
    " SOBEG/SOEND: inicio/fin del horario de trabajo teórico.
    " TODO [SDD 8]: incluir el agrupador MOTPR según el customizing
    " del sistema (asignación MOSID -> MOTPR) si existe más de uno.
    " T550A es tabla con buffer genérico y clave parcial: lectura
    " puntual (1 por día procesado)
    SELECT sobeg, soend
      FROM t550a
      INTO TABLE @DATA(lt_t550a)
      UP TO 1 ROWS
      WHERE tprog = @l_tprog
        AND endda >= @pi_datum
        AND begda <= @pi_datum
      ORDER BY motpr, varia, seqno. "#EC CI_GENBUFF "#EC CI_SEL_NESTED
    IF sy-subrc = 0.
      pr_horario-beguz  = lt_t550a[ 1 ]-sobeg.
      pr_horario-enduz  = lt_t550a[ 1 ]-soend.
      pr_horario-fuente = gc_fuente_teor.
    ENDIF.
  ENDMETHOD.

  METHOD corregir_tipo_marca.
    DATA: l_subrc TYPE sysubrc.

    " En simulación solo se registra la acción propuesta
    IF l_test = abap_false.
      " El IT2011 escribe directamente sobre TEVEN y no existe
      " BAPI/operación de infotipo para MODIFICAR un evento ya
      " registrado. La corrección se realiza sobre TEVEN con bloqueo
      " previo del empleado y unidad de trabajo controlada
      " (desviación autorizada del estándar 21.1 - sin BAPI disponible)
      CALL FUNCTION 'ENQUEUE_EPPRELE'
        EXPORTING
          pernr          = pi_marca-pernr
          infty          = gc_infty_2011
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        registrar( pi_marca   = pi_marca
                   pi_accion  = 'ERROR'(a04)
                   pi_detalle = 'Empleado bloqueado por otro proceso'(d09)
                   pi_tipo    = 'E' ).
        RETURN.
      ENDIF.

      UPDATE teven SET satza = @pi_nuevo
             WHERE pdsnr = @pi_marca-pdsnr.
      l_subrc = sy-subrc.
      IF l_subrc = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

      CALL FUNCTION 'DEQUEUE_EPPRELE'
        EXPORTING
          pernr = pi_marca-pernr
          infty = gc_infty_2011.

      IF l_subrc <> 0.
        registrar( pi_marca   = pi_marca
                   pi_accion  = 'ERROR'(a04)
                   pi_detalle = 'Fallo al corregir tipo de marca'(d05)
                   pi_tipo    = 'E' ).
        RETURN.
      ENDIF.
    ENDIF.

    registrar( pi_marca   = pi_marca
               pi_accion  = 'CORRECCION'(a01)
               pi_detalle = |{ 'Tipo corregido a'(d06) } { pi_nuevo }| ).
  ENDMETHOD.

  METHOD eliminar_marca_portal.
    " Eliminación LÓGICA de la marca de Portal (IDTFinal = PORT):
    " se marca el campo de cliente USER2 de TEVEN con ELIM_LOGICA.
    " La marca original se conserva (nunca borrado físico).
    DATA: l_subrc TYPE sysubrc.

    IF l_test = abap_false.
      " El IT2011 escribe directamente sobre TEVEN y no existe
      " BAPI/operación de infotipo para MODIFICAR un evento ya
      " registrado. La actualización se realiza sobre TEVEN con
      " bloqueo previo del empleado y unidad de trabajo controlada
      " (desviación autorizada del estándar 21.1 - sin BAPI disponible)
      CALL FUNCTION 'ENQUEUE_EPPRELE'
        EXPORTING
          pernr          = pi_marca-pernr
          infty          = gc_infty_2011
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        registrar( pi_marca   = pi_marca
                   pi_accion  = 'ERROR'(a04)
                   pi_detalle = 'Empleado bloqueado por otro proceso'(d09)
                   pi_tipo    = 'E' ).
        RETURN.
      ENDIF.

      UPDATE teven SET user2 = @gc_marca_elim
             WHERE pdsnr = @pi_marca-pdsnr.
      l_subrc = sy-subrc.
      IF l_subrc = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

      CALL FUNCTION 'DEQUEUE_EPPRELE'
        EXPORTING
          pernr = pi_marca-pernr
          infty = gc_infty_2011.

      IF l_subrc <> 0.
        registrar( pi_marca   = pi_marca
                   pi_accion  = 'ERROR'(a04)
                   pi_detalle = 'Fallo en eliminación lógica'(d07)
                   pi_tipo    = 'E' ).
        RETURN.
      ENDIF.
    ENDIF.

    registrar( pi_marca   = pi_marca
               pi_accion  = 'ELIM.LOGICA'(a02)
               pi_detalle = 'Marca Portal duplicada eliminada'(d08) ).
  ENDMETHOD.

  METHOD registrar.
    " Tabla de resultados para el ALV final
    INSERT VALUE gty_resultado( pernr   = pi_marca-pernr
                                ldate   = pi_marca-ldate
                                ltime   = pi_marca-ltime
                                pdsnr   = pi_marca-pdsnr
                                terid   = pi_marca-terid
                                accion  = pi_accion
                                detalle = pi_detalle )
           INTO TABLE gt_resultado.

    " Registro en SLG1: siempre que exista un cambio o novedad
    lo_log->agregar(
      pi_tipo  = pi_tipo
      pi_texto = |PERNR { pi_marca-pernr } { pi_marca-ldate } | &
                 |{ pi_marca-ltime } PDSNR { pi_marca-pdsnr }: | &
                 |{ pi_accion } - { pi_detalle }| ).
  ENDMETHOD.

  METHOD mostrar_resultado.
    DATA: lo_alv TYPE REF TO cl_salv_table.

    IF gt_resultado IS INITIAL.
      MESSAGE 'No se encontraron marcas para depurar'(m05) TYPE 'S'.
      RETURN.
    ENDIF.

    " Una misma marca puede registrarse en más de un paso del proceso;
    " se eliminan las filas totalmente idénticas antes de mostrar
    SORT gt_resultado BY pernr ldate ltime pdsnr terid accion detalle.
    DELETE ADJACENT DUPLICATES FROM gt_resultado COMPARING ALL FIELDS.

    TRY.
        cl_salv_table=>factory(
          IMPORTING r_salv_table = lo_alv
          CHANGING  t_table      = gt_resultado ).
        lo_alv->get_functions( )->set_all( abap_true ).
        lo_alv->get_columns( )->set_optimize( abap_true ).
        lo_alv->display( ).
      CATCH cx_salv_msg INTO DATA(lo_error).
        MESSAGE lo_error->get_text( ) TYPE 'I'.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
