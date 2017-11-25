DROPPER_ONE_X               EQU 142
DROPPER_TWO_X               EQU 258
DROPPER_THREE_X             EQU 374
DROPPER_FOUR_X              EQU 490

DROPPER_Y                   EQU 45
    
DROPPER_WIDTH               EQU 8
DROPPER_HEIGHT              EQU 23

DROP_SIZE                   EQU 10<<8
DROP_SIZE_INCREASE          EQU 1<<5

INIITAL_DROP_SPEED          EQU $180

DROPPER_BOTTOM_OF_SCREEN    EQU 390


UpdateRain

        move.b              (BossRainActive),d0
        beq                 RainUpdateDone
        
        lea                 BossRainArray,a0
        move.l              8(a0),d0
        cmp.l               #DROP_SIZE,d0
        blt                 DoneGrowRain
        jmp                 RainFalling
DoneGrowRain
        
        lea                 BossRainArray,a0
        
        move.l              #DROP_SIZE_INCREASE,d0
        move.l              (DeltaTime),d1
        mulu                d1,d0
        
        add.l               d0,8(a0)
        add.l               d0,26(a0)
        add.l               d0,44(a0)
        add.l               d0,62(a0)

        add.l               d0,12(a0)
        add.l               d0,30(a0)
        add.l               d0,48(a0)
        add.l               d0,66(a0)        
        
        rts
        
RainFalling

        move.l          #0,d6
        lea             BossRainArray,a6
        
UpdateActiveRainLoop
        btst            d6,(BossRainActive)
        bne             UpdateActiveRainFound   
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             RainUpdateDone
        jmp             UpdateActiveRainLoop

UpdateActiveRainFound   
            
        jsr             UpdateSpecificRainAtA6
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             RainUpdateDone
        jmp             UpdateActiveRainLoop
        
UpdateSpecificRainAtA6
    
        move.l          4(a6),d0
        add.l           #INIITAL_DROP_SPEED,d0
        
        cmp.l           #DROPPER_BOTTOM_OF_SCREEN<<8,d0
        bgt             DestroyRain
        
        move.l          d0,4(a6)
        
        rts
DestroyRain

        move.l          #DROPPER_BOTTOM_OF_SCREEN,4(a6)
        bclr            d6,(BossRainActive)
        
        rts

RainUpdateDone
        rts
        
DrawBossRain

        move.l          #0,d6
        lea             BossRainArray,a6
        
DrawActiveRainLoop
        btst            d6,(BossRainActive)
        bne             DrawActiveRainFound
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             AllBossRainDrawn
        jmp             DrawActiveRainLoop

DrawActiveRainFound   
            
        jsr             DrawSpecificRainAtA6
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             AllBossRainDrawn
        jmp             DrawActiveRainLoop
        
AllBossRainDrawn
            
        rts
        
DrawSpecificRainAtA6

        move.l	        #WHITE,d1
	    move.b	        #SET_PEN_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #DRAW_CIRCLE_COMMAND,d0

        move.l          (a6),d1
        move.l          8(a6),d5
        lsr.l           #1,d5
        lsr.l           #8,d5
        sub.l           d5,d1
	    move.l          4(a6),d2
    	lsr.l           #8,d2
    	sub.l           d5,d2
    	move.l          8(a6),d5
    	lsr.l           #8,d5
    	move.l          d1,d3
    	add.l           d5,d3
        move.l          d2,d4
    	add.l           d5,d4
    	trap	        #15
    	
    	rts


        rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
