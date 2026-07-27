<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ContentCategory;
use Illuminate\Http\JsonResponse;

class ContentCategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ContentCategory::query()
            ->orderBy('name')
            ->get(['id', 'name']);

        return response()->json([
            'data' => $categories->map(fn (ContentCategory $c) => [
                'id' => (string) $c->id,
                'nombre' => (string) $c->name,
            ]),
        ]);
    }
}
