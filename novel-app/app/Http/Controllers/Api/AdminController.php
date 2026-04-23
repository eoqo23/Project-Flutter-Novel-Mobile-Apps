<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Novel;
use App\Models\Favorite;

class AdminController extends Controller
{
  public function pending()
{
    return Novel::where('status', 'pending')->get();
}

public function approve($id)
{
    $novel = Novel::findOrFail($id);
    $novel->status = 'approved';
    $novel->save();

    return response()->json(['message' => 'approved']);
}

public function reject($id)
{
    $novel = Novel::findOrFail($id);
    $novel->status = 'rejected';
    $novel->save();

    return response()->json(['message' => 'rejected']);
}
}
