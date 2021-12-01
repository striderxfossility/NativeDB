
public class BasePerksMenuTooltipData extends ATooltipData {

  public let manager: ref<PlayerDevelopmentDataManager>;

  public func RefreshRuntimeData() -> Void;
}

public class AttributeTooltipData extends BasePerksMenuTooltipData {

  public let attributeId: TweakDBID;

  public let attributeType: PerkMenuAttribute;

  public let attributeData: ref<AttributeData>;

  public let displayData: ref<AttributeDisplayData>;

  public func RefreshRuntimeData() -> Void {
    this.attributeData = this.manager.GetAttribute(this.attributeId);
    this.displayData = this.manager.GetAttributeData(this.attributeId);
  }
}

public class SkillTooltipData extends BasePerksMenuTooltipData {

  public let proficiencyType: gamedataProficiencyType;

  public let attributeRecord: ref<Attribute_Record>;

  public let skillData: ref<ProficiencyDisplayData>;

  public func RefreshRuntimeData() -> Void {
    this.skillData = this.manager.GetProficiencyDisplayData(this.proficiencyType, this.attributeRecord);
  }
}

public class PerkTooltipData extends BasePerksMenuTooltipData {

  public let perkType: gamedataPerkType;

  public let perkArea: gamedataPerkArea;

  public let attributeId: TweakDBID;

  public let proficiency: gamedataProficiencyType;

  public let perkData: ref<PerkDisplayData>;

  public let attributeData: ref<AttributeData>;

  public func RefreshRuntimeData() -> Void {
    this.attributeData = this.manager.GetAttribute(this.attributeId);
    this.perkData = this.manager.GetPerkDisplayData(this.perkType, this.perkArea, this.proficiency, this.attributeId);
  }
}

public class TraitTooltipData extends BasePerksMenuTooltipData {

  public let traitType: gamedataTraitType;

  public let attributeId: TweakDBID;

  public let proficiency: gamedataProficiencyType;

  public let traitData: ref<TraitDisplayData>;

  public let attributeData: ref<AttributeData>;

  public func RefreshRuntimeData() -> Void {
    this.attributeData = this.manager.GetAttribute(this.attributeId);
    this.traitData = this.manager.GetTraitDisplayData(this.traitType, this.attributeId, this.proficiency);
  }
}

public class PerkDisplayTooltipController extends AGenericTooltipController {

  private edit let m_root: inkWidgetRef;

  private edit let m_perkNameText: inkTextRef;

  private edit let m_videoWrapper: inkWidgetRef;

  private edit let m_videoWidget: inkVideoRef;

  private edit let m_unlockStateText: inkTextRef;

  private edit let m_perkTypeText: inkTextRef;

  private edit let m_perkTypeWrapper: inkWidgetRef;

  private edit let m_unlockInfoWrapper: inkWidgetRef;

  private edit let m_unlockPointsText: inkTextRef;

  private edit let m_unlockPointsDesc: inkTextRef;

  private edit let m_unlockPerkWrapper: inkWidgetRef;

  private edit let m_levelText: inkTextRef;

  private edit let m_levelDescriptionText: inkTextRef;

  private edit let m_nextLevelWrapper: inkWidgetRef;

  private edit let m_nextLevelText: inkTextRef;

  private edit let m_nextLevelDescriptionText: inkTextRef;

  private edit let m_traitLevelGrowthText: inkTextRef;

  private edit let m_unlockTraitPointsText: inkTextRef;

  private edit let m_unlockTraitWrapper: inkWidgetRef;

  private edit let m_holdToUpgradeHint: inkWidgetRef;

  private let m_data: ref<BasePerksMenuTooltipData>;

  public func Refresh() -> Void {
    this.SetData(this.m_data);
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.m_data = tooltipData as BasePerksMenuTooltipData;
    if this.m_data == null {
      return;
    };
    this.m_data.RefreshRuntimeData();
    if tooltipData.IsA(n"PerkTooltipData") {
      this.RefreshTooltip(this.m_data as PerkTooltipData);
    } else {
      if tooltipData.IsA(n"TraitTooltipData") {
        this.RefreshTooltip(this.m_data as TraitTooltipData);
      };
    };
  }

