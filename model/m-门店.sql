/**
 * 2015 cai
 *
 * 门店数据统计模板
 */

-- 销售
---------------------------------------------------------------------------------------------------------------------------------
select
  部门.二级部门编号,
  部门.实名,
  日历.年,
  sum(t1.未税金额) as 销售金额,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
where
  部门.一级部门名称 = '门店运营部'
  and t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and not (t1.客户代码 in ('021.9998','021.9999') and 部门.二级部门名称 = '浦东宣桥店')
  and (not coalesce(客户.是否商超客户,false))
group by
  1,2,3
order by
  1,2,3;

-- 门店调拨入库
---------------------------------------------------------------------------------------------------------------------------------
select
  仓库按名称.二级部门编号,
  仓库按名称.实名,
  日历.虹越年,
  sum(t1.成本) as 调拨成本
from
  调拨单 t1
  inner join 仓库按名称 on t1.调入仓库 = 仓库按名称.名称
  left join 仓库按名称 as 仓库按名称clone on t1.调出仓库 = 仓库按名称clone.名称
  left join 日历 on t1.日期 = 日历.日期
where
  仓库按名称.一级部门名称 = '门店运营部'
  and 仓库按名称.实名 != 仓库按名称clone.实名
group by
  1,2,3
order by
  1,2,3;

-- 门店外购入库
---------------------------------------------------------------------------------------------------------------------------------
select
  部门.二级部门编号,
  部门.实名,
  日历.虹越年,
  sum(t1.实收金额) as 外购成本
from
  外购入库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
where
  部门.一级部门名称 = '门店运营部'
  and (t1.日期 <= '2014-06-30' or 部门.实名 = '浦东宣桥店')
  and t1.单据编号 not in ('030032113','030032114','030032116','030032117','030032119','030032120','030032121','030032122','030033768','030033939')
group by
  1,2,3
order by
  1,2,3;

-- 盘点
---------------------------------------------------------------------------------------------------------------------------------
select
  仓库按代码.二级部门编号,
  仓库按代码.实名,
  日历.年,
  sum(t1.盘亏数量) as 盘亏数量,
  sum(t1.盘亏金额) as 盘亏成本
from
  (select 日期,盘亏数量,盘亏金额,仓库代码,产品长代码 from 盘亏单 union all select 日期,-盘盈数量,-盘盈金额,仓库代码,产品长代码 from 盘盈单) t1
  inner join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 日历 on t1.日期 = 日历.日期
where
  仓库按代码.一级部门名称 = '门店运营部'
  and not (t1.产品长代码 = '8.8.4.002.88888' and (t1.日期 between '2014-10-01' and '2014-10-31'))
group by
  1,2,3
order by
  1,2,3;

-- 损耗算法2014.6前
---------------------------------------------------------------------------------------------------------------------------------
select
  部门.二级部门编号,
  部门.实名,
  日历.年,
  sum(t1.金额) as 损耗成本
from
  其他出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
where
  部门.一级部门名称 = '门店运营部'
  and t1.出库类型 = '损耗'
group by
  1,2,3
order by
  1,2,3;

-- 损耗算法2014.6后
---------------------------------------------------------------------------------------------------------------------------------
select
  仓库按代码.二级部门编号,
  仓库按代码.实名,
  日历.年,
  sum(t1.金额) as 损耗成本
from
  其他出库单 t1
  inner join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 日历 on t1.日期 = 日历.日期
where
  仓库按代码.一级部门名称 = '门店运营部'
  and (t1.出库类型 = '损耗' or (lower(t1.单据编号) like 'dx%' and t1.出库类型 is null))
group by
  1,2,3
order by
  1,2,3;

-- 客流（不含预定金）
---------------------------------------------------------------------------------------------------------------------------------
select
  机构.二级部门编号,
  机构.实名,
  日历.年,
  count (distinct t1.单据编号) as 客流量
from
  零售单明细 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join 日历 on t1.日期 = 日历.日期
where
  机构.一级部门名称 = '门店运营部'
  and not (t1.分店 = '海宁国际花卉城' and t1.日期 <= '2014-12-24')
  and t1.产品长代码 != '9.6.7.021.00001'
  and t1.单据编号 not in (select 单据编号 from 零售单客户 where array[lower(客户业务类型)] <@ any(select array_agg(代码) from 客户业务类型))
group by
  1,2,3
order by
  1,2,3;

-- 客流（含预定金）
---------------------------------------------------------------------------------------------------------------------------------
select
  机构.二级部门编号,
  机构.实名,
  日历.年,
  count (distinct t1.单据编号) as 客流量
from
  零售单客户 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join 日历 on t1.日期 = 日历.日期
where
  机构.一级部门名称 = '门店运营部'
  and coalesce(lower(客户业务类型),'') not in (select 代码 from 客户业务类型)
  and not (t1.分店 = '海宁国际花卉城' and t1.日期 <= '2014-12-24')
group by
  1,2,3
order by
  1,2,3;

-- 月均库存
---------------------------------------------------------------------------------------------------------------------------------
select
  仓库按名称.二级部门编号,
  仓库按名称.实名,
  (coalesce(sum(t1.期初结存金额),0) + coalesce(sum(t1.期末结存金额),0)) / 2 as 平均库存
from
  收发汇总表 t1
  inner join 仓库按名称 on t1.仓库 = 仓库按名称.名称
where
  仓库按名称.一级部门名称 = '门店运营部'
  and t1.会计期间 = '2015.4'
group by
  1,2
order by
  1,2;
