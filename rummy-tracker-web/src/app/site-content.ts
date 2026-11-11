export const developer = {
  name: 'Vedad Keskin',
  email: 'vedad.keskin98@gmail.com',
  appName: 'Rummy Tracker',
  packageId: 'com.rummy.tracker',
  versionName: '3.1.2',
  versionCode: '1',
};

export interface PolicySection {
  heading: string;
  paragraphs?: string[];
  bullets?: string[];
}

export interface PolicyDocument {
  id: 'en' | 'bs';
  languageName: string;
  title: string;
  effective: string;
  sections: PolicySection[];
}

export interface ListingCopy {
  id: 'en' | 'bs';
  languageName: string;
  appName: string;
  shortDescription: string;
  fullDescription: string;
}

export const policies: PolicyDocument[] = [
  {
    id: 'en',
    languageName: 'English',
    title: 'Privacy policy',
    effective: 'Effective 11 November 2026',
    sections: [
      {
        heading: 'Who this covers',
        paragraphs: [
          'This policy describes Rummy Tracker, an offline Android app for keeping score in Rummy and Remi. The developer is Vedad Keskin. Contact: vedad.keskin98@gmail.com.',
          'The app does not deal cards, accept wagers, process payments, or connect to a game server. It records scores you enter.',
        ],
      },
      {
        heading: 'Information stored on your device',
        paragraphs: [
          'The app saves the following in private storage on your phone. None of it is uploaded.',
        ],
        bullets: [
          'Player names you type',
          'Round scores, including the preset values -40, -140, and -500, and any custom number you enter',
          'Session totals and the in-progress game, so a session can resume after you close the app',
          'All-time win counts',
          'Your language choice, English or Bosnian',
        ],
      },
      {
        heading: 'Information we do not collect',
        paragraphs: [
          'We do not collect, transmit, or share the information above. The release app does not use the internet. It has no accounts, no advertising, no analytics, and no advertising ID. No third-party service receives data from the app.',
        ],
      },
      {
        heading: 'Permissions',
        paragraphs: [
          'The release version does not request network, location, camera, microphone, contacts, or photo access.',
        ],
      },
      {
        heading: 'Children',
        paragraphs: [
          'Rummy Tracker is a general-audience scorekeeper. It is not directed at children under 13, and it does not knowingly collect personal information from children. Names you type stay on the device.',
        ],
      },
      {
        heading: 'How long data stays',
        paragraphs: [
          'Data remains on the device until you delete a player, reset win records, clear the app’s storage, or uninstall the app. Uninstalling the app deletes it. We do not keep a copy.',
        ],
      },
      {
        heading: 'Your choices',
        paragraphs: [
          'You can edit or delete player names in the app, reset rankings, and leave an unfinished game. Because nothing is sent to us, we cannot access or delete that data for you.',
        ],
      },
      {
        heading: 'Changes',
        paragraphs: [
          'If this policy changes, the new version will be posted on this page with a new effective date.',
        ],
      },
      {
        heading: 'Contact',
        paragraphs: ['Vedad Keskin', 'vedad.keskin98@gmail.com'],
      },
    ],
  },
  {
    id: 'bs',
    languageName: 'Bosanski',
    title: 'Politika privatnosti',
    effective: 'Stupa na snagu 11. novembra 2026.',
    sections: [
      {
        heading: 'Na koga se odnosi',
        paragraphs: [
          'Ova politika opisuje Rummy Tracker, vanmrežnu Android aplikaciju za praćenje rezultata igre remi (rummy). Razvijatelj je Vedad Keskin. Kontakt: vedad.keskin98@gmail.com.',
          'Aplikacija ne dijeli karte, ne prima uloge, ne obrađuje novac i ne povezuje se sa serverom za igru. Bilježi rezultate koje vi unesete.',
        ],
      },
      {
        heading: 'Podaci koji ostaju na uređaju',
        paragraphs: [
          'Aplikacija čuva sljedeće u privatnoj pohrani na telefonu. Ništa od toga se ne šalje.',
        ],
        bullets: [
          'Imena igrača koja upišete',
          'Rezultate rundi, uključujući gotove vrijednosti -40, -140 i -500, i svaki broj koji sami unesete',
          'Zbirove sesije i nedovršenu partiju, kako biste mogli nastaviti nakon zatvaranja aplikacije',
          'Ukupan broj pobjeda',
          'Odabrani jezik, engleski ili bosanski',
        ],
      },
      {
        heading: 'Podaci koje ne prikupljamo',
        paragraphs: [
          'Te podatke ne prikupljamo, ne prenosimo i ne dijelimo. Objavljena verzija ne koristi internet. Nema naloga, nema oglasa, nema analitike i nema reklamnog identifikatora. Nijedna usluga treće strane ne prima podatke iz aplikacije.',
        ],
      },
      {
        heading: 'Dozvole',
        paragraphs: [
          'Objavljena verzija ne traži pristup mreži, lokaciji, kameri, mikrofonu, kontaktima ni fotografijama.',
        ],
      },
      {
        heading: 'Djeca',
        paragraphs: [
          'Rummy Tracker je bilježnik rezultata za opštu publiku. Nije usmjeren na djecu mlađu od 13 godina i svjesno ne prikuplja lične podatke djece. Imena koja upišete ostaju na uređaju.',
        ],
      },
      {
        heading: 'Koliko dugo podaci ostaju',
        paragraphs: [
          'Podaci ostaju na uređaju dok ne obrišete igrača, ne poništite pobjede, ne obrišete pohranu aplikacije ili je ne deinstalirate. Deinstalacija briše podatke. Mi nemamo njihovu kopiju.',
        ],
      },
      {
        heading: 'Vaš izbor',
        paragraphs: [
          'Imena igrača možete urediti ili obrisati u aplikaciji, poništiti rang-listu i napustiti nedovršenu partiju. Pošto nam se ništa ne šalje, ne možemo pristupiti tim podacima niti ih obrisati umjesto vas.',
        ],
      },
      {
        heading: 'Izmjene',
        paragraphs: [
          'Ako se ova politika promijeni, nova verzija biće objavljena na ovoj stranici sa novim datumom.',
        ],
      },
      {
        heading: 'Kontakt',
        paragraphs: ['Vedad Keskin', 'vedad.keskin98@gmail.com'],
      },
    ],
  },
];

