/**
 * 2015 cai
 *
 * 导入2015年前业务单据
 *
 * 导入脚本来自`get_pg_copy_script.py3`
 */

drop table if exists 卡流水, 其他入库单, 其他出库单, 盘盈单, 外购入库单, 零售单, 零售单明细, 零售单客户, 销售出库单, 盘亏单, 收发汇总表, 调拨单, 成本调整单;

create table 卡流水 (
  文件路径 varchar(255),
  流水号 int,
  卡号 varchar(255),
  卡类型 varchar(255),
  账户名称 varchar(255),
  会员名称 varchar(255),
  发生机构 varchar(255),
  发生方向 varchar(255),
  发生金额 numeric(20,4),
  结存金额 numeric(20,4),
  发生积分 numeric(20,4),
  结存积分 numeric(20,4),
  折扣金额 numeric(20,4),
  消费金额 numeric(20,4),
  业务类型 varchar(255),
  单据编号 varchar(255),
  业务日期 timestamp
);

create table 其他入库单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  部门 varchar(255),
  产品长代码 varchar(255),
  数量 numeric(20,4),
  金额 numeric(20,4),
  摘要 varchar(255),
  入库类型 varchar(255),
  仓库代码 varchar(255)
);

create table 其他出库单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  部门 varchar(255),
  单据编号 varchar(255),
  产品长代码 varchar(255),
  数量 numeric(20,4),
  金额 numeric(20,4),
  出库类型 varchar(255),
  仓库代码 varchar(255)
);

create table 盘盈单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  产品长代码 varchar(255),
  盘盈数量 numeric(20,4),
  盘盈金额 numeric(20,4),
  仓库代码 varchar(255)
);

create table 外购入库单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  供应商 varchar(255),
  产品长代码 varchar(255),
  实收数量 numeric(20,4),
  实收金额 numeric(20,4),
  部门 varchar(255),
  业务员 varchar(255),
  仓库代码 varchar(255)
);

create table 零售单 (
  文件路径 varchar(255),
  账套 varchar(255),
  单据编号 varchar(255),
  日期 date,
  分店 varchar(255),
  实收金额 numeric(20,4),
  会员姓名 varchar(255),
  结算方式 varchar(255),
  结算金额 numeric(20,4),
  卡类别 varchar(255),
  会员卡 varchar(255),
  折扣金额  numeric(20,4),
  卡号 varchar(255),
  销售开始时间 timestamp
);

create table 零售单明细 (
  文件路径 varchar(255),
  账套 varchar(255),
  单据编号 varchar(255),
  日期 date,
  分店 varchar(255),
  会员卡 varchar(255),
  产品长代码 varchar(255),
  数量 numeric(20,4),
  原价 numeric(20,4),
  实价 numeric(20,4),
  应付金额 numeric(20,4),
  实付金额 numeric(20,4),
  商品打折率 numeric(20,4),
  打折类型 varchar(255),
  打折原因 varchar(255)
);

create table 零售单客户 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  分店 varchar(255),
  客户业务类型 varchar(255)
);

create table 销售出库单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  产品长代码 varchar(255),
  实发数量  numeric(20,4),
  成本  numeric(20,4),
  部门 varchar(255),
  业务员 varchar(255),
  摘要 varchar(255),
  含税金额 numeric(20,4),
  仓库代码 varchar(255),
  客户代码 varchar(255),
  商品所属部门 varchar(255),
  "1+税率"  numeric(20,4),
  未税金额  numeric(20,4),
  建议零售价  numeric(20,4)
);

create table 盘亏单 (
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  产品长代码 varchar(255),
  盘亏数量 numeric(20,4),
  盘亏金额 numeric(20,4),
  仓库代码 varchar(255)
);

create table 收发汇总表 (
  文件路径 varchar(255),
  账套 varchar(255),
  会计期间 varchar(255),
  仓库 varchar(255),
  产品长代码 varchar(255),
  期初结存数量 numeric(20,4),
  期初结存金额 numeric(20,4),
  本期收入数量 numeric(20,4),
  本期收入金额 numeric(20,4),
  本期发出数量 numeric(20,4),
  本期发出金额 numeric(20,4),
  期末结存数量 numeric(20,4),
  期末结存金额 numeric(20,4)
);

