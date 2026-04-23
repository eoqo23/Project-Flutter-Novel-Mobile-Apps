<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Favorite extends Model
{
    protected $fillable = [
        'user_id',
        'novel_id',
    ];

    // 🔗 relasi ke user
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // 🔗 relasi ke novel
    public function novel()
    {
        return $this->belongsTo(Novel::class);
    }
}