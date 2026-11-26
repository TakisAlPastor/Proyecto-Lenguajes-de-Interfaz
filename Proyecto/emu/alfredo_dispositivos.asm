; =================================================================
; ALFREDO - DISPOSITIVOS (Stepper, Traffic_Lights, LEDs, Switches)
; Responsable: Jose Alfredo Camarena Martinez
; =================================================================

PANEL_DISPOSITIVOS_ALFREDO PROC
CICLO_HW_M1:
    CALL CLEAN_SCREEN
    SCROLL_ARRIBA 0,  2, 14,  4, 65, 30H
    SCROLL_ARRIBA 0,  6, 14, 17, 65, 70H
    SCROLL_ARRIBA 0, 19, 14, 21, 65, 0EH

    IMPCAD_COLOR titHwM1,    48,  3, 16, 0, 0, 30H
    IMPCAD_COLOR opHw1M1,    48,  7, 16, 0, 0, 70H
    IMPCAD_COLOR opHw2M1,    48,  8, 16, 0, 0, 70H
    IMPCAD_COLOR opHw3M1,    48,  9, 16, 0, 0, 70H
    IMPCAD_COLOR opHw4M1,    48, 10, 16, 0, 0, 70H
    IMPCAD_COLOR opHw5M1,    48, 11, 16, 0, 0, 74H
    IMPCAD_COLOR msjEligeOp, 48, 15, 16, 0, 0, 71H

    CURSOR 15, 45, 0
    RASTREO

    CMP AL, '1'
    JE PRUEBA_STEPPER_M1
    CMP AL, '2'
    JE PRUEBA_TRAFFIC_M1
    CMP AL, '3'
    JE PRUEBA_LEDS_M1
    CMP AL, '4'
    JE PRUEBA_SWITCHES_M1
    CMP AL, '5'
    JE FIN_HW_M1
    JMP CICLO_HW_M1

PRUEBA_STEPPER_M1:
    IMPCAD_COLOR msjHwStepAbrM1, 48, 19, 16, 0, 0, 1FH
    CALL TECLA
    CALL ABRIR_CERRADURA_STEPPER

    IMPCAD_COLOR msjHwStepCerM1, 48, 19, 16, 0, 0, 1FH
    CALL TECLA
    CALL CERRAR_CERRADURA_STEPPER
    JMP CICLO_HW_M1

PRUEBA_TRAFFIC_M1:
    MOV AX, 0249H               ; Rojo
    OUT 4, AX
    IMPCAD_COLOR msjHwTrafM1, 48, 19, 16, 0, 0, 4FH
    CALL TECLA

    MOV AX, 0492H               ; Amarillo
    OUT 4, AX
    IMPCAD_COLOR msjHwTrafAmM1, 48, 19, 16, 0, 0, 60H
    CALL TECLA

    MOV AX, 0924H               ; Verde
    OUT 4, AX
    IMPCAD_COLOR msjHwTrafVeM1, 48, 19, 16, 0, 0, 2FH
    CALL TECLA
    JMP CICLO_HW_M1

PRUEBA_LEDS_M1:
    MOV DX, 2070H
    MOV AL, 00000001B           ; Bit 0: Sistema
    OUT DX, AL
    IMPCAD_COLOR msjHwLedM1, 48, 19, 16, 0, 0, 1FH
    CALL TECLA

    MOV AL, 00000011B           ; Bit 0 + Bit 1: Puerta abierta
    OUT DX, AL
    IMPCAD_COLOR msjHwLed2M1, 48, 19, 16, 0, 0, 1FH
    CALL TECLA

    MOV AL, 00010011B           ; + Bit 4: Alerta termica
    OUT DX, AL
    IMPCAD_COLOR msjHwLed3M1, 48, 19, 16, 0, 0, 4FH
    CALL TECLA

    MOV AL, 00100001B           ; Bit 0 + Bit 5: Bloqueo
    OUT DX, AL
    IMPCAD_COLOR msjHwLed4M1, 48, 19, 16, 0, 0, 4FH
    CALL TECLA

    MOV AL, 00000011B           ; Restaurar sistema + puerta
    OUT DX, AL
    JMP CICLO_HW_M1

PRUEBA_SWITCHES_M1:
    IMPCAD_COLOR msjHwSwM1, 48, 19, 16, 0, 0, 1FH
    CALL TECLA

    MOV DX, 2084H
    IN AL, DX
    MOV byteSwitches, AL

    ; Imprimir los 8 bits (b7..b0) en pantalla
    MOV tempByte, AL
    MOV colVisor, 16
    MOV SI, 0
    MOV CX, 8

CICLO_BITS_SW_M1:
    CURSOR 20, colVisor, 0
    MOV AL, tempByte
    CMP AL, potenciaBit[SI]
    JB BIT_CERO_SW_M1
    SUB AL, potenciaBit[SI]
    MOV tempByte, AL
    IMP_CARACTER '1'
    JMP SIG_BIT_SW_M1

BIT_CERO_SW_M1:
    IMP_CARACTER '0'

SIG_BIT_SW_M1:
    INC SI
    INC colVisor
    LOOP CICLO_BITS_SW_M1

    ; Bit 7 (Switches >= 128) = Boton de Emergencia / Bloqueo
    CMP byteSwitches, 128
    JB SW_SIN_EMERG_M1

    IMPCAD_COLOR msjHwEmergM1, 48, 19, 16, 0, 0, 4FH
    CALL TECLA
    CALL REGISTRAR_ALERTA_EMERGENCIA
    MOV AX, 0249H               ; Traffic_Lights Rojo
    OUT 4, AX
    MOV DX, 2070H
    MOV AL, 00100001B           ; Bit 0 + Bit 5 (Bloqueo emergencia)
    OUT DX, AL
    CALL MOSTRAR_DOT_MATRIX_ERROR
    MOV idMsgLcd, 2             ; ASCII LCD: Bloqueo emergencia
    CALL MOSTRAR_LCD_ESTADO
    CALL CERRAR_CERRADURA_STEPPER
    CALL TECLA
    JMP CICLO_HW_M1

SW_SIN_EMERG_M1:
    IMPCAD_COLOR msjHwSwOkM1, 48, 19, 16, 0, 0, 2FH
    CALL TECLA
    JMP CICLO_HW_M1

FIN_HW_M1:
    RET
PANEL_DISPOSITIVOS_ALFREDO ENDP

; Gira cerradura en sentido horario (ABRIR puerta)
ABRIR_CERRADURA_STEPPER PROC
    MOV CX, 4
GIRO_CW_M1:
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000001B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000011B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000010B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000110B
    OUT 7, AL
    LOOP GIRO_CW_M1
    RET
ABRIR_CERRADURA_STEPPER ENDP

; Gira cerradura en sentido antihorario (CERRAR seguro)
CERRAR_CERRADURA_STEPPER PROC
    MOV CX, 4
GIRO_CCW_M1:
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000110B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000010B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000011B
    OUT 7, AL
    CALL ESPERAR_STEPPER_M1
    MOV AL, 00000001B
    OUT 7, AL
    LOOP GIRO_CCW_M1
    RET
CERRAR_CERRADURA_STEPPER ENDP

ESPERAR_STEPPER_M1 PROC
    MOV esperaM1, 1000
CICLO_ESP_STP_M1:
    IN AL, 7
    CMP AL, 128
    JAE LISTO_STP_M1
    DEC esperaM1
    JNZ CICLO_ESP_STP_M1
LISTO_STP_M1:
    RET
ESPERAR_STEPPER_M1 ENDP
