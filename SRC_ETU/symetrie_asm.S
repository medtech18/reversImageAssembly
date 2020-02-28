                                                                                        
@  Importation des,constantes symboliques WIDTH, HEIGHT, BYTES, BYTES_PER_LINE          
#include "image_bits_include.h" 
                .Data

        WIDTH          : .byte  168
        HEIGHT         : .byte  145
        BYTES          : .hword 3045
        BYTES_PER_LINE : .byte  21 
        msg            : .asciz "VAL [%x] \n"
                                                                                        
                 .global symetrie_octet                                                 
                 .global permuter_cols                                                  
                 .global symetrie_axe_v                                                 
                 .global permuter_ligne                                                 
                 .global symetrie_axe_h                                                 
                 .global symetrie_axe_h                                                 
                 .global permuter_lignes                                                
                 .global symetrie_axe_v                                                 
                                                                                        
                 .text                                                                  
                                                                                        
@ r0 : parametre reçu adresse                                                           
@ r1 : variable locale octet                                                            
                                                                                        
#ifndef C_SYMETRIE_OCTET                                                                
#ifndef SYMTAB                                                                          
                                                                                        
@  Version avec opérations bit à bit                                                    
                                                                                        
symetrie_octet:  

    PUSH    {lr}


    
    ldrb r1,[r0]    @octet = *adresse;  

    @ echange de quartets adjacents

    AND r2,r1,#0xF0     @ (octet & 0xF0)
    LSR r2 , r2 , #4    @ (octet & 0xF0) >> 4 

    AND r3,r1,#0x0F     @ (octet & 0x0F)
    LSL r3 , r3 , #4    @ (octet & 0x0F) <<4

    orr r1, r3, r2      @ octet = (octet & 0xF0) >> 4 | (octet & 0x0F) <<4;


    @echange de doublets adjacents

    AND r2,r1,#0xCC     @ (octet & 0xCC)
    LSR r2 , r2 , #2    @ (octet & 0xCC) >> 2 
    
    AND r3,r1,#0x33     @ (octet & 0x33)
    LSL r3 , r3 , #2    @ (octet & 0x33) <<4
        
    orr r1, r3, r2      @ octet = (octet & 0xCC) >> 4 | (octet & 0x33) <<4;

    @echange de bits adjacents

    AND r2,r1,#0xAA     @ (octet & 0xAA)
    LSR r2 , r2 , #1    @ (octet & 0xAA) >> 2 

    AND r3,r1,#0x55     @ (octet & 0x55)
    LSL r3 , r3 , #1    @ (octet & 0x55) <<4
    
    orr r1, r3, r2      @ octet = (octet & 0xAA) >> 4 | (octet & 0x55) <<4;

    @ *adresse = octet;
    strb r1,[r0]

    POP    {lr}   

    bx lr                                                                 
                                                                                        
#else  // SYMTAB                                                                        
                                                                                        
@ Version tabulée                                                                       
symetrie_octet: 

    PUSH    {lr}

    ldrb r1,[r0]   @ octet = *adresse;
    ldrb  r2,[r0,r1]   @ octet = *(octet + adresse) <==> octet = tabsym_octet[octet];
    strb r2,[r0]   @ *adresse = octet;

    POP    {lr}
    bx lr  

#endif  // SYMTAB      

#endif  // C_SYMETRIE_OCTET    






@ r0 : parametre tab                                                                    
@ r1 : parametre col  

#ifndef C_PERMUTER_COLS                                                                 
                                                                                        
permuter_cols:  

    
    PUSH    {lr}


    ldr r3 , =BYTES_PER_LINE    @ BYTES_PER_LINE 

    SUB r3 , r3 , #1            @ BYTES_PER_LINE -1
    SUB r3 , r3 , r1            @ BYTES_PER_LINE -1 - col


    ldrb r2 , [r0,r3]              @ tmp = tab[BYTES_PER_LINE -1 - col];
    ldrb r4 , [r0,r1]              @ tab [col];


    strb r4 , [r0,r3]              @ tab [BYTES_PER_LINE -1 - col] = tab [col];
    strb r2, [r0,r1]               @ tab[col] = tmp;

    POP    {lr}
    bx lr

#endif // C_PERMUTER_COLS  






                                                                                        
@ r0 : paramètre image                                                                  
                                                                                        
#ifndef C_SYMETRIE_AXE_V 

symetrie_axe_v: 

@r3 : BYTES
@r2: POSITION
@r0: image

    PUSH    {lr}

    ldr r3 , =BYTES @ BYTES
    mov r2 , #0     @ position = 0

