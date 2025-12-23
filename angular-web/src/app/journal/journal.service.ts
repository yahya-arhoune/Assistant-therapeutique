import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
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
  private readonly baseUrl = '';

  constructor(private readonly http: HttpClient) {}

  create(body: EmotionEntryUpsert): Observable<EmotionEntry> {
    return this.http.post<EmotionEntry>(`${this.baseUrl}/api/journal/create`, body);
  }

  getAll(): Observable<EmotionEntry[]> {
    return this.http.get<EmotionEntry[]>(`${this.baseUrl}/api/journal/all`);
  }

  update(id: number, body: EmotionEntryUpsert): Observable<EmotionEntry> {
    return this.http.put<EmotionEntry>(`${this.baseUrl}/api/journal/${id}`, body);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/api/journal/${id}`);
  }
}
