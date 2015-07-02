/**
 * 2015 cai
 *
 * 会员特征信息
 */

-- 根据会员身份证号得到出生年份和籍贯
select
  t1.身份证号,
  substring(t1.身份证号,7,4)::int as 出生年份,
  t2.省份 as 籍贯
from
  卡资料 t1
  left join 省份 t2 on substring(t1.身份证号,1,2) = t2.编号::text
where
  length(t1.身份证号) = 18
order by
  1;
