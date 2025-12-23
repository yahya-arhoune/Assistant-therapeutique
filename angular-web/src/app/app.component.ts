import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService, AppRole } from './auth/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'angular-web';

  constructor(public readonly auth: AuthService, private readonly router: Router) {}

  get isLoggedIn(): boolean {
    return this.auth.isLoggedIn();
  }

  get role(): AppRole | null {
    return this.auth.getRole();
  }

  logout(): void {
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}
