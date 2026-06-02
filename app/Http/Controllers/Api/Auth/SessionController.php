<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

/**
 * Controller for session management - list, revoke tokens.
 */
class SessionController extends Controller
{
    /**
     * Get all active sessions for the authenticated user.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $tokens = $request->user()->tokens->map(function ($token) {
            return [
                'id' => $token->id,
                'name' => $token->name,
                'abilities' => $token->abilities,
                'last_used_at' => $token->last_used_at,
                'expires_at' => $token->expires_at,
                'created_at' => $token->created_at,
            ];
        });

        return response()->json([
            'sessions' => $tokens,
        ]);
    }

    /**
     * Revoke a specific session/token.
     * 
     * @param Request $request
     * @param int $tokenId
     * @return JsonResponse
     */
    public function destroy(Request $request, int $tokenId): JsonResponse
    {
        $token = PersonalAccessToken::where('tokenable_id', $request->user()->id)
            ->where('tokenable_type', User::class)
            ->find($tokenId);

        if (!$token) {
            return response()->json([
                'message' => 'Sesión no encontrada',
            ], 404);
        }

        // Don't allow revoking current token through this endpoint
        if ($token->id === $request->user()->currentAccessToken()->id) {
            return response()->json([
                'message' => 'No puedes revocar la sesión actual. Usa logout.',
            ], 422);
        }

        $tokenName = $token->name;
        $token->delete();

        AuditLog::log(
            $request->user()->id,
            AuditLog::ACTION_SESSION_REVOKED,
            "Sesión revocada: {$tokenName}",
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent(),
            ['token_id' => $tokenId, 'token_name' => $tokenName]
        );

        return response()->json([
            'message' => 'Sesión revocada exitosamente',
        ]);
    }

    /**
     * Revoke all sessions except current.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function revokeAll(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentTokenId = $user->currentAccessToken()->id;

        // Delete all tokens except current
        $user->tokens()
            ->where('id', '!=', $currentTokenId)
            ->delete();

        AuditLog::log(
            $user->id,
            AuditLog::ACTION_SESSION_REVOKED,
            'Todas las demás sesiones revocadas',
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent()
        );

        return response()->json([
            'message' => 'Todas las demás sesiones han sido revocadas',
        ]);
    }
}
