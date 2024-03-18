
org 100h 
cpu 186 

segment .data



          GAME_ACTIVE DB 1  ; bool of the game

          GAMEOVER DB 'GAME OVER', '$'

          WINNER DB 'WINNER: PLAYER ', '$'

          WINNER_INDEX DB 0

          WINNER_INDEX_TXT DB '0', '$'

          PLAY_AGAIN DB 'R - PLAY AGAIN', '$'

          EXIT_MM DB 'E - MAIN MENU','$'

          CREDITS DB 'MADE BY: DOSPIIR - NASM x86', '$'

          CURRENT_SCENE DB 0

          WELCOME DB 'WELCOME TO: PONG GAME', '$'

          SINGLE DB '1 - SINGLEPLAYER (COMING SOON)', '$'

          MULTI DB '2 - MULTIPLAYER', '$'

          OPTIONS DB '3 - OPTION (COMING SOON)', '$'
          
          BALL_OPTIONSTR DB '1 - BALL OPTIONS', '$'
          
          COLORSTR DB 'COLOR: 1- WHITE  2- RED  3- GREEN', '$'
          
          SPEEDSTR DB 'SPEED: 4- LOW  5- MEDIUM  6- HIGH', '$'
          
          PAD_OPTIONSTR DB '2 - PADDLES OPTION', '$'
          
          PAD1_OPSTR DB '1 - PLAYER 1 (RIGHT)', '$'
          
          PAD2_OPSTR DB '2 - PLAYER 2 (LEFT)', '$'



          TIME DB 0

          

          SCREEN_WIDTH DW 136h

          SCREEN_HEIGHT DW 0C3h

          BALL_X DW 160

          BALL_Y DW 100

          BALL_SIZE DW 4

          VELOC_X DW 06h

          VELOC_Y DW 02h
          
          BALL_COLOR DW 0Fh
          
          PAD1_COLOR DW 0Fh
          
          PAD2_COLOR DW 0Fh

          

          PSIZE DW 4 ; paddle size

          PHEIGHT DW 35

          

          RP_X DW 10

          RP_Y DW 10

          RP_POINTS DB 0

          RP_PTS_TXT DB '0', '$'

          

          LP_X DW 306

          LP_Y DW 10

          LP_POINTS DB 0

          LP_PTS_TXT DB '0', '$'

          

          PADDLE_VELOC DW 05h

          

          ;boxColliders

          ;ball :

          

          MAXX1 DW 0           ; maxx1 = ball_x + 4 

          MAXY1 DW 0           ; maxy1 = ball_y

          MINX1 DW 0           ; minx1 = ball_x

          MINY1 DW 0          ; miny1 = ball_y + 4

       

       ; paddles : 

       

          MAXX2 DW 0   ; maxx2 = RP/LP_X + 4   

          

         



