@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title CRM PRO - He Thong Quan Ly Khach Hang

echo =====================================================================
echo                 KHOI DONG DU AN CRM PRO
echo =====================================================================
echo.

set PHP_CMD=

rem Kiem tra PHP trong PATH
where php.exe >nul 2>&1
if not errorlevel 1 set PHP_CMD=php.exe

rem Kiem tra cac thu muc cai dat PHP pho bien (D:, C:, E:, Laragon)
if not defined PHP_CMD if exist "D:\xampp\php\php.exe" set PHP_CMD=D:\xampp\php\php.exe
if not defined PHP_CMD if exist "C:\xampp\php\php.exe" set PHP_CMD=C:\xampp\php\php.exe
if not defined PHP_CMD if exist "E:\xampp\php\php.exe" set PHP_CMD=E:\xampp\php\php.exe
if not defined PHP_CMD if exist "C:\laragon\bin\php\php.exe" set PHP_CMD=C:\laragon\bin\php\php.exe
if not defined PHP_CMD if exist "D:\laragon\bin\php\php.exe" set PHP_CMD=D:\laragon\bin\php\php.exe

if not defined PHP_CMD (
    echo [LOI] Khong tim thay trinh thuc thi PHP tren may tinh!
    echo Vui long cai dat XAMPP hoac them PHP vao bien moi truong PATH.
    echo.
    pause
    exit /b 1
)

echo [OK] Tim thay PHP: !PHP_CMD!
echo.

rem Kiem tra va bat MySQL service neu chua chay tren cong 3306/3307
netstat -ano | findstr /r /c:":3306 .*LISTENING" >nul 2>&1
if errorlevel 1 (
    netstat -ano | findstr /r /c:":3307 .*LISTENING" >nul 2>&1
    if errorlevel 1 (
        echo [*] Dang khoi dong dich vu MySQL...
        for %%S in (MySQL94 MySQL84 MySQL80 MySQL) do (
            sc query "%%S" >nul 2>&1
            if not errorlevel 1 net start "%%S" >nul 2>&1
        )
        timeout /t 3 /nobreak >nul
    )
)

echo [*] Kiem tra ket noi MySQL va co so du lieu...
"!PHP_CMD!" "%~dp0auto_setup.php"
if errorlevel 1 (
    echo.
    echo [CANH BAO] Thiet lap CSDL tu dong gap su co.
    echo Vui long kiem tra MySQL da bat chua, hoac import database.sql bang phpMyAdmin!
    echo.
    pause
)
echo.

rem Tu dong chon cong (neu cong 8000 dang bi chiem boi du an khac thi chuyen sang 8080 hoac 8088)
set "PORT=8000"
netstat -ano | findstr /r /c:":8000 .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    set "PORT=8080"
    netstat -ano | findstr /r /c:":8080 .*LISTENING" >nul 2>&1
    if not errorlevel 1 set "PORT=8088"
)

echo =====================================================================
echo   He thong dang chay tai: http://localhost:%PORT%/login.php
echo.
echo   Tai khoan dang nhap mau:
echo     - Quan tri vien (Admin): admin     /  admin123
echo     - Nhan vien 1   (Staff): staff_nam /  staff123
echo     - Nhan vien 2   (Staff): staff_hoa /  staff123
echo.
echo   Luu y: Giu cua so nay mo trong suot qua trinh su dung.
echo          Nhan Ctrl + C de tat may chu.
echo =====================================================================
echo.

timeout /t 2 >nul
start http://localhost:%PORT%/login.php

pushd "%~dp0"
"!PHP_CMD!" -S localhost:%PORT%
if errorlevel 1 (
    echo.
    echo [LOI] Khong the khoi dong may chu PHP tren cong %PORT%!
    echo Co the cong %PORT% dang bi chiem dung boi mot chuong trinh khac.
    pause
)
popd
