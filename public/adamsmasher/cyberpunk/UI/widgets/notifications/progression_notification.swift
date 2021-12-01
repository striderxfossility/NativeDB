
public native class ProgressionViewData extends GenericNotificationViewData {

  public native let expValue: Int32;

  public native let expProgress: Float;

  public native let delta: Int32;

  public native let notificationColorTheme: CName;

  public native let type: gamedataProficiencyType;

  public native let currentLevel: Int32;

  public native let isLevelMaxed: Bool;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    let newData: ref<ProgressionViewData> = data as ProgressionViewData;
    if IsDefined(newData) && Equals(newData.type, this.type) {
      this.expProgress = newData.expProgress;
      this.expValue = newData.expValue;
      this.delta += newData.delta;
      this.currentLevel = newData.currentLevel;
      this.isLevelMaxed = newData.isLevelMaxed;
      return true;
    };
    return false;
  }
}

public class ProgressionWidgetGameController extends gameuiGenericNotificationGameController {

  @default(ProgressionWidgetGameController, 3.0f)
  private edit let m_duration: Float;

  private let m_playerDevelopmentSystem: ref<PlayerDevelopmentSystem>;

  private let m_combatModePSM: gamePSMCombat;

  private let m_combatModeListener: ref<CallbackHandle>;

  private let m_playerObject: wref<GameObject>;

  private let m_gameInstance: GameInstance;

  public func GetShouldSaveState() -> Bool {
    return true;
  }

  public func GetID() -> Int32 {
    return EnumInt(GenericNotificationType.ProgressionNotification);
  }

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    let controlledPuppet: wref<gamePuppetBase>;
    let controlledPuppetRecordID: TweakDBID;
    this.m_playerObject = this.GetPlayerControlledObject();
    this.m_playerDevelopmentSystem = GameInstance.GetScriptableSystemsContainer(this.m_playerObject.GetGame()).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem;
    this.RegisterPSMListeners(this.m_playerObject);
    this.m_gameInstance = this.GetPlayerControlledObject().GetGame();
    controlledPuppet = GetPlayer(this.m_gameInstance);
    if controlledPuppet != null {
      controlledPuppetRecordID = controlledPuppet.GetRecordID();
      if controlledPuppetRecordID == t"Character.johnny_replacer" {
        this.GetRootWidget().SetVisible(false);
      } else {
        this.GetRootWidget().SetVisible(true);
      };
    } else {
      this.GetRootWidget().SetVisible(true);
    };
  }

  protected cb func OnPlayerDetach(playerGameObject: ref<GameObject>) -> Bool {
    this.UnregisterPSMListeners(this.m_playerObject);
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
    if Equals(this.m_combatModePSM, gamePSMCombat.OutOfCombat) || Equals(this.m_combatModePSM, gamePSMCombat.Default) {
      this.SetNotificationPause(false);
      this.GetRootWidget().SetVisible(true);
    } else {
      this.SetNotificationPause(true);
      this.GetRootWidget().SetVisible(false);
    };
  }

  protected cb func OnCharacterProficiencyUpdated(evt: ref<ProficiencyProgressEvent>) -> Bool {
    switch evt.type {
      case gamedataProficiencyType.StreetCred:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"StreetCred", "LocKey#1210", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Assault:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22315", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Athletics:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22299", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Brawling:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22306", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.ColdBlood:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22302", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.CombatHacking:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22332", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Engineering:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22326", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Gunslinger:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22311", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Kenjutsu:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22318", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Stealth:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22324", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Demolition:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22320", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Crafting:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22328", evt.type, evt.currentLevel, evt.isLevelMaxed);
        break;
      case gamedataProficiencyType.Hacking:
        this.AddToNotificationQueue(evt.expValue, evt.remainingXP, evt.delta, n"Skills", "LocKey#22330", evt.type, evt.currentLevel, evt.isLevelMaxed);
    };
  }

  public final func AddToNotificationQueue(value: Int32, remainingPointsToLevelUp: Int32, delta: Int32, notificationColorTheme: CName, notificationName: String, type: gamedataProficiencyType, currentLevel: Int32, isLevelMaxed: Bool) -> Void {
    let notificationData: gameuiGenericNotificationData;
    let userData: ref<ProgressionViewData>;
    let sum: Int32 = remainingPointsToLevelUp + value;
    notificationData.time = this.m_duration;
    let progress: Float = Cast(value) / Cast(sum);
    if progress == 0.00 {
      progress = Cast(sum);
    };
    notificationData.widgetLibraryItemName = n"progression";
    userData = new ProgressionViewData();
    userData.expProgress = progress;
    userData.expValue = value;
    userData.notificationColorTheme = notificationColorTheme;
    userData.title = notificationName;
    userData.delta = delta;
    userData.type = type;
    userData.currentLevel = currentLevel;
    userData.isLevelMaxed = isLevelMaxed;
    notificationData.notificationData = userData;
    this.AddNewNotificationData(notificationData);
  }
}

