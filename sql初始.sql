
/* ==================== 1) 患者（跨 3 天，展示编号习惯） ==================== */
INSERT INTO huanzhe (bianhao, xingming, xingbie, chusheng_riqi, dianhua, dizhi, beizhu)
VALUES
('20250905001','张三','M','1990-03-12','13800000001','朝阳','首诊'),
('20250905002','李四','F','1988-07-21','13800000002','海淀','过敏史见档'),
('20250906001','王五','M','1979-11-02','13800000003','丰台','复诊'),
('20250907001','赵六','M','1991-04-10','13900000001','东城','新患者A'),
('20250907002','孙七','F','1985-12-05','13900000002','西城','新患者B');

/* 当日序列表（不回填编号演示） */
INSERT INTO bianhao_xulie (id, riqi, mokuai, dangri_zuidaxuhao)
VALUES
(1,'2025-09-05','huanzhe',2),
(2,'2025-09-06','huanzhe',1),
(3,'2025-09-07','huanzhe',2);

/* ==================== 2) 就诊（四状态全覆盖） ==================== */
INSERT INTO jiuzhen (id, huanzhe_bianhao, jiuzhen_shijian, zhuangtai, linchuang_zhenduan, zhongyi_zhenduan, beizhu)
VALUES
(3001,'20250905001','2025-09-05 10:00:00','wancheng','上呼吸道感染','风寒感冒','完成案例'),
(3002,'20250905002','2025-09-05 11:00:00','jiezhenzhong','颈肩痛','经筋痹证','接诊中，可暂停'),
(3003,'20250906001','2025-09-06 09:00:00','caogao',NULL,NULL,'草稿，未完善'),
(3004,'20250905002','2025-09-05 13:00:00','quxiao','咽喉不适',NULL,'患者取消'),
(3005,'20250907001','2025-09-07 09:10:00','wancheng','上呼吸道感染','外感风寒','完成案例2'),
(3006,'20250907002','2025-09-07 09:30:00','jiezhenzhong','颈肩肌紧张','筋伤','接诊中案例2');

/* ==================== 3) 药房（启用/停用/缺货/近效期/默认用法） ==================== */
-- 中药（单位=g）
INSERT INTO yaopin (id, zhonglei, mingcheng, danwei, jinjia, maijia, guoqi_riqi, kucun_liang, moren_yongfa, qiyong)
VALUES
(1101,'zhongyao','桂枝','g',0.05,0.08,'2026-12-31',500.000,'煎服',1),
(1102,'zhongyao','芍药','g',0.04,0.07,'2026-12-31',480.000,'煎服',1),
(1103,'zhongyao','生姜','g',0.03,0.05,'2026-12-31',450.000,'煎服',1),
(1104,'zhongyao','大枣','g',0.02,0.04,'2026-12-31',600.000,'煎服',1),
(1105,'zhongyao','甘草','g',0.03,0.06,'2026-12-31',470.000,'煎服',1),
(1106,'zhongyao','麻黄','g',0.05,0.08,'2026-12-31',420.000,'煎服',1),
(1107,'zhongyao','杏仁','g',0.07,0.10,'2026-12-31',300.000,'煎服',1),
(1108,'zhongyao','当归','g',0.08,0.12,'2026-12-31',320.000,'煎/外洗',1),
(1109,'zhongyao','川芎','g',0.07,0.11,'2026-12-31',350.000,'煎/外洗',1),
(1111,'zhongyao','艾叶','g',0.03,0.05,'2026-12-31',380.000,'外洗/艾灸',1);

-- 西药（覆盖全部途径；含缺货/停用/近效期示例）
INSERT INTO yaopin (id, zhonglei, mingcheng, danwei, jinjia, maijia, guoqi_riqi, kucun_liang, moren_yongfa, qiyong)
VALUES
(201,'xiyao','阿莫西林胶囊 0.25g','粒',0.80,1.20,'2027-03-31',300.000,'口服',1),
(601,'xiyao','甲硝唑片 0.2g','片',0.30,0.60,'2027-06-30',500.000,'口服',1),
(602,'xiyao','氯雷他定片 10mg','片',0.50,0.90,'2027-06-30',400.000,'口服/睡前',1),
(305,'xiyao','维生素C注射液 2ml:0.5g','支',5.00,8.00,'2026-08-31', 80.000,'静脉',1),
(331,'xiyao','维生素B12注射液 1ml:0.5mg','支',4.00,6.00,'2026-08-31', 60.000,'肌注',1),
(530,'xiyao','胰岛素注射液 1ml:100IU','支',15.00,20.00,'2026-12-31', 40.000,'皮下',1),
(410,'xiyao','莫匹罗星软膏 10g','支',12.00,18.00,'2026-02-28', 10.000,'外用',1),
(420,'xiyao','复方水杨酸贴膏','贴',6.00,10.00,'2026-05-31', 50.000,'外用',1),
(540,'xiyao','异丙托溴铵雾化溶液 2ml','支',10.00,14.00,'2026-08-31', 30.000,'雾化',1),
(512,'xiyao','布地奈德雾化混悬液 2ml:0.5mg','支',12.00,16.00,'2026-08-31',  0.000,'雾化',1), -- 缺货
(333,'xiyao','青霉素钠注射用','支',3.00,5.00,'2025-12-31', 30.000,'静脉',0); -- 停用

