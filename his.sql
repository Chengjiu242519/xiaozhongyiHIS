-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- 主机： localhost
-- 生成日期： 2025-09-02 15:44:54
-- 服务器版本： 8.0.12
-- PHP 版本： 7.3.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 数据库： `his`
--

-- --------------------------------------------------------

--
-- 表的结构 `chufang`
--

CREATE TABLE `chufang` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `visit_id` bigint(20) UNSIGNED NOT NULL,
  `leixing` enum('中医','理疗','西医') NOT NULL,
  `biaoti` varchar(255) DEFAULT NULL,
  `is_taocan` tinyint(1) NOT NULL DEFAULT '0',
  `fufa` varchar(255) DEFAULT NULL,
  `jishu` int(11) DEFAULT NULL,
  `zhouqi` varchar(64) DEFAULT NULL,
  `meiri_cishu` decimal(10,2) DEFAULT NULL,
  `meici_liang` varchar(64) DEFAULT NULL,
  `yongyao_fangfa` varchar(255) DEFAULT NULL,
  `beizhu` text,
  `total_amount` decimal(12,2) DEFAULT NULL,
  `moban_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `chufang`
--

INSERT INTO `chufang` (`id`, `visit_id`, `leixing`, `biaoti`, `is_taocan`, `fufa`, `jishu`, `zhouqi`, `meiri_cishu`, `meici_liang`, `yongyao_fangfa`, `beizhu`, `total_amount`, `moban_id`, `created_at`) VALUES
(1, 1, '中医', NULL, 0, '水煎分早晚2次', 3, '3日', NULL, NULL, '饭后服', '注意保暖', '128.00', NULL, '2025-09-02 07:42:05'),
(2, 2, '理疗', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, '颈肩肌肉紧张', '1280.00', NULL, '2025-09-02 07:42:05'),
(3, 2, '理疗', '肩颈调理套餐', 1, NULL, NULL, NULL, NULL, NULL, NULL, '套餐有效期 90 天', '1088.00', NULL, '2025-09-02 07:42:05'),
(4, 1, '西医', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, '出现胃不适请停药并复诊', '86.00', NULL, '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `chufang_liliao_mx`
--

CREATE TABLE `chufang_liliao_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `chufang_id` bigint(20) UNSIGNED NOT NULL,
  `seq` int(11) NOT NULL,
  `xiangmu_id` bigint(20) UNSIGNED DEFAULT NULL,
  `xiangmu_name` varchar(128) NOT NULL,
  `cishu` int(11) NOT NULL DEFAULT '1',
  `danjia` decimal(12,2) DEFAULT NULL,
  `jine` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `chufang_liliao_mx`
--

INSERT INTO `chufang_liliao_mx` (`id`, `chufang_id`, `seq`, `xiangmu_id`, `xiangmu_name`, `cishu`, `danjia`, `jine`) VALUES
(1, 2, 1, 1, '推拿', 10, '128.00', '1280.00'),
(2, 3, 1, 1, '推拿', 5, NULL, NULL),
(3, 3, 2, 2, '刮痧', 3, NULL, NULL),
(4, 3, 3, 3, '艾灸', 3, NULL, NULL);

-- --------------------------------------------------------

--
-- 表的结构 `chufang_xiyi_mx`
--

CREATE TABLE `chufang_xiyi_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `chufang_id` bigint(20) UNSIGNED NOT NULL,
  `seq` int(11) NOT NULL,
  `yaopin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `yaopin_name` varchar(128) NOT NULL,
  `guige` varchar(128) DEFAULT NULL,
  `yongfa` varchar(128) DEFAULT NULL,
  `pinci` varchar(64) DEFAULT NULL,
  `meici_liang` varchar(64) DEFAULT NULL,
  `meiri_cishu` varchar(64) DEFAULT NULL,
  `tianshu` int(11) DEFAULT NULL,
  `beizhu` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `chufang_xiyi_mx`
--

INSERT INTO `chufang_xiyi_mx` (`id`, `chufang_id`, `seq`, `yaopin_id`, `yaopin_name`, `guige`, `yongfa`, `pinci`, `meici_liang`, `meiri_cishu`, `tianshu`, `beizhu`) VALUES
(1, 4, 1, 4, '阿莫西林胶囊', '0.5g*24粒', '口服', 'bid', '0.5g', '2', 5, NULL),
(2, 4, 2, 5, '布洛芬缓释片', '0.3g*20片', '口服', 'prn', '0.3g', NULL, 3, '发热疼痛时服用');

-- --------------------------------------------------------

--
-- 表的结构 `chufang_zhongyao_mx`
--

