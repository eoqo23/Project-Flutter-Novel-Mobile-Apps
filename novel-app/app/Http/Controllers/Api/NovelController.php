<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Novel;
use App\Models\Favorite; // ✅ FIX
use App\Http\Requests\StoreNovelRequest;
use App\Http\Resources\NovelResource;

class NovelController extends Controller
{
    // ================================
    // HELPER FAVORITE
    // ================================
    private function attachFavoriteStatus($novels, $userId)
    {
        if (!$userId) return $novels;

        $favoriteIds = Favorite::where('user_id', $userId)
            ->pluck('novel_id')
            ->toArray();

        return $novels->map(function ($novel) use ($favoriteIds) {
            $novel->is_favorited = in_array($novel->id, $favoriteIds);
            return $novel;
        });
    }

    // ================================
    // AUTHOR - GET MY NOVELS
    // ================================
    public function index(Request $request)
    {
        $keyword = $request->query('search');

        $novels = Novel::with(['author'])
            ->where('user_id', $request->user()->id)
            ->when($keyword, function ($query, $keyword) {
                return $query->where('title', 'like', "%{$keyword}%")
                    ->orWhereHas('author', function ($q) use ($keyword) {
                        $q->where('name', 'like', "%{$keyword}%");
                    });
            })
            ->latest()
            ->get();

        // ✅ FAVORITE
        $novels = $this->attachFavoriteStatus($novels, $request->user()->id);

        // 🔥 Fix cover
        $novels->transform(function ($novel) {
    if ($novel->cover_image) {
        $novel->cover = url('storage/' . $novel->cover_image);
    } else {
        $novel->cover = null;
    }

    return $novel;
});

        return response()->json([
            'data' => $novels
        ]);
    }

    // ================================
    // CREATE
    // ================================
    public function store(StoreNovelRequest $request)
    {
        $coverPath = null;

        if ($request->hasFile('cover')) {
            $coverPath = $request->file('cover')->store('covers', 'public');
        }

        $novel = Novel::create([
            'user_id' => $request->user()->id,
            'title' => $request->title,
            'description' => $request->description,
            'status' => $request->status ?? 'draft',
            'cover_image' => $coverPath,
        ]);

        // 🔥 attach genre
        if ($request->has('genres')) {
            $novel->genres()->sync($request->genres);
        }

        $novel->load(['author', 'genres', 'chapters', 'chapters.likes']);

        return new NovelResource($novel);
    }

    // ================================
    // UPDATE
    // ================================
     public function update(StoreNovelRequest $request, $id)
    {
        $novel = Novel::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $novel->update([
            'title' => $request->title,
            'description' => $request->description,
            'status' => $request->status ?? $novel->status,
        ]);

        // 🔥 update genre juga
        if ($request->has('genres')) {
            $novel->genres()->sync($request->genres);
        }

        $novel->load(['author', 'genres', 'chapters', 'chapters.likes']);

        return new NovelResource($novel);
    }
    // ================================
    // DELETE
    // ================================
    public function destroy(Request $request, $id)
    {
        $novel = Novel::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $novel->delete();

        return response()->json([
            'message' => 'Novel deleted successfully'
        ]);
    }

    // ================================
    // ADMIN - GET ALL NOVELS
    // ================================
     public function adminIndex(Request $request)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $novels = Novel::with([
                'author',
                'genres' // 🔥 FIX
            ])
            ->latest()
            ->get();

        $novels = $this->attachFavoriteStatus($novels, $request->user()->id);

        return response()->json([
            'data' => $novels
        ]);
    }

    // ================================
    // ADMIN - UPDATE STATUS
    // ================================
    public function updateStatus(Request $request, $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $novel = Novel::findOrFail($id);

        $novel->update([
            'status' => $request->status
        ]);

        return response()->json([
            'message' => 'Status updated',
            'status' => $novel->status
        ]);
    }

    // ================================
    // ADMIN - DELETE
    // ================================
    public function adminDelete(Request $request, $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $novel = Novel::findOrFail($id);
        $novel->delete();

        return response()->json([
            'message' => 'Deleted'
        ]);
    }

    // ================================
    // SEARCH (READER)
    // ================================
    public function search(Request $request)
    {
        $search = $request->input('search');

        $novels = Novel::with(['author', 'chapters', 'chapters.likes', 'genres'])
            ->when($search, function ($query, $search) {
                return $query->where('title', 'like', "%$search%")
                    ->orWhere('description', 'like', "%$search%");
            })
            ->latest()
            ->get();

        // ✅ FAVORITE
        $novels = $this->attachFavoriteStatus($novels, $request->user()?->id);

        return response()->json([
            'data' => $novels
        ]);
    }
}