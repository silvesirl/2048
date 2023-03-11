section .data               
;Change Name and Surname for your data.
developer db "Silvestre Lopez",0

;Constant that is also defined in C.
DimMatrix    equ 4 
SizeMatrix   equ (DimMatrix*DimMatrix) ;=16 

section .text            

;Variables defined in Assembly language.
global developer                        

;Assembly language subroutines called from C.
global showNumberP2, updateBoardP2, copyMatrixP2,
global rotateMatrixRP2, shiftNumbersRP2, addPairsRP2
global readKeyP2, checkEndP2, playP2

;Global variables defined in C.
extern m, mRotated, mAux, mUndo, state

;C functions that are called from assembly code.
extern clearScreen_C,  gotoxyP2_C, getchP2_C, printchP2_C
extern printBoardP2_C, printMessageP2_C, insertTileP2_C   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATTENTION: Remember that in assembly language the variables and parameters 
;; of type 'char' must be assigned to records of type
;; BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;; those of type 'short' must be assigned to records of type
;; WORD (2 bytes): ax, bx, cx, dx, si, di, ...., r15w
;; those of type 'int' must be assigned to records of type
;; DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;; those of type 'long' must be assigned to records of type
;; QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; The assembly subroutines you need to modify to implement pass parameter are:
;;   showNumberP2, updateBoardP2, copyMatrixP2, 
;;   rotateMatrixRP2, shiftNumbersRP2, addPairsRP2
;; The assembly subroutine you need to implement is:
;;   checkEndP2
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Place the cursor at a position on the screen.  
; 
; Global variables :	
; None
; 
; Input parameters : 
; rdi(edi): (rowScReen) : Row of the screen where the cursor is placed.
; rsi(esi): (colScreen) :  Column of the screen where the cursor is placed.
; 
; Output parameters: 
; None
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxyP2:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; When we call the gotoxyP2_C function (int rowScreen, int colScreen) from assembly language
   ; the first parameter (rowScreen) must be passed through the rdi (edi) register, and
   ; the second parameter (colScreen) must be passed through the rsi (esi) register.
   call gotoxyP2_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Show a character on the screen at the cursor position.
; 
; Global variables :	
; None
; 
; Input parameters : 
; rdi(dil): (c):  Character to show.
; 
; Output parameters: 
; None
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchP2:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; When we call the printchP2_C (char c) function from assembly language,
   ; parameter (c) must be passed through the rdi (dil) register.
   call printchP2_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Read a character from the keyboard without displaying it 
; on the screen and return it.
; 
; Global variables :	
; None
; 
; Input parameters : 
; None
; 
; Output parameters: 
; rax(al) : (c): Character read from the keyboard.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchP2:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15
   push rbp
   
   mov rax, 0
   ; When we call the getchP2_C function from assembly language
   ; return over the rax(al) register the read character.
   call getchP2_C

   pop rbp
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   
   mov rsp, rbp
   pop rbp
   ret 


;;;;;
; Converts the number of 6 digits (n <= 999999) stored in the short 
; type variable (n), recived as a parameter, to ASCII characters 
; representing its value.
; If (n) is greater than 999999 we will change the value to 999999.
; The value must be divided (/) by 10, iteratively, 
; until the 6 digits are obtained.
; At each iteration, the remainder of the division (%) which is a value
; between (0-9) indicates the value of the digit to be converted to 
; ASCII ('0' - '9') by adding '0' ( 48 decimal) to be able to display it.
; When the quotient is 0 we will show spaces in the non-significant part.
; For example, if number=103 we will show "103" and not "000103".
; The digits (ASCII character) must be displayed from the position 
; indicated by the variables (rowScreen) and (colScreen), position 
; of the units, to the left.
; The first digit we get is the units, then the tens, ..., to display the
; value the cursor must be moved one position to the left in each iteration.
; To place the cursor call the gotoxyP2 subroutine and to display the 
; characters call the printchP2 subroutine .
; 
; Global variables :	
; None
; 
; Input parameters : 
; rdi(edi): (rScreen): Row to place the cursor on the screen.
; rsi(esi): (cScreen): Column to place the cursor on the screen.
; rdx(edx): (n)      : Number to show.
; 
; Output parameters : 
; None
;;;;;
showNumberP2:
	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp
	
	mov r11, 0
	mov rax, rdx
	cmp rdx, 999999; ; here wi will check if the score is bigger than 6 digits, if is is it will reajust to 999999
	jg fixNumberP2
	jmp forShowP2
	
	fixNumberP2: ; reajust number if needed
		mov rdx, 999999
		jmp forShowP2
	
	forShowP2:
		cmp r11, 5 ; we only go to 6 digits, no more
		jg endShowNumberP2
		jmp positiveNumberP2
	
	positiveNumberP2:
		call gotoxyP2
		push rdi
		mov dil, ' '
		cmp rax, 0
		jle printP2
		mov rdx, 0
		mov rcx, 10 	
		div rcx         ; we will divide the score by 10, the coicient will be saved in rdx
		mov dil, dl
		add dil,'0'
		jmp printP2		; we will print the coicient
		
	printP2:
		call printchP2		; we call print and load rdi, rsi and increase r11
		pop rdi
		dec rsi
		inc r11
		jmp forShowP2
			
	endShowNumberP2:	
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 


