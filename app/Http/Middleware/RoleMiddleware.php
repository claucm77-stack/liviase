<?php

namespace App\Http\Middleware;

use App\Constants\Roles;
use App\Models\AuditLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware to check user's role before accessing protected routes.
 */
class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure $next
     * @param string ...$roles Allowed roles
     * @return Response
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        // Check if user is authenticated
        if (!$user) {
            AuditLog::log(
                null,
                AuditLog::ACTION_ACCESS_DENIED,
                'Intento de acceso sin autenticación',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent(),
                ['path' => $request->path()]
            );

            return response()->json([
                'message' => 'No autenticado',
            ], 401);
        }

        // Check if user is active
        if (!$user->is_active) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_ACCESS_DENIED,
                'Intento de acceso con cuenta desactivada',
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent()
            );

            return response()->json([
                'message' => 'Cuenta desactivada. Contacte al administrador.',
            ], 403);
        }

        // Validate roles parameter
        $validRoles = array_filter($roles, fn($role) => Roles::isValid($role));
        if (empty($validRoles)) {
            return response()->json([
                'message' => 'Roles inválidos especificados',
            ], 500);
        }

        // Check if user has any of the required roles
        if (!$user->hasAnyRole($validRoles)) {
            AuditLog::log(
                $user->id,
                AuditLog::ACTION_ACCESS_DENIED,
                "Intento de acceso a ruta protegida. Rol requerido: " . implode(', ', $validRoles) . ". Rol actual: {$user->role}",
                AuditLog::MODULE_AUTH,
                $request->ip(),
                $request->userAgent(),
                ['required_roles' => $validRoles, 'user_role' => $user->role]
            );

            return response()->json([
                'message' => 'No tienes permiso para acceder a esta ruta',
            ], 403);
        }

        return $next($request);
    }
}
