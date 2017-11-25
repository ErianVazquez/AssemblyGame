BOSS_START_X                        EQU 400
BOSS_WIDTH                          EQU 40
BOSS_HEIGHT                         EQU 40

BOSS_VELOCITY_UP		            EQU	$800
BOSS_GRAVITY_SIZE                   EQU $30
BOSS_TIME_TO_JUMP_AND_FALL          EQU (BOSS_VELOCITY_UP/BOSS_GRAVITY_SIZE)

BOSS_BULLET_COLOR                   EQU $00FFFF00

BOSS_BULLET_SPEED                   EQU $300
BOSS_TIME_BETWEEN_SHOT              EQU 50
BOSS_BULLET_COUNT_SHOT              EQU 3
BOSS_BULLET_WIDTH                   EQU 10
BOSS_BULLET_HEIGHT                  EQU 10
BOSS_SHOT_HEIGHT_OFFSET             EQU 25

BOSS_MAX_BULLETS                    EQU 6
BOSS_MAX_RAIN                       EQU 4
BOSS_BULLET_DATA_SIZE_IN_BYTES      EQU 10
BOSS_RAIN_DATA_SIZE_IN_BYTES        EQU 18

BOSS_WAIT_TIME                      EQU 10

BOSS_LAVA_FILL_RATE                 EQU 3<<7

UpdateBoss
        
        move.l          (BossPositionAndSize),d0
        move.l          (PlayerPositionAndSize),d1 
        cmp.l           d0,d1
        blt             UpdateBossLookLeft        
UpdateBossLookRight        
        move.b          #1,(BossShouldFaceRight)
        jmp             UpdateBossLookDone
UpdateBossLookLeft
        move.b          #0,(BossShouldFaceRight)
        
UpdateBossLookDone
        moveq.l         #0,d0
        move.b          (BossState),d0
        beq             GetNewState

CheckBossState
       
        move.l          (OldTime),d4
        move.l          (BossTimeStateStart),d5
        beq             DoState
        cmp.l           d4,d5
        bgt             BossStateNeedsToWait
       
DoState
        lea             UpdateStateTable,a0
        sub.l           #4,d0
        move.l          (a0,d0),d0
        move.l          d0,a0
        jsr             (a0)
        jmp             BossStateUpdateDone
        
GetNewState

        move.l          (OldTime),d5
        add.l           #BOSS_WAIT_TIME,d5
        move.l          d5,(BossTimeStateStart)

        jsr             getRandomLongIntoD6
;                move.l           #3,d6
        and.l           #3,d6
        lsl.l           #2,d6
        lea             SetStateTable,a0
        add.l           d6,a0
        move.l          (a0),d6
        move.l          d6,a0
        jsr             (a0)
        
BossStateNeedsToWait
        move.l          d5,d5
BossStateUpdateDone
        lea             BossPositionAndSize,a6
        move.l          (BossOnGround),d0  
        bne             BossReachFloor
        move.l          (DeltaTime),d0
        muls            #GRAVITY_SIZE,d0
        add.w           d0,18(a6)
BossReachFloor

        rts

DrawBoss
        move.l          #WHITE,d1
        move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15

        lea             BossPositionAndSize,a6

        move.l          (BossHealth),d1
        bmi             DrawDoneBoss

        moveq.l         #0,d2
        move.l	        (BossColor),d1
        move.b          (BossState),d2
        beq             StateZeroDraw
        sub.b           #4,d2
        beq             StateOneDraw
        sub.b           #4,d2
        beq             StateTwoDraw
        sub.b           #4,d2
        beq             StateThreeDraw
        sub.b           #4,d2
        beq             StateFourDraw
StateZeroDraw
        and.l           #$FFFFFF,d1
        jmp             ChangeColorDone
StateOneDraw
        and.l           #$FF0000,d1       
        jmp             ChangeColorDone
StateTwoDraw
        and.l           #$00FF00,d1
        jmp             ChangeColorDone
StateThreeDraw
        and.l           #$0000FF,d1
        jmp             ChangeColorDone
StateFourDraw
        and.l           #$FF00FF,d1
        jmp             ChangeColorDone
ChangeColorDone

	    move.l          #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15

	    move.b	        #DRAW_CIRCLE_COMMAND,d0
	    move.l          (a6),d1 
	    lsr.l           #8,d1
	    move.l          4(a6),d2
	    lsr.l           #8,d2
	    move.l          8(a6),d3
	    add.l           (a6),d3
	    lsr.l           #8,d3
	    move.l          12(a6),d4
	    add.l           4(a6),d4
	    lsr.l           #8,d4	
	    trap	        #15

DrawDoneBoss
	    rts
        
EraseBoss: ;a6 memory location of x,y,w,h,v_x,v_y
       
        lea             BossPositionAndSize,a6
        move.l          (a6),d0
        lsr.l           #8,d0
        sub.l           #1,d0
        move.l          4(a6),d1
        lsr.l           #8,d1
        sub.l           #-1,d1
        move.l          8(a6),d2
        lsr.l           #8,d2
        lea.l           Bitmap, a0
        move.l          d0,d0
        move.l          d1,d1
        move.l          d2,d3
        add.l           #2,d2
        move.l          d2,d2
        move.l          d0,d4
        move.l          d1,d5
        
        jsr DrawBackgroundBitmap
        
        rts

