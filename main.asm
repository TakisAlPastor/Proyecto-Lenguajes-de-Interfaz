INCLUDE BIBLIOTECA.TXT

.MODEL SMALL
.STACK
.DATA
    msj     DB 'Mensaje de Prueba'
.CODE
INICIO:
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

MAIN:
    CALL MOSTRAR_MENU    

FIN:
    MOV AX, 4C00H
    INT 21H

INCLUDE ejemplo.asm    
END                