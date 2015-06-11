/**
 * 2015 cai
 *
 * 商品销售排行
 */

with w1 as (
select
  部门.实名,
  split_part(商品.全名, '_', 4) as 商品类别,
  sum(t1.未税金额) as 销售金额,
  sum(t1.实发数量) as 销售数量
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 商品 on t1.产品长代码= 商品.代码
where
  t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and 部门.一级部门名称 = '门店运营部'
  and t1.日期 between '2014-04-01' and '2014-06-30'
  and 商品.产品名称 !~ '组合盆栽|zupenfei|freight'
group by
  1,2
), w2 as (
select
  实名,
  商品类别,
  rank() over (partition by 实名 order by 销售金额 desc, 销售数量 desc) as 金额排行, 
  rank() over (partition by 实名 order by 销售数量 desc, 销售金额 desc) as 数量排行, 
  w1.销售数量,
  w1.销售金额,
  w1.销售金额 / (sum(销售金额) over (partition by w1.实名)) as 销售金额占比
from
  w1
)
select
  *
from
  w2
where
  金额排行 <= 20
order by
  实名,
  金额排行;
