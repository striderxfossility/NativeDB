
public class InventoryStatsDisplay extends inkLogicController {

  private edit let m_StatsRoot: inkCompoundRef;

  private edit let m_StatItemName: CName;

  private let m_StatItems: array<wref<InventoryStatItemV2>>;

  public final func Setup(stats: array<StatViewData>) -> Void {
    let i: Int32;
    let statView: wref<InventoryStatItemV2>;
    let limit: Int32 = ArraySize(stats);
    while ArraySize(this.m_StatItems) > limit {
      statView = ArrayPop(this.m_StatItems);
      inkCompoundRef.RemoveChild(this.m_StatsRoot, statView.GetRootWidget());
    };
    while ArraySize(this.m_StatItems) < limit {
      statView = this.SpawnFromLocal(inkWidgetRef.Get(this.m_StatsRoot), this.m_StatItemName).GetController() as InventoryStatItemV2;
      ArrayPush(this.m_StatItems, statView);
    };
    i = 0;
    while i < limit {
      statView = this.m_StatItems[i];
      if IsDefined(statView) {
        statView.Setup(stats[i], 6 + i);
      };
      i += 1;
    };
  }
}

public class InventoryStatItemV2 extends inkLogicController {

  private edit let m_LabelRef: inkTextRef;

  private edit let m_ValueRef: inkTextRef;

  private edit let m_Icon: inkImageRef;

  private edit let m_BackgroundIcon: inkImageRef;

  private edit let m_TextGroup: inkWidgetRef;

  @default(InventoryStatItemV2, false)
  private let m_IntroPlayed: Bool;

  public final func Setup(statViewData: StatViewData, framesDelay: Int32) -> Void {
    this.Setup(statViewData.statName, statViewData.value, statViewData.type);
    if !this.m_IntroPlayed {
      this.m_IntroPlayed = true;
      this.PlayIntroAnimation(framesDelay);
    };
  }

  public final func Setup(statViewData: StatViewData) -> Void {
    this.Setup(statViewData.statName, statViewData.value, statViewData.type);
  }

  public final func Setup(scannerStatDetails: ScannerStatDetails) -> Void {
    this.Setup("", Cast(scannerStatDetails.value), scannerStatDetails.statType);
  }

  public final func Setup(statName: String, statValue: Int32, statType: gamedataStatType) -> Void {
    inkTextRef.SetLetterCase(this.m_LabelRef, textLetterCase.UpperCase);
    inkTextRef.SetText(this.m_LabelRef, statName);
    if inkWidgetRef.IsValid(this.m_ValueRef) {
      inkTextRef.SetText(this.m_ValueRef, IntToString(statValue));
    };
    inkImageRef.SetTexturePart(this.m_BackgroundIcon, UIItemsHelper.GetBGIconNameForStat(statType));
    inkImageRef.SetTexturePart(this.m_Icon, UIItemsHelper.GetIconNameForStat(statType));
    this.GetRootWidget().SetState(UIItemsHelper.GetStateNameForStat(statType));
  }

  private final func PlayIntroAnimation(framesDelay: Int32) -> Void {
    let alphaInterp: ref<inkAnimTransparency>;
    let animationDef: ref<inkAnimDef> = new inkAnimDef();
    let scaleInterp: ref<inkAnimScale> = new inkAnimScale();
    scaleInterp.SetStartScale(new Vector2(0.00, 0.00));
    scaleInterp.SetEndScale(new Vector2(1.00, 1.00));
    scaleInterp.SetMode(inkanimInterpolationMode.EasyInOut);
    scaleInterp.SetType(inkanimInterpolationType.Sinusoidal);
    scaleInterp.SetDirection(inkanimInterpolationDirection.FromTo);
    scaleInterp.SetDuration(0.25);
    scaleInterp.SetStartDelay(0.03 * Cast(framesDelay));
    animationDef.AddInterpolator(scaleInterp);
    inkWidgetRef.PlayAnimation(this.m_Icon, animationDef);
    animationDef = new inkAnimDef();
    alphaInterp = new inkAnimTransparency();
    alphaInterp.SetStartTransparency(0.00);
    alphaInterp.SetEndTransparency(1.00);
    alphaInterp.SetMode(inkanimInterpolationMode.EasyInOut);
    alphaInterp.SetType(inkanimInterpolationType.Sinusoidal);
    alphaInterp.SetDirection(inkanimInterpolationDirection.FromTo);
    alphaInterp.SetDuration(0.25);
    alphaInterp.SetStartDelay(0.03 * Cast(framesDelay));
    animationDef.AddInterpolator(alphaInterp);
    inkWidgetRef.PlayAnimation(this.m_TextGroup, animationDef);
  }
}
