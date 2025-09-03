import 'package:mysql_client/mysql_client.dart';
import '../lianjie_chi.dart';
import '../yujus/menzhen_yuju.dart';
import '../../shuju_moban/huanzhe.dart';
import '../../shuju_moban/huanzhe_xinxi.dart';
import '../../shuju_moban/menzhen_caogao.dart';
import '../../shuju_moban/menzhen_liebiao_xiang.dart';
import '../../shuju_moban/lishi_jiuzhen_xiang.dart';

/// 门诊“仓库”：对外提供简洁方法，内部使用 SQL
class MenZhenCangKuMySql {
  final MySQLConnectionPool _chi = LianJieChi.chi;

  Future<List<MenZhenLieBiaoXiang>> chaxunJiuZhenZhongLieBiao() async {
    final rs = await _chi.execute(MenZhenYuJu.sql_chaxun_jiuzhenzhong_liebiao);
    return rs.rows.map((r) {
      return MenZhenLieBiaoXiang(
        patientId: int.parse(r.colByName('patient_id')!),
        name: r.colByName('patient_name') ?? '',
        phone: r.colByName('phone') ?? '',
        time: DateTime.parse(r.colByName('updated_at')!),
        inSession: true,
      );
    }).toList();
  }

  Future<List<MenZhenLieBiaoXiang>> chaxunJinRiWanChengLieBiao() async {
    final rs = await _chi.execute(
      MenZhenYuJu.sql_chaxun_jinri_wancheng_liebiao,
    );
    return rs.rows.map((r) {
      return MenZhenLieBiaoXiang(
        patientId: int.parse(r.colByName('patient_id')!),
        name: r.colByName('patient_name') ?? '',
        phone: r.colByName('phone') ?? '',
        time: DateTime.parse(r.colByName('visit_time')!),
        inSession: false,
        visitId: int.parse(r.colByName('visit_id')!),
      );
    }).toList();
  }

  Future<List<Huanzhe>> sousuoHuanzhe(String guanjianzi) async {
    final like = '%$guanjianzi%';
    final rs = await _chi.execute(MenZhenYuJu.sql_sousuo_huanzhe, {'kw': like});
    return rs.rows
        .map(
          (r) => Huanzhe(
            id: int.parse(r.colByName('id')!),
            name: r.colByName('name') ?? '',
            phone: r.colByName('phone') ?? '',
          ),
        )
        .toList();
  }

  /// 新建患者（必填：姓名/性别/年龄/手机号）
  Future<int> xinjianHuanzhe({
    required String xingming,
    required String xingbie, // '男' | '女' | '未知'
    required int nianling, // 正整数
    required String dianhua,
  }) async {
    final now = DateTime.now();
    final shengri = DateTime(now.year - nianling, now.month, now.day);
    final shengriStr = shengri.toIso8601String().substring(0, 10); // yyyy-MM-dd

    final rs = await _chi.execute(MenZhenYuJu.sql_xinjian_huanzhe, {
      'name': xingming,
      'phone': dianhua,
      'gender': xingbie,
      'birthday': shengriStr,
    });
    return rs.lastInsertID.toInt();
  }

  Future<void> jiezhen(int patientId) async {
    await _chi.execute(MenZhenYuJu.sql_jiezhen_jiuzhen_session, {
      'pid': patientId,
    });
  }

  Future<void> baocunCaoGao(MenZhenCaoGao d) async {
    await _chi.execute(MenZhenYuJu.sql_baocun_caogao, {
      'pid': d.patientId,
      'a': d.zhusu,
      'b': d.xianbingshi,
      'c': d.linchuangDx,
      'd': d.zhongyiDx,
      'e': d.beizhu,
    });
  }

