-- v8 (2.0.x): gremio o clan del participante y su acrónimo.
-- Correr en el SQL Editor de Supabase ANTES de usar la app nueva: si las
-- columnas no existen, la sincronización de participantes falla.

alter table public.players add column if not exists guild text;
alter table public.players add column if not exists guild_acronym text;

-- Acrónimo: obligatorio si hay gremio, 1 a 4 letras, siempre en mayúsculas.
alter table public.players drop constraint if exists players_guild_acronym_check;
alter table public.players add constraint players_guild_acronym_check check (
  (guild is null and guild_acronym is null)
  or (guild is not null and guild_acronym is not null
      and char_length(guild_acronym) between 1 and 4
      and guild_acronym = upper(guild_acronym))
);
