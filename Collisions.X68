
BOSS_START_HEALTH               EQU 255
PLAYER_START_HEALTH             EQU 255

BOSS_SHOOT_DAMAGE               EQU 30
BOSS_RAIN_DAMAGE                EQU 30
BOSS_LAVA_DAMAGE                EQU 40
BOSS_JUMP_DAMAGE                EQU 40

PLAYER_BULLET_DAMAGE            EQU 8
PLAYER_INVULNERABILITY_TIME     EQU 100 
        
CheckCollision

        jsr             CheckPlayerBullet
        jsr             CheckPlayerAndBossCollision
        jsr             CheckBossBullets
        jsr             CheckBossRain
        jsr             CheckLava

        rts
        
CheckPlayerAndBossCollision

        move.l          (OldTime),d0

        cmp.l           (PlayerVulnerabilityTime),d0
        blt             BossDidNotCollide

        lea             PlayerPositionAndSize,a6
        lea             BossPositionAndSize,a5
        
        move.l          (a6),d1
        move.l          4(a6),d2
        
        move.l          4(a5),d3
        sub.l           #PLAYER_HEIGHT<<8,d3
        
        cmp.l           d2,d3
        bgt             BossDidNotCollide
        add.l           #PLAYER_HEIGHT<<8+BOSS_HEIGHT<<8,d3
        cmp.l           d2,d3
        blt             BossDidNotCollide
        move.l          (a5),d3
        sub.l           #PLAYER_WIDTH<<8,d3
        cmp.l           d1,d3
        bgt             BossDidNotCollide
        add.l           #PLAYER_WIDTH<<8+BOSS_WIDTH<<8,d3
        cmp.l           d1,d3
        blt             BossDidNotCollide
        
        add.l           #PLAYER_INVULNERABILITY_TIME,d0
        move.l          d0,(PlayerVulnerabilityTime)
        sub.l           #BOSS_JUMP_DAMAGE,(PlayerHealth)

        move.l          (PlayerHealth),d4

        move.l          d4,d3
        swap            d3
        move.b          d4,d3
        lsl.w           #8,d3
        move.b          d4,d3

        move.l          d3,(PlayerColor)

        rts
BossDidNotCollide
        
        rts

CheckPlayerBullet
        
        move.l          #0,d0
        lea             BulletOnePosition,a6
        
CheckPlayerBulletLoop
        btst            d0,(ActiveBullets)
        bne             CheckActiveBullet
        add.b           #1,d0
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #MAX_ALLOWED_BULLETS,d0
        bgt             AllPlayerBulletChecked
        jmp             CheckPlayerBulletLoop

CheckActiveBullet

        jsr             CheckPlayerBulletCollisionAtA6
        add.b           #1,d0
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #MAX_ALLOWED_BULLETS,d0
        bgt             AllPlayerBulletChecked
        jmp             CheckPlayerBulletLoop

AllPlayerBulletChecked
            
        rts
        
CheckPlayerBulletCollisionAtA6
        
        move.l          (a6),d1
        move.l          4(a6),d2
        
        lea             BossPositionAndSize,a5
        
        move.l          4(a5),d3
        sub.l           #BULLET_SIZE_HEIGHT<<8,d3
        
        cmp.l           d2,d3
        bgt             BulletDidNotCollide
        add.l           #BULLET_SIZE_HEIGHT<<8+BOSS_HEIGHT<<8,d3
        cmp.l           d2,d3
        blt             BulletDidNotCollide
        move.l          (a5),d3
        sub.l           #BULLET_SIZE_WIDTH<<8,d3
        cmp.l           d1,d3
        bgt             BulletDidNotCollide
        add.l           #BULLET_SIZE_WIDTH<<8+BOSS_WIDTH<<8,d3
        cmp.l           d1,d3
        blt             BulletDidNotCollide
        
        move.l          d0,-(sp)
        jsr             EraseBullets
        move.l          (sp)+,d0        
        
        sub.l           #PLAYER_BULLET_DAMAGE,(BossHealth)
        bclr            d0,(ActiveBullets)
        
        move.l          (BossHealth),d4
        
        move.l          d4,d3
        swap            d3
        move.b          d4,d3
        lsl.w           #8,d3
        move.b          d4,d3
        move.l          d3,(BossColor)
        
BulletDidNotCollide
        rts
        
        
CheckBossBullets

        move.l          #0,d6
        lea             BossBulletArray,a6
        
CheckBossBulletsLoop
        btst            d6,(BossBulletsActive)
        bne             ActiveBossBullet
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletChecked
        jmp             CheckBossBulletsLoop

ActiveBossBullet
            
        jsr             CheckBossBulletCollisionAtA6
        add.b           #1,d6
        add.l           #BOSS_BULLET_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_BULLETS,d6
        bgt             AllBossBulletChecked
        jmp             CheckBossBulletsLoop
        
AllBossBulletChecked
            
        rts
        
