-- Execute once in Supabase > SQL Editor (project sc-learning).
-- Append-only review events, independent of learning_progress and term_notes.
create table if not exists public.review_events (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  term_id text not null,
  rating text not null,
  occurred_at timestamptz not null,
  primary key (user_id, id),
  constraint review_events_term_length check (char_length(term_id) between 1 and 300),
  constraint review_events_rating check (rating in ('good','unsure','bad'))
);
create index if not exists review_events_user_time_idx
 on public.review_events (user_id, occurred_at desc);
alter table public.review_events enable row level security;
revoke all on public.review_events from anon;
grant select, insert on public.review_events to authenticated;
-- No UPDATE / DELETE is needed for immutable review records.
drop policy if exists "Select own review events" on public.review_events;
create policy "Select own review events"
 on public.review_events for select to authenticated
 using ((select auth.uid()) = user_id);
drop policy if exists "Insert own review events" on public.review_events;
create policy "Insert own review events"
 on public.review_events for insert to authenticated
 with check ((select auth.uid()) = user_id);
