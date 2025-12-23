import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { ReactiveFormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { LoginComponent } from './auth/login.component';
import { RegisterComponent } from './auth/register.component';
import { ProfileComponent } from './users/profile.component';
import { JournalListComponent } from './journal/journal-list.component';
import { JournalFormComponent } from './journal/journal-form.component';
import { AdminDashboardComponent } from './admin/admin-dashboard.component';
import { AdminUsersComponent } from './admin/admin-users.component';
import { JwtInterceptor } from './core/jwt.interceptor';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    RegisterComponent,
    ProfileComponent,
    JournalListComponent,
    JournalFormComponent,
    AdminDashboardComponent,
    AdminUsersComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    ReactiveFormsModule,
    AppRoutingModule
  ],
  providers: [
    {
      provide: HTTP_INTERCEPTORS,
      useClass: JwtInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
