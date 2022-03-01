@echo off
set HOST=127.0.0.1
set PORT=58526
set REMOTE_PATH=/storage/emulated/0/Shared/
setlocal enabledelayedexpansion

FOR /F %%a IN ('powershell -command "$([guid]::NewGuid().ToString().SubString(0,13).Trim())"') DO (set UID=%%a)

if %1=="" (
   FOR /F %%i IN ('powershell -sta "add-type -as System.Windows.Forms; [windows.forms.clipboard]::ContainsImage()"') DO (
      if "%%i"=="True" (
         powershell -sta "add-type -as System.Windows.Forms; [windows.forms.clipboard]::GetImage().Save('clipboard-%UID%.png', [System.Drawing.Imaging.ImageFormat]::Png)"
         adb connect %HOST%:%PORT%
         adb push clipboard-%UID%.png %REMOTE_PATH%clipboard-%UID%.png
         adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file://%REMOTE_PATH%clipboard-%UID%.png
         del clipboard-%UID%.png
      ) else (
         adb connect %HOST%:%PORT%
         FOR /F "tokens=*" %%a IN ('powershell -sta "add-type -as System.Windows.Forms; [windows.forms.clipboard]::GetFileDropList()"') DO (
            adb push "%%a" "%REMOTE_PATH%%%~na-!UID!%%~xa"
            adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://%REMOTE_PATH%%%~na-!UID!%%~xa"
            FOR /F %%a IN ('powershell -command "$([guid]::NewGuid().ToString().SubString(0,13).Trim())"') DO (set UID=%%a)
         )
      )
   )   
) else (
   adb connect %HOST%:%PORT%
   FOR %%i IN (%*) DO (
      if exist %%i (
         adb push %%i "%REMOTE_PATH%%%~ni-!UID!%%~xi"
         adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://%REMOTE_PATH%%%~ni-!UID!%%~xi"
         FOR /F %%a IN ('powershell -command "$([guid]::NewGuid().ToString().SubString(0,13).Trim())"') DO (set UID=%%a)
      )
   )
)