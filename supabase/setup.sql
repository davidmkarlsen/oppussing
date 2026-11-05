-- =====================================================================
-- Oppussing 1. etasje: databaseoppsett for Supabase
-- Lim inn hele filen i Supabase → SQL Editor → New query, og trykk Run.
-- Filen kan kjøres flere ganger uten at noe dobles eller slettes.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. HVEM SKAL HA TILGANG? Endre e-postene under før du kjører.
--    Bare disse kan logge inn og se/endre planen. Legg til flere linjer
--    for flere personer, f.eks. ('partner@epost.no').
-- ---------------------------------------------------------------------
create table if not exists public.allowed_users (
  email text primary key
);
alter table public.allowed_users enable row level security;

insert into public.allowed_users (email) values
  ('DIN-EPOST@eksempel.no')
on conflict (email) do nothing;


-- ---------------------------------------------------------------------
-- 1. Tilgangssjekk: er den innloggede e-posten på listen?
-- ---------------------------------------------------------------------
create or replace function public.is_allowed()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.allowed_users
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;
revoke all on function public.is_allowed() from public, anon;
grant execute on function public.is_allowed() to authenticated;


-- ---------------------------------------------------------------------
-- 2. Oppgaver (én rad per oppgave, innholdet ligger i "data")
-- ---------------------------------------------------------------------
create table if not exists public.tasks (
  id         text primary key,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.tasks enable row level security;

drop policy if exists "tasks: les"   on public.tasks;
drop policy if exists "tasks: ny"    on public.tasks;
drop policy if exists "tasks: endre" on public.tasks;
drop policy if exists "tasks: slett" on public.tasks;
create policy "tasks: les"   on public.tasks for select to authenticated using (public.is_allowed());
create policy "tasks: ny"    on public.tasks for insert to authenticated with check (public.is_allowed());
create policy "tasks: endre" on public.tasks for update to authenticated using (public.is_allowed()) with check (public.is_allowed());
create policy "tasks: slett" on public.tasks for delete to authenticated using (public.is_allowed());

-- Live-oppdatering mellom mobil og PC (og mellom dere to)
alter table public.tasks replica identity full;
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'tasks'
  ) then
    alter publication supabase_realtime add table public.tasks;
  end if;
end $$;


-- ---------------------------------------------------------------------
-- 3. Bilder: privat lagringsmappe, bare for de på tilgangslisten
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 20971520, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do nothing;

drop policy if exists "photos: les"   on storage.objects;
drop policy if exists "photos: ny"    on storage.objects;
drop policy if exists "photos: endre" on storage.objects;
drop policy if exists "photos: slett" on storage.objects;
create policy "photos: les"   on storage.objects for select to authenticated using (bucket_id = 'photos' and public.is_allowed());
create policy "photos: ny"    on storage.objects for insert to authenticated with check (bucket_id = 'photos' and public.is_allowed());
create policy "photos: endre" on storage.objects for update to authenticated using (bucket_id = 'photos' and public.is_allowed());
create policy "photos: slett" on storage.objects for delete to authenticated using (bucket_id = 'photos' and public.is_allowed());


