<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MicrobusinessField;
use Illuminate\Http\JsonResponse;

class MicrobusinessFieldController extends Controller
{
    public function index(): JsonResponse
    {
        $fields = MicrobusinessField::query()
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get();

        $data = $fields->map(function (MicrobusinessField $field) {
            return [
                'id' => (string) $field->id,
                'name' => (string) $field->name,
                'field_type' => (string) $field->field_type,
                'is_required' => (bool) $field->is_required,
                'is_filterable' => (bool) $field->is_filterable,
                'sort_order' => (int) $field->sort_order,
                'options' => is_array($field->options_json) ? $field->options_json : [],
            ];
        });

        return response()->json([
            'data' => $data,
        ]);
    }
}
