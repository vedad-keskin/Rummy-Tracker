import { Routes } from '@angular/router';
import { HomePage } from './pages/home';
import { PrivacyPage } from './pages/privacy';

export const routes: Routes = [
  { path: '', component: HomePage },
  { path: 'privacy', component: PrivacyPage },
];
