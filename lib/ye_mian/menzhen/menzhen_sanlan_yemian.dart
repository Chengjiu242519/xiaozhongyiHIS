import 'package:flutter/material.dart';
import '../../mysql/cangku/menzhen_cangku_mysql.dart';
import '../../shuju_moban/huanzhe.dart';
import '../../shuju_moban/huanzhe_xinxi.dart';
import '../../shuju_moban/menzhen_caogao.dart';
import '../../shuju_moban/menzhen_liebiao_xiang.dart';
import '../../shuju_moban/lishi_jiuzhen_xiang.dart';
import 'huanzhe_lan.dart';
import 'bingli_lan.dart';
import 'lishi_lan.dart';

class MenZhenSanLanYeMian extends StatefulWidget {
  const MenZhenSanLanYeMian({super.key});
  @override
  State<MenZhenSanLanYeMian> createState() => _MenZhenSanLanYeMianState();
}

class _MenZhenSanLanYeMianState extends State<MenZhenSanLanYeMian> {
  final cangku = MenZhenCangKuMySql();
  bool xiugaiMoShi = false; // 已完成病历的“修改模式”开关
  String? yizhuText; // 完成态回显医嘱
  String? rizhiText; // 完成态回显门诊日志

  // 左栏
  List<MenZhenLieBiaoXiang> jiuzhenzhong = [];
  List<MenZhenLieBiaoXiang> jinriwancheng = [];

  // 中栏
  Huanzhe? dangqianHuanzhe;
  HuanzheXinXi? dangqianHuanzheXinxi;
  MenZhenCaoGao? caogao; // 病历主数据
  bool wanchengMoShi = false; // true: 只读（已完成病历）
  int? dangqianVisitId; // 已完成病历的 visitId
  List<String> yiZhu = [];
  List<(DateTime, String)> menzhenRiZhi = [];

  // 右栏：历史就诊列表（修复 undefined_identifier: lishi）
  List<LiShiJiuZhenXiang> lishi = [];

  @override
  void initState() {
    super.initState();
    _shuaxinLieBiao();
  }

  Future<void> _shuaxinLieBiao() async {
    final a = await cangku.chaxunJiuZhenZhongLieBiao();
    final b = await cangku.chaxunJinRiWanChengLieBiao();
    setState(() {
      jiuzhenzhong = a;
      jinriwancheng = b;
    });
  }

  Future<void> _xuanzeHuanzheZaizhen(Huanzhe p) async {
    await cangku.jiezhen(p.id);
    final d = await cangku.duquCaoGao(p.id);
    final li = await cangku.lishiJiuzhen(p.id);
    final px = await cangku.duquHuanzheXinxi(p.id);
    final rz = await cangku.liebiaoMenZhenRiZhi(p.id);
    final pj = await cangku.duquHuanzheJiben(p.id);
    if (!mounted) return;
    setState(() {
      dangqianHuanzhe = pj ?? p;
      dangqianHuanzheXinxi = px;
      caogao = d;
      wanchengMoShi = false;
      dangqianVisitId = null;
      yiZhu = [];
      menzhenRiZhi = rz;
      lishi = li;
      xiugaiMoShi = false;
      yizhuText = null; // 完成态回显清空
      rizhiText = null;
    });
  }

  Future<void> _xuanzeHuanzheWanCheng(MenZhenLieBiaoXiang item) async {
    if (item.visitId == null) return;
    final data = await cangku.duquWanChengBingLi(item.visitId!);
    if (data == null) return;
    final (p, px, bl, yzText, rzText) = data;
    final li = await cangku.lishiJiuzhen(p.id);
    if (!mounted) return;
    setState(() {
      dangqianHuanzhe = p;
      dangqianHuanzheXinxi = px;
      caogao = bl;
      wanchengMoShi = true;
      dangqianVisitId = item.visitId;
      yiZhu = [];
      menzhenRiZhi = [];
      lishi = li;
      xiugaiMoShi = false;
      yizhuText = yzText; // 完成态回显医嘱
      rizhiText = rzText; // 完成态回显日志
    });
  }

