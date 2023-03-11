/**
 * C-Implementation of the practice, to have a high-level 
 * functional version with all the features you have to implement 
 * in assembly language.
 * From this code calls are made to assembly subroutines. 
 * THIS CODE CANNOT BE MODIFIED AND SHOULD NOT BE DELIVERED. 
 **/
 
#include <stdlib.h>
#include <stdio.h>
#include <termios.h>     //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>      //STDIN_FILENO

extern int developer;    //Declared variable in assembly language indicating the program developer name.

/**
 * Constants
 */
#define DimMatrix  4     //matrix dimension
#define SizeMatrix DimMatrix*DimMatrix //=16


/**
 * Definició de variables globals
 */
// Matrix 4x4 where we have the numbers of the game
// Access to matrixs in C: we use row(0..[DimMatrix-1]) and
// column(0..[DimMatrix-1]) (m[row][column]).
// Access to matrixs in assembly language: It is accessed as an array
// where indexMat (0..[DimMatrix*DimMatrix-1]).
// indexMat=((row*DimMatrix)+(column))*2 (2 because the matrix is short type).
// WORD[M+indexMat] (WORD because it is short type)
// (indexMat must be a register of type long/QWORD:RAX,RBX,..,RSI,RDI,..,R15).
short m[DimMatrix][DimMatrix]        = { { 	  8,    8,    32,    32},
                                         {    4,   32,   128,    64},
                                         {    0,    0,   256,   128},
                                         {    0,    4,   512,  1024} };

short mRotated[DimMatrix][DimMatrix] = { {    2,    0,     2,     0},
                                         {    2,    2,     4,     4},
                                         {    4,    4,     0,     4},
                                         {    4,    2,     2,     4} };

short mAux[DimMatrix][DimMatrix]     = { {    0,    0,     0,     0},
                                         {    0,    0,     0,     0},
                                         {    0,    0,     0,     0},
                                         {    0,    0,     0,     0} };
                                    
short mUndo[DimMatrix][DimMatrix]    = { {    0,    1,     3,     7},
                                         {   15,   31,    63,   127},
                                         {  255,  511,  1023,  2047},
                                         { 4095, 8191, 16383, 32767},};

char state = '1';   //'0': Exit, 'ESC' pressed.
			        //'1': Let's keep playing.
			        //'2': We continue playing but there have been changes in the matrix.
                    //'3': Undo last move.
                    //'4': Win, 2048 has been reached.
                    //'5': Lost, no more moves.

/**
 * Definition of C functions.
 */
void clearscreen_C();
void gotoxyP2_C(int, int);
void printchP2_C(char);
char getchP2_C();

char printMenuP2_C();
void printBoardP2_C();

void  showNumberP2_C(int, int, int);
void  updateBoardP2_C(int);
void  copyMatrixP2_C(short [DimMatrix][DimMatrix], short [DimMatrix][DimMatrix]);
void  rotateMatrixRP2_C(short [DimMatrix][DimMatrix]);
int   shiftNumbersRP2_C(short [DimMatrix][DimMatrix]);
int   addPairsRP2_C(short [DimMatrix][DimMatrix]);

int   readKeyP2_C(int);
void  insertTileP2_C();
void  checkEndP2_C();
void  printMessageP2_C();
void  playP2_C();


/**
 * Definition of assembly language subroutines called from C.
 */
extern void  showNumberP2(int, int, int);
extern void  updateBoardP2(int);
extern void  copyMatrixP2(short [DimMatrix][DimMatrix], short [DimMatrix][DimMatrix]);
extern void  rotateMatrixRP2(short [DimMatrix][DimMatrix]);
extern int   shiftNumbersRP2(short [DimMatrix][DimMatrix]);
extern int   addPairsRP2(short [DimMatrix][DimMatrix]);
extern int   readKeyP2(int);
extern void  checkEndP2();
extern void  playP2();


/**
 * Clear screen.
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * None
 *   
 * Output parameters: 
 * None
 * 
 * This function is not called from assembly code
 * and an equivalent assembly subroutine is not defined.
 */
void clearScreen_C(){
	
    printf("\x1B[2J");
    
}


/**
 * Place the cursor at a position on the screen.  
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * rdi(edi): (rowScreen): Row
 * rsi(esi): (colScreen): Column
 * 
 * Output parameters: 
 * None
 * 
 * An assembly language subroutine 'gotoxyP2' is defined to be able 
 * to call this function saving the status of the processor registers. 
 * This is done because C functions do not maintain the status of 
 * the processor registers. The parameters are equivalent.
 */
