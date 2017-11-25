START   ORG     $1000

ALL_REG                         REG     D0-D7/A0-A6

SET_PEN_COLOR_COMMAND           EQU     80
SET_FILL_COLOR_COMMAND          EQU     81
DRAW_CIRCLE_COMMAND             EQU     88
DRAW_RECT_COMMAND               EQU     87

CLEAR_SCREEN_COMMAND            EQU     11
CLEAR_SCREEN_MAGIC_VAL          EQu     $FF00
DRAWING_MODE_TRAP_CODE	        EQU	92
DOUBLE_BUFFERED_MODE	        EQU	17
REPAINT_SCREEN_TRAP_CODE	EQU	94
GET_TIME_SINCE_MIDNIGHT         EQU	8

LEFT_SIDE_OF_SCREEN             EQU     30
RIGHT_SIDE_OF_SCREEN	        EQU	610
BOTTOM_SIDE_OF_SCREEN           EQU     400

BACKGROUND_IMG_WIDTH            EQU     640
BACKGROUND_IMG_HEIGHT           EQU     480

DEBOUNCE_TIME                   EQU     10

YELLOW                          EQU     $0000FFFF
WHITE			        EQU	$00FFFFFF
BLACK			        EQU	$00000000

TIME_TO_KILL_BOSS               EQU     120

GET_KEY_INPUT_D1___R            EQU     $00000052

BLACK_BOX_LEFT_SIDE_OF_SCREEN   EQU     30
BLACK_BOX_TOP_SIDE_OF_SCREEN    EQU     45
BLACK_BOX_RIGHT_SIDE_OF_SCREEN	EQU	610
BLACK_BOX_BOTTOM_SIDE_OF_SCREEN EQU     400

LEFT_PLATFORM_LEFT_X            EQU     200
RIGHT_PLATFORM_LEFT_X           EQU     394
PLATFORM_Y                      EQU     300
PLATFORM_WIDTH                  EQU     46
PLATFORM_HEIGHT                 EQU     12

SCREEN_WIDTH                    EQU     540
SCREEN_HEIGHT                   EQU     480

;full screen
        move.b	        #33,d0
      	move.b	        #2,d1
      	*trap	        #15

Setup

;Setup
        *set double buffered mode
      	move.b	        #DRAWING_MODE_TRAP_CODE,d0
      	move.b	        #DOUBLE_BUFFERED_MODE,d1
      	trap	        #15

        jsr             seedRandomNumber

        lea.l           Bitmap, a0
        move.l          #0, d0
        move.l          #0, d1
        move.l          #BACKGROUND_IMG_WIDTH, d2
        move.l          #BACKGROUND_IMG_HEIGHT, d3
        move.l          #0, d4
        move.l          #0, d5
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap
        add.l           #28, sp
        
        move.l	        #Black,d1
        
        move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15
	move.l          #SET_FILL_COLOR_COMMAND,d0
	trap	        #15

	move.b	        #DRAW_RECT_COMMAND,d0
	move.l          #BLACK_BOX_LEFT_SIDE_OF_SCREEN,d1
	move.l          #BLACK_BOX_TOP_SIDE_OF_SCREEN,d2
	move.l          #BLACK_BOX_RIGHT_SIDE_OF_SCREEN,d3
	move.l          #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d4
        trap	        #15
        
        jsr             DrawDroppers
        jsr             DrawPlatforms
        
        jsr	        swapBuffers

        jsr             GetDeltaTime
        move.l          (OldTime),(PlayerVulnerabilityTime)
        move.l          (OldTime),d0
        add.l           #TIME_TO_KILL_BOSS*100,d0
        move.l          d0,(EndTime)
        
GameLoop:
        jsr             GetDeltaTime 
        
        jsr             ClearScreen
        
        jsr             UpdateGameObjects
        
        jsr             CheckCollision
        
        jsr             DrawGameObjects
       	
	jsr	        swapBuffers
	
	jsr             CheckGameStatus
	
	bra             GameLoop

