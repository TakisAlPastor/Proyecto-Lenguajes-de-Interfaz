; =================================================================
; DATOS MODULO ALFREDO (Login, Usuarios, Accesos y Dispositivos)
; Incluido dentro de .DATA en main.asm
; =================================================================

    txtUsuariosBase  DB 'alfredo:1234:05', 0DH, 0AH
                     DB 'said:5678:10', 0DH, 0AH ; 31 bytes
    txtEncabezadoAcc DB '=== BITACORA DE ACCESOS ===', 0DH, 0AH ; 29 bytes

    prefijoAccUsr    DB 'USR: ' ; 5 bytes
    prefijoAccMetC   DB ' [CLAVE]  -> ' ; 13 bytes
    prefijoAccMetH   DB ' [HUELLA] -> ' ; 13 bytes
    msjLogOk         DB 'CONCEDIDO', 0DH, 0AH ; 11 bytes
    msjLogFail       DB 'DENEGADO', 0DH, 0AH  ; 10 bytes

    entradaUsuario   DB 13, 0, 14 DUP(' ')
    entradaClave     DB 13, 0, 14 DUP(' ')
    entradaHuella    DB  3, 0,  4 DUP(' ')

    estadoAcceso     DB 0
    metodoAcceso     DB 'C'      ; 'C' = Clave, 'H' = Huella
    huellaLeida      DB 0
    huellaAscii      DB '00'
    digitoM1         DB '0'
    inicioLineaM1    DW 0
    longTempM1       DW 0
    esperaM1         DW 0
    byteSwitches     DB 0
    potenciaBit      DB 128, 64, 32, 16, 8, 4, 2, 1

    sepDosPuntos     DB ':'
    saltoLineaM1     DB 0DH, 0AH
    barraCampoM1     DB 14 DUP(177)
    barraChicaM1     DB  4 DUP(177)

    ; --- Textos Login (48 chars c/u) ---
    titLoginM1       DB '  MARCAHUELLA - ACCESO DE PERSONAL              '
    subLoginM1       DB 'Seleccione metodo de autenticacion:             '
    opLogin1M1       DB '[1] Ingresar con Usuario y Contrasena           '
    opLogin2M1       DB '[2] Ingresar con Huella Digital                 '
    opLogin3M1       DB '[3] Salir del Sistema                           '
    msjIntentosM1    DB 'Intentos restantes:                             '
    etqUsuarioM1     DB 'Usuario (max 12):   ' ; 20
    etqClaveM1       DB 'Contrasena (max 12):' ; 20
    etqHuellaM1      DB 'Huella (01..99):    ' ; 20
    msjPonHuellaM1   DB 'Ajusta Switches (2084h) [01..99] y presiona...  '
    msjHuellaCodM1   DB 'Codigo detectado en sensor:                     '
    msjLoginOkM1     DB 'Acceso concedido. Presiona una tecla...         '
    msjLoginErrM1    DB 'Credenciales/Huella invalidas. Presiona tecla...'
    msjLoginBloqM1   DB 'Acceso bloqueado (3 fallos). Cerrando sistema.. '

    ; --- Avisos previos de activacion de devices en Login (48 chars c/u) ---
    msjDevEsperaM1   DB 'Activando: Traffic(Amarillo), 7Seg(Int), LED(B0)'
    msjDevHuellaM1   DB 'Activando: Switches(2084h) -> LEDs(2070h)...    '
    msjDevExitoM1    DB 'Activando: Traffic(Verde), Stepper(Abrir), Kit..'
    msjDevFalloM1    DB 'Activando: Traffic(Rojo), LED(B5), 7Seg, Mat(X).'
    msjDevBloqM1     DB 'Activando: Stepper(Cerrar seguro)...            '

    ; --- Textos Submenu Alfredo (48 chars c/u) ---
    titMod1M1        DB '         ACCESO, USUARIOS Y SEGURIDAD           '
    opMod1_1         DB '[1] Registrar Nuevo Usuario                     '
    opMod1_2         DB '[2] Ver Bitacora de Accesos                     '
    opMod1_3         DB '[3] Ver Usuarios Registrados                    '
    opMod1_4         DB '[4] Dispositivos de Seguridad y Puerta          '
    opMod1_5         DB '[5] Volver al Menu Principal                    '

    ; --- Textos Formulario Alta Usuario (48 chars c/u) ---
    titAltaM1        DB '                ALTA DE USUARIOS                '
    msjAltaOkM1      DB 'Usuario guardado en USUARIOS.TXT                '
    msjAltaErrM1     DB 'Datos invalidos (huella debe ser 01..99).       '
    msjOtroUsrM1     DB 'Desea registrar otro usuario? [S/N]:            '

    ; --- Textos Visores (48 chars c/u) ---
    titVisorAccM1    DB '  VISOR DE BITACORA                             '
    titVisorUsrM1    DB '  VISOR DE USUARIOS                             '

    ; --- Textos Panel Dispositivos Alfredo (48 chars c/u) ---
    titHwM1          DB '  DISPOSITIVOS DE ACCESO Y SEGURIDAD            '
    opHw1M1          DB '[1] Cerradura Stepper_motor (Abrir / Cerrar)    '
    opHw2M1          DB '[2] Semaforo Traffic_Lights (Puerto 4)          '
    opHw3M1          DB '[3] Tablero LEDs por Subsistema (Puerto 2070h)  '
    opHw4M1          DB '[4] Sensor Switches / Emergencia (Puerto 2084h) '
    opHw5M1          DB '[5] Volver                                      '
    msjHwStepAbrM1   DB 'Activando: Stepper_motor (7) -> ABRIR puerta... '
    msjHwStepCerM1   DB 'Activando: Stepper_motor (7) -> CERRAR seguro...'
    msjHwTrafM1      DB 'Traffic(4): ROJO activo -> tecla para Amarillo..'
    msjHwTrafAmM1    DB 'Traffic(4): AMARILLO -> tecla para Verde...     '
    msjHwTrafVeM1    DB 'Traffic(4): VERDE activo -> tecla para volver...'
    msjHwLedM1       DB 'LEDs(2070h): Bit0=Sistema (tecla para Puerta)...'
    msjHwLed2M1      DB 'LEDs(2070h): Bit0+1=Puerta (tecla para Term)... '
    msjHwLed3M1      DB 'LEDs(2070h): +Bit4=Termica (tecla para Bloq)... '
    msjHwLed4M1      DB 'LEDs(2070h): Bit0+5=Bloqueo (tecla para volver).'
    msjHwSwM1        DB 'Activando: Switches(2084h) -> Leer bits/emerg...'
    msjHwEmergM1     DB 'EMERGENCIA (Bit 7)! Alerta + Bloqueo activado!  '
    msjHwSwOkM1      DB 'Switches normales (Bit 7=0). Sin emergencia.    '
