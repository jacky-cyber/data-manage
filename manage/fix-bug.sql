/**
 * 2015 cai
 *
 * 数据清洗
 */

-- 更新税率
-------------------------------------------------------------------------------------------------------------------------------------------
update
  销售出库单
set
  未税金额 = 含税金额/(1 + 商品.税率/100)
from
  商品
where
  未税金额 is null
  and 产品长代码 = 商品.代码;
  
-- 更新三账套的建议零售价
-------------------------------------------------------------------------------------------------------------------------------------------
update
  销售出库单
set
  建议零售价 = 商品.销售单价
from
  商品
where
  账套 in ('临安','上海','沈阳')
  and 产品长代码 = 商品.代码;
-------------------------------------------------------------------------------------------------------------------------------------------

-- 国际业务部修正
update 销售出库单 set 部门 = '国际业务部' where 部门 = '草业事业部' and 单据编号 in ('020051406','020051888','020051395');
update 销售出库单 set 部门 = '国际业务部' where 部门 = '肥料介质部' and 单据编号 in ('020049429','020053081','020052254','020051908','020053078','020050317');
update 销售出库单 set 部门 = '国际业务部' where 部门 = '总部苗圃' and 单据编号 in ('020051865');
update 销售出库单 set 部门 = '国际业务部' where 部门 = '金五月销售部' and 单据编号 in ('020050927');

-- 表修改
-------------------------------------------------------------------------------------------------------------------------------------------
update 零售单 set 分店 = '浙江虹安园艺有限公司嘉兴分公司' where 单据编号 like 'RBH18%';
update 零售单明细 set 分店 = '浙江虹安园艺有限公司嘉兴分公司' where 单据编号 like 'RBH18%';
delete from 销售出库单 where 单据编号 in ('060006485','060006486');
update 销售出库单 set 部门 = '原苏州树山店' where 部门 = '苏州树山店' and 日期 <= '2012-12-31';
update 销售出库单 set 部门 = '空部门' where 部门 is null;
delete from 销售出库单 where 单据编号 = 'DXH25201412190006' and 产品长代码 = '8.8.4.002.88888';
delete from 收发汇总表 where 账套 = '嘉兴' and 会计期间 = '2014.7';
update 外购入库单 set 部门 = '临安分公司' where 账套 = '临安' and 部门 is null;
-------------------------------------------------------------------------------------------------------------------------------------------