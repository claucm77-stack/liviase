<?php

namespace App\Models;

use App\Constants\Roles;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/**
 * Role model for RBAC (Role-Based Access Control).
 * 
 * @property int $id
 * @property string $name
 * @property string $description
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class Role extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'roles';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'description',
    ];

    /**
     * The attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
        ];
    }

    /**
     * Users that belong to this role.
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'user_roles');
    }

    /**
     * Permissions that belong to this role.
     */
    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class, 'role_permissions');
    }

    /**
     * Check if role can manage users (admin only).
     */
    public function canManageUsers(): bool
    {
        return Roles::canManageUsers($this->name);
    }

    /**
     * Check if role can view sensitive data.
     */
    public function canViewSensitive(): bool
    {
        return Roles::canViewSensitive($this->name);
    }

    /**
     * Check if role can manage content.
     */
    public function canManageContent(): bool
    {
        return Roles::canManageContent($this->name);
    }

    /**
     * Get role display name.
     */
    public function getDisplayNameAttribute(): string
    {
        return Roles::getDisplayName($this->name);
    }

    /**
     * Check if user has specific permission.
     */
    public function hasPermission(string $permission): bool
    {
        return $this->permissions()->where('name', $permission)->exists();
    }
}
