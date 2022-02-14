@echo OFF
setlocal DISABLEDELAYEDEXPANSION
php "%~dp0\bin\console.php" %*
pause
