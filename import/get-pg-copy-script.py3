# 2015 cai
# 
# 生成PG数据库的K3数据文件导入脚本

import os.path,re

b = 'd:/data/import/'
d = {'card':'卡流水','other_in':'其他入库单', 'other_out':'其他出库单', 'overage':'盘盈单', 'purchase':'外购入库单', 'retail':'零售单', 'retail_c':'零售单客户', 'retail_d':'零售单明细', 'sale':'销售出库单', 'shortage':'盘亏单', 'warehouse':'收发汇总表','requisition':'调拨单'}
l = ['card', 'other_in', 'other_out', 'overage', 'purchase', 'retail', 'retail_c', 'retail_d', 'sale', 'shortage', 'warehouse','requisition']
result = ''
for i in l:
  p = b + i
  result += '\n' + '--' + d[i] + '\n' + 'delete from ' + d[i] + ';\n'
  for j in os.listdir(p):
    if (not re.search(r'2015.*txt$', j)):
      result += "select copyk3('" + d[i] + "','" + i + "/" + re.sub(r'.txt$','',j) + "');\n"
with open('pg_copy_script.txt','w+') as f:
  f.write(result)