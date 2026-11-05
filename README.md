# MediCore — Cabinet Médical

Single-page medical-office manager (patients, agenda, consultations, prescriptions,
medical and sick-leave certificates, finance, medicine base). Runs entirely in the browser.

## Run it

Open `index.html` in a modern browser (Chrome, Edge, Firefox, Safari).
The app loads sql.js (SQLite in WebAssembly) from cdnjs.cloudflare.com and fonts from Google Fonts.
For drug thumbnails it asks the English and French Wikipedia APIs for the medicine's name (DCI or brand).
Patient, consultation and finance data are never sent anywhere.

## Where the data lives — read this

- The database is **SQLite compiled to WebAssembly**, stored in the browser's `localStorage`
  (key `medicoreDB`, compact base64). There is no backend server.
- Data belongs to the browser profile on that computer. Clearing site data erases it.
- Back up regularly: **Paramètres → Exporter (JSON)**. The app reminds you after 7 days.
- Import a backup with **Paramètres → Importer**.

## Database

The schema is in `database/schema.sql` and is created automatically on first load.
Tables: `patients`, `appointments`, `consultations`, `ordonnances`, `patient_images`,
`certificats`, `certificats_repos`, `transactions`, `medicaments`, `settings_kv`.

## Shortcuts

| Keys | Action |
| --- | --- |
| Ctrl/⌘ + K | Command palette: find a patient, open a page, run an action |
| Esc | Close the top-most dialog, lightbox or menu |

## Deploy as a link (GitHub Pages)

Push to `main`. The workflow in `.github/workflows/pages.yml` publishes the folder to Pages.
In the repository settings, set **Pages → Source: GitHub Actions** once.

## Privacy

This repository contains **no patient data**. The demo names in the markup were replaced
with placeholders. Do not commit exported backups (`*.json`) — they are ignored by `.gitignore`.
