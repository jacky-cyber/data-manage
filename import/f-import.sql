/**
 * 2015 cai
 *
 * 数据导入存储过程
 */

-- copyk3(text, text)
-- i: 表名, 文件相对'd:/data/import/'路径
-- o: 插入表
create or replace function copyk3(a text, b text) returns void as
$body$
begin
  execute format('copy %s from ''d:/data/import/%s.txt'' csv header delimiter '',''  encoding ''gbk''',a,b);
end
$body$
language plpgsql volatile;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- copygbk(text, text)
-- i: 表名,文件相对'd:/data/'路径
-- o: 插入表
create or replace function copygbk(a text, b text) returns void as
$body$
begin
  execute format('copy %s from ''d:/data/%s'' csv header delimiter '',''  encoding ''gbk''',a,b);
end
$body$
language plpgsql volatile;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- dataupdate(text, text, text)
-- i: 表名,表对应文件夹名,日期
-- o: 插入表
create or replace function dataupdate(t text, f text, m text) returns void as
$body$
begin
  if  m ~ e'^\\d{6}$' then
    if t = '收发汇总表' then
      execute format('delete from %s where (会计期间 || ''.01'')::date = ''%s01''::date;',t,m);
    else
      execute format('delete from %s where date_trunc(''month'',日期)::date = ''%s01''::date;',t,m);
    end if;
  end if;
  if t !~ '零售单' then
    execute format('
      select copyk3(''%s'',''%s/guomei-%s'');
      select copyk3(''%s'',''%s/hangzhou-%s'');
      select copyk3(''%s'',''%s/jinwuyue-%s'');
      select copyk3(''%s'',''%s/kunshan-%s'');
      select copyk3(''%s'',''%s/licai-%s'');
      select copyk3(''%s'',''%s/linan-%s'');
      select copyk3(''%s'',''%s/shanghai-%s'');
      select copyk3(''%s'',''%s/shenyang-%s'');
      select copyk3(''%s'',''%s/suzhou-%s'');
      select copyk3(''%s'',''%s/wuxi-%s'');
      select copyk3(''%s'',''%s/zhejiang-%s'');
    ',t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m,t,f,m);
  end if;
  execute format('
    select copyk3(''%s'',''%s/hongan-%s'');
    select copyk3(''%s'',''%s/huicai-%s'');
  ',t,f,m,t,f,m);
  if t = '收发汇总表' then
    delete from 收发汇总表 where 仓库 = '合计' or 仓库 like '%(小计)';
    delete from 收发汇总表 where coalesce("期初结存数量","期初结存金额","本期收入数量","本期收入金额","本期发出数量","本期发出金额","期末结存数量","期末结存金额") is null;
  end if;
end
$body$
language plpgsql volatile;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- cardflowupdate(text)
-- i: 日期
-- o: 插入表
create or replace function cardflowupdate(m text) returns void as
$body$
begin
  if m ~ e'^\\d{6}$' then
    execute format('delete from 卡流水 where date_trunc(''month'',业务日期)::date = ''%s01''::date;',m);
  end if;
  execute format('select copyk3(''卡流水'',''card/flow-%s'');',m);
end
$body$ language plpgsql volatile;
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- monthlyupdate(text,text)
-- i: 日期,会计期间
-- o: 插入表
create or replace function monthlyupdate(s text) returns void as
$body$
begin
  execute format('
    select cardflowupdate(''%s'');
    select dataupdate(''其他入库单'',''other_in'',''%s'');
    select dataupdate(''其他出库单'',''other_out'',''%s'');
    select dataupdate(''盘盈单'',''overage'',''%s'');
    select dataupdate(''外购入库单'',''purchase'',''%s'');
    select dataupdate(''零售单'',''retail'',''%s'');
    select dataupdate(''零售单明细'',''retail_d'',''%s'');
    select dataupdate(''零售单客户'',''retail_c'',''%s'');
    select dataupdate(''销售出库单'',''sale'',''%s'');
    select dataupdate(''盘亏单'',''shortage'',''%s'');
    select dataupdate(''收发汇总表'',''warehouse'',''%s'');
    select dataupdate(''调拨单'',''requisition'',''%s'');
  ',s,s,s,s,s,s,s,s,s,s,s,s);
end
$body$
language plpgsql volatile;
