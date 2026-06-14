@echo off
chcp 65001 >nul
echo ============================================
echo  MemoPro Mobile - Android APK 构建脚本
echo ============================================
echo.

:: 检查 Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [1/4] Flutter 未安装，正在下载...
    
    if not exist "%USERPROFILE%\flutter\bin\flutter.bat" (
        echo 下载 Flutter SDK (约 1GB)...
        powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.0-stable.zip' -OutFile '%TEMP%\flutter.zip'"
        echo 解压中...
        powershell -Command "Expand-Archive -Path '%TEMP%\flutter.zip' -DestinationPath '%USERPROFILE%' -Force"
        del "%TEMP%\flutter.zip" 2>nul
    )
    
    set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
    echo Flutter 安装完成!
) else (
    echo [1/4] Flutter 已安装
)

:: 检查 Java / Android SDK
echo [2/4] 检查环境...
flutter doctor --android-licenses 2>nul

:: 安装依赖
echo [3/4] 安装 Flutter 依赖...
cd /d "%~dp0"
call flutter pub get
if %errorlevel% neq 0 (
    echo 依赖安装失败!
    pause
    exit /b 1
)

:: 构建 APK
echo [4/4] 构建 Android APK...
call flutter build apk --release --split-per-abi
if %errorlevel% neq 0 (
    echo 构建失败! 请检查错误信息。
    pause
    exit /b 1
)

echo.
echo ============================================
echo  构建成功!
echo  APK 文件位置:
echo    build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo    build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
echo    build\app\outputs\flutter-apk\app-x86_64-release.apk
echo ============================================

:: 打开 APK 文件夹
explorer "%~dp0build\app\outputs\flutter-apk"
pause
