import { Injectable } from '@angular/core';
import {
  HttpErrorResponse,
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest
} from '@angular/common/http';
import { Observable, catchError, throwError } from 'rxjs';
import { Router } from '@angular/router';
import { AuthService } from '../auth/auth.service';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {
  constructor(private readonly auth: AuthService, private readonly router: Router) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = this.auth.getToken();

    const authReq = token
      ? req.clone({
          setHeaders: {
            Authorization: `Bearer ${token}`
          }
        })
      : req;

    return next.handle(authReq).pipe(
      catchError((err: unknown) => {
        if (err instanceof HttpErrorResponse && err.status === 401) {
          this.auth.logout();
          this.router.navigate(['/login']);
        }
        return throwError(() => err);
      })
    );
  }
}
