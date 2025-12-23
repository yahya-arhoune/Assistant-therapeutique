import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { EmotionEntry } from '../shared/models/emotion-entry.model';

export interface EmotionEntryUpsert {
  mood: string;
  intensity: number;
  note: string;
}

@Injectable({
  providedIn: 'root'
})
export class JournalService {
  private readonly localStorageKey = 'local_journal_entries';

  private memoryJournalEntries: EmotionEntry[] = [];

  constructor() {}

  private readLocal(): EmotionEntry[] {
    try {
      const raw = localStorage.getItem(this.localStorageKey);
      if (!raw) return this.memoryJournalEntries;
      const parsed = JSON.parse(raw);
      if (!Array.isArray(parsed)) return this.memoryJournalEntries;
      return parsed as EmotionEntry[];
    } catch {
      return this.memoryJournalEntries;
    }
  }

  private writeLocal(entries: EmotionEntry[]): void {
    // Prefer persistence, but keep app usable even if storage is unavailable (e.g. blocked).
    this.memoryJournalEntries = entries;
    try {
      localStorage.setItem(this.localStorageKey, JSON.stringify(entries));
    } catch {
      // Keep in-memory fallback.
    }
  }

  private nextLocalId(entries: EmotionEntry[]): number {
    const maxId = entries.reduce((m, e) => (typeof e.id === 'number' && e.id > m ? e.id : m), 0);
    return maxId + 1;
  }

  private createLocal(body: EmotionEntryUpsert): EmotionEntry {
    const entries = this.readLocal();
    const entry: EmotionEntry = {
      id: this.nextLocalId(entries),
      mood: body.mood,
      intensity: body.intensity,
      note: body.note,
      createdAt: new Date().toISOString()
    };
    this.writeLocal([entry, ...entries]);
    return entry;
  }

  private updateLocal(id: number, body: EmotionEntryUpsert): EmotionEntry {
    const entries = this.readLocal();
    const idx = entries.findIndex((e) => e.id === id);
    const existing = idx >= 0 ? entries[idx] : null;
    const updated: EmotionEntry = {
      id,
      mood: body.mood,
      intensity: body.intensity,
      note: body.note,
      createdAt: existing?.createdAt ?? new Date().toISOString()
    };
    const next = idx >= 0 ? entries.map((e) => (e.id === id ? updated : e)) : [updated, ...entries];
    this.writeLocal(next);
    return updated;
  }

  private deleteLocal(id: number): void {
    const entries = this.readLocal();
    this.writeLocal(entries.filter((e) => e.id !== id));
  }

  create(body: EmotionEntryUpsert): Observable<EmotionEntry> {
    return of(this.createLocal(body));
  }

  getAll(): Observable<EmotionEntry[]> {
    return of(this.readLocal());
  }

  update(id: number, body: EmotionEntryUpsert): Observable<EmotionEntry> {
    return of(this.updateLocal(id, body));
  }

  delete(id: number): Observable<void> {
    this.deleteLocal(id);
    return of(void 0);
  }
}
