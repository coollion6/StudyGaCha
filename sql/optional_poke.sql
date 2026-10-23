-- 可选：戳一戳
-- 因为 RLS 只允许改自己的行，前端不能直接 update 别人的 profiles。
-- 这个函数用 security definer 代劳，只改 poke_message 一个字段。

create or replace function public.poke(target uuid, msg text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
    if auth.uid() is null or target = auth.uid() then
        return false;
    end if;

    update public.profiles
       set poke_message = left(coalesce(msg, ''), 200)
     where id = target;

    return found;
end;
$$;

revoke all on function public.poke(uuid, text) from public;
grant execute on function public.poke(uuid, text) to authenticated;
