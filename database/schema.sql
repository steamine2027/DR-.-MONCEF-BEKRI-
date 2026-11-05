-- ════════════════════════════════════════════════════════════════════
-- CLOUD (Supabase, PostgreSQL) — applied to project "DR MONCEF BEKRI"
-- Every row of every local table is mirrored here as JSON, per signed-in owner.
-- Rows are never hard-deleted: a deletion only sets deleted_at.
-- ════════════════════════════════════════════════════════════════════
create table if not exists public.clinic_rows (
  owner_id   uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  device_id  text        not null,
  table_name text        not null,
  row_id     text        not null,
  data       jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (owner_id, device_id, table_name, row_id)
);

create index if not exists clinic_rows_owner_device_idx
  on public.clinic_rows (owner_id, device_id, table_name);

create or replace function public.clinic_rows_touch()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists clinic_rows_touch on public.clinic_rows;
create trigger clinic_rows_touch
  before update on public.clinic_rows
  for each row execute function public.clinic_rows_touch();

alter table public.clinic_rows enable row level security;

create policy "clinic_rows_select_own" on public.clinic_rows
  for select to authenticated using (owner_id = (select auth.uid()));
create policy "clinic_rows_insert_own" on public.clinic_rows
  for insert to authenticated with check (owner_id = (select auth.uid()));
create policy "clinic_rows_update_own" on public.clinic_rows
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));
-- Deliberately NO delete policy: rows cannot be removed through the API.

revoke all on public.clinic_rows from anon;
revoke all on public.clinic_rows from authenticated;
grant select, insert, update on public.clinic_rows to authenticated;

-- ════════════════════════════════════════════════════════════════════
-- LOCAL — MediCore database schema (SQLite, browser working copy).
-- The app creates these tables automatically on first load (createTables() in index.html).
-- The table and column definitions below match createTables() exactly.
-- The CREATE INDEX lines at the bottom are NOT created by the app; they are optional
-- suggestions for a future server-side database.

CREATE TABLE IF NOT EXISTS patients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dossier TEXT,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  dob TEXT,
  gender TEXT,
  blood_group TEXT,
  phone TEXT,
  phone2 TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  profession TEXT,
  marital_status TEXT,
  insurance TEXT,
  nss TEXT,
  referring_doctor TEXT,
  allergies TEXT,
  antecedents TEXT,
  family_antecedents TEXT,
  current_treatments TEXT,
  status TEXT DEFAULT 'actif',
  emergency_contact TEXT,
  notes TEXT,
  avatar TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS appointments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  date TEXT NOT NULL,            -- YYYY-MM-DD (local calendar day)
  time TEXT NOT NULL,            -- HH:MM
  duration INTEGER DEFAULT 30,   -- minutes
  type TEXT DEFAULT 'Consultation',
  motif TEXT,
  notes TEXT,
  priority TEXT DEFAULT 'normale',
  status TEXT DEFAULT 'planifié',
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS consultations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  date TEXT,
  time TEXT,
  motif TEXT,
  bp TEXT,
  pulse INTEGER,
  temperature REAL,
  spo2 INTEGER,
  weight REAL,
  height INTEGER,
  imc REAL,
  respiratory_rate INTEGER,
  anamnesis TEXT,
  clinical_exam TEXT,
  diagnosis TEXT,
  exams_requested TEXT,
  treatment TEXT,
  recommendations TEXT,
  next_appointment TEXT,
  status TEXT DEFAULT 'terminée',
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS ordonnances (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  date TEXT,
  type TEXT DEFAULT 'Ordonnance simple',
  drugs TEXT,                    -- JSON array of prescribed items
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS patient_images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  data TEXT,                     -- data URL (JPEG after compression)
  description TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS settings_kv (
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE TABLE IF NOT EXISTS certificats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  date TEXT,
  type TEXT DEFAULT 'Aptitude physique',
  objet TEXT,
  body TEXT,
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS certificats_repos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,
  date TEXT,
  date_debut TEXT,
  date_fin TEXT,
  duree INTEGER,
  type TEXT DEFAULT 'Repos à domicile',
  motif TEXT,
  recommandations TEXT,
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER,            -- NULL when the patient was deleted (accounting kept)
  type TEXT DEFAULT 'recette',   -- 'recette' | 'depense'
  date TEXT,
  montant REAL,                  -- amount in DT (3 decimals = millimes)
  mode TEXT DEFAULT 'Espèces',
  categorie TEXT,
  description TEXT,
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY(patient_id) REFERENCES patients(id)
);

CREATE TABLE IF NOT EXISTS medicaments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  dci TEXT,
  classe TEXT,
  forme TEXT,
  dosage TEXT,
  posologie TEXT,
  voie TEXT,
  contre_indications TEXT,
  stock INTEGER DEFAULT 0,
  prix REAL DEFAULT 0,
  disponibilite TEXT DEFAULT 'disponible',  -- 'disponible' | 'rupture' | 'sur_ordonnance'
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
CREATE INDEX IF NOT EXISTS idx_consultations_patient ON consultations(patient_id);
CREATE INDEX IF NOT EXISTS idx_ordonnances_patient ON ordonnances(patient_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