void gotoxyP2_C(int rowScreen, int colScreen){
	
   printf("\x1B[%d;%dH",rowScreen,colScreen);
   
}



/**
 * Show a character on the screen at the cursor position.
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * rdi(dil): (c):  Character to show.
 * 
 * Output parameters: 
 * None
 * 
 * An assembly language subroutine 'printchP2' is defined to be able 
 * to call this function saving the status of the processor registers. 
 * This is done because C functions do not maintain the status of 
 * the processor registers. The parameters are equivalent.
 */
void printchP2_C(char c){
	
   printf("%c",c);
   
}


/**
 * Read a character from the keyboard without displaying it 
 * on the screen and return it.
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters: 
 * rax(al): (c): Character read from the keyboard.
 * 
 * An assembly language subroutine 'getchP2' is defined to be able 
 * to call this function saving the status of the processor registers. 
 * This is done because C functions do not maintain the status of 
 * the processor registers. The parameters are equivalent.
 */
char getchP2_C(){

   char c;   

   static struct termios oldt, newt;

   /*tcgetattr get terminal parameters
   STDIN_FILENO indicates that standard input parameters (STDIN) are written on oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*copy parameters*/
   newt = oldt;

   /* ~ICANON to handle keyboard input character to character, not as an entire line finished with /n
      ~ECHO so that it does not show the character read*/
   newt.c_lflag &= ~(ICANON | ECHO);          

   /*Fix new terminal parameters for standard input (STDIN)
   TCSANOW tells tcsetattr to change the parameters immediately.*/
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Read a character*/
   c=(char)getchar();                 
    
   /*restore the original settings*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);

   /*Return the read character*/
   return c;
   
}


/**
 * Show the game menu on the screen and ask for an option.
 * Only accepts one of the correct menu options ('0'-'9').
 * 
 * Global variables :	
 * (developer) :((char *)&developer): Variable defined in the assembly code.
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters: 
 * rax(al): (charac): Character read from the keyboard.
 * 
 * This function is not called from the assembly code and 
 * an equivalent subroutine has not been defined in assembly language.
 */
char printMenuP2_C(){

 	clearScreen_C();
    gotoxyP2_C(1,1);
    printf("                                    \n");
    printf("           Developed by:            \n");
	printf("        ( %s )   \n",(char *)&developer);
    printf(" __________________________________ \n");
    printf("|                                  |\n");
    printf("|            MAIN MENU             |\n");
    printf("|__________________________________|\n");
    printf("|                                  |\n");
    printf("|         1. ShowNumber            |\n");
    printf("|         2. UpdateBoard           |\n");
    printf("|         3. CopyMatrix            |\n");
    printf("|         4. RotateMatrix          |\n");
    printf("|         5. ShiftNumbers          |\n");
    printf("|         6. AddPairs              |\n");
    printf("|         7. CheckEnd              |\n");
    printf("|         8. Play Game             |\n");
    printf("|         9. Play Game C           |\n");
    printf("|         0. Exit                  |\n");
    printf("|__________________________________|\n");
    printf("|                                  |\n");
    printf("|            OPTION:               |\n");
    printf("|__________________________________|\n"); 

    char charac =' ';
    while (charac < '0' || charac > '9') {
      gotoxyP2_C(21,22);
	  charac = getchP2_C();
	  printchP2_C(charac);
	}
	return charac;
   
}


/**
 * Show the game board on the screen. Lines of the board.
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters: 
 * None
 * 
 * This function is not called from the assembly code and 
 * an equivalent subroutine has not been defined in assembly language.
 */
void printBoardP2_C(){

   gotoxyP2_C(1,1);
   printf(" _________________________________________________  \n"); //01
   printf("|                                                  |\n"); //02
   printf("|                  2048 PUZZLE  v2.0               |\n"); //03
   printf("|                                                  |\n"); //04
   printf("|     Join the numbers and get to the 2048 tile!   |\n"); //05   
   printf("|__________________________________________________|\n"); //06
   printf("|                                                  |\n"); //07
   printf("|            0        1        2        3          |\n"); //08
   printf("|        +--------+--------+--------+--------+     |\n"); //09
   printf("|      0 |        |        |        |        |     |\n"); //10
   printf("|        +--------+--------+--------+--------+     |\n"); //11
   printf("|      1 |        |        |        |        |     |\n"); //12
   printf("|        +--------+--------+--------+--------+-    |\n"); //13
   printf("|      2 |        |        |        |        |     |\n"); //14
   printf("|        +--------+--------+--------+--------+     |\n"); //15
   printf("|      3 |        |        |        |        |     |\n"); //16
   printf("|        +--------+--------+--------+--------+     |\n"); //17
   printf("|          Score:   ______                         |\n"); //18
   printf("|__________________________________________________|\n"); //19
   printf("|                                                  |\n"); //20
   printf("| (ESC)Exit (u)Undo (i)Up (j)Left (k)Down (l)Right |\n"); //21
   printf("|__________________________________________________|\n"); //22
   
}


