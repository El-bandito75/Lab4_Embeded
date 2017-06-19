;*******************************************************************
; main.s
; Author: Michael Revilla & David Broker 
; Date Created: 11/18/2016
; Last Modified: 06/19/2017
; Section Number: 045
; Instructor: Serpen
; Lab number: 4
;   Brief description of the program
; The overall objective of this system is an interactive alarm
; Hardware connections
;   PF4 is switch input  (1 = switch not pressed, 0 = switch pressed)
;   PF3 is LED output    (1 activates green LED)
; The specific operation of this system
;   1) Make PF3 an output and make PF4 an input (enable PUR for PF4).
;   2) The system starts with the LED OFF (make PF3 =0).
;   3) Delay for about 100 ms
;   4) If the switch is pressed (PF4 is 0),
;      then toggle the LED once, else turn the LED OFF.
;   5) Repeat steps 3 and 4 over and over
;*******************************************************************
GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_LOCK_R       EQU   0x40025520
GPIO_PORTF_CR_R         EQU   0x40025524
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608 
PF4                     EQU   0x40025040
PF3                     EQU   0x40025020
 
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
           
Start
   
    BL PortF_Init; //go to PortF_Init
    ;BL Delay;
    BL LED_OutputOFF; // turn led off
    
    
loop   ;// dead loop
    BL SwitchSat_Input; //get input
    CMP r4, #0x00; // if r4(input) =0x00(on)
    BLEQ LED_OutputON; //if is on go to turn on
    BL Delay;
    BL LED_OutputOFF;// if it isnt go to off
    BL Delay;
     
    
Delay PROC ; delay function
    ldr r0, =0x30D40;
nick
    SUB r0, r0, #1;
    STR r0, [r0];
    CMP r0, #0;
    BNE nick;
    BX LR ;
    ENDP
 
 
LED_OutputON ;//set led on
    LDR r3, =PF3    ;GPIO_PORTF_DATA_R;    
    ;LDR r0, [r3];
    MOV r0, #0x08;
    STR r0, [r3];
    
    BX LR 
    ;BX LR;reutrn
 
LED_OutputOFF ;//set led off
    LDR r2, =PF3;
    MOV r0, #0x00;
    STR r0, [r2];
    ;
    BX LR;
    ;BX LR;
 
SwitchSat_Input ;//get input of switch, negative logic
    LDR r0, =GPIO_PORTF_DATA_R;
    LDR r4, [r0];
    AND r4,r4,#0x10;
    
    BX LR;
 
PortF_Init ;// initialize port F
    LDR r1, =SYSCTL_RCGCGPIO_R; // this sets clock port f
    LDR r0, [r1];
    ORR r0, r0,#0x20;
    STR r0, [r1];
    NOP; // delay for clock to start
    NOP;
    
        
    LDR r1, =GPIO_PORTF_AMSEL_R; // turn off analog
    LDR r0, [r1];
    BIC r0, #0x18;
    STR r0, [r1];    
    
    LDR r1, =GPIO_PORTF_PCTL_R; // set PCTL
    LDR r0, [r1];
    BIC r0, #0x18;
    STR r0, [r1];
    
    LDR r1, =GPIO_PORTF_DIR_R; //set the directions
    LDR r0, [r1];
    BIC r0, #0x10; //set PF4 to input
    ORR r0, #0x08; //set PF3 to output
    STR r0,[r1];
    
    LDR r1, =GPIO_PORTF_AFSEL_R; //turn of alt function
    LDR r0, [r1];
    BIC r0, #0x18;
    STR r0,[r1];
    
    LDR r1, =GPIO_PORTF_PUR_R; //enable pull up for PF4
    LDR r0, [r1];
    ORR r0, #0x10; // set PF4 to one
    BIC r0, #0x08; // set PF3 to zero
    STR r0, [r1];
 
    LDR r1, =GPIO_PORTF_DEN_R; //turns on Digtial I/O
    LDR r0, [r1];
    ORR r0, #0x18;
    STR r0, [r1];
        
    BX LR; 
    
 
 
       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file

       