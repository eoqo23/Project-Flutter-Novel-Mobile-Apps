<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BookmarkController extends Controller
{
    // ================= GET ALL =================
 public function index(Request $request)
{
    $user = $request->user();

    $bookmarks = Bookmark::with(['novel', 'chapter'])
        ->where('user_id', $user->id)
        ->latest()
        ->get()
        ->map(function ($b) {

            $novel = $b->novel;
            $chapter = $b->chapter;

            return [
                'id' => $b->id,

                'novel_id' => $b->novel_id,
                'chapter_id' => $b->chapter_id,

                // ===== NOVEL =====
                'novel_title' => $novel?->title,

                // 🔥 FIX COVER (biar sama kayak favorite)
                'cover' => $novel?->cover_image
                    ? url('storage/' . $novel->cover_image)
                    : null,

                // ===== CHAPTER =====
                'chapter_title' => $chapter?->title,

                // 🔥 INI FIX UTAMA
                'chapter_number' => $chapter?->chapter_number,

            ];
        });

    return response()->json($bookmarks);
}

    // ================= STORE =================
    public function store(Request $request)
    {
        $user = Auth::guard('sanctum')->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthorized - token tidak terbaca'
            ], 401);
        }

        $request->validate([
            'novel_id' => 'required|exists:novels,id',
            'chapter_id' => 'required|exists:chapters,id',
        ]);

        // 🔥 Cek duplicate (per chapter)
        $exists = Bookmark::where('user_id', $user->id)
            ->where('chapter_id', $request->chapter_id)
            ->exists();

        if ($exists) {
            return response()->json([
                'message' => 'Already bookmarked'
            ], 409);
        }

        Bookmark::create([
            'user_id' => $user->id,
            'novel_id' => $request->novel_id,
            'chapter_id' => $request->chapter_id,
        ]);

        return response()->json([
            'message' => 'Bookmark saved'
        ]);
    }

    // ================= DELETE =================
    public function destroy($chapterId)
    {
        $user = Auth::guard('sanctum')->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthorized - token tidak terbaca'
            ], 401);
        }

        $deleted = Bookmark::where('user_id', $user->id)
            ->where('chapter_id', $chapterId)
            ->delete();

        if (!$deleted) {
            return response()->json([
                'message' => 'Bookmark tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'message' => 'Bookmark removed'
        ]);
    }
}