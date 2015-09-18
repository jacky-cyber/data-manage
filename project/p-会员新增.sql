drop table 会员新增;
create table 会员新增 as
with w1 as (
select
  卡类.卡类b as 卡类型,
  t1.会员卡,
  date_trunc('month', t1.日期)::date as 年月
from
  零售单 t1
  left join 日历 on t1.日期 = 日历.日期
  left join 卡资料 on t1.会员卡 = 卡资料.卡号
  left join 卡类 on 卡资料.卡类型 = 卡类.卡类型
where
  卡类.卡类a = '会员'
  and t1.日期 <= '2015-08-31'
), w2 as (
select
  卡类型,
  会员卡,
  min(年月) as 首月
from
  w1
group by
  1,2
), w3 as (
select
  卡类型,
  首月,
  count(会员卡) as 卡数
from
  w2
group by
  1,2
), w4 as (
select
  distinct 卡类型,
  generate_series('2012-01-01'::date,'2015-08-01'::date,'1 month')::date 首月
from
  w3
)
select
  *
from
  w4
  left join w3 using(卡类型,首月)
order by
  1,2;
