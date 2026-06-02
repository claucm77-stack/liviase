<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rules\Password as PasswordRule;

/**
 * Controller for password reset and change functionality.
 */
class PasswordController extends Controller
{
    /**
     * Send password reset link to user's email.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function forgot(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        // Check if user exists
        $user = User::where('email', $request->email)->first();

        // Always return success to prevent email enumeration
        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($user) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_PASSWORD_RESET,
                'Solicitud de recuperación de contraseña',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );
        }

        return response()->json([
            'message' => 'Si el correo existe, se enviará un enlace de recuperación',
        ]);
    }

    /**
     * Reset password using token.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function reset(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required|string',
            'email' => 'required|email',
            'password' => ['required', 'confirmed', PasswordRule::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => $password,
                ])->save();

                AuditLog::log(
                    $user->id,
                    AuditLog::ACTION_PASSWORD_CHANGED,
                    'Contraseña restablecerda exitosamente',
                    AuditLog::MODULE_AUTH
                );
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return response()->json([
                'message' => 'Token inválido o expirado',
            ], 400);
        }

        return response()->json([
            'message' => 'Contraseña restablecida exitosamente',
        ]);
    }

    /**
     * Change password for authenticated user.
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function change(Request $request): JsonResponse
    {
        $request->validate([
            'current_password' => 'required|string',
            'password' => ['required', 'confirmed', PasswordRule::min(8)->mixedCase()->numbers()->symbols()],
        ]);

        $user = $request->user();

        // Verify current password
        if (!Hash::check($request->current_password, $user->password)) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_LOGIN_FAILED,
                'Intento de cambio de contraseña con contraseña actual incorrecta',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );

            return response()->json([
                'message' => 'La contraseña actual es incorrecta',
            ], 422);
        }

        // Update password
        $user->forceFill([
            'password' => $request->password,
        ])->save();

        // Revoke all other tokens (force re-login)
        $user->tokens()->delete();

        AuditLog::log(
            $user->id,
            AuditLog::ACTION_PASSWORD_CHANGED,
            'Cambio de contraseña exitoso',
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent()
        );

        return response()->json([
            'message' => 'Contraseña cambiada exitosamente. Por favor, inicia sesión novamente.',
        ]);
    }
}
