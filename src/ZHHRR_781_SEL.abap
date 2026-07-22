*&============================================================*
*& Include ZHHRR_781_SEL                                      *
*& Pantalla de selección del programa ZHHRR_781               *
*& Nota: la selección de empleados y período la provee la     *
*& base de datos lógica PNP (pantalla estándar HR).           *
*&============================================================*
*& Símbolos de texto a definir en SE38 (Pasar a -> Símbolos   *
*& de texto) en ESPAÑOL, con traducción a inglés y portugués  *
*& según estándar LATAM (secc. 8 y 13):                       *
*&   TEXT-001 = Parámetros de proceso                         *
*&   TEXT-002 = Identificación de marca duplicada (FEHLER)    *
*& Textos de selección (Pasar a -> Textos de selección):      *
*&   P_TEST  = Modo simulación (no actualiza TEVEN)           *
*&   P_VENTA = Ventana de proximidad (horas)                  *
*&   P_ERRTY = Tipo de clase de notificación                  *
*&   P_ERROR = Número de la clase de notificación             *
*&============================================================*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-001. " Parámetros de proceso

" Modo simulación: no actualiza TEVEN ni graba log definitivo
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.

" Ventana de proximidad (en horas) respecto a la entrada/salida
" del horario vigente para clasificar la marca (SDD 4.3)
PARAMETERS: p_venta TYPE i DEFAULT 2.

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-002. " Identificación en FEHLER

" TODO [SDD 8]: confirmar valores definitivos del mensaje de
" "marca duplicada" en la tabla FEHLER del cluster B2
PARAMETERS: p_errty TYPE errty OBLIGATORY,   " Tipo de clase de notificación
            p_error TYPE error OBLIGATORY.   " Número de la clase de notificación

SELECTION-SCREEN END OF BLOCK b02.
