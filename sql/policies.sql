-- StudyGacha 行级安全策略（RLS）
-- 在 schema.sql 之后执行，可重复运行。

alter table public.profiles enable row level security;
alter table public.tasks enable row level security;
alter table public.daily_records enable row level security;

-- ===== profiles =====
-- 本人可读写自己的资料
drop policy if exists "Users can manage own profile" on public.profiles;
create policy "Users can manage own profile"
    on public.profiles
    for all
    using (auth.uid() = id)
    with check (auth.uid() = id);

-- 排行榜需要读取所有人的公开资料
-- 注意：这张表里的生日、密保问题也会被读到，不要往这里放敏感答案
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
create policy "Public profiles are viewable by everyone"
    on public.profiles
    for select
    using (true);

-- ===== tasks =====
-- 任务库只对本人可见
drop policy if exists "Users can manage own tasks" on public.tasks;
create policy "Users can manage own tasks"
    on public.tasks
    for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- ===== daily_records =====
-- 本人可读写自己的记录
drop policy if exists "Users can manage own records" on public.daily_records;
create policy "Users can manage own records"
    on public.daily_records
    for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- 偷看好友今日任务需要跨用户读取
-- 注意：这会让所有登录用户都能读到所有人的 tasks_data
drop policy if exists "Public records are viewable by everyone" on public.daily_records;
create policy "Public records are viewable by everyone"
    on public.daily_records
    for select
    using (true);