-- 报损记录（举例）
INSERT INTO yaopin_baosun (id, yaopin_id, shuliang, yuanyin, baosun_shijian, beizhu)
VALUES (1,410,1.000,'破损','2025-09-05 09:00:00','开封外泄');

/* ==================== 4) 理疗（单项目/套餐；购买/配额/消次/退款标记） ==================== */
INSERT INTO liliao_xiangmu (id, mingcheng, jiage, beizhu, qiyong)
VALUES
(12,'针灸',50.00,'肩颈',1),(18,'推拿',80.00,'局部放松',1),(31,'艾灸',60.00,'温灸',1),(32,'刮痧',45.00,'板刮',1);

INSERT INTO liliao_taocan (id, mingcheng, jiage, beizhu, qiyong)
VALUES (9,'肩颈组合10次',399.00,'针灸×6 + 推拿×4',1),(15,'套餐一：艾灸10+刮痧5',888.00,'两类项目组合',1);

INSERT INTO liliao_taocan_mingxi (id, taocan_id, xiangmu_id, cishu, beizhu)
VALUES (9001,9,12,6,'针灸'),(9002,9,18,4,'推拿'),(15001,15,31,10,'艾灸10'),(15002,15,32,5,'刮痧5');

-- 张三购买套餐9（使用两次：针灸1/推拿1）
INSERT INTO huanzhe_taocan (id, huanzhe_bianhao, taocan_id, goumai_shijian, zong_cishu, shengyu_cishu, zhuangtai, beizhu)
VALUES (7001,'20250905001',9,'2025-09-05 10:30:00',10,8,'active','首诊购买');
INSERT INTO huanzhe_taocan_mingxi (id, huanzhe_taocan_id, xiangmu_id, zong_cishu, shengyu_cishu)
VALUES (7101,7001,12,6,5),(7102,7001,18,4,3);
INSERT INTO liliao_xiaoci (id, huanzhe_bianhao, xiangmu_id, laiyuan, laiyuan_mingxi_id, xiaoci_shijian, beizhu)
VALUES (8001,'20250905001',12,'taocan',7101,'2025-09-05 11:00:00','套餐消次：针灸'),(8002,'20250905001',18,'taocan',7102,'2025-09-06 10:00:00','套餐消次：推拿');

-- 李四购买套餐15（同日做艾灸+刮痧各一次；再仅做艾灸一次；随后做部分退款标记）
INSERT INTO huanzhe_taocan (id, huanzhe_bianhao, taocan_id, goumai_shijian, zong_cishu, shengyu_cishu, zhuangtai, beizhu)
VALUES (7010,'20250905002',15,'2025-09-05 14:00:00',15,12,'active','演示：套餐一');
INSERT INTO huanzhe_taocan_mingxi (id, huanzhe_taocan_id, xiangmu_id, zong_cishu, shengyu_cishu)
VALUES (7110,7010,31,10,8),(7111,7010,32,5,4);
INSERT INTO liliao_xiaoci (id, huanzhe_bianhao, xiangmu_id, laiyuan, laiyuan_mingxi_id, xiaoci_shijian, beizhu)
VALUES (8003,'20250905002',31,'taocan',7110,'2025-09-05 15:00:00','套餐消次：艾灸'),(8004,'20250905002',32,'taocan',7111,'2025-09-05 15:30:00','套餐消次：刮痧'),(8005,'20250905002',31,'taocan',7110,'2025-09-06 09:20:00','套餐消次：仅艾灸');
-- 部分退款示例（仅标记）：把状态置为 tuikuan，并在备注写明“退回 3 次”；剩余次数按实际结算调整。
UPDATE huanzhe_taocan SET zhuangtai='tuikuan', beizhu='部分退款：退回3次（总剩余改为9）', shengyu_cishu=9 WHERE id=7010;
UPDATE huanzhe_taocan_mingxi SET shengyu_cishu=7 WHERE id=7110; -- 调整艾灸剩余（示意）

