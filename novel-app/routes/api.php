<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\NovelController;
use App\Http\Controllers\Api\ChapterController;
use App\Http\Controllers\Api\PublicNovelController;
use App\Http\Controllers\Api\BookmarkController;
use App\Http\Controllers\Api\LikeController;
use App\Http\Controllers\Api\CommentController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\GenreController;
use App\Models\Genre;

/*
|--------------------------------------------------------------------------
| 🌍 PUBLIC ROUTES
|--------------------------------------------------------------------------
*/

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/public/novels', [PublicNovelController::class, 'index']);
Route::get('/public/novels/{id}', [PublicNovelController::class, 'show']);
Route::get('/search/novels', [PublicNovelController::class, 'search']);
Route::get('/novels/{id}/likes', [LikeController::class, 'count']);
Route::get('/novels/{id}/comments', [CommentController::class, 'index']);
Route::get('/novels/{novel_id}/chapters', [ChapterController::class, 'index']);
Route::get('/genres', [GenreController::class, 'index']);


/*
|--------------------------------------------------------------------------
| 🔐 AUTH ROUTES
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {

    // 🔐 Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // 👤 Profile
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/change-password', [ProfileController::class, 'changePassword']);

    // 📚 Novel
    Route::apiResource('novels', NovelController::class);
    Route::post('/novels/{id}/cover', [NovelController::class, 'uploadCover']);

    // 📖 Chapter
    Route::apiResource('chapters', ChapterController::class)->except(['index']);
    Route::get('/chapters/{id}', [ChapterController::class, 'show']);
    Route::get('/chapters/{id}/next', [ChapterController::class, 'next']);
    Route::get('/chapters/{id}/prev', [ChapterController::class, 'prev']);

    // ⭐ Bookmark
    Route::get('/bookmarks', [BookmarkController::class, 'index']);
Route::post('/bookmarks', [BookmarkController::class, 'store']);
Route::delete('/bookmarks/{chapterId}', [BookmarkController::class, 'destroy']);

    // ❤️ Like
    Route::post('/novels/{id}/like', [LikeController::class, 'like']);
    Route::delete('/novels/{id}/like', [LikeController::class, 'unlike']);

    // 💬 Comment
    Route::post('/novels/{id}/comments', [CommentController::class, 'store']);
    Route::delete('/comments/{id}', [CommentController::class, 'destroy']);

    // 🌟 Favorite
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::delete('/favorites/{novel_id}', [FavoriteController::class, 'destroy']);

    // 🖋️ Author
      Route::get('/my-novels', [NovelController::class, 'index']); // <-- endpoint author
    Route::post('/novels', [NovelController::class, 'store']);
    Route::get('/novels/{id}', [NovelController::class, 'show']);
    Route::put('/novels/{id}', [NovelController::class, 'update']);
    Route::delete('/novels/{id}', [NovelController::class, 'destroy']);
    Route::post('/novels/{id}/cover', [NovelController::class, 'uploadCover']);

    // 👑 Admin

    Route::get('/admin/novels', [NovelController::class, 'adminIndex']);
    Route::put('/admin/novels/{id}/status', [NovelController::class, 'updateStatus']);
    Route::delete('/admin/novels/{id}', [NovelController::class, 'adminDelete']);
});