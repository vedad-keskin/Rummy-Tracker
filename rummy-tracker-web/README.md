# Rummy Tracker website

A short app homepage at `/` and the privacy policy at `/privacy`, with English and Bosnian policy text. Both pages are prerendered into public HTML.

## Run locally

```sh
npm install
npm start
```

## Validate

```sh
npm test
```

This builds the production site and checks the exported pages, policy content, links and bundled imagery.

## Deploy on Vercel

Use `rummy-tracker-web` as the project root. The existing `vercel.json` sets:

- Build command: `npm run build`
- Output directory: `dist/rummy-tracker-web/browser`

No environment variables are needed. After deployment, use your public HTTPS `/privacy` URL in Play Console. Open that direct URL in a signed-out browser to verify it is accessible.

The policy describes the current offline app, local storage, device-managed backups, retention and deletion, website hosting, and email contact. Keep it aligned with any future changes to the app.

The hero photograph was generated with the built-in imagegen tool; its prompt is saved in the workspace’s ignored `output/website/` directory.
