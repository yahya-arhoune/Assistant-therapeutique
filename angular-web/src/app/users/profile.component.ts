import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../auth/auth.service';
import { UserService } from './user.service';
import { User } from '../shared/models/user.model';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html'
})
export class ProfileComponent implements OnInit {
  user: User | null = null;
  loading = false;
  saving = false;
  error: string | null = null;

  form = this.fb.nonNullable.group({
    username: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]]
  });

  constructor(
    private readonly fb: FormBuilder,
    private readonly users: UserService,
    private readonly auth: AuthService,
    private readonly router: Router
  ) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = null;

    this.users.getMe().subscribe({
      next: (u) => {
        this.user = u;
        this.form.patchValue({ username: u.username, email: u.email });
        this.loading = false;
      },
      error: () => {
        this.loading = false;
        this.error = 'Failed to load profile.';
      }
    });
  }

  save(): void {
    this.error = null;
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving = true;
    this.users.updateMe(this.form.getRawValue()).subscribe({
      next: (u) => {
        this.user = u;
        this.saving = false;
      },
      error: () => {
        this.saving = false;
        this.error = 'Failed to update profile.';
      }
    });
  }

  deleteAccount(): void {
    const confirmed = confirm('Delete your account permanently?');
    if (!confirmed) return;

    this.users.deleteMe().subscribe({
      next: () => {
        this.auth.logout();
        this.router.navigate(['/login']);
      },
      error: () => {
        this.error = 'Failed to delete account.';
      }
    });
  }
}
