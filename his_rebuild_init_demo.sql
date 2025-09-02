
-- ===============================================================
-- HIS 一键“重建 + 初始化 + 演示数据”合集脚本（MySQL 8.0.12 兼容）
-- 说明：
--   1) 可反复执行；会先安全地 DROP 视图/表，再重建结构并写入演示数据；
--   2) 仅使用 8.0.12 支持的特性（不使用 DATE 的表达式默认值）；
--   3) 如生产库执行，请先备份！
-- ===============================================================

/*=========================== A. 重建数据库结构 ===========================*/
/*CREATE DATABASE IF NOT EXISTS his DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;*/
USE his;

-- 先删视图再删表（逆序），规避外键约束
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_print_xiyi;
DROP VIEW IF EXISTS v_print_liliao;
DROP VIEW IF EXISTS v_print_zhongyao;
DROP VIEW IF EXISTS v_liliao_shengyu;

DROP TABLE IF EXISTS moban_xiyi_mx;
DROP TABLE IF EXISTS moban_zhongyao_mx;
DROP TABLE IF EXISTS moban_chufang;
DROP TABLE IF EXISTS liliao_zhixing_mx;
DROP TABLE IF EXISTS liliao_zhixing_dan;
DROP TABLE IF EXISTS liliao_xiaoci_jilu;
DROP TABLE IF EXISTS liliao_goumai_mingxi;
DROP TABLE IF EXISTS liliao_goumai;
DROP TABLE IF EXISTS kucun_liushui;
DROP TABLE IF EXISTS chufang_xiyi_mx;
DROP TABLE IF EXISTS chufang_liliao_mx;
DROP TABLE IF EXISTS chufang_zhongyao_mx;
DROP TABLE IF EXISTS chufang;
DROP TABLE IF EXISTS liliao_taocan_mx;
DROP TABLE IF EXISTS liliao_taocan;
DROP TABLE IF EXISTS liliao_xiangmu;
DROP TABLE IF EXISTS yaopin;
DROP TABLE IF EXISTS rizhi;
DROP TABLE IF EXISTS yizhu;
DROP TABLE IF EXISTS jiuzhen;
DROP TABLE IF EXISTS huanzhe;

SET FOREIGN_KEY_CHECKS = 1;

