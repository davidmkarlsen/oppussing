-- =====================================================================
-- Dokumentlager (PDF) for husinfo-siden
-- Lim inn hele filen i Supabase → SQL Editor → New query, og trykk Run.
-- Kan kjøres flere ganger.
-- Selve husinfoen ligger ikke i repoet, siden den er privat.
-- =====================================================================

-- 1. Dokumentlager for PDF-er (salgsoppgave, takster, tilbud, kvitteringer)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('docs', 'docs', false, 52428800, array['application/pdf','image/jpeg','image/png','image/webp'])
on conflict (id) do update set file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "docs: les"   on storage.objects;
drop policy if exists "docs: ny"    on storage.objects;
drop policy if exists "docs: endre" on storage.objects;
drop policy if exists "docs: slett" on storage.objects;
create policy "docs: les"   on storage.objects for select to authenticated using (bucket_id = 'docs' and public.is_allowed());
create policy "docs: ny"    on storage.objects for insert to authenticated with check (bucket_id = 'docs' and public.is_allowed());
create policy "docs: endre" on storage.objects for update to authenticated using (bucket_id = 'docs' and public.is_allowed());
create policy "docs: slett" on storage.objects for delete to authenticated using (bucket_id = 'docs' and public.is_allowed());
