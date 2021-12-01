
public class interactionItemLogicController extends inkLogicController {

  private edit let m_inputButtonContainer: inkCompoundRef;

  private edit let m_inputDisplayControllerRef: inkWidgetRef;

  private edit let m_QuickHackCostHolder: inkWidgetRef;

  private edit let m_QuickHackCost: inkTextRef;

  private edit let m_QuickHackIcon: inkImageRef;

  private edit let m_QuickHackHolder: inkCompoundRef;

  private edit let m_label: inkTextRef;

  private edit let m_labelFail: inkTextRef;

  private edit let m_SkillCheckPassBG: inkWidgetRef;

  private edit let m_SkillCheckFailBG: inkWidgetRef;

  private edit let m_QHIllegalIndicator: inkWidgetRef;

  private edit let m_SCIllegalIndicator: inkWidgetRef;

  private edit let m_additionalReqsNeeded: inkWidgetRef;

  private edit let m_skillCheck: inkCompoundRef;

  private edit let m_skillCheckNormalReqs: inkCompoundRef;

  private edit let m_skillCheckIcon: inkImageRef;

  private edit let m_skillCheckText: inkTextRef;

  private let m_RootWidget: wref<inkCompoundWidget>;

  @default(interactionItemLogicController, 0.0)
  private let m_inActiveTransparency: Float;

  private let m_inputDisplayController: wref<inkInputDisplayController>;

  private let m_animProxy: ref<inkAnimProxy>;

