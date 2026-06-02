<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * AuditLog model for tracking user activities and security events.
 * 
 * @property int $id
 * @property int|null $user_id
 * @property string $action
 * @property string $description
 * @property string $module
 * @property string|null $ip_address
 * @property string|null $user_agent
 * @property array|null $metadata
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 */
class AuditLog extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'audit_logs';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'action',
        'description',
        'module',
        'ip_address',
        'user_agent',
        'metadata',
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
            'metadata' => 'array',
        ];
    }

    /**
     * User that performed the action.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Log a new audit entry.
     */
    public static function log(
        ?int $userId,
        string $action,
        string $description,
        string $module,
        ?string $ipAddress = null,
        ?string $userAgent = null,
        ?array $metadata = null
    ): self {
        return static::create([
            'user_id' => $userId,
            'action' => $action,
            'description' => $description,
            'module' => $module,
            'ip_address' => $ipAddress,
            'user_agent' => $userAgent,
            'metadata' => $metadata,
        ]);
    }

    /**
     * Scope by module.
     */
    public function scopeModule($query, string $module)
    {
        return $query->where('module', $module);
    }

    /**
     * Scope by action.
     */
    public function scopeAction($query, string $action)
    {
        return $query->where('action', $action);
    }

    /**
     * Scope by user.
     */
    public function scopeUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Common audit actions.
     */
    public const ACTION_LOGIN = 'login';
    public const ACTION_LOGOUT = 'logout';
    public const ACTION_LOGIN_FAILED = 'login_failed';
    public const ACTION_PASSWORD_CHANGED = 'password_changed';
    public const ACTION_PASSWORD_RESET = 'password_reset';
    public const ACTION_SESSION_CREATED = 'session_created';
    public const ACTION_SESSION_REVOKED = 'session_revoked';
    public const ACTION_ROLE_CHANGED = 'role_changed';
    public const ACTION_USER_CREATED = 'user_created';
    public const ACTION_USER_UPDATED = 'user_updated';
    public const ACTION_USER_DEACTIVATED = 'user_deactivated';
    public const ACTION_ACCESS_DENIED = 'access_denied';
    public const ACTION_PERMISSION_GRANTED = 'permission_granted';
    public const ACTION_PERMISSION_REVOKED = 'permission_revoked';

    /**
     * Common modules.
     */
    public const MODULE_AUTH = 'auth';
    public const MODULE_USER = 'user';
    public const MODULE_ROLE = 'role';
    public const MODULE_PERMISSION = 'permission';
    public const MODULE_API = 'api';
}
