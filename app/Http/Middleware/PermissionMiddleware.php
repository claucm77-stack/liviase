<?php

namespace App\Http\Middleware;

use App\Models\AuditLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware to check specific permissions before accessing protected routes.
 */
class PermissionMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure $next
     * @param string ...$permissions Required permissions
     * @return Response
     */
    public function handle(Request $request, Closure $next, string ...$permissions): Response
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

        // Check if user has any of the required permissions
        foreach ($permissions as $permission) {
            if ($user->hasPermission($permission)) {
                return $next($request);
            }
        }

        // If no permission matched log and deny
        AuditLog::log(
            $user->id,
            AuditLog::ACTION_ACCESS_DENIED,
            "Intento de acceso sin permisos suficientes. Permisos requeridos: " . implode(', ', $permissions),
            AuditLog::MODULE_AUTH,
            $request->ip(),
            $request->userAgent(),
            ['required_permissions' => $permissions]
        );

        return response()->json([
            'message' => 'No tienes el permiso requerido para acceder a esta ruta',
        ], 403);
    }
}
