/**
 * 2015 cai
 *
 * 集团各部门销售
 *
 * 单据('020051406','020051888','020051395','020051865','020049429','020053081','020052254','020051908','020053078','020050317') 的出库部门打错，还原为'国际业务部'。
 * 浙江账套内的金五月销售部还原为'国际业务部'。
 * 除销给商超外，浙江账套内部门('草业事业部','肥料介质部','海宁国美','花卉事业部','金五月销售部','丽彩销售部','温室花卉部','温室资材部','浙江丽彩','总部苗圃')的销售剔除。
 * 除销给商超外，浙江账套内部门'盆器饰品部'2014年以后的销售剔除。
 * 杭州账套内部门'草业事业部'2014年以后的销售剔除。
 * 除'国际业务部'外，摘要含'转库|转换仓库|从浙江虹越转移至杭州虹越|转仓|库存转移|移库|西溪店转虹安|转账套出库|库存转到产品部门'关键词之一的销售剔除。
 * 长安苗圃在国美账套以外的销售剔除。
 * 部门'温室资材部'合并到'上海虹越销售部'，'草业事业部' 合并到 '金五月销售部'。
 * 商超：2014年只统计浙江账套，2015年只统计虹安账套。
 * 门店：在2014-12-29至2014-12-31期间，门店摘要含'退回'的销售剔除。
 * 网店：'研究院'销给'999.0078.24'的算在'萌吖吖种子（淘宝）店';'花卉城项目部'销给'999.0089'的算在'海宁国际花卉城（淘宝）店';'多肉项目部'销给('999.0076','999.0066')或在虹安账套销给'999.0167'的算在'多肉时光（淘宝）店';'浦东宣桥店'销给'021.9999'的算在'源怡种苗（淘宝）店';'虹越家居（天猫）专营店'销给'573.450'的算在'虹越亚马逊店';'园艺家总部（淘宝）店' 销给'999.0162'的算在'虹越旗舰店'。
 * 绿植点：因为在原分销模式下各绿植点出库部门统一是绿植采供部，所以根据来源零售单来辨别绿植点。
 *
 * 注意事项：
 * 产品部门与门店之间的关系，在2014年是销售的，2015年变为调拨。
 */

-- 集团各部门销售
-----------------------------------------------------------------------------------------------------------------------------------------------------
select
  日历.年,
  case
    when t1.客户代码 = '999.0213' or t1.摘要 ~ '花彩商城' then '花彩商城店'
    when t1.客户代码 = '999.0078.24' and 部门.实名 = '研究院' then '萌吖吖种子（淘宝）店'
    when t1.客户代码 = '999.0089' and 部门.实名 = '花卉城项目部' then '海宁国际花卉城（淘宝）店'
    when (t1.客户代码 in ('999.0076','999.0066') or (t1.客户代码 = '999.0167' and t1.账套 = '虹安')) and 部门.实名 = '多肉项目部' then '多肉时光（淘宝）店'
    when t1.客户代码 in ('021.9998','021.9999') and 部门.实名 = '浦东宣桥店' then '源怡种苗（淘宝）店'
    when t1.客户代码 = '573.450' and 部门.实名 = '虹越家居（天猫）专营店' then '虹越亚马逊店'
    when t1.客户代码 = '999.0162' and 部门.实名 = '园艺家总部（淘宝）店' then '虹越旗舰店'
    when 部门.实名 = '绿植采供部' and lower(t1.单据编号) ~ 'rth|dx' then
      case substring(t1.单据编号,'\d{2}')
        when '09' then '昆山千灯点'
        when '23' then '海宁花卉城点'
        when '27' then '昌邑花木城点'
        when '28' then '无锡农博园点'
        when '31' then '绍兴东湖点'
        else '绿植采供部'
      end
    when 客户.是否商超客户 then '商超运营部'
    when 部门.实名 = '温室资材部' then '上海虹越销售部'
    when 部门.实名 = '草业事业部' then '金五月销售部'
    else 部门.实名
  end as 二级部门名称,
  sum(case when 客户.是否关联客户 then t1.未税金额 end) as 内销,
  sum(case when not coalesce(客户.是否关联客户,false) then t1.未税金额 end) as 外销,
  sum(t1.未税金额) as 总销
from
  销售出库单 t1
  left join 部门 on t1.部门 = 部门.名称
  left join 日历 on t1.日期 = 日历.日期
  left join 客户 on t1.客户代码 = 客户.代码
where
  ((not (t1.账套 = '浙江' and ((t1.部门 in ('草业事业部','肥料介质部','海宁国美','花卉事业部','金五月销售部','丽彩销售部','温室花卉部','温室资材部','浙江丽彩','总部苗圃')) or (t1.部门 in ('盆器饰品部') and t1.日期 >= '2014-01-01')))) or (客户.是否商超客户))
  and ((not coalesce(客户.是否商超客户,false)) or (t1.账套 = '浙江' and 日历.年 = 2014) or (t1.账套 = '虹安' and 日历.年 = 2015))
  and not(t1.账套 = '杭州' and t1.部门 in ('草业事业部') and t1.日期 >= '2014-01-01')
  and (not(coalesce(t1.摘要,'') ~ '转库|转换仓库|从浙江虹越转移至杭州虹越|转仓|库存转移|移库|西溪店转虹安|转账套出库|库存转到产品部门') or t1.部门 = '国际业务部')
  and not(部门.一级部门名称 = '门店运营部' and t1.日期 between '2014-12-29' and '2014-12-31' and coalesce(t1.摘要,'') ~ '退回')
  and not(t1.部门 = '长安苗圃' and t1.账套 != '国美')
group by
  1,2
order by
  1,2;
