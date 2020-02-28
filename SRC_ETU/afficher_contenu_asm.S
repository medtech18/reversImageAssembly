                                                                        
#include "image_bits_include.h"                                         

                .data
    WIDTH_msg  :  .asciz "\n#define width %d\n"
    HEIGHT_msg :  .asciz "#define height %d\n\n"
    chaine_msg :  .asciz "static unsigned char bits[] = {\n"
    chaine_end_msg: .asciz "};\n"
    return_line: .asciz "\n"
    precision_chaine: .asciz "0x%02x"
    comma_separator : .asciz ", "
    WIDTH      :  .byte  168
    HEIGHT     : .byte  145
    BYTES      : .hword 3045
    LINE_LENGTH : .byte  12 

                .text                                                   
                                                                        
                .balign 4                                               
@  r0 : address
@  r3 : fich_res

#ifndef C_AFFICHER_CONTENU                                              
                .global  afficher_contenu     
afficher:
@ r0 : File pointer
@ r1 : format
@ r2 : enter
                    PUSH {lr}
                    bl fprintf
                    pop {lr}
                    bx lr



afficher_contenu:

PUSH {r0-r6,lr}
                PUSH {r0-r6,lr}
                    MOV r0,r3
                    ldr r1,=WIDTH_msg
                    ldr r2,=WIDTH
                    bl afficher
                pop {r0-r6,lr}


                PUSH {r0-r6,lr}
                    MOV r0,r3
                    ldr r1,=HEIGHT_msg
                    ldr r2,=HEIGHT
                    bl afficher
                pop {r0-r6,lr}


                PUSH {r0-r6,lr}
                    MOV r0,r3
                    ldr r1,=chaine_msg
                    bl afficher
                pop {r0-r6,lr}

            Mov r1 , #0 @ i = 0 
            ldr r4 , =LINE_LENGTH @ position =  LINE_LENGTH
            ldr r5 , =BYTES @ BYTES  


    loop :
        cmp r1, r5
        beq loop_end
        SUB r4,r4,#1

        PUSH {r0-r6,lr}
            ldrb r2,[r0]
            MOV r0,r3
            ldr r1,=precision_chaine
            bl afficher
        pop {r0-r6,lr}


        PUSH {r5}
            sub r5,r5,#1
            cmp r1,r5
        POP {r5}
            bne if_BYTES
            b if_pos

if_BYTES:
                PUSH {r0-r6,lr}
                    MOV r0,r3
                    ldr r1,=comma_separator
                    bl afficher
                pop {r0-r6,lr}
                

if_pos:
            cmp r4 , #0
            bne continue

            PUSH {r0-r6,lr}
                    MOV r0,r3
                    ldr r1,=comma_separator
                    bl afficher
            pop {r0-r6,lr}
            ldr r4 , =LINE_LENGTH




    continue:
        ADD r0 ,r0 , #1 @ adress++
        ADD r1 ,r1 , #1 @ i++
        b loop

    loop_end:

        PUSH {r0-r6,lr}
            MOV r2,r0
            MOV r0,r3
            ldr r1,=chaine_end_msg
            bl afficher
        pop {r0-r6,lr}


pop {r0-r6,lr}
                    
                    bx lr                       
                                
                                                                   
#endif   // C_AFFICHER_CONTENU                                          
