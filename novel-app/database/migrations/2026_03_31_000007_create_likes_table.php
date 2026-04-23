<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
       Schema::create('likes', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('novel_id')->constrained()->cascadeOnDelete();
    $table->foreignId('chapter_id')->constrained()->cascadeOnDelete();
    $table->timestamps();

    $table->unique(['user_id', 'novel_id', 'chapter_id']); // Pastikan user hanya bisa like 1x per chapter
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('likes');
    }
};