create table 调拨单(
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  调出仓库 varchar(255),
  调入仓库 varchar(255),
  产品长代码 varchar(255),
  调拨数量 numeric(20,4),
  成本 numeric(20,4),
  摘要 varchar(255)
);
create table 成本调整单(
  文件路径 varchar(255),
  账套 varchar(255),
  日期 date,
  单据编号 varchar(255),
  调整仓库 varchar(255),
  商品长代码 varchar(255),
  调整金额 numeric(20,4),
  部门 varchar(255),
  业务员 varchar(255),
  单据类型 varchar(255)
);
--------------------------------------------------------------------------------------------------------------------------------------------------

--外购入库单
delete from 外购入库单;
select copyk3('外购入库单','purchase/guomei-201201-201406');
select copyk3('外购入库单','purchase/guomei-201407');
select copyk3('外购入库单','purchase/guomei-201408');
select copyk3('外购入库单','purchase/guomei-201409');
select copyk3('外购入库单','purchase/guomei-201410');
select copyk3('外购入库单','purchase/guomei-201411');
select copyk3('外购入库单','purchase/guomei-201412');
select copyk3('外购入库单','purchase/hangzhou-201201-201406');
select copyk3('外购入库单','purchase/hangzhou-201407');
select copyk3('外购入库单','purchase/hangzhou-201408');
select copyk3('外购入库单','purchase/hangzhou-201409');
select copyk3('外购入库单','purchase/hangzhou-201410');
select copyk3('外购入库单','purchase/hangzhou-201411');
select copyk3('外购入库单','purchase/hangzhou-201412');
select copyk3('外购入库单','purchase/hongan-201201-201406');
select copyk3('外购入库单','purchase/hongan-201407');
select copyk3('外购入库单','purchase/hongan-201408');
select copyk3('外购入库单','purchase/hongan-201409');
select copyk3('外购入库单','purchase/hongan-201410');
select copyk3('外购入库单','purchase/hongan-201411');
select copyk3('外购入库单','purchase/hongan-201412');
select copyk3('外购入库单','purchase/huicai-201201-201406');
select copyk3('外购入库单','purchase/huicai-201407');
select copyk3('外购入库单','purchase/huicai-201408');
select copyk3('外购入库单','purchase/huicai-201409');
select copyk3('外购入库单','purchase/huicai-201410');
select copyk3('外购入库单','purchase/huicai-201411');
select copyk3('外购入库单','purchase/huicai-201412');
select copyk3('外购入库单','purchase/jiaxing-201201-201406');
select copyk3('外购入库单','purchase/jinwuyue-0-2014');
select copyk3('外购入库单','purchase/kunshan-0-2014');
select copyk3('外购入库单','purchase/licai-0-2014');
select copyk3('外购入库单','purchase/linan-0-2014');
select copyk3('外购入库单','purchase/shanghai-0-2014');
select copyk3('外购入库单','purchase/shenyang-0-2014');
select copyk3('外购入库单','purchase/suzhou-201201-201406');
select copyk3('外购入库单','purchase/suzhou-201407');
select copyk3('外购入库单','purchase/suzhou-201408');
select copyk3('外购入库单','purchase/suzhou-201409');
select copyk3('外购入库单','purchase/suzhou-201410');
select copyk3('外购入库单','purchase/suzhou-201411');
select copyk3('外购入库单','purchase/suzhou-201412');
select copyk3('外购入库单','purchase/wuxi-201201-201406');
select copyk3('外购入库单','purchase/wuxi-201407');
select copyk3('外购入库单','purchase/wuxi-201408');
select copyk3('外购入库单','purchase/wuxi-201409');
select copyk3('外购入库单','purchase/wuxi-201410');
select copyk3('外购入库单','purchase/wuxi-201411');
select copyk3('外购入库单','purchase/wuxi-201412');
select copyk3('外购入库单','purchase/zhejiang-201201-201406');
select copyk3('外购入库单','purchase/zhejiang-201407');
select copyk3('外购入库单','purchase/zhejiang-201408');
select copyk3('外购入库单','purchase/zhejiang-201409');
select copyk3('外购入库单','purchase/zhejiang-201410');
select copyk3('外购入库单','purchase/zhejiang-201411');
select copyk3('外购入库单','purchase/zhejiang-201412');

