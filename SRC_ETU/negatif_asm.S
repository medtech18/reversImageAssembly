                                                                                      
@  Importation des,constantes symboliques WIDTH, HEIGHT, BYTES, BYTES_PER_LINE        
#include "image_bits_include.h"                                                       
                                                
        .Data

        WIDTH          : .byte  168
        HEIGHT         : .byte  145
        BYTES          : .hword 3045
        BYTES_PER_LINE : .byte  21  

                                                                                      
        .text                                                                     
                                                                                      
@ r0 : parametre octet                                                                
                                                                                      
#ifndef C_NEG_OCTET                                                                   
                 .global neg_octet                                                    
                                                                                      
neg_octet:   @neg_octet(unsigned char c)
	  PUSH    {lr}
    MVN r3, r0 @ return ~c;
	  POP    {lr}
    bx lr
    
                                                                                      
#endif // C_NEG_OCTET                                                                 

     

     

#ifndef C_NEG_IMAGE                                                               
                 .global neg_image                                                    
@ r0 : parametre reçu image                                                           
                                                                                      
                                                                                      
neg_image: PUSH    {lr}   

            MOV r4, r0      @use r4 for adr = adress

            @ ldr r2, adr_bytes
            ldr r1 , =BYTES      @ r1 : BYTES =  3045
            ADD r2 , r1 , r0    @ r2 = BYTES + adress
            
    loop:   
            cmp r4, r2 @ perform comparison
            beq done @ end loop if adr >= address+BYTES
    
            PUSH {r0} 
            ldrb r0 , [r4]  @ r0 = *adr
            bl neg_octet    @ neg_image (adr)
            POP {r0} 
            strb r3 , [r4]  @ *adr = neg_octet(adr);


            add r4, #1 @ adr++


            b loop @ repeat loop test
    done:

	pop    {lr}
            mov  pc,lr   
                                                                                      
adr_bytes:	.word BYTES                                                           
#endif // C_NEG_IMAGE                                                                 
