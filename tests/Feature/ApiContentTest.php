<?php

namespace Tests\Feature;

use App\Models\Content;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiContentTest extends TestCase
{
    use RefreshDatabase;

    public function test_published_article_includes_its_full_text_for_mobile_clients(): void
    {
        Content::create([
            'title' => 'Guía de ventas',
            'slug' => 'guia-de-ventas',
            'type' => 'articulo',
            'summary' => 'Resumen',
            'body' => json_encode([
                'type' => 'articulo',
                'data' => ['body' => 'Contenido completo del artículo.'],
            ]),
            'status' => 'publicado',
            'published_at' => now(),
        ]);

        $this->getJson('/api/contents')
            ->assertOk()
            ->assertJsonPath('data.0.titulo', 'Guía de ventas')
            ->assertJsonPath('data.0.tipo', 'texto')
            ->assertJsonPath('data.0.url', '')
            ->assertJsonPath('data.0.contenido', 'Contenido completo del artículo.')
            ->assertJsonPath('data.0.metadata.body', 'Contenido completo del artículo.');
    }

    public function test_content_contract_preserves_event_type_and_named_author(): void
    {
        Content::create([
            'title' => 'Taller de ventas',
            'slug' => 'taller-de-ventas',
            'type' => 'evento',
            'body' => json_encode([
                'type' => 'evento',
                'category' => 'Cronograma Actividades',
                'data' => [
                    'agenda' => 'Agenda del taller.',
                    'author_name' => 'María Pérez',
                ],
            ]),
            'status' => 'publicado',
            'published_at' => now(),
        ]);

        $this->getJson('/api/contents')
            ->assertOk()
            ->assertJsonPath('data.0.tipo', 'evento')
            ->assertJsonPath('data.0.autorNombre', 'María Pérez');
    }
}
