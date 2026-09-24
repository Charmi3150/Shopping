-- Shopmap België -- Supabase schema
-- Voer dit uit in de Supabase SQL editor van je project.

create extension if not exists "pgcrypto";

-- Alle winkels: zowel opgehaald uit OpenStreetMap als zelf toegevoegd.
create table if not exists shops (
  id text primary key,                 -- 'osm-node-123456' of 'user-<uuid>'
  source text not null default 'user', -- 'osm' | 'user'
  name text not null,
  category text not null,              -- 'kleding' | 'schoenen' | 'accessoires' | 'decoratie'
  gender text[] not null default '{}', -- subset van {'dames','heren','kinderen'}
  gender_is_override boolean not null default false, -- true zodra Sofie het zelf aanpaste
  lat double precision not null,
  lng double precision not null,
  city text,
  address text,
  is_favorite boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists shops_category_idx on shops (category);
create index if not exists shops_favorite_idx on shops (is_favorite);

-- Route(s) die Sofie samenstelt: geordende lijst van shop-id's.
create table if not exists routes (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Mijn route',
  shop_ids text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Bijhouden wanneer de OSM-data voor het laatst ververst is.
create table if not exists sync_state (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Simpele opzet zonder login (zoals de Ibiza-tool): iedereen met de anon key
-- mag lezen/schrijven. Voldoende voor persoonlijk gebruik met gedeelde link.
alter table shops enable row level security;
alter table routes enable row level security;
alter table sync_state enable row level security;

create policy "shops_all" on shops for all using (true) with check (true);
create policy "routes_all" on routes for all using (true) with check (true);
create policy "sync_state_all" on sync_state for all using (true) with check (true);
