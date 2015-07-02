/**
 * 2015 cai
 *
 * 集团全段销售利润
 */

drop table if exists t日期范围,t日期范围sc;
create temp table t日期范围 as select '[2014-01-01,2014-12-31]'::daterange as 范围;
create temp table t日期范围sc as select '[2013-09-01,2014-12-31]'::daterange as 范围;

-- 整体
with w110 as ( -- 非商超销售预处理
select
  case
    when t1.客户代码 = '999.0078.24' and 部门.实名 = '研究院' then '萌吖吖种子（淘宝）店'
    when t1.客户代码 = '999.0089' and 部门.实名 = '花卉城项目部' then '海宁国际花卉城（淘宝）店'
    when (t1.客户代码 in ('999.0076','999.0066') or (t1.客户代码 = '999.0167' and t1.账套 = '虹安')) and 部门.实名 = '多肉项目部' then '多肉时光（淘宝）店'
    when t1.客户代码 = '021.9999' and 部门.实名 = '浦东宣桥店' then '源怡种苗（淘宝）店'
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
    else 部门.实名
  end as 实名,
  t1.产品长代码,
  sum(t1.实发数量) as 销售数量,
  sum(t1.未税金额) as 销售金额,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  left join 部门 on t1.部门 = 部门.名称
where
  t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and t1.客户代码 not in (select 代码 from 客户 where 是否商超客户)
  and (select 范围 from t日期范围) @> t1.日期
group by
  1,2
), w11 as ( -- 非商超销售
select
  case when t2.一级部门名称 in ('门店运营部','绿植零批运营部','电商运营部') then t2.一级部门名称 else '产品部' end as 一级部门名称,
  case when t2.一级部门名称 in ('门店运营部','绿植零批运营部','电商运营部') then t2.实名 else '产品部' end as 实名,
  t1.产品长代码,
  sum(t1.销售数量) as 销售数量,
  sum(t1.销售金额) as 销售金额,
  sum(t1.销售成本) as 销售成本
from
  w110 t1
  left join (select distinct 实名,一级部门名称 from 部门) t2 on t1.实名 = t2.实名
group by
  1,2,3
), w12 as ( -- 非商超仓库的其他出库，电商按仓库+部门
select
  case when 仓库按代码.一级部门名称 in ('门店运营部','绿植零批运营部','电商运营部') then 仓库按代码.一级部门名称 when 部门.一级部门名称 in ('电商运营部') then '电商运营部' else '产品部' end as 一级部门名称,
  case when 仓库按代码.一级部门名称 in ('门店运营部','绿植零批运营部','电商运营部') then 仓库按代码.实名 when 部门.一级部门名称 in ('电商运营部') then 部门.实名 else '产品部' end as 实名,
  t1.产品长代码,
  sum(t1.数量) as 其他出库数量,
  sum(t1.金额) as 其他出库成本
from
  其他出库单 t1
  left join 部门 on t1.部门 = 部门.名称
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
where
  (select 范围 from t日期范围) @> t1.日期
  and coalesce(仓库按代码.实名,'') != '商超运营部'
group by
  1,2,3
),w13 as ( -- 盘损（商超以产品部门其他出库形式）
select
  case when 仓库按代码.一级部门名称 in ('门店运营部','绿植零批运营部') then 仓库按代码.一级部门名称 else '产品部' end as 一级部门名称,
  case when 仓库按代码.一级部门名称 in ('门店运营部','绿植零批运营部') then 仓库按代码.实名 else '产品部' end as 实名,
  t1.产品长代码,
  sum(盘亏数量) as 盘亏数量,
  sum(盘亏金额) as 盘亏金额
from
  (select 日期,盘亏数量,盘亏金额,仓库代码,产品长代码 from 盘亏单 union all select 日期, -盘盈数量, -盘盈金额, 仓库代码,产品长代码 from 盘盈单) t1
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
where
  (select 范围 from t日期范围) @> t1.日期
  and not (t1.产品长代码 = '8.8.4.002.88888' and (t1.日期 between '2014-10-01' and '2014-10-31'))
group by
  1,2,3
), wc0 as (  -- 产品单位成本预处理
select
  产品长代码,
  账套,
  sum(成本) / nullif(sum(实发数量),0) as 单位成本
from
  销售出库单
where
  日期 < (select upper(范围) from t日期范围)
group by
  1,2
), wc as ( -- 产品单位成本
select
  distinct on (产品长代码)
  产品长代码,
  单位成本
from
  wc0
where
  单位成本 > 0
order by
  产品长代码,
  单位成本
),wa as (  -- 非商超结果
select
  t1.一级部门名称,
  t1.实名,
  t3.部门 as 商品所属部门,
  sum(t1.销售金额) as 销售金额,
  sum(case when t1.销售数量*t2.单位成本 is not null then t1.销售数量*t2.单位成本 else t1.销售成本 end) as 销售成本,
  coalesce(sum(case when t1.其他出库数量*t2.单位成本 is not null then t1.其他出库数量*t2.单位成本 else t1.其他出库成本 end),0) + coalesce(sum(case when t1.盘亏数量*t2.单位成本 is not null then t1.盘亏数量*t2.单位成本 else t1.盘亏金额 end),0) as 其他出库成本
from
  (w11 t1
  full join w12 using(一级部门名称,实名,产品长代码)
  full join w13 using(一级部门名称,实名,产品长代码)) t1
  left join wc t2 on t1.产品长代码 = t2.产品长代码
  left join 商品 t3 on t1.产品长代码 = t3.代码
group by
  1,2,3
),w41 as (  -- 商超销售额
select
  substring(客户.名称,(select 模式 from 商超名正则)) as 实名,
  t1.产品长代码,
  sum(t1.实发数量) as 销售数量,
  sum(t1.未税金额) as 销售金额,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  left join 客户 on t1.客户代码 = 客户.代码
  left join 日历 on t1.日期 = 日历.日期
where
  客户.是否商超客户
  and (select 范围 from t日期范围sc) @> t1.日期
  and ((t1.账套 = '浙江' and 日历.年 <= 2014) or (t1.账套 = '虹安' and 日历.年 = 2015))
group by
  1,2
),w42 as (  -- 产品成本在销给商超的账套
select
  实名,
  产品长代码,
  sum(销售成本) as 销售成本
from
  w41
where
  产品长代码 in (select 代码 from 商品 where 部门 in ('萌吖吖产品部','商超运营部','研究院'))
group by
  1,2
),w43 as (  -- 产品成本在非丽彩非商超账套
select
  substring(仓库按代码.名称 || t1.摘要,(select 模式 from 商超名正则)) as 实名,
  t1.产品长代码,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 日历 on t1.日期 = 日历.日期
where
  ((t1.客户代码 = '573.495' and 日历.年 <= 2014) or (t1.客户代码 = '573.527' and 日历.年 = 2015))
  and 账套 != '丽彩'
  and ((仓库按代码.名称 || t1.摘要) ~ (select 模式 from 商超名正则))
  and t1.摘要 !~ '大丰'
  and (select 范围 from t日期范围sc) @> t1.日期
  and t1.产品长代码 not in (select 代码 from 商品 where 部门 = '萌吖吖产品部')
group by
  1,2
), w44 as (  -- 产品成本在丽彩账套
select
  t1.实名,
  t1.产品长代码,
  sum(t1.销售数量*t2.单位成本) as 销售成本
from
  w41 t1
  left join (
    select
      case 产品长代码
        when '8.3.2.101.00203' then '9.3.2.201.00001'
        when '8.3.2.101.00501' then '9.3.2.201.00002'
        when '8.3.2.101.00601' then '9.3.2.201.00004'
      else 产品长代码 end as 产品长代码,
      sum(成本)/sum(实发数量) as 单位成本
    from
      销售出库单
    where
      账套 = '丽彩'
      and (产品长代码 in (select distinct 产品长代码 from w41) or (产品长代码 in ('8.3.2.101.00203','8.3.2.101.00501','8.3.2.101.00601')))
      and (select 范围 from t日期范围sc) @> 日期
    group by
      1
  ) t2 on t1.产品长代码 = t2.产品长代码
where
  t1.产品长代码 in (select 代码 from 商品 where 部门 = '丽彩盆栽生产部')
group by
  1,2
), w45 as (  -- 商超仓库的其他出库
select
  substring(仓库按代码.名称,(select 模式 from 商超名正则)) as 实名,
  t1.产品长代码,
  sum(t1.金额) as 其他出库成本
from
  其他出库单 t1
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
where
  仓库按代码.名称 ~ (select 模式 from 商超名正则)
  and (select 范围 from t日期范围sc) @> t1.日期
group by
  1,2
), w40 as (  -- 商超结果
select
  '商超运营部'::text as 一级部门名称,
  实名,
  t2.部门 as 商品所属部门,
  sum(t1.销售金额) as 销售金额,
  sum(t1.销售成本) as 销售成本,
  sum(t1.其他出库成本) as 其他出库成本
from
  ((select 实名,产品长代码,sum(销售金额) as 销售金额 from w41 group by 1,2) t1
  full join (select * from w42 union all select * from w43 union all select * from w44) t2 using (实名,产品长代码)
  full join w45 t3 using(实名,产品长代码)) t1
  left join 商品 t2 on t1.产品长代码 = t2.代码
group by
  1,2,3
)
select * from wa union all select * from w40;