CheckBossBulletCollisionAtA6

        move.l          (a6),d1
        move.l          4(a6),d2
        
        lea             PlayerPositionAndSize,a5
        
        move.l          4(a5),d3
        sub.l           #BOSS_BULLET_HEIGHT<<8,d3
        
        cmp.l           d2,d3
        bgt             BossBulletDidNotCollide
        add.l           #BOSS_BULLET_HEIGHT<<8+PLAYER_HEIGHT<<8,d3
        cmp.l           d2,d3
        blt             BossBulletDidNotCollide
        move.l          (a5),d3
        sub.l           #BOSS_BULLET_WIDTH<<8,d3
        cmp.l           d1,d3
        bgt             BossBulletDidNotCollide
        add.l           #BOSS_BULLET_WIDTH<<8+PLAYER_WIDTH<<8,d3
        cmp.l           d1,d3
        blt             BossBulletDidNotCollide
        
        bclr            d6,(BossBulletsActive)
        
        move.l          (OldTime),d0

        cmp.l           (PlayerVulnerabilityTime),d0
        blt             BossBulletDidNotCollide
        
        add.l           #PLAYER_INVULNERABILITY_TIME,d0
        move.l          d0,(PlayerVulnerabilityTime)
        sub.l           #BOSS_SHOOT_DAMAGE,(PlayerHealth)
        
        move.l          (PlayerHealth),d4

        move.l          d4,d3
        swap            d3
        move.b          d4,d3
        lsl.w           #8,d3
        move.b          d4,d3

        move.l          d3,(PlayerColor)
    	
    	rts

BossBulletDidNotCollide
        rts
        
        
CheckBossRain

        move.l          #0,d6
        lea             BossRainArray,a6
        
CheckBossRainLoop
        btst            d6,(BossRainActive)
        bne             ActiveBossRain
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             AllBossRainChecked
        jmp             CheckBossRainLoop

ActiveBossRain
            
        jsr             CheckBossRainCollisionAtA6
        add.b           #1,d6
        add.l           #BOSS_RAIN_DATA_SIZE_IN_BYTES,a6
        cmp.b           #BOSS_MAX_RAIN,d6
        bgt             AllBossRainChecked
        jmp             CheckBossRainLoop
        
AllBossRainChecked
            
        rts
        
CheckBossRainCollisionAtA6

        move.l          (a6),d1
        move.l          4(a6),d2
        lsl.l           #8,d1
        
        lea             PlayerPositionAndSize,a5
        
        move.l          4(a5),d3
        sub.l           #DROP_SIZE,d3
        
        cmp.l           d2,d3
        bgt             BossBulletDidNotCollide
        add.l           #DROP_SIZE+PLAYER_HEIGHT<<8,d3
        cmp.l           d2,d3
        blt             BossBulletDidNotCollide
        move.l          (a5),d3
        sub.l           #DROP_SIZE,d3
        cmp.l           d1,d3
        bgt             BossBulletDidNotCollide
        add.l           #DROP_SIZE+PLAYER_WIDTH<<8,d3
        cmp.l           d1,d3
        blt             BossBulletDidNotCollide
        
        bclr            d6,(BossRainActive)
        
        move.l          (OldTime),d0

        cmp.l           (PlayerVulnerabilityTime),d0
        blt             BossBulletDidNotCollide
        
        add.l           #PLAYER_INVULNERABILITY_TIME,d0
        move.l          d0,(PlayerVulnerabilityTime)
        sub.l           #BOSS_SHOOT_DAMAGE,(PlayerHealth)
        
        move.l          (PlayerHealth),d4

        move.l          d4,d3
        swap            d3
        move.b          d4,d3
        lsl.w           #8,d3
        move.b          d4,d3

        move.l          d3,(PlayerColor)
    	
    	rts

BossRainDidNotCollide
        rts

CheckLava

        move.l          (OldTime),d0

        cmp.l           (PlayerVulnerabilityTime),d0
        blt             LavaCheckDone

        move.l          (BossLavaFillPercent),d7
        cmp.l           #100<<8,d7
        blt             LavaCheckDone
        
        move.l          #BLACK_BOX_BOTTOM_SIDE_OF_SCREEN,d6
        move.l          (BossLavaFillPercent),d7
        lsr.l           #8,d7
        sub.l           #100,d7
        sub.l           d7,d6
        
        lea             PlayerPositionAndSize,a0
        move.l          4(a0),d0
        lsr.l           #8,d0
        
        sub.l           #PLAYER_HEIGHT,d6
        
        cmp.l           d0,d6
        bgt             LavaCheckDone
        
        move.l          (OldTime),d0
        add.l           #PLAYER_INVULNERABILITY_TIME,d0
        move.l          d0,(PlayerVulnerabilityTime)
        sub.l           #BOSS_LAVA_DAMAGE,(PlayerHealth)
        
        move.l          (PlayerHealth),d4

        move.l          d4,d3
        swap            d3
        move.b          d4,d3
        lsl.w           #8,d3
        move.b          d4,d3

        move.l          d3,(PlayerColor)
        
LavaCheckDone
        rts
        
BossHealth                  dc.l  BOSS_START_HEALTH
PlayerHealth                dc.l  PLAYER_START_HEALTH
PlayerVulnerabilityTime     dc.l  0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
