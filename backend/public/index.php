<?php

declare(strict_types=1);

/**
 * Smart Child Hub – REST API front controller.
 *
 * All API traffic is routed through this file. Requires PHP 8+.
 *
 * Local dev (XAMPP / built-in server):
 *   php -S localhost:8080 -t backend/public backend/public/index.php
 */

use SmartChildHub\Config\Config;
use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Request;
use SmartChildHub\Core\Response;
use SmartChildHub\Core\Router;

define('APP_ROOT', dirname(__DIR__));

// PSR-4 autoloader for the SmartChildHub\ namespace.
spl_autoload_register(static function (string $class): void {
    $prefix = 'SmartChildHub\\';
    if (strncmp($class, $prefix, strlen($prefix)) !== 0) {
        return;
    }
    $relative = substr($class, strlen($prefix));
    $file = APP_ROOT . '/app/' . str_replace('\\', '/', $relative) . '.php';
    if (is_file($file)) {
        require $file;
    }
});

// Apply deployment environment variables (DB credentials, debug mode, CORS,
// public URL) over the local defaults in app/config/config.php.
Config::load();

// Convert every unhandled error into an AppException for the global handler.
set_exception_handler(static function (Throwable $e): never {
    if ($e instanceof AppException) {
        Response::error($e->getMessage(), $e->httpStatus(), $e->errors());
    }

    // Never leak internals when not debugging; log them server side instead.
    if (!Config::$APP_DEBUG) {
        error_log(sprintf(
            '[smart-child-hub] %s: %s in %s:%d',
            get_class($e),
            $e->getMessage(),
            $e->getFile(),
            $e->getLine()
        ));
    }

    $message = Config::$APP_DEBUG ? $e->getMessage() : 'An unexpected server error occurred.';
    Response::error($message, 500);
});

// Bare-minimum CORS for OPTIONS handled before routing.
$request = new Request();

if ($request->method() === 'OPTIONS') {
    Response::noContent('Preflight OK');
}

// Serve uploaded child photos from /uploads/* (public static files).
//
// Photos are fetched by <img>/Image.network, which cannot attach the bearer
// token, so this endpoint is intentionally unauthenticated. Confidentiality
// relies on unguessable filenames (child id + 12 random bytes). Only the three
// formats the upload handler can produce are ever served, and nosniff stops a
// browser from re-interpreting a file as HTML or SVG.
$uploadsDir = __DIR__ . '/uploads';
$uploadsRoot = realpath($uploadsDir) ?: null;
$uploadedPath = realpath($uploadsDir . '/' . substr($request->path(), strlen('uploads/')));
$uploadMime = ['jpg' => 'image/jpeg', 'png' => 'image/png', 'webp' => 'image/webp'];
if (
    str_starts_with($request->path(), 'uploads/')
    && $uploadsRoot !== null
    && $uploadedPath !== false
    && str_starts_with($uploadedPath, $uploadsRoot . DIRECTORY_SEPARATOR)
    && is_file($uploadedPath)
) {
    $ext = strtolower(pathinfo($uploadedPath, PATHINFO_EXTENSION));
    if (isset($uploadMime[$ext])) {
        header('Content-Type: ' . $uploadMime[$ext]);
        header('Content-Length: ' . (string) filesize($uploadedPath));
        header('X-Content-Type-Options: nosniff');
        header('Content-Disposition: inline');
        header('Cache-Control: private, max-age=86400');
        readfile($uploadedPath);
        exit;
    }
    http_response_code(404);
    exit;
}

$router = new Router();

// --- Auth -------------------------------------------------------------------
$router->post('/api/auth/register',         SmartChildHub\Controllers\AuthController::class, 'register');
$router->post('/api/auth/login',            SmartChildHub\Controllers\AuthController::class, 'login');
$router->post('/api/auth/child-login',      SmartChildHub\Controllers\AuthController::class, 'childLogin');
$router->post('/api/auth/logout',           SmartChildHub\Controllers\AuthController::class, 'logout');
$router->post('/api/auth/forgot-password',  SmartChildHub\Controllers\AuthController::class, 'forgotPassword');
$router->post('/api/auth/reset-password',   SmartChildHub\Controllers\AuthController::class, 'resetPassword');
$router->post('/api/auth/change-password',  SmartChildHub\Controllers\AuthController::class, 'changePassword');
$router->get('/api/auth/me',                SmartChildHub\Controllers\AuthController::class, 'me');

// --- Child PIN self-service recovery ----------------------------------------
$childRecovery = SmartChildHub\Controllers\ChildRecoveryController::class;
$router->post('/api/auth/child-recovery/questions', $childRecovery, 'questions');
$router->post('/api/auth/child-recovery/verify',    $childRecovery, 'verify');
$router->post('/api/auth/child-recovery/reset',     $childRecovery, 'reset');