--收发汇总表
delete from 收发汇总表;
select copyk3('收发汇总表','warehouse/guomei-201201-201406');
select copyk3('收发汇总表','warehouse/guomei-201407');
select copyk3('收发汇总表','warehouse/guomei-201408');
select copyk3('收发汇总表','warehouse/guomei-201409');
select copyk3('收发汇总表','warehouse/guomei-201410');
select copyk3('收发汇总表','warehouse/guomei-201411');
select copyk3('收发汇总表','warehouse/guomei-201412');
select copyk3('收发汇总表','warehouse/hangzhou-201201-201406');
select copyk3('收发汇总表','warehouse/hangzhou-201407');
select copyk3('收发汇总表','warehouse/hangzhou-201408');
select copyk3('收发汇总表','warehouse/hangzhou-201409');
select copyk3('收发汇总表','warehouse/hangzhou-201410');
select copyk3('收发汇总表','warehouse/hangzhou-201411');
select copyk3('收发汇总表','warehouse/hangzhou-201412');
select copyk3('收发汇总表','warehouse/hongan-201201-201406');
select copyk3('收发汇总表','warehouse/hongan-201407');
select copyk3('收发汇总表','warehouse/hongan-201408');
select copyk3('收发汇总表','warehouse/hongan-201409');
select copyk3('收发汇总表','warehouse/hongan-201410');
select copyk3('收发汇总表','warehouse/hongan-201411');
select copyk3('收发汇总表','warehouse/hongan-201412');
select copyk3('收发汇总表','warehouse/huicai-201201-201406');
select copyk3('收发汇总表','warehouse/huicai-201407');
select copyk3('收发汇总表','warehouse/huicai-201408');
select copyk3('收发汇总表','warehouse/huicai-201409');
select copyk3('收发汇总表','warehouse/huicai-201410');
select copyk3('收发汇总表','warehouse/huicai-201411');
select copyk3('收发汇总表','warehouse/huicai-201412');
select copyk3('收发汇总表','warehouse/jiaxing-201201-201406');
select copyk3('收发汇总表','warehouse/jiaxing-201407');
select copyk3('收发汇总表','warehouse/jinwuyue-0-2014');
select copyk3('收发汇总表','warehouse/kunshan-0-2014');
select copyk3('收发汇总表','warehouse/licai-0-2014');
select copyk3('收发汇总表','warehouse/linan-0-2014');
select copyk3('收发汇总表','warehouse/shanghai-0-2014');
select copyk3('收发汇总表','warehouse/shenyang-0-2014');
select copyk3('收发汇总表','warehouse/suzhou-201201-201406');
select copyk3('收发汇总表','warehouse/suzhou-201407');
select copyk3('收发汇总表','warehouse/suzhou-201408');
select copyk3('收发汇总表','warehouse/suzhou-201409');
select copyk3('收发汇总表','warehouse/suzhou-201410');
select copyk3('收发汇总表','warehouse/suzhou-201411');
select copyk3('收发汇总表','warehouse/suzhou-201412');
select copyk3('收发汇总表','warehouse/wuxi-201201-201304');
select copyk3('收发汇总表','warehouse/wuxi-201306-201406');
select copyk3('收发汇总表','warehouse/wuxi-201407');
select copyk3('收发汇总表','warehouse/wuxi-201408');
select copyk3('收发汇总表','warehouse/wuxi-201409');
select copyk3('收发汇总表','warehouse/wuxi-201410');
select copyk3('收发汇总表','warehouse/wuxi-201411');
select copyk3('收发汇总表','warehouse/wuxi-201412');
select copyk3('收发汇总表','warehouse/zhejiang-201201-201406');
select copyk3('收发汇总表','warehouse/zhejiang-201407');
select copyk3('收发汇总表','warehouse/zhejiang-201408');
select copyk3('收发汇总表','warehouse/zhejiang-201409');
select copyk3('收发汇总表','warehouse/zhejiang-201410');
select copyk3('收发汇总表','warehouse/zhejiang-201411');
select copyk3('收发汇总表','warehouse/zhejiang-201412');