  Future<MenZhenCaoGao?> duquCaoGao(int patientId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_duqu_caogao, {
      'pid': patientId,
    });
    if (rs.rows.isEmpty) return MenZhenCaoGao(patientId: patientId);
    final r = rs.rows.first;
    return MenZhenCaoGao(
      patientId: patientId,
      zhusu: r.colByName('zhusu'),
      xianbingshi: r.colByName('xianbingshi'),
      linchuangDx: r.colByName('linchuang_dx'),
      zhongyiDx: r.colByName('zhongyi_dx'),
      beizhu: r.colByName('remark'),
    );
  }

  Future<void> wanchengJieZhen(int patientId) async {
    await _chi.execute(MenZhenYuJu.sql_wancheng_jiezhen, {'pid': patientId});
  }

  Future<List<LiShiJiuZhenXiang>> lishiJiuzhen(int patientId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_lishi_jiuzhen, {
      'pid': patientId,
    });
    return rs.rows
        .map(
          (r) => LiShiJiuZhenXiang(
            visitId: int.parse(r.colByName('visit_id')!),
            visitTime: DateTime.parse(r.colByName('visit_time')!),
            summaryDx: r.colByName('summary_dx') ?? '',
          ),
        )
        .toList();
  }

  /// 读取已完成病历（通过 visitId）
  Future<(Huanzhe, HuanzheXinXi, MenZhenCaoGao, String?, String?)?>
  duquWanChengBingLi(int visitId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_duqu_wancheng_bingli, {
      'vid': visitId,
    });
    if (rs.rows.isEmpty) return null;
    final r = rs.rows.first;
    final p = Huanzhe(
      id: int.parse(r.colByName('patient_id')!),
      name: r.colByName('name') ?? '',
      phone: r.colByName('phone') ?? '',
      gender: r.colByName('gender'),
      birthday: r.colByName('birthday') != null
          ? DateTime.parse(r.colByName('birthday')!)
          : null,
    );
    final px = HuanzheXinXi(
      patientId: p.id,
      guominshi: r.colByName('allergy_history'),
      jiwangshi: r.colByName('past_medical_history'),
      huanzheBeizhu: r.colByName('patient_remark'),
    );
    final bl = MenZhenCaoGao(
      patientId: p.id,
      zhusu: r.colByName('zhusu'),
      xianbingshi: r.colByName('xianbingshi'),
      linchuangDx: r.colByName('linchuang_dx'),
      zhongyiDx: r.colByName('zhongyi_dx'),
      beizhu: r.colByName('visit_remark'),
    );
    final yizhuText = r.colByName('advice_text');
    final rizhiText = r.colByName('visit_log');
    return (p, px, bl, yizhuText, rizhiText);
  }

  /// 读取/保存 患者扩展信息（过敏史/既往史/患者备注）
  Future<HuanzheXinXi> duquHuanzheXinxi(int patientId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_duqu_huanzhe_xinxi, {
      'pid': patientId,
    });
    if (rs.rows.isEmpty) return HuanzheXinXi(patientId: patientId);
    final r = rs.rows.first;
    return HuanzheXinXi(
      patientId: patientId,
      guominshi: r.colByName('allergy_history'),
      jiwangshi: r.colByName('past_medical_history'),
      huanzheBeizhu: r.colByName('patient_remark'),
    );
  }

  Future<void> gengxinHuanzheXinxi(HuanzheXinXi x) async {
    await _chi.execute(MenZhenYuJu.sql_gengxin_huanzhe_xinxi, {
      'pid': x.patientId,
      'a': x.guominshi,
      'b': x.jiwangshi,
      'c': x.huanzheBeizhu,
    });
  }

  /// 医嘱：读取/保存（保存时重建序号 1.,2.,3.）
  Future<List<String>> duquYiZhu(int visitId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_liebiao_yizhu, {
      'vid': visitId,
    });
    return rs.rows.map((r) => r.colByName('content') ?? '').toList();
  }

  Future<void> baocunYiZhu(int visitId, List<String> lines) async {
    await _chi.execute(MenZhenYuJu.sql_qingkong_yizhu, {'vid': visitId});
    int i = 1;
    for (final raw in lines) {
      final text = raw.trim();
      if (text.isEmpty) continue;
      final numbered = text.startsWith(RegExp(r'^\d+\.')) ? text : '$i. $text';
      await _chi.execute(MenZhenYuJu.sql_tianjia_yizhu, {
        'vid': visitId,
        'content': numbered,
      });
      i++;
    }
  }

  /// 门诊日志（按患者维度）
  Future<void> tianjiaMenZhenRiZhi(int patientId, String content) async {
    await _chi.execute(MenZhenYuJu.sql_tianjia_menzhen_rizhi, {
      'pid': patientId,
      'content': content,
    });
  }

  Future<List<(DateTime, String)>> liebiaoMenZhenRiZhi(int patientId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_liebiao_menzhen_rizhi, {
      'pid': patientId,
    });
    return rs.rows
        .map(
          (r) => (
            DateTime.parse(r.colByName('created_at')!),
            r.colByName('content') ?? '',
          ),
        )
        .toList();
  }

  Future<Huanzhe?> duquHuanzheJiben(int patientId) async {
    final rs = await _chi.execute(MenZhenYuJu.sql_duqu_huanzhe_jiben, {
      'pid': patientId,
    });
    if (rs.rows.isEmpty) return null;
    final r = rs.rows.first;
    return Huanzhe(
      id: int.parse(r.colByName('id')!),
      name: r.colByName('name') ?? '',
      phone: r.colByName('phone') ?? '',
      gender: r.colByName('gender'),
      birthday: r.colByName('birthday') != null
          ? DateTime.parse(r.colByName('birthday')!)
          : null,
    );
  }

  Future<void> shanchuJiuZhenZhong(int patientId) async {
    await _chi.execute(MenZhenYuJu.sql_shanchu_jiuzhen_draft, {
      'pid': patientId,
    });
    await _chi.execute(MenZhenYuJu.sql_shanchu_jiuzhen_session, {
      'pid': patientId,
    });
  }

  Future<void> shanchuWanChengVisit(int visitId) async {
    await _chi.execute(MenZhenYuJu.sql_shanchu_wancheng_visit, {
      'vid': visitId,
    });
  }

  /// 覆盖更新“已完成就诊”的病历主数据（不改变就诊日期/时间）
  Future<void> gengxinWanChengBingLi(
    int visitId,
    MenZhenCaoGao d, {
    String? yizhuText,
    String? rizhiText,
  }) async {
    await _chi.execute(MenZhenYuJu.sql_gengxin_bingli_by_visitid, {
      'vid': visitId,
      'a': d.zhusu,
      'b': d.xianbingshi,
      'c': d.linchuangDx,
      'd': d.zhongyiDx,
      'e': d.beizhu,
      'f': yizhuText,
      'g': rizhiText,
    });
  }
}
