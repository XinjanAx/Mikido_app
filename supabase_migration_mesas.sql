-- ============================================================================
-- Migración: MESAS (ejecutar UNA vez en Supabase > SQL Editor)
--
-- - Nueva tabla public.mesas (lugar físico: cancha, tatami, ring...).
-- - tournaments.mesa_id: cada categoría pertenece a una mesa.
-- - matches.mesa_order: turno global del encuentro dentro de su mesa.
-- - Los datos existentes quedan todos en una "Mesa 1", con su turno
--   numerado en el orden en que se crearon las categorías y sus encuentros.
--
-- torneo_web no necesita cambios: ignora las columnas nuevas.
-- Debe ejecutarse ANTES de usar la versión de la app con mesas (la app
-- sube mesa_id / mesa_order al sincronizar y fallaría si no existen).
-- ============================================================================

begin;

-- 1. Tabla mesas -------------------------------------------------------------
create table if not exists public.mesas (
  id uuid not null default gen_random_uuid(),
  name text not null,
  description text,
  created_by uuid,
  created_at timestamp with time zone default now(),
  constraint mesas_pkey primary key (id),
  constraint mesas_created_by_fkey foreign key (created_by) references public.profiles(id)
);

-- 2. Columnas nuevas ---------------------------------------------------------
alter table public.tournaments
  add column if not exists mesa_id uuid
  constraint tournaments_mesa_id_fkey references public.mesas(id);

alter table public.matches
  add column if not exists mesa_order integer;

-- 3. RLS de mesas (mismo criterio que tournaments) ---------------------------
alter table public.mesas enable row level security;

drop policy if exists "Lectura pública" on public.mesas;
create policy "Lectura pública" on public.mesas
  as permissive for select to anon
  using (true);

drop policy if exists mesas_select on public.mesas;
create policy mesas_select on public.mesas
  as permissive for select to public
  using (auth.role() = 'authenticated'::text);

drop policy if exists mesas_write on public.mesas;
create policy mesas_write on public.mesas
  as permissive for all to public
  using (exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role = 'admin'::text
  ));

-- 4. Datos existentes → "Mesa 1" --------------------------------------------
insert into public.mesas (name, description, created_by)
select 'Mesa 1',
       'Categorías creadas antes de las mesas',
       (select id from public.profiles where role = 'admin' order by created_at limit 1)
where exists (select 1 from public.tournaments where mesa_id is null);

update public.tournaments
set mesa_id = (select id from public.mesas
               where name = 'Mesa 1'
               order by created_at desc limit 1)
where mesa_id is null;

-- 5. Turno de los encuentros existentes (los BYE no llevan turno) ------------
with numbered as (
  select m.id,
         row_number() over (
           partition by t.mesa_id
           order by t.created_at, m.match_number, m.created_at
         ) as turn
  from public.matches m
  join public.tournaments t on t.id = m.tournament_id
  where m.mesa_order is null
    and m.home_player_id <> m.away_player_id
    and upper(m.away_player_name) <> 'BYE'
)
update public.matches m
set mesa_order = numbered.turn
from numbered
where m.id = numbered.id;

commit;
