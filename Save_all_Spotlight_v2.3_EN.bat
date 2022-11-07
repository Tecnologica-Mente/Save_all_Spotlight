REM ************************************************************************
REM * This script save all the Spootlight Images stored in your Windows OS *
REM *                                                                      *
REM * Homepage: https://github.com/Tecnologica-Mente                       *
REM *    Email: <not available>                                            *
REM *                                                                      *
REM ************************************************************************
REM *                                                                      *
REM * NOTA: To work it requires the file:                                  *
REM * MediaInfo.x86-i686.exe                                               *
REM * to be placed in the same folder as the bat file                      *
REM *                                                                      *
REM ************************************************************************

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
cls
set folder_name=spotlight_imgs
IF EXIST "%folder_name%\" (
   echo.
   echo ATTENTION. DELETE THE %folder_name% FOLDER TO BE ABLE TO PROCEED WITH THE OPERATION
   echo.
   PAUSE
) ELSE (
   IF EXIST "MediaInfo.x86-i686.exe" (   
      md %folder_name%
      echo Copying useful files...
      copy /y "%USERPROFILE%/AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\*.*" %folder_name%
      ren "%folder_name%\*.*" "*.jpg"

      REM Adapted from: https://stackoverflow.com/questions/18855048/get-image-file-dimensions-in-bat-file
      copy MediaInfo.x86-i686.exe %folder_name%
      echo.
      cd %folder_name%
      set /a img_tot=0
      set /a img_elim=0
      set /a img_valide=0
      set /a img_orizz=0
      set /a img_vert=0
      set /a img_ric=0
      set /a img_non_ric=0
      REM Valid image sizes (in pixels) [both horizontal and vertical]
      set /a img_dim1=1080
      set /a img_dim2=1920
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
                  echo Horizontal image
                  set /a img_orizz=img_orizz+1
               )   
            ) ELSE (
               IF %%~c EQU !img_dim2! (
                  IF %%~b EQU !img_dim1! (
                     echo Vertical image
                     set /a img_vert=img_vert+1
                  )
               ) ELSE (
                  IF "%%~a" NEQ "MediaInfo.x86-i686.exe" (
                     echo Image neither horizontal nor vertical, deletion in progress...
                     REM The "\\?\" is used to delete files even if the folder and/or file contains whitespace in its name
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
      echo !img_tot! total images of which:
      echo !img_elim! invalid [deleted]
      echo !img_valide! valid [!img_orizz! horizontal and !img_vert! vertical]
      del MediaInfo.x86-i686.exe
      echo ***** DONE *****
      echo.
      PAUSE
   ) ELSE (
      echo.
      echo ATTENTION. FILE MediaInfo.x86-i686.exe NOT FOUND.
      echo THIS FILE MUST BE PLACED IN THE SAME FOLDER AS THE BAT FILE
      echo.
      PAUSE
   )
)
