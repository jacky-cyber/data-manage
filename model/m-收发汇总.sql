/**
 * 2015 cai
 *
 * 出入库业务与收发汇总表核对，暂不含成本调整单
 */

with w日期范围 as (
select '[2014-01-01, 2014-03-31]'::daterange as 范围
),w1 as (
select
  *
from
  (select 账套,仓库代码,sum(成本) as 销售 from 销售出库单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t1
  full join (select 账套,仓库代码,sum(实收金额) as 采购 from 外购入库单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t2 using (账套,仓库代码)
  full join (select 账套,仓库代码,sum(金额) as 其他出库 from 其他出库单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t3 using (账套,仓库代码)
  full join (select 账套,仓库代码,sum(金额) as 其他入库蓝 from 其他入库单 where 日期 <@ (select 范围 from w日期范围) and 金额 > 0 group by 1,2) t4 using (账套,仓库代码)
  full join (select 账套,仓库代码,sum(金额) as 其他入库红 from 其他入库单 where 日期 <@ (select 范围 from w日期范围) and 金额 < 0 group by 1,2) t5 using (账套,仓库代码)
  full join (select 账套,仓库代码,sum(盘盈金额) as 盘盈 from 盘盈单 where 日期 <@ (select 范围 from w日期范围)  group by 1,2) t6 using (账套,仓库代码)
  full join (select 账套,仓库代码,sum(盘亏金额) as 盘亏 from 盘亏单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t7 using (账套,仓库代码)
),w2 as (
select
  *
from
  (select 账套,调入仓库 as 仓库名称, sum(成本) as 调入 from 调拨单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t1
  full join (select 账套,调出仓库 as 仓库名称, sum(成本) as 调出 from 调拨单 where 日期 <@ (select 范围 from w日期范围) group by 1,2) t2 using (账套,仓库名称)
  full join (select 账套,仓库 as 仓库名称,sum(期初结存金额) as 期初 from 收发汇总表 where (会计期间||'.1')::date <@ (select 范围 from w日期范围) group by 1,2) t3 using (账套,仓库名称)
  full join (select 账套,仓库 as 仓库名称,sum(期末结存金额) as 期末 from 收发汇总表 where (会计期间||'.1')::date <@ (select 范围 from w日期范围) group by 1,2) t4 using (账套,仓库名称)
)
select
  *
from
  (select w1.*,仓库按代码.名称 as 仓库名称 from w1 left join 仓库按代码 on w1.仓库代码 = 仓库按代码.代码) t1
  full join w2 using (账套,仓库名称)
order by
  1,2;
