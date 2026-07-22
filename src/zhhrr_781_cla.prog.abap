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

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_handles
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error al grabar el log de aplicación'(m04) TYPE 'I'.
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
        IMPORTING pi_test    TYPE abap_bool
                  pi_ventana TYPE i
                  pi_log     TYPE REF TO lcl_log,
      " Procesa un empleado entregado por la LDB PNP (SDD 4.1)
      procesar_empleado
        IMPORTING pu_pernr TYPE pernr_d
                  pu_begda TYPE begda
                  pu_endda TYPE endda,
      " Muestra el resultado consolidado en ALV
      mostrar_resultado.

  PRIVATE SECTION.
    DATA: l_test    TYPE abap_bool,
          l_ventana TYPE i,             " Ventana de proximidad en horas
          lo_log    TYPE REF TO lcl_log.

    METHODS:
      " Paso 1: lee FEHLER del cluster B2 y devuelve días con
      " mensaje de marca duplicada (filtro de entrada del proceso)
      leer_dias_con_duplicados
        IMPORTING pu_pernr        TYPE pernr_d
                  pu_begda        TYPE begda
                  pu_endda        TYPE endda
        RETURNING VALUE(pr_dias)  TYPE gty_t_fechas,

      " Pasos 2-6: procesa las marcas de un día concreto
      procesar_dia
        IMPORTING pu_pernr TYPE pernr_d
                  pu_datum TYPE datum,

      " Paso 3 (SDD 4.2): horario vigente; IT2003 prevalece sobre IT0007
      obtener_horario_vigente
        IMPORTING pu_datum          TYPE datum
        RETURNING VALUE(pr_horario) TYPE gty_horario,

      " Obtiene entrada/salida del plan de horario diario (T552A/T550A)
      leer_horario_teorico
        IMPORTING pu_datum          TYPE datum
        RETURNING VALUE(pr_horario) TYPE gty_horario,

      " Paso 4 (SDD 4.3): corrige clase de hecho P10 <-> P20 en TEVEN
      corregir_tipo_marca
        IMPORTING pu_marca TYPE gty_marca
                  pu_nuevo TYPE retyp,

      " Paso 5 (SDD 4.4): eliminación lógica de la marca de Portal
      eliminar_marca_portal
        IMPORTING pu_marca TYPE gty_marca,

      " Registra un resultado en la tabla de salida y en SLG1
      registrar
        IMPORTING pu_marca   TYPE gty_marca
                  pu_accion  TYPE char20
                  pu_detalle TYPE char80
                  pu_tipo    TYPE symsgty DEFAULT 'S'.
ENDCLASS.