-- 王五做单项目（非套餐）消次
INSERT INTO liliao_xiaoci (id, huanzhe_bianhao, xiangmu_id, laiyuan, laiyuan_mingxi_id, xiaoci_shijian, beizhu)
VALUES (8006,'20250906001',32,'danxiangmu',NULL,'2025-09-06 11:00:00','单次刮痧');

/* ==================== 5) 处方模板（3 类常用） ==================== */
INSERT INTO chufang_moban (id, leixing, mingcheng, neirong_json, beizhu, qiyong)
VALUES
(100,'xiyao','上呼感（口服+雾化）',
 JSON_OBJECT('banben',22,'leixing','xiyao','items', JSON_ARRAY(
   JSON_OBJECT('yaopin_id',201,'yaopin_ming','阿莫西林胶囊 0.25g','guige','0.25g*24','yongfa_leixing','chiyong','tujing','po','jiliang',0.5,'danwei','g','pinci','bid','tianshu',5,'shuliang',20),
   JSON_OBJECT('yaopin_id',512,'yaopin_ming','布地奈德雾化混悬液','guige','2ml:0.5mg','yongfa_leixing','qita','tujing','neb','jiliang',2,'danwei','ml','pinci','bid','tianshu',5,'shuliang',10)
  )),'常见感冒',1),
(101,'zhongyao','麻黄汤（jishu=3）',
 JSON_OBJECT('banben',22,'leixing','zhongyao','items', JSON_ARRAY(
   JSON_OBJECT('yaopin_id',1106,'yaocai_ming','麻黄','yongliang',9,'danwei','g'),
   JSON_OBJECT('yaopin_id',1101,'yaocai_ming','桂枝','yongliang',9,'danwei','g'),
   JSON_OBJECT('yaopin_id',1107,'yaocai_ming','杏仁','yongliang',6,'danwei','g'),
   JSON_OBJECT('yaopin_id',1105,'yaocai_ming','甘草','yongliang',6,'danwei','g')
 ), 'qita', JSON_OBJECT('jianfa','先煎麻黄10分钟','fufa','煎服','jishu',3)
 ),'基础方',1),
(102,'liliao','肩颈组合10次（可打折）',
 JSON_OBJECT('banben',22,'leixing','liliao','items', JSON_ARRAY(
   JSON_OBJECT('leixing','taocan','taocan_id',9,'mingcheng','肩颈组合10次','danjia',399.0,
     'mingxi', JSON_ARRAY(
       JSON_OBJECT('liliao_xiangmu_id',12,'xiangmu_ming','针灸','cishu',6),
       JSON_OBJECT('liliao_xiangmu_id',18,'xiangmu_ming','推拿','cishu',4)
     )
   )
 )),'常用套餐',1);

