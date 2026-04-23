<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreChapterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'novel_id' => 'required|exists:novels,id',
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'chapter_number' => 'required|integer|min:1',
        ];
    }
}