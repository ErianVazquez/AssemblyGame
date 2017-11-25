
START_X_TIME_LEFT           EQU RIGHT_SIDE_OF_SCREEN-20
START_Y_TIME_LEFT           EQU 60
X_SEGMENT_OFFSET            EQU 12

DrawTimeLeft

        moveq.l         #0,d5

        move.l          #START_X_TIME_LEFT,d6
        move.l          #START_Y_TIME_LEFT,d7
        
        move.l          (TimeLeft),d0
        divu            #10,d0
        swap            d0
        move.w          d0,d5
        clr.w           d0
        swap            d0

        move.l          d5,-(sp)
        move.l          d0,-(sp)
        jsr             DrawSegment   
        move.l          (sp)+,d0  
        move.l          (sp)+,d5
        
        sub.l           #X_SEGMENT_OFFSET,d6
        
        divu            #10,d0
        swap            d0
        move.w          d0,d5
        clr.w           d0
        swap            d0

        move.l          d5,-(sp)
        move.l          d0,-(sp)
        jsr             DrawSegment   
        move.l          (sp)+,d0  
        move.l          (sp)+,d5
        
        sub.l           #X_SEGMENT_OFFSET,d6
        
        divu            #10,d0
        swap            d0
        move.w          d0,d5
        
        jsr             DrawSegment

        rts

DrawSegment     ;d5-num to draw d6-x d7-y

        moveq.l         #0,d1
        moveq.l         #0,d2
        moveq.l         #0,d3
        moveq.l         #0,d4

        moveq.l         #0,d0
        lea             SegmentBits,a0
        lea             SegmentXStart,a1
        lea             SegmentYStart,a2
        lea             SegmentXEnd,a3
        lea             SegmentYEnd,a4

        move.b          (a0,d5),d5
                
FindActiveSegmentsLoop
        btst            d0,d5
        bne             ActiveSegmentFound
        add.b           #1,d0
        cmp.b           #7,d0
        bgt             AllSegmentsUpdated
        jmp             FindActiveSegmentsLoop

ActiveSegmentFound
        move.l          d0,-(sp)
        jsr             DrawActiveSegment
        move.l          (sp)+,d0
        add.b           #1,d0
        cmp.b           #7,d0
        bgt             AllSegmentsUpdated
        jmp             FindActiveSegmentsLoop

AllSegmentsUpdated
        rts
        
DrawActiveSegment

        move.l	        #WHITE,d1
	    move.b	        #SET_PEN_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15
	    

        moveq.l         #0,d1
        moveq.l         #0,d2   
        moveq.l         #0,d3
        moveq.l         #0,d4

        move.l          d6,d1
        move.l          d7,d2
        move.l          d6,d3
        move.l          d7,d4        

        move.l          4(sp),d0

        add.b           (a1,d0),d1
        add.b           (a2,d0),d2
        add.b           (a3,d0),d3
        add.b           (a4,d0),d4
        
        move.b	        #DRAW_RECT_COMMAND,d0
        trap	        #15
        
        rts
        
ClearSegments

        move.l	        #$00FF0000,d1
	    move.b	        #SET_PEN_COLOR_COMMAND,d0
	    trap	        #15
	    move.b	        #SET_FILL_COLOR_COMMAND,d0
	    trap	        #15
	    
	    move.b	        #DRAW_RECT_COMMAND,d0

        move.l          #START_X_TIME_LEFT-3*X_SEGMENT_OFFSET+5,d1
        move.l          #START_Y_TIME_LEFT,d2
        move.l          #START_X_TIME_LEFT-3*X_SEGMENT_OFFSET+5+40,d3
        move.l          #START_Y_TIME_LEFT+12,d4
        
        trap	        #15
        
        rts
        
CalculateTimeLeft
         
        move.l          (EndTime),d0
        sub.l           (OldTime),d0
        divu            #100,d0
        swap            d0
        clr.w           d0
        swap            d0
        move.l          d0,(TimeLeft)

        rts       
        
SegmentBits         dc.b $3F,$06,$5B,$4f,$66,$6D,$7D,$07,$7F,$67

SegmentXStart       dc.b -4,5,5,4,-5,-5,-4
SegmentYStart       dc.b -5,-1,4,5,1,-4,0

SegmentXEnd         dc.b 4,5,5,-4,-5,-5,4
SegmentYEnd         dc.b -5,-4,1,5,4,-1,0







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
