import { Component, inject } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { policies } from '../site-content';

@Component({
  selector: 'app-privacy',
  templateUrl: './privacy.html',
})
export class PrivacyPage {
  protected readonly policies = policies;

  constructor() {
    inject(Title).setTitle('Privacy policy · Rummy Tracker');
  }
}
