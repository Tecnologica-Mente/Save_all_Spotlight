REM ************************************************************************************************
REM * Questo script salva tutte le Immagini Spotlight archiviate nel tuo Sistema Operativo Windows *
REM *                                                                                              *
REM * Homepage: https://github.com/Tecnologica-Mente                                               *
REM *    Email: <not available>                                                                    *
REM *                                                                                              *
REM ************************************************************************************************
REM *                                                                                              *
REM * NOTA: Per funzionare richiede il file:                                                       *
REM * MediaInfo.x86-i686.exe                                                                       *
REM * da posizionare nella stessa cartella del file bat                                            *
REM *                                                                                              *
REM ************************************************************************************************

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
cls
set folder_name=spotlight_imgs
IF EXIST "%folder_name%\" (
   echo.
   echo ATTENZIONE. ELIMINARE LA CARTELLA %folder_name% PER POTER PROCEDERE CON L'OPERAZIONE
   echo.
   PAUSE
) ELSE (
   IF EXIST "MediaInfo.x86-i686.exe" (   
      md %folder_name%
      echo Copia dei file utili in corso...
      copy /y "%USERPROFILE%/AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\*.*" %folder_name%
      ren "%folder_name%\*.*" "*.jpg"

      REM Tratto da: https://stackoverflow.com/questions/18855048/get-image-file-dimensions-in-bat-file
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
      REM Dimensioni delle immagini valide (in pixel) [sia orizzontali che verticali]
      set /a img_dim1=1080
      set /a img_dim2=1920
      echo Ricerca delle immagini di dimensione !img_dim1!x!img_dim2! pixel [orizzontali] e !img_dim2!x!img_dim1! pixel [verticali] in corso...
      for /r %%a in (*.jpg *.bmp *.png *.gif) do (
         set "width="
         set "height="
         set file1=%%~a
         set /a img_tot=img_tot+1
         for /f "tokens=1*delims=:" %%b in ('"MediaInfo.x86-i686.exe --INFORM=Image;%%Width%%:%%Height%% "%%~a""') do (
            echo Rilevata immagine %%~a [%%~bx%%~c]
            set file2=%%~a
            set /a img_ric=img_ric+1
            REM IF statements do not support logical operators. You can implement a logical OR as described in http://www.robvanderwoude.com/battech_booleanlogic.php
            IF %%~b EQU !img_dim2! (
               IF %%~c EQU !img_dim1! (
                  echo Immagine orizzontale
                  set /a img_orizz=img_orizz+1
               )   
            ) ELSE (
               IF %%~c EQU !img_dim2! (
                  IF %%~b EQU !img_dim1! (
                     echo Immagine verticale
                     set /a img_vert=img_vert+1
                  )
               ) ELSE (
                  IF "%%~a" NEQ "MediaInfo.x86-i686.exe" (
                     echo Immagine ne' orizzontale ne' verticale, eliminazione in corso...
                     REM Il "\\?\" serve ad eliminare i file anche se la cartella e/o il file contengono spazi bianchi nel proprio nome
                     del "\\?\%%~a"
                     set /a img_elim=img_elim+1
                  )
               )
            )
         )
         IF "!file1!" NEQ "!file2!" (
            echo File rilevato non riconosciuto come immagine %%~a
            echo Eliminazione file non riconosciuto %%~a
            del "\\?\%%~a"
            set /a img_elim=img_elim+1
         )
         REM set "file1="
         REM set "file2="
      )
      echo.
      set /a img_valide=img_tot-img_elim
      set /a img_non_ric=img_tot-img_ric
      echo !img_tot! immagini totali di cui:
      echo !img_elim! non valide [eliminate]
      echo !img_valide! valide [!img_orizz! orizzontali e !img_vert! verticali]
      del MediaInfo.x86-i686.exe
      echo ***** DONE *****
      echo.
      PAUSE
   ) ELSE (
      echo.
      echo ATTENZIONE. FILE MediaInfo.x86-i686.exe NON TROVATO.
      echo TALE FILE VA POSIZIONATO NELLA STESSA CARTELLA DEL FILE BAT
      echo.
      PAUSE
   )
)
