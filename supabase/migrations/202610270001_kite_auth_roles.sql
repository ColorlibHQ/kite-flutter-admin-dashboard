-- Single-workspace starter schema. Roles are assigned only by a trusted server
-- or database administrator. No client may grant itself a role.
begin;
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create table public.kite_user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('viewer', 'editor', 'admin'))
);
alter table public.kite_user_roles enable row level security;
revoke all on public.kite_user_roles from anon, authenticated;
grant select on public.kite_user_roles to authenticated;
create policy read_own_role on public.kite_user_roles
  for select to authenticated using (user_id = (select auth.uid()));

-- Reads current table state, so revocation takes effect immediately on the
-- server even while an older access token remains valid.
create function private.kite_has_role(allowed text[]) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.kite_user_roles
    where user_id = (select auth.uid()) and role = any(allowed)
  );
$$;
revoke all on function private.kite_has_role(text[]) from public;
grant execute on function private.kite_has_role(text[]) to authenticated;

create table public.orders (
  id text primary key default gen_random_uuid()::text,
  reference text not null default ('ORD-' || substr(gen_random_uuid()::text, 1, 8)),
  customer text not null,
  status text not null check (status in ('Paid','Pending','Refunded','Shipped','Cancelled')),
  items integer not null check (items >= 0),
  total numeric(14,2) not null check (total >= 0),
  date date not null default current_date,
  notes text not null default ''
);
create table public.customers (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  email text not null,
  orders integer not null default 0 check (orders >= 0),
  spend numeric(14,2) not null default 0 check (spend >= 0),
  status text not null check (status in ('Active','Churned')),
  notes text not null default ''
);
create table public.products (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  sku text not null unique,
  price numeric(14,2) not null check (price >= 0),
  stock integer not null check (stock >= 0),
  status text not null check (status in ('In stock','Low','Out of stock')),
  notes text not null default ''
);

do $$ declare resource text; begin
  foreach resource in array array['orders','customers','products'] loop
    execute format('alter table public.%I enable row level security', resource);
    execute format('revoke all on public.%I from anon, authenticated', resource);
    execute format('grant select, insert, update, delete on public.%I to authenticated', resource);
    execute format('create policy team_read on public.%I for select to authenticated using ((select private.kite_has_role(array[''viewer'',''editor'',''admin''])))', resource);
    execute format('create policy team_create on public.%I for insert to authenticated with check ((select private.kite_has_role(array[''editor'',''admin''])))', resource);
    execute format('create policy team_update on public.%I for update to authenticated using ((select private.kite_has_role(array[''editor'',''admin'']))) with check ((select private.kite_has_role(array[''editor'',''admin''])))', resource);
    execute format('create policy team_delete on public.%I for delete to authenticated using ((select private.kite_has_role(array[''admin''])))', resource);
  end loop;
end $$;
commit;
