<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Models\User;
use App\Models\Chapter;

class Novel extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'cover_image',
        'status',
        'view_count',
    ];

    // 🔗 Relasi ke User (Author)
    public function author()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // 🔗 Relasi ke Chapter
    public function chapters()
    {
        return $this->hasMany(Chapter::class);
    }

    public function bookmarks()
{
    return $this->hasMany(Bookmark::class);
}

public function comments()
{
    return $this->hasMany(Comment::class);
}

public function genres()
{
    return $this->belongsToMany(Genre::class, 'genre_novel');
}

public function favorites() {
    return $this->hasMany(Favorite::class);
}

public function likes()
{
    return $this->hasMany(Like::class);
}


}