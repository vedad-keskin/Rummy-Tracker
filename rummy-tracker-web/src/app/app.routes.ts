import { Routes } from '@angular/router';
import { HomePage } from './pages/home';
import { ListingPage } from './pages/listing';
import { PrivacyPage } from './pages/privacy';

export const routes: Routes = [
  { path: '', component: HomePage },
  { path: 'privacy', component: PrivacyPage },
  { path: 'listing', component: ListingPage },
];