;;;;;
; Update the contents of the Game Board with the data from the 4x4 
; matrix (m) of type short and the scored points (scr), recived as a parameter.
; Go thorugt the entire matrix(m), and for each element of the matrix
; place the cursor on the screen and show the number of that position.
; Go through the entire matrix by rows from left to right and from top to bottom.
; To go through a matrix in assembler the index goes from 0 
; (position [0][0]) to 30 (position [3][3]) with increments of 2 
; because data is short type (WORD) 2 bytes.
; Then, show the scoreboard (scr) at the bottom of the board, 
; row 18, column 26 by calling the showNumberP2 subroutine.
; Finally place the cursor in row 18, column 28 by calling 
; the gotoxyP2 subroutine.
; 
; Global variables :
; (m): Matrix where we have the numbers of the game.
; 
; Input parameters : 
; rdi(edi): (scr): Scored points on the scoreboard.
; 
; Output parameters : 
; None
;;;;;  
updateBoardP2:
	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp
	mov r11, 0
	mov r12, 0
	mov rdi, 10 ; row
	mov rsi, 17 ; column
	mov rbp, rsp
	
	forInColumnP2:
		cmp r11,6
		jg forInRowP2
		
		movzx ecx, WORD[m+r11+r12]	; we get the number in the corrent position in m by row and column
		
		mov edx, ecx ; we pass the result in edx
		
		push rdx ; we save this fucntions
		push rdi
		push rsi
		push r11
		push rax

		call showNumberP2	; call show
		
		pop rax
		pop r11
		pop rsi
		pop rdi ; we load the function back in
		pop rdx

		add rsi, 9	;next column
		mov edx, ecx
		add r11, 2
		jmp forInColumnP2
	
	forInRowP2:
		mov rsi, 17 ; reset column
		add rdi, 2; next row
		mov r11, 0
		add r12, 8 
		cmp r12, 24 ; if r12 is higher than 24 the function will end
		jg endUpdateP2
		jmp forInColumnP2
		
	endUpdateP2:
		
		mov rdx, rax ; we get the score back to rax and reset rsi to 26 and rdi to 18 for getting the position of the score ready
		mov edi, 18
		mov esi, 26
		
		call showNumberP2  ;we call the show number on the position of the score
		mov edi, 18
		mov esi, 26 ; we reset the position of the score becaouse on the function show has been altered
		
		call gotoxyP2 ; we get the curson in this position
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 


;;;;;  
; Copy the values stored in the (mOrig) matrix, recived as a parameter,
; to the (mDest) matrix, recived as a parameter. The (mRotated) matrix 
; should not be modified, changes should be made to the (m) matrix.
; Go through the entire matrix by rows from left to right and from top to bottom.
; To go through a matrix in assembly language the index goes from 0 
; ([0][0] position) to 30 ([3][3] position) with increments of 2 because
; data is short type (WORD), 2 bytes.
; This will allow to copy two matrixs after a rotation
; and handle the '(u)Undo' option.
; Do not show the matrix.
; 
; Global variables :
; None
; 
; Input parameters : 
; rdi(rdi): (mDest)  : Matrix Address where we have the numbers we want to overwrite.
; rsi(rsi): (mOrigin): Matrix address where we have the numbers of the game.
; 
; Output parameters : 
; None.
;;;;;  
copyMatrixP2:

	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp

	mov r11, 0 ; this will be the column
	mov r12, 0 ; this will be the row
	
	forInColumnCopyP2:
		cmp r11, 6
		jg forInRowCopyP2 ; if the column is higher than 6 we will jump row
		
		push r11 ;save r11
		add r11,r12 ; we add to the column the row
		
		mov cx, WORD[esi+r11d] ;we get the result of moriginin the current position of row and column
		mov WORD[edi+r11d], cx ; in the same position, we save the cx into m destiny
		pop r11
		add r11, 2 ; we add 2 to the column
		jmp forInColumnCopyP2 ;return to the for in column
		
	forInRowCopyP2:
		add r12, 8 ; next row
		mov r11, 0 ; reset column
		cmp r12, 24 ; if the row is higher than 24 we will end the function, it means we went from all the positions in the matrix
		jg endCopyP2
		jmp forInColumnCopyP2
		
	endCopyP2: ; end
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 

