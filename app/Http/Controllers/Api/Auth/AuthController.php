<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Main authentication controller handling login, logout, and session management.
 */
class AuthController extends Controller
{
    /**
     * Login user and create token.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:8',
        ]);

        $user = User::where('email', $request->email)->first();

        // Check if user exists
        if (!$user) {
            AuditLog::log(
                null,
                AuditLog::ACTION_LOGIN_FAILED,
                'Intento de login con email no registrado: ' . $request->email,
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent(),
                ['email' => $request->email]
            );

            return response()->json([
                'message' => 'Credenciales inválidas',
            ], 401);
        }

        // Check if user is active
        if (!$user->is_active) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_LOGIN_FAILED,
                'Intento de login en cuenta desactivada',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );

            return response()->json([
                'message' => 'La cuenta está desactivada. Contacte al administrador.',
            ], 403);
        }

        // Verify password
        if (!Hash::check($request->password, $user->password)) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_LOGIN_FAILED,
                'Intento de login con contraseña incorrecta',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );

            return response()->json([
                'message' => 'Credenciales inválidas',
            ], 401);
        }

        // Create token with expiration
        $token = $user->createToken(
            'auth-token',
            ['*'],
            now()->addHours(config('sanctum.token_expiration_hours', 24))
        );

        // Log successful login
        AuditLog::log(
            $user->id,
            AuditLog::ACTION_LOGIN,
            'Usuario inició sesión exitosamente',
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent(),
            ['token_id' => $token->accessToken->id]
        );

        return response()->json([
            'message' => 'Login exitoso',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'role_display_name' => $user->getRoleDisplayName(),
            ],
            'token' => $token->plainTextToken,
            'expires_at' => $token->accessToken->expires_at,
        ]);
    }

    /**
     * Logout user and revoke current token.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user) {
            // Revoke all tokens or just current token
            $request->user()->currentAccessToken()->delete();

            AuditLog::log(
                $user->id,
                AuditLog::ACTION_LOGOUT,
                'Usuario cerró sesión',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );
        }

        return response()->json([
            'message' => 'Logout exitoso',
        ]);
    }

    /**
     * Get current authenticated user.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'role_display_name' => $user->getRoleDisplayName(),
            'is_active' => $user->is_active,
            'created_at' => $user->created_at,
        ]);
    }

    /**
     * Refresh token.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();

        // Revoke current token
        $request->user()->currentAccessToken()->delete();

        // Create new token
        $newToken = $user->createToken(
            'auth-token',
            ['*'],
            now()->addHours(config('sanctum.token_expiration_hours', 24))
        );

        AuditLog::log(
            $user->id,
            AuditLog::ACTION_SESSION_CREATED,
            'Token refrescado',
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent()
        );

        return response()->json([
            'message' => 'Token refrescado',
            'token' => $newToken->plainTextToken,
            'expires_at' => $newToken->accessToken->expires_at,
        ]);
    }
}
