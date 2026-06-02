<?php

namespace App\Http\Middleware;

use App\Models\AuditLog;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Middleware to ensure only active users can access protected routes.
 */
class ActiveUserMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure $next
     * @return Response
     */
    public function handle(Request $request, Closure $next): Response
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
                'message' => 'Tu cuenta está desactivada. Contacte al administrador.',
            ], 403);
        }

        return $next($request);
    }
}