;;;;;      
; Rotate the matrix (mToRotate), recived as a parameter, to the right 
; over the matrix (mRotated).
; The first row becomes the fourth column, the second row becomes 
; the third column, the third row becomes the second column, 
; and the fourth row becomes the first column.
; In the .pdf file there are a detailed explanation how to do the rotation.
; NOTE: This is NOT the same as transpose the matrix.
; The matrix (mToRotate) should not be modified, changes should be made
; to the (mRotated) matrix.
; To go through a matrix in assembly language the index goes from 0 
; (position [0][0]) to 30 (position [3][3]) with increments of 2 
; because the data is short type (WORD), 2 bytes.
; To access a specific position of a matrix in assembly language, 
; you must take into account that the index is:
; (index=(row*DimMatrix+column)*2),
; we multiply by 2 because the data is short type (WORD), 2 bytes.
; Once the rotation has been done, copy the (mRotated) matrix  over the
; matrix recived as a parameter by calling the copyMatrixP2 subroutine.
; The matrix should not be displayed.
; 
; Global variables :
; (mRotated) : Matrix where we have the numbers of the game.
; 
; Input parameters : 
; rdi(rdi): (mToRotate): Matrix address where we have the numbers of the game rotated to the right.
; 
; Output parameters : 
; None
;;;;;  
rotateMatrixRP2:
	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp
	mov r9, 6 ; this six added to the column and row will give is the oposite location if the current one, in every jump in row this will be subtracted by 10
	mov r10, r9
	mov r11, 0 ; this will be the column
	mov r12, 0 ; this will be the row
	
	forInColumnRotateP2:
		cmp r11, 6 ; if the column is bigger than 6, we will jump a row
		jg forInRowRotateP2
		push r11
		add r11, r12
		mov bx, [edi+r11d] ; we get the result on the current position
		
		push r10
		add r10, r11
		mov WORD[mRotated+r10d], bx ; here we copy the result prevously got and we put in the the mrotated matrix in nthe oposite location
		pop r10
		pop r11
		
		add r10, 6 ; in every jump in column we will add 6 to the r10
		add r11, 2 ; next column
		jmp forInColumnRotateP2
	
	forInRowRotateP2:
		add r12, 8 ; next row
		sub r9, 10 ; add 10 tot he r9 for the algoright to getting the opposite position works as intended
		mov r10, r9
		mov r11, 0 ; reset column
		cmp r12, 24 ; if the row is higher than 24 we will end the function, it means we went from all the positions in the matrix
		jg endRotationP2
		jmp forInColumnRotateP2
		
	endRotationP2:
		mov esi, mRotated
		call copyMatrixP2
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 


