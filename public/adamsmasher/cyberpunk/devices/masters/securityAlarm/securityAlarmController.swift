
public class SecurityAlarmController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SecurityAlarmControllerPS extends MasterControllerPS {

  protected persistent let m_securityAlarmSetup: SecurityAlarmSetup;

  @default(SecurityAlarmControllerPS, ESecuritySystemState.SAFE)
  private let m_securityAlarmState: ESecuritySystemState;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Alarm";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.RefreshSlaves_Event();
  }

  public final const func GetAlarmState() -> ESecuritySystemState {
    return this.m_securityAlarmState;
  }

  public final const func UsesSound() -> Bool {
    return this.m_securityAlarmSetup.useSound;
  }

  public final const func AlarmSound() -> CName {
    return this.m_securityAlarmSetup.alarmSound;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionToggleAlarm();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    if !ToggleAlarm.IsDefaultConditionMet(this, context) {
      currentAction.SetInactiveWithReason(false, "LocKey#7005");
    };
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    if !ScriptableDeviceAction.IsDefaultConditionMet(this, context) {
      currentAction.SetInactiveWithReason(false, "LocKey#7003");
    };
    ArrayPush(outActions, currentAction);
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    if Clearance.IsInRange(context.clearance, DefaultActionsParametersHolder.GetQuestClearance()) {
      ArrayPush(outActions, this.ActionQuestForceSecuritySystemSafe());
      ArrayPush(outActions, this.ActionQuestForceSecuritySystemArmed());
    };
    return;
  }

  public func OnTargetAssessmentRequest(evt: ref<TargetAssessmentRequest>) -> EntityNotificationType {
    if IsDefined(this.GetSecuritySystem()) {
      this.m_securityAlarmState = this.GetSecuritySystem().GetSecurityState();
    };
    this.RefreshSlaves_Event();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    this.OnSecuritySystemOutput(evt);
    this.m_securityAlarmState = evt.GetCachedSecurityState();
    this.RefreshSlaves_Event();
    this.NotifyParents();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnSecurityAlarmBreachResponse(evt: ref<SecurityAlarmBreachResponse>) -> EntityNotificationType {
    if Equals(evt.GetSecurityState(), ESecuritySystemState.ALERTED) || Equals(evt.GetSecurityState(), ESecuritySystemState.COMBAT) {
      this.WakeUpDevice();
    };
    this.m_securityAlarmState = evt.GetSecurityState();
    this.RefreshSlaves_Event();
    this.NotifyParents();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceSecuritySystemSafe(evt: ref<QuestForceSecuritySystemSafe>) -> EntityNotificationType {
    this.QuestForceState(ESecuritySystemState.SAFE);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceSecuritySystemArmed(evt: ref<QuestForceSecuritySystemArmed>) -> EntityNotificationType {
    this.QuestForceState(ESecuritySystemState.COMBAT);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func QuestForceState(state: ESecuritySystemState) -> Void {
    this.m_securityAlarmState = state;
    this.RefreshSlaves_Event();
    this.NotifyParents();
  }

  protected final func ActionToggleAlarm() -> ref<ToggleAlarm> {
    let action: ref<ToggleAlarm> = new ToggleAlarm();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleAlarmClearance();
    action.SetUp(this);
    action.SetProperties(this.m_securityAlarmState);
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  public final func OnToggleAlarm(evt: ref<ToggleAlarm>) -> EntityNotificationType {
    let toggledState: ESecuritySystemState = Equals(this.m_securityAlarmState, ESecuritySystemState.COMBAT) ? ESecuritySystemState.SAFE : ESecuritySystemState.COMBAT;
    if evt.IsStarted() {
      evt.SetCanTriggerStim(true);
      this.m_securityAlarmState = toggledState;
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      evt.SetCanTriggerStim(false);
      if this.IsConnectedToSecuritySystem() {
        this.m_securityAlarmState = this.GetSecuritySystem().GetSecurityState();
      } else {
        this.m_securityAlarmState = toggledState;
      };
    };
    this.RefreshSlaves_Event();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSecurityAlarmEscalate() -> ref<SecurityAlarmEscalate> {
    let action: ref<SecurityAlarmEscalate> = new SecurityAlarmEscalate();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  public final func OnSecurityAlarmEscalate(evt: ref<SecurityAlarmEscalate>) -> EntityNotificationType {
    if evt.IsStarted() {
      evt.SetCanTriggerStim(true);
      this.TriggerSecuritySystemNotification(this.GetPlayerMainObject(), this.GetOwnerEntityWeak().GetWorldPosition(), ESecurityNotificationType.COMBAT);
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      evt.SetCanTriggerStim(false);
    };
    this.RefreshSlaves_Event();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func CreateAlarmResponse(alarmState: ESecuritySystemState) -> ref<SecurityAlarmBreachResponse> {
    let action: ref<SecurityAlarmBreachResponse>;
    if Equals(alarmState, ESecuritySystemState.UNINITIALIZED) {
      alarmState = this.m_securityAlarmState;
    };
    action = new SecurityAlarmBreachResponse();
    action.SetUp(this);
    action.SetProperties(alarmState);
    action.AddDeviceName(this.GetDeviceName());
    return action;
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    this.RefreshSlaves();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func RefreshSlaves() -> Void {
    let alarmResponse: ref<SecurityAlarmBreachResponse>;
    let i: Int32;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    if this.IsON() {
      alarmResponse = this.CreateAlarmResponse(this.m_securityAlarmState);
    } else {
      alarmResponse = this.CreateAlarmResponse(ESecuritySystemState.SAFE);
    };
    i = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        this.ExecutePSAction(alarmResponse, devices[i]);
      };
      i = i + 1;
    };
  }

  public final const quest func IsAlarmStateCombat() -> Bool {
    if Equals(this.m_securityAlarmState, ESecuritySystemState.COMBAT) {
      return true;
    };
    return false;
  }

  public final const quest func IsAlarmStateNotCombat() -> Bool {
    if Equals(this.m_securityAlarmState, ESecuritySystemState.COMBAT) {
      return false;
    };
    return true;
  }

  public final const quest func IsAlarmStateSafe() -> Bool {
    if Equals(this.m_securityAlarmState, ESecuritySystemState.SAFE) {
      return true;
    };
    return false;
  }

  public final const quest func IsAlarmStateNotSafe() -> Bool {
    if Equals(this.m_securityAlarmState, ESecuritySystemState.SAFE) {
      return false;
    };
    return true;
  }

  public final const quest func IsAlarmStateAlerted() -> Bool {
    if Equals(this.m_securityAlarmState, ESecuritySystemState.ALERTED) {
      return true;
    };
    return false;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.SecuritySystemDeviceBackground";
  }
}
