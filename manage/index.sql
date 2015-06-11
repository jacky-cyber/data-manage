/**
 * 2015 cai
 *
 * 关键列加入索引
 */

drop index 销售出库单_部门_idx, 销售出库单_客户_idx, 销售出库单_产品长代码_idx;
create index 销售出库单_部门_idx on 销售出库单(部门);
create index 销售出库单_客户_idx on 销售出库单(客户代码);
create index 销售出库单_产品长代码_idx on 销售出库单(产品长代码);
create index 收发汇总表_会计期间_idx on 收发汇总表(会计期间);