--盘亏单
delete from 盘亏单;
select copyk3('盘亏单','shortage/guomei-201201-201406');
select copyk3('盘亏单','shortage/guomei-201407');
select copyk3('盘亏单','shortage/guomei-201408');
select copyk3('盘亏单','shortage/guomei-201409');
select copyk3('盘亏单','shortage/guomei-201410');
select copyk3('盘亏单','shortage/guomei-201411');
select copyk3('盘亏单','shortage/guomei-201412');
select copyk3('盘亏单','shortage/hangzhou-201201-201406');
select copyk3('盘亏单','shortage/hangzhou-201407');
select copyk3('盘亏单','shortage/hangzhou-201408');
select copyk3('盘亏单','shortage/hangzhou-201409');
select copyk3('盘亏单','shortage/hangzhou-201410');
select copyk3('盘亏单','shortage/hangzhou-201411');
select copyk3('盘亏单','shortage/hangzhou-201412');
select copyk3('盘亏单','shortage/hongan-201201-201406');
select copyk3('盘亏单','shortage/hongan-201407');
select copyk3('盘亏单','shortage/hongan-201408');
select copyk3('盘亏单','shortage/hongan-201409');
select copyk3('盘亏单','shortage/hongan-201410');
select copyk3('盘亏单','shortage/hongan-201411');
select copyk3('盘亏单','shortage/hongan-201412');
select copyk3('盘亏单','shortage/huicai-201201-201406');
select copyk3('盘亏单','shortage/huicai-201407');
select copyk3('盘亏单','shortage/huicai-201408');
select copyk3('盘亏单','shortage/huicai-201409');
select copyk3('盘亏单','shortage/huicai-201410');
select copyk3('盘亏单','shortage/huicai-201411');
select copyk3('盘亏单','shortage/huicai-201412');
select copyk3('盘亏单','shortage/jiaxing-201201-201406');
select copyk3('盘亏单','shortage/jinwuyue-0-2014');
select copyk3('盘亏单','shortage/kunshan-0-201412');
select copyk3('盘亏单','shortage/licai-0-2014');
select copyk3('盘亏单','shortage/linan-0-2014');
select copyk3('盘亏单','shortage/shanghai-0-2014');
select copyk3('盘亏单','shortage/shenyang-0-2014');
select copyk3('盘亏单','shortage/suzhou-201201-201406');
select copyk3('盘亏单','shortage/suzhou-201407');
select copyk3('盘亏单','shortage/suzhou-201408');
select copyk3('盘亏单','shortage/suzhou-201409');
select copyk3('盘亏单','shortage/suzhou-201410');
select copyk3('盘亏单','shortage/suzhou-201411');
select copyk3('盘亏单','shortage/suzhou-201412');
select copyk3('盘亏单','shortage/wuxi-201201-201406');
select copyk3('盘亏单','shortage/wuxi-201407');
select copyk3('盘亏单','shortage/wuxi-201408');
select copyk3('盘亏单','shortage/wuxi-201409');
select copyk3('盘亏单','shortage/wuxi-201410');
select copyk3('盘亏单','shortage/wuxi-201411');
select copyk3('盘亏单','shortage/wuxi-201412');
select copyk3('盘亏单','shortage/zhejiang-201201-201406');
select copyk3('盘亏单','shortage/zhejiang-201407');
select copyk3('盘亏单','shortage/zhejiang-201408');
select copyk3('盘亏单','shortage/zhejiang-201409');
select copyk3('盘亏单','shortage/zhejiang-201410');
select copyk3('盘亏单','shortage/zhejiang-201411');
select copyk3('盘亏单','shortage/zhejiang-201412');

