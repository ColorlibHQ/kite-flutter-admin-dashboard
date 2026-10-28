import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export async function cliOptions() {
  let cli = process.env.SUPABASE_CLI;
  if (!cli) {
    const bundled = path.join(root,'.tools/supabase');
    try { await fs.access(bundled); cli = bundled; } catch { cli = 'supabase'; }
  }
  const env = {...process.env, DO_NOT_TRACK:'1'};
  if (!env.DOCKER_HOST && !env.DOCKER_CONTEXT) {
    const socket = path.join(os.homedir(),'.colima/kite-e2e/docker.sock');
    try {await fs.access(socket); env.DOCKER_HOST = `unix://${socket}`;} catch { /* Use the current Docker runtime. */ }
  }
  assert((await fs.readFile(path.join(root,'supabase/config.toml'),'utf8')).includes('project_id = "kite-e2e"'), 'Only the isolated kite-e2e project is supported.');
  return {cli,env};
}
export async function localStatus() {
  const {cli,env} = await cliOptions();
  let status;
  try {status = JSON.parse(execFileSync(cli,['status','-o','json'],{cwd:root,env,encoding:'utf8',stdio:['ignore','pipe','pipe']}));}
  catch {throw new Error('Local Supabase is not available. Check that the Docker CLI is on PATH and the kite-e2e stack is running. Set SUPABASE_CLI if needed.');}
  const mail = status.INBUCKET_URL || status.MAILPIT_URL || 'http://127.0.0.1:57424';
  for (const url of [status.API_URL,mail]) assert(['127.0.0.1','localhost','[::1]'].includes(new URL(url).hostname),'Hosted endpoints are not permitted by the local setup/test helpers.');
  return {...status,MAILPIT_URL:mail};
}
