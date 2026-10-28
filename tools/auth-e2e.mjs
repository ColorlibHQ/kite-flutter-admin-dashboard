#!/usr/bin/env node
// Real local Supabase integration tests. No hosted endpoint is accepted.
import assert from 'node:assert/strict';
import { createHash, randomBytes } from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import {localStatus,root} from './lib/local-supabase.mjs';

const status = await localStatus();
const api = status.API_URL;
const publicKey = status.ANON_KEY || status.PUBLISHABLE_KEY;
const adminKey = status.SERVICE_ROLE_KEY || status.SECRET_KEY;
const mail = status.INBUCKET_URL || status.MAILPIT_URL || 'http://127.0.0.1:57424';
for (const value of [api, mail]) assert(['127.0.0.1','localhost','[::1]'].includes(new URL(value).hostname), 'Only local test services are permitted.');
assert(publicKey && adminKey, 'Local Supabase API keys are required.');
assert((await fs.readFile(path.join(root,'supabase/config.toml'),'utf8')).includes('project_id = "kite-e2e"'), 'This runner is limited to the isolated kite-e2e project.');

const checks = [];
const users = [];
const products = [];
const suffix = randomBytes(6).toString('hex');
const email = `kite-api-${suffix}@example.test`;
const password = `Kite-Initial!${randomBytes(16).toString('hex')}`;
const newPassword = `Kite-Recovered!${randomBytes(16).toString('hex')}`;
const callback = 'http://localhost:8722/auth/callback';
const reportPath = path.join(root,'build/e2e/auth-report.json');
const report = {startedAt: new Date().toISOString(), target: api, emailCapture: mail, checks};

async function request(route, {method='GET', token, admin=false, body, prefer}={}) {
  const response = await fetch(`${api}${route}`, {
    method,
    headers: {apikey: admin ? adminKey : publicKey, ...(token || admin ? {Authorization:`Bearer ${token || adminKey}`} : {}), ...(body ? {'Content-Type':'application/json'} : {}), ...(prefer ? {Prefer:prefer} : {})},
    body: body ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(20000),
  });
  const text = await response.text();
  let data;
  try { data = text ? JSON.parse(text) : null; } catch { data = null; }
  return {status: response.status, data};
}
function ok(result, allowed, context) {
  assert(allowed.includes(result.status), `${context}: expected ${allowed.join('/')}, got HTTP ${result.status} (${result.data?.code || result.data?.error_code || 'no error code'})`);
  return result.data;
}
function passed(name) {checks.push({name, passed:true}); console.log(`PASS ${name}`);}
function pkce() {
  const verifier = randomBytes(32).toString('base64url');
  return {verifier, challenge:createHash('sha256').update(verifier).digest('base64url')};
}
async function messageFor(address, subject, after) {
  const deadline = Date.now()+30000;
  while (Date.now()<deadline) {
    const listing = await (await fetch(`${mail}/api/v1/messages`, {signal:AbortSignal.timeout(5000)})).json();
    const item = (listing.messages || []).find(m => m.Subject.includes(subject) && m.To?.some(to=>to.Address===address) && (!after || new Date(m.Created).getTime()>=after-1000));
    if (item) return await (await fetch(`${mail}/api/v1/message/${item.ID}`)).json();
    await new Promise(resolve=>setTimeout(resolve,250));
  }
  throw new Error(`No captured ${subject} email arrived within 30 seconds.`);
}
function emailLink(message) {
  const match = message.HTML.match(/href="([^"]+)"/);
  assert(match, 'Captured email contains a verification link.');
  const link = match[1].replaceAll('&amp;','&');
  const url = new URL(link);
  assert(['127.0.0.1','localhost'].includes(url.hostname), 'Verification links must remain local.');
  return link;
}
async function followAndExchange(message, proof) {
  const verified = await fetch(emailLink(message), {redirect:'manual',signal:AbortSignal.timeout(15000)});
  assert([302,303].includes(verified.status), `Email verification returned HTTP ${verified.status}.`);
  const location = new URL(verified.headers.get('location'));
  assert.equal(location.origin, new URL(callback).origin);
  assert.equal(location.pathname, '/auth/callback');
  assert(!location.searchParams.has('error'), 'Verification callback must not contain an error.');
  const code = location.searchParams.get('code');
  assert(code, 'PKCE callback contains a code.');
  const result = await request('/auth/v1/token?grant_type=pkce', {method:'POST',body:{auth_code:code,code_verifier:proof.verifier}});
  return {session:ok(result,[200],'PKCE exchange'), location};
}
async function assign(userId, role) {
  assert(/^[a-f\d-]{36}$/i.test(userId));
  if (role) ok(await request('/rest/v1/kite_user_roles', {method:'POST',admin:true,prefer:'resolution=merge-duplicates',body:{user_id:userId,role}}),[200,201],'assign server role');
  else ok(await request(`/rest/v1/kite_user_roles?user_id=eq.${userId}`, {method:'DELETE',admin:true}),[204],'revoke server role');
}
async function read(token) {return ok(await request(`/rest/v1/products?id=eq.${products[0]}&select=id,name`,{token}),[200],'read resource');}
async function write(token, name='client') {return request('/rest/v1/products',{method:'POST',token,prefer:'return=representation',body:{name,sku:`${suffix}-${randomBytes(3).toString('hex')}`,price:10,stock:1,status:'In stock'}});}