loop:
    cmp r2,r3
    beq endLoop

    push {r0-r4}
        ADD r0 ,r0,r2     @ image+position
        bl symetrie_octet @ symetrie_octet(image+position);
    POP {r0-r4}

    ADD r2,r2, #1   @ position++
    b loop
endLoop:
    
@r3 : HEIGHT
@r2 : adresse
@r1 : li
@r0 : image
@r4 : BYTES_PER_LINE
@r5 : BYTES_PER_LINE \2

    ldr r3 , =HEIGHT           @ r3 = HEIGHT
    ldr r4 , =BYTES_PER_LINE   @ r4 = BYTES_PER_LINE
    LSR r5,r4,#1               @ BYTES_PER_LINE/2
    MOV r1,#0                   @ li = 0





symetrie_verticale_loop:


    cmp r1,r3
    beq v_endLoop

    PUSH {r4}
        MUL r4,r1    @ li*BYTES_PER_LINE       
        ADD r2,r0,r4 @ adresse = image+li*BYTES_PER_LINE
    POP {r4}
    
    bl nested_loop 

    ADD r1,r1, #1   @ li++

    b symetrie_verticale_loop


    nested_loop:

    

        PUSH {r0-r5,lr}

            MOV r1 , #0 @ r1 : col = 0
            MOV r0 , r2 @ r0 : r0  = adresse

    v_loop:  
            cmp r1,r5
            beq end_v_loop

            push {r0-r5,lr}
                bl permuter_cols @ permuter_cols (adresse, col);
            POP {r0-r5,lr}

            ADD r1,r1, #1   @ position++

            b v_loop


    end_v_loop:
    
        pop {r0-r5,lr}
        bx lr          @ retun to the first loop [symetrie_verticale_loop]
v_endLoop:

    POP    {lr}
    bx lr
                                                                                        
#endif // C_SYMETRIE_AXE_V     



@ r0 : tab                                                                              
@ r1 : li            
                                                                                        
#ifndef C_PERMUTER_LIGNES  

permuter_lignes:

    PUSH    {r0-r8,lr}


    ldr r3 , =HEIGHT         @ HEIGHT 
    ldr r2 , =BYTES_PER_LINE @ BYTES_PER_LINE 
    SUB r3 , r3 , #1         @ HEIGHT -1
    SUB r3 , r3 , r1         @ HEIGHT -1 - li 


    MUL r6,r3,r2   @ (HEIGHT -1 - li)  * BYTES_PER_LINE
    MUL r5 ,r1,r2   @ li * BYTES_PER_LINE

    ldrb r8 , [r0,r6]   @tab[HEIGHT -1 - li][0];
    ldrb r7,[r0,r5]     @ tmp = tab[li][0];
    
    strb   r8 ,[r0,r5]  @ tab[li][0] = tab[HEIGHT -1 - li][0];
    strb   r7,  [r0,r6] @ tab[HEIGHT -1 - li][0] = tmp;

    
    POP    {r0-r8,lr}
    bx lr

                                                                                        
#endif // C_PERMUTER_LIGNES                                                             
                                                                                        
@ r0 : paramètre image                                                                  
                                                                                        
#ifndef  C_SYMETRIE_AXE_H                                                               
symetrie_axe_h:
PUSH    {r0-r5,lr}

@r3 : HEIGHT
@r1 : li
@r0 : image
@r4 : BYTES_PER_LINE
@r5 : BYTES_PER_LINE \2

    ldr r3 , =HEIGHT           @ r3 = HEIGHT    
    ldr r4 , =BYTES_PER_LINE   @ r4 = BYTES_PER_LINE @ MAX[col]
    LSR r5,r3,#1               @ HEIGHT/2      @ MAX[li]   
    MOV r1,#0                   @ li = 0





symetrie_horizontal_loop:
    cmp r1,r5
    beq h_endLoop


    bl h_nested_loop 

    ADD r1,r1, #1   @ li++

    MOV r2,r1
    b symetrie_horizontal_loop


    h_nested_loop:

        PUSH {r0-r5,lr}

            MOV r1 , #0 @ r1 : col = 0

    h_loop:  
            cmp r1,r4
            beq end_h_loop

            
            push {r0-r5,lr}
                ADD r0,r0,r1    @(image+col)
                MOV r1,r2       @ r1: li
                bl permuter_lignes @ permuter_lignes ((image+col), li);
            POP {r0-r5,lr}

            ADD r1,r1, #1   @ col++

            b h_loop


    end_h_loop:
    
        pop {r0-r5,lr}
        bx lr          @ retun to the first loop [symetrie_horizontal_loop]
h_endLoop:

    POP   {r0-r5,lr}
    bx lr                                                                                      
#endif   // C_SYMETRIE_AXE_H                                                            