/**
 * Converts the number of 6 digits (n <= 999999) stored in the short 
 * type variable (n), recived as a parameter, to ASCII characters 
 * representing its value.
 * If (n) is greater than 999999 we will change the value to 999999.
 * The value must be divided (/) by 10, iteratively, 
 * until the 6 digits are obtained.
 * At each iteration, the remainder of the division (%) which is a value
 * between (0-9) indicates the value of the digit to be converted to 
 * ASCII ('0' - '9') by adding '0' ( 48 decimal) to be able to display it.
 * When the quotient is 0 we will show spaces in the non-significant part.
 * For example, if number=103 we will show "103" and not "000103".
 * The digits (ASCII character) must be displayed from the position 
 * indicated by the variables (rowScreen) and (colScreen), position 
 * of the units, to the left.
 * The first digit we get is the units, then the tens, ..., to display the
 * value the cursor must be moved one position to the left in each iteration.
 * To place the cursor call the functin gotoxyP2_C and to display the 
 * characters call the function printchP2_C.
 * 
 * Global variables :	
 * None
 * 
 * Input parameters : 
 * rdi(edi): (rScreen): Row to place the cursor on the screen.
 * rsi(esi): (cScreen): Column to place the cursor on the screen.
 * rdx(edx): (n)      : Number to show.
 * 
 * Output parameters : 
 * None
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'showNumberP2' 
 * is defined, the parameters are equivalent.
 * 
 */
 void showNumberP2_C(int rScreen, int cScreen, int n) {
	
	char charac;
	int  i;

    if (n > 999999) n = 999999;
	for (i=0;i<6;i++){
	  charac = ' ';
	  if (n > 0) {
		charac = n%10;	//residu
		n = n/10;		//quocient
		charac = charac + '0';
	  } 
	  gotoxyP2_C(rScreen, cScreen);
	  printchP2_C(charac);
	  cScreen--;
	}
		
}


/**
 * Update the contents of the Game Board with the data from the 4x4 
 * matrix (m) of type short and the scored points (scr), recived as a parameter.
 * Go thorugt the entire matrix(m), and for each element of the matrix
 * place the cursor on the screen and show the number of that position.
 * Go through the entire matrix by rows from left to right and from top to bottom.
 * To go through a matrix in assembler the index goes from 0 
 * (position [0][0]) to 30 (position [3][3]) with increments of 2 
 * because data is short type (WORD) 2 bytes.
 * Then, show the scoreboard (scr) at the bottom of the board, 
 * row 18, column 26 by calling the showNumberP2_C function.
 * Finally place the cursor in row 18, column 28 by calling 
 * the gotoxyP2_C() function.
 * 
 * Global variables :
 * (m): Matrix where we have the numbers of the game.
 * 
 * Input parameters : 
 * rdi(edi): (scr): Scored points on the scoreboard.
 * 
 * Output parameters : 
 * None
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'updateBoardP2' 
 * is defined, the parameters are equivalent.
 */
void updateBoardP2_C(int scr){

   int i,j;
   int rScreen, cScreen;
   
   rScreen = 10;
   for (i=0;i<DimMatrix;i++){
	  cScreen = 17;
      for (j=0;j<DimMatrix;j++){
         showNumberP2_C(rScreen,cScreen, m[i][j]);
         cScreen = cScreen + 9;
      }
      rScreen = rScreen + 2;
   }
   showNumberP2_C(18, 26, scr);   
   gotoxyP2_C(18,28);
   
}


