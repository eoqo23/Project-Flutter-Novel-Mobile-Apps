<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Novel;
use App\Http\Resources\NovelResource;
use Illuminate\Http\Request;

class PublicNovelController extends Controller
{
    // ✅ LIST semua novel published
    public function index()
    {
        $novels = Novel::where('status', 'published')
            ->latest()
            ->paginate(15);

        return NovelResource::collection($novels);
    }

    // ✅ DETAIL novel + chapters
    public function show($id)
{
    $novel = Novel::with('chapters')
        ->where('id', $id)
        ->where('status', 'published')
        ->firstOrFail();

    // 👁️ tambah view
    $novel->increment('view_count');

    return new \App\Http\Resources\NovelResource($novel);
}

public function search(Request $request)
{
    $keyword = strtolower($request->q);

    // 🔥 1. handle kosong
    if (!$keyword) {
        return response()->json([
            'message' => 'Keyword is required'
        ], 400);
    }

    $novels = \App\Models\Novel::where('status', 'published')
        ->where(function ($query) use ($keyword) {
            $query->where('title', 'like', "%$keyword%")
                  ->orWhere('description', 'like', "%$keyword%");
        })
        ->latest()
        ->paginate(10) // 🔥 3. limit
        ->get();

    return \App\Http\Resources\NovelResource::collection($novels);
}
}