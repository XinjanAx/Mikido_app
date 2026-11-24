-- Torneo App (Club MIKIDO) — esquema de Supabase (Postgres)

create extension if not exists pgcrypto;

create table public.profiles (
  id uuid not null,
  email text not null,
  name text not null,
  role text not null default 'user'::text check (role = any (array['admin'::text, 'user'::text])),
  created_at timestamp with time zone default now(),
  constraint profiles_pkey primary key (id),
  constraint profiles_id_fkey foreign key (id) references auth.users(id)
);

-- Mesa: lugar físico (cancha, tatami, ring...) con varias categorías.
create table public.mesas (
  id uuid not null default gen_random_uuid(),
  name text not null,
  description text,
  created_by uuid,
  created_at timestamp with time zone default now(),
  constraint mesas_pkey primary key (id),
  constraint mesas_created_by_fkey foreign key (created_by) references public.profiles(id)
);

-- tournaments = "categorías" en la UI de la app.
create table public.tournaments (
  id uuid not null default gen_random_uuid(),
  name text not null,
  mode text not null check (mode = any (array['groups'::text, 'elimination'::text, 'league'::text])),
  status text not null default 'draft'::text check (status = any (array['draft'::text, 'active'::text, 'finished'::text, 'cancelled'::text])),
  description text,
  start_date timestamp with time zone not null,
  end_date timestamp with time zone not null,
  created_by uuid,
  created_at timestamp with time zone default now(),
  mesa_id uuid,
  color text, -- color de la categoría, '#RRGGBB'
  constraint tournaments_pkey primary key (id),
  constraint tournaments_created_by_fkey foreign key (created_by) references public.profiles(id),
  constraint tournaments_mesa_id_fkey foreign key (mesa_id) references public.mesas(id)
);

create table public.players (
  id uuid not null default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  birth_date date,
  photo_url text,
  created_at timestamp with time zone default now(),
  -- Gremio o clan (opcional) y su acrónimo (máx. 4 letras, mayúsculas,
  -- obligatorio si hay gremio).
  guild text,
  guild_acronym text,
  constraint players_pkey primary key (id),
  constraint players_guild_acronym_check check (
    (guild is null and guild_acronym is null)
    or (guild is not null and guild_acronym is not null
        and char_length(guild_acronym) between 1 and 4
        and guild_acronym = upper(guild_acronym))
  )
);

create table public.enrollments (
  id uuid not null default gen_random_uuid(),
  player_id uuid not null,
  tournament_id uuid not null,
  enrolled_at timestamp with time zone default now(),
  constraint enrollments_pkey primary key (id),
  constraint enrollments_player_id_fkey foreign key (player_id) references public.players(id),
  constraint enrollments_tournament_id_fkey foreign key (tournament_id) references public.tournaments(id)
);

create table public.matches (
  id uuid not null default gen_random_uuid(),
  tournament_id uuid not null,
  home_player_id uuid not null,
  away_player_id uuid not null,
  home_player_name text not null default ''::text,
  away_player_name text not null default ''::text,
  home_score integer,
  away_score integer,
  status text not null default 'pending'::text check (status = any (array['pending'::text, 'in_progress'::text, 'finished'::text])),
  scheduled_at timestamp with time zone,
  round text,
  match_number integer,
  mesa_order integer, -- turno global dentro de la mesa (null en los BYE)
  created_at timestamp with time zone default now(),
  constraint matches_pkey primary key (id),
  constraint matches_tournament_id_fkey foreign key (tournament_id) references public.tournaments(id),
  constraint matches_home_player_id_fkey foreign key (home_player_id) references public.players(id),
  constraint matches_away_player_id_fkey foreign key (away_player_id) references public.players(id)
);

create table public.results (
  id uuid not null default gen_random_uuid(),
  match_id uuid not null unique,
  tournament_id uuid not null,
  home_player_id uuid not null,
  away_player_id uuid not null,
  home_score integer not null,
  away_score integer not null,
  notes text,
  registered_by uuid,
  registered_at timestamp with time zone default now(),
  constraint results_pkey primary key (id),
  constraint results_match_id_fkey foreign key (match_id) references public.matches(id),
  constraint results_tournament_id_fkey foreign key (tournament_id) references public.tournaments(id),
  constraint results_home_player_id_fkey foreign key (home_player_id) references public.players(id),
  constraint results_away_player_id_fkey foreign key (away_player_id) references public.players(id),
  constraint results_registered_by_fkey foreign key (registered_by) references public.profiles(id)
);