/**
 * Copy the values stored in the (mOrig) matrix, recived as a parameter,
 * to the (mDest) matrix, recived as a parameter. The (mRotated) matrix 
 * should not be modified, changes should be made to the (m) matrix.
 * Go through the entire matrix by rows from left to right and from top to bottom.
 * To go through a matrix in assembly language the index goes from 0 
 * ([0][0] position) to 30 ([3][3] position) with increments of 2 because
 * data is short type (WORD), 2 bytes.
 * This will allow to copy two matrixs after a rotation
 * and handle the '(u)Undo' option.
 * Do not show the matrix.
 * 
 * Global variables :
 * None
 * 
 * Input parameters : 
 * rdi(rdi): (mDest)  : Matrix Address where we have the numbers we want to overwrite.
 * rsi(rsi): (mOrigin): Matrix address where we have the numbers of the game.
 * 
 * Output parameters : 
 * None.
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'copyMatrixP2' 
 * is defined, the parameters are equivalent.
 */
void copyMatrixP2_C(short mDest[DimMatrix][DimMatrix], short mOrig[DimMatrix][DimMatrix]) {
	
	int i,j;
	
	for (i=0; i<DimMatrix; i++) {
		for (j=0; j<DimMatrix; j++) {
			mDest[i][j]=mOrig[i][j];
		}
	}

}


/**
 * Rotate the matrix (mToRotate), recived as a parameter, to the right 
 * over the matrix (mRotated).
 * The first row becomes the fourth column, the second row becomes 
 * the third column, the third row becomes the second column, 
 * and the fourth row becomes the first column.
 * In the .pdf file there are a detailed explanation how to do the rotation.
 * NOTE: This is NOT the same as transpose the matrix.
 * The matrix (mToRotate) should not be modified, changes should be made
 * to the (mRotated) matrix.
 * To go through a matrix in assembly language the index goes from 0 
 * (position [0][0]) to 30 (position [3][3]) with increments of 2 
 * because the data is short type (WORD), 2 bytes.
 * To access a specific position of a matrix in assembly language, 
 * you must take into account that the index is:
 * (index=(row*DimMatrix+column)*2),
 * we multiply by 2 because the data is short type (WORD), 2 bytes.
 * Once the rotation has been done, copy the (mRotated) matrix  over the
 * matrix recived as a parameter by calling the function copyMatrixP2_C().
 * The matrix should not be displayed.
 * 
 * Global variables :
 * (mRotated) : Matrix where we have the numbers of the game.
 * 
 * Input parameters : 
 * rdi(rdi): (mToRotate): Matrix address where we have the numbers of the game rotated to the right.
 * 
 * Output parameters : 
 * None
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'rotateMatrixRP2' 
 * is defined, the parameters are equivalent.
 */
void rotateMatrixRP2_C(short mToRotate[DimMatrix][DimMatrix]) {
	
	int i,j;
	
	for (i=0; i<DimMatrix; i++) {
		for (j=0; j<DimMatrix; j++) {	
			mRotated[j][DimMatrix-1-i] = mToRotate[i][j];
		}
	}
	
	copyMatrixP2_C(mToRotate, mRotated);
	
}


/**
 * Shift right the numbers in each row of the matrix (mShift),
 * recived as a parameter, keeping the order of the numbers and moving 
 * the zeros to the left.
 * Go through the matrix by rows from right to left and bottom to top.
 * To go through a matrix in assembly language, in this case, the index 
 * goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
 * of 2 because the data is short type (WORD), 2 bytes.
 * To access a specific position of a matrix in assembly language, 
 * you must take into account that the index is:
 * (index=(row*DimMatrix+column)*2),
 * we multiply by 2 because the data is short type (WORD), 2 bytes.
 * If a number is moved (NOT THE ZEROS) the shifts must be counted by 
 * increasing the variable (shifts).
 * In each row, if a 0 is found, check if there is a non-zero number 
 * in the same row to move it to that position.
 * If a row of the matrix is: [0,2,0,4] and (shifts=0), 
 * it will be [0,0,2,4] and (shifts=2).
 * Changes must be made on the same matrix.
 * The matrix should not be displayed.
 * 
 * Global variables :
 * None
 * 
 * Input parameters : 
 * rdi(edi): (mShift): Matrix address where we have the numbers of the game to shift.
 * 
 * Output parameters : 
 * rax(eax): (shifts): Shifts that have been made.
 * 
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'shiftNumbersRP2' 
 * is defined, the parameters are equivalent.
 */
int shiftNumbersRP2_C(short mShift[DimMatrix][DimMatrix]) {
	
	int i,j,k;
	int shifts=0;
	
	for (i=DimMatrix-1; i>=0; i--) {
      for (j=DimMatrix-1; j>0; j--) {
        if (mShift[i][j] == 0) {
          k = j-1;           
          while (k>=0 && mShift[i][k]==0) k--;
          if (k==-1) {
             j=0;                
          } else {
              mShift[i][j]=mShift[i][k];
              mShift[i][k]= 0; 
              shifts++;         
          }
        }      
      }
    }

    return shifts;
	
}
	

