<?php

namespace App\Policies;

use App\Models\User;

/**
 * Policy for User model authorization.
 */
class UserPolicy
{
    /**
     * Determine if user can view any users.
     */
    public function viewAny(User $user): bool
    {
        return $user->canManageUsers();
    }

    /**
     * Determine if user can view a specific user.
     */
    public function view(User $user, User $targetUser): bool
    {
        // Admins can view all
        if ($user->canManageUsers()) {
            return true;
        }

        // Users can view their own profile
        return $user->id === $targetUser->id;
    }

    /**
     * Determine if user can create users.
     */
    public function create(User $user): bool
    {
        return $user->canManageUsers();
    }

    /**
     * Determine if user can update a specific user.
     */
    public function update(User $user, User $targetUser): bool
    {
        // Admins can update any user
        if ($user->canManageUsers()) {
            return true;
        }

        // Users can update their own profile (except role and is_active)
        return $user->id === $targetUser->id;
    }

    /**
     * Determine if user can delete a specific user.
     */
    public function delete(User $user, User $targetUser): bool
    {
        // Admins can delete (deactivate) users
        return $user->canManageUsers() && $user->id !== $targetUser->id;
    }

    /**
     * Determine if user can change user roles.
     */
    public function changeRole(User $user, User $targetUser): bool
    {
        return $user->canManageUsers();
    }

    /**
     * Determine if user can manage (activate/deactivate) users.
     */
    public function manage(User $user): bool
    {
        return $user->canManageUsers();
    }
}
