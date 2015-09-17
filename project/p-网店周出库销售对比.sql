with w1 as (
select
  case when 二级部门名称 = '花彩商城店' then '花彩' else '阿里' end as 网店类别,
  二级部门名称 网店,
  期 周,
  sum(外销) 出库
from
  周报数据
where
  二级部门名称 in ('海宁国际花卉城（淘宝）店','虹越家居（天猫）专营店','虹越旗舰店','虹越园艺家预售店','花彩盆栽（淘宝）店','萌吖吖种子（淘宝）店','园艺家总部（淘宝）店','花彩商城店')
  and 年 = 2015
  and 期 >= 27
group by
  1,2,3
)
select
  *
from
  w1
  full join 网店周销售 using (网店类别,网店,周)
order by
  1,2,3;