/* ==================== 6) 处方（三大类全部用法） ==================== */
DELETE FROM chufang;
-- 西药：一次性覆盖 口服/IV/IM/SC/外用/雾化
INSERT INTO chufang (id, jiuzhen_id, huanzhe_bianhao, leixing, bingqing_xinxi, neirong_json, zong_jine, yisheng_qianming, yishoufei, beizhu, chuangjian_shijian)
VALUES
(7001,3005,'20250907001','xiyao','上呼吸道感染，伴鼻塞咳嗽',
 JSON_OBJECT('banben',22,'leixing','xiyao','items', JSON_ARRAY(
   JSON_OBJECT('yaopin_id',201,'yaopin_ming','阿莫西林胶囊','guige','0.25g*24','yongfa_leixing','chiyong','tujing','po','jiliang',0.5,'danwei','g','pinci','bid','tianshu',5,'shuliang',20,'danjia',1.2,'xiaoji',24.0,'yongfa_shuoming','饭后'),
   JSON_OBJECT('yaopin_id',601,'yaopin_ming','甲硝唑片','guige','0.2g*24','yongfa_leixing','chiyong','tujing','po','jiliang',0.4,'danwei','g','pinci','tid','tianshu',3,'shuliang',18,'danjia',0.6,'xiaoji',10.8),
   JSON_OBJECT('yaopin_id',602,'yaopin_ming','氯雷他定片','guige','10mg*10','yongfa_leixing','chiyong','tujing','po','jiliang',10,'danwei','mg','pinci','qhs','tianshu',5,'shuliang',5,'danjia',0.9,'xiaoji',4.5),
   JSON_OBJECT('yaopin_id',305,'yaopin_ming','维生素C注射液','guige','2ml:0.5g','yongfa_leixing','dazhen','tujing','iv','jiliang',2,'danwei','ml','pinci','qd','tianshu',3,'shuliang',3,'danjia',8.0,'xiaoji',24.0),
   JSON_OBJECT('yaopin_id',331,'yaopin_ming','维生素B12注射液','guige','1ml:0.5mg','yongfa_leixing','dazhen','tujing','im','jiliang',1,'danwei','ml','pinci','qd','tianshu',3,'shuliang',3,'danjia',6.0,'xiaoji',18.0),
   JSON_OBJECT('yaopin_id',530,'yaopin_ming','胰岛素注射液','guige','1ml:100IU','yongfa_leixing','dazhen','tujing','sc','jiliang',10,'danwei','IU','pinci','tid','tianshu',2,'shuliang',6,'danjia',20.0,'xiaoji',120.0,'yongfa_shuoming','餐前'),
   JSON_OBJECT('yaopin_id',410,'yaopin_ming','莫匹罗星软膏','guige','10g','yongfa_leixing','waiyong','tujing','topical','shuliang',1,'danjia',18.0,'xiaoji',18.0),
   JSON_OBJECT('yaopin_id',420,'yaopin_ming','复方水杨酸贴膏','guige','贴','yongfa_leixing','waiyong','tujing','topical','shuliang',2,'danjia',10.0,'xiaoji',20.0),
   JSON_OBJECT('yaopin_id',540,'yaopin_ming','异丙托溴铵雾化溶液','guige','2ml','yongfa_leixing','qita','tujing','neb','jiliang',2,'danwei','ml','pinci','bid','tianshu',3,'shuliang',6,'danjia',14.0,'xiaoji',84.0),
   JSON_OBJECT('yaopin_id',512,'yaopin_ming','布地奈德雾化混悬液','guige','2ml:0.5mg','yongfa_leixing','qita','tujing','neb','jiliang',2,'danwei','ml','pinci','bid','tianshu',3,'shuliang',6,'danjia',16.0,'xiaoji',96.0)
 )) , 395.3,'王医生',1,'一次性覆盖全部用法；注意 512 当前缺货', '2025-09-07 09:20:00');

-- 中药：麻黄汤（煎服，jishu=3） + 外洗方
INSERT INTO chufang (id, jiuzhen_id, huanzhe_bianhao, leixing, bingqing_xinxi, neirong_json, zong_jine, yisheng_qianming, yishoufei, beizhu, chuangjian_shijian)
VALUES
(7010,3002,'20250905002','zhongyao','风寒感冒（麻黄汤）',
 JSON_OBJECT('banben',22,'leixing','zhongyao','items', JSON_ARRAY(
   JSON_OBJECT('yaopin_id',1106,'yaocai_ming','麻黄','yongliang',9,'danwei','g'),
   JSON_OBJECT('yaopin_id',1101,'yaocai_ming','桂枝','yongliang',9,'danwei','g'),
   JSON_OBJECT('yaopin_id',1107,'yaocai_ming','杏仁','yongliang',6,'danwei','g'),
   JSON_OBJECT('yaopin_id',1105,'yaocai_ming','甘草','yongliang',6,'danwei','g')
 ),'qita', JSON_OBJECT('jianfa','先煎麻黄10分钟','fufa','煎服','jishu',3)
 )) , 0.00,'王医生',1,'价格前端计算', '2025-09-05 11:10:00'),
(7011,3002,'20250905002','zhongyao','局部外洗（当归川芎艾叶）',
 JSON_OBJECT('banben',22,'leixing','zhongyao','items', JSON_ARRAY(
   JSON_OBJECT('yaopin_id',1108,'yaocai_ming','当归','yongliang',20,'danwei','g'),
   JSON_OBJECT('yaopin_id',1109,'yaocai_ming','川芎','yongliang',15,'danwei','g'),
   JSON_OBJECT('yaopin_id',1111,'yaocai_ming','艾叶','yongliang',10,'danwei','g')
 ),'qita', JSON_OBJECT('jianfa','水煎取汁','fufa','外洗','jishu',1)
 )) , 0.00,'王医生',1,'外治法', '2025-09-05 11:15:00');

