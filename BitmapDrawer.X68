*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    
PEN_COLOR_TRAP_CODE                     EQU     80
DRAW_PIXEL_TRAP_CODE                    EQU     82
SET_OUTPUT_RESOLUTION_TRAP_CODE         EQU     33

BITMAP_HEADER_FIELD                     EQU     16973
BITMAP_WIDTH_OFFSET                     EQU     18
BITMAP_HEIGHT_OFFSET                    EQU     22
BITMAP_PIXEL_ARRAY_OFFSET               EQU     10
BITMAP_COLOR_ARRAY_OFFSET               EQU     54
BITMAP_NUM_OF_COLOR_IN_PALETTE          EQU     46

STACK_ARGUMENT_ONE                      EQU     4
STACK_ARGUMENT_TWO                      EQU     8
STACK_ARGUMENT_THREE                    EQU     12
STACK_ARGUMENT_FOUR                     EQU     16
STACK_ARGUMENT_FIVE                     EQU     20
STACK_ARGUMENT_SIX                      EQU     24
STACK_ARGUMENT_SEVEN                    EQU     28

LONG_LENGTH_IN_BYTES                    EQU     4

OUTPUT_WIDTH                            EQU     640
OUTPUT_HEIGHT                           EQU     480
   
;START    ORG    $1000
        
TurnAddressToBigEndian: ; address in d7, returns address in d7
        rol.w       #8, d7
        swap        d7
        rol.w       #8, d7 
        rts

DrawBitmap ;Arguemnts bitmap address, x,y,width,height (of bitmap) and x,y (where to draw)
   
        move.l      STACK_ARGUMENT_SEVEN(sp),a1     ; check if valid bitmap
        
        ;get address (in memeory of pixel array) and put it into a2
        move.l      a1,a2
        add.l       #BITMAP_PIXEL_ARRAY_OFFSET,a2
        move.l      (a2),d7
        jsr         TurnAddressToBigEndian
        move.l      d7,a2
        add.l       a1,a2
        
        ;might need to change to long but if only 256 colors then byte will work
        ;go to non palette version if there is 0 colors in the palette
        move.b      BITMAP_NUM_OF_COLOR_IN_PALETTE(a1),d0
        beq         DrawNonPalette   
        
DrawPalette:
        ;store the location of the color array to later offset
        move.l      a1,a3
        add.l       #BITMAP_COLOR_ARRAY_OFFSET,a3

        move.l      STACK_ARGUMENT_ONE(sp),d2
        add.l       STACK_ARGUMENT_THREE(sp),d2
        sub.l       #1,d2
        
        move.l      STACK_ARGUMENT_TWO(sp),d3
     
        move.l      STACK_ARGUMENT_THREE(sp),d4
        add.l       #1,d4
        
        move.l      STACK_ARGUMENT_FOUR(sp),d5

        move.l      BITMAP_WIDTH_OFFSET(a1),d7      ;store the offset between rows
        jsr         TurnAddressToBigEndian
        move.l      d7,d6
        and.l       #3,d6                           ;padding
        mulu        #3,d6
        and.l       #3,d6                           ;padding
        add.l       d6,d7
        move.l      d7,a5
        sub.l       STACK_ARGUMENT_FOUR(sp),d7 
        move.l      d7,a6
        
        move.l      a2,a0
        move.l      BITMAP_HEIGHT_OFFSET(a1),d7
        jsr         TurnAddressToBigEndian
        sub.l       STACK_ARGUMENT_THREE(sp),d7
        sub.l       STACK_ARGUMENT_FIVE(sp),d7
        move.l      a5,d6
        mulu        d7,d6
        add.l       STACK_ARGUMENT_SIX(sp),d6
        add.l       d6,a0
        
        move.l      d5,d7
        and.l       #1,d7

PaletteEvenOrOdd: 
        move        d7,d7
        beq         DrawPaletteLoop
DrawOnePointPalette:
        move.l      a3,a4
        clr.w       d6
        add.b       (a0)+,d6
        lsl.w       #2,d6
        add.l       d6,a4
        move.l      (a4),d1                     ;get color value into d1 to set pen color
        lsr.l       #8,d1
        
        ;Set pen color
        move.l      #PEN_COLOR_TRAP_CODE,d0
        trap        #15
        
        ;Color at this point
        move.l      d3,d1
        move.l      #DRAW_PIXEL_TRAP_CODE,d0
        trap        #15
        
        addi.l      #1,d3
        addi.l      #-1,d5
        beq         FinishInnerLoopPalette

