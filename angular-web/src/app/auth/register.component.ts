import { Component } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from './auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  error: string | null = null;
  success: string | null = null;
  isSubmitting = false;

  form = this.fb.nonNullable.group({
    username: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]]
  });

  constructor(
    private readonly fb: FormBuilder,
    private readonly auth: AuthService,
    private readonly router: Router
  ) {}

  submit(): void {
    this.error = null;
    this.success = null;

    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    this.auth.register(this.form.getRawValue()).subscribe({
      next: () => {
        this.isSubmitting = false;
        this.success = 'Account created. You can now login.';
        setTimeout(() => this.router.navigate(['/login']), 300);
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

      if (err.status === 409) {
        return 'Email already exists. Please use a different email.';
      }

      const body = err.error;
      if (typeof body === 'string' && body.trim().length > 0) {
        if (body.toLowerCase().includes('email already exists')) {
          return 'Email already exists. Please use a different email.';
        }
        return body;
      }

      const message = (body && typeof body === 'object' && 'message' in body) ? String((body as any).message) : '';
      if (message.trim().length > 0) {
        if (message.toLowerCase().includes('email already exists')) {
          return 'Email already exists. Please use a different email.';
        }
        return message;
      }

      if (err.status === 500) {
        return 'Server error (HTTP 500). If you already registered this email, try a different one.';
      }

      return `Registration failed (HTTP ${err.status}).`;
    }

    return 'Registration failed. Please try again.';
  }
}