-- 理疗：单项目 + 套餐混合（含折扣）
INSERT INTO chufang (id, jiuzhen_id, huanzhe_bianhao, leixing, bingqing_xinxi, neirong_json, zong_jine, yisheng_qianming, yishoufei, beizhu, chuangjian_shijian)
VALUES
(7020,3006,'20250907002','liliao','颈肩肌紧张（当次做艾灸+刮痧）',
 JSON_OBJECT('banben',22,'leixing','liliao','items', JSON_ARRAY(
   JSON_OBJECT('leixing','danxiangmu','liliao_xiangmu_id',31,'xiangmu_ming','艾灸','cishu',1,'danjia',60.0,'xiaoji',60.0),
   JSON_OBJECT('leixing','danxiangmu','liliao_xiangmu_id',32,'xiangmu_ming','刮痧','cishu',1,'danjia',45.0,'xiaoji',45.0),
   JSON_OBJECT('leixing','taocan','taocan_id',9,'mingcheng','肩颈组合10次','danjia',399.0,'shifu_jine',360.0,
     'mingxi', JSON_ARRAY(
       JSON_OBJECT('liliao_xiangmu_id',12,'xiangmu_ming','针灸','cishu',6),
       JSON_OBJECT('liliao_xiangmu_id',18,'xiangmu_ming','推拿','cishu',4)
     )
   )
 )) , 465.0,'王医生',1,'套餐入账待后续逐次消耗', '2025-09-07 09:50:00');

/* ==================== 7) 视图（最后重建） ==================== */
CREATE OR REPLACE VIEW v_kexuan_yaopin AS
SELECT id, zhonglei, mingcheng, danwei, maijia, kucun_liang
FROM yaopin
WHERE qiyong = 1 AND kucun_liang > 0;

/* ==================== 8) 完成接诊 → 扣库存 事务示例 ==================== */
-- 约定：由 Flutter 先汇总某处方需要扣减的 {yaopin_id: 数量}；
-- 成功示例：对处方 7001 扣库存（示意值与上面 JSON 保持一致）
START TRANSACTION;
  UPDATE yaopin SET kucun_liang = kucun_liang - 20 WHERE id=201 AND kucun_liang >= 20;      SELECT ROW_COUNT() INTO @A1;
  UPDATE yaopin SET kucun_liang = kucun_liang - 18 WHERE id=601 AND kucun_liang >= 18;      SELECT ROW_COUNT() INTO @A2;
  UPDATE yaopin SET kucun_liang = kucun_liang - 5  WHERE id=602 AND kucun_liang >= 5;       SELECT ROW_COUNT() INTO @A3;
  UPDATE yaopin SET kucun_liang = kucun_liang - 3  WHERE id=305 AND kucun_liang >= 3;       SELECT ROW_COUNT() INTO @A4;
  UPDATE yaopin SET kucun_liang = kucun_liang - 3  WHERE id=331 AND kucun_liang >= 3;       SELECT ROW_COUNT() INTO @A5;
  UPDATE yaopin SET kucun_liang = kucun_liang - 6  WHERE id=530 AND kucun_liang >= 6;       SELECT ROW_COUNT() INTO @A6;
  UPDATE yaopin SET kucun_liang = kucun_liang - 1  WHERE id=410 AND kucun_liang >= 1;       SELECT ROW_COUNT() INTO @A7;
  UPDATE yaopin SET kucun_liang = kucun_liang - 2  WHERE id=420 AND kucun_liang >= 2;       SELECT ROW_COUNT() INTO @A8;
  UPDATE yaopin SET kucun_liang = kucun_liang - 6  WHERE id=540 AND kucun_liang >= 6;       SELECT ROW_COUNT() INTO @A9;
  -- 注意：512 当前库存=0，视图已过滤，不应出现在可选列表；若仍在处方草稿中，完成时会失败→见失败示例
  SET @ok = (@A1+@A2+@A3+@A4+@A5+@A6+@A7+@A8+@A9 = 9);
  IF @ok THEN COMMIT; ELSE ROLLBACK; END IF;

-- 失败示例：尝试对 512 扣 6 支，但库存=0 → 回滚
START TRANSACTION;
  UPDATE yaopin SET kucun_liang = kucun_liang - 6 WHERE id=512 AND kucun_liang >= 6;  SELECT ROW_COUNT() INTO @B1;
  SET @ok = (@B1 = 1);
  IF @ok THEN COMMIT; ELSE ROLLBACK; END IF;
