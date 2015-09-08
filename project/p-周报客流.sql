with w1 as (
select
  机构.二级部门编号,
  机构.实名,
  报表日历.虹越年,
  报表日历.虹越周,
  count (distinct t1.单据编号) as 客流量
from
  零售单客户 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join 报表日历 on t1.日期 = 报表日历.日期
where
  机构.一级部门名称 = '门店运营部'
  and coalesce(lower(客户业务类型),'') not in (select 代码 from 客户业务类型)
  and not (t1.分店 = '海宁国际花卉城' and t1.日期 <= '2014-12-24')
  and 报表日历.虹越年 >= 2014
  and 报表日历.虹越周 <= 36
group by
  1,2,3,4
 )
select
  *
from
  (select distinct 二级部门编号,实名 from w1) t1
  cross join (select distinct 虹越年,虹越周 from w1) t2
  full join w1 using (二级部门编号,实名,虹越年,虹越周)
order by
  1,2,3;
