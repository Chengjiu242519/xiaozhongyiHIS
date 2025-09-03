-- ============================================================
-- HIS（门诊/药房/理疗/处方模板）数据库全量创建脚本
-- 兼容 MySQL 8.0+；字符集 utf8mb4；已按外键拓扑顺序创建
-- ============================================================

-- 0) 初始化与库
DROP DATABASE IF EXISTS `his`;
CREATE DATABASE `his` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `his`;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
/*!40101 SET NAMES utf8mb4 */;

-- ============================================================
-- 一、基础主档（无外键依赖）
-- ============================================================

-- 1. 患者主档
CREATE TABLE `huanzhe` (
  `id`                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name`                   VARCHAR(64)  NOT NULL COMMENT '姓名',
  `phone`                  VARCHAR(32)  NOT NULL COMMENT '联系电话（与姓名组成联合唯一）',
  `gender`                 ENUM('男','女','未知') DEFAULT '未知' COMMENT '性别',
  `birthday`               DATE DEFAULT NULL COMMENT '出生日期',
  `id_no`                  VARCHAR(32)  DEFAULT NULL COMMENT '证件号（可选）',
  `address`                VARCHAR(255) DEFAULT NULL COMMENT '住址（可选）',
  `allergy_history`        TEXT         DEFAULT NULL COMMENT '过敏史（自由文本）',
  `past_medical_history`   TEXT         DEFAULT NULL COMMENT '既往史（自由文本）',
  `emergency_contact`      VARCHAR(64)  DEFAULT NULL COMMENT '紧急联系人姓名',
  `emergency_phone`        VARCHAR(32)  DEFAULT NULL COMMENT '紧急联系人电话',
  `created_at`             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at`             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name_phone` (`name`,`phone`),
  KEY `idx_phone` (`phone`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB COMMENT='患者主档';

-- 2. 药品字典
CREATE TABLE `yaopin` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '药品ID',
  `name`       VARCHAR(128) NOT NULL COMMENT '药品名（唯一）',
  `spec`       VARCHAR(128) DEFAULT NULL COMMENT '规格',
  `unit`       VARCHAR(16)  DEFAULT NULL COMMENT '单位（盒/片/袋等）',
  `price`      DECIMAL(12,2) DEFAULT NULL COMMENT '参考单价',
  `pinyin`     VARCHAR(64)  DEFAULT NULL COMMENT '拼音码（可选）',
  `is_active`  TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB COMMENT='药品字典';

-- 3. 理疗项目字典
CREATE TABLE `liliao_xiangmu` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `name`       VARCHAR(128) NOT NULL COMMENT '项目名称（唯一）',
  `price`      DECIMAL(12,2) NOT NULL COMMENT '标准单价',
  `remark`     VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `is_active`  TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB COMMENT='理疗项目字典';

-- 4. 理疗套餐（及明细会在后面建立）
CREATE TABLE `liliao_taocan` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '套餐ID',
  `name`        VARCHAR(128) NOT NULL COMMENT '套餐名称（唯一）',
  `total_times` INT NOT NULL DEFAULT 0 COMMENT '总次数（可按明细分配）',
  `price`       DECIMAL(12,2) NOT NULL COMMENT '套餐价格',
  `remark`      VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB COMMENT='理疗套餐';

-- 5. 处方模板主表
CREATE TABLE `moban_chufang` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name`           VARCHAR(128) NOT NULL COMMENT '模板名称（唯一）',
  `leixing`        ENUM('中医','西医','理疗') NOT NULL COMMENT '模板类型',
  `meici_liang`    VARCHAR(64)  DEFAULT NULL COMMENT '每次量（示例/默认）',
  `yongyao_fangfa` VARCHAR(128) DEFAULT NULL COMMENT '用药方法/疗法说明（默认）',
  `beizhu`         VARCHAR(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB COMMENT='处方模板主表';

-- 6. 系统日志（可选）
CREATE TABLE `rizhi` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `level`      VARCHAR(16)  NOT NULL DEFAULT 'INFO' COMMENT '级别',
  `action`     VARCHAR(64)  NOT NULL COMMENT '动作',
  `detail`     TEXT         DEFAULT NULL COMMENT '详情',
  `visit_id`   BIGINT UNSIGNED DEFAULT NULL COMMENT '关联就诊ID（可空）',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='系统日志';


-- ============================================================
-- 二、门诊就诊（主线：就诊主表、会话、草稿）
-- ============================================================

-- 7. 就诊主表
CREATE TABLE `jiuzhen` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '就诊ID',
  `patient_id`    BIGINT UNSIGNED NOT NULL COMMENT '患者ID，关联 huanzhe.id',
  `visit_no`      VARCHAR(32)  DEFAULT NULL COMMENT '就诊号（可选）',
  `visit_time`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '就诊完成时间',
  `zhusu`         TEXT DEFAULT NULL COMMENT '主诉',
  `xianbingshi`   TEXT DEFAULT NULL COMMENT '现病史',
  `linchuang_dx`  VARCHAR(255) DEFAULT NULL COMMENT '临床诊断',
  `zhongyi_dx`    VARCHAR(255) DEFAULT NULL COMMENT '中医诊断',
  `remark`        TEXT DEFAULT NULL COMMENT '备注',
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_patient` (`patient_id`),
  KEY `idx_visit_time` (`visit_time`),
  CONSTRAINT `fk_jz_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='就诊主表';

-- 8. 就诊中会话（左栏“就诊中”常显；同一患者唯一在诊中）
CREATE TABLE `jiuzhen_session` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `patient_id`  BIGINT UNSIGNED NOT NULL COMMENT '患者ID（唯一在诊中）',
  `started_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '进入就诊中的时间',
  `updated_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近活跃时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_patient` (`patient_id`),
  CONSTRAINT `fk_session_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='就诊中会话';

-- 9. 就诊草稿（保存后可切换患者，完成时落库到 jiuzhen）
CREATE TABLE `jiuzhen_draft` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `patient_id`    BIGINT UNSIGNED NOT NULL COMMENT '患者ID（唯一一份草稿）',
  `zhusu`         TEXT DEFAULT NULL COMMENT '主诉（草稿）',
  `xianbingshi`   TEXT DEFAULT NULL COMMENT '现病史（草稿）',
  `linchuang_dx`  VARCHAR(255) DEFAULT NULL COMMENT '临床诊断（草稿）',
  `zhongyi_dx`    VARCHAR(255) DEFAULT NULL COMMENT '中医诊断（草稿）',
  `remark`        TEXT DEFAULT NULL COMMENT '备注（草稿）',
  `updated_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最近保存时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_draft_patient` (`patient_id`),
  CONSTRAINT `fk_draft_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='门诊就诊草稿';


-- ============================================================
-- 三、处方（主表+明细；中医/西医/理疗）
-- ============================================================

-- 10. 处方主表
CREATE TABLE `chufang` (
  `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '处方ID',
  `visit_id`       BIGINT UNSIGNED NOT NULL COMMENT '就诊ID，关联 jiuzhen.id',
  `leixing`        ENUM('中医','西医','理疗') NOT NULL COMMENT '处方类型',
  `meici_liang`    VARCHAR(64)  DEFAULT NULL COMMENT '每次量/付数（可空）',
  `yongyao_fangfa` VARCHAR(128) DEFAULT NULL COMMENT '用药方法/疗法',
  `beizhu`         VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `total_amount`   DECIMAL(12,2) DEFAULT NULL COMMENT '金额（可选聚合）',
  `created_at`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_visit` (`visit_id`),
  CONSTRAINT `fk_cf_visit` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='处方主表';

-- 11. 理疗处方明细
CREATE TABLE `chufang_liliao_mx` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `chufang_id`  BIGINT UNSIGNED NOT NULL COMMENT '处方ID',
  `seq`         INT NOT NULL COMMENT '行号',
  `xiangmu_id`  BIGINT UNSIGNED NOT NULL COMMENT '理疗项目ID',
  `xiangmu_name` VARCHAR(128) NOT NULL COMMENT '项目名称（冗余快照）',
  `cishu`       INT DEFAULT NULL COMMENT '次数（若走套餐可为空）',
  `danjia`      DECIMAL(12,2) DEFAULT NULL COMMENT '单价（冗余）',
  `jine`        DECIMAL(12,2) DEFAULT NULL COMMENT '金额（冗余）',
  PRIMARY KEY (`id`),
  KEY `idx_cf` (`chufang_id`),
  KEY `idx_ll_item` (`xiangmu_id`),
  CONSTRAINT `fk_llmx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_llmx_item` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`)
) ENGINE=InnoDB COMMENT='理疗处方明细';