-- -------- 1. 基础实体 --------
CREATE TABLE huanzhe (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(64)  NOT NULL,
  phone         VARCHAR(32)  NOT NULL,
  gender        ENUM('男','女','未知') DEFAULT '未知',
  birthday      DATE NULL,
  id_no         VARCHAR(32) NULL,
  address       VARCHAR(255) NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_name_phone (name, phone),
  KEY idx_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE jiuzhen (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  patient_id    BIGINT UNSIGNED NOT NULL,
  visit_no      VARCHAR(32) NULL,
  visit_time    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  zhusu         TEXT,
  xianbingshi   TEXT,
  linchuang_dx  VARCHAR(255),
  zhongyi_dx    VARCHAR(255),
  remark        TEXT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES huanzhe(id) ON DELETE CASCADE,
  KEY idx_patient_time (patient_id, visit_time DESC)
) ENGINE=InnoDB;

CREATE TABLE yizhu (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  visit_id      BIGINT UNSIGNED NOT NULL,
  content       TEXT NOT NULL,
  copy_from_id  BIGINT UNSIGNED NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (visit_id) REFERENCES jiuzhen(id) ON DELETE CASCADE,
  FOREIGN KEY (copy_from_id) REFERENCES yizhu(id) ON DELETE SET NULL,
  KEY idx_visit (visit_id)
) ENGINE=InnoDB;

CREATE TABLE rizhi (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  visit_id      BIGINT UNSIGNED NOT NULL,
  content       TEXT NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by    VARCHAR(64) NULL,
  FOREIGN KEY (visit_id) REFERENCES jiuzhen(id) ON DELETE CASCADE,
  KEY idx_visit_created (visit_id, created_at DESC)
) ENGINE=InnoDB;

-- -------- 2. 资源字典/目录 --------
CREATE TABLE yaopin (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  fenlei          ENUM('中药饮片','中成药','西药口服','西药输液','耗材') NOT NULL,
  name            VARCHAR(128) NOT NULL,
  spec            VARCHAR(128) NULL,
  unit            VARCHAR(16)  NOT NULL,
  stock_qty       DECIMAL(14,3) NOT NULL DEFAULT 0,
  cost_price      DECIMAL(12,4) NULL,
  sale_price      DECIMAL(12,4) NULL,
  rec_dose        VARCHAR(64)  NULL,
  default_usage   VARCHAR(128) NULL,
  remark          VARCHAR(255) NULL,
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_name_spec_unit (name, spec, unit),
  KEY idx_fenlei (fenlei),
  KEY idx_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE liliao_xiangmu (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(128) NOT NULL,
  price         DECIMAL(12,2) NOT NULL,
  remark        VARCHAR(255) NULL,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uk_name (name)
) ENGINE=InnoDB;

CREATE TABLE liliao_taocan (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(128) NOT NULL,
  total_price   DECIMAL(12,2) NOT NULL,
  remark        VARCHAR(255) NULL,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uk_name (name)
) ENGINE=InnoDB;

CREATE TABLE liliao_taocan_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  taocan_id     BIGINT UNSIGNED NOT NULL,
  xiangmu_id    BIGINT UNSIGNED NOT NULL,
  xiangmu_name  VARCHAR(128) NOT NULL,
  total_times   INT NOT NULL,
  FOREIGN KEY (taocan_id) REFERENCES liliao_taocan(id) ON DELETE CASCADE,
  FOREIGN KEY (xiangmu_id) REFERENCES liliao_xiangmu(id) ON DELETE RESTRICT,
  UNIQUE KEY uk_taocan_item (taocan_id, xiangmu_id)
) ENGINE=InnoDB;

-- -------- 3. 模板 --------
CREATE TABLE moban_chufang (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  leixing       ENUM('中医','西医') NOT NULL,
  biaoti        VARCHAR(255) NOT NULL,
  content_json  JSON NULL,
  is_active     TINYINT(1) NOT NULL DEFAULT 1,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_type_active (leixing, is_active)
) ENGINE=InnoDB;

CREATE TABLE moban_zhongyao_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  moban_id      BIGINT UNSIGNED NOT NULL,
  seq           INT NOT NULL,
  yaowei_name   VARCHAR(128) NOT NULL,
  yongliang     DECIMAL(10,2) NOT NULL,
  danwei        VARCHAR(16)  NOT NULL,
  special_use   VARCHAR(128) NULL,
  FOREIGN KEY (moban_id) REFERENCES moban_chufang(id) ON DELETE CASCADE,
  UNIQUE KEY uk_moban_seq (moban_id, seq)
) ENGINE=InnoDB;

CREATE TABLE moban_xiyi_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  moban_id      BIGINT UNSIGNED NOT NULL,
  seq           INT NOT NULL,
  yaopin_name   VARCHAR(128) NOT NULL,
  guige         VARCHAR(128) NULL,
  yongfa        VARCHAR(128) NULL,
  pinci         VARCHAR(64)  NULL,
  meici_liang   VARCHAR(64)  NULL,
  meiri_cishu   VARCHAR(64)  NULL,
  tianshu       INT NULL,
  beizhu        VARCHAR(255) NULL,
  FOREIGN KEY (moban_id) REFERENCES moban_chufang(id) ON DELETE CASCADE,
  UNIQUE KEY uk_moban_seq (moban_id, seq)
) ENGINE=InnoDB;

-- -------- 4. 处方（总表与明细） --------
CREATE TABLE chufang (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  visit_id        BIGINT UNSIGNED NOT NULL,
  leixing         ENUM('中医','理疗','西医') NOT NULL,
  biaoti          VARCHAR(255) NULL,
  is_taocan       TINYINT(1) NOT NULL DEFAULT 0,
  fufa            VARCHAR(255) NULL,
  jishu           INT NULL,
  zhouqi          VARCHAR(64) NULL,
  meiri_cishu     DECIMAL(10,2) NULL,
  meici_liang     VARCHAR(64) NULL,
  yongyao_fangfa  VARCHAR(255) NULL,
  beizhu          TEXT NULL,
  total_amount    DECIMAL(12,2) NULL,
  moban_id        BIGINT UNSIGNED NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (visit_id) REFERENCES jiuzhen(id) ON DELETE CASCADE,
  KEY idx_visit_type (visit_id, leixing)
) ENGINE=InnoDB;

