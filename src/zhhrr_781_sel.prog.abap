*&============================================================*
*& Include ZHHRR_781_SEL                                      *
*& Pantalla de selección del programa ZHHRR_781               *
*& Nota: la selección de empleados y período la provee la     *
*& base de datos lógica PNP (pantalla estándar HR).           *
*&============================================================*
*& Símbolos de texto y textos de selección: se cargan vía     *
*& abapGit desde zhhrr_781.prog.xml (en ESPAÑOL). Requieren   *
*& traducción a inglés y portugués según estándar LATAM       *
*& (secc. 8 y 13) antes del transporte a productivo:          *
*&   TEXT-001 = Parámetros de proceso                         *
*&   TEXT-002 = Identificación de marca duplicada (FEHLER)    *
*&   P_TEST  = Modo simulación (no actualiza TEVEN)           *
*&   P_ELIML = Eliminado lógico (anula con STOKZ)             *
*&   P_ELIMF = Eliminado definitivo (borrado físico)          *
*&   S_ERRTY = Tipo de clase de notificación                  *
*&   S_ERROR = Número de la clase de notificación             *
*&============================================================*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001. " Parámetros de proceso

" Modo simulación: no actualiza TEVEN ni graba log definitivo
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.

" Tipo de eliminación de la marca duplicada de Portal:
"   - Lógico:     anula el evento (STOKZ = 'X'); el registro se conserva
"   - Definitivo: borra físicamente el registro de TEVEN
PARAMETERS: p_eliml RADIOBUTTON GROUP gr1 DEFAULT 'X',  " Eliminado lógico
            p_elimf RADIOBUTTON GROUP gr1.              " Eliminado definitivo

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002. " Identificación en FEHLER

" TODO [SDD 8]: confirmar valores definitivos del mensaje de
" "marca duplicada" en la tabla FEHLER del cluster B2.
" Se admiten múltiples clases/números de mensaje (SELECT-OPTIONS)
SELECT-OPTIONS: s_errty FOR g_errty OBLIGATORY,   " Tipo de clase de notificación
                s_error FOR g_error OBLIGATORY.   " Número de la clase de notificación

SELECTION-SCREEN END OF BLOCK b02.
