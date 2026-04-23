<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Novel;
use App\Models\Chapter;
use App\Models\Genre;
use App\Models\Comment;
use App\Models\Like;
use App\Models\Bookmark;
use App\Models\Favorite;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 👤 USERS
        $admin = User::create([
            'name' => 'Admin',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'admin'
        ]);

        $author = User::create([
            'name' => 'Author',
            'email' => 'author@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'author'
        ]);

        $reader = User::create([
            'name' => 'Reader',
            'email' => 'reader@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'reader'
        ]);

        // 🎭 GENRES
        $fantasy = Genre::create(['name' => 'Fantasy']);
        $romance = Genre::create(['name' => 'Romance']);
        $action = Genre::create(['name' => 'Action']);

        // ➕ TAMBAHAN GENRE (sesuai request)
        $horror = Genre::create(['name' => 'Horror']);
        $drama = Genre::create(['name' => 'Drama']);

        // 📚 NOVELS
        $novel1 = Novel::create([
            'title' => 'Dark Kingdom',
            'description' => 'A fallen king story',
            'cover' => 'default.png',
            'status' => 'published',
            'user_id' => $author->id
        ]);

        $novel2 = Novel::create([
            'title' => 'Love in Silence',
            'description' => 'Romantic drama',
            'cover' => 'default.png',
            'status' => 'draft',
            'user_id' => $author->id
        ]);

        // 🔗 GENRE RELATION
        $novel1->genres()->attach([$fantasy->id, $action->id]);
        $novel2->genres()->attach([$romance->id]);

        // ➕ TAMBAHAN 15 PUBLISHED NOVELS
        for ($i = 1; $i <= 15; $i++) {
            $novel = Novel::create([
                'title' => 'Published Novel ' . $i,
                'description' => 'Description for published novel ' . $i,
                'cover' => 'default.png',
                'status' => 'published',
                'user_id' => $author->id
            ]);

            $novel->genres()->attach([
                $fantasy->id,
                $action->id,
                $horror->id
            ]);
        }

        // ➕ TAMBAHAN 15 DRAFT NOVELS
        for ($i = 1; $i <= 15; $i++) {
            $novel = Novel::create([
                'title' => 'Draft Novel ' . $i,
                'description' => 'Description for draft novel ' . $i,
                'cover' => 'default.png',
                'status' => 'draft',
                'user_id' => $author->id
            ]);

            $novel->genres()->attach([
                $romance->id,
                $drama->id
            ]);
        }

        // 📖 CHAPTERS
        $chapter1 = Chapter::create([
            'novel_id' => $novel1->id,
            'title' => 'Chapter 1',
            'content' => 'Once upon a time...',
            'chapter_number' => 1
        ]);

        $chapter2 = Chapter::create([
            'novel_id' => $novel1->id,
            'title' => 'Chapter 2',
            'content' => 'The war begins...',
            'chapter_number' => 2
        ]);

        // ❤️ LIKE
        Like::create([
            'user_id' => $reader->id,
            'novel_id' => $novel1->id,
            'chapter_id' => $chapter1->id
        ]);

        // 🔖 BOOKMARK
        Bookmark::create([
            'user_id' => $reader->id,
            'novel_id' => $novel1->id
        ]);

        // ⭐ FAVORITE
        Favorite::create([
            'user_id' => $reader->id,
            'novel_id' => $novel1->id
        ]);

        // 💬 COMMENT
        Comment::create([
            'user_id' => $reader->id,
            'novel_id' => $novel1->id,
            'content' => 'Keren banget!'
        ]);
    }
}