  private final func GetUiLocalizationData(levelDataRecord: wref<PerkLevelData_Record>) -> ref<UILocalizationDataPackage> {
    return UILocalizationDataPackage.FromPerkUIDataPackage(levelDataRecord.UiData());
  }

  private final func GetLevelDescription(perkData: ref<PerkDisplayData>, levelDataRecord: wref<PerkLevelData_Record>) -> String {
    let constPerkModifier: wref<ConstantStatModifier_Record>;
    let i: Int32;
    let perkModifiers: array<wref<StatModifier_Record>>;
    let perkStat: wref<Stat_Record>;
    let resultString: String;
    let statValue: Float;
    let stringToReplace: String;
    ArrayClear(perkModifiers);
    levelDataRecord.DataPackage().Stats(perkModifiers);
    resultString = perkData.m_localizedDescription;
    i = 0;
    while i < ArraySize(perkModifiers) {
      perkStat = perkModifiers[i].StatType();
      constPerkModifier = perkModifiers[i] as ConstantStatModifier_Record;
      stringToReplace = "<BaseStats." + EnumValueToString("gamedataStatType", EnumInt(perkStat.StatType())) + ">";
      statValue = constPerkModifier.Value();
      resultString = StrReplaceAll(resultString, stringToReplace, IntToString(RoundF(statValue)));
      i += 1;
    };
    return resultString;
  }

  private final func RefreshTooltip(data: ref<PerkTooltipData>) -> Void {
    let perkPackages: array<wref<PerkLevelData_Record>>;
    let playerDevelopmentData: wref<PlayerDevelopmentData> = this.m_data.manager.GetPlayerDevelopmentData();
    let perkRecord: wref<Perk_Record> = playerDevelopmentData.GetPerkRecord(data.perkData.m_type);
    perkRecord.Levels(perkPackages);
    this.UpdateState(data.perkData);
    this.UpdatePerkDescriptions(data, perkPackages);
    this.UpdateVideo(data);
    this.UpdateName(data.perkData);
    this.UpdateType(perkRecord);
    this.UpdateTooltipHints(data, data.perkData);
    this.UpdateRequirements(playerDevelopmentData, data);
  }

  private final func RefreshTooltip(data: ref<TraitTooltipData>) -> Void {
    let playerDevelopmentData: wref<PlayerDevelopmentData> = this.m_data.manager.GetPlayerDevelopmentData();
    this.UpdateState(data.traitData);
    this.UpdateTraitDescriptions(data);
    this.UpdateVideo(data);
    this.UpdateName(data.traitData);
    this.UpdateType();
    this.UpdateTooltipHints(data, data.traitData);
    this.UpdateRequirements(playerDevelopmentData, data);
  }

  private final func UpdateType(opt perkRecord: wref<Perk_Record>) -> Void {
    let perkUtility: wref<PerkUtility_Record>;
    if IsDefined(perkRecord) {
      perkUtility = perkRecord.Utility();
      if IsDefined(perkUtility) {
        inkTextRef.SetText(this.m_perkTypeText, PlayerDevelopmentDataManager.PerkUtilityToString(perkUtility.UtilityType()));
        inkWidgetRef.SetVisible(this.m_perkTypeWrapper, true);
        return;
      };
    };
    inkWidgetRef.SetVisible(this.m_perkTypeWrapper, false);
  }

  private final func UpdateState(basePerkData: ref<BasePerkDisplayData>) -> Void {
    if basePerkData.m_locked {
      inkTextRef.SetText(this.m_unlockStateText, GetLocalizedText("UI-Cyberpunk-Fullscreen-PlayerDevelopment-Perks-Locked"));
      inkWidgetRef.SetState(this.m_root, n"Locked");
    } else {
      if basePerkData.m_level == 0 {
        inkTextRef.SetText(this.m_unlockStateText, GetLocalizedText("UI-Cyberpunk-Fullscreen-PlayerDevelopment-Perks-NotPurchased"));
        inkWidgetRef.SetState(this.m_root, n"NotPurchased");
      } else {
        if basePerkData.m_level == basePerkData.m_maxLevel {
          inkTextRef.SetText(this.m_unlockStateText, GetLocalizedText("UI-Menus-Perks-MaxedOut"));
          inkWidgetRef.SetState(this.m_root, n"MaxedOut");
        } else {
          inkTextRef.SetText(this.m_unlockStateText, GetLocalizedText("UI-Menus-Perks-Purchased"));
          inkWidgetRef.SetState(this.m_root, n"Purchased");
        };
      };
    };
  }

