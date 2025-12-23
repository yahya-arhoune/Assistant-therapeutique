import { Component, OnInit } from '@angular/core';
import { UserService } from '../users/user.service';
import { User } from '../shared/models/user.model';

@Component({
  selector: 'app-admin-users',
  templateUrl: './admin-users.component.html'
})
export class AdminUsersComponent implements OnInit {
  users: User[] = [];
  loading = false;
  error: string | null = null;

  constructor(private readonly userService: UserService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = null;

    this.userService.getAllUsers().subscribe({
      next: (items) => {
        this.users = items;
        this.loading = false;
      },
      error: () => {
        this.loading = false;
        this.error = 'Failed to load users.';
      }
    });
  }

  changeRole(user: User, role: 'USER' | 'ADMIN'): void {
    if (user.id == null) return;

    this.userService.updateUserRole(user.id, role).subscribe({
      next: (updated) => {
        this.users = this.users.map((u) => (u.id === updated.id ? updated : u));
      },
      error: () => {
        this.error = 'Failed to update role.';
      }
    });
  }
}
