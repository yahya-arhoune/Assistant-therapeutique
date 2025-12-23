import { Component, OnInit } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { EmotionEntry } from '../shared/models/emotion-entry.model';
import { JournalService } from './journal.service';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-journal-list',
  templateUrl: './journal-list.component.html'
})
export class JournalListComponent implements OnInit {
  entries: EmotionEntry[] = [];
  loading = false;
  error: string | null = null;

  seeding = false;

  showForm = false;
  editing: EmotionEntry | null = null;

  constructor(private readonly journal: JournalService) {}

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading = true;
    this.error = null;

    this.journal.getAll().subscribe({
      next: (items) => {
        this.entries = items;
        this.loading = false;
      },
      error: (err: unknown) => {
        this.loading = false;
        if (err instanceof HttpErrorResponse) {
          console.error('Journal load failed', {
            status: err.status,
            url: err.url,
            error: err.error
          });

          const backendMessage =
            (typeof err.error === 'string' && err.error) ||
            (err.error && typeof err.error === 'object' && (err.error.message || err.error.error || JSON.stringify(err.error))) ||
            null;
          this.error = backendMessage
            ? `Failed to load journal entries: ${backendMessage}`
            : `Failed to load journal entries (HTTP ${err.status}).`;
          return;
        }

        this.error = 'Failed to load journal entries.';
      }
    });
  }

  seedSampleEntries(): void {
    this.error = null;
    this.seeding = true;

    const samples = [
      { mood: 'Starglow Calm', intensity: 7, note: 'Breathing felt steady today. I handled a difficult moment without spiraling.' },
      { mood: 'Nebula Focus', intensity: 8, note: 'Deep work session went well. Short walk + water helped keep me grounded.' }
    ];

    forkJoin(samples.map((s) => this.journal.create(s))).subscribe({
      next: () => {
        this.seeding = false;
        this.load();
      },
      error: (err: unknown) => {
        this.seeding = false;
        if (err instanceof HttpErrorResponse) {
          console.error('Journal seed failed', {
            status: err.status,
            url: err.url,
            error: err.error
          });

          const backendMessage =
            (typeof err.error === 'string' && err.error) ||
            (err.error && typeof err.error === 'object' && (err.error.message || err.error.error || JSON.stringify(err.error))) ||
            null;
          this.error = backendMessage
            ? `Failed to add sample entries: ${backendMessage}`
            : `Failed to add sample entries (HTTP ${err.status}).`;
          return;
        }
        this.error = 'Failed to add sample entries.';
      }
    });
  }

  newEntry(): void {
    this.editing = null;
    this.showForm = true;
  }

  edit(entry: EmotionEntry): void {
    this.editing = entry;
    this.showForm = true;
  }

  remove(entry: EmotionEntry): void {
    const confirmed = confirm('Delete this entry?');
    if (!confirmed) return;

    this.journal.delete(entry.id).subscribe({
      next: () => {
        this.entries = this.entries.filter((e) => e.id !== entry.id);
      },
      error: () => {
        this.error = 'Failed to delete entry.';
      }
    });
  }

  onSaved(): void {
    this.showForm = false;
    this.editing = null;
    this.load();
  }

  onCancelled(): void {
    this.showForm = false;
    this.editing = null;
  }
}