/**
 * Find pairs of the same number from the right of the matrix (mPairs), 
 * recived as a parameter, and accumulate the points on the scoreboard 
 * by adding the points of the pairs that have been made.
 * Go through the matrix by rows from right to left and from bottom to top.
 * When a pair is found, two consecutive tiles in the same
 * row with the same number, join the pair by adding the values and 
 * store the sum in the right tile, a 0 in the left tile and
 * accumulate this sum in the (p) variable (earned points).
 * If a row of the matrix is: [8,4,4,2] it will be [8,0,8,2] and
 * p = p + (4+4).
 * Return the points (p) obtained from making pairs.
 * To go through a matrix in assembly language, in this case, the index 
 * goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
 * of 2 because the data is short type (WORD), 2 bytes.
 * Changes must be made on the same matrix.
 * The matrix should not be displayed.
 * 
 * Global variables :
 * None
 * 
 * Input parameters : 
 * rdi(edi): (mPairs): Matrix address where we have the numbers of the game to make pairs.
 * 
 * Output parameters : 
 * rax(eax): (p): Points to add to the scoreboard.
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'addPairsRP2' 
 * is defined, the parameters are equivalent.
 */
int addPairsRP2_C(short mPairs[DimMatrix][DimMatrix]) {
	
	int i,j;
	int p = 0;
	
	for (i=DimMatrix-1; i>=0; i--) {
      for (j=DimMatrix-1; j>0; j--) {
			if ((mPairs[i][j]!=0) && (mPairs[i][j]==mPairs[i][j-1])) {
				mPairs[i][j]  = mPairs[i][j]*2;
				mPairs[i][j-1]= 0;
				p = p + mPairs[i][j];
			}		
		}
	}
	
	return p;
	
}


/**
 * Check if a 2048 has been reached or if no move can be made.
 * If there is the number 2048 in the matrix (m), change the status 
 * to 4 (status='4') to indicate that the game has been won (WIN!).
 * If we haven't won, check if we can make a move,
 * If no move can be made change the status to 5 (status='5') 
 * to indicate that the game has been lost (GAME OVER!!!).
 * Go through the matrix (m) row by row from right to left and 
 * from bottom to top counting the empty tiles and checking if 
 * the number 2048 is there.
 * To go through a matrix in assembly language, in this case, the index 
 * goes from 30 (position [3][3]) to 0 (position [0][0]) with increments
 * of 2 because the data is short type (WORD), 2 bytes.
 * If there isn't any 2048 assign (status='4') and finish.
 * If there is no number 2048 and there are no empty tiles, 
 * see if you can make an horizontal or a vertical move. 
 * To do this, you must copy the matrix (m) over the matrix (mAux) 
 * by calling (copyMatrixP2_C), make pairs over the matrix (mAux) 
 * to see if you can make pairs horizontally by calling (addPairsRP2_C)
 * and save the points obtained , rotate the matrix (mAux) by calling
 * (rotateMatrixRP2_C) and make pairs in the matrix (mAux) again 
 * to see if you can make pairs vertically by calling (addPairsRP2_C) 
 * and accumulate the points obtained with the points obtained before, 
 * if the accumulated points are 0, it means no pairs can be made 
 * and the game status must be set to 5 (status='5'), Game Over!.
 * Neither the (m) matrix nor the (mUndo) matrix can be modified.
 * 
 * Global variables :
 * (m)       : Matrix where we have the numbers of the game.
 * (mRotated): Matrix where we have the numbers of the game rotated.
 * (mAux)    : Matrix where we have the numbers of the game to check it.
 * (state)   : State of the game.
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters : 
 * None
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'checkEndP2' 
 * is defined, the parameters are equivalent.
 */
void checkEndP2_C() {
	
	int i,j;
	int zeros=0;
	int pairs=0;
		
	i=DimMatrix;
	do {
		i--;
		j=DimMatrix;
		do {
			j--;
			if (m[i][j] == 0 ) zeros++;
			if (m[i][j] == 2048) state='4';
		} while ((j>0) && (m[i][j]!=2048));
		
	} while ((i>0) && (m[i][j]!=2048));

	if ((state!= '4') && (zeros == 0)) {
		copyMatrixP2_C(mAux,m);
		pairs = addPairsRP2_C(mAux);
		rotateMatrixRP2_C(mAux);
		pairs = pairs + addPairsRP2_C(mAux);
		if (pairs==0) state = '5';	
	}
	
} 