segment .text

    global main

    

 %MACRO DrawBall 0 

    

        MOV CX, word [BALL_X]

        MOV DX, word [BALL_Y]

    

    CBH :  

    MOV AH, 0Ch

    MOV AL, [BALL_COLOR]

    MOV BH, 00h

    INT 10h

    INC CX

    MOV AX, CX

    SUB AX, word [BALL_X]

    CMP AX, [BALL_SIZE]

    JNG CBH ; CBH = create horizontal ball

    MOV CX, word [BALL_X]

    INC DX

    MOV AX, DX

    SUB AX, word [BALL_Y]

    CMP AX, word [BALL_SIZE]

    JNG CBH

    

 %ENDMACRO





 %MACRO clearScreen 0

    

    MOV AH, 00h

    MOV Al, 13h

    INT 10h

    

    MOV AH, 0Bh

    MOV BH, 00h

    MOV BL, 0h

    INT 10h

    

 %ENDMACRO

 

 %MACRO MOVEBALL 0 

 

    MOV AX, [VELOC_X]

    SUB word [BALL_X], AX

    MOV AX, [VELOC_Y]

    SUB word [BALL_Y], AX

    

        ; collision : if (X < 0 || X > WIDTH) => X = -X

        ; collision : if (Y < 0 || Y > HEIGHT) => Y = -Y

        ; kol maytkhbat lfo9 wla ta7t = -Y

        ; kol maytkhbat a cote = -X

      

        ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny1 && miny1 < maxy2

        

        MOV AX, word [BALL_X]

        ADD AX, 4

        CMP AX, word [RP_X]

        JL nn

        MOV AX, word [RP_X]

        ADD AX, 4

        MOV word [MAXX2], AX

        MOV AX, word [BALL_X]

        CMP AX, word [MAXX2] ; RP_X + PADDLE SIZE (4)

        JG nn

        MOV AX, word [BALL_Y]

        ADD AX, 4

        CMP AX, word [RP_Y]

        JL nn

        MOV AX, word [RP_Y]

        ADD AX, 30

        CMP word [BALL_Y], AX

        JG nn

        

        NEG word [VELOC_X]

        

         nn :

        MOV AX, word [BALL_X]

        ADD AX, 4

        CMP AX, word [LP_X]

        JL EXI

        MOV AX, word [LP_X]

        ADD AX, 4

        CMP word [BALL_X], AX

        JG EXI

        MOV AX, word [BALL_Y]

        ADD AX, 4

        CMP AX, word [LP_Y]

        JL EXI

        MOV AX, word [LP_Y]

        ADD AX, 30

        CMP word [BALL_Y], AX

        JG EXI

        NEG word [VELOC_X]

      

      EXI :

        

        MOV AX, word [BALL_X] 

        CMP AX, 3

        

        

        JL ADDTO_LP

        CMP AX, word [SCREEN_WIDTH]

        

        JG ADDTO_RP

        

        MOV AX, word [BALL_Y]

        CMP AX, 2

        JL NEG_Y

        CMP AX, word [SCREEN_HEIGHT]

        JG NEG_Y

        

        JMP emchi

        

        NEG_X : 

        NEG word [VELOC_X]

        JMP emchi 

        

        NEG_Y : 

        NEG word [VELOC_Y]

        JMP emchi

        

        ADDTO_LP : 

        INC byte [LP_POINTS]

        MOV AL, byte [LP_POINTS]

        ADD AL, 30h 

        MOV byte [LP_PTS_TXT], AL

        JMP REST

        

        ADDTO_RP :

        INC byte [RP_POINTS]

        MOV AL, byte [RP_POINTS]

        ADD AL, 30h 

        MOV byte [RP_PTS_TXT], AL

        JMP REST

        

        REST : 

        MOV word [BALL_X], 160

        MOV word [BALL_Y], 100

        

       CMP byte [LP_POINTS], 3

       JE GAME_OVER_1

       CMP byte [RP_POINTS], 3

       JE GAME_OVER_2

       JMP emchi

       

       GAME_OVER_1 : 

        MOV byte [WINNER_INDEX], 1

        MOV byte [RP_POINTS], 0

        MOV byte [LP_POINTS], 0

        MOV AL, 0

        ADD AL, 30h 

        MOV byte [RP_PTS_TXT], AL

        MOV byte [LP_PTS_TXT], AL

        MOV byte [GAME_ACTIVE], 0

        JMP emchi 

        

        GAME_OVER_2 : 

        MOV byte [WINNER_INDEX], 2

        MOV byte [RP_POINTS], 0

        MOV byte [LP_POINTS], 0

        MOV AL, 0

        ADD AL, 30h 

        MOV byte [RP_PTS_TXT], AL

        MOV byte [LP_PTS_TXT], AL

        MOV byte [GAME_ACTIVE], 0

       

    emchi :

 

 %ENDMACRO

 

 %MACRO RIGHTPADDLE 0

 

       MOV CX, word [RP_X]

        MOV DX, word [RP_Y]

    

    

    MOV AH, 0Ch

    MOV AL, [PAD2_COLOR]

    MOV BH, 00h

    INT 10h

   

 cnt :  

    MOV AH, 0Ch

    MOV AL, [PAD2_COLOR]

    MOV BH, 00h

    INT 10h

    INC CX

    MOV AX, CX

    SUB AX, word [RP_X]

    CMP AX, [PSIZE]

    JNG cnt ; cnt = continue

    MOV CX, word [RP_X]

    INC DX

    MOV AX, DX

    SUB AX, word [RP_Y]

    CMP AX, word [PHEIGHT]

    JNG cnt

 

 %ENDMACRO

 

 

  %MACRO LEFTPADDLE 0

 

        MOV CX, word [LP_X]

        MOV DX, word [LP_Y]

    

    

    MOV AH, 0Ch

    MOV AL, [PAD1_COLOR]

    MOV BH, 00h

    INT 10h

   

 cnt1 :  

    MOV AH, 0Ch

    MOV AL, [PAD1_COLOR]

    MOV BH, 00h

    INT 10h

    INC CX

    MOV AX, CX

    SUB AX, word [LP_X]

    CMP AX, [PSIZE]

    JNG cnt1 ; cnt = continue

    MOV CX, word [LP_X]

    INC DX

    MOV AX, DX

    SUB AX, word [LP_Y]

    CMP AX, word [PHEIGHT]

    JNG cnt1

 

 %ENDMACRO

 

 

 %MACRO DRAWPADDLES 0 

  RIGHTPADDLE

  LEFTPADDLE

 %ENDMACRO

 

 %MACRO MOVEPADDLES 0

 

     MOV AH, 01h

     INT 16h

     JZ leav

     

     MOV AH, 00h

     INT 16h
     
     
     CMP byte [CURRENT_SCENE], 4
     JE CHECKRIGHTPADDLE

     

     CMP AL, 4Fh                  

     JE MOVEUPL

     CMP AL, 6Fh

     JE MOVEUPL

    

     CMP AL, 4Ch

     JE MOVEDOWNL

     CMP AL, 6Ch

     JE MOVEDOWNL

     JMP CHECKRIGHTPADDLE

     

     MOVEUPL : 

      MOV AX, word [PADDLE_VELOC]

      SUB word [LP_Y], AX

     

     JMP CHECKRIGHTPADDLE

     

     MOVEDOWNL : 

      MOV AX, word [PADDLE_VELOC]

      ADD word [LP_Y], AX

     

     JMP CHECKRIGHTPADDLE

     

     CHECKRIGHTPADDLE : 

     

     CMP AL, 77h 

     JE MOVEUPR

     CMP AL, 57h 

     JE MOVEUPR

    

     CMP AL, 73h 

     JE MOVEDOWNR

     CMP AL, 53h

     JE MOVEDOWNR

     

     JMP leav

     

      MOVEUPR : 

      MOV AX, word [PADDLE_VELOC]

      SUB word [RP_Y], AX

     

     JMP leav

     

     MOVEDOWNR : 

      MOV AX, word [PADDLE_VELOC]

      ADD word [RP_Y], AX

     

     JMP leav

     leav :

     

 

 

 %ENDMACRO 





  %MACRO COLLIDE 0 

        

                   ; Y ta3 lkora ykon fi majal l paddle: RP_Y < BALL_Y < RP_Y + 35 (PADDLE HEIGHT)

                   ; X ta3 lkora = X ta3 paddle: RP_X = BALL_X

                   

      MOV AX, word [RP_X] 

      CMP word [BALL_X], AX

      JE CHECK_HEIGHT

      JMP LEV

      

      CHECK_HEIGHT :

      

     MOV AX, word [BALL_Y]

     CMP AX, word [RP_Y]

     JL LEV

     MOV AX, [RP_Y]

     SUB AX, 35 ; paddle height

     CMP word [BALL_Y], AX

     JG LEV

     NEG word [VELOC_X]

     

     LEV :

                     

  

  %ENDMACRO

  

  

  %MACRO UI 0

  

  

  MOV AH, 02h

  MOV BH, 00h

  MOV DH, 02h

  MOV DL, 10h

  INT 10h

  

  MOV AH, 09h

  LEA DX, RP_PTS_TXT

  INT 21h

  

  MOV AH, 02h

  MOV BH, 00h

  MOV DH, 02h

  MOV DL, 15h

  INT 10h

  

  MOV AH, 09h

  LEA DX, LP_PTS_TXT

  INT 21h

  

  

  

  %ENDMACRO 

  

  %MACRO OVERMENU 0

  

          ; CLEAR  THE SCREEN

    MOV AH, 00h

    MOV Al, 13h

    INT 10h

    

    MOV AH, 0Bh

    MOV BH, 00h

    MOV BL, 0h

    INT 10h

    

    ; DISPLAY GAME OVER

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 11

     MOV DL, 15

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [GAMEOVER]

     INT 21h

    

     

     ; WINNER IS :

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 13

     MOV DL, 12

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [WINNER]

     INT 21h

     

     ;winner index 

     

     

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 13

     MOV DL, 27

     INT 10h

     

     MOV AL,  byte [WINNER_INDEX]

     ADD AL, 30h 

     MOV byte [WINNER_INDEX_TXT], AL

  

     MOV AH, 09h

     LEA DX, WINNER_INDEX_TXT

     INT 21h

     

     

     

     ; press R 

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 21

     MOV DL, 13

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [PLAY_AGAIN]

     INT 21h

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 23

     MOV DL, 13

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [EXIT_MM]

     INT 21h

      



