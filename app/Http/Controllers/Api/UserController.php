<?php

namespace App\Http\Controllers\Api;

use App\Constants\Roles;
use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password as PasswordRule;

/**
 * Controller for user management (admin only).
 */
class UserController extends Controller
{
    /**
     * Get all users (paginated).
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        // Check if user can manage users
        if (!$request->user()->canManageUsers()) {
            AuditLog::log(
                $request->user()->id,
                AuditLog::ACTION_ACCESS_DENIED,
                'Intento de acceder a lista de usuarios.sin permiso',
                AuditLog::MODULE_USER,
                $request->ip(),
                $request->userAgent()
            );

            return response()->json([
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        $query = User::query();

        // Filter by role
        if ($request->has('role')) {
            $query->role(Roles::normalize((string) $request->role));
        }

        // Filter by active status
        if ($request->has('is_active')) {
            $query->where('is_active', $request->boolean('is_active'));
        }

        // Search by name or email
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')
            ->paginate($request->input('per_page', 15));

        return response()->json($users);
    }

    /**
     * Get a specific user.
     * 
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function show(Request $request, int $id): JsonResponse
    {
        if (!$request->user()->canManageUsers()) {
            return response()->json([
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        $user = User::findOrFail($id);

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'role_display_name' => $user->getRoleDisplayName(),
            'is_active' => $user->is_active,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ]);
    }

    /**
     * Create a new user (admin only).
     * 
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        if (!$request->user()->canManageUsers()) {
            return response()->json([
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'password' => ['required', 'confirmed', PasswordRule::min(8)->mixedCase()->numbers()->symbols()],
            'role' => 'required|string|in:' . implode(',', Roles::active()),
            'is_active' => 'nullable|boolean',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password,
            'role' => Roles::normalize((string) $request->role),
            'is_active' => $request->input('is_active', true),
        ]);

        AuditLog::log(
            $request->user()->id,
            AuditLog::ACTION_USER_CREATED,
            "Usuario creado: {$user->email}",
            AuditLog::MODULE_USER,
            $request->ip(),
            $request->userAgent(),
            ['created_user_id' => $user->id, 'role' => $user->role]
        );

        return response()->json([
            'message' => 'Usuario creado exitosamente',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'role_display_name' => $user->getRoleDisplayName(),
                'is_active' => $user->is_active,
            ],
        ], 201);
    }

    /**
     * Update a user.
     * 
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        if (!$request->user()->canManageUsers()) {
            return response()->json([
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        $user = User::findOrFail($id);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email|max:255|unique:users,email,' . $id,
            'role' => 'sometimes|string|in:' . implode(',', Roles::active()),
            'is_active' => 'sometimes|boolean',
        ]);

        $oldData = [
            'name' => $user->name,
            'role' => $user->role,
            'is_active' => $user->is_active,
        ];

        $payload = $request->only(['name', 'email', 'role', 'is_active']);
        if (isset($payload['role'])) {
            $payload['role'] = Roles::normalize((string) $payload['role']);
        }

        $user->update($payload);

        AuditLog::log(
            $request->user()->id,
            AuditLog::ACTION_USER_UPDATED,
            "Usuario actualizado: {$user->email}",
            AuditLog::MODULE_USER,
            $request->ip(),
            $request->userAgent(),
            ['old_data' => $oldData, 'new_data' => $payload]
        );

        return response()->json([
            'message' => 'Usuario actualizado exitosamente',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'role_display_name' => $user->getRoleDisplayName(),
                'is_active' => $user->is_active,
            ],
        ]);
    }

    /**
     * Deactivate a user (soft delete).
     * 
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        if (!$request->user()->canManageUsers()) {
            return response()->json([
                'message' => 'No tienes permiso para realizar esta acción',
            ], 403);
        }

        $user = User::findOrFail($id);

        // Don't allow self-deactivation
        if ($user->id === $request->user()->id) {
            return response()->json([
                'message' => 'No puedes desactivarte a ti mismo',
            ], 422);
        }

        $user->update(['is_active' => false]);

        // Revoke all tokens
        $user->tokens()->delete();

        AuditLog::log(
            $request->user()->id,
            AuditLog::ACTION_USER_DEACTIVATED,
            "Usuario desactivado: {$user->email}",
            AuditLog::MODULE_USER,
            $request->ip(),
            $request->userAgent()
        );

        return response()->json([
            'message' => 'Usuario desactivado exitosamente',
        ]);
    }
}