/**
 * Read a key by calling the function getchP2_C and it will be stored
 * in the (c) variable.
 * According to the key read we will call the corresponding functions.
 * ['i' (up), 'j' (left), 'k' (down) or 'l' (right)]
 * Move the numbers and make the pairs according to the chosen direction.
 * Depending on the key pressed, rotate the matrix (m) by calling 
 * (rotateMatrixRP1_C), to be able to move the numbers to the right 
 * (shiftNumbersRP1_C), make pairs to the right (addPairsRP1_C) and 
 * shift numbers to the right again (shiftNumbersRP1_C) with the pairs made, 
 * If a move or a pair has been made, indicate this by assigning (state='2').
 * Then, keep rotating the matrix by calling (rotateMatrixRP1_C) 
 * until leaving the matrix in the initial position.
 * For the 'l' key (right) no rotations are required, for the rest, 
 * 4 rotations must be made.
 * 'u'                Assign (state = '3') to undo the last move.
 * '<ESC>' (ASCII 27) Set (state = '0') to exit the game.
 * If it is not any of these keys do nothing.
 * The changes produced by this function is not displayed on the screen.
 * 
 * Global variables :
 * (mRotated): Matrix where we have the numbers of the game rotated.
 * (m)       : Matrix where we have the numbers of the game.
 * (state)   : State of the game.
 * 
 * Input parameters : 
 * rdi(edi): (actualScore): Scored points on the scoreboard.
 * 
 * Output parameters : 
 * rax(eax): (actualScore): Updated scored points.
 *  
 * This function is not called from assembly code.
 * An equivalent assembly language subroutine 'readKeyP2' 
 * is defined, the parameters are equivalent.
 */
int readKeyP2_C(int actualScore){

   int s1, s2;
   int p;
   
   char c;
   c = getchP2_C();	
 
   switch(c){
      case 'i': //i:(105) up
         rotateMatrixRP2_C(m);
		 
         s1 = shiftNumbersRP2_C(m);
         p  = addPairsRP2_C(m);
         s2 = shiftNumbersRP2_C(m);
         actualScore = actualScore + p;
         if ( (s1>0) || (p>0) || (s2>0) ) state = '2';
         
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
		 
      break;
      case 'j': //j:(106) left
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
         
         s1 = shiftNumbersRP2_C(m);
         p  = addPairsRP2_C(m);
         s2 = shiftNumbersRP2_C(m);
         actualScore = actualScore + p;
         if ( (s1>0) || (p>0) || (s2>0) ) state = '2';
         
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
      break;
      case 'k': //k:(107) down
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
         rotateMatrixRP2_C(m);
             
         s1 = shiftNumbersRP2_C(m);
         p  = addPairsRP2_C(m);
         s2 = shiftNumbersRP2_C(m);
         actualScore = actualScore + p;
         if ( (s1>0) || (p>0) || (s2>0) ) state = '2';
         
		 rotateMatrixRP2_C(m);
      break;
      case 'l': //l:(108) right
         s1 = shiftNumbersRP2_C(m);
         p  = addPairsRP2_C(m);
         s2 = shiftNumbersRP2_C(m);
         actualScore = actualScore + p;
         if ( (s1>0) || (p>0) || (s2>0) ) state = '2';
      break;  
	  case 'u': //u:(117) undu
         state = '3';
	  break;
	  case 27: //ESC:(27) exit the program
		 state = '0';
	  break;
	}
   
   return actualScore;
   
}


/**
 * Generate a new tile randomly.
 * If there is at least one empty cell in the (m) matrix, 
 * randomly generate a row and a column until it is one of 
 * the empty cells.
 * Then generate a random number to decide if the new token should be
 * a 2 (90% of cases) or a 4 (10% of cases).
 * 
 * Global variables :
 * (m): Matrix where we have the numbers of the game.
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters : 
 * None
 *  
 * This function is called from C and from assembler, and 
 * there is no equivalent assembly subroutine defined.
 * There are no parameters.
 */