ask : 

     MOV AH, 00h

     INT 16h

     

     CMP AL, 'r'

     JE replay

     CMP AL, 'R'

     JE replay

     CMP AL, 'e'

     JE MM

     CMP AL, 'E'

     JE MM

     JMP ask

     

     replay : 

     MOV byte [GAME_ACTIVE], 1

     JMP kml

     

     MM : 

     MOV byte [CURRENT_SCENE], 0

     

     kml :

    

  

  

  %ENDMACRO

  

  %MACRO MAINMENU 0 

  

     MOV AH, 00h

     MOV Al, 13h

     INT 10h

     

      

     MOV AH, 0Bh

     MOV BH, 00h

     MOV BL, 0h

     INT 10h

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 6

     MOV DL, 9

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [WELCOME]

     INT 21h

     

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 12

     MOV DL, 5

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [SINGLE]

     INT 21h

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 14

     MOV DL, 11

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [MULTI]

     INT 21h

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 16

     MOV DL, 7

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [OPTIONS]

     INT 21h

     

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 24

     MOV DL, 6

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [CREDITS]

     INT 21h

     

     ask1 : 

     MOV AH, 00h

     INT 16h

     
     CMP AL, '1'
     
     JE playsingle
     
     CMP AL, '2'

     JE play

     CMP AL, '3'

     JE opt

     JMP ask1

     
     playsingle : 
     
     MOV byte [CURRENT_SCENE], 4
     MOV byte [GAME_ACTIVE], 1
     JMP ccc
     
     play : 

     MOV byte [CURRENT_SCENE], 1

     MOV byte [GAME_ACTIVE], 1
     
     JMP ccc

     opt : 
     MOV byte [CURRENT_SCENE], 2
     
     ccc:
  

  

  %ENDMACRO

  
