@echo off
REM run.bat
REM Uso:
REM   run.bat QA1
REM   run.bat QA2 mobile
REM   run.bat QA3 web smoke

set ENV=%1
if "%ENV%"=="" set ENV=QA1

set TYPE=%2
if "%TYPE%"=="" set TYPE=web

set TAG=%3

set ENV_LOWER=%ENV%
call :tolower ENV_LOWER

for /f "tokens=2 delims==" %%I in ('"wmic os get LocalDateTime /value | find "=" "') do set DT=%%I
set OUTDIR=results\%ENV_LOWER%_%TYPE%_%DT:~0,14%

set EXTRA=
if not "%TAG%"=="" set EXTRA=--include %TAG%

echo Executando: ENV=%ENV% TYPE=%TYPE% TAG=%TAG%
echo Saida: %OUTDIR%

robot ^
  --variablefile resources\variables\env_loader.py:%ENV% ^
  --variable ENV:%ENV% ^
  -V environments\%ENV_LOWER%.robot ^
  -d %OUTDIR% ^
  %EXTRA% ^
  tests\%TYPE%

goto :eof

:tolower
for %%a in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") do (
  call set %1=%%%1:%%~a%%
)
goto :eof
