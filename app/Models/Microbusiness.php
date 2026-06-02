<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Microbusiness extends Model
{
    protected $fillable = [
        'name',
        'description',
        'category',
        'address',
        'latitude',
        'longitude',
        'maps_url',
        'image_url',
        'owner_id',
        'contact',
        'schedule',
        'status',
        'created_on_app_at',
        'favorites',
        'average_rating',
        'ratings_count',
    ];

    protected $casts = [
        'latitude' => 'float',
        'longitude' => 'float',
        'created_on_app_at' => 'datetime',
        'favorites' => 'array',
        'average_rating' => 'float',
        'ratings_count' => 'integer',
    ];

    public function isActive(): bool
    {
        return $this->status === 'activo';
    }
}