%MACRO OPTS 0 

 ;CS 
  MOV AH, 00h

    MOV Al, 13h

    INT 10h

    

    MOV AH, 0Bh

    MOV BH, 00h

    MOV BL, 0h

    INT 10h
    
    
    ; DISPLAY GAME OVER (testing purpose)

     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 10

     MOV DL, 12

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [BALL_OPTIONSTR]

     INT 21h
     
     
     
     MOV AH, 02h

     MOV BH, 00h

     MOV DH, 13

     MOV DL, 11

     INT 10h

  

     MOV AH, 09h

     LEA DX, byte [PAD_OPTIONSTR]

     INT 21h
     
     
     askkk : 
    
     MOV AH, 00h
     INT 16h
     CMP AL, '1'
     JE ballop
     CMP AL, '2'
     JE padop
     JNE askkk
     
     ballop : 
     
    ;CS 
    MOV AH, 00h
    MOV Al, 13h
    INT 10h 

    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 0h
    INT 10h
    
    ;DISPLAY BALL OPTIONS
     
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 10
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [COLORSTR]
     INT 21h
     
      
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 13
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [SPEEDSTR]
     INT 21h
     
     askballop :
     MOV AH, 00h
     INT 16h
     CMP AL, '1'
     JNE next
     MOV word [BALL_COLOR], 0Fh
     next:
     CMP AL, '2'
     JNE next1
     MOV word [BALL_COLOR], 04h
     next1:
     CMP AL, '3'
     JNE next2
     MOV word [BALL_COLOR], 02h
     next2:
     CMP AL, '4'
     CMP AL, '5'
     CMP AL, '6'
     JNE quiti
     
     padop :
     
     ;CS 
    MOV AH, 00h
    MOV Al, 13h
    INT 10h 

    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 0h
    INT 10h
    
    ;DISPLAY PAD OPTIONS
     
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 10
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [PAD1_OPSTR]
     INT 21h
     
      
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 13
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [PAD2_OPSTR]
     INT 21h
     
     ag:
     MOV AH, 00h
     INT 16h
     CMP AL, '1'
     JE pad1op
     CMP AL, '2'
     JE pad2op
     JNE ag
     
     pad1op :
     ;CS 
    MOV AH, 00h
    MOV Al, 13h
    INT 10h 

    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 0h
    INT 10h
    
    ;DISPLAY BALL OPTIONS
     
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 10
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [COLORSTR]
     INT 21h
     
      
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 13
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [SPEEDSTR]
     INT 21h
     
     
     MOV AH, 00h
     INT 16h
     CMP AL, '1'
     JNE nex
     MOV word [PAD1_COLOR], 0Fh
     nex:
     CMP AL, '2'
     JNE next1
     MOV word [PAD1_COLOR], 04h
     nex1:
     CMP AL, '3'
     JNE nex2
     MOV word [PAD1_COLOR], 02h
     nex2:
     CMP AL, '4'
     CMP AL, '5'
     CMP AL, '6'
     JNE quiti
     
     pad2op :
     ;CS 
    MOV AH, 00h
    MOV Al, 13h
    INT 10h 

    MOV AH, 0Bh
    MOV BH, 00h
    MOV BL, 0h
    INT 10h
    
    ;DISPLAY BALL OPTIONS
     
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 10
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [COLORSTR]
     INT 21h
     
      
     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 13
     MOV DL, 3
     INT 10h

     MOV AH, 09h
     LEA DX, byte [SPEEDSTR]
     INT 21h
     
     
     MOV AH, 00h
     INT 16h
     CMP AL, '1'
     JNE nextt
     MOV word [PAD2_COLOR], 0Fh
     nextt:
     CMP AL, '2'
     JNE nextt1
     MOV word [PAD2_COLOR], 04h
     nextt1:
     CMP AL, '3'
     JNE nextt2
     MOV word [PAD2_COLOR], 02h
     nextt2:
     CMP AL, '4'
     CMP AL, '5'
     CMP AL, '6'
     JNE quiti
     
     quiti:
     MOV byte [CURRENT_SCENE], 0


