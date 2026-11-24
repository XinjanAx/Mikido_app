-- Gremio/acrónimo visibles para torneo_web (que entra sin iniciar sesión),
-- SIN exponer correo ni teléfono y sin vistas (Supabase marcaba la vista
-- player_guilds como "UNRESTRICTED" / "Security Definer View").
--
-- Se usa permiso POR COLUMNA: el visitante sin sesión (anon) solo puede
-- leer id, guild y guild_acronym de players. players mantiene su RLS; se
-- agrega una regla que deja a anon ver las filas (las columnas privadas
-- siguen bloqueadas por el permiso de columna).

-- ===== PASO 1 (correr primero; la web sigue funcionando igual) =====

-- anon pierde el permiso de lectura de TODA la tabla...
revoke select on public.players from anon;
-- ...y lo recupera solo para estas tres columnas.
grant select (id, guild, guild_acronym) on public.players to anon;

-- Regla RLS: anon puede ver las filas (solo esas columnas, por lo anterior).
drop policy if exists players_select_anon_guild on public.players;
create policy players_select_anon_guild on public.players
  as permissive for select to anon
  using (true);

-- ===== PASO 2 (después de publicar la web nueva) =====
-- La vista ya no se usa: se borra y desaparece la advertencia.
-- drop view if exists public.player_guilds;
