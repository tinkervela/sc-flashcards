-- Run once in Supabase Dashboard > SQL Editor.
-- Personal notes are separate from the existing learning_progress table.
create table if not exists public.term_notes (
  user_id uuid not null references auth.users(id) on delete cascade,
  term_id text not null,
  note text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, term_id),
  constraint term_notes_note_length check (char_length(note) <= 10000),
  constraint term_notes_term_id_length check (char_length(term_id) between 1 and 300)
);
alter table public.term_notes enable row level security;
revoke all on public.term_notes from anon;
grant select, insert, update, delete on public.term_notes to authenticated;
drop policy if exists "Select own notes" on public.term_notes;
create policy "Select own notes" on public.term_notes for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Insert own notes" on public.term_notes;
create policy "Insert own notes" on public.term_notes for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Update own notes" on public.term_notes;
create policy "Update own notes" on public.term_notes for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "Delete own notes" on public.term_notes;
create policy "Delete own notes" on public.term_notes for delete to authenticated using ((select auth.uid()) = user_id);