CREATE TABLE chufang_zhongyao_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  chufang_id    BIGINT UNSIGNED NOT NULL,
  seq           INT NOT NULL,
  yaowei_name   VARCHAR(128) NOT NULL,
  yongliang     DECIMAL(10,2) NOT NULL,
  danwei        VARCHAR(16) NOT NULL,
  special_use   VARCHAR(128) NULL,
  FOREIGN KEY (chufang_id) REFERENCES chufang(id) ON DELETE CASCADE,
  UNIQUE KEY uk_cf_seq (chufang_id, seq)
) ENGINE=InnoDB;

CREATE TABLE chufang_liliao_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  chufang_id    BIGINT UNSIGNED NOT NULL,
  seq           INT NOT NULL,
  xiangmu_id    BIGINT UNSIGNED NULL,
  xiangmu_name  VARCHAR(128) NOT NULL,
  cishu         INT NOT NULL DEFAULT 1,
  danjia        DECIMAL(12,2) NULL,
  jine          DECIMAL(12,2) NULL,
  FOREIGN KEY (chufang_id) REFERENCES chufang(id) ON DELETE CASCADE,
  FOREIGN KEY (xiangmu_id) REFERENCES liliao_xiangmu(id),
  UNIQUE KEY uk_cf_seq (chufang_id, seq)
) ENGINE=InnoDB;

CREATE TABLE chufang_xiyi_mx (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  chufang_id    BIGINT UNSIGNED NOT NULL,
  seq           INT NOT NULL,
  yaopin_id     BIGINT UNSIGNED NULL,
  yaopin_name   VARCHAR(128) NOT NULL,
  guige         VARCHAR(128) NULL,
  yongfa        VARCHAR(128) NULL,
  pinci         VARCHAR(64)  NULL,
  meici_liang   VARCHAR(64)  NULL,
  meiri_cishu   VARCHAR(64)  NULL,
  tianshu       INT NULL,
  beizhu        VARCHAR(255) NULL,
  FOREIGN KEY (chufang_id) REFERENCES chufang(id) ON DELETE CASCADE,
  FOREIGN KEY (yaopin_id) REFERENCES yaopin(id),
  UNIQUE KEY uk_cf_seq (chufang_id, seq)
) ENGINE=InnoDB;

-- -------- 5. 库存流水 --------
CREATE TABLE kucun_liushui (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  yaopin_id       BIGINT UNSIGNED NOT NULL,
  liushui_type    ENUM('入库','出库','调整') NOT NULL,
  qty             DECIMAL(14,3) NOT NULL,
  related_table   VARCHAR(64) NULL,
  related_id      BIGINT UNSIGNED NULL,
  note            VARCHAR(255) NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (yaopin_id) REFERENCES yaopin(id) ON DELETE RESTRICT,
  KEY idx_yp_time (yaopin_id, created_at DESC),
  KEY idx_type_time (liushui_type, created_at DESC)
) ENGINE=InnoDB;

-- -------- 6. 理疗购买/消次/执行单 --------
CREATE TABLE liliao_goumai (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  patient_id      BIGINT UNSIGNED NOT NULL,
  buy_time        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  taocan_id       BIGINT UNSIGNED NULL,
  taocan_name     VARCHAR(128) NULL,
  total_price     DECIMAL(12,2) NOT NULL,
  source_cf_id    BIGINT UNSIGNED NULL,
  remark          VARCHAR(255) NULL,
  FOREIGN KEY (patient_id) REFERENCES huanzhe(id) ON DELETE CASCADE,
  FOREIGN KEY (taocan_id)  REFERENCES liliao_taocan(id) ON DELETE SET NULL,
  FOREIGN KEY (source_cf_id) REFERENCES chufang(id) ON DELETE SET NULL,
  KEY idx_patient_time (patient_id, buy_time DESC)
) ENGINE=InnoDB;

CREATE TABLE liliao_goumai_mingxi (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  goumai_id       BIGINT UNSIGNED NOT NULL,
  xiangmu_id      BIGINT UNSIGNED NOT NULL,
  xiangmu_name    VARCHAR(128) NOT NULL,
  total_times     INT NOT NULL,
  used_times      INT NOT NULL DEFAULT 0,
  FOREIGN KEY (goumai_id)  REFERENCES liliao_goumai(id) ON DELETE CASCADE,
  FOREIGN KEY (xiangmu_id) REFERENCES liliao_xiangmu(id) ON DELETE RESTRICT,
  KEY idx_gm (goumai_id),
  KEY idx_item (xiangmu_id)
) ENGINE=InnoDB;

