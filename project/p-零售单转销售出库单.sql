with w1 as (
-- 基本表1
select
  机构.实名,
  --case lower(t2.客户业务类型) when 'ziyongcaozuo' then '领用' when 'zupencaozuo' then '组盆' when 'baosuncaozuo' then '损耗' else case t1.卡类别 when '25' then '损耗' else '销售' end end as 销售类型,
  case lower(t2.客户业务类型) when 'ziyongcaozuo' then '领用' when 'zupencaozuo' then '组盆' when 'baosuncaozuo' then '损耗'  else '销售' end as 销售类型,
  t1.单据编号,
  t1.卡类别,
  t1.卡号,
  花卡.折扣 as 花卡折扣,
  sum(t1.结算金额) as 结算金额
from
  零售单 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join (select distinct 单据编号,客户业务类型 from 零售单客户 where array[lower(客户业务类型)] <@ any(select array_agg(代码) from 客户业务类型)) t2 on t1.单据编号 = t2.单据编号
  left join 花卡 on t1.卡号 = 花卡.卡号
where
  机构.一级部门名称 = '绿植零批运营部'
  and t1.日期 between '2015-01-01' and '2015-07-31'
  and coalesce(t1.结算方式,'') != '抹零'
group by
  1,2,3,4,5,6
), w2 as (
-- 基本表2
select
  t1.单据编号,
  --1 - coalesce(sum(case when t1.产品长代码 = '9.6.7.021.00001' then 实付金额 end)/sum(实付金额),0) as 非预定金占比,
  min(case when t1.产品长代码 = '9.6.7.021.00001' then 0 else 1 end) as 非预定金占比
from
  零售单明细 t1
  inner join 机构 on t1.分店 = 机构.名称
where
  机构.一级部门名称 = '绿植零批运营部'
  and t1.日期 between '2015-01-01' and '2015-07-31'
group by
  1
), w3 as (
-- 非销售
select
  实名,
  sum(case 销售类型 when '领用' then 结算金额 end) as 领用,
  sum(case 销售类型 when '组盆' then 结算金额 end) as 组盆,
  sum(case 销售类型 when '损耗' then 结算金额 end) as 损耗
from
  w1
where
  销售类型 != '销售'
group by
  1
), w4 as (
-- 销售
select
  w1.实名,
  sum(w1.结算金额*(1 - w2.非预定金占比)) as 预定金,
  sum(case when w1.卡类别 = '23' then w1.结算金额*w2.非预定金占比 end) as 非预定金_抵价券,
  sum(case when w1.卡类别 = '22' then w1.结算金额*w2.非预定金占比*coalesce(1 - w1.花卡折扣,0) end) as 非预定金_花卡折扣金额,
  sum(case when coalesce(w1.卡类别,'') != '23' then w1.结算金额*w2.非预定金占比 * coalesce(w1.花卡折扣,1) end) as 非预定金_销售额
from
  w1
  left join w2 on w1.单据编号 = w2.单据编号
where
  销售类型 = '销售'
group by
  1
)
select * from w4 left join w3 using (实名) order by 1;
