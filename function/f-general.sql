/**
 * 2015 cai
 *
 * 一般存储过程
 */

-----------------------------------------------------------------------------------------------------------------------------------------------------
-- hyyear(date)
-- i: 日期
-- o: 年
create or replace function hyyear (d date) returns int as
$$
declare l date; wl int; y int;
begin
  y := date_part('year', d);
  l := (y || '-12-31') :: date;
  wl := date_part('dow',l);
  if (l - d < wl) then
    return date_part('year',d) + 1;
  else
    return date_part('year',d);
  end if;
end;
$$
language plpgsql immutable;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- hyweek(date)
-- i: 日期
-- o: 周号
create or replace function hyweek (d date) returns int as
$$
declare f date; wf int;l date; wl int; y int;
begin
  y := date_part('year', d);
  l := (y || '-12-31') :: date;
  wl := date_part('dow',l);
  if (l - d < wl) then
    return 1;
  end if;
  f := (y || '-01-01') :: date;
  wf := date_part('dow',f);
  if (wf = 0) then
    return (d - f + 6) / 7 + 1 ;
  else
    return (d - f + wf - 1) / 7 + 1 ;
  end if;
end;
$$
language plpgsql immutable;

-- 数据缺失验证
-----------------------------------------------------------------------------------------------------------------------------------------------------
create or replace function checkMiss(text, text, text, text) returns table (缺失 varchar(255)) as
$proc$
begin
return query execute format ('select distinct %s from %s except select %s from %s',$1,$2,$3,$4);
end;
$proc$
language plpgsql;
-----------------------------------------------------------------------------------------------------------------------------------------------------