*--------------------------------------------------------------------*
* CLASS lcl_depurador IMPLEMENTATION
*--------------------------------------------------------------------*
CLASS lcl_depurador IMPLEMENTATION.

  METHOD constructor.
    l_test    = pi_test.
    l_ventana = pi_ventana.
    lo_log    = pi_log.
  ENDMETHOD.

  METHOD procesar_empleado.
    DATA: lt_dias TYPE gty_t_fechas.

    " Paso 1: días con mensaje de marca duplicada según FEHLER
    lt_dias = leer_dias_con_duplicados( pu_pernr = pu_pernr
                                        pu_begda = pu_begda
                                        pu_endda = pu_endda ).
    IF lt_dias IS INITIAL.
      RETURN.   " Sin error de duplicados: el empleado no se procesa
    ENDIF.

    LOOP AT lt_dias REFERENCE INTO DATA(lr_dia).
      procesar_dia( pu_pernr = pu_pernr
                    pu_datum = lr_dia->* ).
    ENDLOOP.
  ENDMETHOD.

  METHOD leer_dias_con_duplicados.
    DATA: l_fecha TYPE datum,
          l_pabrj TYPE pabrj,
          l_pabrp TYPE pabrp.

    " Recorre los períodos mensuales del rango e importa el cluster B2.
    " La importación se delega a una FORM (include ZHHRR_781_F00)
    " porque las macros RP-IMP-* no están soportadas en contexto OO.
    l_fecha = pu_begda.
    WHILE l_fecha <= pu_endda.
      l_pabrj = l_fecha(4).
      l_pabrp = l_fecha+4(2).

      PERFORM f_leer_fehler_b2 USING pu_pernr
                                     l_pabrj
                                     l_pabrp
                                     pu_begda
                                     pu_endda
                            CHANGING pr_dias.

      " Avanza al primer día del mes siguiente
      l_fecha+6(2) = '01'.
      l_fecha      = l_fecha + 32.
      l_fecha+6(2) = '01'.
    ENDWHILE.
  ENDMETHOD.

  METHOD procesar_dia.
    DATA: lt_marcas   TYPE gty_t_marcas,
          l_esperado  TYPE retyp,
          l_dif_ent   TYPE i,
          l_dif_sal   TYPE i,
          l_seg_vent  TYPE i.

    " Ventana de proximidad en segundos
    l_seg_vent = l_ventana * 3600.

    "----------------------------------------------------------------
    " Lectura de las marcaciones del día en TEVEN (solo lectura)
    "----------------------------------------------------------------
    SELECT pernr, ldate, ltime, pdsnr, satza, terid
      FROM teven
      INTO CORRESPONDING FIELDS OF TABLE @lt_marcas
      WHERE pernr = @pu_pernr
        AND ldate = @pu_datum
        AND ( satza = @gc_satza_entrada OR satza = @gc_satza_salida )
      ORDER BY ltime.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    "----------------------------------------------------------------
    " Paso 3: horario vigente (IT2003 prevalece SIEMPRE sobre IT0007)
    "----------------------------------------------------------------
    DATA(lwa_horario) = obtener_horario_vigente( pu_datum ).
    IF lwa_horario-beguz IS INITIAL AND lwa_horario-enduz IS INITIAL.
      registrar( pu_marca   = VALUE #( pernr = pu_pernr ldate = pu_datum )
                 pu_accion  = 'NO PROCESADA'(a03)
                 pu_detalle = 'Sin horario vigente determinable'(d01)
                 pu_tipo    = 'W' ).
      RETURN.
    ENDIF.

    "----------------------------------------------------------------
    " Paso 4: discernimiento del tipo de marca (SDD 4.3)
    "----------------------------------------------------------------
    LOOP AT lt_marcas REFERENCE INTO DATA(lr_marca).
      l_dif_ent = abs( lr_marca->ltime - lwa_horario-beguz ).
      l_dif_sal = abs( lr_marca->ltime - lwa_horario-enduz ).

      DATA(l_en_entrada) = xsdbool( l_dif_ent <= l_seg_vent ).
      DATA(l_en_salida)  = xsdbool( l_dif_sal <= l_seg_vent ).

      IF l_en_entrada = abap_true AND l_en_salida = abap_true.
        " Marca en ambas ventanas: no se corrige automáticamente
        registrar( pu_marca   = lr_marca->*
                   pu_accion  = 'NO PROCESADA'(a03)
                   pu_detalle = 'Marca dentro de ambas ventanas'(d02)
                   pu_tipo    = 'W' ).
        CONTINUE.
      ELSEIF l_en_entrada = abap_false AND l_en_salida = abap_false.
        " Marca fuera de rango: solo se registra en el log
        registrar( pu_marca   = lr_marca->*
                   pu_accion  = 'NO PROCESADA'(a03)
                   pu_detalle = 'Marca fuera de las ventanas'(d03)
                   pu_tipo    = 'W' ).
        CONTINUE.
      ENDIF.

      l_esperado = COND #( WHEN l_en_entrada = abap_true
                           THEN gc_satza_entrada
                           ELSE gc_satza_salida ).

      IF lr_marca->satza <> l_esperado.
        corregir_tipo_marca( pu_marca = lr_marca->*
                             pu_nuevo = l_esperado ).
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

      DATA(lt_evento) = VALUE gty_t_marcas( FOR lwa IN lt_marcas
                                            WHERE ( satza = l_tipo )
                                            ( lwa ) ).
      IF lines( lt_evento ) < 2.
        CONTINUE.   " Sin duplicado para este evento
      ENDIF.

      " Verifica la casuística: una marca de reloj (0) y una de Portal
      DATA(l_hay_reloj)  = xsdbool( line_exists( lt_evento[ terid = gc_idt_reloj ] ) ).
      DATA(l_hay_portal) = xsdbool( line_exists( lt_evento[ terid = gc_idt_portal ] ) ).

      IF l_hay_reloj = abap_true AND l_hay_portal = abap_true.
        " Regla fija: SIEMPRE prevalece IDTFinal = 0, se elimina PORT
        LOOP AT lt_evento REFERENCE INTO DATA(lr_portal)
             WHERE terid = gc_idt_portal.
          eliminar_marca_portal( lr_portal->* ).
        ENDLOOP.
      ELSE.
        " Duplicado del mismo origen: fuera de alcance de esta fase
        LOOP AT lt_evento REFERENCE INTO DATA(lr_dup).
          registrar( pu_marca   = lr_dup->*
                     pu_accion  = 'NO PROCESADA'(a03)
                     pu_detalle = 'Duplicado del mismo origen'(d04)
                     pu_tipo    = 'W' ).
        ENDLOOP.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD obtener_horario_vigente.
    "----------------------------------------------------------------
    " Suplencia (IT2003): prevalece SIEMPRE sobre el horario teórico
    "----------------------------------------------------------------
    LOOP AT p2003 REFERENCE INTO DATA(lr_supl)
         WHERE begda <= pu_datum AND endda >= pu_datum.

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
        SELECT sobeg, soend
          FROM t550a
          INTO ( @pr_horario-beguz, @pr_horario-enduz )
          UP TO 1 ROWS
          WHERE tprog = @lr_supl->tprog
            AND endda >= @pu_datum
            AND begda <= @pu_datum
          ORDER BY motpr, varia, seqno.
        ENDSELECT.
        IF sy-subrc = 0.
          pr_horario-fuente = gc_fuente_supl.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.

    "----------------------------------------------------------------
    " Sin suplencia: horario teórico del IT0007
    "----------------------------------------------------------------
    pr_horario = leer_horario_teorico( pu_datum ).
  ENDMETHOD.

  METHOD leer_horario_teorico.
    DATA: l_schkz  TYPE schkn,
          l_zeity  TYPE dzeity,
          l_mosid  TYPE mosid,
          l_mofid  TYPE hident,
          l_tprog  TYPE tprog,
          l_campo  TYPE fieldname.

    FIELD-SYMBOLS: <lfs_tprog> TYPE any.

    " Regla de plan de horario del IT0007 vigente en la fecha
    LOOP AT p0007 REFERENCE INTO DATA(lr_p0007)
         WHERE begda <= pu_datum AND endda >= pu_datum.
      l_schkz = lr_p0007->schkz.
      EXIT.
    ENDLOOP.
    IF l_schkz IS INITIAL.
      RETURN.
    ENDIF.

    " Agrupadores desde la asignación organizativa (IT0001)
    LOOP AT p0001 REFERENCE INTO DATA(lr_p0001)
         WHERE begda <= pu_datum AND endda >= pu_datum.

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

    " Plan de horario mensual generado (T552A): TPROG del día
    SELECT * FROM t552a
      INTO @DATA(lwa_t552a)
      UP TO 1 ROWS
      WHERE zeity = @l_zeity
        AND mofid = @l_mofid
        AND mosid = @l_mosid
        AND schkz = @l_schkz
        AND kjahr = @pu_datum(4)
        AND monat = @pu_datum+4(2).
    ENDSELECT.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Campo TPRnn correspondiente al día del mes
    l_campo = |TPR{ pu_datum+6(2) }|.
    ASSIGN COMPONENT l_campo OF STRUCTURE lwa_t552a TO <lfs_tprog>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    l_tprog = <lfs_tprog>.

    " Horas de entrada/salida del plan de horario diario (T550A)
    " SOBEG/SOEND: inicio/fin del horario de trabajo teórico.
    " TODO [SDD 8]: incluir el agrupador MOTPR según el customizing
    " del sistema (asignación MOSID -> MOTPR) si existe más de uno.
    SELECT sobeg, soend
      FROM t550a
      INTO ( @pr_horario-beguz, @pr_horario-enduz )
      UP TO 1 ROWS
      WHERE tprog = @l_tprog
        AND endda >= @pu_datum
        AND begda <= @pu_datum
      ORDER BY motpr, varia, seqno.
    ENDSELECT.
    IF sy-subrc = 0.
      pr_horario-fuente = gc_fuente_teor.
    ENDIF.
  ENDMETHOD.

  METHOD corregir_tipo_marca.
    DATA: lwa_p2011 TYPE p2011,
          lwa_key   TYPE bapipakey,
          lwa_ret   TYPE bapireturn1.

    " En simulación solo se registra la acción propuesta
    IF l_test = abap_false.
      " Actualización vía infotipo 2011 (no update directo a TEVEN,
      " estándar LATAM 11.3). TODO [SDD 8]: confirmar mecanismo.
      lwa_p2011-pernr = pu_marca-pernr.
      lwa_p2011-infty = '2011'.
      lwa_p2011-begda = pu_marca-ldate.
      lwa_p2011-endda = pu_marca-ldate.
      lwa_p2011-ldate = pu_marca-ldate.
      lwa_p2011-ltime = pu_marca-ltime.
      lwa_p2011-pdsnr = pu_marca-pdsnr.
      lwa_p2011-satza = pu_nuevo.
      lwa_p2011-terid = pu_marca-terid.

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = '2011'
          number        = pu_marca-pernr
          record        = lwa_p2011
          validitybegin = pu_marca-ldate
          validityend   = pu_marca-ldate
          operation     = 'MOD'
          tclas         = 'B'          " Datos de tiempos (PCLAS B)
        IMPORTING
          return        = lwa_ret
          key           = lwa_key.
      IF lwa_ret-type = 'E' OR lwa_ret-type = 'A'.
        registrar( pu_marca   = pu_marca
                   pu_accion  = 'ERROR'(a04)
                   pu_detalle = 'Fallo al corregir tipo de marca'(d05)
                   pu_tipo    = 'E' ).
        RETURN.
      ENDIF.
    ENDIF.

    registrar( pu_marca   = pu_marca
               pu_accion  = 'CORRECCION'(a01)
               pu_detalle = |{ 'Tipo corregido a'(d06) } { pu_nuevo }| ).
  ENDMETHOD.

  METHOD eliminar_marca_portal.
    " Eliminación LÓGICA de la marca de Portal (IDTFinal = PORT).
    " TODO [SDD 8]: confirmar el indicador definitivo de borrado
    " lógico en TEVEN (p.ej. campo de cliente PDC_USRUP / USER2)
    " y el mecanismo de actualización. La marca original se conserva.
    DATA: lwa_p2011 TYPE p2011,
          lwa_ret   TYPE bapireturn1.

    IF l_test = abap_false.
      lwa_p2011-pernr = pu_marca-pernr.
      lwa_p2011-infty = '2011'.
      lwa_p2011-begda = pu_marca-ldate.
      lwa_p2011-endda = pu_marca-ldate.
      lwa_p2011-ldate = pu_marca-ldate.
      lwa_p2011-ltime = pu_marca-ltime.
      lwa_p2011-pdsnr = pu_marca-pdsnr.
      lwa_p2011-satza = pu_marca-satza.
      lwa_p2011-terid = pu_marca-terid.
      lwa_p2011-user2 = 'ELIM_LOGICA'.   " Indicador provisorio de borrado

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = '2011'
          number        = pu_marca-pernr
          record        = lwa_p2011
          validitybegin = pu_marca-ldate
          validityend   = pu_marca-ldate
          operation     = 'MOD'
          tclas         = 'B'
        IMPORTING
          return        = lwa_ret.
      IF lwa_ret-type = 'E' OR lwa_ret-type = 'A'.
        registrar( pu_marca   = pu_marca
                   pu_accion  = 'ERROR'(a04)
                   pu_detalle = 'Fallo en eliminación lógica'(d07)
                   pu_tipo    = 'E' ).
        RETURN.
      ENDIF.
    ENDIF.

    registrar( pu_marca   = pu_marca
               pu_accion  = 'ELIM.LOGICA'(a02)
               pu_detalle = 'Marca Portal duplicada eliminada'(d08) ).
  ENDMETHOD.

  METHOD registrar.
    " Tabla de resultados para el ALV final
    INSERT VALUE gty_resultado( pernr   = pu_marca-pernr
                                ldate   = pu_marca-ldate
                                ltime   = pu_marca-ltime
                                pdsnr   = pu_marca-pdsnr
                                accion  = pu_accion
                                detalle = pu_detalle )
           INTO TABLE gt_resultado.

    " Registro en SLG1: siempre que exista un cambio o novedad
    lo_log->agregar(
      pi_tipo  = pu_tipo
      pi_texto = |PERNR { pu_marca-pernr } { pu_marca-ldate } | &
                 |{ pu_marca-ltime } PDSNR { pu_marca-pdsnr }: | &
                 |{ pu_accion } - { pu_detalle }| ).
  ENDMETHOD.

  METHOD mostrar_resultado.
    DATA: lo_alv TYPE REF TO cl_salv_table.

    IF gt_resultado IS INITIAL.
      MESSAGE 'No se encontraron marcas para depurar'(m05) TYPE 'S'.
      RETURN.
    ENDIF.

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