;;;;;  
; Shift right the numbers in each row of the matrix (mShift),
; recived as a parameter, keeping the order of the numbers and moving 
; the zeros to the left.
; Go through the matrix by rows from right to left and bottom to top.
; To go through a matrix in assembly language, in this case, the index 
; goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
; of 2 because the data is short type (WORD), 2 bytes.
; To access a specific position of a matrix in assembly language, 
; you must take into account that the index is:
; (index=(row*DimMatrix+column)*2),
; we multiply by 2 because the data is short type (WORD), 2 bytes.
; If a number is moved (NOT THE ZEROS) the shifts must be counted by 
; increasing the variable (shifts).
; In each row, if a 0 is found, check if there is a non-zero number 
; in the same row to move it to that position.
; If a row of the matrix is: [0,2,0,4] and (shifts=0), 
; it will be [0,0,2,4] and (shifts=2).
; Changes must be made on the same matrix.
; The matrix should not be displayed.
; 
; Global variables :
; None
; 
; Input parameters : 
; rdi(edi): (mShift): Matrix address where we have the numbers of the game to shift.
; 
; Output parameters : 
; rax(eax): (shifts): Shifts that have been made.
;;;;;  
shiftNumbersRP2:
	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp
	mov rbx, 0
	mov r10, 24 ; this will be our i
	mov r11, 6; this will be our J
	mov r12, 0 ; this will be our k
	mov r13, 0 ; this will be the shift made, after everything is done we will give the result to rax
	jmp shiftNumbersBeginP2
   
	shiftNumbersBeginP2:
		cmp r10, 0
		jl endShiftP2
		jmp shiftCheckColumnP2
	
	shiftCheckColumnP2:
		cmp r11, 0
		jl increaseIShiftP2
		jmp saveDataShiftP2
	
		saveDataShiftP2: ; first if
			push r10 
			add r10, r11
			mov ax, [edi+r10d] ;if (m[i][j] == 0)
			pop r10 
			cmp rax, 0
			jle checkKP2
			jmp increaseJShiftP2
		
		checkKP2:	; if correct, we decrease k and continue to the while
			mov r12, r11
			sub r12, 2 ;k = j-1;
			jmp whileShiftP2   
		
		whileShiftP2:  ;first condition of the while, if is correct we check the second condition, if not we exit the while
			cmp r12, 0
			jge secondConditionShiftP2
			jmp outsideWhileShiftP2
		
			zeroJP2:	
				mov r11,0
				jmp endWhileP2
		
			secondConditionShiftP2: ; we are still in the while, checking the second condition m[i][k]==0
				push r10
				add r10, r12
				mov bx, [edi+r10d]
				pop r10
				cmp rbx, 0
				jle whileTrueP2
				jmp outsideWhileShiftP2
			
			whileTrueP2: ; the while is complete, we deacrese k and we start all over again
				sub r12, 2
				jmp whileShiftP2
				
			outsideWhileShiftP2:
				cmp r12, -2
				jle zeroJP2
				jmp checkForShiftP2
		
			checkForShiftP2: ;this will move the zeros
				push r10
				add r10, r11
				mov [edi+r10d], bx
				pop r10
				push r10
				add r10, r12
				mov WORD[edi+r10d], 0
				pop r10
				inc r13 ; when a shift is made, we increase the r13
				jmp endWhileP2
			
			endWhileP2: ; we end the while and begin anew, with k decreased
				jmp increaseJShiftP2
		
	increaseJShiftP2: ; we increase the j
		mov r12, 0
		sub r11, 2
		jmp shiftCheckColumnP2
		
	increaseIShiftP2: ; we increase the i
		sub r10, 8
		mov r11, 6
		mov r12, 0
		jmp shiftNumbersBeginP2
   
	endShiftP2: ;end
		mov rax, r13 ; we pass the numbers of shifts to the rax
		mov rsp, rbp
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 

