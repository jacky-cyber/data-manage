/**
 * 2015 cai
 *
 * 基础资料表处理
 */

drop table if exists 日历, 周报日历, 商超名正则, 客户业务类型, 部门编号, 部门整合, 部门, 仓库, 仓库按代码, 仓库按名称, 机构整合, 机构, 卡资料, 卡类, 客户, 商品, 商品辅助, 商品经营目录, 省份;

-- 建表
---------------------------------------------------------------------------------------------------------------------------------------------------
create table 日历 as
select
  d::date as 日期,
  date_part('year',d)::int as 年,
  date_part('quarter',d)::int as 季度,
  date_part('month',d)::int as 月,
  to_char(d,'Dy') as 星期,
  hyyear(d::date) as 虹越年,
  hyweek(d::date) as 虹越周
from
  generate_series('2012-01-01'::date,'2015-12-31'::date,'1 days') d;
alter table 日历 add primary key (日期);

create table 周报日历 (
  日期 date,
  年 int,
  虹越年 int,
  虹越周 int
);
alter table 周报日历 add primary key (日期);

create table 商超名正则 as select '华润|苏果|联华|星火|物美|小小'::varchar(255) as 模式;

create table 客户业务类型 as select unnest('{ziyongcaozuo,zupencaozuo,baosuncaozuo}'::text[]) as 代码;

create table 部门编号 (
  模块编号 int,
  模块名称 varchar(255),
  一级部门编号 int,
  一级部门名称 varchar(255),
  二级部门编号 int,
  二级部门名称 varchar(255)
);

create table 部门整合 (
  文件路径 varchar(255),
  代码 int,
  名称 varchar(255),
  全名 varchar(255),
  部门电话 varchar(255),
  数库实体 varchar(255),
  对应仓库名称 varchar(255),
  备注 varchar(255),
  部门所属机构整合 varchar(255),
  商品部门 varchar(255),
  产部业务员 varchar(255),
  审核人 varchar(255),
  附件 varchar(255),
  图片 varchar(255)
);

create table 仓库 (
  文件路径 varchar(255),
  代码 varchar(255) primary key,
  名称 varchar(255),
  全名 varchar(255),
  分支机构整合 varchar(255),
  审核人 varchar(255),
  附件 varchar(255),
  图片 varchar(255)
);

create table 机构整合 (
  文件路径 varchar(255),
  代码 int,
  名称 varchar(255),
  全名 varchar(255),
  备注 varchar(255),
  审核人 varchar(255),
  附件 varchar(255),
  图片 varchar(255)
);
create table 卡资料 (
  文件路径 varchar(255),
  卡号 varchar(255) primary key,
  卡类型 varchar(255),
  发卡机构整合 varchar(255),
  当前储值 numeric(20,4),
  卡状态 varchar(255),
  冻结状态 varchar(255),
  发卡日期 date,
  会员名称 varchar(255),
  身份证号 varchar(255),
  性别 varchar(255),
  出生日期 date,
  手机  varchar(255),
  居住地址  varchar(255)
);

create table 卡类 (
  卡类型 varchar(255) primary key,
  卡类b varchar(255),
  卡类a varchar(255),
  折扣率 numeric(20,4),
  积分比率  numeric(20,4)
);

create table 客户 (
  文件路径 varchar(255),
  代码 varchar(255) primary key,
  名称 varchar(255),
  全名 varchar(255),
  简称 varchar(255),
  地址 varchar(255),
  联系人 varchar(255),
  电话 varchar(255),
  移动电话 varchar(255),
  审核人 varchar(255),
  附件 varchar(255),
  图片 varchar(255)
);

create table 商品 (
  文件路径 varchar(255),
  代码 varchar(255) primary key,
  产品名称 varchar(255),
  全名 varchar(255),
  商品条码 varchar(255),
  规格型号 varchar(255),
  销售单价 numeric(20,4),
  部门 varchar(255),
  税率 numeric(20,4),
  商品属性 varchar(255),
  计量单位组 varchar(255),
  商品所属类别 varchar(255),
  产品属性 varchar(255),
  商品大类 varchar(255),
  辅助属性5 varchar(255),
  审核人 varchar(255),
  附件 varchar(255),
  图片 varchar(255)
);

select * into 商品辅助 from 商品;

create table 商品经营目录 (
  文件路径 varchar(255),
  门店名称 varchar(255),
  门店编码 varchar(255),
  商品编码 varchar(255),
  零售价 numeric(20,4),
  操作日期 date
);

create table 省份 (
  省份 varchar(255),
  编号 int
);

