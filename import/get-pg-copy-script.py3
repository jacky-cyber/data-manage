import os.path,re

b = 'd:/data/import/'
d = {'card':'卡流水','other_in':'其他入库单', 'other_out':'其他出库单', 'overage':'盘盈单', 'purchase':'外购入库单', 'retail':'零售单', 'retail_c':'零售单客户', 'retail_d':'零售单明细', 'sale':'销售出库单', 'shortage':'盘亏单', 'warehouse':'收发汇总表','requisition':'调拨单','adjust':'成本调整单'}
result = ''
for i in d:
  p = b + i
  result += '\n' + '--' + d[i] + '\n' + 'delete from ' + d[i] + ';\n'
  for j in os.listdir(p):
    if ((i == 'adjust' and j.split('-')[-1] <= '201506.txt') or (not re.search(r'2015.*txt$', j))):
      result += "select copyk3('" + d[i] + "','" + i + "/" + re.sub(r'.txt$','',j) + "');\n"
with open('pg_copy_script.txt','w+') as f:
  f.write(result)