;;;;;  
; Find pairs of the same number from the right of the matrix (mPairs), 
; recived as a parameter, and accumulate the points on the scoreboard 
; by adding the points of the pairs that have been made.
; Go through the matrix by rows from right to left and from bottom to top.
; When a pair is found, two consecutive tiles in the same
; row with the same number, join the pair by adding the values and 
; store the sum in the right tile, a 0 in the left tile and
; accumulate this sum in the (p) variable (earned points).
; If a row of the matrix is: [8,4,4,2] it will be [8,0,8,2] and
; p = p + (4+4).
; Return the points (p) obtained from making pairs.
; To go through a matrix in assembly language, in this case, the index 
; goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
; of 2 because the data is short type (WORD), 2 bytes.
; Changes must be made on the same matrix.
; The matrix should not be displayed.
; 
; Global variables :
; None
; 
; Input parameters : 
; rdi(edi): (mPairs): Matrix address where we have the numbers of the game to make pairs.
; 
; Output parameters : 
; rax(eax): (p): Points to add to the scoreboard.
;;;;;  
addPairsRP2:
	push rbp
	mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rbp
	mov  rbp, rsp
	mov rax, 0
	mov r11, 6 ; we start by the biggest column possible
	mov r12, 24 ; we start by the biggest row possible
	
	forInColumnAddPairsP2:
		cmp r11, 0 ; if the column is smaller than 0 we will deacrese the row
		jl forInRowAddPairsP2
		jmp checkAddPairsP2
		
		checkAddPairsP2:
			mov rcx, 0
			mov rdx, 0
			mov rbx, 0
			mov r10, r11 ; we copy r11 to r10
			sub r10, 2 ; we subtract 2 to r10, r11 is intact
			cmp r10, 0; if r10 is smaller than 0 this will mean that there is no next number to the current pisition, in this case we can continue tot he other part of the algorith, nothig to sum
			jl continueAddPairsP2 
			push r11 ; we save r11
			add r11, r12; we add r11 and r12 for getting the current position
			mov cx, [edi+r11d] ; the result of the current position stored in cx
			mov dx, [edi+r11d-2]; the result of the next polumn, stored in dx
			pop r11 ; load r11
			mov rbx, rdx
			sub rbx, rcx ; we will subtract both results
			cmp rbx, 0 ; if the result is 0 it means both results were the exact number, if this occurs, we can jump to adding the numbers, if not, we will continue to the other part of the algorith
			jg continueAddPairsP2
			cmp rbx, 0
			jl continueAddPairsP2
			jmp addPairsP2
			
			addPairsP2:
				add rdx, rcx ; we add both results
				add rax, rdx ; we add the score to the current one in rax
				push r11
				add r11, r12
				mov [edi+r11d], dx ;the current position will store the result between the 2 numbers
				mov WORD[edi+r11d-2], 0 ; the other position is a 0
				pop r11
				jmp continueAddPairsP2
		
	continueAddPairsP2:
		sub r11, 2 ; next column
		jmp forInColumnAddPairsP2
		
	forInRowAddPairsP2:
		sub r12, 8 ; next row
		mov r11, 6 ; reset column
		cmp r12, 0 ; if the row is smaller than 0, we will end the function
		jl endAddPairsP2
		jmp forInColumnAddPairsP2
	
	endAddPairsP2
		mov rsp, rbp
		pop rbp
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8
		pop rdi
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		mov rsp, rbp
		pop rbp
		ret 


;;;;;  
; Check if a 2048 has been reached or if no move can be made.
; If there is the number 2048 in the matrix (m), change the status 
; to 4 (status='4') to indicate that the game has been won (WIN!).
; If we haven't won, check if we can make a move,
; If no move can be made change the status to 5 (status='5') 
; to indicate that the game has been lost (GAME OVER!!!).
; Go through the matrix (m) row by row from right to left and 
; from bottom to top counting the empty tiles and checking if 
; the number 2048 is there.
; To go through a matrix in assembly language, in this case, the index 
; goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
; of 2 because the data is short type (WORD), 2 bytes.
; If there isn't any 2048 assign (status='4') and finish.
; If there is no number 2048 and there are no empty tiles, 
; see if you can make an horizontal or a vertical move. 
; To do this, you must copy the matrix (m) over the matrix (mAux) 
; by calling (copyMatrixP2), make pairs over the matrix (mAux) 
; to see if you can make pairs horizontally by calling (addPairsRP2)
; and save the points obtained , rotate the matrix (mAux) by calling
; (rotateMatrixRP2) and make pairs in the matrix (mAux) again 
; to see if you can make pairs vertically by calling (addPairsRP2) 
; and accumulate the points obtained with the points obtained before, 
; if the accumulated points are 0, it means no pairs can be made 
; and the game status must be set to 5 (status='5'), Game Over!.
; Neither the (m) matrix nor the (mUndo) matrix can be modified.
; 
; Global variables :
; (m)       : Matrix where we have the numbers of the game.
; (mRotated): Matrix where we have the numbers of the game rotated.
; (mAux)    : Matrix where we have the numbers of the game to check it.
; (state)   : State of the game.
; 
; Input parameters : 
; None
; 
; Output parameters : 
; None
;;;;;  
checkEndP2:
	push rbp
	mov  rbp, rsp
	mov rcx, 0
	mov rbx, 0
	mov rbx, 0
	mov rax, 0
	mov r11, 6 ; column
	mov r12, 24 ;row
	mov r14, 0 ; this will be the count of zeros
	
	forInColumnEndP2:
		cmp r11, 0
		jl forInRowEndP2
		jmp check2048P2
		
		check2048P2: ;in every position we will check if we have a 2048
			mov bx, [m+r11+r12] ; we get the current position, and check if it is a 2048
			cmp rbx, 2048
			jl checkForZerosP2
			cmp rbx, 2048
			jg checkForZerosP2
			jmp winBy2048P2 ; if it is, we win
		
		checkForZerosP2: ; for every position we will check if there is a 0
			cmp rbx, 0
			jl continueInColumnEndP2
			cmp rbx, 0
			jg continueInColumnEndP2
			inc r14 ; if there is a 0, we will add 1 to the r14, out zero counter
			jmp continueInColumnEndP2
			
	continueInColumnEndP2:
		sub r11, 2 ; next column
		jmp forInColumnEndP2
		
	forInRowEndP2:
		mov r11, 6 ; reset column
		sub r12, 8 ; next row
		cmp r12, 0 ; if the row is smaller than 0, we will end this aprt of the code
		jl check2ConditionsP2
		jmp forInColumnEndP2
		
		check2ConditionsP2: ; here we check if there is any zeros in the matrix
			cmp r14, 0
			jg endEndCheckP2 ; if there is more than 0 empty tiles the function will end since we have more space, if not, we will check if we can make more movements
			jmp checkForMovementsEndP2 
			
		winBy2048P2:
			mov BYTE[state], '4' ;win
			jmp endEndCheckP2
			
		checkForMovementsEndP2: ; this checks if there is a movement we can do
			mov rdi, mAux ; we save the matrix maux in rdi
			mov rsi, m	;we save rsi in m, this will change the position of the registers that store this information in the following function
			call copyMatrixP2 ; call copy
			call addPairsRP2 ; call addpairs
			call rotateMatrixRP2; call rotate, then we call addpairs again to see if there is any posible position to make a movement above and bellow the tiles
			mov rcx, rax ;  after colling the addpairs, it is posible that we got some points,  we add to rcx the score
			call addPairsRP2 ; we call addpairs again, let's see if there is some score
			add rcx, rax ; we add the score
			cmp rcx, 0 ; if the score we gathered is  0, it means there are no score added for making pairs, which means there are no moves to make, so it's game over for us
			jg endEndCheckP2 ;if its different from 0, the game is not over yet!
			jmp gameOverP2  ; if its 0, there are no more movements to make, so we jump top the game over function
			
			gameOverP2: ; game over
				mov BYTE[state], '5'
				mov r14, 0
				jmp endEndCheckP2
	
	endEndCheckP2:
		mov r14, 0
		mov rsp, rbp
		pop rbp
		ret   



