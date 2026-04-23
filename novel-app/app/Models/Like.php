<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Novel;
use App\Models\User;
use App\Models\Chapter;

class Like extends Model
{
    protected $fillable = [
        'user_id',
        'novel_id',
        'chapter_id',
    ];

    public function novel()
    {
        return $this->belongsTo(Novel::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
}

    public function chapter()
{
    return $this->belongsTo(Chapter::class);
}
}