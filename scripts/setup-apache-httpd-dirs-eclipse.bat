@echo off

mkdir "%USERPROFILE%\programs\apache-httpd\www\www-eclipse"

rmdir "%USERPROFILE%\programs\apache-httpd\www\www-eclipse\kame-house"
mklink /D "%USERPROFILE%\programs\apache-httpd\www\www-eclipse\kame-house" "%USERPROFILE%\workspace-eclipse\kamehouse\kamehouse-ui\src\main\webapp"

rmdir "%USERPROFILE%\programs\apache-httpd\www\www-eclipse\kame-house-groot"
mklink /D "%USERPROFILE%\programs\apache-httpd\www\www-eclipse\kame-house-groot" "%USERPROFILE%\workspace-eclipse\kamehouse\kamehouse-groot\public\kame-house-groot"

pause