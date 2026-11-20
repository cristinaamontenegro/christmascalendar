-- RP Team Holidays: run in Supabase Dashboard > SQL Editor.
create table if not exists public.rp_team_holidays (
  id uuid primary key default gen_random_uuid(),
  holiday_date date not null,
  team_member text not null check (char_length(trim(team_member)) between 1 and 50),
  created_at timestamptz not null default now()
);

create unique index if not exists rp_team_holidays_date_member_unique
  on public.rp_team_holidays (holiday_date, lower(team_member));

alter table public.rp_team_holidays enable row level security;

-- Public anonymous access: anyone who can open the public GitHub Pages site
-- can read, add and delete entries. Use Supabase Auth and stricter policies
-- instead if the calendar should be restricted to the RP team.
drop policy if exists "Public can read RP team holidays" on public.rp_team_holidays;
create policy "Public can read RP team holidays"
  on public.rp_team_holidays for select to anon using (true);

drop policy if exists "Public can add RP team holidays" on public.rp_team_holidays;
create policy "Public can add RP team holidays"
  on public.rp_team_holidays for insert to anon
  with check (
    char_length(trim(team_member)) between 1 and 50
    and holiday_date between date '2026-11-30' and date '2027-01-07'
  );

drop policy if exists "Public can remove RP team holidays" on public.rp_team_holidays;
create policy "Public can remove RP team holidays"
  on public.rp_team_holidays for delete to anon
  using (holiday_date between date '2026-11-30' and date '2027-01-07');

-- Enable Realtime. If this reports the table is already in the publication, that's fine.
do $$
begin
  alter publication supabase_realtime add table public.rp_team_holidays;
exception when duplicate_object then null;
end $$;