;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Read a key by calling the getchP2 subroutine and it is stored
; in the (al) register.
; According to the key read we will call the corresponding functions.
; ['i' (up), 'j' (left), 'k' (down) or 'l' (right)]
; Move the numbers and make the pairs according to the chosen direction.
; Depending on the key pressed, rotate the matrix (m) by calling 
; (rotateMatrixRP1), to be able to move the numbers to the right 
; (shiftNumbersRP1), make pairs to the right (addPairsRP1) and 
; shift numbers to the right again (shiftNumbersRP1) with the pairs made, 
; If a move or a pair has been made, indicate this by assigning (state='2').
; Then, keep rotating the matrix by calling (rotateMatrixRP1) 
; until leaving the matrix in the initial position.
; For the 'l' key (right) no rotations are required, for the rest, 
; 4 rotations must be made.
; 'u'                Assign (state = '3') to undo the last move.
; '<ESC>' (ASCII 27) Set (state = '0') to exit the game.
; If it is not any of these keys do nothing.
; The changes produced by these subroutine are not displayed on the screen.
; 
; Global variables :
; (mRotated): Matrix where we have the numbers of the game rotated.
; (m)       : Matrix where we have the numbers of the game.
; (state)   : State of the game.
; 
; Input parameters : 
; rdi(edi): (actualScore): Scored points on the scoreboard.
; 
; Output parameters : 
; rax(eax): (actualScore): Updated scored points.
;;;;;  
readKeyP2:
   push rbp
   mov  rbp, rsp

   push rbx
   push rdx
   push rsi
   push rdi
   push r8          ;s1
   push r9          ;s2
   push r10         ;p
   push r11         ;actualscore
   
   mov  r11d, edi
   mov  rdi, m      
   mov  rsi, mRotated
   
   call getchP2     ;getchP2_C();
      
   readKeyP2_i:
   cmp al, 'i'                ;i:(105) up
   jne  readKeyP2_j
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      
      call shiftNumbersRP2    ;s1 = shiftNumbersRP2_C(m);
      mov  r8d, eax
      call addPairsRP2        ;p  = addPairsRP2_C(m);
      mov  r10d, eax
      call shiftNumbersRP2    ;s2 = shiftNumbersRP2_C(m);
      mov  r9d, eax           
      
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      jmp  readKeyP2_moved
      
   readKeyP2_j:
   cmp al, 'j'                ;j:(106) left
   jne  readKeyP2_k
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      
      call shiftNumbersRP2    ;s1 = shiftNumbersRP2_C(m);
      mov  r8d, eax
      call addPairsRP2        ;actualScore = actualScore + p;
      mov  r10d, eax
      call shiftNumbersRP2    ;s2 = shiftNumbersRP2_C(m);
      mov  r9d, eax          
      
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      jmp  readKeyP2_moved
   
   readKeyP2_k:
   cmp al, 'k'                ;k:(107) down
   jne  readKeyP2_l
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
     
      call shiftNumbersRP2    ;s1 = shiftNumbersRP2_C(m);
      mov  r8d, eax
      call addPairsRP2        ;p  = addPairsRP2_C(m);
      mov  r10d, eax
      call shiftNumbersRP2    ;s2 = shiftNumbersRP2_C(m);
      mov  r9d, eax           
      
      call rotateMatrixRP2    ;rotateMatrixRP2_C(m);
      jmp  readKeyP2_moved
      
   readKeyP2_l:
   cmp al, 'l'                ;l:(108) right
   jne  readKeyP2_u
      
      call shiftNumbersRP2    ;s1 = shiftNumbersRP2_C(m);
      mov  r8d, eax
      call addPairsRP2        ;p  = addPairsRP2_C(m);
      mov  r10d, eax
      call shiftNumbersRP2    ;s2 = shiftNumbersRP2_C(m);
      mov  r9d, eax           
      jmp readKeyP2_moved
      
   readKeyP2_u:
   cmp al, 'u'                ; Undo
   jne  readKeyP2_ESC
      mov BYTE[state], '3'    ;state = '3';
      jmp  readKeyP2_End
   
   readKeyP2_ESC:
   cmp al, 27                 ; Sortir del programa
   jne readKeyP2_End
      mov BYTE[state], '0'    ;state='0';
   jmp readKeyP2_End 

   readKeyP2_moved:
   add  r11d, r10d            ;actualScore = actualScore + p;
   cmp  r8d, 0                ;if ( (s1>0) || 
   jg  readKeyP2_status2
      cmp  r10d, 0            ;(p>0) || 
      jg  readKeyP2_status2
         cmp r9d, 0           ;(s2>0) ) 
         jg  readKeyP2_status2
            jmp readKeyP2_End
   readKeyP2_status2:         ;state = '2';
   mov  BYTE[state], '2'
      
   readKeyP2_End:
   mov eax, r11d              ;return actualScore;
   
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rbx
   
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Show a message below the dashboard according to the value of 
; the (state) variable by calling the printMessageP2 subroutine.
; 
; Global variables :
; (state):  State of the game.
; 
; Input parameters : 
; None
; 
; Output parameters : 
; None
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printMessageP2:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; We call the printMessageP2_C function from assembly language.
   call printMessageP2_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret 
   
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; Generar nova fitxa de forma aleatòria.
; Si hi ha com a mínim una casella buida a la matriu (m) genera una 
; fila i una columna de forma aleatòria fins que és una de les caselles 
; buides. A continuació generar un nombre aleatori per decidir si la 
; nova fitxa ha de ser un 2 (90% dels casos) o un 4 (10% dels casos),
; cridant la funció insertTileP2_C().
; 
; Global variables :	
; Cap
; 
; Input parameters : 
; Cap
; 
; Output parameters : 
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
insertTileP2:
   push rbp
   mov  rbp, rsp
   ; We save the processor's registers' state because 
   ; the C functions do not keep the registers' state.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; We call the insertTileP2_C function from assembly language.
   call insertTileP2_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   
   mov rsp, rbp
   pop rbp
   ret 
   
   
