
public class SimpleSwitchController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SimpleSwitchControllerPS extends MasterControllerPS {

  protected persistent let m_switchAction: ESwitchAction;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForON: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForOFF: TweakDBID;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#115";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.RefreshSlaves_Event(true);
  }

  public const func GetExpectedSlaveState() -> EDeviceStatus {
    if Equals(this.m_switchAction, ESwitchAction.ToggleOn) {
      return this.GetDeviceState();
    };
    return EDeviceStatus.INVALID;
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(2, 2);
  }

  public final func IsLightSwitch() -> Bool {
    if Equals(this.m_switchAction, ESwitchAction.ToggleOn) {
      return true;
    };
    return false;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if ToggleON.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionToggleON());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleON();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetInactiveWithReason(ToggleON.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    this.RefreshSlaves(evt.onInitialize);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func RefreshSlaves(opt onInitialize: Bool) -> Void {
    let device: ref<ScriptableDeviceComponentPS>;
    let i: Int32;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let action: ref<ScriptableDeviceAction> = this.GetAction();
    if IsDefined(action) {
      i = 0;
      while i < ArraySize(devices) {
        device = devices[i] as ScriptableDeviceComponentPS;
        if !IsDefined(device) {
        } else {
          if onInitialize && device.IsConnectedToCLS() {
          } else {
            this.ExecutePSAction(action, devices[i]);
          };
        };
        i += 1;
      };
    };
  }

  private final func GetAction() -> ref<ScriptableDeviceAction> {
    let actionToGet: ref<ScriptableDeviceAction>;
    if Equals(this.m_switchAction, ESwitchAction.ToggleOn) {
      if this.IsON() {
        actionToGet = this.ActionSetDeviceON();
      } else {
        if this.IsOFF() {
          actionToGet = this.ActionSetDeviceOFF();
        };
      };
    } else {
      if Equals(this.m_switchAction, ESwitchAction.ToggleActivate) {
        if this.IsON() {
          actionToGet = this.ActionActivateDevice();
        } else {
          if this.IsOFF() {
            actionToGet = this.ActionDeactivateDevice();
          };
        };
      };
    };
    return actionToGet;
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState, this.m_nameForON, this.m_nameForOFF);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction();
    return action;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.OnToggleON(evt);
    this.RefreshSlaves();
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnQuestForceON(evt: ref<QuestForceON>) -> EntityNotificationType {
    this.OnQuestForceON(evt);
    this.RefreshSlaves();
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func OnQuestForceOFF(evt: ref<QuestForceOFF>) -> EntityNotificationType {
    this.OnQuestForceOFF(evt);
    this.RefreshSlaves();
    return EntityNotificationType.SendPSChangedEventToEntity;
  }
}
