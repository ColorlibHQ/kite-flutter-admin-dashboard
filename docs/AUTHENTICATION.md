# Authentication and roles

Kite includes a zero-configuration demo and a Supabase Auth integration. Real
identity verification and data permissions require your Supabase project;
this repository does not provision a hosted service or send email by itself.

## Demo login and preview link

Without backend configuration, sign in with the prefilled `admin@kite.dev` /
`password` sample account. Mock mode verifies no password and sends no mail;
identities and resource edits reset on restart. The hosted public demo starts
on the dashboard automatically; sign out to view the sample login.

Production sign-in starts with empty fields and links to the separate public
preview. Set `KITE_PREVIEW_URL` to your own demo URL at build time, or set it to
an empty string to remove the link. Public demo credentials never grant a
Supabase role or bypass production authentication.

## Local end-to-end environment

The checked-in `supabase/config.toml` runs a separate local `kite-e2e` stack:
API `57421`, database `57422`, and Mailpit `57424`. Email confirmation is on;
confirmation and recovery messages stay in Mailpit and are never delivered to
real inboxes. These local settings do not modify a hosted project's Auth config.

With Supabase CLI 2.122.0 (matching CI) and a Docker-compatible runtime available:

```bash
node tools/local-supabase.mjs start
node tools/configure-local-supabase.mjs
node tools/auth-e2e.mjs
```

`SUPABASE_CLI` may specify a CLI executable path; helpers also detect the
project-local `.tools/supabase` executable. A `kite-e2e` Colima socket is selected
only if no Docker environment override is set. The Docker CLI must be on PATH.
If using a separate VM, mount this repository read-only at its original path:
Supabase serves the checked-in email templates using bind mounts.

Run the app with:

```bash
flutter run -d chrome --web-port 8722 --dart-define-from-file=config/supabase.local.json
```

After signing up locally and confirming the captured email, assign access with
the trusted local-only helper:

```bash
node tools/local-role.mjs you@example.test admin
# viewer, editor, and none are also supported
```

Sign in again to refresh the UI role. This helper uses local service credentials
only inside the Node process and refuses hosted endpoints.

Use `node tools/local-supabase.mjs status` for public service URLs and
`node tools/local-supabase.mjs stop` to stop local services while preserving the
database. To release the isolated VM's resources too, run
`colima stop kite-e2e`; restart it with `colima start kite-e2e --activate=false`
before starting the stack again. Your other container profiles are unchanged.
The helpers do not print service-role keys.

The integration runner accepts
only loopback endpoints and the `kite-e2e` project. It creates fresh synthetic
users and products, exercises actual Auth/PostgREST services, and removes its
fixtures. Results without credentials are saved in `build/e2e/auth-report.json`.
Local service credentials must never be used for a hosted deployment.

## Hosted staging verification

Keep hosted configuration in an ignored `config/staging.local.json`, with only
the project URL, publishable key, and callback URL. Use port `8723` for hosted
staging to keep the local Mailpit environment on `8722`:

```bash
flutter run -d chrome --web-port 8723 --dart-define-from-file=config/staging.local.json
```

Set the hosted Site URL to `http://localhost:8723` and allow these exact callbacks:
`http://localhost:8723/auth/callback` and
`http://localhost:8723/auth/callback?flow=recovery`. For a deployed frontend,
replace these with its HTTPS origin. Configure custom SMTP and use an inbox you
control for hosted email testing; local Mailpit cannot capture hosted emails.
The verification form accepts six through ten digits, including Supabase's
eight-digit default; email-link confirmation is supported too. Match the hosted
minimum password length to the app's 12-character requirement.

`tools/policy-tests/hosted-roles.sql` checks role permissions in a transaction as
`postgres` and rolls back all fixtures. Run it only against an isolated staging
database. It tests database authorization, separately from email and Auth flows.
Run security and performance advisors after applying the migration. Never point
the local integration runner at a hosted project or disable email confirmation
to make a test pass.

### Cloudflare SMTP

Cloudflare Email Routing receives and forwards mail. To send Supabase Auth
messages, also onboard a sender domain under Cloudflare **Email Sending**.
A dedicated subdomain such as `auth.example.com` keeps authentication-mail
DNS separate from the primary support address.

Configure Supabase **Authentication → Emails → SMTP Settings** with:

| Setting | Value |
| --- | --- |
| Sender email | `noreply@auth.example.com`, matching the onboarded domain |
| Host | `smtp.mx.cloudflare.net` |
| Port | `465` (implicit TLS) |
| Username | Literal `api_token` |
| Password | Cloudflare token with account-scoped **Email Sending: Edit** |

