<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Novel;
use App\Models\Favorite;

class FavoriteController extends Controller
{
    public function store(Request $request)
{
    $request->validate([
        'novel_id' => 'required|exists:novels,id'
    ]);

    $favorite = Favorite::firstOrCreate([
        'user_id' => $request->user()->id,
        'novel_id' => $request->novel_id
    ]);

    return response()->json($favorite);
}

public function index(Request $request)
{
    $favorites = Favorite::with('novel')
        ->where('user_id', $request->user()->id)
        ->get();

    // 🔥 FIX cover + favorite status
    $favorites->transform(function ($fav) {
    if ($fav->novel) {

        // 🔥 PAKAI cover_image
        if ($fav->novel->cover_image) {
            $fav->novel->cover = url('storage/' . $fav->novel->cover_image);
        } else {
            $fav->novel->cover = null;
        }

        $fav->novel->is_favorited = true;
    }

    return $fav;
});

    return response()->json($favorites);
}

public function destroy(Request $request, $id)
{
    $favorite = Favorite::where('user_id', $request->user()->id)
        ->where('novel_id', $id)
        ->first();

    if ($favorite) {
        $favorite->delete();
    }

    return response()->json(['message' => 'removed']);
}
}