  private final func UpdatePerkDescriptions(data: ref<PerkTooltipData>, perkPackages: script_ref<array<wref<PerkLevelData_Record>>>) -> Void {
    let levelLocalizationData: ref<UILocalizationDataPackage>;
    let nextLevelLocalizationData: ref<UILocalizationDataPackage>;
    let nextLevelPerkPackage: wref<PerkLevelData_Record>;
    let nextLevelTextParams: ref<inkTextParams>;
    let currentLevel: Int32 = Max(0, data.perkData.m_level - 1);
    let levelTextParams: ref<inkTextParams> = new inkTextParams();
    let levelPerkPackage: wref<PerkLevelData_Record> = Deref(perkPackages)[currentLevel];
    if data.perkData.m_locked || data.perkData.m_level == 0 || data.perkData.m_level == data.perkData.m_maxLevel {
      inkTextRef.SetText(this.m_levelText, "UI-Tooltips-Perks-Level");
      levelTextParams.AddNumber("level", currentLevel + 1);
    } else {
      inkTextRef.SetText(this.m_levelText, "UI-Tooltips-Perks-CurrentLevel");
      levelTextParams.AddNumber("level", currentLevel + 1);
    };
    inkTextRef.SetTextParameters(this.m_levelText, levelTextParams);
    inkTextRef.SetText(this.m_levelDescriptionText, this.GetLevelDescription(data.perkData, levelPerkPackage));
    levelLocalizationData = this.GetUiLocalizationData(levelPerkPackage);
    if levelLocalizationData.GetParamsCount() > 0 {
      inkTextRef.SetTextParameters(this.m_levelDescriptionText, levelLocalizationData.GetTextParams());
    };
    if data.perkData.m_level > 0 && data.perkData.m_level < data.perkData.m_maxLevel {
      nextLevelTextParams = new inkTextParams();
      nextLevelPerkPackage = Deref(perkPackages)[currentLevel + 1];
      inkWidgetRef.SetVisible(this.m_nextLevelWrapper, true);
      inkTextRef.SetText(this.m_nextLevelText, "UI-Tooltips-Perks-NextLevel");
      nextLevelTextParams.AddNumber("level", data.perkData.m_level + 1);
      inkTextRef.SetTextParameters(this.m_nextLevelText, nextLevelTextParams);
      inkTextRef.SetText(this.m_nextLevelDescriptionText, this.GetLevelDescription(data.perkData, nextLevelPerkPackage));
      nextLevelLocalizationData = this.GetUiLocalizationData(nextLevelPerkPackage);
      if nextLevelLocalizationData.GetParamsCount() > 0 {
        inkTextRef.SetTextParameters(this.m_nextLevelDescriptionText, nextLevelLocalizationData.GetTextParams());
      };
    } else {
      inkWidgetRef.SetVisible(this.m_nextLevelWrapper, false);
    };
    inkWidgetRef.SetVisible(this.m_traitLevelGrowthText, false);
  }

