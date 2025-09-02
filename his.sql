-- ============================================================
-- HIS 数据库（带完整中文注释 + 初始数据）
-- 兼容 MySQL 8.0+
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
/*!40101 SET NAMES utf8mb4 */;

-- ========================= 基础主档 =========================
-- 患者主档（最基础表，无依赖）
CREATE TABLE `huanzhe` (
  `id`              bigint UNSIGNED NOT NULL COMMENT '主键ID',
  `name`            varchar(64) NOT NULL COMMENT '姓名',
  `phone`           varchar(32) NOT NULL COMMENT '联系电话（与姓名组成联合唯一）',
  `gender`          enum('男','女','未知') DEFAULT '未知' COMMENT '性别',
  `birthday`        date DEFAULT NULL COMMENT '出生日期',
  `id_no`           varchar(32) DEFAULT NULL COMMENT '证件号（可选）',
  `address`         varchar(255) DEFAULT NULL COMMENT '住址（可选）',
  `created_at`      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_phone` (`name`,`phone`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='患者主档';

INSERT INTO `huanzhe` (`id`,`name`,`phone`,`gender`,`birthday`,`id_no`,`address`,`created_at`,`updated_at`) VALUES
(1,'张三','13800000001','男','1990-05-20',NULL,'广州市天河区','2025-09-02 11:53:24','2025-09-02 11:53:24'),
(2,'李四','13800000002','女','1988-11-03',NULL,'深圳市南山区','2025-09-02 11:53:24','2025-09-02 11:53:24');

-- ========================= 理疗基础表 =========================
-- 理疗项目字典（被处方明细引用）
CREATE TABLE `liliao_xiangmu` (
  `id`         bigint UNSIGNED NOT NULL COMMENT '项目ID',
  `name`       varchar(128) NOT NULL COMMENT '项目名称（唯一）',
  `price`      decimal(12,2) NOT NULL COMMENT '标准单价',
  `remark`     varchar(255) DEFAULT NULL COMMENT '备注',
  `is_active`  tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗项目字典';

INSERT INTO `liliao_xiangmu` (`id`,`name`,`price`,`remark`,`is_active`) VALUES
(1,'推拿',128.00,'30分钟',1),
(2,'刮痧',98.00,'15分钟',1),
(3,'艾灸',118.00,'20分钟',1),
(4,'拔罐',88.00,'15分钟',1);

-- 药品字典（被西医处方明细引用）
CREATE TABLE `yaopin` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '药品ID',
  `fenlei`       enum('中药饮片','中成药','西药口服','西药输液','耗材') NOT NULL COMMENT '分类',
  `name`         varchar(128) NOT NULL COMMENT '药品名称',
  `spec`         varchar(128) DEFAULT NULL COMMENT '规格',
  `unit`         varchar(16) NOT NULL COMMENT '单位（盒/瓶/支/g 等）',
  `stock_qty`    decimal(14,3) NOT NULL DEFAULT '0.000' COMMENT '现库存数量',
  `cost_price`   decimal(12,4) DEFAULT NULL COMMENT '成本价（可选）',
  `sale_price`   decimal(12,4) DEFAULT NULL COMMENT '建议售价（可选）',
  `rec_dose`     varchar(64) DEFAULT NULL COMMENT '常用单次剂量（可选）',
  `default_usage` varchar(128) DEFAULT NULL COMMENT '默认用法（可选）',
  `remark`       varchar(255) DEFAULT NULL COMMENT '备注',
  `is_active`    tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用',
  `created_at`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_spec_unit` (`name`,`spec`,`unit`),
  KEY `idx_fenlei` (`fenlei`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='药品字典与库存';

INSERT INTO `yaopin` (`id`,`fenlei`,`name`,`spec`,`unit`,`stock_qty`,`cost_price`,`sale_price`,`rec_dose`,`default_usage`,`remark`,`is_active`,`created_at`) VALUES
(1,'中药饮片','黄芪','切片','g',5000.000,0.0500,0.1200,'10-30g','水煎服',NULL,1,'2025-09-02 11:53:24'),
(2,'中药饮片','桂枝','切片','g',4000.000,0.0600,0.1500,'6-9g','水煎服',NULL,1,'2025-09-02 11:53:24'),
(3,'中成药','藿香正气液','10ml*6支','盒',100.000,8.0000,16.0000,'一次10ml','口服',NULL,1,'2025-09-02 11:53:24'),
(4,'西药口服','阿莫西林胶囊','0.5g*24粒','盒',200.000,12.0000,26.0000,'0.5g','口服',NULL,1,'2025-09-02 11:53:24'),
(5,'西药口服','布洛芬缓释片','0.3g*20片','盒',150.000,15.0000,32.0000,'0.3g','口服',NULL,1,'2025-09-02 11:53:24'),
(6,'西药输液','0.9%氯化钠注射液','500ml','瓶',80.000,3.5000,8.0000,NULL,'静滴',NULL,1,'2025-09-02 11:53:24'),
(7,'耗材','一次性注射器','5ml','支',500.000,0.5000,1.0000,NULL,NULL,NULL,1,'2025-09-02 11:53:24');

-- ========================= 门诊就诊 =========================
-- 门诊就诊主表（被处方、医嘱、日志引用）
CREATE TABLE `jiuzhen` (
  `id`             bigint UNSIGNED NOT NULL COMMENT '主键ID',
  `patient_id`     bigint UNSIGNED NOT NULL COMMENT '患者ID，关联 huanzhe.id',
  `visit_no`       varchar(32) DEFAULT NULL COMMENT '就诊号（用于打印/对账）',
  `visit_time`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '就诊时间',
  `zhusu`          text COMMENT '主诉',
  `xianbingshi`    text COMMENT '现病史',
  `linchuang_dx`   varchar(255) DEFAULT NULL COMMENT '临床诊断',
  `zhongyi_dx`     varchar(255) DEFAULT NULL COMMENT '中医诊断',
  `remark`         text COMMENT '备注',
  `created_at`     timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_patient_time` (`patient_id`,`visit_time` DESC),
  CONSTRAINT `fk_jz_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='门诊就诊（完成）主表';

INSERT INTO `jiuzhen` (`id`,`patient_id`,`visit_no`,`visit_time`,`zhusu`,`xianbingshi`,`linchuang_dx`,`zhongyi_dx`,`remark`,`created_at`) VALUES
(1,1,'MZ20250901-001','2025-09-01 10:00:00','咳嗽，咽痛','受凉后出现发热咽痛3天','上呼吸道感染','风热犯肺','初诊','2025-09-02 11:53:24'),
(2,2,'MZ20250901-002','2025-09-01 11:00:00','颈肩酸痛','久坐工作，颈肩僵硬1月','颈型颈椎病','气滞血瘀','理疗评估','2025-09-02 11:53:24');

-- 就诊中会话表（被其他表无直接引用，但需在患者表后）
CREATE TABLE `jiuzhen_session` (
  `id`          bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `patient_id`  bigint UNSIGNED NOT NULL COMMENT '患者ID（唯一在诊中），关联 huanzhe.id',
  `started_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '进入就诊中的时间',
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近活跃时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_patient` (`patient_id`),
  KEY `idx_session_updated` (`updated_at` DESC),
  CONSTRAINT `fk_session_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='门诊就诊会话（就诊中）';

INSERT INTO `jiuzhen_session` (`id`,`patient_id`,`started_at`,`updated_at`) VALUES
(1,1,'2025-09-02 22:42:39','2025-09-02 22:42:39');

-- ========================= 处方相关 =========================
-- 处方主表（引用门诊就诊）
CREATE TABLE `chufang` (
  `id`            bigint UNSIGNED NOT NULL COMMENT '处方ID',
  `visit_id`      bigint UNSIGNED NOT NULL COMMENT '就诊ID，关联 jiuzhen.id',
  `leixing`       enum('中医','理疗','西医') NOT NULL COMMENT '处方类型',
  `biaoti`        varchar(255) DEFAULT NULL COMMENT '处方标题（可选）',
  `is_taocan`     tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否套餐处方',
  `fufa`          varchar(255) DEFAULT NULL COMMENT '中药/中成药服法提示',
  `jishu`         int DEFAULT NULL COMMENT '剂数/付数（中医）',
  `zhouqi`        varchar(64) DEFAULT NULL COMMENT '疗程周期描述',
  `meiri_cishu`   decimal(10,2) DEFAULT NULL COMMENT '每日次数（中医打印用）',
  `meici_liang`   varchar(64) DEFAULT NULL COMMENT '每次用量（中医打印用）',
  `yongyao_fangfa` varchar(255) DEFAULT NULL COMMENT '用药方法（补充）',
  `beizhu`        text COMMENT '处方备注',
  `total_amount`  decimal(12,2) DEFAULT NULL COMMENT '处方总金额（快照）',
  `moban_id`      bigint UNSIGNED DEFAULT NULL COMMENT '来源模板ID（可选）',
  `created_at`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_visit_type` (`visit_id`,`leixing`),
  CONSTRAINT `fk_cf_visit` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='处方主表';

INSERT INTO `chufang` (`id`,`visit_id`,`leixing`,`biaoti`,`is_taocan`,`fufa`,`jishu`,`zhouqi`,`meiri_cishu`,`meici_liang`,`yongyao_fangfa`,`beizhu`,`total_amount`,`moban_id`,`created_at`) VALUES
(1,1,'中医',NULL,0,'水煎分早晚2次',3,'3日',NULL,NULL,'饭后服','注意保暖',128.00,NULL,'2025-09-02 11:53:24'),
(2,2,'理疗',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'颈肩肌肉紧张',1280.00,NULL,'2025-09-02 11:53:24'),
(3,2,'理疗','肩颈调理套餐',1,NULL,NULL,NULL,NULL,NULL,NULL,'套餐有效期 90 天',1088.00,NULL,'2025-09-02 11:53:24'),
(4,1,'西医',NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,'出现胃不适请停药并复诊',86.00,NULL,'2025-09-02 11:53:24');

-- 理疗处方明细（引用处方主表和理疗项目）
CREATE TABLE `chufang_liliao_mx` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `chufang_id`   bigint UNSIGNED NOT NULL COMMENT '处方ID，关联 chufang.id',
  `seq`          int NOT NULL COMMENT '行号（处方内顺序）',
  `xiangmu_id`   bigint UNSIGNED DEFAULT NULL COMMENT '项目ID（可选），关联 liliao_xiangmu.id',
  `xiangmu_name` varchar(128) NOT NULL COMMENT '项目名称（快照）',
  `cishu`        int NOT NULL DEFAULT '1' COMMENT '次数',
  `danjia`       decimal(12,2) DEFAULT NULL COMMENT '单价（快照）',
  `jine`         decimal(12,2) DEFAULT NULL COMMENT '金额（快照）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`),
  KEY `idx_ll_item` (`xiangmu_id`),
  CONSTRAINT `fk_llmx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_llmx_item` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗处方明细';

INSERT INTO `chufang_liliao_mx` (`id`,`chufang_id`,`seq`,`xiangmu_id`,`xiangmu_name`,`cishu`,`danjia`,`jine`) VALUES
(1,2,1,1,'推拿',10,128.00,1280.00),
(2,3,1,1,'推拿',5,NULL,NULL),
(3,3,2,2,'刮痧',3,NULL,NULL),
(4,3,3,3,'艾灸',3,NULL,NULL);

-- 西医处方明细（引用处方主表和药品）
CREATE TABLE `chufang_xiyi_mx` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `chufang_id`   bigint UNSIGNED NOT NULL COMMENT '处方ID，关联 chufang.id',
  `seq`          int NOT NULL COMMENT '行号（处方内顺序）',
  `yaopin_id`    bigint UNSIGNED DEFAULT NULL COMMENT '药品ID（可选），关联 yaopin.id',
  `yaopin_name`  varchar(128) NOT NULL COMMENT '药品名称（快照）',
  `guige`        varchar(128) DEFAULT NULL COMMENT '规格（快照）',
  `yongfa`       varchar(128) DEFAULT NULL COMMENT '用法（po/iv 等）',
  `pinci`        varchar(64)  DEFAULT NULL COMMENT '频次（bid/tid/prn 等）',
  `meici_liang`  varchar(64)  DEFAULT NULL COMMENT '每次用量（快照）',
  `meiri_cishu`  varchar(64)  DEFAULT NULL COMMENT '每日次数（快照）',
  `tianshu`      int DEFAULT NULL COMMENT '天数',
  `beizhu`       varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`),
  KEY `idx_xy_yp` (`yaopin_id`),
  CONSTRAINT `fk_xymx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_xymx_yp` FOREIGN KEY (`yaopin_id`) REFERENCES `yaopin`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='西医处方明细';

INSERT INTO `chufang_xiyi_mx` (`id`,`chufang_id`,`seq`,`yaopin_id`,`yaopin_name`,`guige`,`yongfa`,`pinci`,`meici_liang`,`meiri_cishu`,`tianshu`,`beizhu`) VALUES
(1,4,1,4,'阿莫西林胶囊','0.5g*24粒','口服','bid','0.5g','2',5,NULL),
(2,4,2,5,'布洛芬缓释片','0.3g*20片','口服','prn','0.3g',NULL,3,'发热疼痛时服用');

-- 中药处方明细（仅引用处方主表）
CREATE TABLE `chufang_zhongyao_mx` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `chufang_id`   bigint UNSIGNED NOT NULL COMMENT '处方ID，关联 chufang.id',
  `seq`          int NOT NULL COMMENT '行号（处方内顺序）',
  `yaowei_name`  varchar(128) NOT NULL COMMENT '药味名称（快照）',
  `yongliang`    decimal(10,2) NOT NULL COMMENT '用量',
  `danwei`       varchar(16) NOT NULL COMMENT '单位（g/片 等）',
  `special_use`  varchar(128) DEFAULT NULL COMMENT '特殊用法（后下、先煎、打碎等）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`),
  CONSTRAINT `fk_zymx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='中药处方明细';

INSERT INTO `chufang_zhongyao_mx` (`id`,`chufang_id`,`seq`,`yaowei_name`,`yongliang`,`danwei`,`special_use`) VALUES
(1,1,1,'银花',12.00,'g',NULL),
(2,1,2,'连翘',12.00,'g',NULL),
(3,1,3,'薄荷',6.00,'g','后下'),
(4,1,4,'牛蒡子',9.00,'g',NULL),
(5,1,5,'荆芥',9.00,'g',NULL),
(6,1,6,'黄芩',10.00,'g',NULL),
(7,1,7,'桔梗',6.00,'g',NULL),
(8,1,8,'甘草',6.00,'g','炙'),
(9,1,9,'芦根',15.00,'g',NULL),
(10,1,10,'淡竹叶',6.00,'g',NULL),
(11,1,11,'杏仁',9.00,'g','打碎'),
(12,1,12,'生姜',3.00,'片','加减');

-- 理疗套餐主档（被套餐明细、购买单引用）
CREATE TABLE `liliao_taocan` (
  `id`          bigint UNSIGNED NOT NULL COMMENT '套餐ID',
  `name`        varchar(128) NOT NULL COMMENT '套餐名称（唯一）',
  `total_price` decimal(12,2) NOT NULL COMMENT '套餐总价',
  `remark`      varchar(255) DEFAULT NULL COMMENT '备注/有效期说明',
  `is_active`   tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗套餐主档';

INSERT INTO `liliao_taocan` (`id`,`name`,`total_price`,`remark`,`is_active`) VALUES
(1,'肩颈调理套餐',1088.00,'有效期 90 天',1);

-- 理疗套餐明细（引用套餐主档和理疗项目）
CREATE TABLE `liliao_taocan_mx` (
  `id`          bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `taocan_id`   bigint UNSIGNED NOT NULL COMMENT '套餐ID，关联 liliao_taocan.id',
  `xiangmu_id`  bigint UNSIGNED NOT NULL COMMENT '项目ID，关联 liliao_xiangmu.id',
  `xiangmu_name` varchar(128) NOT NULL COMMENT '项目名称（快照）',
  `total_times` int NOT NULL COMMENT '包含次数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_taocan_item` (`taocan_id`,`xiangmu_id`),
  KEY `idx_tc_item` (`xiangmu_id`),
  CONSTRAINT `fk_tcmx_tc` FOREIGN KEY (`taocan_id`) REFERENCES `liliao_taocan`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tcmx_item` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗套餐明细';

INSERT INTO `liliao_taocan_mx` (`id`,`taocan_id`,`xiangmu_id`,`xiangmu_name`,`total_times`) VALUES
(1,1,1,'推拿',5),
(2,1,2,'刮痧',3),
(3,1,3,'艾灸',3);

-- 套餐购买单（引用患者、套餐、处方）
CREATE TABLE `liliao_goumai` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '购买单ID',
  `patient_id`   bigint UNSIGNED NOT NULL COMMENT '患者ID',
  `buy_time`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '购买时间',
  `taocan_id`    bigint UNSIGNED DEFAULT NULL COMMENT '套餐ID（可空）',
  `taocan_name`  varchar(128) DEFAULT NULL COMMENT '套餐名称（快照）',
  `total_price`  decimal(12,2) NOT NULL COMMENT '应收总价',
  `source_cf_id` bigint UNSIGNED DEFAULT NULL COMMENT '来源处方ID（可空）',
  `remark`       varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_patient_time` (`patient_id`,`buy_time` DESC),
  KEY `idx_tc_id` (`taocan_id`),
  KEY `idx_src_cf` (`source_cf_id`),
  CONSTRAINT `fk_gm_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gm_tc` FOREIGN KEY (`taocan_id`) REFERENCES `liliao_taocan`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_gm_cf` FOREIGN KEY (`source_cf_id`) REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗套餐购买单';

INSERT INTO `liliao_goumai` (`id`,`patient_id`,`buy_time`,`taocan_id`,`taocan_name`,`total_price`,`source_cf_id`,`remark`) VALUES
(1,1,'2025-09-01 11:30:00',1,'肩颈调理套餐',1088.00,3,'线上支付');

-- 套餐购买明细（引用购买单和理疗项目）
CREATE TABLE `liliao_goumai_mingxi` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `goumai_id`    bigint UNSIGNED NOT NULL COMMENT '购买单ID，关联 liliao_goumai.id',
  `xiangmu_id`   bigint UNSIGNED NOT NULL COMMENT '项目ID，关联 liliao_xiangmu.id',
  `xiangmu_name` varchar(128) NOT NULL COMMENT '项目名称（快照）',
  `total_times`  int NOT NULL COMMENT '购买总次数',
  `used_times`   int NOT NULL DEFAULT '0' COMMENT '已用次数',
  PRIMARY KEY (`id`),
  KEY `idx_gm` (`goumai_id`),
  KEY `idx_item` (`xiangmu_id`),
  CONSTRAINT `fk_gmmx_gm` FOREIGN KEY (`goumai_id`) REFERENCES `liliao_goumai`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gmmx_item` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗套餐购买明细';

INSERT INTO `liliao_goumai_mingxi` (`id`,`goumai_id`,`xiangmu_id`,`xiangmu_name`,`total_times`,`used_times`) VALUES
(1,1,1,'推拿',5,1),
(2,1,2,'刮痧',3,0),
(3,1,3,'艾灸',3,0);

-- 理疗执行单（引用患者和处方）
CREATE TABLE `liliao_zhixing_dan` (
  `id`            bigint UNSIGNED NOT NULL COMMENT '执行单ID',
  `patient_id`    bigint UNSIGNED NOT NULL COMMENT '患者ID',
  `cf_id`         bigint UNSIGNED DEFAULT NULL COMMENT '来源处方ID（可空）',
  `exec_date`     date NOT NULL COMMENT '执行日期',
  `remark`        varchar(255) DEFAULT NULL COMMENT '备注/注意事项',
  `patient_sign`  varchar(255) DEFAULT NULL COMMENT '患者签字（图片路径或哈希）',
  `doctor_sign`   varchar(255) DEFAULT NULL COMMENT '医生签字（图片路径或哈希）',
  `created_at`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_patient_date` (`patient_id`,`exec_date` DESC),
  KEY `idx_cf` (`cf_id`),
  CONSTRAINT `fk_zx_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_zx_cf` FOREIGN KEY (`cf_id`) REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗执行单';

INSERT INTO `liliao_zhixing_dan` (`id`,`patient_id`,`cf_id`,`exec_date`,`remark`,`patient_sign`,`doctor_sign`,`created_at`) VALUES
(1,1,3,'2025-09-02','本单据仅作当次理疗执行确认',NULL,NULL,'2025-09-02 11:53:24');

-- 理疗执行明细（引用执行单）
CREATE TABLE `liliao_zhixing_mx` (
  `id`            bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `zhixing_id`    bigint UNSIGNED NOT NULL COMMENT '执行单ID，关联 liliao_zhixing_dan.id',
  `xiangmu_name`  varchar(128) NOT NULL COMMENT '执行项目名称（快照）',
  `progress_n`    int NOT NULL COMMENT '当前执行进度-已完成次数',
  `progress_m`    int NOT NULL COMMENT '当前执行进度-总次数',
  `snapshot_json` json DEFAULT NULL COMMENT '快照（如来自套餐、关联明细ID等）',
  PRIMARY KEY (`id`),
  KEY `idx_zhixing` (`zhixing_id`),
  CONSTRAINT `fk_zxmx_zx` FOREIGN KEY (`zhixing_id`) REFERENCES `liliao_zhixing_dan`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗执行明细';

INSERT INTO `liliao_zhixing_mx` (`id`,`zhixing_id`,`xiangmu_name`,`progress_n`,`progress_m`,`snapshot_json`) VALUES
(1,1,'推拿',2,5,'{\"from\":\"套餐\",\"goumai_mx_id\":1}'),
(2,1,'刮痧',1,3,'{\"from\":\"套餐\",\"goumai_mx_id\":2}');

-- 药库出入流水（引用药品）
CREATE TABLE `kucun_liushui` (
  `id`            bigint UNSIGNED NOT NULL COMMENT '流水ID',
  `yaopin_id`     bigint UNSIGNED NOT NULL COMMENT '药品ID，关联 yaopin.id',
  `liushui_type`  enum('入库','出库','调整') NOT NULL COMMENT '流水类型',
  `qty`           decimal(14,3) NOT NULL COMMENT '数量（正数）',
  `related_table` varchar(64) DEFAULT NULL COMMENT '关联来源表名（可选）',
  `related_id`    bigint UNSIGNED DEFAULT NULL COMMENT '关联来源表主键（可选）',
  `note`          varchar(255) DEFAULT NULL COMMENT '备注',
  `created_at`    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_yp_time` (`yaopin_id`,`created_at` DESC),
  KEY `idx_type_time` (`liushui_type`,`created_at` DESC),
  CONSTRAINT `fk_kc_yp` FOREIGN KEY (`yaopin_id`) REFERENCES `yaopin`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='药库出入流水';

INSERT INTO `kucun_liushui` (`id`,`yaopin_id`,`liushui_type`,`qty`,`related_table`,`related_id`,`note`,`created_at`) VALUES
(1,1,'入库',5000.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(2,2,'入库',4000.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(3,3,'入库',100.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(4,4,'入库',200.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(5,5,'入库',150.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(6,6,'入库',80.000,'init',NULL,'期初','2025-09-02 11:53:24'),
(7,7,'入库',500.000,'init',NULL,'期初','2025-09-02 11:53:24');

-- ========================= 模板/医嘱/日志 =========================
-- 处方模板主表（无依赖）
CREATE TABLE `moban_chufang` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '模板ID',
  `leixing`      enum('中医','西医') NOT NULL COMMENT '模板类型',
  `biaoti`       varchar(255) NOT NULL COMMENT '模板标题',
  `content_json` json DEFAULT NULL COMMENT '模板内容（JSON）',
  `is_active`    tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否启用',
  `created_at`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_type_active` (`leixing`,`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='处方模板主表';

INSERT INTO `moban_chufang` (`id`,`leixing`,`biaoti`,`content_json`,`is_active`,`created_at`) VALUES
(1,'中医','健脾益气方','{\"fufa\":\"水煎分早晚2次\",\"jishu\":3,\"zhouqi\":\"3日\"}',1,'2025-09-02 11:53:24'),
(2,'西医','上呼吸道感染处方','{\"remark\":\"多饮水休息\"}',1,'2025-09-02 11:53:24');

-- 西医模板明细（引用模板主表）
CREATE TABLE `moban_xiyi_mx` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `moban_id`     bigint UNSIGNED NOT NULL COMMENT '模板ID，关联 moban_chufang.id',
  `seq`          int NOT NULL COMMENT '行号',
  `yaopin_name`  varchar(128) NOT NULL COMMENT '药品名称（模板）',
  `guige`        varchar(128) DEFAULT NULL COMMENT '规格（模板）',
  `yongfa`       varchar(128) DEFAULT NULL COMMENT '用法（模板）',
  `pinci`        varchar(64)  DEFAULT NULL COMMENT '频次（模板）',
  `meici_liang`  varchar(64)  DEFAULT NULL COMMENT '每次用量（模板）',
  `meiri_cishu`  varchar(64)  DEFAULT NULL COMMENT '每日次数（模板）',
  `tianshu`      int DEFAULT NULL COMMENT '天数（模板）',
  `beizhu`       varchar(255) DEFAULT NULL COMMENT '备注（模板）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_moban_seq` (`moban_id`,`seq`),
  CONSTRAINT `fk_mxymx_mb` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='处方模板明细（西医）';

INSERT INTO `moban_xiyi_mx` (`id`,`moban_id`,`seq`,`yaopin_name`,`guige`,`yongfa`,`pinci`,`meici_liang`,`meiri_cishu`,`tianshu`,`beizhu`) VALUES
(1,2,1,'阿莫西林胶囊','0.5g*24粒','口服','bid','0.5g','2',5,NULL),
(2,2,2,'布洛芬缓释片','0.3g*20片','口服','prn','0.3g',NULL,3,'发热疼痛时用');

-- 中药模板明细（引用模板主表）
CREATE TABLE `moban_zhongyao_mx` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '明细ID',
  `moban_id`     bigint UNSIGNED NOT NULL COMMENT '模板ID，关联 moban_chufang.id',
  `seq`          int NOT NULL COMMENT '行号',
  `yaowei_name`  varchar(128) NOT NULL COMMENT '药味名称（模板）',
  `yongliang`    decimal(10,2) NOT NULL COMMENT '用量（模板）',
  `danwei`       varchar(16) NOT NULL COMMENT '单位（模板）',
  `special_use`  varchar(128) DEFAULT NULL COMMENT '特殊用法（模板）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_moban_seq` (`moban_id`,`seq`),
  CONSTRAINT `fk_mzymx_mb` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='处方模板明细（中药）';

INSERT INTO `moban_zhongyao_mx` (`id`,`moban_id`,`seq`,`yaowei_name`,`yongliang`,`danwei`,`special_use`) VALUES
(1,1,1,'黄芪',15.00,'g',NULL),
(2,1,2,'白术',10.00,'g',NULL),
(3,1,3,'茯苓',12.00,'g',NULL),
(4,1,4,'炙甘草',6.00,'g',NULL),
(5,1,5,'陈皮',6.00,'g',NULL);

-- 医嘱（引用门诊就诊）
CREATE TABLE `yizhu` (
  `id`           bigint UNSIGNED NOT NULL COMMENT '医嘱ID',
  `visit_id`     bigint UNSIGNED NOT NULL COMMENT '就诊ID，关联 jiuzhen.id',
  `content`      text NOT NULL COMMENT '医嘱内容',
  `copy_from_id` bigint UNSIGNED DEFAULT NULL COMMENT '复制来源医嘱ID（可空）',
  `created_at`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_visit` (`visit_id`),
  KEY `idx_copy_from` (`copy_from_id`),
  CONSTRAINT `fk_yz_visit` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_yz_copy`  FOREIGN KEY (`copy_from_id`) REFERENCES `yizhu`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='医嘱';

INSERT INTO `yizhu` (`id`,`visit_id`,`content`,`copy_from_id`,`created_at`) VALUES
(1,1,'多饮水休息，避免辛辣刺激',NULL,'2025-09-02 11:53:24'),
(2,1,'如发热>38.5℃可对症退热',NULL,'2025-09-02 11:53:24'),
(3,2,'注意工位人体工学，避免久坐',NULL,'2025-09-02 11:53:24');

-- 诊疗日志（引用门诊就诊）
CREATE TABLE `rizhi` (
  `id`         bigint UNSIGNED NOT NULL COMMENT '日志ID',
  `visit_id`   bigint UNSIGNED NOT NULL COMMENT '就诊ID，关联 jiuzhen.id',
  `content`    text NOT NULL COMMENT '日志内容',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `created_by` varchar(64) DEFAULT NULL COMMENT '记录人（医生/护士）',
  PRIMARY KEY (`id`),
  KEY `idx_visit_created` (`visit_id`,`created_at` DESC),
  CONSTRAINT `fk_rz_visit` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='诊疗日志';

INSERT INTO `rizhi` (`id`,`visit_id`,`content`,`created_at`,`created_by`) VALUES
(1,1,'完成问诊与体格检查，建议复诊时间 9/5','2025-09-02 11:53:24','王医生'),
(2,2,'完成颈肩评估，建议理疗10次','2025-09-02 11:53:24','李医生');

-- ========================= 次数使用记录 =========================
-- 理疗小次记录（引用患者、购买明细、项目、处方）
CREATE TABLE `liliao_xiaoci_jilu` (
  `id`            bigint UNSIGNED NOT NULL COMMENT '记录ID',
  `patient_id`    bigint UNSIGNED NOT NULL COMMENT '患者ID',
  `goumai_mx_id`  bigint UNSIGNED DEFAULT NULL COMMENT '关联购买明细ID（可空）',
  `xiangmu_id`    bigint UNSIGNED NOT NULL COMMENT '项目ID',
  `xiangmu_name`  varchar(128) NOT NULL COMMENT '项目名称（快照）',
  `count_used`    int NOT NULL DEFAULT '1' COMMENT '本次核销次数',
  `used_time`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '使用时间',
  `cf_id`         bigint UNSIGNED DEFAULT NULL COMMENT '关联处方ID（可空）',
  `operator_name` varchar(64) DEFAULT NULL COMMENT '操作人',
  `remark`        varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_patient_time` (`patient_id`,`used_time` DESC),
  KEY `idx_gm_mx` (`goumai_mx_id`),
  KEY `idx_item` (`xiangmu_id`),
  KEY `idx_cf_id` (`cf_id`),
  CONSTRAINT `fk_xc_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_xc_gmmx`    FOREIGN KEY (`goumai_mx_id`) REFERENCES `liliao_goumai_mingxi`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_xc_item`    FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_xc_cf`      FOREIGN KEY (`cf_id`) REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='理疗次数核销记录';

INSERT INTO `liliao_xiaoci_jilu` (`id`,`patient_id`,`goumai_mx_id`,`xiangmu_id`,`xiangmu_name`,`count_used`,`used_time`,`cf_id`,`operator_name`,`remark`) VALUES
(1,1,1,1,'推拿',1,'2025-09-02 10:30:00',2,'技师-小刘','感觉放松');

-- ========================= 视图（打印与剩余次数） =========================
DROP VIEW IF EXISTS `v_liliao_shengyu`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_liliao_shengyu` AS
SELECT
  gm.patient_id                         AS patient_id,
  gmm.id                                AS goumai_mx_id,
  gmm.xiangmu_id                        AS xiangmu_id,
  gmm.xiangmu_name                      AS xiangmu_name,
  GREATEST(gmm.total_times - gmm.used_times, 0) AS remain_times
FROM liliao_goumai_mingxi gmm
JOIN liliao_goumai gm ON gm.id = gmm.goumai_id;

DROP VIEW IF EXISTS `v_print_liliao`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_print_liliao` AS
SELECT
  cf.id          AS cf_id,
  jz.visit_time  AS visit_time,
  hz.name        AS patient_name,
  hz.phone       AS phone,
  cf.biaoti      AS biaoti,
  cf.is_taocan   AS is_taocan,
  cf.total_amount AS total_amount,
  cf.beizhu      AS beizhu,
  mx.seq         AS seq,
  mx.xiangmu_name AS xiangmu_name,
  mx.cishu       AS cishu,
  mx.danjia      AS danjia,
  mx.jine        AS jine
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
LEFT JOIN chufang_liliao_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '理疗'
ORDER BY cf.id ASC, mx.seq ASC;

DROP VIEW IF EXISTS `v_print_xiyi`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_print_xiyi` AS
SELECT
  cf.id           AS cf_id,
  jz.visit_time   AS visit_time,
  hz.name         AS patient_name,
  hz.phone        AS phone,
  cf.beizhu       AS beizhu,
  cf.total_amount AS total_amount,
  mx.seq          AS seq,
  mx.yaopin_name  AS yaopin_name,
  mx.guige        AS guige,
  mx.yongfa       AS yongfa,
  mx.pinci        AS pinci,
  mx.meici_liang  AS meici_liang,
  mx.meiri_cishu  AS meiri_cishu,
  mx.tianshu      AS tianshu,
  mx.beizhu       AS mx_beizhu
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
JOIN chufang_xiyi_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '西医'
ORDER BY cf.id ASC, mx.seq ASC;

DROP VIEW IF EXISTS `v_print_zhongyao`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_print_zhongyao` AS
SELECT
  cf.id           AS cf_id,
  jz.visit_time   AS visit_time,
  hz.name         AS patient_name,
  hz.phone        AS phone,
  cf.fufa         AS fufa,
  cf.jishu        AS jishu,
  cf.zhouqi       AS zhouqi,
  cf.meiri_cishu  AS meiri_cishu,
  cf.meici_liang  AS meici_liang,
  cf.yongyao_fangfa AS yongyao_fangfa,
  cf.beizhu       AS beizhu,
  cf.total_amount AS total_amount,
  mx.seq          AS seq,
  mx.yaowei_name  AS yaowei_name,
  mx.yongliang    AS yongliang,
  mx.danwei       AS danwei,
  mx.special_use  AS special_use
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
JOIN chufang_zhongyao_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '中医'
ORDER BY cf.id ASC, mx.seq ASC;