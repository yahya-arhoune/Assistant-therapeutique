import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, Router, UrlTree } from '@angular/router';
import { AuthService, AppRole } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private readonly auth: AuthService, private readonly router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean | UrlTree {
    if (!this.auth.isLoggedIn()) {
      return this.router.createUrlTree(['/login']);
    }

    const requiredRoles = (route.data?.['roles'] as AppRole[] | undefined) ?? undefined;
    if (requiredRoles && requiredRoles.length > 0) {
      const role = this.auth.getRole();
      if (!role || !requiredRoles.includes(role)) {
        return this.router.createUrlTree(['/journal']);
      }
    }

    return true;
  }
}
