/**
 * 2015 cai
 *
 * 门店月度运营数据之SKU
 */

with w日期范围 as (
select
  '[2015-01-01,2015-08-31]'::daterange as 范围
), w0_1 as (
select
  部门.二级部门编号,
  日历.月,
  t1.产品长代码
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
where
  t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and (select 范围 from w日期范围) @> t1.日期
  and 部门.一级部门名称 = '绿植零批运营部'
group by
  1,2,3
),w0_2 as (
select
  仓库按名称.二级部门编号,
  split_part(t1.会计期间,'.',2)::int as 月,
  t1.产品长代码
from
  收发汇总表 t1
  inner join 仓库按名称 on t1.仓库 = 仓库按名称.名称
where
  (select 范围 from w日期范围) @> (t1.会计期间 || '.01')::date
  and 仓库按名称.一级部门名称='绿植零批运营部'
  and t1.仓库 not in ('昆山虹越（农博园）','昆山虹越（花木城）','千灯店卖场')
group by
  1,2,3
),
w1_1 as (select 二级部门编号, 0 as 月, count(distinct 产品长代码) as 销售sku from w0_1 group by 1,2),
w1_2 as (select 二级部门编号, 0 as 月, count(distinct 产品长代码) as 库存sku from w0_2 group by 1,2),
w2_1 as (select 0 as 二级部门编号, 月, count(distinct 产品长代码) as 销售sku from w0_1 group by 1,2),
w2_2 as (select 0 as 二级部门编号, 月, count(distinct 产品长代码) as 库存sku from w0_2 group by 1,2),
w3_1 as (select 0 as 二级部门编号, 0 as 月, count(distinct 产品长代码) as 销售sku from w0_1  group by 1,2),
w3_2 as (select 0 as 二级部门编号, 0 as 月, count(distinct 产品长代码) as 库存sku from w0_2 group by 1,2)
select
  *
from
  (select * from w1_1 union all select * from w2_1 union all select * from w3_1 ) t1
  full join (select * from w1_2 union all select * from w2_2 union all select * from w3_2) t2 using (二级部门编号, 月)
order by
  1,2,3;