public class ProgressionNotification extends GenericNotificationController {

  private let progression_data: ref<ProgressionViewData>;

  private edit let m_expBar: inkWidgetRef;

  private edit let m_expText: inkTextRef;

  private edit let m_barFG: inkWidgetRef;

  private edit let m_barBG: inkWidgetRef;

  private edit let m_root: inkWidgetRef;

  private edit let m_currentLevel: inkTextRef;

  private edit let m_nextLevel: inkTextRef;

  private let m_expBarWidthSize: Float;

  private let m_expBarHeightSize: Float;

  private let m_animationProxy: ref<inkAnimProxy>;

  private let m_barAnimationProxy: ref<inkAnimProxy>;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let barEndSize: Vector2;
    let barStartSize: Vector2;
    this.m_expBarWidthSize = inkWidgetRef.GetWidth(this.m_expBar);
    this.m_expBarHeightSize = inkWidgetRef.GetHeight(this.m_expBar);
    this.progression_data = notificationData as ProgressionViewData;
    inkTextRef.SetText(this.m_titleRef, this.progression_data.title);
    inkWidgetRef.SetState(this.m_root, this.progression_data.notificationColorTheme);
    barStartSize = new Vector2(AbsF(this.progression_data.expProgress * this.m_expBarWidthSize - Cast(this.progression_data.delta)), this.m_expBarHeightSize);
    barEndSize = new Vector2(this.progression_data.expProgress * this.m_expBarWidthSize, this.m_expBarHeightSize);
    inkTextRef.SetText(this.m_expText, IntToString(this.progression_data.delta));
    inkTextRef.SetText(this.m_currentLevel, IntToString(this.progression_data.currentLevel));
    if this.progression_data.isLevelMaxed {
      inkTextRef.SetText(this.m_nextLevel, "LocKey#42198");
    } else {
      inkTextRef.SetText(this.m_nextLevel, IntToString(this.progression_data.currentLevel + 1));
    };
    if barStartSize.X > barEndSize.X {
      barStartSize.X = barStartSize.X - barStartSize.X;
    };
    this.PlayAnim(n"intro");
    GameInstance.GetAudioSystem(this.GetPlayerControlledObject().GetGame()).Play(n"ui_menu_perk_level_up");
    this.BarProgressAnim(this.m_expBar, barStartSize, barEndSize);
  }

  public final func BarProgressAnim(animatingObject: inkWidgetRef, barStartSize: Vector2, barEndSize: Vector2) -> Void {
    let barProgress: ref<inkAnimDef> = new inkAnimDef();
    let sizeInterpolator: ref<inkAnimSize> = new inkAnimSize();
    sizeInterpolator.SetDuration(1.50);
    sizeInterpolator.SetStartSize(barStartSize);
    sizeInterpolator.SetEndSize(barEndSize);
    sizeInterpolator.SetType(inkanimInterpolationType.Quintic);
    sizeInterpolator.SetMode(inkanimInterpolationMode.EasyInOut);
    barProgress.AddInterpolator(sizeInterpolator);
    this.m_barAnimationProxy = inkWidgetRef.PlayAnimation(animatingObject, barProgress);
    this.m_barAnimationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnBarAnimationFinished");
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
  }

  protected cb func OnBarAnimationFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.PlayAnim(n"outro");
  }
}
