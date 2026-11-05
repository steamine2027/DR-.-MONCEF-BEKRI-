# MediCore — Cabinet Médical

Medical-office manager (patients, agenda, consultations, prescriptions, medical and
sick-leave certificates, finance, medicine base). The app runs in the browser and saves
every change automatically to a Supabase cloud database.

## Run it

Open `index.html` in a modern browser (Chrome, Edge, Firefox, Safari), or use the
GitHub Pages link once it is enabled.

The app loads sql.js (SQLite in WebAssembly) from cdnjs.cloudflare.com, the Supabase
client from `assets/supabase.js` (bundled), and fonts from Google Fonts. For drug thumbnails it asks the
English and French Wikipedia APIs for the medicine's name only (DCI or brand).

## Where the data lives

- **Working copy:** SQLite in the browser (`localStorage`, key `medicoreDB`).
- **Cloud copy:** Supabase project **DR MONCEF BEKRI** (region eu-north-1, Stockholm),
  table `public.clinic_rows`. Every table row is stored there as JSON, under the
  signed-in doctor's account.
- **No sign-in.** The app writes straight to the database with the publishable key.
  Every row belongs to one clinic id (`6f1d2c3a-0000-4000-8000-00000000c11c`).
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

- **Accepted risk (owner's decision):** without sign-in, anyone who has the site link and the
  publishable key (visible in the page source) can read and change the clinic's rows.
  Rows cannot be hard-deleted through the API, but they can be overwritten or soft-deleted.
- Row-level security limits every request to the clinic id above; there is no DELETE policy.
- Do not put real patient records in this version until you decide on sign-in or another access control.
- Health data: check your legal obligations on storing patient data before using real records.

## Database

- Cloud schema: `database/schema.sql` (the `clinic_rows` table and its policies).
- Local schema (created automatically on first load): `patients`, `appointments`,
  `consultations`, `ordonnances`, `patient_images`, `certificats`, `certificats_repos`,
  `transactions`, `medicaments`, `settings_kv`.

## Installer sur téléphone

- **Android (Chrome)** : ouvrez le lien, puis menu ⋮ → **Installer l'application** (ou *Ajouter à l'écran d'accueil*).
- **iPhone (Safari)** : ouvrez le lien, puis Partager → **Sur l'écran d'accueil**.

L'application s'ouvre ensuite en plein écran, comme une application. Une fois ouverte une première fois avec Internet,
elle reste disponible hors ligne ; les modifications sont envoyées au cloud dès que la connexion revient.

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

## Hors ligne et stockage des données

- **Première ouverture avec internet** : l'application et son moteur de base de données sont enregistrés sur l'appareil. Ensuite, elle s'ouvre et fonctionne **sans connexion**.
- **Stockage** : les données sont enregistrées dans la base IndexedDB du navigateur (plusieurs centaines de Mo), et non plus dans localStorage (environ 5 Mo). L'application demande au navigateur de ne pas effacer ces données (stockage persistant).
- **Sans réseau** : tout est enregistré sur l'appareil. La sauvegarde cloud reprend automatiquement au retour de la connexion.
- À éviter : vider les données du site dans le navigateur, ou désinstaller le navigateur, sans avoir fait d'abord une sauvegarde JSON.
