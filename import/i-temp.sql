/**
 * 2015 cai
 *
 * 导入临时文件（结账前）
 */

-- 用于销售周报
delete from 销售出库单 where date_trunc('month',日期)::date in ('2015-06-01');
select dataupdate('销售出库单','sale','20150628t');

-- 用于周报客流
delete from 零售单客户 where date_trunc('month',日期)::date in ('2015-05-01','2015-06-01');
select dataupdate('零售单客户','retail_c','20150531t');
select dataupdate('零售单客户','retail_c','20150607t');
select dataupdate('零售单客户','retail_c','20150614t');
select dataupdate('零售单客户','retail_c','20150621t');
select dataupdate('零售单客户','retail_c','20150628t');

delete from 零售单 where date_trunc('month',日期)::date in ('2015-05-01');
select dataupdate('零售单','retail','20150531t');

-- 5月门店运营数据
select dataupdate('销售出库单', 'sale','201505');
select dataupdate('其他出库单', 'other_out','201505');
select dataupdate('收发汇总表', 'warehouse','201505');
delete from 盘盈单 where 日期 >= '2015-05-01';
delete from 盘亏单 where 日期 >= '2015-05-01';
select copyk3('盘盈单','overage/hongan-201505');
select copyk3('盘盈单','overage/huicai-201505');
select copyk3('盘亏单','overage/hongan-201505');
select copyk3('盘亏单','overage/huicai-201505');

-- 产品成本
-------------------------------------------------------------------------------------------------------------------------------------------
drop table if exists 产品成本;
create table 产品成本 as
select
  distinct on (产品长代码)
  产品长代码,
  账套,
  单位成本
from
  (select 产品长代码,账套,sum(成本) / nullif(sum(实发数量),0) as 单位成本 from 销售出库单 where 日期 <= '2015-04-30' group by 1,2) t
where
  单位成本 > 0
order by
  产品长代码,
  单位成本;

-- 产品分期成本
-------------------------------------------------------------------------------------------------------------------------------------------
drop table if exists 产品分期成本;
create table 产品分期成本 as
select
  distinct on (产品长代码,年月)
  产品长代码,
  年月,
  账套,
  单位成本
from
  (select 产品长代码,date_trunc('month',日期)::date as 年月,账套,sum(成本) / nullif(sum(实发数量),0) as 单位成本 from 销售出库单 where 日期 <= '2015-02-28' group by 1,2,3) t
where
  单位成本 > 0
order by
  产品长代码,
  年月,
  单位成本;