CREATE TABLE liliao_xiaoci_jilu (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  patient_id      BIGINT UNSIGNED NOT NULL,
  goumai_mx_id    BIGINT UNSIGNED NULL,
  xiangmu_id      BIGINT UNSIGNED NOT NULL,
  xiangmu_name    VARCHAR(128) NOT NULL,
  count_used      INT NOT NULL DEFAULT 1,
  used_time       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cf_id           BIGINT UNSIGNED NULL,
  operator_name   VARCHAR(64) NULL,
  remark          VARCHAR(255) NULL,
  FOREIGN KEY (patient_id) REFERENCES huanzhe(id) ON DELETE CASCADE,
  FOREIGN KEY (goumai_mx_id) REFERENCES liliao_goumai_mingxi(id) ON DELETE SET NULL,
  FOREIGN KEY (xiangmu_id)   REFERENCES liliao_xiangmu(id) ON DELETE RESTRICT,
  FOREIGN KEY (cf_id)        REFERENCES chufang(id) ON DELETE SET NULL,
  KEY idx_patient_time (patient_id, used_time DESC)
) ENGINE=InnoDB;

CREATE TABLE liliao_zhixing_dan (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  patient_id      BIGINT UNSIGNED NOT NULL,
  cf_id           BIGINT UNSIGNED NULL,
  exec_date       DATE NOT NULL,            -- 8.0.12：不使用 DEFAULT (CURRENT_DATE)
  remark          VARCHAR(255) NULL,
  patient_sign    VARCHAR(255) NULL,
  doctor_sign     VARCHAR(255) NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES huanzhe(id) ON DELETE CASCADE,
  FOREIGN KEY (cf_id)      REFERENCES chufang(id) ON DELETE SET NULL,
  KEY idx_patient_date (patient_id, exec_date DESC)
) ENGINE=InnoDB;

CREATE TABLE liliao_zhixing_mx (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  zhixing_id      BIGINT UNSIGNED NOT NULL,
  xiangmu_name    VARCHAR(128) NOT NULL,
  progress_n      INT NOT NULL,
  progress_m      INT NOT NULL,
  snapshot_json   JSON NULL,
  FOREIGN KEY (zhixing_id) REFERENCES liliao_zhixing_dan(id) ON DELETE CASCADE,
  KEY idx_zhixing (zhixing_id)
) ENGINE=InnoDB;

-- -------- 7. 视图 --------
CREATE OR REPLACE VIEW v_liliao_shengyu AS
SELECT
  gm.patient_id,
  gmm.id         AS goumai_mx_id,
  gmm.xiangmu_id,
  gmm.xiangmu_name,
  GREATEST(gmm.total_times - gmm.used_times, 0) AS remain_times
FROM liliao_goumai_mingxi gmm
JOIN liliao_goumai gm ON gm.id = gmm.goumai_id;

CREATE OR REPLACE VIEW v_print_zhongyao AS
SELECT
  cf.id          AS cf_id,
  jz.visit_time,
  hz.name        AS patient_name,
  hz.phone,
  cf.fufa, cf.jishu, cf.zhouqi, cf.meiri_cishu, cf.meici_liang, cf.yongyao_fangfa, cf.beizhu, cf.total_amount,
  mx.seq, mx.yaowei_name, mx.yongliang, mx.danwei, mx.special_use
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
JOIN chufang_zhongyao_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '中医'
ORDER BY cf.id, mx.seq;

CREATE OR REPLACE VIEW v_print_liliao AS
SELECT
  cf.id          AS cf_id,
  jz.visit_time,
  hz.name        AS patient_name,
  hz.phone,
  cf.biaoti, cf.is_taocan, cf.total_amount, cf.beizhu,
  mx.seq, mx.xiangmu_name, mx.cishu, mx.danjia, mx.jine
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
LEFT JOIN chufang_liliao_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '理疗'
ORDER BY cf.id, mx.seq;

CREATE OR REPLACE VIEW v_print_xiyi AS
SELECT
  cf.id          AS cf_id,
  jz.visit_time,
  hz.name        AS patient_name,
  hz.phone,
  cf.beizhu, cf.total_amount,
  mx.seq, mx.yaopin_name, mx.guige, mx.yongfa, mx.pinci, mx.meici_liang, mx.meiri_cishu, mx.tianshu, mx.beizhu AS mx_beizhu
