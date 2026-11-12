INCLUDE BIBLIOTECA.TXT

.MODEL SMALL
.STACK
.DATA
    msj     DB 'Mensaje de Prueba'

    ; --- Rutas de directorios y los 2 archivos de Carlos ---
    dirRaiz       DB 'C:\BUZON', 0
    dirCarlos     DB 'C:\BUZON\CARLOS', 0
    rutaReportes  DB 'C:\BUZON\CARLOS\REP_01.TXT', 0
    rutaAlertas   DB 'C:\BUZON\CARLOS\ALERTAS.TXT', 0
    ID            DW 0

    ; --- Textos base para inicializar archivos si no existen ---
    txtRepBase    DB 'FOLIO 01: Mejorar iluminacion en sala de lectura.', 0DH, 0AH
                  DB 'FOLIO 02: Agregar mas contactos electricos.', '$'
    txtAleBase    DB 'LOG 01: Sistema de buzon inicializado OK.', 0DH, 0AH, '$'
    txtAleFuego   DB 'ALERTA CRITICA: Temperatura > 40C detectada en buzon!', 0DH, 0AH
    txtAleRobot   DB 'ACCESO FISICO: Robot abrio compartimento de quejas.', 0DH, 0AH

    ; --- Buffer de lectura ---
    bufferLectura DB 250 DUP('$')

    ; --- Textos de la interfaz (FormaAlertas) ---
    titCabecera   DB ' PANEL DE PERSONAL - BUZON BIBLIOTECA ALAMEDA ' ; 46 chars
    op1           DB '[1] Leer Sugerencias Guardadas (REP_01.TXT) '   ; 44 chars
    op2           DB '[2] Leer Bitacora de Alertas (ALERTAS.TXT)  '   ; 44 chars
    op3           DB '[3] Activar Robot (Extraer Sobres del Buzon)'   ; 44 chars
    op4           DB '[4] Escanear Termometro (Sensor Anti-Fuego) '   ; 44 chars
    op5           DB '[5] Salir del Modulo de Personal            '   ; 44 chars
    titVisor      DB ' CONTENIDO DEL ARCHIVO / ESTADO DEL SISTEMA: '  ; 45 chars

    msjRobotOK    DB 'Robot activado: Puerta abierta y sobres recolectados.$'
    msjTempOk     DB 'Temperatura normal (<40 C). Buzon seguro.            $'
    msjTempAlta   DB 'PELIGRO (>40 C)! Alerta guardada en ALERTAS.TXT      $'
    msjErrorArch  DB 'Error al abrir o procesar el archivo en disco.       $'

.CODE
INICIO:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

MAIN:
    CALL MOSTRAR_MENU
    CALL MODULO_PERSONAL

FIN:
    MOV AX, 4C00H
    INT 21H

INCLUDE ejemplo.asm    
END                
