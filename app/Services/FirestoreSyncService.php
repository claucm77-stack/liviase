<?php

namespace App\Services;

use App\Models\Content;
use App\Models\Microbusiness;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Firestore;
use Throwable;

class FirestoreSyncService
{
    private ?Firestore $firestore = null;

    public function __construct()
    {
        try {
            $this->firestore = (new Factory())
                ->withServiceAccount(config('services.firebase.credentials'))
                ->createFirestore();
        } catch (Throwable) {
            $this->firestore = null;
        }
    }

    public function syncContent(Content $content): void
    {
        $payload = $this->decodeContentPayload($content);
        $data = $payload['data'] ?? [];
        $type = (string) ($content->type ?? 'articulo');

        $this->setDocument('contenidos', (string) $content->id, [
            'titulo' => $content->title,
            'descripcion' => (string) ($content->summary ?? ''),
            'tipo' => $this->normalizeContentType($type),
            'url' => $this->contentUrl($type, $data),
            'imagen' => (string) ($payload['image_url'] ?? ''),
            'categoria' => $this->contentCategory($type),
            'autorId' => '',
            'fechaCreacion' => optional($content->created_at)?->toIso8601String() ?? now()->toIso8601String(),
            'estado' => $content->status === 'publicado' ? 'activo' : 'inactivo',
            'destacado' => false,
            'metadata' => $data,
        ]);
    }

    public function deleteContent(Content $content): void
    {
        $this->deleteDocument('contenidos', (string) $content->id);
    }

    public function syncMicrobusiness(Microbusiness $business): void
    {
        $this->setDocument('micronegocios', (string) $business->id, [
            'nombre' => $business->name,
            'descripcion' => (string) ($business->description ?? ''),
            'categoria' => (string) ($business->category ?? ''),
            'direccion' => (string) ($business->address ?? ''),
            'latitud' => (float) $business->latitude,
            'longitud' => (float) $business->longitude,
            'mapsUrl' => (string) ($business->maps_url ?? ''),
            'imagen' => (string) ($business->image_url ?? ''),
            'propietarioId' => (string) ($business->owner_id ?? ''),
            'contacto' => (string) ($business->contact ?? ''),
            'horario' => (string) ($business->schedule ?? ''),
            'estado' => $business->status,
            'fechaCreacion' => optional($business->created_on_app_at ?? $business->created_at)?->toIso8601String() ?? now()->toIso8601String(),
            'favoritos' => $business->favorites ?? [],
            'ratingPromedio' => $business->average_rating,
            'totalCalificaciones' => $business->ratings_count,
        ]);
    }

    public function deleteMicrobusiness(Microbusiness $business): void
    {
        $this->deleteDocument('micronegocios', (string) $business->id);
    }

    private function setDocument(string $collection, string $id, array $data): void
    {
        if ($this->firestore === null) {
            return;
        }

        try {
            $this->firestore->database()
                ->collection($collection)
                ->document($id)
                ->set($data, ['merge' => true]);
        } catch (Throwable) {
            // El panel local no debe fallar si Firebase no esta disponible.
        }
    }

    private function deleteDocument(string $collection, string $id): void
    {
        if ($this->firestore === null) {
            return;
        }

        try {
            $this->firestore->database()
                ->collection($collection)
                ->document($id)
                ->delete();
        } catch (Throwable) {
            // El panel local no debe fallar si Firebase no esta disponible.
        }
    }

    private function normalizeContentType(string $type): string
    {
        return match ($type) {
            'video' => 'video',
            'pdf' => 'pdf',
            default => 'texto',
        };
    }

    private function contentCategory(string $type): string
    {
        return match ($type) {
            'video' => 'Repositorio en video',
            'pdf' => 'Artículos Relacionados',
            'evento' => 'Cronograma Actividades',
            default => 'Artículos Populares',
        };
    }

    private function contentUrl(string $type, array $data): string
    {
        return match ($type) {
            'video' => (string) ($data['video_url'] ?? ''),
            'pdf' => (string) ($data['pdf_url'] ?? ''),
            'evento' => (string) ($data['registration_url'] ?? ''),
            default => '',
        };
    }

    private function decodeContentPayload(Content $content): array
    {
        $decoded = json_decode((string) $content->body, true);
        if (is_array($decoded)) {
            return $decoded;
        }

        return [
            'type' => $content->type,
            'image_url' => '',
            'data' => [
                'body' => (string) ($content->body ?? ''),
            ],
        ];
    }
}
