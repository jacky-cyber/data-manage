select
  卡资料.卡类型,
  case when length(卡资料.身份证号) = 18 then (2015 - substring(卡资料.身份证号,7,4)::int) / 10 * 10 end as 出生年份,
  case when length(卡资料.身份证号) = 18 then case substring(卡资料.身份证号,17,1)::int % 2 when 1 then '男' when 0 then '女' end end as 性别,
  卡资料.卡号,
  count(distinct t1.日期) as 消费次数,
  sum(t1.实付金额) as 零售金额
from
  零售单明细 t1
  inner join 机构 on t1.分店 = 机构.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 卡资料 on t1.会员卡 = 卡资料.卡号
  left join 省份 t2 on substring(卡资料.身份证号,1,2) = t2.编号::text
where
  机构.一级部门名称 = '绿植零批运营部'
  and t1.产品长代码 != '9.6.7.021.00001'
  and t1.单据编号 not in (select 单据编号 from 零售单客户 where array[lower(客户业务类型)] <@ any(select array_agg(代码) from 客户业务类型))
  and 日历.年 >= 2015
  and 日历.月 <= 7
group by
  1,2,3,4
order by
  1,2,3,4;
