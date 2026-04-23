<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\NovelResource;

class ChapterResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'content' => $this->content,
            'number' => $this->chapter_number,
            'novel_id' => $this->novel_id,
            'view_count' => $this->view_count,
            'likes_count' => $this->likes_count,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}