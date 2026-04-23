<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\Novel;
use App\Models\Bookmark;
use App\Models\Like;
use App\Models\Comment;
use App\Models\Favorite;


class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function novels()
    {
        return $this->hasMany(Novel::class);
    }

    public function isAuthor()
    {
        return $this->role === 'author';
    }

    public function isReader()
    {
        return $this->role === 'reader';
    }

    public function bookmarks()
{
    return $this->hasMany(Bookmark::class);
}

public function likes()
{
    return $this->hasMany(Like::class);
}

public function comments()
{
    return $this->hasMany(Comment::class);
}

public function favorites() {
    return $this->hasMany(Favorite::class);
}
}