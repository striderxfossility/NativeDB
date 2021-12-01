
public class PerkDisplayController extends inkButtonController {

  protected edit let m_levelText: inkTextRef;

  protected edit let m_icon: inkImageRef;

  protected edit let m_fluffText: inkTextRef;

  protected edit let m_requiredTrainerIcon: inkWidgetRef;

  protected edit let m_requiredPointsText: inkTextRef;

  protected let m_displayData: ref<BasePerkDisplayData>;

  protected let m_dataManager: ref<PlayerDevelopmentDataManager>;

  protected let m_playerDevelopmentData: wref<PlayerDevelopmentData>;

  protected let m_recentlyPurchased: Bool;

  protected let m_holdStarted: Bool;

  protected let m_isTrait: Bool;

  protected let m_wasLocked: Bool;

  protected let m_index: Int32;

  protected let m_cool_in_proxy: ref<inkAnimProxy>;

  protected let m_cool_out_proxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.RegisterToCallback(n"OnRelease", this, n"OnPerkDisplayClick");
    this.RegisterToCallback(n"OnHold", this, n"OnPerkDisplayHold");
    this.RegisterToCallback(n"OnHoverOver", this, n"OnPerkItemHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnPerkItemHoverOut");
  }

  protected cb func OnUninitialize() -> Bool {
    this.UnregisterFromCallback(n"OnRelease", this, n"OnPerkDisplayClick");
    this.UnregisterFromCallback(n"OnHold", this, n"OnPerkDisplayHold");
    this.UnregisterFromCallback(n"OnHoverOver", this, n"OnPerkItemHoverOver");
    this.UnregisterFromCallback(n"OnHoverOut", this, n"OnPerkItemHoverOut");
  }

  public final func Setup(displayData: ref<BasePerkDisplayData>, dataManager: ref<PlayerDevelopmentDataManager>, opt index: Int32) -> Void {
    this.m_playerDevelopmentData = dataManager.GetPlayerDevelopmentData();
    this.m_index = index;
    this.m_isTrait = (displayData as TraitDisplayData) != null;
    this.m_dataManager = dataManager;
    this.UpdateLayout(displayData);
    this.CheckRevealAnimation(displayData, this.m_displayData);
    this.m_displayData = displayData;
  }

  public final func CheckRevealAnimation(newDisplayData: ref<BasePerkDisplayData>, oldDisplayData: ref<BasePerkDisplayData>) -> Void {
    let isFirstTime: Bool;
    let unlimitedUnlocked: ref<UnlimitedUnlocked>;
    if IsDefined(oldDisplayData) {
      isFirstTime = NotEquals(oldDisplayData.m_proficiency, newDisplayData.m_proficiency);
    } else {
      isFirstTime = true;
    };
    if isFirstTime {
      this.m_wasLocked = newDisplayData.m_locked;
    } else {
      this.m_wasLocked = oldDisplayData.m_locked;
      if this.m_wasLocked && !newDisplayData.m_locked {
        if this.m_isTrait {
          unlimitedUnlocked = new UnlimitedUnlocked();
          this.QueueEvent(unlimitedUnlocked);
        } else {
          this.PlayLibraryAnimation(n"reveal_perk");
        };
      };
    };
  }

  private final func UpdateLayout(data: ref<BasePerkDisplayData>) -> Void {
    let state: CName;
    let root: wref<inkWidget> = this.GetRootWidget();
    let isDataNull: Bool = data == null;
    if Equals(isDataNull, root.IsVisible()) {
      root.SetVisible(!isDataNull);
    };
    if isDataNull {
      return;
    };
    state = n"Default";
    if data.m_locked {
      state = n"Locked";
    } else {
      if data.m_level == data.m_maxLevel {
        state = n"Maxed";
      } else {
        if data.m_level > 0 {
          state = n"Bought";
        };
      };
    };
    this.GetRootWidget().SetState(state);
    InkImageUtils.RequestSetImage(this, this.m_icon, "UIIcon." + ToString(data.m_iconID));
    inkWidgetRef.SetVisible(this.m_icon, NotEquals(data.m_iconID, n""));
    if !this.m_isTrait {
      this.UpdateLayout(data as PerkDisplayData);
    } else {
      this.UpdateLayout(data as TraitDisplayData);
    };
  }

  private final func UpdateLayout(data: ref<PerkDisplayData>) -> Void {
    let numPointsRequired: Int32 = 0;
    let requiresPoints: Bool = false;
    let requiresMastery: Bool = false;
    let levelParams: ref<inkTextParams> = new inkTextParams();
    let perkAreaRecord: ref<PerkArea_Record> = this.m_playerDevelopmentData.GetPerkAreaRecord(data.m_area);
    let statPrereqRecord: ref<StatPrereq_Record> = perkAreaRecord.Requirement() as StatPrereq_Record;
    let statType: gamedataStatType = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", statPrereqRecord.StatType())));
    let statValue: Float = GameInstance.GetStatsSystem(this.m_dataManager.GetPlayer().GetGame()).GetStatValue(Cast(this.m_dataManager.GetPlayer().GetEntityID()), statType);
    numPointsRequired = Cast(statPrereqRecord.ValueToCheck()) - Cast(statValue);
    requiresPoints = numPointsRequired > 0;
    inkWidgetRef.SetVisible(this.m_requiredPointsText, requiresPoints);
    inkTextRef.SetText(this.m_requiredPointsText, IntToString(numPointsRequired));
    requiresMastery = !this.m_playerDevelopmentData.IsPerkAreaMasteryReqMet(perkAreaRecord);
    inkWidgetRef.SetVisible(this.m_requiredTrainerIcon, requiresMastery);
    levelParams.AddString("level", IntToString(data.m_level));
    levelParams.AddString("maxLevel", IntToString(data.m_maxLevel));
    inkTextRef.SetTextParameters(this.m_levelText, levelParams);
    inkTextRef.SetText(this.m_fluffText, "FNC_" + IntToString(this.GetFluffRand(data)) + " " + IntToString(this.GetFluffRand(data, 3425)));
  }

  private final func UpdateLayout(data: ref<TraitDisplayData>) -> Void {
    let statPrereqRecord: ref<StatPrereq_Record>;
    let numPointsRequired: Int32 = 0;
    let requiresPoints: Bool = false;
    let levelParams: ref<inkTextParams> = new inkTextParams();
    let prereq: ref<StatPrereq_Record> = traitRecord.Requirement() as StatPrereq_Record;
    let proficiencyType: gamedataProficiencyType = IntEnum(Cast(EnumValueFromName(n"gamedataProficiencyType", statPrereqRecord.StatType())));
    numPointsRequired = Cast(prereq.ValueToCheck()) - this.m_playerDevelopmentData.GetProficiencyLevel(proficiencyType);
    let traitRecord: ref<Trait_Record> = RPGManager.GetTraitRecord(data.m_type);
    requiresPoints = numPointsRequired > 0;
    inkWidgetRef.SetVisible(this.m_requiredPointsText, requiresPoints);
    inkTextRef.SetText(this.m_requiredPointsText, IntToString(numPointsRequired));
    levelParams.AddString("level", IntToString(data.m_level));
    inkTextRef.SetTextParameters(this.m_levelText, levelParams);
    inkTextRef.SetText(this.m_fluffText, "FNC_" + IntToString(this.GetFluffRand(data)) + " " + IntToString(this.GetFluffRand(data, 6327)));
  }

  protected final func GetFluffRand(perkData: ref<PerkDisplayData>, opt offset: Int32) -> Int32 {
    return Cast(RandNoiseF(EnumInt(perkData.m_proficiency) * 1000 + EnumInt(perkData.m_area) * 100 + EnumInt(perkData.m_type) + offset, 1000.00, 9999.00));
  }

  protected final func GetFluffRand(traitData: ref<TraitDisplayData>, opt offset: Int32) -> Int32 {
    return Cast(RandNoiseF(traitData.m_level * 100 + EnumInt(traitData.m_type) + offset, 1000.00, 9999.00));
  }

  private final func Upgrade() -> Void {
    if !this.m_isTrait {
      this.m_dataManager.UpgradePerk(this.m_displayData as PerkDisplayData);
    } else {
      this.m_dataManager.UpgradeTrait(this.m_displayData as TraitDisplayData);
    };
  }

  protected cb func OnUnlimitedUnlocked(evt: ref<UnlimitedUnlocked>) -> Bool {
    if this.m_isTrait {
      this.PlayLibraryAnimation(n"reveal_unlimited_perk");
    };
  }

  protected cb func OnPerkItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
    let hoverOverEvent: ref<PerkHoverOverEvent> = new PerkHoverOverEvent();
    hoverOverEvent.widget = this.GetRootWidget();
    hoverOverEvent.perkIndex = this.m_index;
    hoverOverEvent.perkData = this.m_displayData;
    this.QueueEvent(hoverOverEvent);
    this.StopHoverAnimations();
    this.m_cool_in_proxy = this.PlayLibraryAnimation(this.m_isTrait ? n"cool_unlimited_hover" : n"cool_hover");
  }

  protected cb func OnPerkItemHoverOut(evt: ref<inkPointerEvent>) -> Bool {
    let hoverOutEvent: ref<PerkHoverOutEvent> = new PerkHoverOutEvent();
    hoverOutEvent.widget = this.GetRootWidget();
    hoverOutEvent.perkData = this.m_displayData;
    this.QueueEvent(hoverOutEvent);
    this.StopHoverAnimations();
    this.m_cool_out_proxy = this.PlayLibraryAnimation(this.m_isTrait ? n"cool_unlimited_hover_out" : n"cool_hover_out");
  }

  private final func StopHoverAnimations() -> Void {
    if IsDefined(this.m_cool_in_proxy) {
      this.m_cool_in_proxy.Stop();
    };
    if IsDefined(this.m_cool_out_proxy) {
      this.m_cool_out_proxy.Stop();
    };
  }

  protected cb func OnPerkDisplayClick(evt: ref<inkPointerEvent>) -> Bool {
    this.m_holdStarted = false;
  }

  protected cb func OnPerkDisplayHold(evt: ref<inkPointerEvent>) -> Bool {
    let holdStartEvent: ref<PerksItemHoldStart>;
    let progress: Float;
    if evt.IsAction(n"upgrade_perk") {
      progress = evt.GetHoldProgress();
      if progress > 0.00 && !this.m_holdStarted {
        holdStartEvent = new PerksItemHoldStart();
        holdStartEvent.widget = this.GetRootWidget();
        holdStartEvent.perkData = this.m_displayData;
        holdStartEvent.actionName = evt.GetActionName();
        this.QueueEvent(holdStartEvent);
        this.m_holdStarted = true;
        if !this.m_dataManager.IsPerkUpgradeable(this.m_displayData, true) && this.IsActionNameCompatible(evt) {
          this.PlayLibraryAnimation(this.m_isTrait ? n"locked_unlimited_perk" : n"locked_perk");
          this.PlaySound(n"Perk", n"OnBuyFail");
        };
      };
      if progress >= 1.00 {
        if this.m_dataManager.IsPerkUpgradeable(this.m_displayData) && this.IsActionNameCompatible(evt) {
          this.m_recentlyPurchased = true;
          this.Upgrade();
          if this.m_displayData.m_level == this.m_displayData.m_maxLevel - 1 {
            this.PlayLibraryAnimation(n"maxed_perk");
            this.PlaySound(n"Perk", n"OnBuyFail");
          } else {
            if this.m_displayData.m_level >= 0 {
              this.PlayLibraryAnimation(this.m_isTrait ? n"buy_unlimited_perk" : n"buy_perk");
              this.PlaySound(n"Perk", n"OnLevelUp");
            };
          };
        };
      } else {
        if !this.m_recentlyPurchased {
          this.m_recentlyPurchased = false;
        };
      };
    };
  }

  private final func IsActionNameCompatible(evt: ref<inkPointerEvent>) -> Bool {
    return evt.IsAction(n"use_item") || evt.IsAction(n"click") || evt.IsAction(n"upgrade_perk");
  }
}