CREATE TABLE `chufang_zhongyao_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `chufang_id` bigint(20) UNSIGNED NOT NULL,
  `seq` int(11) NOT NULL,
  `yaowei_name` varchar(128) NOT NULL,
  `yongliang` decimal(10,2) NOT NULL,
  `danwei` varchar(16) NOT NULL,
  `special_use` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `chufang_zhongyao_mx`
--

INSERT INTO `chufang_zhongyao_mx` (`id`, `chufang_id`, `seq`, `yaowei_name`, `yongliang`, `danwei`, `special_use`) VALUES
(1, 1, 1, '银花', '12.00', 'g', NULL),
(2, 1, 2, '连翘', '12.00', 'g', NULL),
(3, 1, 3, '薄荷', '6.00', 'g', '后下'),
(4, 1, 4, '牛蒡子', '9.00', 'g', NULL),
(5, 1, 5, '荆芥', '9.00', 'g', NULL),
(6, 1, 6, '黄芩', '10.00', 'g', NULL),
(7, 1, 7, '桔梗', '6.00', 'g', NULL),
(8, 1, 8, '甘草', '6.00', 'g', '炙'),
(9, 1, 9, '芦根', '15.00', 'g', NULL),
(10, 1, 10, '淡竹叶', '6.00', 'g', NULL),
(11, 1, 11, '杏仁', '9.00', 'g', '打碎'),
(12, 1, 12, '生姜', '3.00', '片', '加减');

-- --------------------------------------------------------

--
-- 表的结构 `huanzhe`
--

CREATE TABLE `huanzhe` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(64) NOT NULL,
  `phone` varchar(32) NOT NULL,
  `gender` enum('男','女','未知') DEFAULT '未知',
  `birthday` date DEFAULT NULL,
  `id_no` varchar(32) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `huanzhe`
--

INSERT INTO `huanzhe` (`id`, `name`, `phone`, `gender`, `birthday`, `id_no`, `address`, `created_at`, `updated_at`) VALUES
(1, '张三', '13800000001', '男', '1990-05-20', NULL, '广州市天河区', '2025-09-02 07:42:05', '2025-09-02 07:42:05'),
(2, '李四', '13800000002', '女', '1988-11-03', NULL, '深圳市南山区', '2025-09-02 07:42:05', '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `jiuzhen`
--

CREATE TABLE `jiuzhen` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `patient_id` bigint(20) UNSIGNED NOT NULL,
  `visit_no` varchar(32) DEFAULT NULL,
  `visit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `zhusu` text,
  `xianbingshi` text,
  `linchuang_dx` varchar(255) DEFAULT NULL,
  `zhongyi_dx` varchar(255) DEFAULT NULL,
  `remark` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `jiuzhen`
--