;;;;;
; This subroutine is already done. YOU CANNOT MODIFY IT.
; 2048 game.
; Main function of the game
; Allows you to play the 8-PUZZLE game by calling all the functionalities.
;
; Pseudo code:
; Initialize state of the game, (state='1')
; Clear screen (call the clearScreen_C function).
; Display the board (call function printBoardP1_C).
; Updates the content of the board and the score (call updateBoardP1 subroutine).
; While (state=='1') do
;   Copy the matrix (m) over the matrix (mAux) (by calling the subroutine
;   (copyMatrixP2) and copy the points (score) over (scoreAux).
;   Read a key (call the readKeyP1 subroutine) 
;   and call the corresponding subroutines.
;   If we have moved some number when making the shifts or when making 
;   pairs (state=='2'), copy the state of the game we saved before
;   (mAux and scoreAux) over (mUndo and scoreUndo) to be able to undo 
;   the last move (recover previous state) by copying (mAux) over (mUndo)
;   (calling copyMatrixP2 subroutine) and copying (scoreAux) over (scoreUndo).
;   Generate a new tile (calling the insertTileP2 subroutine) and set 
;   the state variable to '1' (state='1').
;   If we need to recover the previous state (state='3'), copy the 
;   previous state of the game we have in (mUndu and scoreUndu) over 
;   (m and score) (calling the copyMatrixP2 subroutine) and copying 
;   (scoreUndu) over (score) and set the state variable to '1' (state='1').
;   Updates the board content and the score (call updateBoardP2 subroutine).
;   Check if 2048 has been reached or if no move can be made
;   (call CheckEndP2 subroutine).
;   Display a message below the board on the value of the variable
;   (state) (call printMessageP2 subroutine).
; End while 
; Exit:
; The game is over.
; 
; Global variables :
; (m)       : Matrix where we have the numbers of the game.
; (mRotated): Matrix where we have the numbers of the game rotated.
; (mAux)    : Matrix where we have the numbers of the game to check it.
; (mAux)    : Matrix where we have the numbers of the game to undu the last move.
; (state)   : State of the game.
;             '0': Exit, 'ESC' pressed.
;             '1': Let's keep playing.
;             '2': We continue playing but there have been changes in the matrix.
;             '3': Undo last move.
;             '4': Win, 2048 has been reached.
;             '5': Lost, no more moves.
; 
; Input parameters : 
; None
; 
; Output parameters : 
; None
;;;;;  
playP2:
   push rbp
   mov  rbp, rsp
   
   push rax
   push rbx
   push rdx
   push rsi
   push rdi
   push r10
   push r11
   push r12
   
   call clearScreen_C
   call printBoardP2_C
   
   mov  r10d, 290500        ;int score     = 290500;
   mov  r11d, 0             ;int scoreAux  = 0;
   mov  r12d, 1             ;int scoreUndu = 1;
   
   mov  BYTE[state], '1'    ;state = '1';	   		
   
   mov  edi, r10d
   call updateBoardP2

   playP2_Loop:                    ;while  {  
   cmp  BYTE[state], '1'           ;(state == 1)
   jne  playP2_End
      
      mov edi, mAux
      mov esi, m   
      call copyMatrixP2            ;copyMatrixP2_C(mAux,m);
      mov r11d, r10d               ;scoreAux = score
      mov edi,  r10d                        
      call readKeyP2               ;readKeyP2_C();
      mov r10d, eax
      cmp BYTE[state], '2'         ;(state == '2') 
      jne playP2_Next 
         mov edi, mUndo
         mov esi, mAux
         call copyMatrixP2         ;copyMatrixP2_C(mUndo,mAux);
         mov  r12d, r11d           ;scoreUndo = scoreAux
         call insertTileP2         ;insertTileP2_C(); 
         mov BYTE[state],'1'       ;state = '1';
         jmp playP2_Next
      cmp BYTE[state], '3'         ;(state == '3') 
      jne playP2_Next  
         mov  edi, m 
		 mov  esi, mUndo
		 call copyMatrixP2         ;copyMatrixP2_C(m,mUndo);
		 mov  r10d, r12d           ;score = scoreUndo;
		 mov  BYTE[state], '1'     ;state = '1';
      playP2_Next:
      mov  edi, r10d
      call updateBoardP2           ;updateBoardP2_C(score);
      call checkEndP2              ;checkEndP2_C();  
      call printMessageP2          ;printMessageP2_C(); 
      cmp BYTE[state], '3'         ;(state == '3') 
      jne playP2_Loop
         mov edi, m
		 mov  esi, mUndo
		 call copyMatrixP2        ;copyMatrixP2_C(m,mUndo);
		 mov  r10d, r12d          ;score = scoreUndo;
		 mov  BYTE[state], '1'    ;state = '1';
		 mov  edi, r10d
		 call updateBoardP2
   jmp playP2_Loop
   
   playP2_End:
           
   pop r12
   pop r11
   pop r10
   pop rdi
   pop rsi
   pop rdx
   pop rbx
   pop rax  
   
   mov rsp, rbp
   pop rbp
   ret