SetStateOne
        move.b          #BOSS_BULLET_COUNT_SHOT,(BossBulletsLeftToShoot)
        move.l          (OldTime),d7
        move.l          d7,(BossTimeToShoot)
                
        move.b          #4,(BossState)
        rts
SetStateTwo

        lea             PlayerPositionAndSize,a0

        move.l          (a0),d0
        move.l          8(a0),d1
        asr.l           #1,d1
        add.l           d1,d0
        lea             BossPositionAndSize,a0
        move.l          (a0),d1
        
        move.b          (BossShouldFaceRight),d2
        bne.b           SetStateTwoFaceRight
SetStateTwoFaceLeft
        jmp             SetStateTwoOffset
SetStateTwoFaceRight
        add.l           8(a0),d1
SetStateTwoOffset
        
        sub.l           d0,d1
        move.l          d1,d0
        asr.l           #1,d0
        add.l           d0,d1
        divs            #-BOSS_TIME_TO_JUMP_AND_FALL,d1    
        asr.w           #1,d1
        move.w          d1,(BossVelocityX)
      
        move.w          #-BOSS_VELOCITY_UP,(BossVelocityY)

        move.b          #8,(BossState)
        
        ;jsr             UpdateStateTwo
        
        rts 
SetStateThree

        moveq.l         #0,d0
        move.b          (BossRainActive),d0
        bne             FinishSetStateThree 

        bset            #0,(BossRainActive)
        bset            #1,(BossRainActive)
        bset            #2,(BossRainActive)
        bset            #3,(BossRainActive)

        move.l          #DROPPER_Y<<8+DROPPER_HEIGHT<<8,d0

        lea             BossRainArray,a0

        move.l          #DROPPER_ONE_X+DROPPER_WIDTH/2,(a0)
        move.l          #DROPPER_TWO_X+DROPPER_WIDTH/2,18(a0)
        move.l          #DROPPER_THREE_X+DROPPER_WIDTH/2,36(a0)
        move.l          #DROPPER_FOUR_X+DROPPER_WIDTH/2,54(a0)   

        move.l          d0,4(a0)
        move.l          d0,22(a0)
        move.l          d0,40(a0)
        move.l          d0,58(a0)
        
        move.l          #DROP_SIZE_INCREASE,8(a0)
        move.l          #DROP_SIZE_INCREASE,26(a0)
        move.l          #DROP_SIZE_INCREASE,44(a0)
        move.l          #DROP_SIZE_INCREASE,62(a0)
        move.l          #DROP_SIZE_INCREASE,12(a0)
        move.l          #DROP_SIZE_INCREASE,30(a0)
        move.l          #DROP_SIZE_INCREASE,48(a0)
        move.l          #DROP_SIZE_INCREASE,66(a0) 

        move.w          #INIITAL_DROP_SPEED,16(a0)
        move.w          #INIITAL_DROP_SPEED,34(a0)
        move.w          #INIITAL_DROP_SPEED,52(a0)
        move.w          #INIITAL_DROP_SPEED,70(a0)

        move.b          #12,(BossState)
        rts
FinishSetStateThree 
        move.b          #0,(BossState)
        rts
SetStateFour

        move.l          #0,(BossLavaFillPercent)
        move.l          #BOSS_LAVA_FILL_RATE,(BossLavaFillRate)

        move.b          #16,(BossState)
        rts

UpdateStateOne

        lea             BossBulletsLeftToShoot,a0
        moveq.l         #0,d0
        move.b          (a0),d0
        beq             FinsihedStateOne    
    
        move.l          (OldTime),d7
        move.l          (BossTimeToShoot),d6
        cmp.l           d6,d7
        blt             BossShootBulletDone
    
        sub.b           #1,d0
        move.b          d0,(a0)
    
        move.l          #0,d0
        
FindOpenBossBulletLoop
        btst            d0,(BossBulletsActive)
        beq             BossBulletFound
        add.b           #1,d0
        cmp.b           #BOSS_MAX_BULLETS,d0
        bgt             FinsihedStateOne
        jmp             FindOpenBossBulletLoop

BossBulletFound

        bset            d0,(BossBulletsActive)

        mulu            #BOSS_BULLET_DATA_SIZE_IN_BYTES,d0
        lea             BossBulletArray,a0
        add.l           d0,a0
        
        lea             BossPositionAndSize,a1     
        move.b          (BossShouldFaceRight),d0
        bne             BossShootRight
BossShootLeft
        move.l          (a1),(a0)
        move.l          4(a1),d2
        add.l           #BOSS_SHOT_HEIGHT_OFFSET<<8,d2
        move.l          d2,4(a0)   
        move.w          #-BOSS_BULLET_SPEED,8(a0)
        jmp             BossShotDone