  Future<void> _sousuoJieZhen(String guanjianzi) async {
    if (guanjianzi.trim().isEmpty) return;
    final res = await cangku.sousuoHuanzhe(guanjianzi.trim());
    if (res.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('未找到该患者，请先新建。')));
      }
      return;
    }
    await _xuanzeHuanzheZaizhen(res.first);
    await _shuaxinLieBiao();
  }

  // 新建患者
  Future<void> _xinjianHuanzhe(
    String xingming,
    String xingbie,
    int nianling,
    String dianhua,
  ) async {
    final id = await cangku.xinjianHuanzhe(
      xingming: xingming,
      xingbie: xingbie,
      nianling: nianling,
      dianhua: dianhua,
    );
    final p = Huanzhe(id: id, name: xingming, phone: dianhua);
    await _xuanzeHuanzheZaizhen(p);
    await _shuaxinLieBiao();
  }

  // 保存草稿（就诊中）
  Future<void> _baocunCaoGao({
    String? zhusu,
    String? xianbingshi,
    String? linchuangDx,
    String? zhongyiDx,
    String? beizhu,
  }) async {
    final p = dangqianHuanzhe;
    if (p == null) return;
    final d = MenZhenCaoGao(
      patientId: p.id,
      zhusu: zhusu,
      xianbingshi: xianbingshi,
      linchuangDx: linchuangDx,
      zhongyiDx: zhongyiDx,
      beizhu: beizhu,
    );
    await cangku.baocunCaoGao(d);
    await _shuaxinLieBiao();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('草稿已保存')));
    }
  }

  // 接诊完成
  Future<void> _wanchengJieZhen() async {
    final p = dangqianHuanzhe;
    if (p == null) return;
    await cangku.wanchengJieZhen(p.id);
    setState(() {
      dangqianHuanzhe = null;
      dangqianHuanzheXinxi = null;
      caogao = null;
      yiZhu = [];
      menzhenRiZhi = [];
      wanchengMoShi = false;
      dangqianVisitId = null;
      lishi = []; // ✅ 清空
    });
    await _shuaxinLieBiao();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已接诊完成')));
    }
  }

  // 保存患者扩展信息（过敏史/既往史/患者备注）
  Future<void> _baocunHuanzheXinxi(String? gm, String? jw, String? bz) async {
    final p = dangqianHuanzhe;
    if (p == null) return;
    final x = HuanzheXinXi(
      patientId: p.id,
      guominshi: gm,
      jiwangshi: jw,
      huanzheBeizhu: bz,
    );
    await cangku.gengxinHuanzheXinxi(x);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('患者基础信息已保存')));
    }
  }

  // 保存医嘱
  Future<void> _baocunYiZhu(List<String> lines) async {
    if (dangqianVisitId == null) return; // 只有已完成病历有固定 visitId
    await cangku.baocunYiZhu(dangqianVisitId!, lines);
    yiZhu = await cangku.duquYiZhu(dangqianVisitId!);
    if (mounted) setState(() {});
  }

  // 添加门诊日志
  Future<void> _tianjiaRiZhi(String content) async {
    final p = dangqianHuanzhe;
    if (p == null) return;
    await cangku.tianjiaMenZhenRiZhi(p.id, content);
    menzhenRiZhi = await cangku.liebiaoMenZhenRiZhi(p.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左：患者栏
        SizedBox(
          width: 360,
          child: HuanzheLan(
            jiuzhenzhong: jiuzhenzhong,
            jinriwancheng: jinriwancheng,
            onShuaxin: _shuaxinLieBiao,
            onSousuoJieZhen: _sousuoJieZhen,
            onXinjianHuanzhe: _xinjianHuanzhe,
            onDianJiLieBiao: (x) {
              if (xiugaiMoShi) {
                _toast('正在修改当前病历，请先保存或取消');
                return;
              }
              if (x.inSession) {
                _xuanzeHuanzheZaizhen(
                  Huanzhe(id: x.patientId, name: x.name, phone: x.phone),
                );
              } else {
                _xuanzeHuanzheWanCheng(x);
              }
            },
          ),
        ),

        const VerticalDivider(width: 1),

        // 中：病历栏（五大分区）
        Expanded(
          child: BingLiLan(
            huanzhe: dangqianHuanzhe,
            huanzheXinxi: dangqianHuanzheXinxi,
            caogao: caogao,
            wanCheng: wanchengMoShi,
            xiuGaiMoShi: xiugaiMoShi,
            yizhuTextChuShi: yizhuText,
            rizhiTextChuShi: rizhiText,
            onBaocunHuanzheXinxi: _baocunHuanzheXinxi,
            onBaocun: _baocunCaoGao,
            onWancheng: _wanchengJieZhen,
            onBaocunYiZhu: _baocunYiZhu,
            onTianjiaRiZhi: _tianjiaRiZhi,
            onShanchuZaiZhen: _shanchuZaizhen,
            onShanchuWanCheng: _shanchuWanCheng,
            onXiugaiWanCheng: _jinruXiuGaiMoShi,
            onBaoCunXiuGai:
                ({
                  String? zhusu,
                  String? xianbingshi,
                  String? linchuangDx,
                  String? zhongyiDx,
                  String? beizhu,
                  String? yizhuText,
                  String? rizhiText,
                }) => _baocunXiuGai(
                  zhusu: zhusu,
                  xianbingshi: xianbingshi,
                  linchuangDx: linchuangDx,
                  zhongyiDx: zhongyiDx,
                  beizhu: beizhu,
                  yizhuTextParam: yizhuText,
                  rizhiTextParam: rizhiText,
                ),
            onTuikuan: _tuikuan,
            onQuxiaoXiuGai: _quxiaoXiuGai,
          ),
        ),
        const VerticalDivider(width: 1),

        // 右：历史就诊栏
        SizedBox(
          width: 360,
          child: LiShiLan(
            huanzhe: dangqianHuanzhe,
            lishi: dangqianHuanzhe == null ? [] : lishi,
          ),
        ),
      ],
    );
  }

  Future<void> _shanchuZaizhen() async {
    final p = dangqianHuanzhe;
    if (p == null) return;
    await cangku.shanchuJiuZhenZhong(p.id);
    setState(() {
      dangqianHuanzhe = null;
      dangqianHuanzheXinxi = null;
      caogao = null;
      yiZhu = [];
      menzhenRiZhi = [];
      dangqianVisitId = null;
      wanchengMoShi = false;
      lishi = [];
    });
    await _shuaxinLieBiao();
  }

  Future<void> _shanchuWanCheng() async {
    final vid = dangqianVisitId;
    if (vid == null) return;
    await cangku.shanchuWanChengVisit(vid);
    setState(() {
      dangqianHuanzhe = null;
      dangqianHuanzheXinxi = null;
      caogao = null;
      yiZhu = [];
      menzhenRiZhi = [];
      dangqianVisitId = null;
      wanchengMoShi = false;
      lishi = [];
    });
    await _shuaxinLieBiao();
  }

  Future<void> _tuikuan() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('退款功能稍后接入')));
  }

  void _toast(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 72, left: 16, right: 16),
      ),
    );
  }

  Future<void> _baocunXiuGai({
    String? zhusu,
    String? xianbingshi,
    String? linchuangDx,
    String? zhongyiDx,
    String? beizhu,
    String? yizhuTextParam,
    String? rizhiTextParam,
  }) async {
    if (dangqianVisitId == null || dangqianHuanzhe == null) return;
    await cangku.gengxinWanChengBingLi(
      dangqianVisitId!,
      MenZhenCaoGao(
        patientId: dangqianHuanzhe!.id,
        zhusu: zhusu,
        xianbingshi: xianbingshi,
        linchuangDx: linchuangDx,
        zhongyiDx: zhongyiDx,
        beizhu: beizhu,
      ),
      yizhuText: yizhuTextParam,
      rizhiText: rizhiTextParam,
    );
    if (!mounted) return;
    setState(() {
      xiugaiMoShi = false;
    });
    await _shuaxinLieBiao();
    if (!mounted) return;
    _toast('修改已保存');
  }

  void _quxiaoXiuGai() {
    setState(() {
      xiugaiMoShi = false;
    });
    _toast('已取消修改');
  }

  Future<void> _jinruXiuGaiMoShi() async {
    setState(() {
      xiugaiMoShi = true;
    });
    _toast('已进入修改模式');
  }
}
