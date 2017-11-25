*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
PLAYER_START_X                  EQU 100
PLAYER_START_Y                  EQU 300
PLAYER_WIDTH                    EQU 20
PLAYER_HEIGHT                   EQU 20

PLAYER_VELOCITY		            EQU	$200
PLAYER_VELOCITY_UP		        EQU	$680
GRAVITY_SIZE                    EQU $40

GET_KEY_INPUT_TRAP_CODE         EQU 19
GET_KEY_INPUT_D1_ULDR           EQU $26252827
GET_KEY_INPUT_D1____Sp          EQU $00000020

UpdatePlayer       
        lea             PlayerPositionAndSize,a6

        move.l          #GET_KEY_INPUT_TRAP_CODE,d0
        move.l          #GET_KEY_INPUT_D1_ULDR,d1
        trap            #15
        move.l          d1,(PlayerInput)
RightInput        
        move.b          d1,d1
        beq             LeftInput
        move.w          #PLAYER_VELOCITY,16(a6)
        move.l          #1,(PlayerLookingRight)
LeftInput
        swap            d1
        move.b          d1,d1
        beq             UpInput
        move.w          #-PLAYER_VELOCITY,16(a6)
        move.l          #0,(PlayerLookingRight)
UpInput
        lsr.l           #8,d1
        move.b          d1,d1
        beq             Undebounce
        move.l          (PlayerShouldJump),d0
        bne             DownInput
        move.l          #1,(PlayerShouldJump)
        lea             PlayerJumpCounter,a0
        move.b          3(a0),d0
        beq             DownInput
        lea             DebounceUpTime,a1
        move.l          (OldTime),d2
        cmp.l           (a1),d2
        blt             DownInput
        move.l          (OldTime),d1
        add.l           #DEBOUNCE_TIME,d1
        move.l          d1,(a1)
        move.w          #-PLAYER_VELOCITY_UP,18(a6)
        sub.b           #1,d0
        move.b          d0,3(a0)
Undebounce        
        move.l          #0,PlayerShouldJump
DownInput  
        swap            d1
        move.b          d1,d1
        beq             MoveInputDone
        
MoveInputDone

        jsr             UpdatePlayerInfo        
        
        move.w          #0,16(a6)           ; After updating player set players X speed to 0
        
        move.l          (PlayerOnGround),d0
        bne             PlayerReachFloor
        move.l          (DeltaTime),d0
        muls            #GRAVITY_SIZE,d0
        add.w           d0,18(a6)
        rts
PlayerReachFloor
        move.l          #0,18(a6)
        lea             PlayerJumpCounter,a0
        move.b          #2,3(a0)
        rts
        
UpdatePlayerInfo:
        move.l          (DeltaTime),d0
	    muls            16(a6),d0
        add.l           (a6),d0
        cmp.l           #LEFT_SIDE_OF_SCREEN<<8,d0
        ble             PlayerReachLeftSide
        cmp.l           #RIGHT_SIDE_OF_SCREEN<<8-PLAYER_WIDTH<<8,d0
        bgt             PlayerReachRightSide
        move.l          d0,(a6)
        jmp             FinishUpdatingPlayerX
PlayerReachLeftSide
        move.l          #LEFT_SIDE_OF_SCREEN<<8,(a6)
        jmp             FinishUpdatingPlayerX
PlayerReachRightSide
        move.l          #RIGHT_SIDE_OF_SCREEN<<8-PLAYER_WIDTH<<8,(a6)
FinishUpdatingPlayerX
               
        move.l          (DeltaTime),d0
	    muls            18(a6),d0
        add.l           4(a6),d0
        cmp.l           #BOTTOM_SIDE_OF_SCREEN<<8-PLAYER_HEIGHT<<8,d0
        bgt             PlayerReachBottomUpdate
        
        move.l          (PlayerInput),d1
        lsr.l           #8,d1
        move.b          d1,d1
        bne             PlayerNotMovingDown
 
        lea             PlayerMovement,a0
        moveq.l         #0,d1
        move.w          2(a0),d1
        bmi             PlayerNotMovingDown
    
        move.l          #PLATFORM_Y-PLAYER_HEIGHT-8,d1
        move.l          d0,d2
        lsr.l           #8,d2
        cmp.l           d1,d2
        blt             PlayerNotMovingDown     
       
        move.l          #PLATFORM_Y-PLAYER_HEIGHT+1,d1
        move.l          d0,d2
        lsr.l           #8,d2
        cmp.l           d1,d2
        blt             PlayerAtPlatformHeight
        
PlayerNotMovingDown     
   
        move.l          d0,4(a6)
        move.l          #0,(PlayerOnGround)
        rts
PlayerReachBottomUpdate
        move.l          #BOTTOM_SIDE_OF_SCREEN<<8-PLAYER_HEIGHT<<8,4(a6)
        move.l          #1,(PlayerOnGround)
	    rts

PlayerAtPlatformHeight

        move.l          (a6),d1
        cmp.l           #LEFT_PLATFORM_LEFT_X<<8-PLAYER_WIDTH<<8,d1
        blt             PlayerNotOnPlatform
        cmp.l           #LEFT_PLATFORM_LEFT_X<<8+PLATFORM_WIDTH<<8,d1
        blt             PlayerOnPlatform
        
        cmp.l           #RIGHT_PLATFORM_LEFT_X<<8-PLAYER_WIDTH<<8,d1
        blt             PlayerNotOnPlatform
        cmp.l           #RIGHT_PLATFORM_LEFT_X<<8+PLATFORM_WIDTH<<8,d1
        blt             PlayerOnPlatform
        jmp             PlayerNotOnPlatform
        
PlayerOnPlatform

        move.l          #PLATFORM_Y<<8-PLAYER_HEIGHT<<8,4(a6)
        move.l          #1,(PlayerOnGround)

        rts
        
PlayerNotOnPlatform

        move.l          d0,4(a6)
        move.l          #0,(PlayerOnGround)

        rts	    
	    
	    
DrawPlayer
        lea             PlayerPositionAndSize,a6
        
        move.l          (OldTime),d0

        cmp.l           (PlayerVulnerabilityTime),d0
        blt             DrawInVulnerablePlayer

        move.l	        #WHITE,d1
	    move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15
        jmp             ChangeInVulnerableColor

DrawInVulnerablePlayer

        move.l	        #YELLOW,d1
	    move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15

ChangeInVulnerableColor	    
        
  	    move.l	        (PlayerColor),d1
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

	    rts
        
ErasePlayer: ;a6 memory location of x,y,w,h,v_x,v_y
       
        lea             PlayerPositionAndSize,a6
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
        
PlayerPositionAndSize       dc.l PLAYER_START_X<<8,PLAYER_START_Y<<8,PLAYER_WIDTH<<8,PLAYER_HEIGHT<<8
PlayerMovement              dc.w 0,0
PlayerOnGround              dc.l 0
PlayerLookingRight          dc.l 1
PlayerJumpCounter           dc.l 2
DebounceUpTime              dc.l 0
PlayerColor                 dc.l WHITE
PlayerInput                 dc.l 0
PlayerShouldJump            dc.l 0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
