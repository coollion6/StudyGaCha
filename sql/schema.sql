-- StudyGacha 数据库结构
-- 在 Supabase SQL Editor 中执行。全部使用 if not exists，可重复运行。

create extension if not exists pgcrypto;

-- 用户资料：一行对应一个 auth.users
create table if not exists public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    username text unique not null,
    birthday date,
    security_question text,
    total_minutes int not null default 0,
    total_coins int not null default 0,
    streak int not null default 0,
    last_active_date date,
    custom_rewards jsonb not null default '[]'::jsonb,
    custom_quotes jsonb not null default '[]'::jsonb,
    redeem_history jsonb not null default '[]'::jsonb,
    poke_message text
);

-- 任务库
create table if not exists public.tasks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    name text not null,
    difficulty int not null check (difficulty between 1 and 10),
    willingness int not null check (willingness between 1 and 10),
    score int not null,
    rarity text not null,
    type text not null,
    created_at timestamptz not null default now()
);

-- 每日抽卡与打卡记录
create table if not exists public.daily_records (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    record_date date not null,
    tasks_data jsonb not null default '[]'::jsonb,
    completed_minutes int not null default 0,
    completed_coins int not null default 0,
    has_rerolled boolean not null default false,
    unique (user_id, record_date)
);

create index if not exists tasks_user_idx on public.tasks (user_id);
create index if not exists daily_records_user_date_idx
    on public.daily_records (user_id, record_date);
