/**
 * 2015 cai
 *
 * 卡流水
 */

drop table if exists t日期范围;
create temp table t日期范围 as select '[2012-01-01,2014-10-31]'::daterange as 范围;

-- 卡储值金额
-------------------------------------------------------------------------------------------------------------------------------------------
select
  卡号,
  业务类型,
  sum(case when 发生方向 = '减' then - 发生金额 else 发生金额 end) as 金额
from
  卡流水
where
  账户名称 = '储值账户'
  and (select 范围 from t日期范围) @> 业务日期::date
group by
  1,2
order by
  1,2;

-- 卡结存金额
-------------------------------------------------------------------------------------------------------------------------------------------
select
  distinct on (卡号)
  卡号,
  结存金额
from
  卡流水
where
  账户名称 = '储值账户'
  and 业务日期::date < (select upper(范围) from t日期范围)
  and 业务类型 not in ('卡冻结解冻单', '卡挂失解挂单')
order by
  卡号,
  流水号 desc;

-- 卡结存积分
-------------------------------------------------------------------------------------------------------------------------------------------
select
  distinct on (卡号)
  卡号,
  结存积分
from
  卡流水
where
  账户名称 = '积分账户'
  and 业务日期::date < (select upper(范围) from t日期范围)
  and 业务类型 not in ('卡冻结解冻单', '卡挂失解挂单')
order by
  卡号,
  流水号 desc;
  