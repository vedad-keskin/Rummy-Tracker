export const developer = {
  name: 'Nightfall Studio',
  email: 'vedad.keskin98@gmail.com',
  appName: 'Rummy Tracker',
};

interface PolicySection {
  id: string;
  heading: string;
  paragraphs?: string[];
  bullets?: string[];
}

interface PolicyDocument {
  id: 'en' | 'bs';
  title: string;
  intro: string;
  effective: string;
  sections: PolicySection[];
}

export const policies: PolicyDocument[] = [
  {
    id: 'en',
    title: 'Privacy policy.',
    intro: 'Here is what Rummy Tracker stores, what stays with you, and how you stay in control.',
    effective: '11 November 2026',
    sections: [
      {
        id: 'about',
        heading: 'About this policy',
        paragraphs: ['This privacy policy covers Rummy Tracker, the offline Android companion for keeping score in Rummy and Remi games played with physical cards. The developer is Nightfall Studio.',
          'The app records scores you enter. It does not operate accounts, deal cards, accept wagers, or process payments.'],
      },
      {
        id: 'storage',
        heading: 'What the app stores',
        paragraphs: ['Rummy Tracker uses Android’s app-private storage to save the information needed to run your games:'],
        bullets: ['Player names and the players selected for a game.',
          'Round scores, session totals, and your unfinished game.',
          'All-time win counts and rankings.',
          'Your language and background preferences.'],
      },
      {
        id: 'sharing',
        heading: 'Collection & sharing',
        paragraphs: ['We do not receive, collect, sell, or share your player names, scores, rankings, or app preferences. The app has no developer-run game server or cloud account.',
          'The release app works without an internet connection. It contains no advertising, analytics, advertising ID access, or third-party tracking SDKs.'],
      },
      {
        id: 'backups',
        heading: 'Backups & deleting data',
        paragraphs: ['Game data stays in the app’s local storage until you change or remove it. You can edit or delete players and reset win records in the app. To remove all local app data, clear Rummy Tracker’s storage in Android Settings, or uninstall the app.',
          'Android may include app data in system backups or device-to-device transfers, depending on your device and account settings. These are managed by your operating system and backup provider, not by us. We cannot access those backups.',
          'Uninstalling or clearing storage removes the local copy; a system backup may still exist and may restore data when you reinstall. Manage those copies through your device’s backup settings. We do not retain a separate copy and cannot remotely access or erase data on your phone.'],
      },
      {
        id: 'permissions',
        heading: 'Permissions & security',
        paragraphs: ['The release app does not request internet, location, camera, microphone, contacts, or photo access.',
          'Saved game information is kept in app-private storage. The security of your phone and any system backups also depends on your device lock, account security, and backup settings.'],
      },
      {
        id: 'children',
        heading: 'Children’s privacy',
        paragraphs: ['Rummy Tracker is a general-audience scorekeeper and is not directed at children under 13. The app does not knowingly collect personal information from children. Player names and scores entered in the app are not sent to us.'],
      },
      {
        id: 'website',
        heading: 'Using this website',
        paragraphs: ['This website does not add advertising, analytics, or tracking cookies.',
          'To deliver these pages, our hosting provider receives standard connection information such as your IP address and browser request headers. The provider may maintain operational and security logs under its own policies. This is separate from the offline app.'],
      },
      {
        id: 'changes',
        heading: 'Changes to this policy',
        paragraphs: ['If the app’s data practices change, we will update this page and its effective date. You can always find the current policy here.'],
      },
    ],
  },
  {
    id: 'bs',
    title: 'Politika privatnosti.',
    intro: 'Šta Rummy Tracker čuva, koji podaci ostaju kod vas i kako njima upravljate.',
    effective: '11. novembra 2026.',
    sections: [
      {
        id: 'about',
        heading: 'O ovoj politici',
        paragraphs: ['Ova politika privatnosti odnosi se na Rummy Tracker, vanmrežnu Android aplikaciju za praćenje rezultata remija koji igrate pravim kartama. Razvijatelj je Nightfall Studio.',
          'Aplikacija bilježi rezultate koje unesete. Nema korisničkih naloga, ne dijeli karte, ne prima uloge i ne obrađuje plaćanja.'],
      },
      {
        id: 'storage',
        heading: 'Šta aplikacija čuva',
        paragraphs: ['Rummy Tracker koristi privatnu pohranu aplikacije na Androidu za podatke potrebne za vaše partije:'],
        bullets: ['Imena igrača i igrače odabrane za partiju.',
          'Rezultate rundi, ukupne rezultate i nedovršenu partiju.',
          'Ukupan broj pobjeda i rang-listu.',
          'Odabrani jezik i pozadinu.'],
      },
      {
        id: 'sharing',
        heading: 'Prikupljanje i dijeljenje',
        paragraphs: ['Ne primamo, ne prikupljamo, ne prodajemo i ne dijelimo vaša imena igrača, rezultate, rang-listu ili postavke. Aplikacija nema naš server za igru niti nalog u oblaku.',
          'Objavljena aplikacija radi bez internetske veze. Nema oglasa, analitike, pristupa reklamnom identifikatoru niti alata trećih strana za praćenje.'],
      },
      {
        id: 'backups',
        heading: 'Sigurnosne kopije i brisanje',
        paragraphs: ['Podaci igre ostaju u lokalnoj pohrani aplikacije dok ih ne promijenite ili uklonite. U aplikaciji možete uređivati i brisati igrače te poništiti pobjede. Sve lokalne podatke možete ukloniti brisanjem pohrane aplikacije u Android postavkama ili deinstalacijom.',
          'Android može uključiti podatke aplikacije u sistemske sigurnosne kopije ili prijenos između uređaja, zavisno od postavki uređaja i naloga. Time upravljaju operativni sistem i pružatelj sigurnosne kopije, a ne mi. Nemamo pristup tim kopijama.',
          'Deinstalacija ili brisanje pohrane uklanja lokalnu kopiju. Sistemska sigurnosna kopija može ostati i vratiti podatke nakon ponovne instalacije. Njome upravljate u postavkama sigurnosne kopije uređaja. Ne čuvamo zasebnu kopiju i ne možemo daljinski pristupiti podacima na vašem telefonu niti ih obrisati.'],
      },
      {
        id: 'permissions',
        heading: 'Dozvole i sigurnost',
        paragraphs: ['Objavljena aplikacija ne traži pristup internetu, lokaciji, kameri, mikrofonu, kontaktima ili fotografijama.',
          'Podaci igre čuvaju se u privatnoj pohrani aplikacije. Sigurnost telefona i sistemskih sigurnosnih kopija zavisi i od zaključavanja uređaja, sigurnosti naloga i postavki sigurnosne kopije.'],
      },
      {
        id: 'children',
        heading: 'Privatnost djece',
        paragraphs: ['Rummy Tracker je bilježnik rezultata za opću publiku i nije namijenjen djeci mlađoj od 13 godina. Aplikacija svjesno ne prikuplja lične podatke djece. Imena i rezultati uneseni u aplikaciju ne šalju se nama.'],
      },
      {
        id: 'website',
        heading: 'Ova web stranica',
        paragraphs: ['Ova stranica ne koristi oglase, analitiku ni kolačiće za praćenje.',
          'Za prikaz ovih stranica, pružatelj hostinga prima standardne podatke veze, kao što su IP adresa i zaglavlja zahtjeva preglednika. Može čuvati operativne i sigurnosne zapise prema vlastitim pravilima. To je odvojeno od vanmrežne aplikacije.'],
      },
      {
        id: 'changes',
        heading: 'Izmjene politike',
        paragraphs: ['Ako se način postupanja s podacima promijeni, ažurirat ćemo ovu stranicu i datum stupanja na snagu. Važeću politiku uvijek možete pronaći ovdje.'],
      },
    ],
  },
];
