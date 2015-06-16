/**
 * 2015 cai
 *
 * 门店月度销售库存分布
 */

with w日期范围 as (
select
  '[2015-05-01,2015-05-31]'::daterange as 范围
), w1 as (
select
  部门.实名,
  商品.部门 as 商品所属部门,
  sum(t1.未税金额) as 销售金额
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 商品 on t1.产品长代码 = 商品.代码
where
  部门.一级部门名称 = '门店运营部'
  and t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and (select 范围 from w日期范围) @> t1.日期
group by
  1,2
), w2 as (
select
  仓库按名称.实名,
  商品.部门 as 商品所属部门,
  (coalesce(sum(t1.期初结存金额),0) + coalesce(sum(t1.期末结存金额),0)) / 2 as 门店库存
from
  收发汇总表 t1
  inner join 仓库按名称 on t1.仓库 = 仓库按名称.名称
  left join 商品 on t1.产品长代码 = 商品.代码
where
  仓库按名称.一级部门名称 = '门店运营部'
  and (select 范围 from w日期范围) @> (t1.会计期间 || '.01')::date
group by
  1,2
)
select
  *
from
  w1
  full join w2 using(实名,商品所属部门)
order by
  1,2;