-- ---------------------------------------------------------------------
-- 4. Dagens 8 oppgaver (hoppes over hvis de allerede finnes)
-- ---------------------------------------------------------------------
insert into public.tasks (id, data) values
  ('el-anlegg', $task${"actualCost": null, "costMax": 150000, "costMin": 60000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 15, "daysMin": 7, "dependsOn": "Etter riving av vegg, før veggplater", "description": "Nytt sikringsskap med jordfeilautomater og overspenningsvern, nye kurser, kabler, stikkontakter og brytere i 1. etasje. Må utføres av registrert elinstallatør, som også sender ferdigmelding og samsvarserklæring.", "doneBy": "handverker", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "⚡", "notes": "Prisen avhenger mest av antall punkter (ofte rundt 600–1 000 kr per punkt) og om anlegget legges skjult.\nHent inn minst 3 tilbud. Ta vare på samsvarserklæringen.\nPlanlegg punkter for kjøkkenøy/åpen løsning samtidig.", "order": 2, "priority": "hoy", "requiresPro": true, "status": "ikke-startet", "title": "Bytte el-anlegget"}$task$::jsonb),
  ('innerdorer', $task${"actualCost": null, "costMax": 25000, "costMin": 9000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 3, "daysMin": 1, "dependsOn": "Etter MDF-plater på vegg, før laminat og nye gulvlister", "description": "Rive de gamle sponplatedørene med karm, og montere nye ferdigdører med karm, foringer og gerikter. Karmer laget etter ca. 1972 har som regel standardmål, så nye dørblader kan passe i eksisterende karm om du vil spare.", "doneBy": "begge", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🚪", "notes": "Ca. 3 000–6 000 kr per dør med karm, pluss 2 000–3 000 kr per dør om snekker monterer.\nMål karmåpningen (bredde × høyde) før du bestiller.", "order": 5, "priority": "middels", "requiresPro": false, "status": "ikke-startet", "title": "Bytte 3 innerdører med karm"}$task$::jsonb),
  ('inngangsdor', $task${"actualCost": null, "costMax": 40000, "costMin": 15000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 2, "daysMin": 1, "dependsOn": "Uavhengig av de andre jobbene. Kan gjøres når som helst.", "description": "Ny ytterdør med karm, lås og beslag. Gir bedre isolasjon, tetthet og sikkerhet. Montering inkluderer riving av gammel dør, justering, drevning og nye utvendige og innvendige foringer.", "doneBy": "handverker", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🔑", "notes": "Døren alene koster typisk 10 000–30 000 kr. Leveringstid kan være flere uker, så bestill tidlig.", "order": 6, "priority": "middels", "requiresPro": false, "status": "ikke-startet", "title": "Bytte inngangsdør"}$task$::jsonb),
  ('kjokkenfronter', $task${"actualCost": null, "costMax": 5000, "costMin": 1500, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 4, "daysMin": 2, "dependsOn": "Etter støvete arbeid (riving, el, vegger, gulv)", "description": "Demontere fronter og hengsler, vaske og avfette, slipe (korn 120 → 180/240), beise eller grunne, og lakke 2–3 strøk. Vurder nye håndtak og hengsler samtidig. Gjøres sist, så frontene ikke får støv fra riving og sliping.", "doneBy": "selv", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🖌️", "notes": "Sjekk om frontene er heltre, finer eller folie/melamin. Folie og melamin kan ikke beises, bare males etter heftgrunning.\nMateriell: slipepapir, avfetting, beis eller grunning, lakk/maling, evt. håndtak.", "order": 8, "priority": "hoy", "requiresPro": false, "status": "ikke-startet", "title": "Pusse og beise/lakke kjøkkenfronter"}$task$::jsonb),
  ('laminat', $task${"actualCost": null, "costMax": 50000, "costMin": 18000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 5, "daysMin": 3, "dependsOn": "Etter riving av vegg (gulvet der veggen sto må fylles) og dørbytte", "description": "Rive gammelt gulvbelegg, rette opp undergulvet der det trengs, legge underlag og nytt laminat i alle rom utenom bad. Nye gulvlister og overganger mot bad og dører.", "doneBy": "selv", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🪵", "notes": "Antatt ca. 70 m². Juster når du har målt.\nLaminat 200–450 kr/m² + underlag. Legger du ikke selv: ca. 150–250 kr/m² i tillegg.\nKjøp 8–10 % ekstra for kapp.", "order": 7, "priority": "middels", "requiresPro": false, "status": "ikke-startet", "title": "Nytt laminat i hele 1. etasje"}$task$::jsonb),
  ('mdf-vegger', $task${"actualCost": null, "costMax": 150000, "costMin": 40000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 15, "daysMin": 8, "dependsOn": "Etter el og ventilasjon, før dører og laminat", "description": "Kle veggene i 1. etasje med MDF-veggplater (ferdigmalte eller for maling), inkludert nye gerikter rundt dører og vinduer og nye tak- og gulvlister. Gjøres etter at el og ventilasjon er lagt i veggene.", "doneBy": "begge", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🪚", "notes": "Antatt ca. 130–160 m² veggflate. Juster når du har målt.\nGjør du det selv: ca. 40 000–80 000 kr i materialer. Med snekker: ca. 80 000–150 000 kr.\nPlanlegg gulvlistene sammen med laminatet.", "order": 4, "priority": "middels", "requiresPro": false, "status": "ikke-startet", "title": "MDF-plater på alle vegger"}$task$::jsonb),
  ('rive-vegg', $task${"actualCost": null, "costMax": 120000, "costMin": 20000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 10, "daysMin": 3, "dependsOn": "Først. Påvirker el, ventilasjon, gulv og vegger.", "description": "Avklar først om veggen er bærende (byggetegninger, retning på bjelkelag og takstoler). Ikke-bærende: riving, flikk av tak, vegger og gulv, og flytting av el-punkter i veggen. Bærende: en konstruktør beregner bjelke, og jobben kan være søknadspliktig.", "doneBy": "begge", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🔨", "notes": "Ikke-bærende vegg: ca. 20 000–40 000 kr.\nBærende vegg med bjelke og konstruktør: ca. 60 000–120 000 kr.\nSjekk med kommunen om tiltaket er søknadspliktig.", "order": 1, "priority": "hoy", "requiresPro": true, "status": "ikke-startet", "title": "Rive vegg mellom kjøkken og stue"}$task$::jsonb),
  ('ventilasjon', $task${"actualCost": null, "costMax": 120000, "costMin": 25000, "createdAt": "2026-11-05T10:50:00Z", "daysMax": 10, "daysMin": 3, "dependsOn": "Etter riving. Kanaler legges før vegger og tak kles.", "description": "I dag finnes bare en liten ventil på badet, og ingen avtrekk fra kjøkkenet. Alternativ A: mekanisk avtrekk med kjøkkenhette og kanal ut, baderomsvifte og friskluftventiler i stue og soverom. Alternativ B: balansert ventilasjon med varmegjenvinning.", "doneBy": "handverker", "groups": {"inspo": {"notes": "", "photos": []}, "naa": {"notes": "", "photos": []}, "resultat": {"notes": "", "photos": []}}, "icon": "🌬️", "notes": "Alternativ A: ca. 25 000–40 000 kr.\nAlternativ B: ca. 70 000–120 000 kr. Enova kan gi støtte til balansert ventilasjon i boliger med byggemelding før 1. juli 2010.\nDårlig ventilasjon gir fukt- og muggfare, særlig når huset blir tettere etter oppussing.", "order": 3, "priority": "hoy", "requiresPro": true, "status": "ikke-startet", "title": "Ventilasjon i 1. etasje"}$task$::jsonb)
on conflict (id) do nothing;