  private final func UpdateTraitDescriptions(data: ref<TraitTooltipData>) -> Void {
    let levelTextParams: ref<inkTextParams>;
    let traitRecord: wref<Trait_Record>;
    let uiLocalizationData: ref<UILocalizationDataPackage>;
    let uiLocalizationInfiniteData: ref<UILocalizationDataPackage>;
    inkWidgetRef.SetVisible(this.m_nextLevelWrapper, false);
    levelTextParams = new inkTextParams();
    traitRecord = RPGManager.GetTraitRecord(data.traitData.m_type);
    inkTextRef.SetText(this.m_levelText, GetLocalizedText("UI-Statistic-Level") + ": " + NameToString(n"<Rich size=\"45\" style=\"Bold\">{level,number}</>"));
    levelTextParams.AddNumber("level", data.traitData.m_level + 1);
    inkTextRef.SetTextParameters(this.m_levelText, levelTextParams);
    inkTextRef.SetText(this.m_levelDescriptionText, data.traitData.m_localizedDescription);
    inkTextRef.SetText(this.m_traitLevelGrowthText, GetLocalizedText(traitRecord.InfiniteTraitData().Loc_desc_key()));
    uiLocalizationData = UILocalizationDataPackage.FromLogicUIDataPackage(traitRecord.BaseTraitData().DataPackage().UIData());
    uiLocalizationInfiniteData = UILocalizationDataPackage.FromLogicUIDataPackage(traitRecord.InfiniteTraitData().DataPackage().UIData());
    if uiLocalizationData.GetParamsCount() > 0 {
      inkTextRef.SetTextParameters(this.m_levelDescriptionText, uiLocalizationData.GetTextParams());
    };
    if uiLocalizationInfiniteData.GetParamsCount() > 0 {
      inkTextRef.SetTextParameters(this.m_traitLevelGrowthText, uiLocalizationInfiniteData.GetTextParams());
    };
    inkWidgetRef.SetVisible(this.m_traitLevelGrowthText, true);
  }

  private final func UpdateName(data: ref<BasePerkDisplayData>) -> Void {
    inkTextRef.SetText(this.m_perkNameText, data.m_localizedName);
  }

  private final func UpdateVideo(data: ref<PerkTooltipData>) -> Void {
    data.RefreshRuntimeData();
    this.CommonUpdateVideo(data.perkData);
  }

  private final func UpdateVideo(data: ref<TraitTooltipData>) -> Void {
    data.RefreshRuntimeData();
    this.CommonUpdateVideo(data.traitData);
  }

  private final func CommonUpdateVideo(data: ref<BasePerkDisplayData>) -> Void {
    if IsDefined(data) && ResRef.IsValid(data.m_binkRef) {
      inkVideoRef.Stop(this.m_videoWidget);
      inkVideoRef.SetVideoPath(this.m_videoWidget, data.m_binkRef);
      inkVideoRef.SetLoop(this.m_videoWidget, true);
      inkVideoRef.Play(this.m_videoWidget);
      inkWidgetRef.SetVisible(this.m_videoWrapper, true);
    } else {
      inkWidgetRef.SetVisible(this.m_videoWrapper, false);
    };
  }

  private final func UpdateTooltipHints(data: ref<BasePerksMenuTooltipData>, perkData: ref<BasePerkDisplayData>) -> Void {
    inkWidgetRef.SetVisible(this.m_holdToUpgradeHint, data.manager.IsPerkUpgradeable(perkData));
  }

  private final func UpdateRequirements(playerDevelopmentData: wref<PlayerDevelopmentData>, data: ref<PerkTooltipData>) -> Void {
    let areaRecord: wref<PerkArea_Record> = playerDevelopmentData.GetPerkAreaRecord(data.perkData.m_area);
    let statCastPrereqRecord: wref<StatPrereq_Record> = areaRecord.Requirement() as StatPrereq_Record;
    inkWidgetRef.SetVisible(this.m_unlockInfoWrapper, data.perkData.m_locked);
    inkWidgetRef.SetVisible(this.m_unlockPerkWrapper, true);
    inkWidgetRef.SetVisible(this.m_unlockTraitWrapper, false);
    inkTextRef.SetText(this.m_unlockPointsText, IntToString(RoundF(statCastPrereqRecord.ValueToCheck())));
    inkTextRef.SetText(this.m_unlockPointsDesc, "UI-Tooltips-Perks-UnlockInfoText");
  }

