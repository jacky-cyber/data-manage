with w1 as (
select
  case when 部门.实名 = '绿植采供部' and lower(t1.单据编号) ~ 'rth|dx' then
      case substring(t1.单据编号,'\d{2}')
        when '09' then '昆山千灯点'
        when '23' then '海宁花卉城点'
        when '27' then '昌邑花木城点'
        when '28' then '无锡农博园点'
        when '31' then '绍兴东湖点'
    end
  else 部门.实名 end as 实名,
  日历.年,
  日历.月,
  sum(t1.未税金额) as 销售金额,
  sum(t1.成本) as 销售成本
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
where
  t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and t1.日期 between '2014-01-01' and '2015-08-31'
  and ((部门.实名 = '绿植采供部' and lower(t1.单据编号) ~ 'rth|dx' and substring(t1.单据编号,'\d{2}') in ('09','23','27','28','31')) or 部门.一级部门名称 = '绿植零批运营部')
group by
  1,2,3
)
select * from w1 left join (select distinct 二级部门名称 实名,二级部门编号 from 部门 where 一级部门名称 = '绿植零批运营部') t using (实名)
order by
  1,2,3,4;