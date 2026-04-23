<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Chapter;
use App\Models\Novel;
use App\Http\Requests\StoreChapterRequest;
use App\Http\Resources\ChapterResource;

class ChapterController extends Controller
{
    // ✅ LIST chapter per novel
    public function index($novel_id)
    {
        $chapters = Chapter::where('novel_id', $novel_id)
            ->orderBy('chapter_number')
            ->get();

        return ChapterResource::collection($chapters);
    }

    // ✅ CREATE chapter (hanya author)
    public function store(StoreChapterRequest $request)
    {
        $novel = Novel::where('id', $request->novel_id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $chapter = Chapter::create([
            'novel_id' => $novel->id,
            'title' => $request->title,
            'content' => $request->content,
            'chapter_number' => $request->chapter_number,
        ]);

        return new ChapterResource($chapter);
    }

public function show($id)
{
    $chapter = Chapter::withCount('likes')->findOrFail($id);

    // 🔥 Tambah view
    $chapter->increment('view_count');

    $next = Chapter::where('novel_id', $chapter->novel_id)
        ->where('chapter_number', '>', $chapter->chapter_number)
        ->orderBy('chapter_number')
        ->first();

    $prev = Chapter::where('novel_id', $chapter->novel_id)
        ->where('chapter_number', '<', $chapter->chapter_number)
        ->orderByDesc('chapter_number')
        ->first();

    return response()->json([
        'data' => [
            'id' => $chapter->id,
            'novel_id' => $chapter->novel_id,
            'title' => $chapter->title,
            'content' => $chapter->content,
            'chapter_number' => $chapter->chapter_number,
            'likes_count' => $chapter->likes_count ?? 0,
        ],
        'navigation' => [
            'next_id' => $next->id ?? null,
            'prev_id' => $prev->id ?? null,
        ]
    ]);
}

    // ✅ UPDATE chapter (hanya author)
    public function update(StoreChapterRequest $request, $id)
    {
        $chapter = Chapter::findOrFail($id);

        if ($chapter->novel->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }

        $chapter->update($request->validated());

        return new ChapterResource($chapter);
    }

    // ✅ DELETE chapter (hanya author)
    public function destroy(Request $request, $id)
    {
        $chapter = Chapter::findOrFail($id);

        if ($chapter->novel->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }

        $chapter->delete();

        return response()->json([
            'message' => 'Chapter deleted successfully'
        ]);
    }

    // 🔥 NEXT CHAPTER (reader mode)
    public function next($id)
    {
        $current = Chapter::findOrFail($id);

        $next = Chapter::where('novel_id', $current->novel_id)
            ->where('chapter_number', '>', $current->chapter_number)
            ->orderBy('chapter_number')
            ->first();

        if (!$next) {
            return response()->json([
                'message' => 'No next chapter'
            ], 404);
        }

        return new ChapterResource($next);
    }

    // 🔥 PREVIOUS CHAPTER (reader mode)
    public function prev($id)
    {
        $current = Chapter::findOrFail($id);

        $prev = Chapter::where('novel_id', $current->novel_id)
            ->where('chapter_number', '<', $current->chapter_number)
            ->orderByDesc('chapter_number')
            ->first();

        if (!$prev) {
            return response()->json([
                'message' => 'No previous chapter'
            ], 404);
        }

        return new ChapterResource($prev);
    }

    public function addView($id)
{
    $chapter = Chapter::findOrFail($id);
    $chapter->increment('views');

    return response()->json([
        'message' => 'view added'
    ]);
}
    
}