// ignore_for_file: constant_identifier_names

/// 门诊模块用到的 SQL 语句（集中管理，便于查找）
class MenZhenYuJu {
  // 患者栏：就诊中
  static const String sql_chaxun_jiuzhenzhong_liebiao = '''
    SELECT patient_id, patient_name, phone, started_at, updated_at
    FROM v_visit_in_session
    ORDER BY updated_at DESC
  ''';

  // 患者栏：今日完成（带 visit_id，便于打开已完成病历）
  static const String sql_chaxun_jinri_wancheng_liebiao = '''
    SELECT visit_id, patient_id, patient_name, phone, visit_time
    FROM (
      SELECT jz.id AS visit_id, jz.patient_id, hz.name AS patient_name, hz.phone, jz.visit_time
      FROM jiuzhen jz JOIN huanzhe hz ON hz.id = jz.patient_id
      WHERE DATE(jz.visit_time) = CURRENT_DATE()
    ) t
    ORDER BY visit_time DESC
  ''';

  // 搜索患者（姓名/电话）
  static const String sql_sousuo_huanzhe = '''
    SELECT id, name, phone
    FROM huanzhe
    WHERE name LIKE :kw OR phone LIKE :kw
    ORDER BY created_at DESC
    LIMIT 50
  ''';

  // 新建患者（必填：姓名/性别/生日[由年龄换算]/手机号）
  static const String sql_xinjian_huanzhe = '''
    INSERT INTO huanzhe(id, name, phone, gender, birthday, created_at, updated_at)
    VALUES (NULL, :name, :phone, :gender, :birthday, NOW(), NOW())
  ''';

  // 接诊：upsert 会话
  static const String sql_jiezhen_jiuzhen_session = '''
    INSERT INTO jiuzhen_session(id, patient_id, started_at, updated_at)
    VALUES (NULL, :pid, NOW(), NOW())
    ON DUPLICATE KEY UPDATE updated_at = NOW()
  ''';

  // 保存草稿：upsert
  static const String sql_baocun_caogao = '''
    INSERT INTO jiuzhen_draft(patient_id, zhusu, xianbingshi, linchuang_dx, zhongyi_dx, remark)
    VALUES (:pid, :a, :b, :c, :d, :e)
    ON DUPLICATE KEY UPDATE
      zhusu=:a, xianbingshi=:b, linchuang_dx=:c, zhongyi_dx=:d, remark=:e, updated_at=NOW()
  ''';

  // 读取草稿
  static const String sql_duqu_caogao = '''
    SELECT zhusu, xianbingshi, linchuang_dx, zhongyi_dx, remark
    FROM jiuzhen_draft WHERE patient_id = :pid
  ''';

  // 接诊完成：调用存储过程
  static const String sql_wancheng_jiezhen = 'CALL sp_complete_visit(:pid)';

  // 历史就诊
  static const String sql_lishi_jiuzhen = '''
    SELECT visit_id, visit_time, summary_dx
    FROM v_patient_visit_history
    WHERE patient_id = :pid
    ORDER BY visit_time DESC
    LIMIT 100
  ''';

  // 读取已完成病历（用于“今日完成”点击后在中栏展示）
  static const String sql_duqu_wancheng_bingli = '''
    SELECT jz.id AS visit_id,
           jz.patient_id,
           jz.zhusu, jz.xianbingshi, jz.linchuang_dx, jz.zhongyi_dx, jz.remark AS visit_remark,
           jz.advice_text, jz.visit_log,
           hz.name, hz.phone, hz.gender, hz.birthday,
           hz.allergy_history, hz.past_medical_history, hz.patient_remark
    FROM jiuzhen jz
    JOIN huanzhe hz ON hz.id = jz.patient_id
    WHERE jz.id = :vid
    LIMIT 1
  ''';

  // 患者扩展信息（仅三项可改）
  static const String sql_duqu_huanzhe_xinxi = '''
    SELECT allergy_history, past_medical_history, patient_remark
    FROM huanzhe WHERE id = :pid
  ''';

  static const String sql_gengxin_huanzhe_xinxi = '''
    UPDATE huanzhe
      SET allergy_history = :a,
          past_medical_history = :b,
          patient_remark = :c,
          updated_at = NOW()
    WHERE id = :pid
  ''';

  // 医嘱（按 visit 维护，保存时清空后重插简化）
  static const String sql_liebiao_yizhu = '''
    SELECT id, content FROM yizhu WHERE visit_id = :vid ORDER BY id ASC
  ''';
  static const String sql_qingkong_yizhu = '''
    DELETE FROM yizhu WHERE visit_id = :vid
  ''';
  static const String sql_tianjia_yizhu = '''
    INSERT INTO yizhu(visit_id, content, copy_from_id) VALUES(:vid, :content, NULL)
  ''';

  // 门诊日志（按患者维度）
  static const String sql_tianjia_menzhen_rizhi = '''
    INSERT INTO menzhen_rizhi(id, patient_id, content, created_at) VALUES (NULL, :pid, :content, NOW())
  ''';
  static const String sql_liebiao_menzhen_rizhi = '''
    SELECT id, content, created_at FROM menzhen_rizhi WHERE patient_id = :pid ORDER BY created_at DESC
  ''';
  // 删除：就诊中（草稿 + 会话）
  static const String sql_shanchu_jiuzhen_draft =
      'DELETE FROM jiuzhen_draft WHERE patient_id = :pid';
  static const String sql_shanchu_jiuzhen_session =
      'DELETE FROM jiuzhen_session WHERE patient_id = :pid';

  // 删除：已完成就诊（按 visitId）
  static const String sql_shanchu_wancheng_visit =
      'DELETE FROM jiuzhen WHERE id = :vid';

  // 读取患者基础信息（用于展示性别/生日）
  static const String sql_duqu_huanzhe_jiben = '''
    SELECT id, name, phone, gender, birthday
    FROM huanzhe WHERE id = :pid
  ''';
  // 覆盖更新：已完成就诊的病历主数据（不改日期时间）
  static const String sql_gengxin_bingli_by_visitid = '''
    UPDATE jiuzhen
      SET zhusu = :a,
          xianbingshi = :b,
          linchuang_dx = :c,
          zhongyi_dx = :d,
          remark = :e,
          advice_text = :f,
          visit_log  = :g,
          updated_at = NOW()
    WHERE id = :vid
  ''';
}
