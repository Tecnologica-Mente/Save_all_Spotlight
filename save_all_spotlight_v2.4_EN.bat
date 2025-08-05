REM ************************************************************************
REM * This script save all the Spootlight Images stored in your Windows OS *
REM *                                                                      *
REM * Homepage: https://github.com/Tecnologica-Mente/Save_all_Spotlight    *
REM *    Email: <not available>                                            *
REM *                                                                      *
REM ************************************************************************
REM *                                                                      *
REM * NOTA: To work it requires the file:                                  *
REM * MediaInfo.x86-i686.exe                                               *
REM * that you can download from:                                          *
REM * and place it in the same folder as the bat file                      *
REM * (it must be extracted from the MediaInfo-CLI.XXXX-XX-XX.zip file     *
REM * where XXXX-XX-XX indicates the file version, e.g. 2024-08-17)        *
REM *                                                                      *
REM ************************************************************************

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
title Save All Spotlight v2.4
REM Set the text color to green
REM color 0a
cls
echo **************************
echo *** SAVE ALL SPOTLIGHT ***
echo **************************
echo.
set folder_name=spotlight_imgs

REM Check for the presence of the "spotlight_imgs" folder
IF EXIST "%folder_name%\" (
   echo ATTENTION. DELETE THE %folder_name% FOLDER TO BE ABLE TO PROCEED WITH THE OPERATION
   echo.
   PAUSE
   exit /b 1
)

REM Checking for the existence of the "MediaInfo.x86-i686.exe" file
IF NOT EXIST "MediaInfo.x86-i686.exe" (
   echo.
   echo ATTENTION. MediaInfo.x86-i686.exe FILE NOT FOUND.
   echo THIS FILE MUST BE PLACED IN THE SAME FOLDER AS THE BAT FILE
   echo.
   PAUSE
   exit /b 1
)

echo STEP 1. SAVE WINDOWS LOCK SCREEN FILES
md %folder_name%
echo Copying the necessary files...
copy /y "%USERPROFILE%\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\*.*" %folder_name%
ren "%folder_name%\*.*" "*.jpg"

REM Adapted from: https://stackoverflow.com/questions/18855048/get-image-file-dimensions-in-bat-file
copy MediaInfo.x86-i686.exe %folder_name%
cd /d %folder_name%

set /a img_tot=0
set /a img_elim=0
set /a img_valide=0
set /a img_orizz=0
set /a img_vert=0
set /a img_ric=0
set /a img_non_ric=0
REM Valid image sizes (in pixels) [both horizontal and vertical]
REM NOTE: When specifying the dimensions of an image in pixels, the standard convention is: Width × Height (e.g. a 1920×1080 image is 1920 pixels wide and 1080 pixels high)
set /a img_dim1=1920
set /a img_dim2=1080

echo.
echo Search for images of size !img_dim1!x!img_dim2! pixels [horizontal] and !img_dim2!x!img_dim1! pixels [vertical] in progress...
for /r %%a in (*.jpg *.bmp *.png *.gif) do (
   set "width="
   set "height="
   set file1=%%~a
   set /a img_tot=img_tot+1
   for /f "tokens=1*delims=:" %%b in ('"MediaInfo.x86-i686.exe --INFORM=Image;%%Width%%:%%Height%% "%%~a""') do (
      echo Image detected %%~a [%%~bx%%~c]
      set file2=%%~a
      set /a img_ric=img_ric+1
      REM IF statements do not support logical operators. You can implement a logical OR as described in http://www.robvanderwoude.com/battech_booleanlogic.php
      IF %%~b EQU !img_dim2! (
         IF %%~c EQU !img_dim1! (
            echo Vertical image
            set /a img_vert=img_vert+1
         )   
      ) ELSE (
         IF %%~c EQU !img_dim2! (
            IF %%~b EQU !img_dim1! (
               echo Horizontal image
               set /a img_orizz=img_orizz+1
            )
         ) ELSE (
            IF "%%~a" NEQ "MediaInfo.x86-i686.exe" (
               echo Image neither horizontal nor vertical, deletion in progress...
               REM Il "\\?\" is used to delete files even if the folder and/or file contains whitespace in its name
               del "\\?\%%~a"
               set /a img_elim=img_elim+1
            )
         )
      )
   )
   IF "!file1!" NEQ "!file2!" (
      echo Detected file not recognized as an image %%~a
      echo Unrecognized file deletion %%~a
      del "\\?\%%~a"
      set /a img_elim=img_elim+1
   )
   REM set "file1="
   REM set "file2="
)
echo.
set /a img_valide=img_tot-img_elim
set /a img_non_ric=img_tot-img_ric
echo !img_tot! total images copied of which:
echo !img_elim! invalid [deleted]
echo !img_valide! valid [!img_orizz! horizontal and !img_vert! vertical]
del MediaInfo.x86-i686.exe
cd /d "%~dp0"
echo STEP 1 COMPLETED
echo.

echo STEP 2. SAVE WINDOWS DESKTOP BACKGROUND FILES
REM Set up folders
set "origine=%USERPROFILE%\AppData\Local\Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\LocalCache\Microsoft\IrisService"
set "destinazione=%~dp0%folder_name%"
set count=0

REM Checking for the existence of the "origine" folder
if not exist "%origine%" (
   echo ERROR: The folder "%origine%" does not exist
   REM echo Manual check: explorer.exe "%origine%"
   REM PAUSE
   goto :fase2_end
)

REM Copy files with verification (only if the "origine" folder exists)
for /r "%origine%" %%f in (*) do (
   copy "%%f" "%destinazione%" >nul
   if errorlevel 1 (
      echo Copy ERROR %%f
   ) else (
      set /a count+=1
      echo Copied: %%~nxf  [!count!]
   )
)

:fase2_end
echo.
echo %count% total images copied
echo STEP 2 COMPLETED
echo.

set /a totale=img_valide + count
echo TOTAL IMAGES SAVED (STEP 1 + STEP 2): %totale%
echo ****************************
echo *** OPERATIONS COMPLETED ***
echo ****************************
PAUSE