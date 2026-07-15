import { Injectable, signal, computed } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError, of } from 'rxjs';
import { catchError, map, tap, finalize } from 'rxjs/operators';
import { 
  User, 
  AuthResponse, 
  LoginRequest, 
  RegisterRequest, 
  ChangePasswordRequest,
  ForgotPasswordRequest,
  ResetPasswordRequest,
  Session 
} from '../models/user.model';
import { TokenService } from './token.service';

/**
 * Auth service for handling authentication flow in Angular.
 * Implements complete login, logout, register, password management, and session handling.
 */
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly apiUrl = 'https://liviase.sanmartin.edu.co/api';
  
  // Signals for reactive state management
  private _currentUser = signal<User | null>(null);
  private _isAuthenticated = signal<boolean>(false);
  private _isLoading = signal<boolean>(false);
  private _error = signal<string | null>(null);
  
  // Public computed signals
  readonly currentUser = computed(() => this._currentUser());
  readonly isAuthenticated = computed(() => this._isAuthenticated());
  readonly isLoading = computed(() => this._isLoading());
  readonly error = computed(() => this._error());
  
  // Sessions (tokens) management
  private _sessions = signal<Session[]>([]);
  readonly sessions = computed(() => this._sessions());

  constructor(
    private http: HttpClient,
    private tokenService: TokenService
  ) {
    this.initializeAuth();
  }

  /**
   * Initialize authentication state from stored token.
   */
  private initializeAuth(): void {
    const token = this.tokenService.getToken();
    if (token) {
      this.fetchCurrentUser().subscribe({
        next: () => {
          this._isAuthenticated.set(true);
          this.loadSessions();
        },
        error: () => {
          this.tokenService.removeToken();
          this._isAuthenticated.set(false);
          this._currentUser.set(null);
        }
      });
    }
  }

  /**
   * Login user with email and password.
   */
  login(credentials: LoginRequest): Observable<User> {
    this._isLoading.set(true);
    this._error.set(null);

    return this.http.post<AuthResponse>(`${this.apiUrl}/auth/login`, credentials).pipe(
      map(response => {
        // Save token
        this.tokenService.setToken(response.token);
        
        // Update state
        this._currentUser.set(response.user);
        this._isAuthenticated.set(true);
        
        return response.user;
      }),
      catchError(error => this.handleError(error)),
      finalize(() => this._isLoading.set(false))
    );
  }

  /**
   * Register a new user.
   */
  register(data: RegisterRequest): Observable<User> {
    this._isLoading.set(true);
    this._error.set(null);

    return this.http.post<AuthResponse>(`${this.apiUrl}/auth/register`, data).pipe(
      map(response => {
        // Save token
        this.tokenService.setToken(response.token);
        
        // Update state
        this._currentUser.set(response.user);
        this._isAuthenticated.set(true);
        
        return response.user;
      }),
      catchError(error => this.handleError(error)),
      finalize(() => this._isLoading.set(false))
    );
  }

  /**
   * Logout current user.
   */
  logout(): Observable<void> {
    this._isLoading.set(true);

    return this.http.post<void>(`${this.apiUrl}/auth/logout`, {}).pipe(
      tap(() => {
        // Clear all auth state
        this.tokenService.removeToken();
        this._currentUser.set(null);
        this._isAuthenticated.set(false);
        this._sessions.set([]);
      }),
      catchError(error => {
        // Even on error, clear local state
        this.tokenService.removeToken();
        this._currentUser.set(null);
        this._isAuthenticated.set(false);
        this._sessions.set([]);
        return throwError(() => error);
      }),
      finalize(() => this._isLoading.set(false))
    );
  }

  /**
   * Get current authenticated user.
   */
  fetchCurrentUser(): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/auth/me`).pipe(
      map(user => {
        this._currentUser.set(user);
        return user;
      }),
      catchError(error => {
        this._currentUser.set(null);
        return throwError(() => error);
      })
    );
  }

  /**
   * Refresh authentication token.
   */
  refreshToken(): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/auth/refresh`, {}).pipe(
      map(response => {
        this.tokenService.setToken(response.token);
        return response;
      }),
      catchError(error => {
        this.logout();
        return throwError(() => error);
      })
    );
  }

  /**
   * Send password reset email.
   */
  forgotPassword(request: ForgotPasswordRequest): Observable<{message: string}> {
    return this.http.post<{message: string}>(`${this.apiUrl}/auth/forgot`, request).pipe(
      catchError(error => this.handleError(error))
    );
  }

  /**
   * Reset password with token.
   */
  resetPassword(request: ResetPasswordRequest): Observable<{message: string}> {
    return this.http.post<{message: string}>(`${this.apiUrl}/auth/reset`, request).pipe(
      catchError(error => this.handleError(error))
    );
  }

  /**
   * Change password for authenticated user.
   */
  changePassword(request: ChangePasswordRequest): Observable<{message: string}> {
    this._isLoading.set(true);
    this._error.set(null);

    return this.http.post<{message: string}>(`${this.apiUrl}/auth/password/change`, request).pipe(
      tap(() => {
        // Force re-login after password change
        this.logout();
      }),
      catchError(error => this.handleError(error)),
      finalize(() => this._isLoading.set(false))
    );
  }

  /**
   * Get all active sessions (tokens).
   */
  loadSessions(): void {
    this.http.get<{sessions: Session[]}>(`${this.apiUrl}/auth/sessions`).pipe(
      map(response => response.sessions),
      catchError(() => of([]))
    ).subscribe(sessions => this._sessions.set(sessions));
  }

  /**
   * Revoke a specific session.
   */
  revokeSession(tokenId: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/auth/sessions/${tokenId}`).pipe(
      tap(() => {
        // Remove session from list
        const currentSessions = this._sessions();
        this._sessions.set(currentSessions.filter(s => s.id !== tokenId));
      }),
      catchError(error => this.handleError(error))
    );
  }

  /**
   * Revoke all sessions except current.
   */
  revokeAllSessions(): Observable<void> {
    return this.http.post<void>(`${this.apiUrl}/auth/sessions/revoke-all`, {}).pipe(
      tap(() => {
        // Keep only current session
        const currentTokenId = this.tokenService.getTokenId();
        if (currentTokenId) {
          const currentSession = this._sessions().find(s => s.id === currentTokenId);
          this._sessions.set(currentSession ? [currentSession] : []);
        }
      }),
      catchError(error => this.handleError(error))
    );
  }

  /**
   * Check if user has specific role.
   */
  hasRole(role: string): boolean {
    const user = this._currentUser();
    return user?.role === role;
  }

  /**
   * Check if user has any of the given roles.
   */
  hasAnyRole(roles: string[]): boolean {
    const user = this._currentUser();
    return user ? roles.includes(user.role) : false;
  }

  /**
   * Check if user is admin.
   */
  isAdmin(): boolean {
    return this.hasRole('admin');
  }

  /**
   * Check if user can manage users.
   */
  canManageUsers(): boolean {
    const user = this._currentUser();
    return user?.role === 'admin';
  }

  /**
   * Handle HTTP errors.
   */
  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'Ocurrió un error inesperado';

    if (error.status === 401) {
      errorMessage = 'Credenciales inválidas';
      this.tokenService.removeToken();
      this._isAuthenticated.set(false);
      this._currentUser.set(null);
    } else if (error.status === 403) {
      errorMessage = error.error?.message || 'No tienes permiso para realizar esta acción';
    } else if (error.status === 422) {
      errorMessage = error.error?.message || 'Datos inválidos';
      if (error.error?.errors) {
        // Join all validation errors
        const errors = Object.values(error.error.errors).flat();
        errorMessage = errors.join(', ');
      }
    } else if (error.status === 429) {
      errorMessage = 'Demasiadas solicitudes. Por favor, espera un momento';
    } else if (error.status === 0) {
      errorMessage = 'No se pudo conectar con el servidor';
    } else if (error.error?.message) {
      errorMessage = error.error.message;
    }

    this._error.set(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}
