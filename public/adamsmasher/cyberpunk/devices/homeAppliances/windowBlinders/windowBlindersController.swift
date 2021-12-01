
public class ToggleTiltBlinders extends ActionBool {

  public final func SetProperties(isTilted: Bool) -> Void {
    this.actionName = n"ActionTiltBlinders";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ActionTiltBlinders", isTilted, n"LocKey#271", n"LocKey#272");
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if FromVariant(this.prop.first) {
      return "TiltBlindersClose";
    };
    return "TiltBlindersOpen";
  }
}

public class WindowBlindersController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class WindowBlindersControllerPS extends ScriptableDeviceComponentPS {

  private inline let m_windowBlindersSkillChecks: ref<EngDemoContainer>;

  protected persistent let m_windowBlindersData: WindowBlindersData;

  protected let m_cachedState: EWindowBlindersStates;

  protected let m_alarmRaised: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-WindowBlinders";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.InitializeSkillChecks(this.m_windowBlindersSkillChecks);
    if this.IsSkillCheckActive() {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
    };
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_door.widgetbrush";
  }

  public final const quest func IsOpen() -> Bool {
    if Equals(this.m_windowBlindersData.m_windowBlindersState, EWindowBlindersStates.Open) {
      return true;
    };
    return false;
  }

  public final const quest func IsTilted() -> Bool {
    if Equals(this.m_windowBlindersData.m_windowBlindersState, EWindowBlindersStates.Tilted) {
      return true;
    };
    return false;
  }

  public final const quest func IsClosed() -> Bool {
    if Equals(this.m_windowBlindersData.m_windowBlindersState, EWindowBlindersStates.Closed) {
      return true;
    };
    return false;
  }

  public final const quest func IsNonInteractive() -> Bool {
    if Equals(this.m_windowBlindersData.m_windowBlindersState, EWindowBlindersStates.NonInteractive) {
      return true;
    };
    return false;
  }

  protected func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if this.IsNonInteractive() {
      return false;
    };
    if this.GetActions(actions, context) {
      if this.m_windowBlindersData.m_hasOpenInteraction {
        ArrayPush(actions, this.ActionToggleOpen());
      };
      if !this.IsOpen() && this.m_windowBlindersData.m_hasTiltInteraction {
        ArrayPush(actions, this.ActionToggleTiltBlinders());
      };
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if this.IsNonInteractive() || !this.m_windowBlindersData.m_hasQuickHack {
      return false;
    };
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if this.IsNonInteractive() || !this.m_windowBlindersData.m_hasQuickHack {
      return;
    };
    currentAction = this.ActionQuickHackToggleOpen();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    ArrayPush(outActions, currentAction);
    if this.m_windowBlindersData.m_hasTiltInteraction {
      currentAction = this.ActionToggleTiltBlinders();
      currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
      currentAction.SetInactiveWithReason(!this.IsOpen(), "LocKey#7012");
      ArrayPush(outActions, currentAction);
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionQuestForceOpen());
    ArrayPush(outActions, this.ActionQuestForceClose());
    return;
  }

  protected func ActionQuickHackToggleOpen() -> ref<QuickHackToggleOpen> {
    let action: ref<QuickHackToggleOpen> = new QuickHackToggleOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsOpen());
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    return action;
  }

  public final func OnQuickHackToggleOpen(evt: ref<QuickHackToggleOpen>) -> EntityNotificationType {
    this.ExecutePSAction(this.ActionToggleOpen());
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func ActionToggleOpen() -> ref<ToggleOpen> {
    let action: ref<ToggleOpen> = new ToggleOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsOpen());
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleOpen(evt: ref<ToggleOpen>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsOpen() {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
    } else {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Open;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func ActionToggleTiltBlinders() -> ref<ToggleTiltBlinders> {
    let action: ref<ToggleTiltBlinders> = new ToggleTiltBlinders();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsTilted());
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleTiltBlinders(evt: ref<ToggleTiltBlinders>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if !this.IsTilted() {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Tilted;
    } else {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.OnActionEngineering(evt);
    if this.IsOpen() {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
    } else {
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Open;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.OnActionDemolition(evt);
    this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Open;
    this.ForceDisableDevice();
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    this.OnSecuritySystemOutput(evt);
    if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
      this.m_alarmRaised = true;
      this.m_cachedState = this.m_windowBlindersData.m_windowBlindersState;
      if this.IsOpen() {
        this.ExecutePSAction(this.ActionToggleOpen(), this);
      } else {
        if this.IsTilted() {
          this.ExecutePSAction(this.ActionToggleTiltBlinders(), this);
        };
      };
      this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.NonInteractive;
    } else {
      if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.SAFE) && this.m_alarmRaised {
        this.m_alarmRaised = false;
        this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
        if Equals(this.m_cachedState, EWindowBlindersStates.Tilted) {
          this.ExecutePSAction(this.ActionToggleTiltBlinders(), this);
        } else {
          if Equals(this.m_cachedState, EWindowBlindersStates.Open) {
            this.ExecutePSAction(this.ActionToggleOpen(), this);
          };
        };
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func ActionQuestForceOpen() -> ref<QuestForceOpen> {
    let action: ref<QuestForceOpen> = new QuestForceOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceOpen(evt: ref<QuestForceOpen>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Open;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func ActionQuestForceClose() -> ref<QuestForceClose> {
    let action: ref<QuestForceClose> = new QuestForceClose();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceClose(evt: ref<QuestForceClose>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_windowBlindersData.m_windowBlindersState = EWindowBlindersStates.Closed;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceBackground";
  }
}