  private final func UpdateRequirements(playerDevelopmentData: wref<PlayerDevelopmentData>, data: ref<TraitTooltipData>) -> Void {
    let unlockTraitTextParams: ref<inkTextParams> = new inkTextParams();
    let traitRecord: wref<Trait_Record> = RPGManager.GetTraitRecord(data.traitData.m_type);
    let statPrereqRecord: wref<StatPrereq_Record> = traitRecord.Requirement() as StatPrereq_Record;
    let type: CName = statPrereqRecord.StatType();
    let proficiencyType: gamedataProficiencyType = IntEnum(Cast(EnumValueFromName(n"gamedataProficiencyType", type)));
    let profString: String = RPGManager.GetProficiencyRecord(proficiencyType).Loc_name_key();
    inkWidgetRef.SetVisible(this.m_unlockInfoWrapper, data.traitData.m_locked);
    inkWidgetRef.SetVisible(this.m_unlockPerkWrapper, false);
    inkWidgetRef.SetVisible(this.m_unlockTraitWrapper, true);
    unlockTraitTextParams.AddNumber("points", Cast(statPrereqRecord.ValueToCheck()));
    unlockTraitTextParams.AddString("attribute", GetLocalizedText(profString));
    inkTextRef.SetTextParameters(this.m_unlockTraitPointsText, unlockTraitTextParams);
  }
}

public class PerkMenuTooltipController extends AGenericTooltipController {

  protected edit let m_titleContainer: inkWidgetRef;

  protected edit let m_titleText: inkTextRef;

  protected edit let m_typeContainer: inkWidgetRef;

  protected edit let m_typeText: inkTextRef;

  protected edit let m_desc1Container: inkWidgetRef;

  protected edit let m_desc1Text: inkTextRef;

  protected edit let m_desc2Container: inkWidgetRef;

  protected edit let m_desc2Text: inkTextRef;

  protected edit let m_desc2TextNextLevel: inkTextRef;

  protected edit let m_desc2TextNextLevelDesc: inkTextRef;

  protected edit let m_holdToUpgrade: inkWidgetRef;

  protected edit let m_openPerkScreen: inkWidgetRef;

  protected edit let m_videoContainerWidget: inkWidgetRef;

  protected edit let m_videoWidget: inkVideoRef;

  private let m_data: ref<BasePerksMenuTooltipData>;

  @default(PerkMenuTooltipController, 20)
  public const let m_maxProficiencyLevel: Int32;

  public func Refresh() -> Void {
    this.SetData(this.m_data);
  }

