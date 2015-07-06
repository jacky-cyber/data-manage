class K3(object):
  """数据文件处理 for K3"""
  def __init__(self, path_org, path_new, pattern):
    super(K3, self).__init__()
    self.path_org = path_org
    self.path_new = path_new
    self.pattern = pattern
    self.copy()
    self.syn()
  def copy(self):
    dic_co = {'guomei':'国美', 'hangzhou':'杭州', 'hongan':'虹安', 'huicai':'卉彩', 'jiaxing':'嘉兴', 'kunshan':'昆山', 'suzhou':'苏州', 'wuxi':'无锡', 'zhejiang':'浙江', 'shanghai':'上海', 'jinwuyue':'金五月', 'linan':'临安', 'licai':'丽彩', 'shenyang':'沈阳'}
    for i, j, k in os.walk(self.path_org):
      path_dir = re.sub(self.path_org, self.path_new, i, 1)
      if not os.path.exists(path_dir):
        os.makedirs(path_dir)
      for m in k:
        path_org_file = re.sub(r'\\', r'/', os.path.join(i, m))
        if re.search(self.pattern, path_org_file):
          path_new_file = re.sub(self.path_org, self.path_new, path_org_file, 1)
          with open(path_org_file, 'r', errors="ignore") as fa, open(path_new_file, 'w+') as fb:
            ls = fa.readlines()
            if re.search(r'合计', ls[-1]):
              ls = ls[:-1]
            co = m.split('-')[0]
            if co in dic_co:
              add_col = '"' + path_new_file + '","' + dic_co[co] + '",'
            else:
              add_col = '"' + path_new_file + '",'
            for l in ls:
                fb.write(add_col + l)
  def syn(self):
    for i, j, k in os.walk(self.path_new):
      path_dir = re.sub(self.path_new, self.path_org, i, 1)
      if not os.path.exists(path_dir):
        shutil.rmtree(i)
    for i, j, k in os.walk(self.path_new):
      for m in k:
        path_new_file = os.path.join(i, m)
        path_org_file = re.sub(self.path_new, self.path_org, path_new_file, 1)
        if not os.path.exists(path_org_file) and m != 'dog.py':
          os.remove(path_new_file)
import os, re, shutil
K3('d:/data/o_import', 'd:/data/import', r'20150(630t|0705t|0706).txt')
