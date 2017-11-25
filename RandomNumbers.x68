GET_TIME_COMMAND        equ     8

seedRandomNumber
        movem.l ALL_REG,-(sp)
        clr.l   d6
        move.b  #GET_TIME_COMMAND,d0
        TRAP    #15

        move.l  d1,RANDOMVAL
        movem.l (sp)+,ALL_REG
        rts

getRandomByteIntoD6
        movem.l d0,-(sp)
        movem.l d1,-(sp)
        movem.l d2,-(sp)
        move.l  RANDOMVAL,d0
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
Ninc0	
	add.l	d0,d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2,Ninc0
	
	move.l	d0,RANDOMVAL
	clr.l	d6
	move.b	d0,d6
	
        movem.l (sp)+,d2
        movem.l (sp)+,d1
        movem.l (sp)+,d0
        rts
        

getRandomLongIntoD6
        movem.l ALL_REG,-(sp)
        jsr     getRandomByteIntoD6
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        jsr     getRandomByteIntoD6
        lsl.l   #8,d5
        move.b  d6,d5
        move.l  d5,TEMPRANDOMLONG
        movem.l (sp)+,ALL_REG
        move.l  TEMPRANDOMLONG,d6
        rts


RANDOMVAL       ds.l    1
TEMPRANDOMLONG  ds.l    1

        END     START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
