<?php

use App\Models\Content;
use App\Models\ContentCategory;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::transaction(function () {
            // Bootstrap inicial (mapea lo que antes estaba hardcodeado en Admin)
            $defaults = [
                'Conferencia en vivo',
                'Repositorio en video',
                'Artículos Populares',
                'Artículos Relacionados',
                'Cronograma Actividades',
            ];

            foreach ($defaults as $name) {
                ContentCategory::query()->firstOrCreate(['name' => $name]);
            }

            // Asigna FK en contenidos existentes usando el JSON guardado en `body`
            Content::query()->chunkById(200, function ($contents) {
                /** @var Content $content */
                foreach ($contents as $content) {
                    if (!empty($content->content_category_id)) {
                        continue;
                    }

                    $raw = (string) ($content->body ?? '');
                    $decoded = json_decode($raw, true);

                    $categoryId = isset($decoded['category_id']) && is_numeric($decoded['category_id'])
                        ? (int) $decoded['category_id']
                        : null;

                    if ($categoryId) {
                        $content->content_category_id = $categoryId;
                        $content->save();
                        continue;
                    }

                    $categoryName = isset($decoded['category']) ? (string) $decoded['category'] : '';

                    if (trim($categoryName) !== '') {
                        $cat = ContentCategory::query()->where('name', $categoryName)->first();
                        if ($cat) {
                            $content->content_category_id = $cat->id;
                            $content->save();
                            continue;
                        }
                    }

                    // Fallback SOLO para migración de datos (compatibilidad histórica)
                    $type = (string) ($content->type ?? '');
                    $fallbackName = match ($type) {
                        'video' => 'Repositorio en video',
                        'pdf' => 'Artículos Relacionados',
                        'evento' => 'Cronograma Actividades',
                        default => 'Artículos Populares',
                    };

                    $cat = ContentCategory::query()->where('name', $fallbackName)->first();
                    if ($cat) {
                        $content->content_category_id = $cat->id;
                        $content->save();
                    }
                }
            });
        });
    }

    public function down(): void
    {
        // No se revierte contenido_category_id ni se eliminan categorías para evitar perder datos creados.
    }
};
