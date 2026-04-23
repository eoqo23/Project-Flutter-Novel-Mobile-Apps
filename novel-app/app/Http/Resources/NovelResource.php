<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\ChapterResource;

class NovelResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
public function toArray($request): array
{
    return [
        'id' => $this->id,
        'title' => $this->title,
        'description' => $this->description,

        // 🔗 author
        'author' => $this->author->name ?? null,

        // 🔥 COVER FIX
        'cover' => $this->cover_image
            ? asset('storage/' . $this->cover_image)
            : asset('images/default_cover.jpg'),

        // ❤️ LIKE & 👁️ VIEW (NOVEL)
        'likes_count' => $this->likes_count ?? 0,
        'view_count' => $this->view_count ?? 0,

        'genres' => $this->whenLoaded('genres', function () {
    return $this->genres->map(function ($genre) {
        return [
            'id' => $genre->id,
            'name' => $genre->name,
        ];
    });
}),

        // 📚 CHAPTERS
        'chapters' => $this->whenLoaded('chapters', function () {
            return $this->chapters->map(function ($chapter) {
                return [
                    'id' => $chapter->id,
                    'title' => $chapter->title,
                    'chapter_number' => $chapter->chapter_number,

                    // 🔥 FIX: ambil dari chapter
                    'view_count' => $chapter->view_count ?? 0,
                    'likes_count' => $chapter->likes()->count(),
                ];
            });
        }),
    ];
}
}

