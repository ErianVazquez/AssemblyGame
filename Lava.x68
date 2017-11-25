
LAVA_SIZE_FROM_BOTTOM           EQU 80



DrawLava

        move.l          (BossLavaFillPercent),d6
        ble             DrawLavaDone
                
        move.l	        #$FF00FF,d1        
        move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15
	    move.l          #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15

        lsr.l           #8,d6
        mulu            #LAVA_SIZE_FROM_BOTTOM,d6
        divu            #100,d6
        swap            d6
        clr.w           d6
        swap            d6

        move.l          #480,d7
        sub.l           d6,d7

	    move.b	        #DRAW_RECT_COMMAND,d0
	    move.l          #282,d1
	    move.l          d7,d2
	    move.l          #303,d3
	    move.l          #480,d4
        trap	        #15

        move.l          #354,d1
	    move.l          #375,d3
        trap	        #15
        
        move.l          (BossLavaFillPercent),d7
        cmp.l           #100<<8,d7
        blt             DrawLavaDone
        
        move.l          #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d6
        move.l          (BossLavaFillPercent),d7
        lsr.l           #8,d7
        sub.l           #100,d7
        sub.l           d7,d6
        
        move.b	        #DRAW_RECT_COMMAND,d0
	    move.l          #BLACK_BOX_LEFT_SIDE_OF_SCREEN,d1
	    move.l          d6,d2
	    move.l          #BLACK_BOX_RIGHT_SIDE_OF_SCREEN,d3
	    move.l          #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d4
        trap	        #15
        

DrawLavaDone
        rts
    
EraseLava

        jsr             TurnPercentToYValueInD7
        add.l           #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d7
        move.l          #480,d5
        sub.l           d7,d5
        move.l          d5,d1
        move.l          d6,d7
        jsr             TurnPercentToYValueInD7
        add.l           #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d7
        move.l          #480,d5
        sub.l           d7,d5
        move.l          d5,d3
        
        sub.l           d1,d3
        add.l           #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d1
              
        lea.l           Bitmap, a0
        move.l          #282, d0
        move.l          #303-282, d2
        move.l          #282, d4
        move.l          d1, d5
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap
        
	    move.l          #354,4(sp)
	    
	    jsr             DrawBitmap
	    
	    add.l           #28, sp
	    
DoneErase
        rts
        
TurnPercentToYValueInD7

        lsr.l           #8,d7
        mulu            #LAVA_SIZE_FROM_BOTTOM,d7
        divu            #100,d7
        swap            d7
        clr.w           d7
        swap            d7

        
        rts

        
        
        
        
        
        
        

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