FROM chufang cf
JOIN jiuzhen jz ON jz.id = cf.visit_id
JOIN huanzhe hz ON hz.id = jz.patient_id
JOIN chufang_xiyi_mx mx ON mx.chufang_id = cf.id
WHERE cf.leixing = '西医'
ORDER BY cf.id, mx.seq;

-- ===============================================================
-- B. 初始化 & 演示数据
-- ===============================================================
SET NAMES utf8mb4;
SET time_zone = '+08:00';
START TRANSACTION;

-- 1) 基础：患者/就诊/医嘱/日志
INSERT INTO huanzhe (name, phone, gender, birthday, address)
VALUES
('张三', '13800000001', '男', '1990-05-20', '广州市天河区'),
('李四', '13800000002', '女', '1988-11-03', '深圳市南山区');

SELECT id INTO @p_zhang FROM huanzhe WHERE phone='13800000001';
SELECT id INTO @p_li   FROM huanzhe WHERE phone='13800000002';

INSERT INTO jiuzhen (patient_id, visit_no, visit_time, zhusu, xianbingshi, linchuang_dx, zhongyi_dx, remark)
VALUES
(@p_zhang, 'MZ20250901-001', '2025-09-01 10:00:00', '咳嗽，咽痛', '受凉后出现发热咽痛3天', '上呼吸道感染', '风热犯肺', '初诊'),
(@p_li,   'MZ20250901-002', '2025-09-01 11:00:00', '颈肩酸痛', '久坐工作，颈肩僵硬1月', '颈型颈椎病', '气滞血瘀', '理疗评估');

SELECT id INTO @v1 FROM jiuzhen WHERE visit_no='MZ20250901-001';
SELECT id INTO @v2 FROM jiuzhen WHERE visit_no='MZ20250901-002';

INSERT INTO yizhu (visit_id, content) VALUES
(@v1, '多饮水休息，避免辛辣刺激'),
(@v1, '如发热>38.5℃可对症退热'),
(@v2, '注意工位人体工学，避免久坐');
INSERT INTO rizhi (visit_id, content, created_by) VALUES
(@v1, '完成问诊与体格检查，建议复诊时间 9/5', '王医生'),
(@v2, '完成颈肩评估，建议理疗10次', '李医生');

-- 2) 药房：药品与库存流水（期初入库）
INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('中药饮片','黄芪','切片','g', 5000, 0.0500, 0.1200, '10-30g', '水煎服', NULL);
SET @yp_huangqi := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('中药饮片','桂枝','切片','g', 4000, 0.0600, 0.1500, '6-9g', '水煎服', NULL);
SET @yp_guizhi := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('中成药','藿香正气液','10ml*6支','盒', 100, 8.0000, 16.0000, '一次10ml', '口服', NULL);
SET @yp_huoxiang := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('西药口服','阿莫西林胶囊','0.5g*24粒','盒', 200, 12.0000, 26.0000, '0.5g', '口服', NULL);
SET @yp_amox := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('西药口服','布洛芬缓释片','0.3g*20片','盒', 150, 15.0000, 32.0000, '0.3g', '口服', NULL);
SET @yp_ibuprofen := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('西药输液','0.9%氯化钠注射液','500ml','瓶', 80, 3.5000, 8.0000, NULL, '静滴', NULL);
SET @yp_ns := LAST_INSERT_ID();

INSERT INTO yaopin (fenlei, name, spec, unit, stock_qty, cost_price, sale_price, rec_dose, default_usage, remark)
VALUES ('耗材','一次性注射器','5ml','支', 500, 0.5000, 1.0000, NULL, NULL, NULL);
SET @yp_syringe := LAST_INSERT_ID();

INSERT INTO kucun_liushui (yaopin_id, liushui_type, qty, related_table, note)
VALUES
(@yp_huangqi, '入库', 5000, 'init', '期初'),
(@yp_guizhi,  '入库', 4000, 'init', '期初'),
(@yp_huoxiang,'入库', 100,  'init', '期初'),
(@yp_amox,    '入库', 200,  'init', '期初'),
(@yp_ibuprofen,'入库',150,  'init', '期初'),
(@yp_ns,      '入库', 80,   'init', '期初'),
(@yp_syringe, '入库', 500,  'init', '期初');

