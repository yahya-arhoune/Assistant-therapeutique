import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { EmotionEntry } from '../shared/models/emotion-entry.model';
import { JournalService } from './journal.service';

@Component({
  selector: 'app-journal-form',
  templateUrl: './journal-form.component.html'
})
export class JournalFormComponent {
  @Input() entry: EmotionEntry | null = null;
  @Output() saved = new EventEmitter<void>();
  @Output() cancelled = new EventEmitter<void>();

  error: string | null = null;
  isSubmitting = false;

  form = this.fb.nonNullable.group({
    mood: ['', [Validators.required]],
    intensity: [5, [Validators.required, Validators.min(1), Validators.max(10)]],
    note: ['', [Validators.required, Validators.maxLength(500)]]
  });

  constructor(private readonly fb: FormBuilder, private readonly journal: JournalService) {}

  ngOnChanges(): void {
    if (this.entry) {
      this.form.patchValue({
        mood: this.entry.mood,
        intensity: this.entry.intensity,
        note: this.entry.note
      });
    } else {
      this.form.reset({ mood: '', intensity: 5, note: '' });
    }
  }

  submit(): void {
    this.error = null;
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.isSubmitting = true;
    const payload = this.form.getRawValue();

    const req$ = this.entry
      ? this.journal.update(this.entry.id, payload)
      : this.journal.create(payload);

    req$.subscribe({
      next: () => {
        this.isSubmitting = false;
        this.saved.emit();
      },
      error: (err: unknown) => {
        this.isSubmitting = false;

        if (err instanceof HttpErrorResponse) {
          console.error('Journal save failed', {
            status: err.status,
            url: err.url,
            error: err.error
          });

          const backendMessage =
            (typeof err.error === 'string' && err.error) ||
            (err.error && typeof err.error === 'object' && (err.error.message || err.error.error || JSON.stringify(err.error))) ||
            null;
          this.error = backendMessage
            ? `Failed to save entry: ${backendMessage}`
            : `Failed to save entry (HTTP ${err.status}).`;
          return;
        }

        this.error = 'Failed to save entry.';
      }
    });
  }

  cancel(): void {
    this.cancelled.emit();
  }
}