--盘盈单
delete from 盘盈单;
select copyk3('盘盈单','overage/guomei-0-201412');
select copyk3('盘盈单','overage/hangzhou-201201-201406');
select copyk3('盘盈单','overage/hangzhou-201407');
select copyk3('盘盈单','overage/hangzhou-201408');
select copyk3('盘盈单','overage/hangzhou-201409');
select copyk3('盘盈单','overage/hangzhou-201410');
select copyk3('盘盈单','overage/hangzhou-201411');
select copyk3('盘盈单','overage/hangzhou-201412');
select copyk3('盘盈单','overage/hongan-201201-201406');
select copyk3('盘盈单','overage/hongan-201407');
select copyk3('盘盈单','overage/hongan-201408');
select copyk3('盘盈单','overage/hongan-201409');
select copyk3('盘盈单','overage/hongan-201410');
select copyk3('盘盈单','overage/hongan-201411');
select copyk3('盘盈单','overage/hongan-201412');
select copyk3('盘盈单','overage/huicai-201201-201406');
select copyk3('盘盈单','overage/huicai-201407');
select copyk3('盘盈单','overage/huicai-201408');
select copyk3('盘盈单','overage/huicai-201409');
select copyk3('盘盈单','overage/huicai-201410');
select copyk3('盘盈单','overage/huicai-201411');
select copyk3('盘盈单','overage/huicai-201412');
select copyk3('盘盈单','overage/jiaxing-201201-201406');
select copyk3('盘盈单','overage/jinwuyue-0-2014');
select copyk3('盘盈单','overage/kunshan-0-201412');
select copyk3('盘盈单','overage/licai-0-2014');
select copyk3('盘盈单','overage/linan-0-2014');
select copyk3('盘盈单','overage/shanghai-0-2014');
select copyk3('盘盈单','overage/shenyang-0-2014');
select copyk3('盘盈单','overage/suzhou-201201-201406');
select copyk3('盘盈单','overage/suzhou-201407');
select copyk3('盘盈单','overage/suzhou-201408');
select copyk3('盘盈单','overage/suzhou-201409');
select copyk3('盘盈单','overage/suzhou-201410');
select copyk3('盘盈单','overage/suzhou-201411');
select copyk3('盘盈单','overage/suzhou-201412');
select copyk3('盘盈单','overage/wuxi-201201-201406');
select copyk3('盘盈单','overage/wuxi-201407');
select copyk3('盘盈单','overage/wuxi-201408');
select copyk3('盘盈单','overage/wuxi-201409');
select copyk3('盘盈单','overage/wuxi-201410');
select copyk3('盘盈单','overage/wuxi-201411');
select copyk3('盘盈单','overage/wuxi-201412');
select copyk3('盘盈单','overage/zhejiang-201201-201406');
select copyk3('盘盈单','overage/zhejiang-201407');
select copyk3('盘盈单','overage/zhejiang-201408');
select copyk3('盘盈单','overage/zhejiang-201409');
select copyk3('盘盈单','overage/zhejiang-201410');
select copyk3('盘盈单','overage/zhejiang-201411');
select copyk3('盘盈单','overage/zhejiang-201412');

--卡流水
delete from 卡流水;
select copyk3('卡流水','card/flow-201201-201406');
select copyk3('卡流水','card/flow-201407');
select copyk3('卡流水','card/flow-201408');
select copyk3('卡流水','card/flow-201409');
select copyk3('卡流水','card/flow-201410');
select copyk3('卡流水','card/flow-201411');
select copyk3('卡流水','card/flow-201412');