-- 3) 理疗：项目 / 套餐
INSERT INTO liliao_xiangmu (name, price, remark) VALUES ('推拿', 128.00, '30分钟');
SET @xm_tuina := LAST_INSERT_ID();
INSERT INTO liliao_xiangmu (name, price, remark) VALUES ('刮痧', 98.00, '15分钟');
SET @xm_guasha := LAST_INSERT_ID();
INSERT INTO liliao_xiangmu (name, price, remark) VALUES ('艾灸', 118.00, '20分钟');
SET @xm_aijiu := LAST_INSERT_ID();
INSERT INTO liliao_xiangmu (name, price, remark) VALUES ('拔罐', 88.00, '15分钟');
SET @xm_baguan := LAST_INSERT_ID();

INSERT INTO liliao_taocan (name, total_price, remark) VALUES ('肩颈调理套餐', 1088.00, '有效期 90 天');
SET @tc_jianjing := LAST_INSERT_ID();
INSERT INTO liliao_taocan_mx (taocan_id, xiangmu_id, xiangmu_name, total_times)
VALUES
(@tc_jianjing, @xm_tuina,  '推拿', 5),
(@tc_jianjing, @xm_guasha, '刮痧', 3),
(@tc_jianjing, @xm_aijiu,  '艾灸', 3);

-- 4) 模板（中医/西医）
INSERT INTO moban_chufang (leixing, biaoti, content_json) VALUES
('中医', '健脾益气方', JSON_OBJECT('fufa','水煎分早晚2次','jishu',3,'zhouqi','3日'));
SET @mb_zy := LAST_INSERT_ID();
INSERT INTO moban_zhongyao_mx (moban_id, seq, yaowei_name, yongliang, danwei, special_use) VALUES
(@mb_zy,1,'黄芪',15,'g',NULL),
(@mb_zy,2,'白术',10,'g',NULL),
(@mb_zy,3,'茯苓',12,'g',NULL),
(@mb_zy,4,'炙甘草',6,'g',NULL),
(@mb_zy,5,'陈皮',6,'g',NULL);

INSERT INTO moban_chufang (leixing, biaoti, content_json) VALUES
('西医', '上呼吸道感染处方', JSON_OBJECT('remark','多饮水休息'));
SET @mb_xy := LAST_INSERT_ID();
INSERT INTO moban_xiyi_mx (moban_id, seq, yaopin_name, guige, yongfa, pinci, meici_liang, meiri_cishu, tianshu, beizhu) VALUES
(@mb_xy,1,'阿莫西林胶囊','0.5g*24粒','口服','bid','0.5g','2','5',NULL),
(@mb_xy,2,'布洛芬缓释片','0.3g*20片','口服','prn','0.3g',NULL,'3','发热疼痛时用');

-- 5) 处方：中医 / 理疗（单项与套餐）/ 西医
INSERT INTO chufang (visit_id, leixing, biaoti, is_taocan, fufa, jishu, zhouqi, meici_liang, yongyao_fangfa, beizhu, total_amount)
VALUES (@v1,'中医',NULL,0,'水煎分早晚2次',3,'3日',NULL,'饭后服','注意保暖', 128.00);
SET @cf_zy := LAST_INSERT_ID();
INSERT INTO chufang_zhongyao_mx (chufang_id, seq, yaowei_name, yongliang, danwei, special_use) VALUES
(@cf_zy,1,'银花',12,'g',NULL),
(@cf_zy,2,'连翘',12,'g',NULL),
(@cf_zy,3,'薄荷',6,'g','后下'),
(@cf_zy,4,'牛蒡子',9,'g',NULL),
(@cf_zy,5,'荆芥',9,'g',NULL),
(@cf_zy,6,'黄芩',10,'g',NULL),
(@cf_zy,7,'桔梗',6,'g',NULL),
(@cf_zy,8,'甘草',6,'g','炙'),
(@cf_zy,9,'芦根',15,'g',NULL),
(@cf_zy,10,'淡竹叶',6,'g',NULL),
(@cf_zy,11,'杏仁',9,'g','打碎'),
(@cf_zy,12,'生姜',3,'片','加减');

INSERT INTO chufang (visit_id, leixing, biaoti, is_taocan, beizhu, total_amount)
VALUES (@v2,'理疗',NULL,0,'颈肩肌肉紧张','1280.00');
SET @cf_ll_single := LAST_INSERT_ID();
INSERT INTO chufang_liliao_mx (chufang_id, seq, xiangmu_id, xiangmu_name, cishu, danjia, jine) VALUES
(@cf_ll_single,1,@xm_tuina,'推拿',10,128.00,1280.00);

