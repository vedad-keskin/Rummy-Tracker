import { Component, inject, signal } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { developer, listings, playConsole } from '../site-content';

@Component({
  selector: 'app-listing',
  templateUrl: './listing.html',
})
export class ListingPage {
  protected readonly developer = developer;
  protected readonly listings = listings;
  protected readonly playConsole = playConsole;
  protected readonly copied = signal<string | null>(null);

  constructor() {
    inject(Title).setTitle('Play listing · Rummy Tracker');
  }

  protected limits = {
    name: 30,
    short: 80,
    full: 4000,
  };

  protected async copy(id: string, value: string): Promise<void> {
    try {
      await navigator.clipboard.writeText(value);
      this.copied.set(id);
    } catch {
      this.copied.set(null);
    }
  }
}