-- 12. 西医处方明细
CREATE TABLE `chufang_xiyi_mx` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `chufang_id`  BIGINT UNSIGNED NOT NULL COMMENT '处方ID',
  `seq`         INT NOT NULL COMMENT '行号',
  `yaopin_id`   BIGINT UNSIGNED NOT NULL COMMENT '药品ID',
  `yaowei_name` VARCHAR(128) NOT NULL COMMENT '药味/药品名称（冗余快照）',
  `yongliang`   DECIMAL(12,3) DEFAULT NULL COMMENT '用量',
  `danwei`      VARCHAR(16)  DEFAULT NULL COMMENT '单位',
  `special_use` TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '特殊用法标记',
  PRIMARY KEY (`id`),
  KEY `idx_cf` (`chufang_id`),
  KEY `idx_yp` (`yaopin_id`),
  CONSTRAINT `fk_xymx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_xymx_yp` FOREIGN KEY (`yaopin_id`)  REFERENCES `yaopin`(`id`)
) ENGINE=InnoDB COMMENT='西医处方明细';

-- 13. 中医处方明细
CREATE TABLE `chufang_zhongyao_mx` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `chufang_id`  BIGINT UNSIGNED NOT NULL COMMENT '处方ID',
  `seq`         INT NOT NULL COMMENT '行号',
  `yaowei_name` VARCHAR(128) NOT NULL COMMENT '药味名',
  `yongliang`   DECIMAL(12,3) DEFAULT NULL COMMENT '用量',
  `danwei`      VARCHAR(16)  DEFAULT NULL COMMENT '单位',
  `special_use` TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '特殊用法标记',
  PRIMARY KEY (`id`),
  KEY `idx_cf` (`chufang_id`),
  CONSTRAINT `fk_zymx_cf` FOREIGN KEY (`chufang_id`) REFERENCES `chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='中医处方明细';


-- ============================================================
-- 四、理疗套餐与购买/执行
-- ============================================================

-- 14. 理疗套餐明细（定义套餐包含的项目及次数）
CREATE TABLE `liliao_taocan_mx` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `taocan_id`   BIGINT UNSIGNED NOT NULL COMMENT '套餐ID',
  `seq`         INT NOT NULL COMMENT '行号',
  `xiangmu_id`  BIGINT UNSIGNED NOT NULL COMMENT '项目ID',
  `times`       INT NOT NULL DEFAULT 1 COMMENT '包含次数',
  PRIMARY KEY (`id`),
  KEY `idx_tc` (`taocan_id`),
  KEY `idx_item` (`xiangmu_id`),
  CONSTRAINT `fk_tcmx_tc`   FOREIGN KEY (`taocan_id`)  REFERENCES `liliao_taocan`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tcmx_item` FOREIGN KEY (`xiangmu_id`)  REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='理疗套餐明细';

