import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { PGlite } from '@electric-sql/pglite';

// Execute the real migration against PostgreSQL/Wasm. The auth fixture supplies
// only the users and JWT subject normally provided by Supabase.
const db = new PGlite();
await db.exec(`
  create role anon;
  create role authenticated;
  create schema auth;
  create table auth.users (id uuid primary key);
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
  $$;
  grant usage on schema auth to authenticated;
  grant execute on function auth.uid() to authenticated;
  insert into auth.users values
    ('00000000-0000-0000-0000-000000000001'),
    ('00000000-0000-0000-0000-000000000002'),
    ('00000000-0000-0000-0000-000000000003'),
    ('00000000-0000-0000-0000-000000000004');
`);
await db.exec(await fs.readFile(new URL('../../supabase/migrations/202610270001_kite_auth_roles.sql', import.meta.url), 'utf8'));
await db.exec(`
  insert into public.kite_user_roles values
    ('00000000-0000-0000-0000-000000000001', 'viewer'),
    ('00000000-0000-0000-0000-000000000002', 'editor'),
    ('00000000-0000-0000-0000-000000000003', 'admin');
  insert into public.products (id,name,sku,price,stock,status) values ('one','Test','TEST',10,5,'In stock');
`);
async function asUser(suffix) {
  await db.exec('reset role');
  await db.query("select set_config('request.jwt.claim.sub', $1, false)", [`00000000-0000-0000-0000-00000000000${suffix}`]);
  await db.exec('set role authenticated');
}
async function count() {
  return (await db.query('select count(*)::int as n from public.products')).rows[0].n;
}
async function denied(sql) {
  await assert.rejects(() => db.exec(sql), (error) => error.code === '42501');
}
try {
  await asUser(1);
  assert.equal(await count(), 1, 'viewer can read');
  await denied("insert into public.products(name,sku,price,stock,status) values('Bad','BAD',1,1,'In stock')");
  assert.equal((await db.query("update public.products set name='Bad' returning id")).rows.length, 0);
  assert.equal((await db.query('delete from public.products returning id')).rows.length, 0);
  await denied("update public.kite_user_roles set role='admin'");
  await denied("insert into public.kite_user_roles values ('00000000-0000-0000-0000-000000000001','admin')");
  assert.deepEqual((await db.query('select role from public.kite_user_roles')).rows, [{ role: 'viewer' }], 'only own role is visible');
  await db.query("select set_config('request.jwt.claims', $1, false)", ['{"role":"admin","user_metadata":{"role":"admin"}}']);
  await denied("insert into public.products(name,sku,price,stock,status) values('Spoof','SPOOF',1,1,'In stock')");

  await asUser(2);
  await db.exec("insert into public.products(id,name,sku,price,stock,status) values('two','Editor','EDIT',1,1,'In stock')");
  assert.equal((await db.query("update public.products set price=20 where id='one' returning id")).rows.length, 1);
  assert.equal((await db.query("delete from public.products where id='one' returning id")).rows.length, 0, 'editor cannot delete');

  await asUser(3);
  assert.equal((await db.query("delete from public.products where id='two' returning id")).rows.length, 1, 'admin can delete');

  await asUser(4);
  assert.equal(await count(), 0, 'unassigned user sees no records');
  await denied("insert into public.products(name,sku,price,stock,status) values('Bad','NONE',1,1,'In stock')");

  await db.exec("reset role; delete from public.kite_user_roles where user_id='00000000-0000-0000-0000-000000000001'");
  await asUser(1);
  assert.equal(await count(), 0, 'revocation is immediate even with the same JWT subject');
  await db.exec('reset role; set role anon');
  await denied('select * from public.products');
  console.log('PASS: migration, viewer/editor/admin access, self-escalation, metadata spoofing, unassigned users, anonymous access, and immediate revocation.');
} finally {
  await db.close();
}