// --- Parent ---------------------------------------------------------------
$router->get('/api/parent/profile',         SmartChildHub\Controllers\ParentController::class, 'profile');
$router->put('/api/parent/profile',         SmartChildHub\Controllers\ParentController::class, 'updateProfile');
$router->get('/api/parent/dashboard',       SmartChildHub\Controllers\ParentController::class, 'dashboard');
$router->get('/api/parent/children',        SmartChildHub\Controllers\ParentController::class, 'children');
$router->post('/api/parent/children',       SmartChildHub\Controllers\ParentController::class, 'storeChild');
$router->get('/api/parent/children/{id}',   SmartChildHub\Controllers\ParentController::class, 'showChild');
$router->put('/api/parent/children/{id}',   SmartChildHub\Controllers\ParentController::class, 'updateChild');
$router->put('/api/parent/children/{id}/pin', SmartChildHub\Controllers\ParentController::class, 'changeChildPin');
$router->get('/api/parent/children/{id}/security-questions', SmartChildHub\Controllers\ParentController::class, 'childSecurityQuestions');
$router->post('/api/parent/children/{id}/photo', SmartChildHub\Controllers\ParentController::class, 'uploadChildPhoto');
$router->delete('/api/parent/children/{id}/photo', SmartChildHub\Controllers\ParentController::class, 'removeChildPhoto');
$router->delete('/api/parent/children/{id}', SmartChildHub\Controllers\ParentController::class, 'destroyChild');

// --- Child activities -----------------------------------------------------
$child = SmartChildHub\Controllers\ChildActivityController::class;
$router->get('/api/children/{id}/activities',       $child, 'activities');
$router->post('/api/children/{id}/activities',      $child, 'storeActivity');
$router->get('/api/children/{id}/activities/{aId}', $child, 'showActivity');
$router->put('/api/children/{id}/activities/{aId}', $child, 'updateActivity');
$router->delete('/api/children/{id}/activities/{aId}', $child, 'destroyActivity');

$router->get('/api/children/{id}/sleep',   $child, 'sleep');
$router->post('/api/children/{id}/sleep',  $child, 'storeSleep');
$router->get('/api/sleep/{id}',   $child, 'showSleep');
$router->put('/api/sleep/{id}',   $child, 'updateSleep');
$router->delete('/api/sleep/{id}', $child, 'destroySleep');

$router->get('/api/children/{id}/meals',  $child, 'meals');
$router->post('/api/children/{id}/meals', $child, 'storeMeal');
$router->get('/api/meals/{id}',   $child, 'showMeal');
$router->put('/api/meals/{id}',   $child, 'updateMeal');
$router->delete('/api/meals/{id}', $child, 'destroyMeal');

$router->get('/api/children/{id}/water',  $child, 'water');
$router->post('/api/children/{id}/water', $child, 'storeWater');
$router->get('/api/water/{id}',   $child, 'showWater');
$router->put('/api/water/{id}',   $child, 'updateWater');
$router->delete('/api/water/{id}', $child, 'destroyWater');

$router->get('/api/children/{id}/moods',  $child, 'moods');
$router->post('/api/children/{id}/moods', $child, 'storeMood');
$router->get('/api/moods/{id}',   $child, 'showMood');
$router->put('/api/moods/{id}',   $child, 'updateMood');
$router->delete('/api/moods/{id}', $child, 'destroyMood');

$router->get('/api/children/{id}/homework',  $child, 'homework');
$router->post('/api/children/{id}/homework', $child, 'storeHomework');
$router->get('/api/homework/{id}',   $child, 'showHomework');
$router->put('/api/homework/{id}',   $child, 'updateHomework');
$router->delete('/api/homework/{id}', $child, 'destroyHomework');

$router->get('/api/children/{id}/attendance',  $child, 'attendance');
$router->post('/api/children/{id}/attendance', $child, 'storeAttendance');
$router->get('/api/attendance/{id}',   $child, 'showAttendance');
$router->put('/api/attendance/{id}',   $child, 'updateAttendance');
$router->delete('/api/attendance/{id}', $child, 'destroyAttendance');

$router->get('/api/children/{id}/screen-time',  $child, 'screenTime');
$router->post('/api/children/{id}/screen-time', $child, 'storeScreenTime');
$router->get('/api/screen-time/{id}',   $child, 'showScreenTime');
$router->put('/api/screen-time/{id}',   $child, 'updateScreenTime');
$router->delete('/api/screen-time/{id}', $child, 'destroyScreenTime');

// --- Notifications ---------------------------------------------------------
$notifications = SmartChildHub\Controllers\NotificationController::class;
$router->get('/api/notifications',               $notifications, 'index');
$router->post('/api/notifications',              $notifications, 'store');
$router->get('/api/notifications/unread-count',  $notifications, 'unreadCount');
$router->put('/api/notifications/read-all',      $notifications, 'markAllRead');
$router->get('/api/notifications/{id}',          $notifications, 'show');
$router->put('/api/notifications/{id}',          $notifications, 'update');
$router->put('/api/notifications/{id}/read',     $notifications, 'markRead');
$router->delete('/api/notifications/{id}',       $notifications, 'destroy');

// --- Reports ---------------------------------------------------------------
$reports = SmartChildHub\Controllers\ReportController::class;
$router->get('/api/children/{id}/reports/history', $reports, 'history');
$router->get('/api/children/{id}/reports/{type}',  $reports, 'show');

// --- Health -----------------------------------------------------------------
$router->get('/api/health', static function (Request $request): never {
    Response::success([
        'service' => 'Smart Child Hub API',
        'status'  => 'ok',
        'time'    => date('Y-m-d\TH:i:s'),
    ], 200, 'API is healthy.');
});

$router->dispatch($request);
