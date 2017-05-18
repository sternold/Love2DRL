@ECHO ON

CD /D "C:\Program Files\7-Zip"

SET SourceDir=%1
SET DestDir=%2

7z.exe a -tzip "%DestDir%\build.love" -r "%SourceDir%\*.*"