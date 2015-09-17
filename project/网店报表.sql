with w1 as (
select
  case
    when t1.客户代码 = '999.0213' or t1.摘要 ~ '花彩商城' then '花彩商城店'
    when t1.客户代码 = '999.0078.24' and 部门.实名 = '研究院' then '萌吖吖种子（淘宝）店'
    when t1.客户代码 = '999.0089' and 部门.实名 = '花卉城项目部' then '海宁国际花卉城（淘宝）店'
    when (t1.客户代码 in ('999.0076','999.0066') or (t1.客户代码 = '999.0167' and t1.账套 = '虹安')) and 部门.实名 = '多肉项目部' then '多肉时光（淘宝）店'
    when t1.客户代码 = '021.9999' and 部门.实名 = '浦东宣桥店' then '源怡种苗（淘宝）店'
    when t1.客户代码 = '573.450' and 部门.实名 = '虹越家居（天猫）专营店' then '虹越亚马逊店'
    when t1.客户代码 = '999.0162' and 部门.实名 = '园艺家总部（淘宝）店' then '虹越旗舰店'
    else 部门.实名
  end as 网店,
  日历.年,
  日历.月,
  sum(t1.未税金额) as 出库金额,
  sum(t1.成本) as 出库成本,
  sum(t1.未税金额) - sum(t1.成本) as 出库毛利
from
  销售出库单 t1
  inner join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
where
  t1.客户代码 not in (select 代码 from 客户 where 是否关联客户)
  and t1.日期 between '2012-01-01' and '2015-08-31'
group by
  1,2,3
),w2 as (
select
  *,
  case when 网店 = '花彩商城店' then '花彩' else '阿里' end as 网店类别
from
  w1
where
  网店 in ('海宁国际花卉城（淘宝）店','虹越家居（天猫）专营店','虹越旗舰店','虹越园艺家预售店','花彩盆栽（淘宝）店','萌吖吖种子（淘宝）店','园艺家总部（淘宝）店','花彩商城店')
)
select
  *,
  sum(销售额) over(partition by 年,网店 order by 月) as 年累计销售额
from
  w2
  full join 网店销售 using (年,月,网店类别,网店)
order by
  1,2,3,4;