  private let m_isSelected: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_RootWidget = this.GetRootCompoundWidget();
    this.m_inputDisplayController = inkWidgetRef.GetControllerByType(this.m_inputDisplayControllerRef, n"inkInputDisplayController") as inkInputDisplayController;
    inkWidgetRef.SetVisible(this.m_QuickHackHolder, false);
    inkWidgetRef.SetVisible(this.m_SCIllegalIndicator, false);
    inkWidgetRef.SetVisible(this.m_QHIllegalIndicator, false);
    inkWidgetRef.SetVisible(this.m_QuickHackCostHolder, false);
    this.PlayLibraryAnimation(n"interaction_intro");
  }

  public final func SetData(data: script_ref<InteractionChoiceData>, opt skillCheck: UIInteractionSkillCheck) -> Void {
    let iconID: TweakDBID;
    let skillReqParams: ref<inkTextParams>;
    let keyData: inkInputKeyData = new inkInputKeyData();
    inkInputKeyData.SetInputKey(keyData, Deref(data).rawInputKey);
    this.m_inputDisplayController.SetInputAction(Deref(data).inputAction);
    inkWidgetRef.SetVisible(this.m_skillCheck, skillCheck.isValid);
    if skillCheck.isValid {
      skillReqParams = new inkTextParams();
      if Equals(skillCheck.skillCheck, EDeviceChallengeSkill.Hacking) {
        iconID = t"ChoiceIcons.HackingIcon";
        skillReqParams.AddLocalizedString("NAME", "LocKey#22278");
      } else {
        if Equals(skillCheck.skillCheck, EDeviceChallengeSkill.Engineering) {
          iconID = t"ChoiceIcons.EngineeringIcon";
          skillReqParams.AddLocalizedString("NAME", "LocKey#22276");
        } else {
          iconID = t"ChoiceIcons.AthleticsIcon";
          skillReqParams.AddLocalizedString("NAME", "LocKey#22271");
        };
      };
      if skillCheck.isPassed {
        skillReqParams.AddNumber("REQUIRED_SKILL", skillCheck.requiredSkill);
        inkTextRef.SetLocalizedTextScript(this.m_skillCheckText, "LocKey#49423", skillReqParams);
      } else {
        skillReqParams.AddNumber("PLAYER_SKILL", skillCheck.playerSkill);
        skillReqParams.AddNumber("REQUIRED_SKILL", skillCheck.requiredSkill);
        inkTextRef.SetLocalizedTextScript(this.m_skillCheckText, "LocKey#49421", skillReqParams);
      };
      this.SetTexture(this.m_skillCheckIcon, iconID);
      inkWidgetRef.SetVisible(this.m_label, skillCheck.isPassed);
      inkWidgetRef.SetVisible(this.m_labelFail, !skillCheck.isPassed);
      inkWidgetRef.SetVisible(this.m_SkillCheckPassBG, skillCheck.isPassed);
      inkWidgetRef.SetVisible(this.m_SkillCheckFailBG, !skillCheck.isPassed);
      inkWidgetRef.SetVisible(this.m_skillCheckNormalReqs, skillCheck.isPassed || !skillCheck.hasAdditionalRequirements);
      inkWidgetRef.SetVisible(this.m_additionalReqsNeeded, !skillCheck.isPassed && skillCheck.hasAdditionalRequirements);
    };
    this.SetLabel(data);
    if ArraySize(Deref(data).captionParts.parts) > 0 {
      this.EmptyCaptionParts();
      this.SetCaptionParts(Deref(data).captionParts.parts);
    } else {
      this.EmptyCaptionParts();
    };
    if ChoiceTypeWrapper.IsType(Deref(data).type, gameinteractionsChoiceType.Illegal) {
      inkWidgetRef.SetVisible(this.m_QHIllegalIndicator, true);
      if ArraySize(Deref(data).captionParts.parts) == 0 {
        inkWidgetRef.SetVisible(this.m_SCIllegalIndicator, false);
      };
    } else {
      inkWidgetRef.SetVisible(this.m_QHIllegalIndicator, false);
      inkWidgetRef.SetVisible(this.m_SCIllegalIndicator, false);
    };
    if ChoiceTypeWrapper.IsType(Deref(data).type, gameinteractionsChoiceType.Inactive) || ChoiceTypeWrapper.IsType(Deref(data).type, gameinteractionsChoiceType.CheckFailed) {
      this.m_RootWidget.SetState(n"Inactive");
      inkWidgetRef.SetVisible(this.m_SkillCheckPassBG, false);
      inkWidgetRef.SetVisible(this.m_SkillCheckFailBG, true);
      inkWidgetRef.SetVisible(this.m_label, false);
      inkWidgetRef.SetVisible(this.m_labelFail, true);
    } else {
      this.m_RootWidget.SetState(n"Active");
      inkWidgetRef.SetVisible(this.m_SkillCheckPassBG, true);
      inkWidgetRef.SetVisible(this.m_SkillCheckFailBG, false);
      inkWidgetRef.SetVisible(this.m_label, true);
      inkWidgetRef.SetVisible(this.m_labelFail, false);
    };
    if ChoiceTypeWrapper.IsType(Deref(data).type, gameinteractionsChoiceType.Selected) && !this.m_isSelected {
      this.PlayAnim(n"Select");
    };
  }

  public final func SetButtonVisibility(argBool: Bool) -> Void {
    this.m_inputDisplayController.SetVisible(argBool);
    inkWidgetRef.SetOpacity(this.m_label, argBool ? 1.00 : this.m_inActiveTransparency);
  }

  public final func SetZoneChange(value: Int32) -> Void {
    let zone: gamePSMZones = IntEnum(value);
    switch zone {
      case gamePSMZones.Safe:
      case gamePSMZones.Public:
        this.SetIllegalActionOpacity(0.00);
        break;
      case gamePSMZones.Dangerous:
      case gamePSMZones.Restricted:
        this.SetIllegalActionOpacity(1.00);
    };
  }

  private final func SetLabel(data: script_ref<InteractionChoiceData>) -> Void {
    let action: ref<DeviceAction>;
    let deviceAction: ref<ScriptableDeviceAction>;
    let textParams: ref<inkTextParams>;
    let locText: String = GetLocalizedText(Deref(data).localizedName);
    let captionTags: String = GetCaptionTagsFromArray(Deref(data).captionParts.parts);
    if NotEquals(captionTags, "") {
      locText = captionTags + " " + locText;
    };
    if ArraySize(Deref(data).data) > 0 {
      action = FromVariant(Deref(data).data[0]);
      deviceAction = action as ScriptableDeviceAction;
    };
    if IsDefined(deviceAction) && deviceAction.IsInactive() && NotEquals(deviceAction.GetInactiveReason(), "") {
      textParams = new inkTextParams();
      textParams.AddString("ACTION", locText);
      textParams.AddLocalizedString("ADDITIONALINFO", deviceAction.GetInactiveReason());
      inkTextRef.SetLocalizedTextScript(this.m_label, "LocKey#42173", textParams);
      inkTextRef.SetLocalizedTextScript(this.m_labelFail, "LocKey#42173", textParams);
    } else {
      inkTextRef.SetText(this.m_label, locText);
      inkTextRef.SetText(this.m_labelFail, locText);
    };
  }

  public final func SetCaptionParts(argList: array<ref<InteractionChoiceCaptionPart>>) -> Void {
    let currType: gamedataChoiceCaptionPartType;
    let iconID: TweakDBID;
    let iconName: CName;
    let iconRecord: wref<ChoiceCaptionIconPart_Record>;
    let mappinVariant: gamedataMappinVariant;
    let showQHHolder: Bool;
    let i: Int32 = 0;
    while i < ArraySize(argList) {
      currType = argList[i].GetType();
      if Equals(currType, gamedataChoiceCaptionPartType.Icon) {
        iconRecord = argList[i] as InteractionChoiceCaptionIconPart.iconRecord;
        iconID = iconRecord.TexturePartID().GetID();
        if TDBID.IsValid(iconID) {
          this.SetTexture(this.m_QuickHackIcon, iconID);
          showQHHolder = true;
        } else {
          mappinVariant = iconRecord.MappinVariant().Type();
          iconName = MappinUIUtils.MappinToTexturePart(mappinVariant);
          inkImageRef.SetTexturePart(this.m_QuickHackIcon, iconName);
          if NotEquals(iconName, n"invalid") && NotEquals(iconName, n"") {
            showQHHolder = true;
          };
        };
        if showQHHolder {
          inkWidgetRef.SetVisible(this.m_QuickHackHolder, true);
        };
      } else {
        if Equals(currType, gamedataChoiceCaptionPartType.QuickhackCost) {
          inkWidgetRef.SetVisible(this.m_QuickHackHolder, true);
          inkWidgetRef.SetVisible(this.m_QuickHackCostHolder, true);
          inkTextRef.SetText(this.m_QuickHackCost, IntToString(argList[i] as InteractionChoiceCaptionQuickhackCostPart.cost));
        };
      };
      i = i + 1;
    };
  }

  public final func EmptyCaptionParts() -> Void {
    inkWidgetRef.SetVisible(this.m_QuickHackHolder, false);
  }

  private final func SetIllegalActionOpacity(opacity: Float) -> Void {
    inkWidgetRef.SetOpacity(this.m_QHIllegalIndicator, opacity);
    inkWidgetRef.SetOpacity(this.m_SCIllegalIndicator, opacity);
  }

  private final func PlayAnim(animName: CName) -> Void {
    this.m_animProxy = this.PlayLibraryAnimation(animName);
  }
}
