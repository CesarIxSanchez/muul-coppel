-- Muul Auth + Profiles schema for Supabase
-- Run this script in Supabase SQL editor.

begin;

create extension if not exists pgcrypto;

-- 1) Types
do $$
begin
  if not exists (
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where t.typname = 'gender_enum' and n.nspname = 'public'
  ) then
    create type public.gender_enum as enum ('male', 'female', 'not_specified');
  end if;
end
$$;

-- 2) Users profile table linked 1:1 with auth.users
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  gender public.gender_enum not null default 'not_specified',
  language text not null default 'es-MX',
  last_username_change_date timestamptz,
  avatar_url text default 'https://i.pravatar.cc/300?img=12',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_username_format check (username ~ '^@[a-zA-Z0-9_]{3,30}$')
);

create unique index if not exists users_username_unique_idx on public.users (lower(username));

-- 3) Business profile table linked 1:1 with auth.users
create table if not exists public.businesses (
  id uuid primary key references auth.users(id) on delete cascade,
  business_name text not null,
  address text not null,
  language text not null default 'es-MX',
  avatar_url text default 'https://i.pravatar.cc/300?img=22',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint business_name_len check (length(trim(business_name)) >= 2),
  constraint business_address_len check (length(trim(address)) >= 6)
);

-- 4) Utility trigger functions
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.ensure_username()
returns trigger
language plpgsql
as $$
declare
  base_username text;
  candidate text;
  suffix text;
begin
  base_username := regexp_replace(coalesce(new.username, ''), '[^a-zA-Z0-9_]', '', 'g');

  if length(base_username) < 3 then
    base_username := 'usuario' || floor(random() * 90000 + 10000)::text;
  end if;

  candidate := '@' || lower(base_username);

  while exists (
    select 1 from public.users u
    where lower(u.username) = lower(candidate)
      and (tg_op = 'INSERT' or u.id <> new.id)
  ) loop
    suffix := floor(random() * 90000 + 10000)::text;
    candidate := '@' || lower(base_username) || suffix;
  end loop;

  new.username := candidate;
  return new;
end;
$$;

create or replace function public.enforce_username_change_window()
returns trigger
language plpgsql
as $$
begin
  if new.username is distinct from old.username then
    if old.last_username_change_date is not null
      and old.last_username_change_date > now() - interval '30 days' then
      raise exception 'USERNAME_CHANGE_LOCKED_FOR_30_DAYS';
    end if;

    new.last_username_change_date := now();
  end if;

  return new;
end;
$$;

create or replace function public.prevent_business_identity_update()
returns trigger
language plpgsql
as $$
begin
  if new.business_name is distinct from old.business_name then
    raise exception 'BUSINESS_NAME_IMMUTABLE';
  end if;

  if new.address is distinct from old.address then
    raise exception 'BUSINESS_ADDRESS_IMMUTABLE';
  end if;

  return new;
end;
$$;

-- 5) Triggers

drop trigger if exists trg_users_set_updated_at on public.users;
create trigger trg_users_set_updated_at
before update on public.users
for each row execute function public.set_updated_at();

drop trigger if exists trg_businesses_set_updated_at on public.businesses;
create trigger trg_businesses_set_updated_at
before update on public.businesses
for each row execute function public.set_updated_at();

drop trigger if exists trg_users_ensure_username_insert on public.users;
create trigger trg_users_ensure_username_insert
before insert on public.users
for each row execute function public.ensure_username();

drop trigger if exists trg_users_ensure_username_update on public.users;
create trigger trg_users_ensure_username_update
before update of username on public.users
for each row execute function public.ensure_username();

drop trigger if exists trg_users_username_window on public.users;
create trigger trg_users_username_window
before update of username on public.users
for each row execute function public.enforce_username_change_window();

drop trigger if exists trg_businesses_immutable on public.businesses;
create trigger trg_businesses_immutable
before update of business_name, address on public.businesses
for each row execute function public.prevent_business_identity_update();

-- 6) RLS strict policies
alter table public.users enable row level security;
alter table public.businesses enable row level security;

-- Users table: owner only

drop policy if exists users_select_own on public.users;
create policy users_select_own on public.users
for select using (auth.uid() = id);

drop policy if exists users_insert_own on public.users;
create policy users_insert_own on public.users
for insert with check (auth.uid() = id);

drop policy if exists users_update_own on public.users;
create policy users_update_own on public.users
for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists users_delete_own on public.users;
create policy users_delete_own on public.users
for delete using (auth.uid() = id);

-- Businesses table: owner only

drop policy if exists businesses_select_own on public.businesses;
create policy businesses_select_own on public.businesses
for select using (auth.uid() = id);

drop policy if exists businesses_insert_own on public.businesses;
create policy businesses_insert_own on public.businesses
for insert with check (auth.uid() = id);

drop policy if exists businesses_update_own on public.businesses;
create policy businesses_update_own on public.businesses
for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists businesses_delete_own on public.businesses;
create policy businesses_delete_own on public.businesses
for delete using (auth.uid() = id);

commit;

-- Notes:
-- 1) Supabase GoTrue manages auth.sessions internally. No custom sessions table is required.
-- 2) Session persistence on mobile is handled by supabase_flutter + secure refresh token fallback in app code.
