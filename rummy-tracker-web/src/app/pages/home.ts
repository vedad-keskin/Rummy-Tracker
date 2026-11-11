import { Component, inject } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { developer } from '../site-content';

@Component({
  selector: 'app-home',
  imports: [RouterLink],
  templateUrl: './home.html',
})
export class HomePage {
  protected readonly developer = developer;

  constructor() {
    inject(Title).setTitle('Rummy Tracker');
  }
}
