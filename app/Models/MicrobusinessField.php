<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MicrobusinessField extends Model
{
    protected $fillable = [
        'name',
        'field_type',
        'is_required',
        'options_json',
        'sort_order',
        'is_active',
    ];

    protected $casts = [
        'is_required' => 'boolean',
        'is_active' => 'boolean',
        'options_json' => 'array',
    ];
}
