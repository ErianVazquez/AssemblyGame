
UpdateBossBullets
        
        move.l          #0,d0
        
FindActiveBossBulletLoop
        btst            d0,(BossBulletsActive)
        bne             ActiveBulletsFound
        add.b           #1,d0
        cmp.b           #BOSS_MAX_BULLETS,d0
        bgt             AllBossBulletsUpdated
        jmp             FindActiveBossBulletLoop

ActiveBulletsFound

        jsr             UpdateSpecificBossBullet

        add.b           #1,d0
        cmp.b           #BOSS_MAX_BULLETS,d0
        bgt             AllBossBulletsUpdated
        jmp             FindActiveBossBulletLoop

AllBossBulletsUpdated
            
        rts
        
UpdateSpecificBossBullet

        move.l          d0,d1
        lea             BossBulletArray,a0
        mulu            #BOSS_BULLET_DATA_SIZE_IN_BYTES,d1
        add.l           d1,a0
        
        move.l          (DeltaTime),d7
        move.w          8(a0),d1
        muls            d7,d1
        add.l           (a0),d1
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d1
        blt             DeleteBossBullet
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-BOSS_BULLET_WIDTH<<8,d1
        bgt             DeleteBossBullet
        move.l          d1,(a0)        
        rts
DeleteBossBullet        
        bclr            d0,(BossBulletsActive)
        rts

        
DrawBossBullets

        move.l          #0,d6
        lea             BossBulletArray,a6
        
DrawActiveBossBulletLoop
        btst            d6,(BossBulletsActive)
        bne             DrawActiveBossBulletFound   
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletDrawn
        jmp             DrawActiveBossBulletLoop

DrawActiveBossBulletFound   
            
        jsr             DrawSpecificBossBulletAtA6
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletDrawn
        jmp             DrawActiveBossBulletLoop
        
AllBossBulletDrawn
            
        rts
        
DrawSpecificBossBulletAtA6

        move.l	        #BULLET_COLOR,d1
	    move.b	        #SET_PEN_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #DRAW_CIRCLE_COMMAND,d0

        move.l          (a6),d1
	    lsr.l           #8,d1
	    move.l          4(a6),d2
    	lsr.l           #8,d2
    	move.l          d1,d3
       	add.l           #BOSS_BULLET_WIDTH,d3
	    move.l          d2,d4
       	add.l           #BOSS_BULLET_HEIGHT,d4	
    	trap	        #15
    	
    	rts
        
EraseBossBullets        
    
        move.l          #0,d6
        lea             BossBulletArray,a6
        
EraseActiveBossBulletLoop
        btst            d6,(BossBulletsActive)
        bne             EraseActiveBossBulletFound
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletDrawn
        jmp             EraseActiveBossBulletLoop

EraseActiveBossBulletFound   
         
        move.l          a6,-(sp) 
        move.l          d6,-(sp)  
        jsr             ErasedSpecificBossBulletAtA6
        move.l          (sp)+,d6
        move.l          (sp)+,a6
        
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletDrawn
        jmp             EraseActiveBossBulletLoop
        
AllBossBulletErased
            
        rts
        
ErasedSpecificBossBulletAtA6
        move.l          (a6),d0
        lsr.l           #8,d0
        sub.l           #1,d0
        move.l          4(a6),d1
        lsr.l           #8,d1
        sub.l           #-1,d1

        lea.l           Bitmap, a0
        move.l          d0,d0
        move.l          d1,d1
        move.l          #BULLET_DRAW_SIZE_WIDTH,d2
        move.l          #BULLET_SIZE_HEIGHT,d3
        move.l          d0,d4
        move.l          d1,d5
        
        jsr             DrawBackgroundBitmap
    	
    	rts




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
