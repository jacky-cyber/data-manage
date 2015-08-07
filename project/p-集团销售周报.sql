/**
 * 2015 cai
 *
 * 周报（第22周更新）
 */

drop table if exists 周报部门编号, 周报数据;
create temp table 周报部门编号 as select * from 部门编号 where 二级部门名称 not in ('温室资材部','草业事业部');

-- 周报_k3销售数据 (date,date)
-- i: 开始日期,结束日期
-- o: k3周销售数据表
drop function if exists 周报_k3销售数据 (date,date);
create or replace function
  周报_k3销售数据 (date,date)
returns
  table (虹越年 int,虹越周 int,二级部门名称 varchar(255),内销 numeric (20,4),外销 numeric (20,4), 总销 numeric (20,4)) as $$
select
  周报日历.虹越年,
  周报日历.虹越周,
  case
    when t1.客户代码 = '999.0213' or t1.摘要 ~ '花彩商城' then '花彩商城店'
    when t1.客户代码 = '999.0078.24' and 部门.实名 = '研究院' then '萌吖吖种子（淘宝）店'
    when t1.客户代码 = '999.0089' and 部门.实名 = '花卉城项目部' then '海宁国际花卉城（淘宝）店'
    when (t1.客户代码 in ('999.0076','999.0066') or (t1.客户代码 = '999.0167' and t1.账套 = '虹安')) and 部门.实名 = '多肉项目部' then '多肉时光（淘宝）店'
    when t1.客户代码 in ('021.9998','021.9999') and 部门.实名 = '浦东宣桥店' then '源怡种苗（淘宝）店'
    when t1.客户代码 = '573.450' and 部门.实名 = '虹越家居（天猫）专营店' then '虹越亚马逊店'
    when t1.客户代码 = '999.0162' and 部门.实名 = '园艺家总部（淘宝）店' then '虹越旗舰店'
    when 部门.实名 = '绿植采供部' and lower(t1.单据编号) ~ 'rth|dx' then
      case substring(t1.单据编号,'\d{2}')
        when '09' then '昆山千灯点'
        when '23' then '海宁花卉城点'
        when '27' then '昌邑花木城点'
        when '28' then '无锡农博园点'
        when '31' then '绍兴东湖点'
        else '绿植采供部'
      end
    when 客户.是否商超客户 then '商超运营部'
    when 部门.实名 = '温室资材部' then '上海虹越销售部'
    when 部门.实名 = '草业事业部' then '金五月销售部'
    else 部门.实名
  end as 二级部门名称,
  sum(case when 客户.是否关联客户 then t1.未税金额 end) as 内销,
  sum(case when not coalesce(客户.是否关联客户,false) then t1.未税金额 end) as 外销,
  sum(t1.未税金额) as 总销
from
  销售出库单 t1
  left join 部门 on t1.部门 = 部门.名称
  left join 周报日历 on t1.日期 = 周报日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
where
  t1.日期 between $1 and $2
  and ((not (客户.是否关联客户 and t1.账套 = '浙江' and ((t1.部门 in ('草业事业部','肥料介质部','海宁国美','花卉事业部','金五月销售部','丽彩销售部','温室花卉部','温室资材部','浙江丽彩','总部苗圃')) or (t1.部门 in ('盆器饰品部') and t1.日期 >= '2014-01-01')))) or (客户.是否商超客户))
  and ((not coalesce(客户.是否商超客户,false)) or (t1.账套 = '浙江' and 周报日历.年 = 2014) or (t1.账套 = '虹安' and 周报日历.年 = 2015))
  and not(客户.是否关联客户 and t1.账套 = '杭州' and t1.部门 in ('草业事业部') and t1.日期 >= '2014-01-01')
  and (not(客户.是否关联客户 and coalesce(t1.摘要,'') ~ '转库|转换仓库|从浙江虹越转移至杭州虹越|转仓|库存转移|移库|西溪店转虹安|转账套出库|库存转到产品部门') or t1.部门 = '国际业务部')
  and not(客户.是否关联客户 and 部门.一级部门名称 = '门店运营部' and t1.日期 between '2014-12-29' and '2014-12-31' and coalesce(t1.摘要,'') ~ '退回')
  and not(客户.是否关联客户 and t1.部门 = '长安苗圃' and t1.账套 != '国美')
group by
  1,2,3;
$$ language sql stable;

-- 周报数据
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table 周报数据 as
with w1 as (
select
  *
from
  (select * from (select distinct 虹越年,虹越周 from 周报日历 where 日期 between '2014-01-01' and date'today') t1 cross join 周报部门编号 t2) t1
  full join (select * from 周报_k3销售数据('2014-01-01',date'today')) t2 using (虹越年,虹越周,二级部门名称)
)
select
  t1.*,
  t2.内销 as 上周内销,
  t3.内销 as 上年内销,
  t2.外销 as 上周外销,
  t3.外销 as 上年外销,
  t2.总销 as 上周总销,
  t3.总销 as 上年总销,
  sum (t1.内销) over (partition by t1.虹越年,t1.二级部门名称 order by t1.虹越周 ) as 累计内销,
  sum (t1.外销) over (partition by t1.虹越年,t1.二级部门名称 order by t1.虹越周 ) as 累计外销,
  sum (t1.总销) over (partition by t1.虹越年,t1.二级部门名称 order by t1.虹越周 ) as 累计总销,
  sum (t3.内销) over (partition by t3.虹越年,t3.二级部门名称 order by t3.虹越周 ) as 上年累计内销,
  sum (t3.外销) over (partition by t3.虹越年,t3.二级部门名称 order by t3.虹越周 ) as 上年累计外销,
  sum (t3.总销) over (partition by t3.虹越年,t3.二级部门名称 order by t3.虹越周 ) as 上年累计总销