CheckGameStatus

        lea             GameOverBossKilled,a1
        move.l          #1,d1
        move.l          (BossHealth),d0
        ble             GameOver
        lea             GameOverPlayerKilled,a1	
        move.l          #0,d1
        move.l          (PlayerHealth),d0
        ble             GameOver
        move.l          #0,d1
        lea             GameOverTimeRanOut,a1	
        move.l          (TimeLeft),d0
        ext.l           d0
        bmi             GameOver

        rts
GameOver
       	
        cmp.l           #0,d1
      	beq             GameOverYouLose   
GameOverYouWin
        lea.l           YouWin,a0
        jmp             GameOverPrint    
GameOverYouLose   
        lea.l           YouLose,a0
GameOverPrint    	
       	
        move.l          #0, d0
        move.l          #1, d1
        move.l          #130, d2
        move.l          #39, d3
        move.l          #255, d4
        move.l          #220, d5
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap

        jsr	        swapBuffers
        
GameOverLoop
        
        move.l          #GET_KEY_INPUT_TRAP_CODE,d0
        move.l          #GET_KEY_INPUT_D1___R,d1
        trap            #15
        move.b          d1,d1
        bne             ResetGame
        
        beq             GameOverLoop
        
ResetGame
        
        move.l          #BOSS_START_HEALTH,(BossHealth)
        move.l          #PLAYER_START_HEALTH,(PlayerHealth)
;Reset Boss        
        lea             BossPositionAndSize,a0
        move.l          #BOSS_START_X<<8,(a0)+
        move.l          #BOTTOM_SIDE_OF_SCREEN<<8-BOSS_HEIGHT<<8-1<<8,(a0)+
        move.l          #BOSS_WIDTH<<8,(a0)+
        move.l          #BOSS_HEIGHT<<8,(a0)+

        move.w          #0,(a0)+
        move.w          #0,(a0)+
        move.l          #0,(a0)+
        move.b          #0,(a0)+
        move.b          #0,(a0)+
        move.l          #$00FFFFFF,(a0)+   

        lea             BossBulletsLeftToShoot,a0
        move.b          #BOSS_BULLET_COUNT_SHOT,(a0)+
        move.b          #0,(a0)
        
        lea             BossLavaFillPercent,a0
        move.l          #0,(a0)+
        move.l          #BOSS_LAVA_FILL_RATE,(a0)+
        
        lea             BossRainLeftToShoot,a0
        move.b          #BOSS_MAX_RAIN,(a0)+
        move.b          #0,1(a0)
        
        lea             BossTimeStateStart,a0
        move.l          #0,(a0)
        
;Reset Player
        lea             PlayerPositionAndSize,a0
        move.l          #PLAYER_START_X<<8,(a0)+
        move.l          #PLAYER_START_Y<<8,(a0)+
        move.l          #PLAYER_WIDTH<<8,(a0)+
        move.l          #PLAYER_HEIGHT<<8,(a0)+

        move.l          #0,(a0)+
        move.l          #0,(a0)+
        move.l          #1,(a0)+
        move.l          #2,(a0)+
        move.l          #0,(a0)+
        move.l          #WHITE,(a0)+
        move.l          #0,(a0)+
        move.l          #0,(a0)+  

; Reset Bullet      
        lea             AllowedBullets,a0
        move.b          #MAX_ALLOWED_BULLETS,(a0)+
        move.b          #0,(a0)+

        lea             BossHealth,a0
        move.l          #BOSS_START_HEALTH,(a0)+
        move.l          #PLAYER_START_HEALTH,(a0)+
        move.l          #0,(a0)+
        
        move.l          #$01000000,a7
        jmp             Setup

GetDeltaTime
        move.l          #GET_TIME_SINCE_MIDNIGHT,d0
        trap            #15
        sub.l           (OldTime),d1
        move.l          d1,(DeltaTime)
        trap            #15
        move.l          d1,(OldTime)
        rts

DrawBackgroundBitmap: ;a0-address, d0-x piece d1-y piece d2-piece width d3-piece height d4-draw x location d5-draw y location
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap
        
        add.l           #28, sp
        rts
        
