@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script
@REM ----------------------------------------------------------------------------
@echo off
set ERROR_CODE=0
set MAVEN_PROJECTBASEDIR=%~dp0
if "%MAVEN_PROJECTBASEDIR%"=="" set MAVEN_PROJECTBASEDIR=%CD%

IF NOT "%JAVA_HOME%"=="" goto OkJHome
set JAVA_HOME=C:\Program Files\Java\jdk-25
:OkJHome

set MAVEN_CMD=C:\Users\Darshit\maven\apache-maven-3.9.12\bin\mvn.cmd
if exist "%MAVEN_CMD%" (
    "%MAVEN_CMD%" %*
) else (
    mvn %*
)