export const listings: ListingCopy[] = [
  {
    id: 'en',
    languageName: 'English',
    appName: 'Rummy Tracker',
    shortDescription:
      'Offline Rummy and Remi scorekeeper. No betting, cards, or accounts.',
    fullDescription: `Rummy Tracker keeps score for Rummy and Remi. It does not deal cards, take bets, or move money. You play the cards at the table. The app only records the result.

Live rounds
Add each round one player at a time. Preset scores cover a regular win (-40), going out (-140), and a rummy (-500). You can also type any whole number. After every score, the table sorts itself. The lowest total wins.

Resume a session
An unfinished game is saved on the phone. Close the app and continue the same session later.

Players and all-time wins
Add, rename, and delete players. When you finish a session, the winner's career win count updates on the rankings screen.

Edit a game while it is in progress
Change a score from an earlier round, remove a player, or add someone to the current session. A game needs at least two players.

English and Bosnian
Switch language at any time. Every screen is available in both.

Nothing leaves the phone
Names, scores, and rankings stay on the device. There is no account, no advertising, and the release app does not use the internet.`,
  },
  {
    id: 'bs',
    languageName: 'Bosanski',
    appName: 'Rummy Tracker',
    shortDescription: 'Vanmrežni bilježnik rezultata za remi. Bez klađenja, karata i naloga.',
    fullDescription: `Rummy Tracker vodi rezultat za remi (rummy). Ne dijeli karte, ne prima uloge i ne prenosi novac. Karte igrate za stolom. Aplikacija samo bilježi rezultat.

Runde
Rundu dodajete igrač po igrač. Gotove vrijednosti su obična pobjeda (-40), izlazak (-140) i remi (-500). Možete upisati i bilo koji cijeli broj. Poslije svakog rezultata tabela se sama sortira. Najmanji zbir pobjeđuje.

Nastavak partije
Nedovršena partija ostaje sačuvana na telefonu. Zatvorite aplikaciju i nastavite istu sesiju kasnije.

Igrači i pobjede
Igrače možete dodati, preimenovati i obrisati. Kada završite sesiju, broj pobjeda pobjednika ažurira se na rang-listi.

Izmjene tokom igre
Možete ispraviti rezultat iz ranije runde, ukloniti igrača ili dodati nekoga u tekuću sesiju. Za partiju su potrebna najmanje dva igrača.

Engleski i bosanski
Jezik možete promijeniti u bilo kojem trenutku. Svaki ekran postoji na oba jezika.

Ništa ne napušta telefon
Imena, rezultati i rang-lista ostaju na uređaju. Nema naloga, nema oglasa, a objavljena aplikacija ne koristi internet.`,
  },
];

export const playConsole = [
  { label: 'App name', value: developer.appName },
  { label: 'Package name', value: developer.packageId },
  { label: 'Version name', value: developer.versionName },
  { label: 'Version code', value: developer.versionCode },
  { label: 'Price', value: 'Free' },
  { label: 'Type', value: 'Game' },
  { label: 'Category', value: 'Cards' },
  { label: 'Ads', value: 'No' },
  { label: 'In-app purchases', value: 'No' },
  { label: 'App access', value: 'All features are available without a login.' },
  {
    label: 'Privacy policy URL',
    value: 'https://<your-vercel-domain>/privacy',
  },
  { label: 'Developer email', value: developer.email },
  {
    label: 'Data safety',
    value:
      'Data is not collected and not shared. Player names, scores, rankings, and language stay on the device. No advertising ID.',
  },
  {
    label: 'Content rating',
    value:
      'Scorekeeper only. No violence, sexual content, user chat, location sharing, digital purchases, or real-money or simulated gambling.',
  },
  {
    label: 'Target audience',
    value: 'Not a children\'s app. Do not opt into the Families program.',
  },
  { label: 'Financial features', value: 'None. The app does not take stakes or move money.' },
  { label: 'News, health, government', value: 'No' },
];