-- 15. 套餐购买主表（可来源于理疗处方）
CREATE TABLE `liliao_goumai` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '购买ID',
  `patient_id`    BIGINT UNSIGNED NOT NULL COMMENT '患者ID',
  `taocan_id`     BIGINT UNSIGNED DEFAULT NULL COMMENT '套餐ID（可空，若为自定义）',
  `source_cf_id`  BIGINT UNSIGNED DEFAULT NULL COMMENT '来源处方ID（可空）',
  `total_times`   INT NOT NULL DEFAULT 0 COMMENT '总次数',
  `used_times`    INT NOT NULL DEFAULT 0 COMMENT '已使用次数',
  `status`        ENUM('有效','已用完','已退款') NOT NULL DEFAULT '有效' COMMENT '状态',
  `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_patient` (`patient_id`),
  KEY `idx_tc` (`taocan_id`),
  KEY `idx_cf` (`source_cf_id`),
  CONSTRAINT `fk_gm_patient` FOREIGN KEY (`patient_id`)   REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gm_tc`      FOREIGN KEY (`taocan_id`)    REFERENCES `liliao_taocan`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_gm_cf`      FOREIGN KEY (`source_cf_id`) REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='理疗套餐购买';

-- 16. 套餐购买明细（按项目分配次数）
CREATE TABLE `liliao_goumai_mingxi` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `goumai_id`   BIGINT UNSIGNED NOT NULL COMMENT '购买ID',
  `xiangmu_id`  BIGINT UNSIGNED NOT NULL COMMENT '项目ID',
  `quota_times` INT NOT NULL DEFAULT 0 COMMENT '购买时分配的项目次数',
  `used_times`  INT NOT NULL DEFAULT 0 COMMENT '已用次数',
  PRIMARY KEY (`id`),
  KEY `idx_gm` (`goumai_id`),
  KEY `idx_item` (`xiangmu_id`),
  CONSTRAINT `fk_gmmx_gm`   FOREIGN KEY (`goumai_id`)  REFERENCES `liliao_goumai`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gmmx_item` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='理疗购买明细';

-- 17. 理疗执行单（核销入口，可来自处方或套餐）
CREATE TABLE `liliao_zhixing_dan` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '执行单ID',
  `patient_id`  BIGINT UNSIGNED NOT NULL COMMENT '患者ID',
  `cf_id`       BIGINT UNSIGNED DEFAULT NULL COMMENT '来源处方ID（可空）',
  `status`      ENUM('待执行','已完成','已撤销') NOT NULL DEFAULT '待执行' COMMENT '状态',
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_patient` (`patient_id`),
  KEY `idx_cf` (`cf_id`),
  CONSTRAINT `fk_zx_patient` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_zx_cf`      FOREIGN KEY (`cf_id`)      REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='理疗执行单';

-- 18. 理疗执行明细
CREATE TABLE `liliao_zhixing_mx` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `zhixing_id`   BIGINT UNSIGNED NOT NULL COMMENT '执行单ID',
  `xiangmu_id`   BIGINT UNSIGNED NOT NULL COMMENT '项目ID',
  `times`        INT NOT NULL DEFAULT 1 COMMENT '本次执行次数',
  `finished_at`  DATETIME DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`id`),
  KEY `idx_zx` (`zhixing_id`),
  KEY `idx_item` (`xiangmu_id`),
  CONSTRAINT `fk_zxmx_zx`   FOREIGN KEY (`zhixing_id`) REFERENCES `liliao_zhixing_dan`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_zxmx_item` FOREIGN KEY (`xiangmu_id`)  REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='理疗执行明细';

