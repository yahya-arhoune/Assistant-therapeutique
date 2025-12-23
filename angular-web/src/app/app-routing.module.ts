import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from './auth/auth.guard';
import { LoginComponent } from './auth/login.component';
import { RegisterComponent } from './auth/register.component';
import { ProfileComponent } from './users/profile.component';
import { JournalListComponent } from './journal/journal-list.component';
import { AdminDashboardComponent } from './admin/admin-dashboard.component';
import { AdminUsersComponent } from './admin/admin-users.component';

const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'journal' },

  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },

  { path: 'profile', component: ProfileComponent, canActivate: [AuthGuard] },
  { path: 'journal', component: JournalListComponent, canActivate: [AuthGuard] },

  {
    path: 'admin/dashboard',
    component: AdminDashboardComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ADMIN'] }
  },
  {
    path: 'admin/users',
    component: AdminUsersComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ADMIN'] }
  },

  { path: '**', redirectTo: 'journal' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
