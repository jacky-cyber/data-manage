/**
 * 2015 cai
 *
 * 导入临时文件（结账前）
 */

-- 用于销售周报
delete from 销售出库单 where date_trunc('month',日期)::date in ('2015-09-01');
select dataupdate('销售出库单','sale','20150920t');

-- 用于周报客流
delete from 零售单客户 where date_trunc('month',日期)::date in ('2015-09-01');
select dataupdate('零售单客户','retail_c','20150920t');



-- 用于会员日
delete from 零售单 where date_trunc('month',日期)::date in ('2015-09-01');
select dataupdate('零售单','retail','20150916t');

delete from 卡流水 where 业务日期 >= '2015-09-01';
select cardflowupdate('20150916t');

drop table if exists 网店销售;
create table 网店销售(
  年 int,
  月 int,
  网店类别 varchar(255),
  网店 varchar(255),
  销售额 numeric(20,4),
  成交人数 numeric(20,4)
);

select copygbk('网店销售','other/ali_sale.csv');
select copygbk('网店销售','other/huacai_sale.csv');

drop table if exists 网店周销售;
create table 网店周销售(
  年 int,
  周 int,
  网店类别 varchar(255),
  网店 varchar(255),
  销售额 numeric(20,4),
  成交人数 numeric(20,4)
);

select copygbk('网店周销售','other/ali_week_sale.csv');
select copygbk('网店周销售','other/huacai_week_sale.csv');
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
  (select 产品长代码,账套,sum(成本) / nullif(sum(实发数量),0) as 单位成本 from 销售出库单 where 日期 between '2014-01-01' and '2015-07-31' group by 1,2) t
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
