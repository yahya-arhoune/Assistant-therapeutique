import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { User } from '../shared/models/user.model';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private readonly baseUrl = '';

  constructor(private readonly http: HttpClient) {}

  getMe(): Observable<User> {
    return this.http.get<User>(`${this.baseUrl}/api/users/me`);
  }

  updateMe(body: Partial<Pick<User, 'username' | 'email'>>): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/api/users/me`, body);
  }

  deleteMe(): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/users/me`);
  }

  // ADMIN endpoints
  getAllUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.baseUrl}/api/admin/users`);
  }

  updateUserRole(id: number, role: 'ADMIN' | 'USER'): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/api/admin/users/${id}/role?role=${role}`, {});
  }
}