--其他出库单
delete from 其他出库单;
select copyk3('其他出库单','other_out/guomei-201201-201406');
select copyk3('其他出库单','other_out/guomei-201407');
select copyk3('其他出库单','other_out/guomei-201408');
select copyk3('其他出库单','other_out/guomei-201409');
select copyk3('其他出库单','other_out/guomei-201410');
select copyk3('其他出库单','other_out/guomei-201411');
select copyk3('其他出库单','other_out/guomei-201412');
select copyk3('其他出库单','other_out/hangzhou-201201-201406');
select copyk3('其他出库单','other_out/hangzhou-201407');
select copyk3('其他出库单','other_out/hangzhou-201408');
select copyk3('其他出库单','other_out/hangzhou-201409');
select copyk3('其他出库单','other_out/hangzhou-201410');
select copyk3('其他出库单','other_out/hangzhou-201411');
select copyk3('其他出库单','other_out/hangzhou-201412');
select copyk3('其他出库单','other_out/hongan-201201-201406');
select copyk3('其他出库单','other_out/hongan-201407');
select copyk3('其他出库单','other_out/hongan-201408');
select copyk3('其他出库单','other_out/hongan-201409');
select copyk3('其他出库单','other_out/hongan-201410');
select copyk3('其他出库单','other_out/hongan-201411');
select copyk3('其他出库单','other_out/hongan-201412');
select copyk3('其他出库单','other_out/huicai-201201-201406');
select copyk3('其他出库单','other_out/huicai-201407');
select copyk3('其他出库单','other_out/huicai-201408');
select copyk3('其他出库单','other_out/huicai-201409');
select copyk3('其他出库单','other_out/huicai-201410');
select copyk3('其他出库单','other_out/huicai-201411');
select copyk3('其他出库单','other_out/huicai-201412');
select copyk3('其他出库单','other_out/jiaxing-201201-201406');
select copyk3('其他出库单','other_out/jinwuyue-0-2014');
select copyk3('其他出库单','other_out/kunshan-201201-201406');
select copyk3('其他出库单','other_out/kunshan-201407');
select copyk3('其他出库单','other_out/kunshan-201408');
select copyk3('其他出库单','other_out/kunshan-201409');
select copyk3('其他出库单','other_out/kunshan-201410');
select copyk3('其他出库单','other_out/kunshan-201411-201412');
select copyk3('其他出库单','other_out/licai-0-2014');
select copyk3('其他出库单','other_out/linan-0-2014');
select copyk3('其他出库单','other_out/shanghai-0-2014');
select copyk3('其他出库单','other_out/shenyang-0-2014');
select copyk3('其他出库单','other_out/suzhou-201201-201406');
select copyk3('其他出库单','other_out/suzhou-201407');
select copyk3('其他出库单','other_out/suzhou-201408');
select copyk3('其他出库单','other_out/suzhou-201409');
select copyk3('其他出库单','other_out/suzhou-201410');
select copyk3('其他出库单','other_out/suzhou-201411');
select copyk3('其他出库单','other_out/suzhou-201412');
select copyk3('其他出库单','other_out/wuxi-201201-201406');
select copyk3('其他出库单','other_out/wuxi-201407');
select copyk3('其他出库单','other_out/wuxi-201408');
select copyk3('其他出库单','other_out/wuxi-201409');
select copyk3('其他出库单','other_out/wuxi-201410');
select copyk3('其他出库单','other_out/wuxi-201411');
select copyk3('其他出库单','other_out/wuxi-201412');
select copyk3('其他出库单','other_out/zhejiang-201201-201406');
select copyk3('其他出库单','other_out/zhejiang-201407');
select copyk3('其他出库单','other_out/zhejiang-201408');
select copyk3('其他出库单','other_out/zhejiang-201409');
select copyk3('其他出库单','other_out/zhejiang-201410');
select copyk3('其他出库单','other_out/zhejiang-201411');
select copyk3('其他出库单','other_out/zhejiang-201412');

--调拨单
delete from 调拨单;
select copyk3('调拨单','requisition/guomei-0-2014');
select copyk3('调拨单','requisition/hangzhou-0-2014');
select copyk3('调拨单','requisition/hongan-0-2014');
select copyk3('调拨单','requisition/huicai-0-2014');
select copyk3('调拨单','requisition/jiaxing-0-2014');
select copyk3('调拨单','requisition/jinwuyue-0-2014');
select copyk3('调拨单','requisition/kunshan-0-2014');
select copyk3('调拨单','requisition/licai-0-2014');
select copyk3('调拨单','requisition/linan-0-2014');
select copyk3('调拨单','requisition/shanghai-0-2014');
select copyk3('调拨单','requisition/shenyang-0-2014');
select copyk3('调拨单','requisition/suzhou-0-2014');
select copyk3('调拨单','requisition/wuxi-0-2014');
select copyk3('调拨单','requisition/zhejiang-0-2014');

--零售单客户
delete from 零售单客户;
select copyk3('零售单客户','retail_c/hangzhou-0-201412');
select copyk3('零售单客户','retail_c/hongan-0-201412');
select copyk3('零售单客户','retail_c/huicai-0-201412');
select copyk3('零售单客户','retail_c/jiaxing-0-201412');
select copyk3('零售单客户','retail_c/kunshan-0-201412');
select copyk3('零售单客户','retail_c/suzhou--0-201412');
select copyk3('零售单客户','retail_c/wuxi-0-201412');

--其他入库单
delete from 其他入库单;
select copyk3('其他入库单','other_in/guomei-0-2014');
select copyk3('其他入库单','other_in/hangzhou-0-2014');
select copyk3('其他入库单','other_in/hongan-0-2014');
select copyk3('其他入库单','other_in/huicai-0-2014');
select copyk3('其他入库单','other_in/jiaxing-0-2014');
select copyk3('其他入库单','other_in/jinwuyue-0-2014');
select copyk3('其他入库单','other_in/kunshan-0-2014');
select copyk3('其他入库单','other_in/licai-0-2014');
select copyk3('其他入库单','other_in/linan-0-2014');
select copyk3('其他入库单','other_in/shanghai-0-2014');
select copyk3('其他入库单','other_in/shenyang-0-2014');
select copyk3('其他入库单','other_in/suzhou-0-2014');
select copyk3('其他入库单','other_in/wuxi-0-2014');
select copyk3('其他入库单','other_in/zhejiang-0-2014');