INSERT INTO chufang (visit_id, leixing, biaoti, is_taocan, beizhu, total_amount)
VALUES (@v2,'理疗','肩颈调理套餐',1,'套餐有效期 90 天','1088.00');
SET @cf_ll_pkg := LAST_INSERT_ID();
INSERT INTO chufang_liliao_mx (chufang_id, seq, xiangmu_id, xiangmu_name, cishu, danjia, jine) VALUES
(@cf_ll_pkg,1,@xm_tuina,'推拿',5,NULL,NULL),
(@cf_ll_pkg,2,@xm_guasha,'刮痧',3,NULL,NULL),
(@cf_ll_pkg,3,@xm_aijiu,'艾灸',3,NULL,NULL);

INSERT INTO chufang (visit_id, leixing, beizhu, total_amount)
VALUES (@v1,'西医','出现胃不适请停药并复诊','86.00');
SET @cf_xy := LAST_INSERT_ID();
INSERT INTO chufang_xiyi_mx (chufang_id, seq, yaopin_id, yaopin_name, guige, yongfa, pinci, meici_liang, meiri_cishu, tianshu, beizhu) VALUES
(@cf_xy,1,@yp_amox,'阿莫西林胶囊','0.5g*24粒','口服','bid','0.5g','2',5,NULL),
(@cf_xy,2,@yp_ibuprofen,'布洛芬缓释片','0.3g*20片','口服','prn','0.3g',NULL,3,'发热疼痛时服用');

-- 6) 理疗：购买/消次/执行单
INSERT INTO liliao_goumai (patient_id, buy_time, taocan_id, taocan_name, total_price, source_cf_id, remark)
VALUES (@p_zhang, '2025-09-01 11:30:00', @tc_jianjing, '肩颈调理套餐', 1088.00, @cf_ll_pkg, '线上支付');
SET @gm1 := LAST_INSERT_ID();

INSERT INTO liliao_goumai_mingxi (goumai_id, xiangmu_id, xiangmu_name, total_times, used_times)
VALUES
(@gm1, @xm_tuina,  '推拿', 5, 1),
(@gm1, @xm_guasha, '刮痧', 3, 0),
(@gm1, @xm_aijiu,  '艾灸', 3, 0);

SELECT id INTO @gmm_tuina  FROM liliao_goumai_mingxi WHERE goumai_id=@gm1 AND xiangmu_id=@xm_tuina;
SELECT id INTO @gmm_guasha FROM liliao_goumai_mingxi WHERE goumai_id=@gm1 AND xiangmu_id=@xm_guasha;
SELECT id INTO @gmm_aijiu  FROM liliao_goumai_mingxi WHERE goumai_id=@gm1 AND xiangmu_id=@xm_aijiu;

INSERT INTO liliao_xiaoci_jilu (patient_id, goumai_mx_id, xiangmu_id, xiangmu_name, count_used, used_time, cf_id, operator_name, remark)
VALUES
(@p_zhang, @gmm_tuina, @xm_tuina, '推拿', 1, '2025-09-02 10:30:00', @cf_ll_single, '技师-小刘', '感觉放松');

INSERT INTO liliao_zhixing_dan (patient_id, cf_id, exec_date, remark, patient_sign, doctor_sign)
VALUES (@p_zhang, @cf_ll_pkg, '2025-09-02', '本单据仅作当次理疗执行确认', NULL, NULL);
SET @zx1 := LAST_INSERT_ID();

INSERT INTO liliao_zhixing_mx (zhixing_id, xiangmu_name, progress_n, progress_m, snapshot_json) VALUES
(@zx1, '推拿', 2, 5, JSON_OBJECT('from','套餐','goumai_mx_id', @gmm_tuina)),
(@zx1, '刮痧', 1, 3, JSON_OBJECT('from','套餐','goumai_mx_id', @gmm_guasha));

COMMIT;

-- 7) 演示查询（可按需取消注释）
-- SELECT * FROM v_print_zhongyao WHERE cf_id = @cf_zy;
-- SELECT * FROM v_print_liliao WHERE cf_id IN (@cf_ll_single, @cf_ll_pkg) ORDER BY seq;
-- SELECT * FROM v_print_xiyi WHERE cf_id = @cf_xy;
-- SELECT * FROM v_liliao_shengyu WHERE patient_id = @p_zhang;
