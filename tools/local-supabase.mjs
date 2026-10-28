#!/usr/bin/env node
// Project-scoped local stack lifecycle; never invokes a hosted project command.
import {execFileSync} from 'node:child_process';
import fs from 'node:fs/promises';
import path from 'node:path';
import {cliOptions,localStatus,root} from './lib/local-supabase.mjs';
const action=process.argv[2] || 'status';
const commands={start:['start','--exclude','realtime,storage-api,imgproxy,postgres-meta,studio,edge-runtime,logflare,vector,supavisor'],stop:['stop']};
if(action==='status') {
  const s=await localStatus();console.log(`API: ${s.API_URL}\nMail capture: ${s.MAILPIT_URL}`);
} else if(commands[action]) {
  const {cli,env}=await cliOptions();
  console.log(`${action==='start'?'Starting':'Stopping'} the isolated local kite-e2e stack…`);
  try {execFileSync(cli,commands[action],{cwd:root,env,encoding:'utf8',maxBuffer:32*1024*1024,stdio:['ignore','pipe','pipe']});}
  catch(error) {
    const log=path.join(root,'build/e2e/local-stack.log');await fs.mkdir(path.dirname(log),{recursive:true});
    // CLI output may include development credentials. Keep diagnostic logs local.
    await fs.writeFile(log,String(error.stderr || 'Local stack command failed.'),{mode:0o600});
    throw new Error(`Local stack command failed. Inspect ignored ${path.relative(root,log)}.`);
  }
  console.log(`Local stack ${action==='start'?'started':'stopped'}.`);
} else {throw new Error('Usage: node tools/local-supabase.mjs start|status|stop');}