void insertTileP2_C() {
	
	int i,j,k,l,r;
	
	i=DimMatrix; // Check if there is an empty tile.
	do {
		i--;
		j=DimMatrix;
		do {
			j--;	
		} while ((j>=0) && (m[i][j]!=0));
	} while ((i>=0) && (m[i][j]!=0));
	
	//We insert a 2 or a 4 if there is at least one empty tile.
	if (m[i][j]==0) { 
		do { // Randomly generate rows and columns until
             // an empty position is found.
			k = rand() % 4; l = rand() % 4; }
		while( m[k][l] != 0 );
		
		//We decide whether to put a 2 or a 4
		r = rand() % 100;
		if( r < 90 ) {
			m[k][l] = 2;
		} else {
			m[k][l] = 4;
		}
	}

}


/**
 * Show a message below the dashboard according to the value of 
 * the (state) variable.
 * state: State of the game.
 *        '0': Exit, 'ESC' pressed.
 *        '1': Let's keep playing.
 *        '2': We continue playing but there have been changes in the matrix.
 *        '3': Undo last move.
 *        '4': Win, 2048 has been reached.
 *        '5': Lost, no more moves.
 * A key is expected to be pressed to continue.
 * 
 * If it has been lost (state='5') you have the option to do a final 
 * 'Undo' by pressing the 'u' key to recover the previous state and try
 * to continue playing (state='3'). Pressing another key exits the game.
 * 
 * Global variables :
 * (state):  State of the game.
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters : 
 * None
 * 
 * An assembly language subroutine 'printMessageP2' is defined to be able 
 * to call this function saving the status of the processor registers. 
 * This is done because C functions do not maintain the status of 
 * the processor registers. The parameters are equivalent.
 */
void printMessageP2_C() {

   switch(state){
      case '0':
		 gotoxyP2_C(23,12);
         printf("<<<<<< EXIT: (ESC) Pressed >>>>>>");
         getchP2_C();
        break;
      case '4':
		 gotoxyP2_C(23,12);
         printf("++++++ 2048!!!  YOU  W I N ++++++");
         getchP2_C();
      break;
      case '5':
		 gotoxyP2_C(23,12);
         printf("---- G A M E   O V E R ! ! ! ----");
         gotoxyP2_C(24,12);
         printf("---- (u)Undo  (Any key) EXIT ----");
         char c;
		 c = getchP2_C();
		 if (c == 'u') {
			gotoxyP2_C(23,12);
			printf("                                  ");
			gotoxyP2_C(24,12);
            printf("                                  ");
            state='3';
		 }
      break;
   }

}
 

/**
 * 2048 game.
 * Main function of the game
 * Allows you to play the 8-PUZZLE game by calling all the functionalities.
 *
 * Pseudo code:
 * Initialize state of the game, (state='1')
 * Clear screen (call the clearScreen_C function).
 * Display the board (call function printBoardP1_C).
 * Updates the content of the board and the score (call function updateBoardP1_C).
 * While (state=='1') do
 *   Copy the matrix (m) over the matrix (mAux) (by calling the function
 *   (copyMatrixP2_C) and copy the points (score) over (scoreAux).
 *   Read a key (call the function readKeyP1_C) 
 *   and call the corresponding functions.
 *   If we have moved some number when making the shifts or when making 
 *   pairs (state=='2'), copy the state of the game we saved before
 *   (mAux and scoreAux) over (mUndo and scoreUndo) to be able to undo 
 *   the last move (recover previous state) by copying (mAux) over (mUndo)
 *   (calling copyMatrixP2_C function) and copying (scoreAux) over (scoreUndo).
 *   Generate a new tile (calling the insertTileP2_C function) and set 
 *   the state variable to '1' (state='1').
 *   If we need to recover the previous state (state='3'), copy the 
 *   previous state of the game we have in (mUndu and scoreUndu) over 
 *   (m and score) (calling the copyMatrixP2_C function) and copying 
 *   (scoreUndu) over (score) and set the state variable to '1' (state='1').
 *   Updates the board content and the score (call function updateBoardP2_C).
 *   Check if 2048 has been reached or if no move can be made
 *   (call function CheckEndP2_C).
 *   Display a message below the board on the value of the variable
 *   (state) (call function printMessageP2_C()).
 * End while 
 * Exit:
 * The game is over.
 * 
 * Global variables :
 * (m)       : Matrix where we have the numbers of the game.
 * (mRotated): Matrix where we have the numbers of the game rotated.
 * (mAux)    : Matrix where we have the numbers of the game to check it.
 * (mAux)    : Matrix where we have the numbers of the game to undu the last move.
 * (state)   : State of the game.
 *             '0': Exit, 'ESC' pressed.
 *             '1': Let's keep playing.
 *             '2': We continue playing but there have been changes in the matrix.
 *             '3': Undo last move.
 *             '4': Win, 2048 has been reached.
 *             '5': Lost, no more moves.
 * 
 * Input parameters : 
 * None
 * 
 * Output parameters : 
 * None
 */