BossShootRight
        move.l          (a1),d2
        add.l           8(a1),d2
        move.l          d2,(a0)
        move.l          4(a1),d2
        add.l           #BOSS_SHOT_HEIGHT_OFFSET<<8,d2
        move.l          d2,4(a0)   
        move.w          #BOSS_BULLET_SPEED,8(a0)
BossShotDone
        move.l          (OldTime),d0
        add.l           #BOSS_TIME_BETWEEN_SHOT,d0
        move.l          d0,(BossTimeToShoot)
BossShootBulletDone
        rts
        
FinsihedStateOne    
        move.b          #0,(BossState)
        rts
        
UpdateStateTwo
        lea             BossPositionAndSize,a6
        
        move.l          (DeltaTime),d0
	    muls            16(a6),d0
        add.l           (a6),d0
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d0
        ble             BossReachLeftSide
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-BOSS_WIDTH<<8,d0
        bgt             BossReachRightSide
        move.l          d0,(a6)
        jmp             FinishUpdatingBossX
BossReachLeftSide
        move.l          #LEFT_SIDE_OF_SCREEN<<8,(a6)
        jmp             FinishUpdatingBossX
BossReachRightSide
        move.l          #RIGHT_SIDE_OF_SCREEN<<8-BOSS_WIDTH<<8,(a6)
FinishUpdatingBossX
               
        move.l          (DeltaTime),d0
	    muls            18(a6),d0
        add.l           4(a6),d0
        cmp.l           #BOTTOM_SIDE_OF_SCREEN<<8-BOSS_HEIGHT<<8,d0
        bgt             BossReachBottomUpdate
        move.l          d0,4(a6)
        move.l          #0,(BossOnGround)
        rts
BossReachBottomUpdate
        move.l          #BOTTOM_SIDE_OF_SCREEN<<8-BOSS_HEIGHT<<8,4(a6)
        move.l          #1,(BossOnGround)
        move.b          #0,(BossState)
	    rts

UpdateStateThree
        lea             BossRainArray,a0
        move.l          8(a0),d0
        cmp.l           #DROP_SIZE,d0
        bge             FinishStateThree
        rts
FinishStateThree
        move.b          #0,(BossState)
        rts
UpdateStateFour

        move.l          (BossLavaFillPercent),d0
        move.l          (BossLavaFillRate),d1
        move.l          (DeltaTime),d2
        muls            d2,d1
        bmi             FillRateIsNegative        
        jmp             FillRateIsPositive
FillRateIsNegative

        move.l          d0,d7

        add.l           d1,d0
        move.l          d0,(BossLavaFillPercent)
        
        move.l          d0,d6
               
        move.l          (BossLavaFillPercent),d0
        bmi             StateFourEnded

        jsr             EraseLava

        rts        

FillRateIsPositive
        
        add.l           d1,d0
        move.l          d0,(BossLavaFillPercent)
        
        cmp.l           #110<<8,d0
        blt             DontSwapSign
        move.l          #-BOSS_LAVA_FILL_RATE,(BossLavaFillRate)
DontSwapSign
        rts

StateFourEnded
        move.l          #BOSS_LAVA_FILL_RATE,(BossLavaFillRate)
        move.b          #0,(BossState)
        rts
              
        
BossPositionAndSize         dc.l BOSS_START_X<<8,BOTTOM_SIDE_OF_SCREEN<<8-BOSS_HEIGHT<<8-1<<8,BOSS_WIDTH<<8,BOSS_HEIGHT<<8
BossVelocityX               dc.w 0
BossVelocityY               dc.w 0
BossOnGround                dc.l 0
BossShouldFaceRight         dc.b 0
BossState                   dc.b 8                        ;State 0 waiting for update, State 4 shooting, State 8 Jumping, State 12 Dropping, State 16 Flooding
BossColor                   dc.l $00FFFFFF

BossBulletsLeftToShoot      dc.b BOSS_BULLET_COUNT_SHOT
BossBulletsActive           dc.b 0
BossTimeToShoot             dc.l 0
BossBulletArray             ds.l BOSS_MAX_BULLETS*BOSS_BULLET_DATA_SIZE_IN_BYTES
*BossBulletOnePosition       dc.l 0<<8,0<<8
*BossBulletOneSpeed          dc.l 0

BossRainLeftToShoot         dc.b BOSS_MAX_RAIN
BossRainActive              dc.b 0
BossRainArray               ds.l BOSS_MAX_RAIN*BOSS_RAIN_DATA_SIZE_IN_BYTES ; center of where to draw, width,height, y velocity

BossLavaFillPercent         dc.l 0
BossLavaFillRate            dc.l BOSS_LAVA_FILL_RATE

BossTimeStateStart          dc.l 0

SetStateTable               dc.l SetStateOne, SetStateTwo, SetStateThree, SetStateFour
UpdateStateTable            dc.l UpdateStateOne, UpdateStateTwo, UpdateStateThree, UpdateStateFour

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
