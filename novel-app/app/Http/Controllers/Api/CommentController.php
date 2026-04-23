<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Comment;
use App\Models\Novel;

class CommentController extends Controller
{
    // 📚 list komentar
    public function index($novel_id)
    {
        $comments = Comment::with('user')
            ->where('novel_id', $novel_id)
            ->latest()
            ->get();

        return response()->json($comments);
    }

    // 💬 tambah komentar
    public function store(Request $request, $novel_id)
    {
        $request->validate([
            'content' => 'required|string'
        ]);

        $novel = Novel::findOrFail($novel_id);

        $comment = Comment::create([
            'user_id' => $request->user()->id,
            'novel_id' => $novel->id,
            'content' => $request->content,
        ]);

        return response()->json($comment);
    }

    // ❌ hapus komentar
    public function destroy(Request $request, $id)
    {
        $comment = Comment::findOrFail($id);

        if ($comment->user_id !== $request->user()->id) {
            abort(403, 'Unauthorized');
        }

        $comment->delete();

        return response()->json([
            'message' => 'Comment deleted'
        ]);
    }
}