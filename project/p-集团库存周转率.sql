/**
 * 2015 cai
 *
 * 集团各部门库存周转率
 */

with w日期范围 as (
select '[2015-01-01, 2015-03-31]'::daterange as 范围
), w1_1 as (
select
  t1.账套,
  t1.仓库代码,
  部门.一级部门名称,
  部门.二级部门名称,
  sum(coalesce(t1.销售成本,0) + coalesce(t1.采购成本,0) + coalesce(t1.生产成本,0)) as 指标
from
  ((select 账套,仓库代码,部门,sum(成本) as 销售成本 from 销售出库单 where 日期 <@ (select 范围 from w日期范围) group by 1,2,3) t1
  full join (select 账套,仓库代码,部门,sum(实收金额) as 采购成本 from 外购入库单 where 日期 <@ (select 范围 from w日期范围) group by 1,2,3) t2 using(账套,仓库代码,部门)
  full join  (select 账套,仓库代码,部门,sum(金额) as 生产成本 from 其他入库单 where 金额 > 0 and  日期 <@ (select 范围 from w日期范围) group by 1,2,3) t3 using(账套,仓库代码,部门)) t1
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 部门 on t1.部门 = 部门.名称
where
  仓库按代码.二级部门名称 is null
  and not (t1.账套 = '浙江' and ((t1.部门 in ('草业事业部','肥料介质部','海宁国美','花卉事业部','金五月销售部','丽彩销售部','温室花卉部','温室资材部','浙江丽彩','总部苗圃')) or (t1.部门 in ('盆器饰品部'))))
  and not(t1.账套 = '杭州' and t1.部门 in ('草业事业部'))
  and not(t1.部门 = '长安苗圃' and t1.账套 != '国美')
group by
  1,2,3,4
), w1_2 as (
select
  账套,
  仓库代码,
  一级部门名称,
  sum(指标)/nullif((sum(sum(指标)) over (partition by 账套,仓库代码)),0) as 占比
from
  w1_1
group by
  1,2,3
), w1_3 as (
select
  账套,
  仓库代码,
  二级部门名称,
  sum(指标)/nullif((sum(sum(指标)) over (partition by 账套,仓库代码)),0) as 占比
from
  w1_1
group by
  1,2,3
), w1 as (  -- 仓库对应一、二级部门
select
  账套,
  仓库代码,
  一级部门名称,
  二级部门名称
from
  (select * from w1_2 where 占比 >= 0.8) t1
  left join (select * from w1_3 where 占比 >= 0.8) t2 using (账套, 仓库代码)
), w2 as (  -- 各部门销售成本
select
  t1.账套 || '_' || 仓库按代码.名称 as 库存单元,
  coalesce(仓库按代码.一级部门名称, w1.一级部门名称, '一级部门共用仓库') as 仓库对应一级部门名称,
  coalesce(仓库按代码.二级部门名称, w1.二级部门名称, '二级部门共用仓库') as 仓库对应二级部门名称,
  t1.产品长代码,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  left join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join w1 on t1.账套 = w1.账套 and t1.仓库代码 = w1.仓库代码
  left join 日历 on t1.日期 = 日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
  left join 部门 on t1.部门 = 部门.名称
where
  t1.日期 <@ (select 范围 from w日期范围)
  and ((not (t1.账套 = '浙江' and ((t1.部门 in ('草业事业部','肥料介质部','海宁国美','花卉事业部','金五月销售部','丽彩销售部','温室花卉部','温室资材部','浙江丽彩','总部苗圃')) or (t1.部门 in ('盆器饰品部') and t1.日期 >= '2014-01-01')))) or (客户.是否商超客户))
  and ((not coalesce(客户.是否商超客户,false)) or (t1.账套 = '浙江' and 日历.年 = 2014) or (t1.账套 = '虹安' and 日历.年 = 2015))
  and not(t1.账套 = '杭州' and t1.部门 in ('草业事业部') and t1.日期 >= '2014-01-01')
  and (not(coalesce(t1.摘要,'') ~ '转库|转换仓库|从浙江虹越转移至杭州虹越|转仓|库存转移|移库|西溪店转虹安|转账套出库|库存转到产品部门') or t1.部门 = '国际业务部')
  and not(部门.一级部门名称 = '门店运营部' and t1.日期 between '2014-12-29' and '2014-12-31' and coalesce(t1.摘要,'') ~ '退回')
  and not(t1.部门 = '长安苗圃' and t1.账套 != '国美')
group by
  1,2,3,4
), w3 as (  -- 各部门库存
select
  t1.账套 || '_' || t1.仓库 as 库存单元,
  coalesce(仓库按名称.一级部门名称, t2.一级部门名称, '一级部门共用仓库') as 仓库对应一级部门名称,
  coalesce(仓库按名称.二级部门名称, t2.二级部门名称, '二级部门共用仓库') as 仓库对应二级部门名称,
  t1.产品长代码,
  (coalesce(sum(t1.期初结存金额),0) + coalesce(sum(t1.期末结存金额),0)) / count( distinct t1.会计期间)/2 as 平均库存
from
  收发汇总表 t1
  left join 仓库按名称 on t1.仓库 = 仓库按名称.名称
  left join (select w1.*, 仓库按代码.名称 from w1 left join 仓库按代码 on w1.仓库代码 = 仓库按代码.代码) t2 on t1.账套 = t2.账套 and t1.仓库 = t2.名称
where
  (t1.会计期间 || '.01')::date <@ (select 范围 from w日期范围)
group by
  1,2,3,4
)
select
  库存单元,
  仓库对应一级部门名称,
  仓库对应二级部门名称,
  sum(销售成本) as 销售成本,
  sum(平均库存) as 平均库存,
  count(distinct case when 销售成本 is not null then 产品长代码 else null end) as 销售sku,
  count(distinct case when 平均库存 is not null then 产品长代码 else null end) as 库存sku
from
  w2
  full join w3 using (库存单元, 仓库对应一级部门名称, 仓库对应二级部门名称, 产品长代码)
group by
  1,2,3
order by
  1,2,3;
