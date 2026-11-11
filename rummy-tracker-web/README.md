# Rummy Tracker site

Public pages for the Android app: an overview, the privacy policy, and the Google Play listing text.

The privacy policy URL to paste into Play Console, after deploy, is:

`https://<your-vercel-domain>/privacy`

## Deploy on Vercel

1. Import this folder as the project. If you import the parent Rummy Tracker repository, set the root directory to `rummy-tracker-web`.
2. Vercel should pick up `vercel.json`:
   - Build command: `npm run build`
   - Output directory: `dist/rummy-tracker-web/browser`
3. No environment variables are required.
4. Deploy, then open `/privacy` and `/listing` on the live domain.

`npm run build` writes a static site. The pages are prerendered, so the privacy policy is in the HTML.
