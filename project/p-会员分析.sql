/**
 * 2015 cai
 *
 * 会员消费分析
 */

with w日期范围 as (
select
  '[2012-01-01,2013-12-31]'::daterange as 范围
),w1 as (
select
  会员卡 as 卡号,
  count(distinct 单据编号) as 消费次数,
  sum(实付金额) as 消费金额
from
  零售单明细
where
  会员卡 is not null
  and 单据编号 not in (select 单据编号 from 零售单客户 where array[lower(客户业务类型)] <@ any(select array_agg(代码) from 客户业务类型))
  and (select 范围 from w日期范围) @> 日期
group by
  1
),w2 as (
select
  卡号,
  sum(case 发生方向 when '加' then 发生金额 else -发生金额 end) as 充值金额
from
  卡流水
where
  账户名称 = '储值账户'
  and 业务类型 = '卡金额充值'
  and (select 范围 from w日期范围) @> 业务日期::date
group by
  1
),w3 as (
select
  distinct on (卡号)
  卡号,
  结存金额
from
  卡流水
where
  账户名称 = '储值账户'
  and 业务类型 != '卡冻结解冻单'
  and 业务类型 != '卡挂失解挂单'
  and 业务日期::date < (select upper(范围) from w日期范围)
order by
  卡号,
  流水号 desc
),w4 as (
select
  distinct on (卡号)
  卡号,
  结存积分
from
  卡流水
where
  账户名称 = '积分账户'
  and 业务类型 != '卡冻结解冻单'
  and 业务类型 != '卡挂失解挂单'
  and 业务日期::date < (select upper(范围) from w日期范围)
order by
  卡号,
  流水号 desc
)
select
  *
from
  w1
  left join w2 using (卡号)
  left join w3 using (卡号)
  left join w4 using (卡号)
  left join (select 卡号,卡类型,会员名称,发卡机构整合 from 卡资料) t using(卡号)  
 order by
  1;
