
public native class LevelUpNotificationViewData extends GenericNotificationViewData {

  public native let canBeMerged: Bool;

  public native let levelupdata: LevelUpData;

  public native let proficiencyRecord: ref<Proficiency_Record>;

  public native let profString: String;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    return this.canBeMerged;
  }
}

public class LevelUpNotificationQueue extends gameuiGenericNotificationGameController {

  @default(LevelUpNotificationQueue, 2.0f)
  private edit let m_duration: Float;

  private let m_levelUpBlackboard: wref<IBlackboard>;

  private let m_playerLevelUpListener: ref<CallbackHandle>;

  private let m_playerObject: wref<GameObject>;

  private let m_combatModePSM: gamePSMCombat;

  private let m_combatModeListener: ref<CallbackHandle>;

  public func GetShouldSaveState() -> Bool {
    return true;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.LevelUpNotification);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_playerObject = this.GetPlayerControlledObject();
    this.RegisterPSMListeners(this.m_playerObject);
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(this.m_playerObject);
  }

  protected cb func OnInitialize() -> Bool {
    this.m_levelUpBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_LevelUp);
    this.m_playerLevelUpListener = this.m_levelUpBlackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this, n"OnCharacterLevelUpdated");
    this.SetNotificationPauseWhenHidden(true);
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_levelUpBlackboard) {
      this.m_levelUpBlackboard.UnregisterListenerVariant(GetAllBlackboardDefs().UI_LevelUp.level, this.m_playerLevelUpListener);
    };
  }

  protected final func RegisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        this.m_combatModeListener = playerStateMachineBlackboard.RegisterListenerInt(playerSMDef.Combat, this, n"OnCombatStateChanged");
      };
    };
  }

  protected final func UnregisterPSMListeners(playerObject: ref<GameObject>) -> Void {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerSMDef: ref<PlayerStateMachineDef> = GetAllBlackboardDefs().PlayerStateMachine;
    if IsDefined(playerSMDef) {
      playerStateMachineBlackboard = this.GetPSMBlackboard(playerObject);
      if IsDefined(playerStateMachineBlackboard) {
        playerStateMachineBlackboard.UnregisterDelayedListener(playerSMDef.Combat, this.m_combatModeListener);
      };
    };
  }

  protected cb func OnCombatStateChanged(value: Int32) -> Bool {
    this.m_combatModePSM = IntEnum(value);
    if Equals(this.m_combatModePSM, gamePSMCombat.InCombat) {
      this.SetNotificationPause(true);
      this.GetRootWidget().SetVisible(false);
    } else {
      this.SetNotificationPause(false);
      this.GetRootWidget().SetVisible(true);
    };
  }

  private final func OnCharacterLevelUpdated(value: Variant) -> Void {
    let action: ref<OpenPerksNotificationAction>;
    let mapAction: ref<OpenWorldMapNotificationAction>;
    let notificationData: gameuiGenericNotificationData;
    let levelUpData: LevelUpData = FromVariant(value);
    let profString: String = EnumValueToString("gamedataProficiencyType", Cast(EnumInt(levelUpData.type)));
    let proficiencyRecord: ref<Proficiency_Record> = TweakDBInterface.GetProficiencyRecord(TDBID.Create("Proficiencies." + profString));
    let unlockedActivites: Int32 = TweakDBInterface.GetInt(TDBID.Create("Constants.StreetCredActivityUnlocks.level" + levelUpData.lvl), 0);
    let userData: ref<LevelUpNotificationViewData> = new LevelUpNotificationViewData();
    userData.canBeMerged = false;
    userData.levelupdata = levelUpData;
    userData.profString = proficiencyRecord.Loc_name_key();
    userData.proficiencyRecord = proficiencyRecord;
    notificationData.time = this.m_duration;
    if Equals(levelUpData.type, gamedataProficiencyType.Level) {
      notificationData.widgetLibraryItemName = n"LevelUp_";
      userData.soundEvent = n"PlayerLevelUpPopup";
      userData.soundAction = n"OnOpen";
      if !levelUpData.disableAction {
        action = new OpenPerksNotificationAction();
        action.m_eventDispatcher = this;
        userData.action = action;
      };
    } else {
      if Equals(levelUpData.type, gamedataProficiencyType.StreetCred) {
        notificationData.widgetLibraryItemName = n"StreetCredUp_";
        userData.soundEvent = n"PlayerLevelUpPopup";
        userData.soundAction = n"OnOpen";
        if !levelUpData.disableAction {
          if unlockedActivites > 0 {
            mapAction = new OpenWorldMapNotificationAction();
            mapAction.m_eventDispatcher = this;
            userData.action = mapAction;
          } else {
            action = null;
            action.m_eventDispatcher = this;
            userData.action = action;
          };
        };
      } else {
        notificationData.widgetLibraryItemName = n"SkillUp_";
        userData.soundEvent = n"SkillLevelUpPopup";
        userData.soundAction = n"OnOpen";
        if !levelUpData.disableAction {
          action = new OpenPerksNotificationAction();
          action.m_eventDispatcher = this;
          userData.action = action;
        };
      };
    };
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }
}