from
  w1 t1
  left join w1 t2 on t1.二级部门名称 = t2.二级部门名称 and ((t1.虹越年 = t2.虹越年 and t1.虹越周 = t2.虹越周 + 1) or (t2.虹越年 = 2014 and t2.虹越周 = 52 and t1.虹越年 = 2015 and t1.虹越周 = 1))
  left join w1 t3 on t1.二级部门名称 = t3.二级部门名称 and t1.虹越年 = t3.虹越年 + 1 and t1.虹越周 = t3.虹越周;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 周报_本周(int,int)
-- i: 虹越周,虹越年
-- o: 本周销售表
drop function if exists 周报_本周 (int,int);
create or replace function
  周报_本周 (int default hyweek (date 'today') - 1,int default hyyear (date 'today'))
returns
  table (模块编号 int,一级部门编号 int,二级部门编号 int,内销 numeric (20,4),外销 numeric (20,4),总销 numeric (20,4),内销同比 numeric (20,4),外销同比 numeric (20,4),总销同比 numeric (20,4),总销环比 numeric (20,4) ) as $proc$
declare s text := 'sum(内销) as 内销,sum (外销) as 外销,sum (总销) as 总销,(sum (内销) - nullif(sum (上年内销),0))/abs(nullif(sum (上年内销),0)) as 内销同比, (sum (外销) - nullif(sum (上年外销),0))/abs(nullif(sum (上年外销),0)) as 外销同比, (sum (总销) - nullif(sum (上年总销),0))/abs(nullif(sum (上年总销),0)) as 总销同比,(sum (总销) - nullif(sum (上周总销),0)) / abs(nullif(sum (上周总销),0)) as 总销环比 from 周报数据 where 虹越年 = %s and 虹越周 = %s group by 1,2,3)';
begin
  return query execute format ('(select 模块编号,一级部门编号,二级部门编号,' || s || ' union all (select 模块编号,一级部门编号,999 as 二级部门编号,' || s || ' union all (select 模块编号,999 as 一级部门编号,999 as 二级部门编号,' || s || ' union all (select 999 as 模块编号,999 as 一级部门编号,999 as 二级部门编号,' || s || ' order by 模块编号,一级部门编号,二级部门编号',$2,$1,$2,$1,$2,$1,$2,$1);
end;
$proc$ language plpgsql stable;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 周报_本年(int,int)
-- i: 虹越周,虹越年
-- o: 本周销售表
drop function if exists 周报_本年 (int,int);
create or replace function
  周报_本年 (int default hyweek (date 'today') - 1,int default hyyear (date 'today'))
returns
  table (模块编号 int,一级部门编号 int,二级部门编号 int,累计内销 numeric (20,4),累计外销 numeric (20,4),累计总销 numeric (20,4),累计内销同比 numeric (20,4),累计外销同比 numeric (20,4),累计总销同比 numeric (20,4)) as $proc$
declare s text := 'sum(累计内销) as 累计内销,sum (累计外销) as 累计外销,sum (累计总销) as 累计总销,(sum (累计内销) - nullif(sum (上年累计内销),0))/abs(nullif(sum (上年累计内销),0)) as 累计内销同比, (sum (累计外销) - nullif(sum (上年累计外销),0))/abs(nullif(sum (上年累计外销),0)) as 累计外销同比, (sum (累计总销) - nullif(sum (上年累计总销),0))/abs(nullif(sum (上年累计总销),0)) as 累计总销同比 from 周报数据 where 虹越年 = %s and 虹越周 = %s group by 1,2,3)';
begin
  return query execute format ('(select 模块编号,一级部门编号,二级部门编号,' || s || ' union all (select 模块编号,一级部门编号,999 as 二级部门编号,' || s || ' union all (select 模块编号,999 as 一级部门编号,999 as 二级部门编号,' || s || ' union all (select 999 as 模块编号,999 as 一级部门编号,999 as 二级部门编号,' || s || ' order by 模块编号,一级部门编号,二级部门编号',$2,$1,$2,$1,$2,$1,$2,$1);
end;
$proc$ language plpgsql stable;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 周报_趋势(int,int,int)
-- i: 模块编号,虹越周,虹越年,
-- o: 销售趋势
drop function if exists 周报_趋势 (int,int,int);
create or replace function
  周报_趋势 (int default 1,int default hyweek (date 'today') - 1,int default hyyear (date 'today'))
returns
  table (虹越周 int,外销 numeric (20,4),上年外销 numeric (20,4),日均外销 numeric (20,4),上年日均外销 numeric (20,4),外销同比 numeric (20,4)) as $$
select
  *,
  外销 / 虹越周 / 7 as 日均外销,
  上年外销 / 虹越周 / 7 as 上虹越年日均外销,
  外销 / nullif(上年外销,0) - 1 as 同比
from
  (select 虹越周,sum(sum(外销)) over (order by 虹越周) as 外销 from 周报数据 where 虹越年 = $3 and 虹越周 <= $2 and 模块编号 != $1 group by 1 ) t1
  full join ( select 虹越周,sum(sum(外销)) over (order by 虹越周) as 上年外销 from 周报数据 where 虹越年 = $3 - 1 and 模块编号 != $1 group by 1 ) t2 using (虹越周)
order by
  1
$$ language sql stable;

select * from 周报_本周();
select * from 周报_本年();
select * from 周报_趋势();
