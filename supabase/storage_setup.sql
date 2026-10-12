-- LocaLink: Supabase Storage setup (from Backend Architecture PDF, section 7)
-- Run once in: Supabase Dashboard -> SQL Editor -> New query -> paste -> Run.
-- Safe to run again.
--
-- Files only. All business data lives in Firebase.
-- The first folder of every path is the Firebase uid:  {uid}/...
-- Policies use auth.jwt() ->> 'sub' (the Firebase uid), never auth.uid().

-- 1) Buckets (5 MB limit per file)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('listing-photos', 'listing-photos', true,  5242880, array['image/jpeg','image/png','image/webp']),
  ('avatars',        'avatars',        true,  5242880, array['image/jpeg','image/png','image/webp']),
  ('request-photos', 'request-photos', false, 5242880, array['image/jpeg','image/png','image/webp']),
  ('provider-docs',  'provider-docs',  false, 5242880, array['image/jpeg','image/png','application/pdf']),
  ('ai-photos',      'ai-photos',      false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- 2) Guests (Firebase anonymous users) must not upload
create or replace function public.is_registered()
returns boolean
language sql
stable
as $$
  select (auth.jwt() ->> 'sub') is not null
     and coalesce(auth.jwt() -> 'firebase' ->> 'sign_in_provider', '') <> 'anonymous';
$$;

-- 3) Policies on storage.objects
drop policy if exists "localink insert own folder" on storage.objects;
drop policy if exists "localink read own files"    on storage.objects;
drop policy if exists "localink update own files"  on storage.objects;
drop policy if exists "localink delete own files"  on storage.objects;

-- upload: real accounts only, and only into their own {uid}/ folder
create policy "localink insert own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id in ('listing-photos','avatars','request-photos','provider-docs','ai-photos')
  and public.is_registered()
  and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
);

-- read/list/create signed URLs: only your own files
-- (public buckets are also readable by anyone through their public URL)
create policy "localink read own files"
on storage.objects for select to authenticated
using (
  bucket_id in ('listing-photos','avatars','request-photos','provider-docs','ai-photos')
  and public.is_registered()
  and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
);

create policy "localink update own files"
on storage.objects for update to authenticated
using (
  bucket_id in ('listing-photos','avatars','request-photos','provider-docs','ai-photos')
  and public.is_registered()
  and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
)
with check (
  (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
);

create policy "localink delete own files"
on storage.objects for delete to authenticated
using (
  bucket_id in ('listing-photos','avatars','request-photos','provider-docs','ai-photos')
  and public.is_registered()
  and (storage.foldername(name))[1] = (auth.jwt() ->> 'sub')
);

-- Admins review provider-docs in the Supabase dashboard (service role bypasses these policies).
-- AI photos are deleted after 24 h by the Cloud Function purgeAiPhotos.