--销售出库单
delete from 销售出库单;
select copyk3('销售出库单','sale/guomei-2012');
select copyk3('销售出库单','sale/guomei-201301-201306');
select copyk3('销售出库单','sale/guomei-201307-201312');
select copyk3('销售出库单','sale/guomei-201401-201402');
select copyk3('销售出库单','sale/guomei-201403-201404');
select copyk3('销售出库单','sale/guomei-201405-201406');
select copyk3('销售出库单','sale/guomei-201407-201408');
select copyk3('销售出库单','sale/guomei-201409-201409');
select copyk3('销售出库单','sale/guomei-201410-201410');
select copyk3('销售出库单','sale/guomei-201411');
select copyk3('销售出库单','sale/guomei-201412');
select copyk3('销售出库单','sale/hangzhou-2012');
select copyk3('销售出库单','sale/hangzhou-2013');
select copyk3('销售出库单','sale/hangzhou-201401-201410');
select copyk3('销售出库单','sale/hangzhou-201411');
select copyk3('销售出库单','sale/hangzhou-201412');
select copyk3('销售出库单','sale/hongan-2012');
select copyk3('销售出库单','sale/hongan-2013');
select copyk3('销售出库单','sale/hongan-201401-201410');
select copyk3('销售出库单','sale/hongan-201411');
select copyk3('销售出库单','sale/hongan-201412');
select copyk3('销售出库单','sale/huicai-0-201406');
select copyk3('销售出库单','sale/huicai-201407-201410');
select copyk3('销售出库单','sale/huicai-201411');
select copyk3('销售出库单','sale/huicai-201412');
select copyk3('销售出库单','sale/jiaxing-0-201406');
select copyk3('销售出库单','sale/jinwuyue-0-201410');
select copyk3('销售出库单','sale/jinwuyue-201411');
select copyk3('销售出库单','sale/jinwuyue-201412');
select copyk3('销售出库单','sale/kunshan-2012');
select copyk3('销售出库单','sale/kunshan-2013');
select copyk3('销售出库单','sale/kunshan-201401-201410');
select copyk3('销售出库单','sale/kunshan-201411-201412');
select copyk3('销售出库单','sale/licai-0-201311');
select copyk3('销售出库单','sale/licai-201312-201410');
select copyk3('销售出库单','sale/licai-201411');
select copyk3('销售出库单','sale/licai-201412');
select copyk3('销售出库单','sale/linan-0-201410');
select copyk3('销售出库单','sale/linan-201411');
select copyk3('销售出库单','sale/linan-201412');
select copyk3('销售出库单','sale/shanghai-0-201410');
select copyk3('销售出库单','sale/shanghai-201411');
select copyk3('销售出库单','sale/shanghai-201412');
select copyk3('销售出库单','sale/shenyang-0-201410');
select copyk3('销售出库单','sale/shenyang-201411');
select copyk3('销售出库单','sale/shenyang-201412');
select copyk3('销售出库单','sale/suzhou-2012');
select copyk3('销售出库单','sale/suzhou-2013');
select copyk3('销售出库单','sale/suzhou-201401-201410');
select copyk3('销售出库单','sale/suzhou-201411');
select copyk3('销售出库单','sale/suzhou-201412');
select copyk3('销售出库单','sale/wuxi-2012');
select copyk3('销售出库单','sale/wuxi-2013');
select copyk3('销售出库单','sale/wuxi-201401-201410');
select copyk3('销售出库单','sale/wuxi-201411');
select copyk3('销售出库单','sale/wuxi-201412');
select copyk3('销售出库单','sale/zhejiang-2012');
select copyk3('销售出库单','sale/zhejiang-2013');
select copyk3('销售出库单','sale/zhejiang-201401-201406');
select copyk3('销售出库单','sale/zhejiang-201407-201410');
select copyk3('销售出库单','sale/zhejiang-201411');
select copyk3('销售出库单','sale/zhejiang-201412');

