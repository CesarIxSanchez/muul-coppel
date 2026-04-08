-- Business dashboard metrics support
-- 1) Persist user favorites for negocios
-- 2) Add RPC to increment total negocio views
-- 3) Add RPC to increment daily route clicks

create table if not exists public.negocio_favoritos (
  usuario_id uuid not null references auth.users(id) on delete cascade,
  negocio_id uuid not null references public.negocios(id) on delete cascade,
  creado_en timestamptz not null default now(),
  primary key (usuario_id, negocio_id)
);

create index if not exists negocio_favoritos_negocio_idx
  on public.negocio_favoritos (negocio_id);

create index if not exists negocio_favoritos_usuario_idx
  on public.negocio_favoritos (usuario_id);

alter table public.negocio_favoritos enable row level security;

drop policy if exists negocio_favoritos_select_own on public.negocio_favoritos;
create policy negocio_favoritos_select_own on public.negocio_favoritos
  for select
  to authenticated
  using (auth.uid() = usuario_id);

drop policy if exists negocio_favoritos_insert_own on public.negocio_favoritos;
create policy negocio_favoritos_insert_own on public.negocio_favoritos
  for insert
  to authenticated
  with check (auth.uid() = usuario_id);

drop policy if exists negocio_favoritos_delete_own on public.negocio_favoritos;
create policy negocio_favoritos_delete_own on public.negocio_favoritos
  for delete
  to authenticated
  using (auth.uid() = usuario_id);

drop function if exists public.increment_vistas_negocio(uuid);
create or replace function public.increment_vistas_negocio(p_negocio_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.negocios
  set vistas = coalesce(vistas, 0) + 1
  where id = p_negocio_id;
end;
$$;

grant execute on function public.increment_vistas_negocio(uuid) to anon, authenticated, service_role;

create or replace function public.increment_vista_negocio(p_negocio_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := now()::date;
begin
  update public.negocios
  set vistas = coalesce(vistas, 0) + 1
  where id = p_negocio_id;

  insert into public.negocio_stats (negocio_id, fecha, vistas, clicks_ruta, visitas_gps)
  values (p_negocio_id, v_today, 1, 0, 0)
  on conflict (negocio_id, fecha)
  do update
    set vistas = public.negocio_stats.vistas + 1;
end;
$$;

grant execute on function public.increment_vista_negocio(uuid) to anon, authenticated, service_role;

create or replace function public.increment_clicks_ruta_negocio(p_negocio_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_today date := now()::date;
begin
  insert into public.negocio_stats (negocio_id, fecha, vistas, clicks_ruta, visitas_gps)
  values (p_negocio_id, v_today, 0, 1, 0)
  on conflict (negocio_id, fecha)
  do update
    set clicks_ruta = public.negocio_stats.clicks_ruta + 1;
end;
$$;

grant execute on function public.increment_clicks_ruta_negocio(uuid) to authenticated, service_role;
