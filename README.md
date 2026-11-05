# MediCore — Cabinet Médical

Medical-office manager (patients, agenda, consultations, prescriptions, medical and
sick-leave certificates, finance, medicine base). The app runs in the browser and saves
every change automatically to a Supabase cloud database.

## Run it

Open `index.html` in a modern browser (Chrome, Edge, Firefox, Safari), or use the
GitHub Pages link once it is enabled.

The app loads sql.js (SQLite in WebAssembly) from cdnjs.cloudflare.com, the Supabase
client from cdn.jsdelivr.net, and fonts from Google Fonts. For drug thumbnails it asks the
English and French Wikipedia APIs for the medicine's name only (DCI or brand).

## Where the data lives

- **Working copy:** SQLite in the browser (`localStorage`, key `medicoreDB`).
- **Cloud copy:** Supabase project **DR MONCEF BEKRI** (region eu-north-1, Stockholm),
  table `public.clinic_rows`. Every table row is stored there as JSON, under the
  signed-in doctor's account.
- **Sign-in is required** when the app is online. Without a session, the screen shows a
  login form. Create the account from the same form, then confirm the email if Supabase asks.
- Each change is uploaded within a few seconds. The badge in the bottom-left corner shows
  the state: saved, saving, waiting for the network, or offline. Click it to sync now.
- If the network is down, changes stay in the browser and upload when the connection returns.

## Never losing data

- **Nothing is hard-deleted in the cloud.** A deletion only sets `deleted_at` on the row.
  The table has no DELETE policy, so the API cannot remove rows.
- **Empty browser → automatic restore.** If a browser has no patients and the cloud has
  some, the app restores them on start-up.
- **Manual restore:** Ctrl/⌘ + K → *Restaurer depuis le cloud*. The app first downloads a
  JSON backup of the current data.
- **Keep one main device.** If another device has written a newer version, the badge warns you.
  Your local changes are still uploaded, and the other device's rows are never overwritten.
- **Extra safety:** Paramètres → Exporter (JSON) still works, and the app reminds you after 7 days.

## Security

- Row-level security is on. A signed-in user can read and write only their own rows (`owner_id = auth.uid()`).
  Anonymous visitors see nothing.
- The publishable key in `index.html` is designed to be public. Access control comes from
  sign-in and RLS, not from keeping the key secret.
- Local data stays in the browser after sign-out. Clear the site data to remove it from a computer.
- Health data: check your legal obligations on storing patient data before using real records.

## Database

- Cloud schema: `database/schema.sql` (the `clinic_rows` table and its policies).
- Local schema (created automatically on first load): `patients`, `appointments`,
  `consultations`, `ordonnances`, `patient_images`, `certificats`, `certificats_repos`,
  `transactions`, `medicaments`, `settings_kv`.

## Shortcuts

| Keys | Action |
| --- | --- |
| Ctrl/⌘ + K | Command palette: find a patient, open a page, sync, restore, sign out |
| Esc | Close the top-most dialog, lightbox or menu |

## Deploy as a link (GitHub Pages)

Push to `main`. The workflow in `.github/workflows/pages.yml` publishes the folder to Pages.
In the repository settings, set **Pages → Source: GitHub Actions** once.

## Privacy of this repository

This repository contains **no patient data**. Demo names in the markup are placeholders.
Do not commit exported backups (`*.json`); `.gitignore` excludes them.
