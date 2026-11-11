import { Component, computed, inject, signal } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { policies } from '../site-content';

@Component({
  selector: 'app-privacy',
  imports: [RouterLink],
  templateUrl: './privacy.html',
})
export class PrivacyPage {
  protected readonly policies = policies;
  protected readonly language = signal<'en' | 'bs'>('en');
  protected readonly policy = computed(() => policies[this.language() === 'en' ? 0 : 1]);
  protected readonly isBosnian = computed(() => this.language() === 'bs');

  constructor() {
    inject(Title).setTitle('Privacy policy — Rummy Tracker');
    inject(Meta).updateTag({ name: 'description', content: 'How Rummy Tracker stores your player names, scores, rankings, and preferences. Read about device storage, system backups, and deleting your data.' });
  }
}