DrawPaletteLoop: 
        
        move.l      a3,a4
        move.l      a3,a5
        moveq.l     #0,d6
        add.b       (a0)+,d6
        swap        d6
        add.b       (a0)+,d6
        lsl.l       #2,d6
        add.w       d6,a4
        swap        d6
        add.w       d6,a5
        move.l      (a5),d1                     ;get color value into d1 to set pen color
        lsr.l       #8,d1
        
        ;Set pen color
        move.l      #PEN_COLOR_TRAP_CODE,d0
        trap        #15
        
        ;Color at this point
        move.l      d3,d1
        move.l      #DRAW_PIXEL_TRAP_CODE,d0
        trap        #15
        
        addq.l      #1,d3       
        move.l      (a4),d1                     ;get color value into d1 to set pen color
        lsr.l       #8,d1
        
        ;Set pen color
        move.l      #PEN_COLOR_TRAP_CODE,d0
        trap        #15
        
        ;Color at this point
        move.l      d3,d1
        move.l      #DRAW_PIXEL_TRAP_CODE,d0
        trap        #15
        
        addi.l      #1,d3
        addi.l      #-2,d5
        bne         DrawPaletteLoop
FinishInnerLoopPalette:
        move.l      STACK_ARGUMENT_TWO(sp),d3
        move.l      STACK_ARGUMENT_FOUR(sp),d5
        add.l       a6,a0
        addi.l      #-1,d2
        addi.l      #-1,d4
        bne         PaletteEvenOrOdd
       
        rts   
     
        
DrawNonPalette:
        
        move.l      STACK_ARGUMENT_ONE(sp),d2
        add.l       STACK_ARGUMENT_THREE(sp),d2
        sub.l       #1,d2
        
        move.l      STACK_ARGUMENT_TWO(sp),d3
        move.l      d3,a3
     
        move.l      STACK_ARGUMENT_THREE(sp),d4
        add.l       #1,d4
        
        move.l      STACK_ARGUMENT_FOUR(sp),d5
        move.l      d5,a4

        move.l      BITMAP_WIDTH_OFFSET(a1),d7      ;store the offset between rows
        jsr         TurnAddressToBigEndian
        move.l      d7,d6
        add.l       d6,d7
        add.l       d6,d7
        and.l       #3,d6
        add.l       d6,d7
        move.l      d7,a5
        sub.l       STACK_ARGUMENT_FOUR(sp),d7  
        sub.l       STACK_ARGUMENT_FOUR(sp),d7
        sub.l       STACK_ARGUMENT_FOUR(sp),d7  
        move.l      d7,a6
        
        move.l      a2,a0
        move.l      BITMAP_HEIGHT_OFFSET(a1),d7
        jsr         TurnAddressToBigEndian
        sub.l       STACK_ARGUMENT_THREE(sp),d7
        sub.l       STACK_ARGUMENT_FIVE(sp),d7
        move.l      a5,d6
        mulu        d7,d6
        add.l       STACK_ARGUMENT_SIX(sp),d6
        add.l       STACK_ARGUMENT_SIX(sp),d6
        add.l       STACK_ARGUMENT_SIX(sp),d6
        add.l       d6,a0
        
        move.l      a0,d6
        and.l       #1,d6
        move.b      d6,d7

DrawNonPaletteLoop:

        move.b      d6,d6
        bne         DrawNonPaletteOdd
        
DrawNonPaletteEven:
        move.l      (a0),d1
        lsr.l       #8,d1
        add.l       #3,a0      
        moveq.l     #1,d6
        jmp         DrawNonPaletteDrawer
        
DrawNonPaletteOdd:
        clr.w       d1
        move.b      (a0)+,d1
        swap        d1
        move.w      (a0)+,d1
        moveq.l     #0,d6
        
DrawNonPaletteDrawer:
        ;Set pen color
        move.l      #PEN_COLOR_TRAP_CODE,d0
        trap        #15
        
        ;draw pixel
        move.l      d3,d1
        move.l      #DRAW_PIXEL_TRAP_CODE,d0
        trap        #15

        addi.l      #1,d3
        addi.l      #-1,d5
        bne         DrawNonPaletteLoop       
        move.l      a3,d3
        move.l      a4,d5
        add.l       a6,a0
        move.b      d7,d6
        addi.l      #-1,d2
        addi.l      #-1,d4
        bne         DrawNonPaletteLoop
        
        rts
             
;Bitmap      INCBIN "ancient-city-in-the-desert-background-bmp-color-table.bmp"
Platform    INCBIN "FinalPlatform.bmp"
Dropper     INCBIN "Dropper.bmp"
Bitmap      INCBIN "FinalBackground.bmp"
YouLose     INCBIN "YouLost.bmp"
YouWin      INCBIN "YouWon.bmp"
















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