void playP2_C(){
   		     
   int score     = 290500;
   int scoreAux  = 0;
   int scoreUndo = 1;     
   
   state = '1';	   			   
   clearScreen_C();
   printBoardP2_C();
   updateBoardP2_C(score);
          
   while (state == '1') {  	  //Main loop.
	 copyMatrixP2_C(mAux,m);  
	 scoreAux = score;
	 score = readKeyP2_C(score);
	 if (state == '2') {	  
		copyMatrixP2_C(mUndo,mAux);
		scoreUndo = scoreAux;
		insertTileP2_C();	  
		state = '1';
	 }
	 if (state == '3') {       
		 copyMatrixP2_C(m,mUndo);
         score = scoreUndo;
         state = '1';
     }
     updateBoardP2_C(score);
	 checkEndP2_C();
	 printMessageP2_C();       
	 if (state == '3') {       
		 copyMatrixP2_C(m,mUndo);
         score = scoreUndo;
         state = '1';
         updateBoardP2_C(score);
     } 		
  }

}


/**
 * Main Program
 * 
 * ATTENTION: In each option an assembly subroutine is called.
 * Below them there is a line comment with the equivalent C function 
 * that we give you done in case you want to see how it works.
 * For the full game there is an option for the assembler version and
 * an option for the game in C.
 */
int main(){   

   char op=' ';
   char c;
   int score = 123456;
   
   while (op!='0') {
	  op = printMenuP2_C();
      
      switch(op){
         case '1':// Show a number.
            clearScreen_C();  
            printBoardP2_C();   
            gotoxyP2_C(18, 30);
            printf(" Press any key ");
            //=======================================================
            showNumberP2(18, 26, score);       
            //showNumberP2_C(18, 26, score);   
            //=======================================================
            getchP2_C();
         break;
         case '2': //Update board content.
            clearScreen_C();  
            printBoardP2_C(); 
            //=======================================================
            updateBoardP2(score);
            //updateBoardP2_C(score); 
            //=======================================================
            gotoxyP2_C(18, 30);
            printf("Press any key ");
            getchP2_C();
         break;
         case '3': //Copy matrixs.
            clearScreen_C();  
            printBoardP2_C(); 
            int scoreUndu = 500;
            //=======================================================
            copyMatrixP2(m, mUndo);
            //copyMatrixP2_C(m, mUndo);
            //=======================================================
            updateBoardP2_C(scoreUndu);
            gotoxyP2_C(18, 30);
			printf("Press any key ");
	        getchP2_C();
         break;
         case '4': //Rotate matrix to the right.
            clearScreen_C();  
            printBoardP2_C(); 
            //===================================================
            rotateMatrixRP2(m);
			//rotateMatrixRP2_C(m);
			//===================================================
            updateBoardP2_C(score);
            gotoxyP2_C(18, 30);
			printf("Press any key ");
	        getchP2_C();
          break;
          case '5': //Shift number to the right.
            clearScreen_C();  
            printBoardP2_C(); 
            //===================================================
            shiftNumbersRP2(m);
			//shiftNumbersRP2_C(m);
			//===================================================
            updateBoardP2_C(score);
            gotoxyP2_C(18, 30);
			printf("Press any key ");
	        getchP2_C();
          break;
          case '6': //Make pairs and score points.
            clearScreen_C();  
            printBoardP2_C();   
            score = 1000;
            //===================================================
			score = score + addPairsRP2(m);
			//score = score + addPairsRP2_C(m);
			//===================================================
			updateBoardP2_C(score);
			gotoxyP2_C(18, 30);
			printf("Press any key ");
	        getchP2_C();
         break;
         case '7': //Check if there is a 2048 or if any movement can be made.
            clearScreen_C();        
            printBoardP2_C();       
            updateBoardP2_C(score); 
            //===================================================
			checkEndP2();
			//checkEndP2_C();
			//===================================================
			printMessageP2_C();
			if ((state!='4') && (state!='5')) {
			   gotoxyP2_C(18, 30);
			   printf("Press any key ");
	           getchP2_C();
	        }
         break;
         case '8': //Complete game in assembly language.
            //=======================================================
            playP2();
            //=======================================================
         break;
         case '9': //Complete game in C. 
            //=======================================================
            playP2_C();
            //=======================================================
         break;
      }
   }
   printf("\n\n");
   
   return 0;
   
}