-- 19. 理疗小次（核销）记录（按项目/购买明细维度记录消耗）
CREATE TABLE `liliao_xiaoci_jilu` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `patient_id`    BIGINT UNSIGNED NOT NULL COMMENT '患者ID',
  `goumai_mx_id`  BIGINT UNSIGNED DEFAULT NULL COMMENT '对应的购买明细（可空）',
  `xiangmu_id`    BIGINT UNSIGNED NOT NULL COMMENT '项目ID',
  `cf_id`         BIGINT UNSIGNED DEFAULT NULL COMMENT '来源处方ID（可空）',
  `used_times`    INT NOT NULL DEFAULT 1 COMMENT '本次核销次数',
  `used_at`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '核销时间',
  `remark`        VARCHAR(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  KEY `idx_patient` (`patient_id`),
  KEY `idx_item` (`xiangmu_id`),
  KEY `idx_gmmx` (`goumai_mx_id`),
  KEY `idx_cf` (`cf_id`),
  CONSTRAINT `fk_xc_patient` FOREIGN KEY (`patient_id`)   REFERENCES `huanzhe`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_xc_gmmx`    FOREIGN KEY (`goumai_mx_id`) REFERENCES `liliao_goumai_mingxi`(`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_xc_item`    FOREIGN KEY (`xiangmu_id`)   REFERENCES `liliao_xiangmu`(`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_xc_cf`      FOREIGN KEY (`cf_id`)        REFERENCES `chufang`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='理疗小次核销记录';


-- ============================================================
-- 五、模板明细 & 医嘱 & 库存流水
-- ============================================================

-- 20. 模板-西医明细
CREATE TABLE `moban_xiyi_mx` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `moban_id`   BIGINT UNSIGNED NOT NULL COMMENT '模板ID',
  `seq`        INT NOT NULL COMMENT '行号',
  `yaowei_name` VARCHAR(128) NOT NULL COMMENT '药品名',
  `yongliang`  DECIMAL(12,3) DEFAULT NULL COMMENT '用量',
  `danwei`     VARCHAR(16)  DEFAULT NULL COMMENT '单位',
  PRIMARY KEY (`id`),
  KEY `idx_mb` (`moban_id`),
  CONSTRAINT `fk_mxymx_mb` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='处方模板-西医明细';

-- 21. 模板-中医明细
CREATE TABLE `moban_zhongyao_mx` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `moban_id`   BIGINT UNSIGNED NOT NULL COMMENT '模板ID',
  `seq`        INT NOT NULL COMMENT '行号',
  `yaowei_name` VARCHAR(128) NOT NULL COMMENT '药味名',
  `yongliang`  DECIMAL(12,3) DEFAULT NULL COMMENT '用量',
  `danwei`     VARCHAR(16)  DEFAULT NULL COMMENT '单位',
  PRIMARY KEY (`id`),
  KEY `idx_mb` (`moban_id`),
  CONSTRAINT `fk_mzymx_mb` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='处方模板-中医明细';

-- 22. 医嘱（与就诊关联）
CREATE TABLE `yizhu` (
  `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '医嘱ID',
  `visit_id`     BIGINT UNSIGNED NOT NULL COMMENT '就诊ID',
  `content`      TEXT NOT NULL COMMENT '医嘱内容',
  `copy_from_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '复制来源ID（可空）',
  `created_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_visit` (`visit_id`),
  CONSTRAINT `fk_yz_visit` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_yz_copy`  FOREIGN KEY (`copy_from_id`) REFERENCES `yizhu`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='医嘱';

-- 23. 库存流水（药房）
CREATE TABLE `kucun_liushui` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `yaopin_id`   BIGINT UNSIGNED NOT NULL COMMENT '药品ID',
  `direction`   ENUM('in','out','adjust') NOT NULL COMMENT '方向：入库/出库/调整',
  `qty`         DECIMAL(16,3) NOT NULL COMMENT '数量（正数）',
  `unit`        VARCHAR(16) DEFAULT NULL COMMENT '单位（可选）',
  `ref_type`    VARCHAR(32) DEFAULT NULL COMMENT '来源类型（如：处方、盘点）',
  `ref_id`      BIGINT UNSIGNED DEFAULT NULL COMMENT '来源ID（如：处方ID）',
  `reason`      VARCHAR(128) DEFAULT NULL COMMENT '原因/备注',
  `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (`id`),
  KEY `idx_yp` (`yaopin_id`),
  CONSTRAINT `fk_kc_yp` FOREIGN KEY (`yaopin_id`) REFERENCES `yaopin`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='库存流水';


-- ============================================================
-- 六、便捷视图（供门诊三栏直接使用）
-- ============================================================

-- A. 今日完成患者列表（左栏默认）
DROP VIEW IF EXISTS `v_visit_completed_today`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_visit_completed_today` AS
SELECT jz.id AS visit_id,
       jz.patient_id,
       hz.`name` AS patient_name,
       hz.`phone` AS phone,
       jz.visit_time
FROM `jiuzhen` jz
JOIN `huanzhe` hz ON hz.id = jz.patient_id
WHERE DATE(jz.visit_time) = CURRENT_DATE()
ORDER BY jz.visit_time DESC;

-- B. 就诊中患者（左栏常显，最近活跃在前）
DROP VIEW IF EXISTS `v_visit_in_session`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_visit_in_session` AS
SELECT s.id AS session_id,
       s.patient_id,
       hz.`name` AS patient_name,
       hz.`phone` AS phone,
       s.started_at,
       s.updated_at
FROM `jiuzhen_session` s
JOIN `huanzhe` hz ON hz.id = s.patient_id
ORDER BY s.updated_at DESC;

-- C. 患者历史就诊（右栏）
DROP VIEW IF EXISTS `v_patient_visit_history`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `v_patient_visit_history` AS
SELECT jz.id AS visit_id,
       jz.patient_id,
       jz.visit_time,
       COALESCE(jz.linchuang_dx, jz.zhongyi_dx, '未填写诊断') AS summary_dx
FROM `jiuzhen` jz
ORDER BY jz.visit_time DESC;


-- ============================================================
-- 七、存储过程（接诊完成：草稿→正式就诊，并清理会话）
-- ============================================================

DROP PROCEDURE IF EXISTS `sp_complete_visit`;
DELIMITER $$
CREATE PROCEDURE `sp_complete_visit`(IN p_patient_id BIGINT UNSIGNED)
BEGIN
  DECLARE v_zhusu TEXT;
  DECLARE v_xbs   TEXT;
  DECLARE v_lcdx  VARCHAR(255);
  DECLARE v_zydx  VARCHAR(255);
  DECLARE v_remark TEXT;

  -- 读草稿
  SELECT zhusu, xianbingshi, linchuang_dx, zhongyi_dx, remark
    INTO v_zhusu, v_xbs, v_lcdx, v_zydx, v_remark
  FROM jiuzhen_draft
  WHERE patient_id = p_patient_id
  LIMIT 1;

  START TRANSACTION;
    -- 落到就诊主表
    INSERT INTO jiuzhen(patient_id, visit_no, visit_time, zhusu, xianbingshi, linchuang_dx, zhongyi_dx, remark, created_at)
    VALUES (p_patient_id, NULL, NOW(), v_zhusu, v_xbs, v_lcdx, v_zydx, v_remark, NOW());

    -- 清理会话与草稿
    DELETE FROM jiuzhen_session WHERE patient_id = p_patient_id;
    DELETE FROM jiuzhen_draft   WHERE patient_id = p_patient_id;
  COMMIT;
END$$
DELIMITER ;

-- ============================ 结束 ============================