  public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    this.m_data = tooltipData as BasePerksMenuTooltipData;
    if this.m_data == null {
      return;
    };
    this.m_data.RefreshRuntimeData();
    this.SetupShared(this.m_data);
    if tooltipData.IsA(n"AttributeTooltipData") {
      this.SetupCustom(this.m_data as AttributeTooltipData);
    } else {
      if tooltipData.IsA(n"SkillTooltipData") {
        this.SetupCustom(this.m_data as SkillTooltipData);
      };
    };
  }

  private final func SetupShared(data: ref<BasePerksMenuTooltipData>) -> Void {
    this.SetTitle("");
    this.SetType("");
    this.SetDesc1("");
    this.SetDesc2("");
    inkWidgetRef.SetVisible(this.m_desc2TextNextLevel, false);
    inkWidgetRef.SetVisible(this.m_desc2TextNextLevelDesc, false);
    this.SetCanUpgrade(false);
    this.SetCanOpenPerks(false);
    this.PlayVideo(data);
  }

  private final func PlayVideo(data: ref<BasePerksMenuTooltipData>) -> Void {
    let perkData: ref<PerkTooltipData> = data as PerkTooltipData;
    perkData.RefreshRuntimeData();
    if IsDefined(perkData) && ResRef.IsValid(perkData.perkData.m_binkRef) {
      inkVideoRef.Stop(this.m_videoWidget);
      inkVideoRef.SetVideoPath(this.m_videoWidget, perkData.perkData.m_binkRef);
      inkVideoRef.SetLoop(this.m_videoWidget, true);
      inkVideoRef.Play(this.m_videoWidget);
      inkWidgetRef.SetVisible(this.m_videoContainerWidget, true);
    } else {
      inkWidgetRef.SetVisible(this.m_videoContainerWidget, false);
    };
  }

  private final func SetupCustom(data: ref<AttributeTooltipData>) -> Void {
    let desc1: String;
    let desc1Params: ref<inkTextParams>;
    let desc2: String;
    let i: Int32;
    let isUpgradable: Bool;
    let levelStr: String;
    let skillData: ref<ProficiencyDisplayData>;
    let skillsStr: String;
    let title: String;
    let total: Int32;
    switch data.attributeType {
      case PerkMenuAttribute.Johnny:
        title = "LocKey#1353";
        break;
      default:
        title = data.attributeData.label;
    };
    desc1Params = new inkTextParams();
    desc1Params.AddNumber("level", data.attributeData.value);
    desc1Params.AddNumber("total", this.m_maxProficiencyLevel);
    levelStr += GetLocalizedText("UI-Tooltips-LVL");
    this.AppendLine(desc1, levelStr);
    if NotEquals(data.attributeData.description, "") {
      this.AppendLine(desc2, data.attributeData.description);
    } else {
      this.AppendLine(desc2, "MISSING DESCRIPTION");
    };
    total = ArraySize(data.displayData.m_proficiencies);
    i = 0;
    while i < total {
      skillData = data.displayData.m_proficiencies[i];
      skillsStr += skillData.m_localizedName;
      if i != total - 1 {
        skillsStr += ", ";
      };
      i += 1;
    };
    this.AppendLine(desc2, skillsStr);
    this.SetTitle(title);
    this.SetDesc1(desc1);
    this.SetDesc2(desc2);
    if IsDefined(desc1Params) {
      inkTextRef.SetTextParameters(this.m_desc1Text, desc1Params);
    };
    isUpgradable = data.attributeData.availableToUpgrade && data.manager.HasAvailableAttributePoints();
    this.SetCanUpgrade(isUpgradable);
    this.SetCanOpenPerks(true);
  }

  private final func SetupCustom(data: ref<SkillTooltipData>) -> Void {
    let desc1: String;
    let desc2: String;
    let desc1Params: ref<inkTextParams> = new inkTextParams();
    desc1Params.AddNumber("level", data.skillData.m_level);
    desc1Params.AddNumber("total", data.skillData.m_maxLevel);
    this.AppendLine(desc1, GetLocalizedText("UI-Tooltips-LVL"));
    if data.skillData.m_level != data.skillData.m_maxLevel {
      desc1Params.AddNumber("exp", data.skillData.m_expPoints);
      desc1Params.AddNumber("maxExp", data.skillData.m_maxExpPoints);
      this.AppendLine(desc1, GetLocalizedText("UI-Tooltips-EXP"));
    };
    this.AppendLine(desc2, data.skillData.m_localizedDescription);
    this.SetTitle(data.skillData.m_localizedName);
    this.SetDesc1(desc1);
    this.SetDesc2(desc2);
    if IsDefined(desc1Params) {
      inkTextRef.SetTextParameters(this.m_desc1Text, desc1Params);
    };
  }

  private final func SetTitle(value: String) -> Void {
    inkWidgetRef.SetVisible(this.m_titleContainer, NotEquals(value, ""));
    inkTextRef.SetText(this.m_titleText, value);
  }

  private final func SetType(value: String) -> Void {
    inkWidgetRef.SetVisible(this.m_typeContainer, NotEquals(value, ""));
    inkTextRef.SetText(this.m_typeText, value);
  }

  private final func SetDesc1(value: String) -> Void {
    inkWidgetRef.SetVisible(this.m_desc1Container, NotEquals(value, ""));
    inkTextRef.SetText(this.m_desc1Text, value);
  }

  private final func SetDesc2(value: String) -> Void {
    inkWidgetRef.SetVisible(this.m_desc2Container, NotEquals(value, ""));
    inkTextRef.SetText(this.m_desc2Text, value);
  }

  private final func SetCanUpgrade(value: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_holdToUpgrade, value);
  }

  private final func SetCanOpenPerks(value: Bool) -> Void {
    if inkWidgetRef.IsValid(this.m_openPerkScreen) {
      inkWidgetRef.SetVisible(this.m_openPerkScreen, value);
    };
  }

  private final func AppendLine(out outString: String, line: String) -> Void {
    if NotEquals(line, "") {
      outString += line;
      this.AppendNewLine(outString);
    };
  }

  private final func AppendNewLine(out outString: String) -> Void {
    outString += " \\n";
  }
}