public class PerkDisplayContainerController extends inkLogicController {

  protected edit let m_index: Int32;

  protected edit let m_isTrait: Bool;

  protected edit let m_widget: inkWidgetRef;

  protected let m_data: ref<BasePerkDisplayData>;

  protected let m_dataManager: ref<PlayerDevelopmentDataManager>;

  protected let m_controller: wref<PerkDisplayController>;

  protected cb func OnInitialize() -> Bool {
    let evt: ref<PerkDisplayContainerCreatedEvent> = new PerkDisplayContainerCreatedEvent();
    evt.index = this.m_index;
    evt.isTrait = this.m_isTrait;
    evt.container = this;
    this.QueueEvent(evt);
  }

  private final func SpawnController() -> Void {
    let widget: wref<inkWidget>;
    this.GetRootWidget() as inkCompoundWidget.RemoveAllChildren();
    widget = this.SpawnFromLocal(this.GetRootWidget() as inkCompoundWidget, this.m_isTrait ? n"SkillUnlimitedPerkDisplay" : n"SkillPerkDisplay");
    widget.SetVAlign(inkEVerticalAlign.Top);
    widget.SetHAlign(inkEHorizontalAlign.Left);
    this.m_controller = widget.GetController() as PerkDisplayController;
  }

  public final func SetData(perkData: ref<BasePerkDisplayData>, dataManager: ref<PlayerDevelopmentDataManager>) -> Void {
    this.m_data = perkData;
    this.m_dataManager = dataManager;
    if this.m_controller == null {
      this.SpawnController();
    };
    this.m_controller.Setup(this.m_data, this.m_dataManager, this.m_index);
  }

  public final func GetPerkDisplayData() -> ref<BasePerkDisplayData> {
    return this.m_data;
  }

  public final func GetPerkIndex() -> Int32 {
    return this.m_index;
  }
}