INSERT INTO `jiuzhen` (`id`, `patient_id`, `visit_no`, `visit_time`, `zhusu`, `xianbingshi`, `linchuang_dx`, `zhongyi_dx`, `remark`, `created_at`) VALUES
(1, 1, 'MZ20250901-001', '2025-09-01 10:00:00', '咳嗽，咽痛', '受凉后出现发热咽痛3天', '上呼吸道感染', '风热犯肺', '初诊', '2025-09-02 07:42:05'),
(2, 2, 'MZ20250901-002', '2025-09-01 11:00:00', '颈肩酸痛', '久坐工作，颈肩僵硬1月', '颈型颈椎病', '气滞血瘀', '理疗评估', '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `kucun_liushui`
--

CREATE TABLE `kucun_liushui` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `yaopin_id` bigint(20) UNSIGNED NOT NULL,
  `liushui_type` enum('入库','出库','调整') NOT NULL,
  `qty` decimal(14,3) NOT NULL,
  `related_table` varchar(64) DEFAULT NULL,
  `related_id` bigint(20) UNSIGNED DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `kucun_liushui`
--

INSERT INTO `kucun_liushui` (`id`, `yaopin_id`, `liushui_type`, `qty`, `related_table`, `related_id`, `note`, `created_at`) VALUES
(1, 1, '入库', '5000.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(2, 2, '入库', '4000.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(3, 3, '入库', '100.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(4, 4, '入库', '200.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(5, 5, '入库', '150.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(6, 6, '入库', '80.000', 'init', NULL, '期初', '2025-09-02 07:42:05'),
(7, 7, '入库', '500.000', 'init', NULL, '期初', '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `liliao_goumai`
--

CREATE TABLE `liliao_goumai` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `patient_id` bigint(20) UNSIGNED NOT NULL,
  `buy_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `taocan_id` bigint(20) UNSIGNED DEFAULT NULL,
  `taocan_name` varchar(128) DEFAULT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `source_cf_id` bigint(20) UNSIGNED DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_goumai`
--

INSERT INTO `liliao_goumai` (`id`, `patient_id`, `buy_time`, `taocan_id`, `taocan_name`, `total_price`, `source_cf_id`, `remark`) VALUES
(1, 1, '2025-09-01 11:30:00', 1, '肩颈调理套餐', '1088.00', 3, '线上支付');

-- --------------------------------------------------------

--
-- 表的结构 `liliao_goumai_mingxi`
--

CREATE TABLE `liliao_goumai_mingxi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `goumai_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_name` varchar(128) NOT NULL,
  `total_times` int(11) NOT NULL,
  `used_times` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_goumai_mingxi`
--

INSERT INTO `liliao_goumai_mingxi` (`id`, `goumai_id`, `xiangmu_id`, `xiangmu_name`, `total_times`, `used_times`) VALUES
(1, 1, 1, '推拿', 5, 1),
(2, 1, 2, '刮痧', 3, 0),
(3, 1, 3, '艾灸', 3, 0);

-- --------------------------------------------------------

--
-- 表的结构 `liliao_taocan`
--

CREATE TABLE `liliao_taocan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(128) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_taocan`
--

INSERT INTO `liliao_taocan` (`id`, `name`, `total_price`, `remark`, `is_active`) VALUES
(1, '肩颈调理套餐', '1088.00', '有效期 90 天', 1);

-- --------------------------------------------------------

--
-- 表的结构 `liliao_taocan_mx`
--

CREATE TABLE `liliao_taocan_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `taocan_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_name` varchar(128) NOT NULL,
  `total_times` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_taocan_mx`
--

INSERT INTO `liliao_taocan_mx` (`id`, `taocan_id`, `xiangmu_id`, `xiangmu_name`, `total_times`) VALUES
(1, 1, 1, '推拿', 5),
(2, 1, 2, '刮痧', 3),
(3, 1, 3, '艾灸', 3);

-- --------------------------------------------------------

--
-- 表的结构 `liliao_xiangmu`
--

CREATE TABLE `liliao_xiangmu` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(128) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_xiangmu`
--

INSERT INTO `liliao_xiangmu` (`id`, `name`, `price`, `remark`, `is_active`) VALUES
(1, '推拿', '128.00', '30分钟', 1),
(2, '刮痧', '98.00', '15分钟', 1),
(3, '艾灸', '118.00', '20分钟', 1),
(4, '拔罐', '88.00', '15分钟', 1);

-- --------------------------------------------------------

--
-- 表的结构 `liliao_xiaoci_jilu`
--

CREATE TABLE `liliao_xiaoci_jilu` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `patient_id` bigint(20) UNSIGNED NOT NULL,
  `goumai_mx_id` bigint(20) UNSIGNED DEFAULT NULL,
  `xiangmu_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_name` varchar(128) NOT NULL,
  `count_used` int(11) NOT NULL DEFAULT '1',
  `used_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cf_id` bigint(20) UNSIGNED DEFAULT NULL,
  `operator_name` varchar(64) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_xiaoci_jilu`
--

INSERT INTO `liliao_xiaoci_jilu` (`id`, `patient_id`, `goumai_mx_id`, `xiangmu_id`, `xiangmu_name`, `count_used`, `used_time`, `cf_id`, `operator_name`, `remark`) VALUES
(1, 1, 1, 1, '推拿', 1, '2025-09-02 10:30:00', 2, '技师-小刘', '感觉放松');

-- --------------------------------------------------------

--
-- 表的结构 `liliao_zhixing_dan`
--

CREATE TABLE `liliao_zhixing_dan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `patient_id` bigint(20) UNSIGNED NOT NULL,
  `cf_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exec_date` date NOT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `patient_sign` varchar(255) DEFAULT NULL,
  `doctor_sign` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_zhixing_dan`
--

INSERT INTO `liliao_zhixing_dan` (`id`, `patient_id`, `cf_id`, `exec_date`, `remark`, `patient_sign`, `doctor_sign`, `created_at`) VALUES
(1, 1, 3, '2025-09-02', '本单据仅作当次理疗执行确认', NULL, NULL, '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `liliao_zhixing_mx`
--

CREATE TABLE `liliao_zhixing_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `zhixing_id` bigint(20) UNSIGNED NOT NULL,
  `xiangmu_name` varchar(128) NOT NULL,
  `progress_n` int(11) NOT NULL,
  `progress_m` int(11) NOT NULL,
  `snapshot_json` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `liliao_zhixing_mx`
--

INSERT INTO `liliao_zhixing_mx` (`id`, `zhixing_id`, `xiangmu_name`, `progress_n`, `progress_m`, `snapshot_json`) VALUES
(1, 1, '推拿', 2, 5, '{\"from\": \"套餐\", \"goumai_mx_id\": 1}'),
(2, 1, '刮痧', 1, 3, '{\"from\": \"套餐\", \"goumai_mx_id\": 2}');

-- --------------------------------------------------------

--
-- 表的结构 `moban_chufang`
--

CREATE TABLE `moban_chufang` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `leixing` enum('中医','西医') NOT NULL,
  `biaoti` varchar(255) NOT NULL,
  `content_json` json DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `moban_chufang`
--

INSERT INTO `moban_chufang` (`id`, `leixing`, `biaoti`, `content_json`, `is_active`, `created_at`) VALUES
(1, '中医', '健脾益气方', '{\"fufa\": \"水煎分早晚2次\", \"jishu\": 3, \"zhouqi\": \"3日\"}', 1, '2025-09-02 07:42:05'),
(2, '西医', '上呼吸道感染处方', '{\"remark\": \"多饮水休息\"}', 1, '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `moban_xiyi_mx`
--

CREATE TABLE `moban_xiyi_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `moban_id` bigint(20) UNSIGNED NOT NULL,
  `seq` int(11) NOT NULL,
  `yaopin_name` varchar(128) NOT NULL,
  `guige` varchar(128) DEFAULT NULL,
  `yongfa` varchar(128) DEFAULT NULL,
  `pinci` varchar(64) DEFAULT NULL,
  `meici_liang` varchar(64) DEFAULT NULL,
  `meiri_cishu` varchar(64) DEFAULT NULL,
  `tianshu` int(11) DEFAULT NULL,
  `beizhu` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `moban_xiyi_mx`
--

INSERT INTO `moban_xiyi_mx` (`id`, `moban_id`, `seq`, `yaopin_name`, `guige`, `yongfa`, `pinci`, `meici_liang`, `meiri_cishu`, `tianshu`, `beizhu`) VALUES
(1, 2, 1, '阿莫西林胶囊', '0.5g*24粒', '口服', 'bid', '0.5g', '2', 5, NULL),
(2, 2, 2, '布洛芬缓释片', '0.3g*20片', '口服', 'prn', '0.3g', NULL, 3, '发热疼痛时用');

-- --------------------------------------------------------

--
-- 表的结构 `moban_zhongyao_mx`
--

CREATE TABLE `moban_zhongyao_mx` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `moban_id` bigint(20) UNSIGNED NOT NULL,
  `seq` int(11) NOT NULL,
  `yaowei_name` varchar(128) NOT NULL,
  `yongliang` decimal(10,2) NOT NULL,
  `danwei` varchar(16) NOT NULL,
  `special_use` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `moban_zhongyao_mx`
--

INSERT INTO `moban_zhongyao_mx` (`id`, `moban_id`, `seq`, `yaowei_name`, `yongliang`, `danwei`, `special_use`) VALUES
(1, 1, 1, '黄芪', '15.00', 'g', NULL),
(2, 1, 2, '白术', '10.00', 'g', NULL),
(3, 1, 3, '茯苓', '12.00', 'g', NULL),
(4, 1, 4, '炙甘草', '6.00', 'g', NULL),
(5, 1, 5, '陈皮', '6.00', 'g', NULL);

-- --------------------------------------------------------

--
-- 表的结构 `rizhi`
--

CREATE TABLE `rizhi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `visit_id` bigint(20) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `rizhi`
--

INSERT INTO `rizhi` (`id`, `visit_id`, `content`, `created_at`, `created_by`) VALUES
(1, 1, '完成问诊与体格检查，建议复诊时间 9/5', '2025-09-02 07:42:05', '王医生'),
(2, 2, '完成颈肩评估，建议理疗10次', '2025-09-02 07:42:05', '李医生');

-- --------------------------------------------------------

--
-- 替换视图以便查看 `v_liliao_shengyu`
-- （参见下面的实际视图）
--
CREATE TABLE `v_liliao_shengyu` (
`patient_id` bigint(20) unsigned
,`goumai_mx_id` bigint(20) unsigned
,`xiangmu_id` bigint(20) unsigned
,`xiangmu_name` varchar(128)
,`remain_times` bigint(12)
);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `v_print_liliao`
-- （参见下面的实际视图）
--
CREATE TABLE `v_print_liliao` (
`cf_id` bigint(20) unsigned
,`visit_time` datetime
,`patient_name` varchar(64)
,`phone` varchar(32)
,`biaoti` varchar(255)
,`is_taocan` tinyint(1)
,`total_amount` decimal(12,2)
,`beizhu` text
,`seq` int(11)
,`xiangmu_name` varchar(128)
,`cishu` int(11)
,`danjia` decimal(12,2)
,`jine` decimal(12,2)
);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `v_print_xiyi`
-- （参见下面的实际视图）
--
CREATE TABLE `v_print_xiyi` (
`cf_id` bigint(20) unsigned
,`visit_time` datetime
,`patient_name` varchar(64)
,`phone` varchar(32)
,`beizhu` text
,`total_amount` decimal(12,2)
,`seq` int(11)
,`yaopin_name` varchar(128)
,`guige` varchar(128)
,`yongfa` varchar(128)
,`pinci` varchar(64)
,`meici_liang` varchar(64)
,`meiri_cishu` varchar(64)
,`tianshu` int(11)
,`mx_beizhu` varchar(255)
);

-- --------------------------------------------------------

--
-- 替换视图以便查看 `v_print_zhongyao`
-- （参见下面的实际视图）
--
CREATE TABLE `v_print_zhongyao` (
`cf_id` bigint(20) unsigned
,`visit_time` datetime
,`patient_name` varchar(64)
,`phone` varchar(32)
,`fufa` varchar(255)
,`jishu` int(11)
,`zhouqi` varchar(64)
,`meiri_cishu` decimal(10,2)
,`meici_liang` varchar(64)
,`yongyao_fangfa` varchar(255)
,`beizhu` text
,`total_amount` decimal(12,2)
,`seq` int(11)
,`yaowei_name` varchar(128)
,`yongliang` decimal(10,2)
,`danwei` varchar(16)
,`special_use` varchar(128)
);

-- --------------------------------------------------------

--
-- 表的结构 `yaopin`
--

CREATE TABLE `yaopin` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `fenlei` enum('中药饮片','中成药','西药口服','西药输液','耗材') NOT NULL,
  `name` varchar(128) NOT NULL,
  `spec` varchar(128) DEFAULT NULL,
  `unit` varchar(16) NOT NULL,
  `stock_qty` decimal(14,3) NOT NULL DEFAULT '0.000',
  `cost_price` decimal(12,4) DEFAULT NULL,
  `sale_price` decimal(12,4) DEFAULT NULL,
  `rec_dose` varchar(64) DEFAULT NULL,
  `default_usage` varchar(128) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `yaopin`
--

INSERT INTO `yaopin` (`id`, `fenlei`, `name`, `spec`, `unit`, `stock_qty`, `cost_price`, `sale_price`, `rec_dose`, `default_usage`, `remark`, `is_active`, `created_at`) VALUES
(1, '中药饮片', '黄芪', '切片', 'g', '5000.000', '0.0500', '0.1200', '10-30g', '水煎服', NULL, 1, '2025-09-02 07:42:05'),
(2, '中药饮片', '桂枝', '切片', 'g', '4000.000', '0.0600', '0.1500', '6-9g', '水煎服', NULL, 1, '2025-09-02 07:42:05'),
(3, '中成药', '藿香正气液', '10ml*6支', '盒', '100.000', '8.0000', '16.0000', '一次10ml', '口服', NULL, 1, '2025-09-02 07:42:05'),
(4, '西药口服', '阿莫西林胶囊', '0.5g*24粒', '盒', '200.000', '12.0000', '26.0000', '0.5g', '口服', NULL, 1, '2025-09-02 07:42:05'),
(5, '西药口服', '布洛芬缓释片', '0.3g*20片', '盒', '150.000', '15.0000', '32.0000', '0.3g', '口服', NULL, 1, '2025-09-02 07:42:05'),
(6, '西药输液', '0.9%氯化钠注射液', '500ml', '瓶', '80.000', '3.5000', '8.0000', NULL, '静滴', NULL, 1, '2025-09-02 07:42:05'),
(7, '耗材', '一次性注射器', '5ml', '支', '500.000', '0.5000', '1.0000', NULL, NULL, NULL, 1, '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 表的结构 `yizhu`
--

CREATE TABLE `yizhu` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `visit_id` bigint(20) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `copy_from_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 转存表中的数据 `yizhu`
--

INSERT INTO `yizhu` (`id`, `visit_id`, `content`, `copy_from_id`, `created_at`) VALUES
(1, 1, '多饮水休息，避免辛辣刺激', NULL, '2025-09-02 07:42:05'),
(2, 1, '如发热>38.5℃可对症退热', NULL, '2025-09-02 07:42:05'),
(3, 2, '注意工位人体工学，避免久坐', NULL, '2025-09-02 07:42:05');

-- --------------------------------------------------------

--
-- 视图结构 `v_liliao_shengyu`
--
DROP TABLE IF EXISTS `v_liliao_shengyu`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_liliao_shengyu`  AS  select `gm`.`patient_id` AS `patient_id`,`gmm`.`id` AS `goumai_mx_id`,`gmm`.`xiangmu_id` AS `xiangmu_id`,`gmm`.`xiangmu_name` AS `xiangmu_name`,greatest((`gmm`.`total_times` - `gmm`.`used_times`),0) AS `remain_times` from (`liliao_goumai_mingxi` `gmm` join `liliao_goumai` `gm` on((`gm`.`id` = `gmm`.`goumai_id`))) ;

-- --------------------------------------------------------

--
-- 视图结构 `v_print_liliao`
--
DROP TABLE IF EXISTS `v_print_liliao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_print_liliao`  AS  select `cf`.`id` AS `cf_id`,`jz`.`visit_time` AS `visit_time`,`hz`.`name` AS `patient_name`,`hz`.`phone` AS `phone`,`cf`.`biaoti` AS `biaoti`,`cf`.`is_taocan` AS `is_taocan`,`cf`.`total_amount` AS `total_amount`,`cf`.`beizhu` AS `beizhu`,`mx`.`seq` AS `seq`,`mx`.`xiangmu_name` AS `xiangmu_name`,`mx`.`cishu` AS `cishu`,`mx`.`danjia` AS `danjia`,`mx`.`jine` AS `jine` from (((`chufang` `cf` join `jiuzhen` `jz` on((`jz`.`id` = `cf`.`visit_id`))) join `huanzhe` `hz` on((`hz`.`id` = `jz`.`patient_id`))) left join `chufang_liliao_mx` `mx` on((`mx`.`chufang_id` = `cf`.`id`))) where (`cf`.`leixing` = '理疗') order by `cf`.`id`,`mx`.`seq` ;

-- --------------------------------------------------------

--
-- 视图结构 `v_print_xiyi`
--
DROP TABLE IF EXISTS `v_print_xiyi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_print_xiyi`  AS  select `cf`.`id` AS `cf_id`,`jz`.`visit_time` AS `visit_time`,`hz`.`name` AS `patient_name`,`hz`.`phone` AS `phone`,`cf`.`beizhu` AS `beizhu`,`cf`.`total_amount` AS `total_amount`,`mx`.`seq` AS `seq`,`mx`.`yaopin_name` AS `yaopin_name`,`mx`.`guige` AS `guige`,`mx`.`yongfa` AS `yongfa`,`mx`.`pinci` AS `pinci`,`mx`.`meici_liang` AS `meici_liang`,`mx`.`meiri_cishu` AS `meiri_cishu`,`mx`.`tianshu` AS `tianshu`,`mx`.`beizhu` AS `mx_beizhu` from (((`chufang` `cf` join `jiuzhen` `jz` on((`jz`.`id` = `cf`.`visit_id`))) join `huanzhe` `hz` on((`hz`.`id` = `jz`.`patient_id`))) join `chufang_xiyi_mx` `mx` on((`mx`.`chufang_id` = `cf`.`id`))) where (`cf`.`leixing` = '西医') order by `cf`.`id`,`mx`.`seq` ;

-- --------------------------------------------------------

--
-- 视图结构 `v_print_zhongyao`
--
DROP TABLE IF EXISTS `v_print_zhongyao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_print_zhongyao`  AS  select `cf`.`id` AS `cf_id`,`jz`.`visit_time` AS `visit_time`,`hz`.`name` AS `patient_name`,`hz`.`phone` AS `phone`,`cf`.`fufa` AS `fufa`,`cf`.`jishu` AS `jishu`,`cf`.`zhouqi` AS `zhouqi`,`cf`.`meiri_cishu` AS `meiri_cishu`,`cf`.`meici_liang` AS `meici_liang`,`cf`.`yongyao_fangfa` AS `yongyao_fangfa`,`cf`.`beizhu` AS `beizhu`,`cf`.`total_amount` AS `total_amount`,`mx`.`seq` AS `seq`,`mx`.`yaowei_name` AS `yaowei_name`,`mx`.`yongliang` AS `yongliang`,`mx`.`danwei` AS `danwei`,`mx`.`special_use` AS `special_use` from (((`chufang` `cf` join `jiuzhen` `jz` on((`jz`.`id` = `cf`.`visit_id`))) join `huanzhe` `hz` on((`hz`.`id` = `jz`.`patient_id`))) join `chufang_zhongyao_mx` `mx` on((`mx`.`chufang_id` = `cf`.`id`))) where (`cf`.`leixing` = '中医') order by `cf`.`id`,`mx`.`seq` ;

--
-- 转储表的索引
--

--
-- 表的索引 `chufang`
--
ALTER TABLE `chufang`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_visit_type` (`visit_id`,`leixing`);

--
-- 表的索引 `chufang_liliao_mx`
--
ALTER TABLE `chufang_liliao_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`),
  ADD KEY `xiangmu_id` (`xiangmu_id`);

--
-- 表的索引 `chufang_xiyi_mx`
--
ALTER TABLE `chufang_xiyi_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`),
  ADD KEY `yaopin_id` (`yaopin_id`);

--
-- 表的索引 `chufang_zhongyao_mx`
--
ALTER TABLE `chufang_zhongyao_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_cf_seq` (`chufang_id`,`seq`);

--
-- 表的索引 `huanzhe`
--
ALTER TABLE `huanzhe`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_name_phone` (`name`,`phone`),
  ADD KEY `idx_phone` (`phone`);

--
-- 表的索引 `jiuzhen`
--
ALTER TABLE `jiuzhen`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_patient_time` (`patient_id`,`DESC`);

--
-- 表的索引 `kucun_liushui`
--
ALTER TABLE `kucun_liushui`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_yp_time` (`yaopin_id`,`DESC`),
  ADD KEY `idx_type_time` (`liushui_type`,`DESC`);

--
-- 表的索引 `liliao_goumai`
--
ALTER TABLE `liliao_goumai`
  ADD PRIMARY KEY (`id`),
  ADD KEY `taocan_id` (`taocan_id`),
  ADD KEY `source_cf_id` (`source_cf_id`),
  ADD KEY `idx_patient_time` (`patient_id`,`DESC`);

--
-- 表的索引 `liliao_goumai_mingxi`
--
ALTER TABLE `liliao_goumai_mingxi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gm` (`goumai_id`),
  ADD KEY `idx_item` (`xiangmu_id`);

--
-- 表的索引 `liliao_taocan`
--
ALTER TABLE `liliao_taocan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_name` (`name`);

--
-- 表的索引 `liliao_taocan_mx`
--
ALTER TABLE `liliao_taocan_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_taocan_item` (`taocan_id`,`xiangmu_id`),
  ADD KEY `xiangmu_id` (`xiangmu_id`);

--
-- 表的索引 `liliao_xiangmu`
--
ALTER TABLE `liliao_xiangmu`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_name` (`name`);

--
-- 表的索引 `liliao_xiaoci_jilu`
--
ALTER TABLE `liliao_xiaoci_jilu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `goumai_mx_id` (`goumai_mx_id`),
  ADD KEY `xiangmu_id` (`xiangmu_id`),
  ADD KEY `cf_id` (`cf_id`),
  ADD KEY `idx_patient_time` (`patient_id`,`DESC`);

--
-- 表的索引 `liliao_zhixing_dan`
--
ALTER TABLE `liliao_zhixing_dan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cf_id` (`cf_id`),
  ADD KEY `idx_patient_date` (`patient_id`,`DESC`);

--
-- 表的索引 `liliao_zhixing_mx`
--
ALTER TABLE `liliao_zhixing_mx`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_zhixing` (`zhixing_id`);

--
-- 表的索引 `moban_chufang`
--
ALTER TABLE `moban_chufang`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_type_active` (`leixing`,`is_active`);

--
-- 表的索引 `moban_xiyi_mx`
--
ALTER TABLE `moban_xiyi_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_moban_seq` (`moban_id`,`seq`);

--
-- 表的索引 `moban_zhongyao_mx`
--
ALTER TABLE `moban_zhongyao_mx`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_moban_seq` (`moban_id`,`seq`);

--
-- 表的索引 `rizhi`
--
ALTER TABLE `rizhi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_visit_created` (`visit_id`,`DESC`);

--
-- 表的索引 `yaopin`
--
ALTER TABLE `yaopin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_name_spec_unit` (`name`,`spec`,`unit`),
  ADD KEY `idx_fenlei` (`fenlei`),
  ADD KEY `idx_active` (`is_active`);

--
-- 表的索引 `yizhu`
--
ALTER TABLE `yizhu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `copy_from_id` (`copy_from_id`),
  ADD KEY `idx_visit` (`visit_id`);

--
-- 在导出的表使用AUTO_INCREMENT
--

--
-- 使用表AUTO_INCREMENT `chufang`
--
ALTER TABLE `chufang`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `chufang_liliao_mx`
--
ALTER TABLE `chufang_liliao_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `chufang_xiyi_mx`
--
ALTER TABLE `chufang_xiyi_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `chufang_zhongyao_mx`
--
ALTER TABLE `chufang_zhongyao_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- 使用表AUTO_INCREMENT `huanzhe`
--
ALTER TABLE `huanzhe`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `jiuzhen`
--
ALTER TABLE `jiuzhen`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `kucun_liushui`
--
ALTER TABLE `kucun_liushui`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- 使用表AUTO_INCREMENT `liliao_goumai`
--
ALTER TABLE `liliao_goumai`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `liliao_goumai_mingxi`
--
ALTER TABLE `liliao_goumai_mingxi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `liliao_taocan`
--
ALTER TABLE `liliao_taocan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `liliao_taocan_mx`
--
ALTER TABLE `liliao_taocan_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 使用表AUTO_INCREMENT `liliao_xiangmu`
--
ALTER TABLE `liliao_xiangmu`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 使用表AUTO_INCREMENT `liliao_xiaoci_jilu`
--
ALTER TABLE `liliao_xiaoci_jilu`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `liliao_zhixing_dan`
--
ALTER TABLE `liliao_zhixing_dan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- 使用表AUTO_INCREMENT `liliao_zhixing_mx`
--
ALTER TABLE `liliao_zhixing_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `moban_chufang`
--
ALTER TABLE `moban_chufang`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `moban_xiyi_mx`
--
ALTER TABLE `moban_xiyi_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `moban_zhongyao_mx`
--
ALTER TABLE `moban_zhongyao_mx`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- 使用表AUTO_INCREMENT `rizhi`
--
ALTER TABLE `rizhi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- 使用表AUTO_INCREMENT `yaopin`
--
ALTER TABLE `yaopin`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- 使用表AUTO_INCREMENT `yizhu`
--
ALTER TABLE `yizhu`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 限制导出的表
--

--
-- 限制表 `chufang`
--
ALTER TABLE `chufang`
  ADD CONSTRAINT `chufang_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen` (`id`) ON DELETE CASCADE;

--
-- 限制表 `chufang_liliao_mx`
--
ALTER TABLE `chufang_liliao_mx`
  ADD CONSTRAINT `chufang_liliao_mx_ibfk_1` FOREIGN KEY (`chufang_id`) REFERENCES `chufang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chufang_liliao_mx_ibfk_2` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu` (`id`);

--
-- 限制表 `chufang_xiyi_mx`
--
ALTER TABLE `chufang_xiyi_mx`
  ADD CONSTRAINT `chufang_xiyi_mx_ibfk_1` FOREIGN KEY (`chufang_id`) REFERENCES `chufang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chufang_xiyi_mx_ibfk_2` FOREIGN KEY (`yaopin_id`) REFERENCES `yaopin` (`id`);

--
-- 限制表 `chufang_zhongyao_mx`
--
ALTER TABLE `chufang_zhongyao_mx`
  ADD CONSTRAINT `chufang_zhongyao_mx_ibfk_1` FOREIGN KEY (`chufang_id`) REFERENCES `chufang` (`id`) ON DELETE CASCADE;

--
-- 限制表 `jiuzhen`
--
ALTER TABLE `jiuzhen`
  ADD CONSTRAINT `jiuzhen_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe` (`id`) ON DELETE CASCADE;

--
-- 限制表 `kucun_liushui`
--
ALTER TABLE `kucun_liushui`
  ADD CONSTRAINT `kucun_liushui_ibfk_1` FOREIGN KEY (`yaopin_id`) REFERENCES `yaopin` (`id`);

--
-- 限制表 `liliao_goumai`
--
ALTER TABLE `liliao_goumai`
  ADD CONSTRAINT `liliao_goumai_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `liliao_goumai_ibfk_2` FOREIGN KEY (`taocan_id`) REFERENCES `liliao_taocan` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `liliao_goumai_ibfk_3` FOREIGN KEY (`source_cf_id`) REFERENCES `chufang` (`id`) ON DELETE SET NULL;

--
-- 限制表 `liliao_goumai_mingxi`
--
ALTER TABLE `liliao_goumai_mingxi`
  ADD CONSTRAINT `liliao_goumai_mingxi_ibfk_1` FOREIGN KEY (`goumai_id`) REFERENCES `liliao_goumai` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `liliao_goumai_mingxi_ibfk_2` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu` (`id`);

--
-- 限制表 `liliao_taocan_mx`
--
ALTER TABLE `liliao_taocan_mx`
  ADD CONSTRAINT `liliao_taocan_mx_ibfk_1` FOREIGN KEY (`taocan_id`) REFERENCES `liliao_taocan` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `liliao_taocan_mx_ibfk_2` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu` (`id`);

--
-- 限制表 `liliao_xiaoci_jilu`
--
ALTER TABLE `liliao_xiaoci_jilu`
  ADD CONSTRAINT `liliao_xiaoci_jilu_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `liliao_xiaoci_jilu_ibfk_2` FOREIGN KEY (`goumai_mx_id`) REFERENCES `liliao_goumai_mingxi` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `liliao_xiaoci_jilu_ibfk_3` FOREIGN KEY (`xiangmu_id`) REFERENCES `liliao_xiangmu` (`id`),
  ADD CONSTRAINT `liliao_xiaoci_jilu_ibfk_4` FOREIGN KEY (`cf_id`) REFERENCES `chufang` (`id`) ON DELETE SET NULL;

--
-- 限制表 `liliao_zhixing_dan`
--
ALTER TABLE `liliao_zhixing_dan`
  ADD CONSTRAINT `liliao_zhixing_dan_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `huanzhe` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `liliao_zhixing_dan_ibfk_2` FOREIGN KEY (`cf_id`) REFERENCES `chufang` (`id`) ON DELETE SET NULL;

--
-- 限制表 `liliao_zhixing_mx`
--
ALTER TABLE `liliao_zhixing_mx`
  ADD CONSTRAINT `liliao_zhixing_mx_ibfk_1` FOREIGN KEY (`zhixing_id`) REFERENCES `liliao_zhixing_dan` (`id`) ON DELETE CASCADE;

--
-- 限制表 `moban_xiyi_mx`
--
ALTER TABLE `moban_xiyi_mx`
  ADD CONSTRAINT `moban_xiyi_mx_ibfk_1` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang` (`id`) ON DELETE CASCADE;

--
-- 限制表 `moban_zhongyao_mx`
--
ALTER TABLE `moban_zhongyao_mx`
  ADD CONSTRAINT `moban_zhongyao_mx_ibfk_1` FOREIGN KEY (`moban_id`) REFERENCES `moban_chufang` (`id`) ON DELETE CASCADE;

--
-- 限制表 `rizhi`
--
ALTER TABLE `rizhi`
  ADD CONSTRAINT `rizhi_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen` (`id`) ON DELETE CASCADE;

--
-- 限制表 `yizhu`
--
ALTER TABLE `yizhu`
  ADD CONSTRAINT `yizhu_ibfk_1` FOREIGN KEY (`visit_id`) REFERENCES `jiuzhen` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `yizhu_ibfk_2` FOREIGN KEY (`copy_from_id`) REFERENCES `yizhu` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
