@echo off
echo Creating Flutter project structure for mu_kiks...

REM Create main directories
mkdir lib\core\constants
mkdir lib\core\utils
mkdir lib\models
mkdir lib\services
mkdir lib\providers
mkdir lib\views\home\widgets
mkdir lib\views\now_playing
mkdir lib\views\playlist
mkdir lib\views\settings
mkdir lib\config
mkdir assets\icons
mkdir assets\images

REM Create core files
echo. > lib\core\constants\colors.dart
echo. > lib\core\constants\styles.dart
echo. > lib\core\constants\app_strings.dart
echo. > lib\core\utils\file_utils.dart
echo. > lib\core\utils\permission_utils.dart
echo. > lib\core\utils\logger.dart

REM Create model files
echo. > lib\models\song_model.dart
echo. > lib\models\playlist_model.dart
echo. > lib\models\queue_model.dart

REM Create service files
echo. > lib\services\audio_service.dart
echo. > lib\services\music_scanner.dart
echo. > lib\services\playlist_service.dart

REM Create provider files
echo. > lib\providers\player_provider.dart
echo. > lib\providers\playlist_provider.dart
echo. > lib\providers\theme_provider.dart

REM Create view files
echo. > lib\views\home\home_screen.dart
echo. > lib\views\home\widgets\song_tile.dart
echo. > lib\views\home\widgets\duration_slider.dart
echo. > lib\views\now_playing\now_playing_screen.dart
echo. > lib\views\playlist\playlist_screen.dart
echo. > lib\views\settings\settings_screen.dart

REM Create config files
echo. > lib\config\theme.dart

echo.
echo Flutter project structure created successfully!
echo.
echo Directory structure:
tree /f lib
echo.
echo Assets directories:
tree /f assets
echo.
echo All files have been created as empty files.
echo You can now start implementing your Flutter music app!
pause