create table public.standings (
  id uuid not null default gen_random_uuid(),
  tournament_id uuid not null,
  player_id uuid not null,
  player_name text not null default ''::text,
  played integer not null default 0,
  won integer not null default 0,
  drawn integer not null default 0,
  lost integer not null default 0,
  goals_for integer not null default 0,
  goals_against integer not null default 0,
  points integer not null default 0,
  manual_rank integer,
  updated_at timestamp with time zone default now(),
  constraint standings_pkey primary key (id),
  constraint standings_player_id_fkey foreign key (player_id) references public.players(id),
  constraint standings_tournament_id_fkey foreign key (tournament_id) references public.tournaments(id)
);

-- ------------------------------------------------------------------
-- Funciones auxiliares
-- ------------------------------------------------------------------
-- SECURITY DEFINER: corre con los privilegios de quien la creó (no del
-- usuario que la invoca), necesario para poder leer profiles.role desde
-- dentro de una policy sin caer en referencia circular (una policy de
-- profiles que a su vez consulta profiles con las policies activas).
create or replace function public.get_my_role()
 returns text
 language sql
 stable security definer
as $function$
  select role from public.profiles where id = auth.uid();
$function$;

-- ------------------------------------------------------------------
-- Row Level Security
-- ------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.mesas enable row level security;
alter table public.tournaments enable row level security;
alter table public.players enable row level security;
alter table public.enrollments enable row level security;
alter table public.matches enable row level security;
alter table public.results enable row level security;
alter table public.standings enable row level security;

-- profiles: cada usuario ve/edita su propio perfil; admin ve/edita/borra cualquiera.
create policy profiles_select on public.profiles
  as permissive for select to public
  using ((auth.uid() = id) or (get_my_role() = 'admin'::text));

create policy profiles_insert on public.profiles
  as permissive for insert to public
  with check (auth.uid() = id);

create policy profiles_update on public.profiles
  as permissive for update to public
  using ((auth.uid() = id) or (get_my_role() = 'admin'::text));

create policy profiles_delete on public.profiles
  as permissive for delete to public
  using (get_my_role() = 'admin'::text);

-- mesas: mismo criterio que tournaments.
create policy "Lectura pública" on public.mesas
  as permissive for select to anon
  using (true);

create policy mesas_select on public.mesas
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy mesas_write on public.mesas
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- tournaments: lectura pública (anon, para torneo_web) + lectura para
-- cualquier autenticado; solo admin crea/edita/borra.
create policy "Lectura pública" on public.tournaments
  as permissive for select to anon
  using (true);

create policy tournaments_select on public.tournaments
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy tournaments_insert on public.tournaments
  as permissive for insert to public
  with check (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

create policy tournaments_update on public.tournaments
  as permissive for update to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

create policy tournaments_delete on public.tournaments
  as permissive for delete to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- players: sin lectura anónima (torneo_web no consulta esta tabla
-- directamente -- los nombres ya vienen denormalizados en matches/standings).
create policy players_select on public.players
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy players_write on public.players
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- enrollments: mismo criterio que players, sin lectura anónima.
create policy enrollments_select on public.enrollments
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy enrollments_write on public.enrollments
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- matches: lectura pública (anon, para torneo_web) + autenticado; solo admin escribe.
create policy "Lectura pública" on public.matches
  as permissive for select to anon
  using (true);

create policy matches_select on public.matches
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy matches_write on public.matches
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- results: mismo criterio que matches.
create policy "Lectura pública" on public.results
  as permissive for select to anon
  using (true);

create policy results_select on public.results
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy results_write on public.results
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- standings: mismo criterio que matches.
create policy "Lectura pública" on public.standings
  as permissive for select to anon
  using (true);

create policy standings_select on public.standings
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

create policy standings_write on public.standings
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));
