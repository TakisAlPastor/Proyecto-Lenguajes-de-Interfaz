; =================================================================
; DATOS MODULO SAID (Alertas, Reportes, Termometro, Printer, Kit)
; Incluido dentro de .DATA en main.asm
; =================================================================

    txtAleBase       DB '=== BITACORA DE ALERTAS ===', 0DH, 0AH ; 29 bytes
    txtRepBase       DB '=== REPORTES DE INCIDENCIAS ===', 0DH, 0AH ; 33 bytes

    prefijoRepFol    DB 'FOL:' ; 4 bytes
    prefijoRepZon    DB ' | ZON:' ; 7 bytes
    sepRepDesc       DB ' | ' ; 3 bytes
    saltoLineaM2     DB 0DH, 0AH

    prefijoAleTemp   DB 'ALERTA TERMICA: Temp = ' ; 23 bytes
    sufijoAleTemp    DB ' C (>40C)', 0DH, 0AH ; 11 bytes
    txtAleEmergSw    DB 'ALERTA EMERGENCIA: Switch Bit 7 activado!', 0DH, 0AH ; 43 bytes

    entradaFolio     DB  7, 0,  8 DUP(' ')
    entradaZona      DB 11, 0, 12 DUP(' ')
    entradaDesc      DB 25, 0, 26 DUP(' ')

    valorLedDisplay  DW 0
    tempAscii        DB '000'
    tempCentenas     DB '0'
    esperaM2         DW 0
    tipoPatronMatriz DB 1       ; 1 = OK, 0 = Error/Alerta
    indiceMatriz     DB 0       ; 0..4 (llena Dot Matrix de 1 en 1)
    idMsgLcd         DB 1       ; 1=Denegado, 2=Emergencia, 4=Prueba

    barraFolioM2     DB  8 DUP(177)
    barraZonaM2      DB 12 DUP(177)
    barraDescM2      DB 26 DUP(177)

    ; Tabla 7 segmentos (dp-g-f-e-d-c-b-a) para digitos '0'..'9'
    tabla7Seg        DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH

    ; Buffer corto de 16 bytes para ASCII LCD (2040h..204Fh)
    bufferLcd        DB 16 DUP(' ')
    txtLcdAcceso     DB 'USR:            ' ; 16
    txtLcdTempOk     DB 'TEMP: 000 C OK  ' ; 16
    txtLcdTempAl     DB 'TEMP: 000 C AL! ' ; 16
    txtLcdDenegado   DB 'ACCESO DENEGADO ' ; 16
    txtLcdEmergencia DB 'EMERGENCIA SW7  ' ; 16
    txtLcdPrueba     DB 'LCD OK          ' ; 16

    ; Patron de 8 bytes por cada matriz (Bit 0 = arriba, Bit 7 = abajo)
    patronMatrizOK   DB 00H, 20H, 40H, 20H, 10H, 08H, 04H, 02H
    patronMatrizErr  DB 81H, 42H, 24H, 18H, 18H, 24H, 42H, 81H

    ; --- Textos Submenu Said (48 chars c/u) ---
    titMod2M2        DB '  SAID: ALERTAS, REPORTES Y MONITOREO           '
    opMod2_1         DB '[1] Capturar Reporte / Incidencia (REPORTES.TXT)'
    opMod2_2         DB '[2] Ver Bitacora de Alertas (ALERTAS.TXT)       '
    opMod2_3         DB '[3] Ver Reportes Guardados (REPORTES.TXT)       '
    opMod2_4         DB '[4] Escanear Termometro (Thermometer 125/127)   '
    opMod2_5         DB '[5] Imprimir Reportes en Printer (Puerto 130)   '
    opMod2_6         DB '[6] Probar Salidas Kit y LED_Display            '
    opMod2_7         DB '[7] Volver al Menu Principal                    '
    msjEligeOp7M2    DB 'Seleccione una opcion [1-7]:                    '

    ; --- Textos Formulario Reportes (48 chars c/u) ---
    titRepM2         DB '  CAPTURA DE REPORTES - MULTIPLE                '
    etqFolioM2       DB 'Folio (max 6):      ' ; 20 chars
    etqZonaM2        DB 'Zona  (max 10):     ' ; 20 chars
    etqDescM2        DB 'Detalle (max 24):   ' ; 20 chars
    msjRepOkM2       DB 'Reporte guardado en REPORTES.TXT                '
    msjRepInvM2      DB 'Todos los campos son obligatorios.              '
    msjOtroRepM2     DB 'Desea capturar otro reporte? [S/N]:             '

    ; --- Textos Visores (48 chars c/u) ---
    titVisorAleM2    DB '  VISOR DE ALERTAS - ALERTAS.TXT                '
    titVisorRepM2    DB '  VISOR DE REPORTES - REPORTES.TXT              '

    ; --- Textos Termometro, Printer y Kit (48 chars c/u) ---
    titTermoM2       DB '  SENSOR TERMICO - THERMOMETER (125 / 127)      '
    msjDevTermOnM2   DB 'Activando: Thermometer(127) ON -> Presiona...   '
    msjTermoOnM2     DB 'Sensor encendido. Presiona tecla para leer(125).'
    msjTermoLecM2    DB 'Temperatura registrada (C):                     '
    msjDevTermOkM2   DB 'Activando: LED_D(199), LCD, Traffic(V), Mat(OK).'
    msjDevTermAlM2   DB 'Activando: LED_D(199), Stepper(Abr), Traffic(R).'
    msjTermoOkM2     DB 'Temperatura segura (<= 40 C). Sistema normal.   '
    msjTermoBajoM2   DB 'Temperatura bajo cero detectada. Sistema seguro.'
    msjTermoAleM2    DB 'PELIGRO (> 40 C)! Alerta y salida liberada!     '

    msjDevPrintM2    DB 'Activando: Printer(130) -> REPORTES.TXT...      '
    msjPrintOkM2     DB 'Reportes enviados a Printer (130). Presiona...  '

    titKitM2         DB '  SALIDAS EMULATION KIT Y LED_DISPLAY           '
    opKit1M2         DB '[1] Enviar mensaje a ASCII LCD (2040h..206Fh)   '
    opKit2M2         DB '[2] Mostrar intentos en Seven Segment (2030h)   '
    opKit3M2         DB '[3] Patron OK / Alerta en Dot Matrix (2000h..27)'
    opKit4M2         DB '[4] Mostrar Temperatura en LED_Display (199)    '
    opKit5M2         DB '[5] Regresar                                    '
    msjDevLcdM2      DB 'Activando: ASCII LCD (2040h..206Fh)...          '
    msjDev7SegM2     DB 'Activando: Seven Segment (2030h) = Intentos...  '
    msjDevMatOkM2    DB 'Activando: Dot Matrix (2000h..2027h) = OK...    '
    msjDevMatErrM2   DB 'Activando: Dot Matrix (2000h..2027h) = ERROR... '
    msjDevLedDM2     DB 'Activando: LED_Display (199) = Temp actual...   '
    msjKitOkM2       DB 'Accion completada en device. Presiona tecla...  '