%ENDMACRO
  
  
  %MACRO AUTOPAD 0 
  
  
      MOV AX, word [BALL_Y]
      
      INC AX

      MOV word [LP_Y], AX
      
      
      MOV AH, 01h

     INT 16h

     JZ leav9

     

     MOV AH, 00h

     INT 16h
      
      
      
      CMP AL, 77h 

     JE MOVEUPR9

     CMP AL, 57h 

     JE MOVEUPR9

    

     CMP AL, 73h 

     JE MOVEDOWNR9

     CMP AL, 53h

     JE MOVEDOWNR9

     

     JMP leav9

     

      MOVEUPR9 : 

      MOV AX, word [PADDLE_VELOC]

      SUB word [RP_Y], AX

     

     JMP leav9

     

     MOVEDOWNR9 : 

      MOV AX, word [PADDLE_VELOC]

      ADD word [RP_Y], AX

     

     JMP leav9

     leav9 :

  
  
  
  %ENDMACRO

  

main:



       

    clearScreen

    

    

    checkTime : 

    CMP byte [CURRENT_SCENE], 0

    JE SHOW_MAIN_MENU
    
    CMP byte [CURRENT_SCENE], 2
    
    JE SHOWOPP

    CMP byte [GAME_ACTIVE], 0

    JNE yes

    OVERMENU

    yes :

    MOV AH, 2Ch

    INT 21h

    CMP DL, byte [TIME]

    JE checkTime

    MOV byte [TIME], DL

    

    

    

    

    clearScreen

    COLLIDE
    
    CMP byte [CURRENT_SCENE] , 4
    JNE multip
    AUTOPAD
    JMP singp


    multip:
    MOVEPADDLES
    
    singp :

    MOVEBALL

    

    DrawBall

    

    DRAWPADDLES

    UI

    

    

    JMP checkTime

    

    SHOW_MAIN_MENU : 

    MAINMENU

    JMP checkTime
 
    SHOWOPP :
    OPTS
    JMP checkTime
    
   



    

    lp : 

    jmp lp

    

    

    



  

 

 

