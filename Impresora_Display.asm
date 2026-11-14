MODULO_IMPRESORA PROC
    PUSH AX
    PUSH SI

    LEA SI, mensajeImpresora
    CLD                         ; LODSB avanza hacia el siguiente caracter

ENVIAR_CARACTER:
    LODSB                       ; AL = siguiente caracter
    CMP AL, 0                   ; Cero indica fin del mensaje
    JE FIN_IMPRESORA

    OUT 130, AL                 ; Enviar caracter a la impresora

ESPERAR_IMPRESORA:
    IN AL, 130                  ; Consultar estado de la impresora
    OR AL, AL
    JNZ ESPERAR_IMPRESORA       ; Si no esta lista, seguir esperando

    JMP ENVIAR_CARACTER

FIN_IMPRESORA:
    POP SI
    POP AX

    MOV AH, 09H
    LEA DX, msjImpresora
    INT 21H
    MOV AH, 00H
    INT 16H
    RET
MODULO_IMPRESORA ENDP

MODULO_LED_DISPLAY PROC
    PUSH AX

    MOV AX, numeroDisplay       ; Cargar el numero que se mostrara
    OUT 199, AX                 ; Enviar palabra al LED Display

    POP AX

    MOV AH, 09H
    LEA DX, msjDisplay
    INT 21H
    MOV AH, 00H
    INT 16H
    RET
MODULO_LED_DISPLAY ENDP
