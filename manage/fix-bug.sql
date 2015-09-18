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
  (未税金额 is null or 未税金额 = 0)
  and 产品长代码 = 商品.代码;

-- 长安苗圃修正
update 销售出库单 set "1+税率"= 1 , 未税金额 = 含税金额 where 单据编号 = '060027823' and 产品长代码 = '8.4.2.039.56001';

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
update 销售出库单 set 部门 = '国际业务部' where 部门 = '金五月销售部' and 单据编号 in ('020050927','020052532','020053323','020053229','020053177');

-- 表修改
-------------------------------------------------------------------------------------------------------------------------------------------
update 零售单 set 分店 = '浙江虹安园艺有限公司嘉兴分公司' where 单据编号 like 'RBH18%';
update 零售单明细 set 分店 = '浙江虹安园艺有限公司嘉兴分公司' where 单据编号 like 'RBH18%';
update 销售出库单 set 部门 = '原苏州树山店' where 部门 = '苏州树山店' and 日期 <= '2012-12-31';
update 销售出库单 set 部门 = '空部门' where 部门 is null;

drop table if exists 销售出库单deleted;
select * into  销售出库单deleted from 销售出库单 where 单据编号 in ('060006485','060006486');
insert into 销售出库单deleted select * from 销售出库单 where 单据编号 = 'DXH25201412190006' and 产品长代码 = '8.8.4.002.88888';
delete from 销售出库单 where 单据编号 in ('060006485','060006486');
delete from 销售出库单 where 单据编号 = 'DXH25201412190006' and 产品长代码 = '8.8.4.002.88888';

update 外购入库单 set 部门 = '临安分公司' where 账套 = '临安' and 部门 is null;
update 收发汇总表 set 仓库 = '多肉项目部生产仓库' where 仓库 = '多肉项目部仓库';
update 调拨单 set 调入仓库 = '多肉项目部生产仓库' where 调入仓库 = '多肉项目部仓库';
update 调拨单 set 调出仓库 = '多肉项目部生产仓库' where 调出仓库 = '多肉项目部仓库';
update 收发汇总表 set 仓库 = '宿根花卉店' where 仓库 = '宿根专营店';
update 调拨单 set 调入仓库 = '宿根花卉店' where 调入仓库 = '宿根专营店';
update 调拨单 set 调出仓库 = '宿根花卉店' where 调出仓库 = '宿根专营店';
update 收发汇总表 set 仓库 = '苏果超市研究院将军路店' where 仓库 = '华润虹越研究院蔬果店';

delete from 外购入库单 where 单据编号 = 'DXH32201505170002' and 产品长代码 = '8.5.2.021.04030';
delete from 外购入库单 where 单据编号 = 'DXH32201505100003' and 产品长代码 = '8.5.2.021.04030';
insert into 外购入库单 values('d:/data/import/purchase/hongan-201505.txt','虹安','2015-05-17','DXH32201505170002','','8.5.2.021.04030',1.0000,10.2,'苏州树山店','黄海艳','30.0004');
insert into 外购入库单 values('d:/data/import/purchase/hongan-201505.txt','虹安','2015-05-10','DXH32201505100003','','8.5.2.021.04030',1.0000,11.4,'苏州树山店','黄海艳','30.0004');

-------------------------------------------------------------------------------------------------------------------------------------------
