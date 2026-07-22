*&============================================================*
*& Include ZHHRR_781_F00                                      *
*& Subrutinas del programa ZHHRR_781                          *
*& Nota: la importación del cluster B2 usa las macros         *
*& estándar RP-IMP-*, que NO están soportadas en contexto     *
*& OO; por eso se encapsula en una FORM llamada desde la      *
*& clase LCL_DEPURADOR.                                       *
*&============================================================*

*&--------------------------------------------------------------------*
*& Form f_leer_fehler_b2
*&--------------------------------------------------------------------*
*& Importa el cluster B2 del período y agrega a PC_DIAS las fechas
*& con mensaje de marca duplicada (ERRTY/ERROR de la selección)
*&--------------------------------------------------------------------*
FORM f_leer_fehler_b2 USING pu_pernr TYPE pernr_d
                            pu_pabrj TYPE pabrj
                            pu_pabrp TYPE pabrp
                            pu_begda TYPE begda
                            pu_endda TYPE endda
                   CHANGING pc_dias  TYPE gty_t_fechas.

  " Clave del cluster B2 (resultados de evaluación de tiempos)
  CLEAR b2-key.
  b2-key-pernr = pu_pernr.
  b2-key-pabrj = pu_pabrj.
  b2-key-pabrp = pu_pabrp.
  b2-key-cltyp = gc_cltyp_b2.

  " Importación del cluster B2 (macro estándar; llena tabla FEHLER)
  rp-imp-c2-b2.

  IF rp-imp-b2-subrc <> 0.
    RETURN.   " Sin resultados de evaluación para el período
  ENDIF.

  " Filtro por el mensaje de marca duplicada (ERRTY/ERROR)
  LOOP AT fehler WHERE errty = p_errty
                   AND error = p_error
                   AND ldate BETWEEN pu_begda AND pu_endda.
    " Un día se procesa una sola vez aunque tenga varios mensajes
    READ TABLE pc_dias WITH KEY table_line = fehler-ldate
         TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      APPEND fehler-ldate TO pc_dias.
    ENDIF.
  ENDLOOP.
ENDFORM.
