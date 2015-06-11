/**
 * 2015 cai
 *
 * 代码段模板
 */

--产品分类
-------------------------------------------------------------------------------------------------------------------------------------------
-- 年宵花
case
    when 商品.全名 ~ '组合盆栽' then '组合盆栽'
    when 商品.全名 ~ '大花蕙兰|蝴蝶兰|幸福兰|杜鹃|安祖花|红掌|墨兰|凤梨|富贵竹|君子兰|蟹爪兰|仙客来|长寿花|多肉植物|洋兰类|蕨类|绿叶精灵|彩叶精灵|精品盆栽|盆花|灌木' then substring(商品.全名,'大花蕙兰|蝴蝶兰|幸福兰|杜鹃|安祖花|红掌|墨兰|凤梨|富贵竹|君子兰|蟹爪兰|仙客来|长寿花|多肉植物|洋兰类|蕨类|绿叶精灵|彩叶精灵|精品盆栽|盆花|灌木')
    when 商品.全名 ~ '朱顶红|百合|风信子|郁金香|水仙|马蹄莲|球根' then '球根类'
    else '其他'
end as 产品类别

-- 花园植物
case
    when 商品.产品名称 ~ '月季|铁线莲|绣球|果树|进口植物' then substring(商品.产品名称,'月季|铁线莲|绣球|果树|进口植物')
    else '其他'
end as 产品类别

-- 商超
-------------------------------------------------------------------------------------------------------------------------------------------
-- 仓库名称匹配
'华润|苏果|联华|星火|物美|小小'

-- 仓库代码
('571.3001','025.3801','025.3812','572.0499','571.9744','999.9989')