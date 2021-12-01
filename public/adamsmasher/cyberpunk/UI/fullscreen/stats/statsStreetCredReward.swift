
public class StatsStreetCredReward extends inkLogicController {

  private edit let m_prevRewardsList: inkCompoundRef;

  private edit let m_currentRewardsList: inkCompoundRef;

  private edit let m_nextRewardsList: inkCompoundRef;

  private edit let m_scrollSlider: inkCompoundRef;

  private edit let m_scrollButtonHint: inkCompoundRef;

  private let m_rewardSize: Int32;

  private let m_tooltipIndex: Int32;

  private let m_tooltipsManager: wref<gameuiTooltipsManager>;

  public final func SetData(proficiencyData: ref<ProficiencyDisplayData>, tooltipsManager: wref<gameuiTooltipsManager>, tooltipIndex: Int32) -> Void {
    this.SetData(proficiencyData.m_passiveBonusesData, tooltipsManager, proficiencyData.m_level, tooltipIndex, proficiencyData.m_localizedName);
  }

  public final func SetData(rewardData: array<ref<LevelRewardDisplayData>>, tooltipsManager: wref<gameuiTooltipsManager>, currentLevel: Int32, tooltipIndex: Int32, attributeName: String) -> Void {
    let descPackage: ref<UILocalizationDataPackage>;
    let i: Int32;
    let lastUnlocked: Int32;
    let lastUnlockedIndex: Int32;
    let parentWidget: wref<inkWidget>;
    let positiveIndex: Bool;
    let prevTerm: Int32;
    let rewardItem: ref<StatsStreetCredRewardItem>;
    let state: CName;
    let totalCount: Int32;
    this.RegisterToCallback(n"OnHoverOver", this, n"OnRewardsHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnRewardsHoverOut");
    inkWidgetRef.SetVisible(this.m_scrollSlider, false);
    inkWidgetRef.SetVisible(this.m_scrollButtonHint, false);
    this.m_tooltipIndex = tooltipIndex;
    inkCompoundRef.RemoveAllChildren(this.m_prevRewardsList);
    inkCompoundRef.RemoveAllChildren(this.m_currentRewardsList);
    inkCompoundRef.RemoveAllChildren(this.m_nextRewardsList);
    this.m_tooltipsManager = tooltipsManager;
    i = 0;
    while i < ArraySize(rewardData) {
      if rewardData[i].level < currentLevel || rewardData[i].level == currentLevel {
        lastUnlocked = rewardData[i].level;
        lastUnlockedIndex = i;
      };
      i += 1;
    };
    this.m_rewardSize = ArraySize(rewardData);
    totalCount = 0;
    prevTerm = 0;
    i = lastUnlockedIndex;
    positiveIndex = true;
    while totalCount < this.m_rewardSize {
      i = positiveIndex ? i + prevTerm : i - prevTerm;
      if i < this.m_rewardSize && i >= 0 {
        descPackage = new UILocalizationDataPackage();
        ArrayPush(descPackage.intValues, rewardData[i].level);
        ArrayPush(descPackage.nameValues, StringToName(attributeName));
        rewardData[i].descPackage = descPackage;
        if rewardData[i].level < currentLevel && rewardData[i].level != lastUnlocked {
          parentWidget = inkWidgetRef.Get(this.m_prevRewardsList);
          rewardData[i].isLock = false;
          state = n"Default";
        } else {
          if rewardData[i].level == currentLevel || rewardData[i].level == lastUnlocked {
            parentWidget = inkWidgetRef.Get(this.m_currentRewardsList);
            rewardData[i].isLock = false;
            state = n"Default";
          } else {
            parentWidget = inkWidgetRef.Get(this.m_nextRewardsList);
            rewardData[i].isLock = true;
            state = n"Unavailable";
          };
        };
        rewardItem = this.SpawnFromLocal(parentWidget, n"rewardItem").GetControllerByType(n"StatsStreetCredRewardItem") as StatsStreetCredRewardItem;
        rewardItem.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
        rewardItem.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
        rewardItem.SetData(rewardData[i], state);
        totalCount += 1;
      };
      positiveIndex = !positiveIndex;
      prevTerm += 1;
    };
  }

  protected cb func OnHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let widget: ref<inkWidget> = evt.GetCurrentTarget();
    let data: ref<LevelRewardDisplayData> = (widget.GetController() as StatsStreetCredRewardItem).GetRewardData();
    let tooltipData: ref<MessageTooltipData> = new MessageTooltipData();
    tooltipData.Title = GetLocalizedText(data.description);
    tooltipData.TitleLocalizationPackage = data.locPackage;
    if data.isLock {
      tooltipData.Description = GetLocalizedText("LocKey#78909");
      tooltipData.DescriptionLocalizationPackage = data.descPackage;
    };
    this.m_tooltipsManager.ShowTooltipAtWidget(this.m_tooltipIndex, widget, tooltipData, gameuiETooltipPlacement.RightCenter, new inkMargin(40.00, 0.00, 0.00, 0.00));
  }

  protected cb func OnHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    this.m_tooltipsManager.HideTooltips();
  }

  protected cb func OnRewardsHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    if this.m_rewardSize > 8 {
      inkWidgetRef.SetVisible(this.m_scrollSlider, true);
      inkWidgetRef.SetVisible(this.m_scrollButtonHint, true);
    } else {
      inkWidgetRef.SetVisible(this.m_scrollSlider, false);
      inkWidgetRef.SetVisible(this.m_scrollButtonHint, false);
    };
  }

  protected cb func OnRewardsHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetVisible(this.m_scrollSlider, false);
    inkWidgetRef.SetVisible(this.m_scrollButtonHint, false);
  }
}

public class StatsStreetCredRewardItem extends inkButtonController {

  private edit let m_levelRef: inkTextRef;

  private edit let m_iconRef: inkImageRef;

  private edit let m_data: ref<LevelRewardDisplayData>;

  public final func SetData(data: ref<LevelRewardDisplayData>, opt state: CName) -> Void {
    if NotEquals(state, n"") {
      this.GetRootWidget().SetState(state);
    };
    this.m_data = data;
    inkTextRef.SetText(this.m_levelRef, IntToString(this.m_data.level));
  }

  public final func GetRewardData() -> ref<LevelRewardDisplayData> {
    return this.m_data;
  }
}
