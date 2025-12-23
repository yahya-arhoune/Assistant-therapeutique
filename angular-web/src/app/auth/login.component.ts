import { Component } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  error: string | null = null;
  isSubmitting = false;

  form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]]
  });

  constructor(
    private readonly fb: FormBuilder,
    private readonly auth: AuthService,
    private readonly router: Router
  ) {}

  submit(): void {
    this.error = null;
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    this.auth.login(this.form.getRawValue()).subscribe({
      next: (res) => {
        this.isSubmitting = false;
        const role = this.auth.getRole() ?? res.role;
        this.router.navigate([role === 'ADMIN' ? '/admin/dashboard' : '/journal']);
      },
      error: (err: unknown) => {
        this.isSubmitting = false;
        this.error = this.formatError(err);
      }
    });
  }

  private formatError(err: unknown): string {
    if (err instanceof HttpErrorResponse) {
      if (err.status === 0) {
        return 'Cannot reach backend. Ensure Spring Boot is running on http://localhost:8080 (and dev proxy is active).';
      }

      const body = err.error;
      if (typeof body === 'string' && body.trim().length > 0) {
        return body;
      }

      const message = (body && typeof body === 'object' && 'message' in body) ? String((body as any).message) : '';
      if (message.trim().length > 0) {
        return message;
      }

      if (err.status === 400 || err.status === 401) return 'Invalid email or password.';
      return `Login failed (HTTP ${err.status}).`;
    }
    return 'Login failed.';
  }
}
