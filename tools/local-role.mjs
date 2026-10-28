#!/usr/bin/env node
// Trusted operator helper for LOCAL development only. Never shipped in Flutter.
import {localStatus} from './lib/local-supabase.mjs';
const [email,role]=process.argv.slice(2);
if(!email || !['viewer','editor','admin','none'].includes(role)) throw new Error('Usage: node tools/local-role.mjs email viewer|editor|admin|none');
const s=await localStatus();const key=s.SERVICE_ROLE_KEY||s.SECRET_KEY;
if(!key)throw new Error('Local service credentials are unavailable.');
async function request(route,method='GET',body) {
 const response=await fetch(s.API_URL+route,{method,headers:{apikey:key,Authorization:`Bearer ${key}`,'Content-Type':'application/json',Prefer:'resolution=merge-duplicates'},body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(10000)});
 if(!response.ok)throw new Error(`Local role operation failed: HTTP ${response.status}`);
 const text=await response.text();return text?JSON.parse(text):null;
}
const result=await request('/auth/v1/admin/users?page=1&per_page=1000');
const user=result.users.find(u=>u.email?.toLowerCase()===email.toLowerCase());
if(!user)throw new Error('Local account not found. Sign up and verify its email first.');
if(role==='none')await request(`/rest/v1/kite_user_roles?user_id=eq.${user.id}`,'DELETE');
else await request('/rest/v1/kite_user_roles','POST',{user_id:user.id,role});
console.log(`Local role set to ${role}. Sign in again to refresh the UI.`);
