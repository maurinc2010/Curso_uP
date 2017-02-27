*****************************************************************
rem NOMBRE DEL PROGRAMA  :  ENSAMBLA.BAT
rem AUTOR                :  J.A. ROJAS PONCE
rem FECHA                :  MARZO 17 DE 1993
rem OBJETIVO             :  ENSAMBLAR Y ENLAZAR EL PROGRAMA DADO
*****************************************************************
cls
echo off
rem Se comprueba que el archivo exista, de lo contrario se sale
if not "%1" == "" goto ensambla
echo ­No me dio el nombre del archivo o ha ocurrido alg£n ERROR!
echo ­USO del programa   :  ENSAMBLA nombre de archivo!
goto final
:ensambla
if exist %1.asm goto empieza
echo ­ARCHIVO %1.asm NO FUE encontrado...!
echo ­favor de verificar e intentar de nuevo!
goto final
:empieza
masm /v /z %1.asm;
link %1.obj
del *.obj
del *.bak
:final
*****************************************************************
