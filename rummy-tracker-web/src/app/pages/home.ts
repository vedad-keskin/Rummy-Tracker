import { Component, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-home',
  imports: [RouterLink],
  templateUrl: './home.html',
})
export class HomePage {
  constructor() {
    inject(Title).setTitle('Rummy Tracker — Your game-night companion');
    inject(Meta).updateTag({ name: 'description', content: 'Your offline scorekeeper for Rummy and Remi. Track rounds, save your game, and keep the friendly rivalry going. English and Bosnian. No ads or accounts.' });
  }
}
