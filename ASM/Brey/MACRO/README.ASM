;This sample program uses the MACRO.INC macro include file that contains
;many useful macros.  This program must be assembled with MASM version 6.X
;
	.MODEL SMALL
	.386
	INCLUDE MACRO.INC	;you most likely will need a path!
	.DATA
STR1	DB	'                                  DISK INFO',0
STR2	DB	' This disk contains two directories.',0
STR3	DB	' (1) ASM_FILE, which contains most of the examples from the textbook in',0
STR4	DB	' unassembled form in files keyed to the examples. The EXA14-15 file is',0
STR5	DB	' Example 14-15 from the text.',0
STR6	DB	' (2) MACRO, which contains some very useful macros in a file called MACRO.INC.',0
STR7	DB	' Also in the MACRO directory is an example PROGRAM that uses some of the',0
STR8	DB	' macros from MACRO.INC.',0
STR9	DB	' To execute any of the files on this disk you must assemble them using either',0
STR10	DB	' MASM version 5.10 (not all examples work with this version) or version 6.X.',0
STR11	DB	' Version 5.10 command line syntax (no list file generated):',0
STR12	DB	' MASM EXA14-15;',0
STR13	DB	' Version 5.10 command line syntax (list file generated as EXA14-15.LST):',0
STR14	DB	' MASM EXA14-15,EXA14-15.LST;'
STR15	DB	' Version 6.X command line syntax (no list file):',0
STR16	DB	' ML EXA14-15.ASM',0
STR17	DB	' Version 6.X command line syntax (list file generated as EXA14-15.LST):',0
STR18	DB	' ML /FLEXA14-15.LST EXA14-15.ASM',0
STR19	DB	' In most cases you should be using PWB (Programmer''s WorkBench) to assemble',0
STR20	DB	' the programs and also edit them.',0
STR21	DB	' Barry B. Brey',0
STR22	DB	' Type any key to return to DOS...',0
	.CODE
	.STARTUP
	MOV	AX,12H		;switch to mode 12H
	INT	10H
	_SCREEN 3		;display cyan screen
	_BAND	0,7
	_BAND	1,7
	_BAND	2,7
	_VSTR	1,0,STR1,8	;display disk info
	_VSTR	4,0,STR2,0
	_VSTR	6,0,STR3,0
	_VSTR	7,0,STR4,0
	_VSTR	8,0,STR5,0
	_VSTR	10,0,STR6,0
	_VSTR	11,0,STR7,0
	_VSTR	12,0,STR8,0
	_VSTR	14,0,STR9,0
	_VSTR	15,0,STR10,0
	_VSTR	16,0,STR11,0
	_VSTR	18,0,STR12,0
	_VSTR	20,0,STR13,0
	_VSTR	22,0,STR14,0
	_VSTR	24,0,STR15,0
	_VSTR	26,0,STR16,0
	_VSTR	28,0,STR17,0
	_VSTR	30,0,STR18,0
	_VSTR	32,0,STR19,0
	_VSTR	33,0,STR20,0
	_VSTR	38,29,STR21,9
	_VSTR	48,0,STR22,12
	MOV	AH,1		;wait for any key
	INT	21H
	MOV	AX,3		;back to mode 3
	INT	10H
	.EXIT
	END