UpdateGameObjects
        jsr             CalculateTimeLeft
        jsr             UpdatePlayer
       	jsr             UpdateBoss
       	jsr             UpdateBullets
       	jsr             UpdateBossBullets
       	jsr             UpdateRain

        rts
        
DrawGameObjects
        jsr             DrawTimeLeft
        jsr             DrawPlayer
        jsr             DrawBullets
        jsr             DrawBoss
        jsr             DrawBossBullets 
        jsr             DrawBossRain
        jsr             DrawLava
        
        rts
        
ClearScreen
        
        ;jsr             ErasePlayer
        ;jsr             EraseBullets
        ;jsr             EraseBoss
        ;jsr             EraseBossBullets
        ;jsr             ClearSegments
        ;jsr             EraseLava
                
        move.l	        #Black,d1
        
        move.l          #SET_PEN_COLOR_COMMAND,d0
        trap            #15
	move.l          #SET_FILL_COLOR_COMMAND,d0
	trap	        #15

	move.b	        #DRAW_RECT_COMMAND,d0
	move.l          #BLACK_BOX_LEFT_SIDE_OF_SCREEN,d1
	move.l          #BLACK_BOX_TOP_SIDE_OF_SCREEN,d2
	move.l          #BLACK_BOX_RIGHT_SIDE_OF_SCREEN,d3
	move.l          #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d4
        trap	        #15
        
        jsr             DrawDroppers
        jsr             DrawPlatforms
       
	rts

swapBuffers
	move.b          #REPAINT_SCREEN_TRAP_CODE,d0
      	TRAP            #15
	rts 

DrawDroppers
        lea.l           Dropper,a0
        move.l          #0, d0
        move.l          #0, d1
        move.l          #DROPPER_WIDTH, d2
        move.l          #DROPPER_HEIGHT, d3
        move.l          #DROPPER_ONE_X, d4
        move.l          #DROPPER_Y, d5
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap
        
        move.l          #DROPPER_TWO_X,4(sp)

        jsr             DrawBitmap

        move.l          #DROPPER_THREE_X,4(sp)

        jsr             DrawBitmap
        
        move.l          #DROPPER_FOUR_X,4(sp)

        jsr             DrawBitmap
        
        add.l           #28, sp    
        
        rts
        
DrawPlatforms
        lea.l           Platform,a0
        move.l          #0, d0
        move.l          #0, d1
        move.l          #PLATFORM_WIDTH, d2
        move.l          #PLATFORM_HEIGHT, d3
        move.l          #LEFT_PLATFORM_LEFT_X, d4
        move.l          #PLATFORM_Y, d5
        
        move.l          a0, -(sp)
        move.l          d0, -(sp)
        move.l          d1, -(sp)
        move.l          d2, -(sp)
        move.l          d3, -(sp)
        move.l          d4, -(sp)
        move.l          d5, -(sp)

        jsr             DrawBitmap
        
        move.l          #RIGHT_PLATFORM_LEFT_X,4(sp)

        jsr             DrawBitmap
        
        add.l           #28, sp    
        
        rts        

DeltaTime               ds.l 1
OldTime                 ds.l 1
EndTime                 ds.l 1
TimeLeft                ds.l 1

GameOverBossKilled	dc.b 'YOU WIN Press R to restart',0
GameOverPlayerKilled	dc.b 'YOU LOST Press R to restart',0
GameOverTimeRanOut	dc.b 'YOU RAN OUT OF TIME Press R to restart',0
EmptyLong               ds.l 1

        INCLUDE "Lava.x68"
        INCLUDE "Rain.x68"
        INCLUDE "SevenSegmentDisplay.X68"
        INCLUDE "Collisions.x68"
        INCLUDE "Boss.x68"
        INCLUDE "BossBullets.x68"
        INCLUDE "PlayerController.x68"
        INCLUDE "Bullets.x68"
        INCLUDE "BitmapDrawer.x68"
        INCLUDE "RandomNumbers.x68"
	
        END     START


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
