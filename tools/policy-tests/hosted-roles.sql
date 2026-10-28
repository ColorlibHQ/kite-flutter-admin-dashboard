-- Run against an isolated staging project as postgres. Every fixture is rolled
-- back; this tests database permissions, not hosted email delivery or Auth.
begin;
select set_config('request.jwt.claim.sub', gen_random_uuid()::text, true);
select set_config('kite.test_product', gen_random_uuid()::text, true);
insert into auth.users(id, aud, role)
values (current_setting('request.jwt.claim.sub')::uuid, 'authenticated', 'authenticated');
insert into public.products(id,name,sku,price,stock,status)
values (current_setting('kite.test_product'),'Role test',current_setting('kite.test_product'),1,1,'In stock');

set local role authenticated;
do $$ begin
  assert not exists(select 1 from public.products where id=current_setting('kite.test_product')), 'Unassigned user must not read';
  begin
    insert into public.kite_user_roles values (auth.uid(),'admin');
    raise exception 'Self-promotion was allowed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
insert into public.kite_user_roles values (current_setting('request.jwt.claim.sub')::uuid,'viewer');

set local role authenticated;
do $$ declare affected integer; begin
  assert exists(select 1 from public.products where id=current_setting('kite.test_product')), 'Viewer must read';
  begin
    insert into public.products(name,sku,price,stock,status) values ('Denied',gen_random_uuid()::text,1,1,'In stock');
    raise exception 'Viewer create was allowed';
  exception when insufficient_privilege then null; end;
  update public.products set price=2 where id=current_setting('kite.test_product');
  get diagnostics affected = row_count;
  assert affected=0, 'Viewer update must be denied';
  delete from public.products where id=current_setting('kite.test_product');
  get diagnostics affected = row_count;
  assert affected=0, 'Viewer delete must be denied';
end $$;
reset role;
update public.kite_user_roles set role='editor' where user_id=current_setting('request.jwt.claim.sub')::uuid;

set local role authenticated;
do $$ declare affected integer; begin
  insert into public.products(name,sku,price,stock,status) values ('Editor allowed',gen_random_uuid()::text,1,1,'In stock');
  update public.products set price=2 where id=current_setting('kite.test_product');
  get diagnostics affected = row_count;
  assert affected=1, 'Editor must update';
  delete from public.products where id=current_setting('kite.test_product');
  get diagnostics affected = row_count;
  assert affected=0, 'Editor delete must be denied';
end $$;
reset role;
update public.kite_user_roles set role='admin' where user_id=current_setting('request.jwt.claim.sub')::uuid;

set local role authenticated;
do $$ declare affected integer; begin
  delete from public.products where id=current_setting('kite.test_product');
  get diagnostics affected = row_count;
  assert affected=1, 'Administrator must delete';
end $$;
reset role;
delete from public.kite_user_roles where user_id=current_setting('request.jwt.claim.sub')::uuid;

set local role authenticated;
do $$ begin
  assert not exists(select 1 from public.products), 'Revoked user must not read';
end $$;
reset role;
set local role anon;
do $$ begin
  begin
    perform 1 from public.products limit 1;
    raise exception 'Anonymous read was allowed';
  exception when insufficient_privilege then null; end;
end $$;
reset role;
rollback;
select 'PASS: unassigned, self-promotion, viewer, editor, administrator, revocation, anonymous; fixtures rolled back' as result;