-- 导入数据
-----------------------------------------------------------------------------------------------------------------------------------------------------
select copygbk('周报日历','other/week_rili.csv');
select copygbk('部门编号','other/dep_no.csv');
select copyk3('仓库','base/warehouse-20150708');
select copyk3('机构整合','base/institution-20150720');
select copyk3('卡资料','base/cardinfo-20150708');
select copygbk('卡类','other/card_class.csv');
select copyk3('客户','base/kehu-20150708');
select copyk3('商品','base/product-20150720');
select copyk3('商品经营目录','base/jingying-20150118');
select copyk3('部门整合','base/department-20150104');
select copyk3('部门整合','base/department-20150109');
select copyk3('部门整合','base/department-20150118');
select copyk3('部门整合','base/department-20150226');
select copyk3('部门整合','base/department-20150406');
select copyk3('部门整合','base/department-20150430');
select copyk3('部门整合','base/department-20150504');
select copyk3('部门整合','base/department-20150605');
select copyk3('部门整合','base/department-20150706');
select copyk3('部门整合','base/department-20150720');
select copyk3('商品辅助','base/product-aid-20150226');
select copygbk('省份','other/provin.txt');

-- 部门
-----------------------------------------------------------------------------------------------------------------------------------------------------
update 部门整合 set 名称 = '原苏州树山店' where 代码 = 216 and 名称 = '苏州树山店';  -- 该部门与苏州树山店冲突
delete from 部门整合 where 文件路径 ~ '20150104' and 代码 = 279;  -- 名称存在两个“海宁国际花卉城网店”

alter table 部门整合
  add column 现用名 varchar(255),
  add column 实名 varchar(255);

-- 一些部门在K3不存在了但在已导出单据中存在
insert into
  部门整合(文件路径,名称,现用名)
values
  ('20150101','绿植产品部（农博园）','绿植零批农博园点'),
  ('20150101','绿植产品部（海宁）','绿植零批花卉城点'),
  ('20150101','绿植产品部（花木城）','绿植零批花木城点'),
  ('20150101','昆山虹越生产部','绿植生产部'),
  ('20150101','海宁国际花卉城项目部','花园用品部'),
  ('20150101','植物营养部一部（杭州）','植物营养部'),
  ('20150101','浙江丽彩盆栽生产部','丽彩盆栽生产部'),
  ('20150101','虹越亚马逊店','虹越亚马逊店'),
  ('20150101','空部门','空部门');

-- 曾用名转现用名
update 部门整合 set 现用名 = t.名称 from (select * from 部门整合 where 文件路径 = (select max(文件路径) from 部门整合)) t where t.代码 = 部门整合.代码;
update
  部门整合
set
  现用名 =
  case 名称
    when '花园植物部' then '总部苗圃'
    when '介质肥料部' then '肥料介质部'
    when '浦东宣桥---源怡种苗站' then '源怡种苗站'
    else 名称
  end
where
  现用名 is null;

-- 实名
update
  部门整合
set
  实名 =
  case 现用名
    when '花木城店' then '昌邑花木城店'
    when '总部网店' then '园艺家总部（淘宝）店'
    when '花彩师网店' then '花彩盆栽（淘宝）店'
    when '花彩盆栽网店' then '花彩盆栽（淘宝）店'
    when '多肉时光网店' then '多肉时光（淘宝）店'
    when '萌吖吖种子店' then '萌吖吖种子（淘宝）店'
    when '源怡种苗站' then '源怡种苗（淘宝）店'
    when '海宁国际花卉城网店' then '海宁国际花卉城（淘宝）店'
    when '宿根花卉店' then '花彩商城店'
    when '虹越苏州宿根淘宝店' then '宿根花卉（淘宝）店'
    when '天猫家居店' then '虹越家居（天猫）专营店'
    when '绿植零批花卉城点' then '海宁花卉城点'
    when '绿植零批农博园点' then '无锡农博园点'
    when '绿植零批花木城点' then '昌邑花木城点'
    when '绿植零批千灯点' then '昆山千灯点'
    when '绿植零批东湖点' then '绍兴东湖点'
    when '盆器饰品部一' then '盆器饰品部'
    when '盆器饰品部二' then '盆器饰品部'
    when '温室花卉部' then '盆栽采购部'
    when '绿植产品部' then '绿植采供部'
    when '绿植零批嘉兴点' then '嘉兴植物园点'
    when '绿植零批硖石点' then '海宁硖石点'
    when '杭州西溪湿地' then '杭州西溪湿地店'
    when '植物营养部二部（虹安）' then '植物营养部'
    when '绿植零批夏溪点' then '常州夏溪点'
    when '绿植宁波镇海点' then '宁波镇海点'
    when '绿植上海浦南点' then '上海浦南点'
    else 现用名
  end;

create table 部门 as select distinct t1.名称,t1.现用名,t1.实名,t2.* from (select distinct 名称,现用名,实名 from 部门整合) t1 full join 部门编号 t2 on t1.实名 = t2.二级部门名称;
alter table 部门 add primary key (名称);

