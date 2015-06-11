# 2015 cai
#
# 输出K3原始导出文件的标题行，以检查列是否一致。

import os, re

p = 'd:/data/o_import'
r = '文件路径\t文件列名\n'
for i, j, k in os.walk(p):
  for m in k:
    o = re.sub(r'\\', r'/', os.path.join(i, m))
    with open(o, 'r') as f:
      r = r + o + '\t' + f.readline()
with open ('heade_line.txt','w+') as f1:
  f1.write(r)