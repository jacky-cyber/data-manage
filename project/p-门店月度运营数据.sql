/**
 * 2015 cai
 *
 * 门店月度运营数据统计报告
 */

with w日期范围 as (
select
  '[2015-01-01,2015-08-31]'::daterange as 范围
),/* w销售_2014 as (
select
  部门.二级部门编号,
  日历.月,
  sum(case when t1.单据编号 ~* '^rth|^dx' then t1.未税金额 end)/10000 as 前台销售收入,
  sum(case when t1.单据编号 ~* '^rth|^dx' then t1.实发数量 end)/10000 as 前台实发数量,
  sum(case when t1.单据编号 ~* '^rth|^dx' then t1.成本 end)/10000 as 前台销售成本,
  count(distinct case when t1.单据编号 ~* '^rth|^dx' then t1.产品长代码 end) as 前台销售sku,
  sum(case when t1.单据编号 ~* '^rth|^dx' then t1.实发数量*t1.建议零售价/"1+税率" end)/10000 as 前台原价销售收入,
  sum(case when t1.单据编号 !~* '^rth|^dx' then t1.未税金额 end)/10000 as 后台销售收入,
  sum(case when t1.单据编号 !~* '^rth|^dx' then t1.实发数量 end)/10000 as 后台实发数量,
  sum(case when t1.单据编号 !~* '^rth|^dx' then t1.成本 end)/10000 as 后台销售成本,
  count(distinct case when t1.单据编号 !~* '^rth|^dx' then t1.产品长代码 end) as 后台销售sku,
  sum(case when t1.单据编号 !~* '^rth|^dx' then t1.实发数量*t1.建议零售价/"1+税率" end)/10000 as 后台原价销售收入,
  sum(t1.未税金额)/10000 as 销售收入,
  sum(t1.实发数量)/10000 as 实发数量,
  sum(t1.成本)/10000 as 销售成本,
  count(distinct t1.产品长代码) as 销售sku,
  sum(t1.实发数量*t1.建议零售价/"1+税率" )/10000 as 原价销售收入
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
where
  部门.一级部门名称 = '门店运营部'
  and t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and (select 范围 from w日期范围) @> t1.日期
  and t1.产品长代码 != '8.8.4.002.88888'
group by
  1,2
), */ w销售_2015 as (
select
  部门.二级部门编号,
  日历.月,
  sum(t1.未税金额)/10000 as 销售金额,
  sum(t1.成本)/10000 as 销售成本,
  sum(coalesce(t1.实发数量*t2.单位成本,t1.成本))/10000 as 产品销售成本,
  count(distinct t1.产品长代码) as 销售sku,
  sum(t1.实发数量*t1.建议零售价/"1+税率")/10000 as 原价销售收入,
  sum(t1.实发数量) as 销售数量
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 产品成本 t2 on t1.产品长代码 = t2.产品长代码
  left join 商品 on t1.产品长代码 = 商品.代码
  left join 客户 on t1.客户代码 = 客户.代码
where
  部门.一级部门名称 = '门店运营部'
  and t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and (select 范围 from w日期范围) @> t1.日期
  --and t1.产品长代码 != '8.8.4.002.88888'
  and not (t1.客户代码 in ('021.9998','021.9999') and 部门.二级部门名称 = '浦东宣桥店')
  and not (客户.是否商超客户)
group by
  1,2
), /* w损耗_2014 as (
select
  部门.二级部门编号,
  日历.月,
  sum(t1.金额)/10000 as 损耗金额
from
  其他出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
where
  部门.一级部门名称 = '门店运营部'
  and t1.出库类型 = '损耗'
  and (select 范围 from w日期范围) @> t1.日期
group by
  1,2
),  */ w损耗_2015 as (
select
  仓库按代码.二级部门编号,
  日历.月,
  sum(t1.金额)/10000 as 损耗成本,
  sum(coalesce(t1.数量*t2.单位成本,t1.金额))/10000 as 产品损耗成本
from
  其他出库单 t1
  inner join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 日历 on t1.日期 = 日历.日期
  left join 产品成本 t2 on t1.产品长代码 = t2.产品长代码
where
  仓库按代码.一级部门名称 = '门店运营部'
  and (t1.出库类型 = '损耗' or (lower(t1.单据编号) like 'dx%' and t1.出库类型 is null))
  and (select 范围 from w日期范围) @> t1.日期
group by
  1,2
), w盘损 as (
select
  仓库按代码.二级部门编号,
  日历.月,
  sum(t1.盘亏金额)/10000 as 盘亏成本,
  sum(coalesce(t1.盘亏数量*t2.单位成本,t1.盘亏金额))/10000 as 产品盘亏成本
from
  (select 日期,盘亏数量,盘亏金额,仓库代码,产品长代码 from 盘亏单 union all select 日期,-盘盈数量,-盘盈金额,仓库代码,产品长代码 from 盘盈单) t1
  inner join 仓库按代码 on t1.仓库代码 = 仓库按代码.代码
  left join 日历 on t1.日期 = 日历.日期
  left join 产品成本 t2 on t1.产品长代码 = t2.产品长代码
where
  仓库按代码.一级部门名称 = '门店运营部'
  and not (t1.产品长代码 = '8.8.4.002.88888' and (t1.日期 between '2014-10-01' and '2014-10-31'))
  and (select 范围 from w日期范围) @> t1.日期
group by
  1,2
),w库存 as (
select
  仓库按名称.二级部门编号,
  split_part(t1.会计期间,'.',2)::int as 月,
  (coalesce(sum(t1.期初结存金额),0) + coalesce(sum(t1.期末结存金额),0))/20000 as 库存,
  (coalesce(sum(coalesce(t1.期末结存数量*t2.单位成本,t1.期末结存金额)),0) + coalesce(sum(coalesce(t1.期初结存数量*t2.单位成本,t1.期初结存金额)),0))/20000 as 产品库存,
  count(distinct t1.产品长代码) as 库存sku
from
  收发汇总表 t1
  inner join 仓库按名称 on t1.仓库 = 仓库按名称.名称
  left join 产品成本 t2 on t1.产品长代码 = t2.产品长代码
where
  仓库按名称.一级部门名称 = '门店运营部'
  and (select 范围 from w日期范围) @> (t1.会计期间 || '.01')::date
group by
  1,2
), w客流 as (
select
  机构.二级部门编号,
  日历.月,
  count (distinct t1.单据编号) as 客流量
from
  零售单客户 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join 日历 on t1.日期 = 日历.日期
where
  机构.一级部门名称 = '门店运营部'
  and coalesce(lower(客户业务类型),'') not in (select 代码 from 客户业务类型)
  and not (t1.分店 = '海宁国际花卉城' and t1.日期 <= '2014-12-24')
  and (select 范围 from w日期范围) @> t1.日期
group by
  1,2
), w编号 as (
select
  distinct
  二级部门编号,
  实名 as 部门,
  generate_series(1,12,1) as 月
from
  部门
where
  一级部门名称 = '门店运营部'
)
select
  *
from
  w编号
  full join w销售_2015 using (二级部门编号,月)
  full join w损耗_2015 using (二级部门编号,月)
  full join w盘损 using (二级部门编号,月)
  full join w库存 using (二级部门编号,月)
  full join w客流 using (二级部门编号,月)
order by
  1,2,3;
