import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, tap } from 'rxjs';

export type AppRole = 'USER' | 'ADMIN';

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  role: AppRole;
}

export interface RegisterRequest {
  username: string;
  email: string;
  password: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  // Use relative URLs so `ng serve` proxy can forward to Spring Boot.
  // See `src/proxy.conf.json`.
  private readonly baseUrl = '';
  private readonly tokenKey = 'auth_token';
  private readonly roleKey = 'auth_role';

  private readonly roleSubject = new BehaviorSubject<AppRole | null>(this.getRoleFromStorage());
  readonly role$ = this.roleSubject.asObservable();

  constructor(private readonly http: HttpClient) {}

  login(body: LoginRequest): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${this.baseUrl}/api/auth/login`, body)
      .pipe(
        tap((res) => {
          this.setToken(res.token);
          const roleFromToken = this.extractRoleFromJwt(res.token);
          const role = roleFromToken ?? res.role;
          this.setRole(role);
        })
      );
  }

  register(body: RegisterRequest): Observable<void> {
    return this.http.post<void>(`${this.baseUrl}/api/auth/register`, body);
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.roleKey);
    this.roleSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (!token) return false;
    return !this.isTokenExpired(token);
  }

  getRole(): AppRole | null {
    return this.roleSubject.value;
  }

  hasRole(role: AppRole): boolean {
    return this.getRole() === role;
  }

  private setToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
  }

  private setRole(role: AppRole): void {
    localStorage.setItem(this.roleKey, role);
    this.roleSubject.next(role);
  }

  private getRoleFromStorage(): AppRole | null {
    const role = localStorage.getItem(this.roleKey);
    return role === 'USER' || role === 'ADMIN' ? role : null;
  }

  private decodeJwtPayload(token: string): any {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const payload = parts[1]
      .replace(/-/g, '+')
      .replace(/_/g, '/');

    // base64 padding
    const padded = payload + '='.repeat((4 - (payload.length % 4)) % 4);

    try {
      const json = atob(padded);
      return JSON.parse(json);
    } catch {
      return null;
    }
  }

  private extractRoleFromJwt(token: string): AppRole | null {
    const payload = this.decodeJwtPayload(token);
    if (!payload) return null;

    const directRole = payload.role;
    if (directRole === 'USER' || directRole === 'ADMIN') return directRole;

    const roles = payload.roles;
    if (Array.isArray(roles)) {
      if (roles.includes('ADMIN')) return 'ADMIN';
      if (roles.includes('USER')) return 'USER';
    }

    const authorities = payload.authorities;
    if (Array.isArray(authorities)) {
      if (authorities.includes('ROLE_ADMIN') || authorities.includes('ADMIN')) return 'ADMIN';
      if (authorities.includes('ROLE_USER') || authorities.includes('USER')) return 'USER';
    }

    return null;
  }

  private isTokenExpired(token: string): boolean {
    const payload = this.decodeJwtPayload(token);
    const exp = payload?.exp;
    if (typeof exp !== 'number') return false; // if no exp, assume valid

    // exp is seconds since epoch
    const nowSeconds = Math.floor(Date.now() / 1000);
    return nowSeconds >= exp;
  }
}
