*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

BULLET_SIZE_WIDTH               EQU 10
BULLET_SIZE_HEIGHT              EQU 10
BULLET_SPEED                    EQU $300

BULLET_DRAW_SIZE_WIDTH          EQU 12
MAX_ALLOWED_BULLETS             EQU 3
FULL_ACTIVE_BULLETS             EQU $7

BULLET_COLOR                    EQU $00FFFFFF

UpdateBullets:
        move.l          #GET_KEY_INPUT_TRAP_CODE,d0
        move.l          #GET_KEY_INPUT_D1____Sp,d1
        trap            #15
OneButtonsPressed               
        move.b          d1,d1
        beq             OtherInputDone
        
        lea             DebounceOneTime,a1
        move.l          (OldTime),d2
        cmp.l           (a1),d2
        blt             OtherInputDone
        move.l          (OldTime),d1
        add.l           #DEBOUNCE_TIME,d1
        move.l          d1,(a1)
        jsr             CreateBullets
OtherInputDone

        jsr             UpdateBulletsPositions
        
        rts
        
CreateBullets:
        move.b          (ActiveBullets),d0
        ;cmp.b           #FULL_ACTIVE_BULLETS,d0
        ;beq             BulletsFull
CreateFirstBullet        
        btst            #0,(ActiveBullets)
        bne             CreateSecondBullet
        
        lea             BulletOnePosition,a6
        bset            #0,(ActiveBullets)
        move.l          (PlayerLookingRight),d2
        beq             BulletSetNegativeSpeed
        jmp             BulletSetPositiveSpeed
CreateSecondBullet
        btst            #1,(ActiveBullets)
        bne             CreateThirdBullet
        
        lea             BulletTwoPosition,a6
        bset            #1,(ActiveBullets)
        move.l          (PlayerLookingRight),d2
        beq             BulletSetNegativeSpeed
        jmp             BulletSetPositiveSpeed
        
CreateThirdBullet
        btst            #2,(ActiveBullets)
        bne             BulletsFull
        
        lea             BulletThreePosition,a6
        bset            #2,(ActiveBullets)
        move.l          (PlayerLookingRight),d2
        beq             BulletSetNegativeSpeed
        jmp             BulletSetPositiveSpeed
        
BulletSetNegativeSpeed
        move.w          #-BULLET_SPEED,8(a6)
        lea             PlayerPositionAndSize,a5
        move.l          (a5),(a6)
        move.l          4(a5),4(a6)
        rts
BulletSetPositiveSpeed
        move.w          #BULLET_SPEED,8(a6)
        lea             PlayerPositionAndSize,a5
        move.l          (a5),d2
        add.l           8(a5),d2
        move.l          d2,(a6)
        move.l          4(a5),4(a6)
BulletsFull
        rts

UpdateBulletsPositions:
        move.l          (DeltaTime),d1
        moveq.l         #0,d2
        move.b          (ActiveBullets),d2
        
        beq             UpdateBulletEnd
        
UpdateBulletOne 
        btst            #0,(ActiveBullets)
        beq             UpdateBulletTwo
         
        moveq.l         #0,d0
        lea             BulletOnePosition,a0
        move.w          8(a0),d0
        muls            d1,d0
        add.l           (a0),d0
        move.l          d0,(a0)
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d0
        blt             DestoryOneBullet
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-BULLET_SIZE_WIDTH<<8,d0
        bgt             DestoryOneBullet
        move.l          d0,(a0)
        jmp             UpdateBulletTwo
DestoryOneBullet
        jsr             EraseBullets
        bclr            #0,(ActiveBullets)
UpdateBulletTwo
        btst            #1,(ActiveBullets)
        beq             UpdateBulletThree         
        
        move.l          (DeltaTime),d1
        lea             BulletTwoPosition,a0
        move.w          8(a0),d0
        muls            d1,d0
        add.l           (a0),d0
        move.l          d0,(a0)
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d0
        blt             DestoryTwoBullet
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-BULLET_SIZE_WIDTH<<8,d0
        bgt             DestoryTwoBullet
        move.l          d0,(a0)
        jmp             UpdateBulletThree
DestoryTwoBullet
        jsr             EraseBullets
        bclr            #1,(ActiveBullets)
UpdateBulletThree
        btst            #2,(ActiveBullets)
        beq             UpdateBulletEnd
        
        move.l          (DeltaTime),d1
        lea             BulletThreePosition,a0
        move.w          8(a0),d0
        muls            d1,d0
        add.l           (a0),d0
        move.l          d0,(a0)
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d0
        blt             DestoryThirdBullet
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-BULLET_SIZE_WIDTH<<8,d0
        bgt             DestoryThirdBullet
        move.l          d0,(a0)
        jmp             UpdateBulletEnd
DestoryThirdBullet
        jsr             EraseBullets
        bclr            #2,(ActiveBullets)
        
UpdateBulletEnd       
        rts
        
DrawBullets:
        move.l	        #BULLET_COLOR,d1
	    move.b	        #SET_PEN_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #DRAW_CIRCLE_COMMAND,d0
	    
	    move.b          (ActiveBullets),d5
        beq             EndDrawBullets
        	    
DrawFirstBullet	    
        btst            #0,(ActiveBullets)
        beq             DrawSecondBullet
        
	    lea             BulletOnePosition,a6
        jsr             DrawSpecificBulletAtA6

DrawSecondBullet
        btst            #1,(ActiveBullets)
        beq             DrawThirdBullet
  	
    	lea             BulletTwoPosition,a6
        jsr             DrawSpecificBulletAtA6

DrawThirdBullet    
        btst            #2,(ActiveBullets)
        beq             EndDrawBullets
	
    	lea             BulletThreePosition,a6
    	jsr             DrawSpecificBulletAtA6

EndDrawBullets
        rts
        
DrawSpecificBulletAtA6
        move.l          (a6),d1
	    lsr.l           #8,d1
	    move.l          4(a6),d2
    	lsr.l           #8,d2
    	move.l          d1,d3
       	add.l           #BULLET_SIZE_WIDTH,d3
	    move.l          d2,d4
       	add.l           #BULLET_SIZE_HEIGHT,d4	
    	trap	        #15
    	
    	rts
    
EraseBullets:
        
EraseFirstBullet
        btst            #0,(ActiveBullets)
        beq             EraseSecondBullet
        
        lea             BulletOnePosition,a6
        jsr             EraseCall
        
EraseSecondBullet
        btst            #1,(ActiveBullets)
        beq             EraseThirdBullet
        lea             BulletTwoPosition,a6
        jsr             EraseCall
        
EraseThirdBullet
        btst            #2,(ActiveBullets)
        beq             EraseBulletDone
        lea             BulletThreePosition,a6
        jsr             EraseCall
        rts
EraseCall
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
EraseBulletDone
        rts        

AllowedBullets              dc.b MAX_ALLOWED_BULLETS
ActiveBullets               dc.b 0
BulletOnePosition           dc.l 0<<8,0<<8
BulletOneSpeed              dc.w 0
BulletTwoPosition           dc.l 0<<8,0<<8
BulletTwoSpeed              dc.w 0
BulletThreePosition         dc.l 0<<8,0<<8
BulletThreeSpeed            dc.w 0

DebounceOneTime             dc.l 0






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