--零售单明细
delete from 零售单明细;
select copyk3('零售单明细','retail_d/hangzhou-0-201408');
select copyk3('零售单明细','retail_d/hongan-0-201408');
select copyk3('零售单明细','retail_d/hongan-201409');
select copyk3('零售单明细','retail_d/hongan-201410');
select copyk3('零售单明细','retail_d/hongan-201411');
select copyk3('零售单明细','retail_d/hongan-201412');
select copyk3('零售单明细','retail_d/huicai-0-201408');
select copyk3('零售单明细','retail_d/huicai-201409');
select copyk3('零售单明细','retail_d/huicai-201410');
select copyk3('零售单明细','retail_d/huicai-201411');
select copyk3('零售单明细','retail_d/huicai-201412');
select copyk3('零售单明细','retail_d/jiaxing-0-201408');
select copyk3('零售单明细','retail_d/kunshan-0-2014');
select copyk3('零售单明细','retail_d/suzhou-0-201408');
select copyk3('零售单明细','retail_d/suzhou-201409');
select copyk3('零售单明细','retail_d/suzhou-201410');
select copyk3('零售单明细','retail_d/suzhou-201411');
select copyk3('零售单明细','retail_d/suzhou-201412');
select copyk3('零售单明细','retail_d/wuxi-0-201408');
select copyk3('零售单明细','retail_d/wuxi-201409');
select copyk3('零售单明细','retail_d/wuxi-201410');
select copyk3('零售单明细','retail_d/wuxi-201411');
select copyk3('零售单明细','retail_d/wuxi-201412');

--零售单
delete from 零售单;
select copyk3('零售单','retail/hangzhou-0-201406');
select copyk3('零售单','retail/hongan-0-201406');
select copyk3('零售单','retail/hongan-201407');
select copyk3('零售单','retail/hongan-201408');
select copyk3('零售单','retail/hongan-201409');
select copyk3('零售单','retail/hongan-201410');
select copyk3('零售单','retail/hongan-201411');
select copyk3('零售单','retail/hongan-201412');
select copyk3('零售单','retail/huicai-0-201406');
select copyk3('零售单','retail/huicai-201407');
select copyk3('零售单','retail/huicai-201408');
select copyk3('零售单','retail/huicai-201409');
select copyk3('零售单','retail/huicai-201410');
select copyk3('零售单','retail/huicai-201411');
select copyk3('零售单','retail/huicai-201412');
select copyk3('零售单','retail/jiaxing-0-201406');
select copyk3('零售单','retail/kunshan-2012-2014');
select copyk3('零售单','retail/suzhou-0-201406');
select copyk3('零售单','retail/suzhou-201407');
select copyk3('零售单','retail/suzhou-201408');
select copyk3('零售单','retail/suzhou-201409');
select copyk3('零售单','retail/suzhou-201410');
select copyk3('零售单','retail/suzhou-201411');
select copyk3('零售单','retail/suzhou-201412');
select copyk3('零售单','retail/wuxi-0-201406');
select copyk3('零售单','retail/wuxi-201407');
select copyk3('零售单','retail/wuxi-201408');
select copyk3('零售单','retail/wuxi-201409');
select copyk3('零售单','retail/wuxi-201410');
select copyk3('零售单','retail/wuxi-201411');
select copyk3('零售单','retail/wuxi-201412');

--成本调整单
delete from 成本调整单;
select copyk3('成本调整单','adjust/guomei-0-201406');
select copyk3('成本调整单','adjust/guomei-201407-201506');
select copyk3('成本调整单','adjust/hangzhou-0-201506');
select copyk3('成本调整单','adjust/hongan-0-201506');
select copyk3('成本调整单','adjust/huicai-0-201506');
select copyk3('成本调整单','adjust/jiaxing-0-201406');
select copyk3('成本调整单','adjust/jinwuyue-0-201506');
select copyk3('成本调整单','adjust/kunshan-0-201506');
select copyk3('成本调整单','adjust/licai-0-201506');
select copyk3('成本调整单','adjust/linan-0-201506');
select copyk3('成本调整单','adjust/shanghai-0-201506');
select copyk3('成本调整单','adjust/shenyang-0-201506');
select copyk3('成本调整单','adjust/suzhou-0-201506');
select copyk3('成本调整单','adjust/wuxi-0-201506');
select copyk3('成本调整单','adjust/zhejiang-0-201506');
