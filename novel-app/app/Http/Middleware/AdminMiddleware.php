<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        // 🔐 cek belum login
        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated'
            ], 401);
        }

        // 🔐 cek bukan admin
        if ($user->role !== 'admin') {
            return response()->json([
                'message' => 'Forbidden - Admin Only'
            ], 403);
        }

        return $next($request);
    }
}