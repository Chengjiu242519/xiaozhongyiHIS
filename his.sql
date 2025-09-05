-- 建议：会话字符集 & 北京时间（会话级）
SET NAMES utf8mb4;
SET time_zone = '+08:00';

/* 若重复执行，先清理依赖对象 */
DROP VIEW IF EXISTS v_kexuan_yaopin;

/* =====================================================================
 1) 患者 / 门诊（先建）
===================================================================== */

-- 1.1 患者主档：huanzhe（业务主键：bianhao = YYYYMMDDNNN）
DROP TABLE IF EXISTS huanzhe;
CREATE TABLE huanzhe (
  bianhao VARCHAR(20) PRIMARY KEY COMMENT '患者编号：YYYYMMDDNNN，示例 20250905001',
  xingming VARCHAR(80) NOT NULL COMMENT '姓名',
  xingbie CHAR(1) DEFAULT 'U' COMMENT '性别：M/F/O/U',
  chusheng_riqi DATE NULL COMMENT '出生日期',
  dianhua VARCHAR(40) NULL COMMENT '联系电话',
  dizhi VARCHAR(255) NULL COMMENT '地址',
  guomin_shi VARCHAR(255) NULL COMMENT '过敏史',
  jiwang_shi TEXT NULL COMMENT '既往史',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_huanzhe_xingming (xingming),
  KEY idx_huanzhe_dianhua (dianhua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者主档';

-- 1.2 就诊记录：jiuzhen（完成接诊时才扣库存）
DROP TABLE IF EXISTS jiuzhen;
CREATE TABLE jiuzhen (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '就诊自增ID',
  huanzhe_bianhao VARCHAR(20) NOT NULL COMMENT '患者编号 → huanzhe.bianhao',
  jiuzhen_shijian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '就诊时间',
  zhuangtai VARCHAR(20) NOT NULL DEFAULT 'caogao' COMMENT '状态：caogao/jiezhenzhong/wancheng/quxiao',
  linchuang_zhenduan TEXT NULL COMMENT '临床诊断',
  zhongyi_zhenduan TEXT NULL COMMENT '中医诊断',
  beizhu TEXT NULL COMMENT '备注（体格等临时信息也写这里）',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_jiuzhen_zhuangtai_time (zhuangtai, jiuzhen_shijian),
  KEY idx_jiuzhen_huanzhe_time (huanzhe_bianhao, jiuzhen_shijian)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='就诊记录';

/* =====================================================================
 2) 药房（直接库存）
===================================================================== */

-- 2.1 药品：yaopin（直接库存；仅可开=启用且库存>0）
DROP TABLE IF EXISTS yaopin;
CREATE TABLE yaopin (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '药品ID',
  zhonglei VARCHAR(20) NOT NULL COMMENT '种类：zhongyao/xiyao',
  mingcheng VARCHAR(200) NOT NULL COMMENT '药品名称',
  danwei VARCHAR(20) NOT NULL COMMENT '最小单位：片/袋/g/ml 等',
  jinjia DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '进价（最小单位）',
  maijia DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '卖价（最小单位）',
  guoqi_riqi DATE NULL COMMENT '过期日期（简化：单批）',
  kucun_liang DECIMAL(12,3) NOT NULL DEFAULT 0.000 COMMENT '库存量（最小单位）',
  moren_yongfa VARCHAR(255) NULL COMMENT '默认用法（可空）',
  zui_xiao_danwei_liang DECIMAL(12,3) NULL COMMENT '最小单位量（每包装含多少最小单位，选填）',
  qiyong TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用：1启用/0停用',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_yaopin_mq_name (qiyong, kucun_liang, mingcheng),
  KEY idx_yaopin_zhonglei (zhonglei, qiyong),
  KEY idx_yaopin_mingcheng (mingcheng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='药品（直接库存）';

-- 2.2 药品报损：yaopin_baosun（人工扣减，应用层同步减少库存）
DROP TABLE IF EXISTS yaopin_baosun;
CREATE TABLE yaopin_baosun (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '报损ID',
  yaopin_id BIGINT UNSIGNED NOT NULL COMMENT '药品ID',
  shuliang DECIMAL(12,3) NOT NULL COMMENT '报损数量（最小单位）',
  yuanyin VARCHAR(120) NULL COMMENT '原因（过期/破损等）',
  baosun_shijian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报损时间',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  KEY idx_baosun_yaopin (yaopin_id),
  KEY idx_baosun_time (baosun_shijian)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='药品报损记录';

/* =====================================================================
 3) 理疗（单项目 & 套餐）
===================================================================== */

-- 3.1 理疗项目：liliao_xiangmu
DROP TABLE IF EXISTS liliao_xiangmu;
CREATE TABLE liliao_xiangmu (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '理疗项目ID',
  mingcheng VARCHAR(120) NOT NULL COMMENT '项目名称',
  jiage DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '单次价格',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  qiyong TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_xiangmu_qiyong_ming (qiyong, mingcheng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='理疗单项目';

-- 3.2 理疗套餐：liliao_taocan（多项目不同次数）
DROP TABLE IF EXISTS liliao_taocan;
CREATE TABLE liliao_taocan (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '套餐ID',
  mingcheng VARCHAR(120) NOT NULL COMMENT '套餐名称',
  jiage DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '套餐总价',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  qiyong TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='理疗套餐（多项目）';

-- 3.3 套餐明细：liliao_taocan_mingxi（项目+次数）
DROP TABLE IF EXISTS liliao_taocan_mingxi;
CREATE TABLE liliao_taocan_mingxi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '套餐明细ID',
  taocan_id BIGINT UNSIGNED NOT NULL COMMENT '套餐ID → liliao_taocan.id',
  xiangmu_id BIGINT UNSIGNED NOT NULL COMMENT '项目ID → liliao_xiangmu.id',
  cishu INT NOT NULL DEFAULT 0 COMMENT '该项目包含次数',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  KEY idx_taocan_mingxi_taocan (taocan_id),
  KEY idx_taocan_mingxi_xiangmu (xiangmu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='理疗套餐明细';

-- 3.4 患者套餐（头）：huanzhe_taocan
DROP TABLE IF EXISTS huanzhe_taocan;
CREATE TABLE huanzhe_taocan (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '患者套餐ID',
  huanzhe_bianhao VARCHAR(20) NOT NULL COMMENT '患者编号',
  taocan_id BIGINT UNSIGNED NOT NULL COMMENT '购买的套餐ID',
  goumai_shijian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '购买时间',
  zong_cishu INT NOT NULL DEFAULT 0 COMMENT '总次数（冗余）',
  shengyu_cishu INT NOT NULL DEFAULT 0 COMMENT '剩余总次数（快速查询）',
  zhuangtai VARCHAR(20) NULL COMMENT '状态：active/expired/tuikuan 等',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  KEY idx_hztc_huan_zhuang (huanzhe_bianhao, zhuangtai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者购买的理疗套餐（配额头）';

-- 3.5 患者套餐配额（项目级）：huanzhe_taocan_mingxi
DROP TABLE IF EXISTS huanzhe_taocan_mingxi;
CREATE TABLE huanzhe_taocan_mingxi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '患者套餐明细ID',
  huanzhe_taocan_id BIGINT UNSIGNED NOT NULL COMMENT '患者套餐ID',
  xiangmu_id BIGINT UNSIGNED NOT NULL COMMENT '理疗项目ID',
  zong_cishu INT NOT NULL DEFAULT 0 COMMENT '本项目总次数',
  shengyu_cishu INT NOT NULL DEFAULT 0 COMMENT '本项目剩余次数',
  KEY idx_hztc_mx_head_item (huanzhe_taocan_id, xiangmu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='患者套餐配额（项目级）';

-- 3.6 理疗消次记录：liliao_xiaoci
DROP TABLE IF EXISTS liliao_xiaoci;
CREATE TABLE liliao_xiaoci (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '消次ID',
  huanzhe_bianhao VARCHAR(20) NOT NULL COMMENT '患者编号',
  xiangmu_id BIGINT UNSIGNED NOT NULL COMMENT '理疗项目ID',
  laiyuan VARCHAR(20) NOT NULL COMMENT '来源：danxiangmu/taocan',
  laiyuan_mingxi_id BIGINT UNSIGNED NULL COMMENT '若来源为套餐：对应 huanzhe_taocan_mingxi.id',
  xiaoci_shijian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '消次时间',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  KEY idx_xiaoci_huan_time (huanzhe_bianhao, xiaoci_shijian)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='理疗消次记录';

/* =====================================================================
 4) 处方（统一头 + JSON 明细）与模板
===================================================================== */

-- 4.1 处方头：chufang
DROP TABLE IF EXISTS chufang;
CREATE TABLE chufang (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '处方ID',
  jiuzhen_id BIGINT UNSIGNED NULL COMMENT '就诊ID → jiuzhen.id（允许空）',
  huanzhe_bianhao VARCHAR(20) NOT NULL COMMENT '患者编号',
  leixing VARCHAR(10) NOT NULL COMMENT '处方类型：zhongyao/liliao/xiyao',
  bingqing_xinxi TEXT NULL COMMENT '病情/诊断摘要（抬头展示）',
  neirong_json JSON NOT NULL COMMENT '处方详细内容（多味中药/多项目理疗/多药，含用法）',
  zong_jine DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT '总费用（前端计算写入）',
  yisheng_qianming VARCHAR(80) NULL COMMENT '医生签名',
  yishoufei TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否已收费：默认1',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  gengxin_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_chufang_jz (jiuzhen_id),
  KEY idx_chufang_hz_lx (huanzhe_bianhao, leixing)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='处方（统一头+JSON 明细）';

-- 4.2 处方模板：chufang_moban（与处方同结构，便于一键插入）
DROP TABLE IF EXISTS chufang_moban;
CREATE TABLE chufang_moban (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '处方模板ID',
  leixing VARCHAR(10) NOT NULL COMMENT '模板类型：zhongyao/liliao/xiyao',
  mingcheng VARCHAR(120) NOT NULL COMMENT '模板名称（如：桂枝汤）',
  neirong_json JSON NOT NULL COMMENT '模板内容（与处方同结构）',
  beizhu VARCHAR(255) NULL COMMENT '备注',
  qiyong TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  chuangjian_shijian TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  KEY idx_moban_lx_mc (leixing, mingcheng)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='处方模板';

/* =====================================================================
 5) 编号序列表（不回填编号，保证每日自增）
===================================================================== */

-- 5.1 编号序列表：bianhao_xulie（唯一键：riqi+mokuai）
DROP TABLE IF EXISTS bianhao_xulie;
CREATE TABLE bianhao_xulie (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT '序列ID',
  riqi DATE NOT NULL COMMENT '日期（例如 2025-09-05）',
  mokuai VARCHAR(32) NOT NULL COMMENT '模块名（如 huanzhe）',
  dangri_zuidaxuhao INT NOT NULL DEFAULT 0 COMMENT '当日最大序号',
  UNIQUE KEY uk_bianhao_riqi_mk (riqi, mokuai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='编号序列表（不回填方案）';

/* =====================================================================
 6) 视图（最后创建）
===================================================================== */

-- 6.1 可开药视图：仅显示启用且库存>0 的药品
CREATE OR REPLACE VIEW v_kexuan_yaopin AS
SELECT id, zhonglei, mingcheng, danwei, maijia, kucun_liang
FROM yaopin
WHERE qiyong = 1 AND kucun_liang > 0;