public class LevelUpNotification extends GenericNotificationController {

  private let m_levelup_data: ref<LevelUpNotificationViewData>;

  private let m_animation: ref<inkAnimProxy>;

  private let bonusRecord: ref<PassiveProficiencyBonus_Record>;

  private edit let m_LevelUpLabelText: inkTextRef;

  private edit let m_LevelUpValue: inkTextRef;

  private edit let m_LevelUpHolder: inkWidgetRef;

  private edit let m_LevelUpPreviousValue: inkTextRef;

  private edit let m_AttributePointsValue: inkTextRef;

  private edit let m_AttributePointsPreviousValue: inkTextRef;

  private edit let m_AttributePointsHolder: inkWidgetRef;

  private edit let m_PerkPointsValue: inkTextRef;

  private edit let m_PerkPreviousValue: inkTextRef;

  private edit let m_SkillIcon: inkImageRef;

  private edit let m_SkillIconShadow: inkImageRef;

  private let bonusDisplay: ref<LevelRewardDisplayData>;

  private edit let m_passiveBonusRewardLabel: inkTextRef;

  private edit let m_passiveBonusReward: inkWidgetRef;

  public let unlockedActivites: Int32;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let iconRecord: ref<UIIcon_Record>;
    this.SetNotificationData(notificationData);
    this.m_levelup_data = notificationData as LevelUpNotificationViewData;
    inkTextRef.SetLetterCase(this.m_LevelUpLabelText, textLetterCase.UpperCase);
    inkWidgetRef.SetVisible(this.m_actionRef, this.m_levelup_data.action != null);
    if Equals(this.m_levelup_data.levelupdata.type, gamedataProficiencyType.Level) || Equals(this.m_levelup_data.levelupdata.type, gamedataProficiencyType.StreetCred) {
      inkTextRef.SetText(this.m_LevelUpValue, IntToString(this.m_levelup_data.levelupdata.lvl));
      inkTextRef.SetText(this.m_LevelUpPreviousValue, IntToString(Max(0, this.m_levelup_data.levelupdata.lvl - 1)));
      inkTextRef.SetText(this.m_PerkPointsValue, IntToString(this.m_levelup_data.levelupdata.perkPoints));
      inkTextRef.SetText(this.m_PerkPreviousValue, IntToString(Max(0, this.m_levelup_data.levelupdata.perkPoints - 1)));
      if Equals(this.m_levelup_data.levelupdata.type, gamedataProficiencyType.Level) {
        inkTextRef.SetText(this.m_AttributePointsPreviousValue, IntToString(this.m_levelup_data.levelupdata.attributePoints));
        inkTextRef.SetText(this.m_AttributePointsValue, IntToString(Max(0, this.m_levelup_data.levelupdata.attributePoints - 1)));
        inkTextRef.SetText(this.m_LevelUpLabelText, "LocKey#21980");
        if this.m_animation.IsPlaying() {
          this.m_animation.Stop();
        };
        this.m_animation = this.PlayLibraryAnimation(n"LevelUp_03");
      };
      if Equals(this.m_levelup_data.levelupdata.type, gamedataProficiencyType.StreetCred) {
        this.unlockedActivites = TweakDBInterface.GetInt(TDBID.Create("Constants.StreetCredActivityUnlocks.level" + this.m_levelup_data.levelupdata.lvl), 0);
        if this.unlockedActivites > 0 {
          inkTextRef.SetText(this.m_AttributePointsPreviousValue, IntToString(this.unlockedActivites));
          inkTextRef.SetText(this.m_AttributePointsValue, IntToString(Max(0, this.unlockedActivites - 1)));
          inkWidgetRef.SetVisible(this.m_LevelUpHolder, false);
        } else {
          inkWidgetRef.SetVisible(this.m_AttributePointsHolder, false);
          inkWidgetRef.SetVisible(this.m_actionRef, false);
          inkWidgetRef.SetVisible(this.m_LevelUpHolder, false);
        };
        if this.m_animation.IsPlaying() {
          this.m_animation.Stop();
        };
        this.m_animation = this.PlayLibraryAnimation(n"StreetCredUp_03");
      };
      this.PlaySound(this.m_levelup_data.soundEvent, this.m_levelup_data.soundAction);
    } else {
      inkTextRef.SetText(this.m_LevelUpLabelText, this.m_levelup_data.proficiencyRecord.Loc_name_key());
      inkTextRef.SetText(this.m_LevelUpValue, IntToString(this.m_levelup_data.levelupdata.lvl));
      inkTextRef.SetText(this.m_LevelUpPreviousValue, IntToString(Max(0, this.m_levelup_data.levelupdata.lvl - 1)));
      this.bonusRecord = this.m_levelup_data.proficiencyRecord.GetPassiveBonusesItem(this.m_levelup_data.levelupdata.lvl - 1);
      this.bonusDisplay = new LevelRewardDisplayData();
      this.bonusDisplay.level = this.m_levelup_data.levelupdata.lvl - 1;
      this.bonusDisplay.locPackage = UILocalizationDataPackage.FromPassiveUIDataPackage(this.bonusRecord.UiData());
      this.bonusDisplay.description = LocKeyToString(this.bonusRecord.UiData().Loc_name_key());
      if Cast(this.bonusDisplay.locPackage.GetParamsCount()) {
        inkWidgetRef.SetVisible(this.m_passiveBonusReward, true);
        inkTextRef.SetText(this.m_passiveBonusRewardLabel, LocKeyToString(this.bonusRecord.UiData().Loc_name_key()));
        inkTextRef.SetTextParameters(this.m_passiveBonusRewardLabel, this.bonusDisplay.locPackage.GetTextParams());
      } else {
        inkWidgetRef.SetVisible(this.m_passiveBonusReward, false);
      };
      iconRecord = TweakDBInterface.GetUIIconRecord(TDBID.Create("UIIcon." + ToString(this.m_levelup_data.levelupdata.type)));
      inkImageRef.SetTexturePart(this.m_SkillIcon, iconRecord.AtlasPartName());
      inkImageRef.SetTexturePart(this.m_SkillIconShadow, iconRecord.AtlasPartName());
      if this.m_animation.IsPlaying() {
        this.m_animation.Stop();
      };
      this.m_animation = this.PlayLibraryAnimation(n"SkillUp_02");
      this.PlaySound(this.m_levelup_data.soundEvent, this.m_levelup_data.soundAction);
    };
  }
}