try {
  const proof = pkce();
  const registered = ok(await request(`/auth/v1/signup?redirect_to=${encodeURIComponent(callback)}`, {method:'POST',body:{email,password,data:{full_name:'Kite API E2E',role:'admin'},code_challenge:proof.challenge,code_challenge_method:'s256'}}),[200],'sign-up');
  const userId = registered.user?.id || registered.id;
  assert(userId, 'Sign-up returns a user identity.'); users.push(userId);
  assert(!registered.access_token && !registered.session, 'Email confirmation is required before granting a session.');
  ok(await request('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password}}),[400],'unconfirmed sign-in is blocked');
  passed('Sign-up requires email confirmation');

  const confirmation = await messageFor(email,'Confirm your Kite account');
  const confirmed = await followAndExchange(confirmation,proof);
  assert.equal(confirmed.session.user.id,userId);
  passed('Captured confirmation email completes a real PKCE exchange');
  ok(await request('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password:'wrong-password'}}),[400],'wrong password');
  let session = ok(await request('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password}}),[200],'password sign-in');
  assert.equal(session.user.id,userId);
  passed('Password sign-in accepts the correct password and rejects the wrong one');

  const fixture = ok(await request('/rest/v1/products',{method:'POST',admin:true,prefer:'return=representation',body:{name:'Kite E2E fixture',sku:`${suffix}-fixture`,price:10,stock:1,status:'In stock'}}),[201],'create fixture');
  products.push(fixture[0].id);
  assert.deepEqual(await read(session.access_token),[]);
  ok(await write(session.access_token),[401,403],'unassigned write');
  ok(await request('/rest/v1/kite_user_roles',{method:'POST',token:session.access_token,body:{user_id:userId,role:'admin'}}),[401,403],'self-assigned role');
  passed('Unassigned users and spoofed user metadata cannot access data or self-promote');
  ok(await request('/rest/v1/products?select=id'),[401,403],'anonymous resource access');
  passed('Anonymous callers cannot read resource tables');

  await assign(userId,'viewer');
  assert.equal((await read(session.access_token)).length,1);
  ok(await write(session.access_token),[401,403],'viewer create');
  assert.deepEqual(ok(await request(`/rest/v1/products?id=eq.${products[0]}`,{method:'PATCH',token:session.access_token,prefer:'return=representation',body:{name:'Forbidden'}}),[200],'viewer update'),[]);
  assert.deepEqual(ok(await request(`/rest/v1/products?id=eq.${products[0]}`,{method:'DELETE',token:session.access_token,prefer:'return=representation'}),[200],'viewer delete'),[]);
  passed('Viewer can read but cannot create, update or delete');

  await assign(userId,'editor');
  const created = ok(await write(session.access_token,'Editor-created'),[201],'editor create');products.push(created[0].id);
  const updated = ok(await request(`/rest/v1/products?id=eq.${products[0]}`,{method:'PATCH',token:session.access_token,prefer:'return=representation',body:{name:'Editor-updated'}}),[200],'editor update');
  assert.equal(updated[0].name,'Editor-updated');
  assert.deepEqual(ok(await request(`/rest/v1/products?id=eq.${products[0]}`,{method:'DELETE',token:session.access_token,prefer:'return=representation'}),[200],'editor delete'),[]);
  passed('Editor can create and update but cannot delete');

  await assign(userId,'admin');
  assert.equal(ok(await request(`/rest/v1/products?id=eq.${products[1]}`,{method:'DELETE',token:session.access_token,prefer:'return=representation'}),[200],'admin delete').length,1);
  passed('Administrator can delete');
  await assign(userId,null);
  assert.deepEqual(await read(session.access_token),[]);
  ok(await write(session.access_token),[401,403],'revoked write');
  passed('Server role revocation takes effect immediately with the same access token');

  const resetProof = pkce(); const requestedAt = Date.now();
  const recoveryCallback = `${callback}?flow=recovery`;
  ok(await request(`/auth/v1/recover?redirect_to=${encodeURIComponent(recoveryCallback)}`,{method:'POST',body:{email,code_challenge:resetProof.challenge,code_challenge_method:'s256'}}),[200],'request recovery');
  const recovery = await messageFor(email,'Reset your Kite password',requestedAt);
  const recovered = await followAndExchange(recovery,resetProof);
  assert.equal(recovered.location.searchParams.get('flow'),'recovery');
  ok(await request('/auth/v1/user',{method:'PUT',token:recovered.session.access_token,body:{password:newPassword}}),[200],'update password');
  ok(await request('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password}}),[400],'old password rejected');
  session = ok(await request('/auth/v1/token?grant_type=password',{method:'POST',body:{email,password:newPassword}}),[200],'new password accepted');
  passed('Captured recovery email preserves intent, changes the password and invalidates the old password');
  ok(await request('/auth/v1/logout?scope=local',{method:'POST',token:session.access_token}),[200,204],'logout');
  ok(await request('/auth/v1/token?grant_type=refresh_token',{method:'POST',body:{refresh_token:session.refresh_token}}),[400,401],'revoked refresh token');
  passed('Sign-out revokes the current refresh token');
  report.passed = true;
} catch(error) {
  report.passed = false;
  report.error = error.message;
  process.exitCode=1;
  console.error(`FAIL ${error.message}`);
} finally {
  report.cleanupPassed = true;
  for (const [kind, ids] of [['product', products], ['user', users]]) {
    for (const id of ids) {
      try {
        const result = await request(kind === 'product' ? `/rest/v1/products?id=eq.${id}` : `/auth/v1/admin/users/${id}`, {method:'DELETE',admin:true});
        assert([200,204].includes(result.status));
      } catch {
        report.cleanupPassed = false; report.passed = false; process.exitCode = 1;
      }
    }
  }
  if (!report.cleanupPassed) console.error('FAIL Test fixture cleanup did not complete.');
  report.finishedAt = new Date().toISOString();
  await fs.mkdir(path.dirname(reportPath),{recursive:true});
  await fs.writeFile(reportPath,JSON.stringify(report,null,2)+'\n');
  console.log(`Report: ${path.relative(root,reportPath)}`);
}
