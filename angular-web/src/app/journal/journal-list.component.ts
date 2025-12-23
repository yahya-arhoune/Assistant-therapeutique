import { Component, OnInit } from '@angular/core';
import { EmotionEntry } from '../shared/models/emotion-entry.model';
import { JournalService } from './journal.service';

@Component({
  selector: 'app-journal-list',
  templateUrl: './journal-list.component.html'
})
export class JournalListComponent implements OnInit {
  entries: EmotionEntry[] = [];
  loading = false;
  error: string | null = null;

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
      error: () => {
        this.loading = false;
        this.error = 'Failed to load journal entries.';
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