Keep this credential in Supabase's encrypted SMTP settings. Never add it to
Flutter defines, client configuration, screenshots, logs, or Git. Verify sender
DNS, send a confirmation message, and inspect delivery logs before testing
password recovery. See [Cloudflare's SMTP reference](https://developers.cloudflare.com/email-service/api/send-emails/smtp/)
for current connection requirements and [pricing](https://developers.cloudflare.com/email-service/platform/pricing/).

## Configure a Supabase project

1. Apply `supabase/migrations/202610270001_kite_auth_roles.sql` to a new project
   using the Supabase SQL editor or your migration workflow. It creates the
   resource tables and row-level security policies. For an existing database,
   adapt the schema in a reviewed migration rather than re-running it blindly.
2. Enable email/password authentication and configure an SMTP provider, email
   confirmation, rate limits, and the password policy. The UI requires at least
   12 characters for new passwords; enforce an equivalent policy on the server.
3. Add your exact callback to **Authentication → URL Configuration → Redirect
   URLs**, for example `http://localhost:8722/auth/callback` locally and
   `https://admin.example.com/auth/callback` in production. Set Site URL to your
   app origin. Also allow the recovery callback with `?flow=recovery`, which
   preserves recovery intent across cold starts. Subpath hosting uses `/admin/auth/callback` and `--base-href /admin/`.
4. Create public build configuration using `config/production.example.json` as
   a starting point. Set `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, and
   `KITE_AUTH_REDIRECT_URL`. Legacy anon keys are accepted through
   `SUPABASE_ANON_KEY`. Server secret and service-role keys are rejected.
5. Run `flutter run -d chrome --web-port 8722 --dart-define-from-file=config/production.local.json`.
   For release, pass the same config to `flutter build web --wasm --release`.

Do not combine `KITE_DEMO=true` with production authentication. A remote REST
API without production auth requires explicit demo mode; this prevents the
sample “any email” sign-in from silently protecting real data.

## Assign access on the server

Registration creates an identity, **not an admin**. Until a trusted operator
assigns a role, the account has no resource access. From your SQL editor or
trusted server connection:

Successful email confirmation can therefore open **Access denied** (`/403`).
This means the identity is verified but is still unassigned. Assign access on
the server, then reload the app or sign in again to refresh its role.

```sql
insert into public.kite_user_roles (user_id, role)
select id, 'admin' from auth.users where email = 'owner@example.com'
on conflict (user_id) do update set role = excluded.role;
```

| Role | Read resources | Create / update | Delete |
| --- | --- | --- | --- |
| Unassigned | No | No | No |
| Viewer | Yes | No | No |
| Editor | Yes | Yes | No |
| Admin | Yes | Yes | Yes |

Clients can read only their own role. They cannot insert, update, or delete role
assignments. The app ignores role strings in user-editable metadata and JWT app
metadata; `kite_user_roles` is authoritative. Server policies read the current
table state, so revocation blocks the next request even with an older JWT.
The UI refreshes role information on sign-in, restoration, and auth events.
Sign in again to pick up an assignment immediately.

These policies describe a **single shared workspace**. They do not implement
multi-tenant isolation. Add organization membership and row ownership policies
before placing unrelated organizations in one database.

## Sessions and recovery

The SDK handles session refresh and persistence. On startup Kite validates a
restored identity with the auth server and fetches its current role before
rendering private screens. Invalid sessions are cleared; connection failures
show a retry screen rather than granting access. The data adapters read the
current token on each request, including after refresh.

Native sessions use `flutter_secure_storage` and the OS credential store.
Display preferences use `shared_preferences` and contain no credentials.
Native PKCE verifiers also use the secure credential store. Web
sessions use the SDK's browser local storage, which JavaScript on the same
origin can access. Deploy over HTTPS and protect the app origin against XSS;
use a server-managed HttpOnly-cookie architecture if your threat model requires
that session tokens stay out of browser JavaScript.

Registration and recovery call Supabase, rather than simulating successful mail.
Email confirmation supports links and six- through ten-digit signup codes. To show a code,
include `{{ .Token }}` in your Supabase confirmation email template. Password
recovery uses a PKCE callback and forces the password-update screen. A reset
request uses an account-neutral success message. Demo mode sends no email and
shows the sample verification code explicitly.

Sign-out clears the local identity immediately and asks the server to revoke
the current session. An offline network error does not restore the local user.
Already issued JWTs remain usable until expiration; server-side role revocation
provides an immediate data-access cutoff. The lock screen demonstrates
reauthentication; it is not a replacement for server session security.

## Native callbacks

Android, iOS, and macOS register `kite://login/auth/callback`, with Flutter's competing
deep-link handler disabled so the SDK handles PKCE. Allow this URL in Supabase
and use it as `KITE_AUTH_REDIRECT_URL` for native builds. Replace the `kite`
scheme with your application-specific scheme in platform files and
`AuthConfig.validate` before distribution. Prefer verified app/universal links
for deployed products; custom schemes can be claimed by another installed app.

Windows needs an application-specific URL association in your installer for
recovery links. macOS registers the template scheme in its bundle metadata. Configure this for your bundle ID and
installer rather than using the web callback for native recovery. Email code
confirmation does not require a native callback. macOS has outbound networking
enabled and uses the legacy Keychain to avoid requiring shared-keychain
provisioning. iOS includes its Keychain entitlement. Android disables backups
so encrypted session data is not restored without its device key.

## REST backends

With Supabase Auth configured, setting `KITE_API_URL` selects the REST data
adapter and attaches the current bearer token. Your API must validate Supabase
JWTs and enforce the same roles independently. The Flutter route guard and
`AuthorizedDataProvider` improve UX and prevent accidental calls; they are not
a server security boundary. Extend `AuthRepository` for another identity service.

## Verification

```bash
flutter test --coverage
cd tools/policy-tests
npm ci
npm test
```

The Dart tests use the real Supabase client with mocked HTTP responses; the SQL
tests execute the actual migration in PostgreSQL/Wasm, checking anonymous and
unassigned access, each role, self-escalation, metadata spoofing, and revocation.
Run a staging sign-up/verification/recovery cycle with your real email provider
and signed native callback configuration before deploying.

Implementation references: [Supabase Flutter Auth](https://supabase.com/docs/reference/dart/auth-signinwithpassword),
[row-level security](https://supabase.com/docs/guides/database/postgres/row-level-security),
and [native secure storage setup](https://pub.dev/packages/flutter_secure_storage).
