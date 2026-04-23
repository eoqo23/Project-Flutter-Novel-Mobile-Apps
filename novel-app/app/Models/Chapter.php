<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Novel;
use App\Models\User;
use App\Models\Like;
use App\Models\View;

class Chapter extends Model
{
    // Tabel yang digunakan
    protected $table = 'chapters';

    // Mass assignable fields (biar bisa pakai Chapter::create([...]))
    protected $fillable = [
        'novel_id',
        'title',
        'content',
        'chapter_number',
        'view_count',
        'likes_count',
    ];

    // Relasi ke Novel
    public function novel()
    {
        return $this->belongsTo(Novel::class, 'novel_id');
    }

    // Relasi ke Like
    public function likes()
    {
        return $this->hasMany(Like::class, 'chapter_id');
    }

    public function bookmarks()
{
    return $this->hasMany(Bookmark::class);
}
}