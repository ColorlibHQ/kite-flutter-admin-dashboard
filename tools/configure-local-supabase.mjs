#!/usr/bin/env node
import fs from 'node:fs/promises';
import path from 'node:path';
import {localStatus,root} from './lib/local-supabase.mjs';
const status = await localStatus();
const config = {
  SUPABASE_URL:status.API_URL,
  SUPABASE_PUBLISHABLE_KEY:status.PUBLISHABLE_KEY || status.ANON_KEY,
  KITE_AUTH_REDIRECT_URL:'http://localhost:8722/auth/callback',
};
if (!config.SUPABASE_PUBLISHABLE_KEY) throw new Error('The local stack did not return a public client key.');
const target = path.join(root,'config/supabase.local.json');
await fs.writeFile(target,JSON.stringify(config,null,2)+'\n',{mode:0o600});
console.log('Wrote ignored config/supabase.local.json with local public configuration.');
console.log(`API: ${status.API_URL}\nMail capture: ${status.MAILPIT_URL}`);