-- 机构
-------------------------------------------------------------------------------------------------------------------------------------------
alter table 机构整合 add column 实名 varchar(255);
update 机构整合 set 实名 =
  case 名称
    when '杭州虹越' then '杭州西溪店'
    when '虹越园艺家海宁硖石店' then '海宁硖石店'
    when '花木城店' then '昌邑花木城店'
    when '上海卉彩' then '浦东宣桥店'
    when '苏州虹越' then '苏州树山店'
    when '无锡虹越' then '无锡农博园店'
    when '浙江虹安' then '海宁金筑园店'
    when '浙江虹安园艺有限公司嘉兴分公司' then '嘉兴植物园店'
    when '海宁国际花卉城' then '花卉城经营部'
    when '昆山虹越（花木城）' then '昌邑花木城点'
    when '绿植产品部（海宁）' then '海宁花卉城点'
    when '绿植产品部（硖石）' then '海宁硖石点'
    when '绿植产品部（嘉兴）' then '嘉兴植物园点'
    when '昆山虹越' then '昆山千灯点'
    when '昆山虹越（千灯店）' then '昆山千灯点'
    when '昆山虹越（绍兴东湖）' then '绍兴东湖点'
    when '昆山虹越（农博园）' then '无锡农博园点'
    when '昆山虹越（常州夏溪）' then '常州夏溪点'
    when '绿植宁波镇海点' then '宁波镇海点'
    when '绿植上海浦南点' then '上海浦南点'
    else 名称
  end;
delete from 机构整合 where 代码 = 21;  -- 与18同样被禁用
create table 机构 as select distinct t1.名称,t1.实名,t2.* from 机构整合 t1 left join (select * from 部门编号 where 模块名称 = '平台') t2 on t1.实名= t2.二级部门名称;
alter table 机构 add primary key (名称);

-- 仓库
-------------------------------------------------------------------------------------------------------------------------------------------
alter table 仓库 add column 实名 varchar(255);
update 仓库 set 实名 =
  case 代码
    when '03.6001' then '海宁金筑园店'
    when '03.6003' then '海宁硖石店'
    when '03.6004' then '嘉兴植物园店'
    when '03.6005' then '杭州西溪店'
    when '03.6006' then '昌邑花木城店'
    when '04.6001' then '无锡农博园店'
    when '05.6001' then '杭州西溪店'
    when '08.6001' then '苏州树山店'
    when '14.4001' then '浦东宣桥店'
    when '16.4001' then '浦东宣桥店'
    when '22.6001' then '嘉兴植物园店'
    when '09.6001' then '昆山千灯点'
    when '09.6003' then '昌邑花木城点'
    when '09.6004' then '无锡农博园点'
    when '23.6001' then '海宁花卉城点'
    when '70.0009' then '宁波镇海点'  -- 其余绿植点均为标准名称
    when '90.1001' then '园艺家总部（淘宝）店'
    when '90.1002' then '花彩盆栽（淘宝）店'
    when '90.1003' then '多肉时光（淘宝）店'
    when '90.1004' then '萌吖吖种子（淘宝）店'
    when '90.1005' then '虹越园艺家预售店'
    when '90.1006' then '源怡种苗（淘宝）店'
    when '90.1007' then '海宁国际花卉城（淘宝）店'
    when '90.1008' then '宿根花卉（淘宝）店'
    when '90.2001' then '虹越家居（天猫）专营店'
    else 名称
  end;

update 仓库 set 实名 = '商超运营部' where 名称 ~ (select 模式 from 商超名正则);

create table 仓库按代码 as select distinct t1.代码,t1.名称,t1.实名,t2.* from 仓库 t1 left join (select * from 部门编号 where 模块名称 = '平台') t2 on t1.实名= t2.二级部门名称;
alter table 仓库按代码 add primary key (代码);

create table 仓库按名称 as select distinct t1.名称,t1.实名,t2.* from 仓库 t1 left join (select * from 部门编号 where 模块名称 = '平台') t2 on t1.实名= t2.二级部门名称;
alter table 仓库按名称 add primary key (名称);

-- 客户
-------------------------------------------------------------------------------------------------------------------------------------------
alter table 客户 add column 是否关联客户 boolean default false;
update
  客户
set
  是否关联客户 = true
where
  代码 in ('021.0653','021.0751','025.0810','025.1324','025.2301','571.1141','571.2224','571.9146','571.9164','573.495','573.527','573.850','999.0012','999.0040','573.1031');

alter table 客户 add column 是否商超客户 boolean default false;
update
  客户
set
  是否商超客户 = true
where
  代码 in ('571.3001','025.3801','025.3812','572.0499','571.9744','999.9989');

-- 商品
-------------------------------------------------------------------------------------------------------------------------------------------
insert into 商品 select * from 商品辅助 where 代码 not in (select 代码 from 商品);
