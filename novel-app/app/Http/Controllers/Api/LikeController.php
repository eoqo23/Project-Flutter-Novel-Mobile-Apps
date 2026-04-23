<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Like;
use App\Models\Novel;

class LikeController extends Controller
{
    // ❤️ like
    public function like(Request $request, $novel_id)
    {
        $novel = Novel::findOrFail($novel_id);

        Like::firstOrCreate([
            'user_id' => $request->user()->id,
            'novel_id' => $novel->id,
        ]);

        return response()->json([
            'message' => 'Liked'
        ]);
    }

    // 💔 unlike
    public function unlike(Request $request, $novel_id)
    {
        Like::where('user_id', $request->user()->id)
            ->where('novel_id', $novel_id)
            ->delete();

        return response()->json([
            'message' => 'Unliked'
        ]);
    }

    // 🔢 total like
    public function count($novel_id)
    {
        $count = Like::where('novel_id', $novel_id)->count();

        return response()->json([
            'likes' => $count
        ]);
    }
}