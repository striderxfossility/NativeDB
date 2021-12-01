
public class IntercomController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class IntercomControllerPS extends ScriptableDeviceComponentPS {

  protected let m_isCalling: Bool;

  protected let m_sceneStarted: Bool;

  protected let m_endingCall: Bool;

  private let m_forceLookAt: EntityID;

  private let m_forceFollow: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if this.IsON() && !this.m_isCalling && !this.m_sceneStarted {
      ArrayPush(actions, this.ActionStartCall());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestPickUpCall());
    ArrayPush(actions, this.ActionQuestHangUpCall());
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    action.SetDurationValue(this.GetDistractionDuration(action));
    action.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, action);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final const quest func CallStarted() -> Bool {
    return this.m_isCalling;
  }

  protected final func ActionStartCall() -> ref<StartCall> {
    let action: ref<StartCall> = new StartCall();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.GetDeviceName());
    action.SetDurationValue(6.00);
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnStartCall(evt: ref<StartCall>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if evt.IsStarted() {
      this.m_isCalling = true;
      this.m_forceFollow = true;
      this.m_forceLookAt = evt.GetExecutor().GetEntityID();
      this.RefreshSlaves_Event();
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      if !this.m_sceneStarted {
        this.m_forceFollow = false;
        this.RefreshSlaves_Event();
        this.ExecutePSActionWithDelay(this.ActionResetIntercom(), this, 2.00);
      } else {
        return EntityNotificationType.DoNotNotifyEntity;
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestPickUpCall() -> ref<QuestPickUpCall> {
    let action: ref<QuestPickUpCall> = new QuestPickUpCall();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestPickUpCall(evt: ref<QuestPickUpCall>) -> EntityNotificationType {
    this.m_sceneStarted = true;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionQuestHangUpCall() -> ref<QuestHangUpCall> {
    let action: ref<QuestHangUpCall> = new QuestHangUpCall();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestHangUpCall(evt: ref<QuestHangUpCall>) -> EntityNotificationType {
    this.m_forceFollow = false;
    this.RefreshSlaves_Event();
    this.UseNotifier(evt);
    this.ExecutePSActionWithDelay(this.ActionResetIntercom(), this, 2.00);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionResetIntercom() -> ref<DelayEvent> {
    let delayEvent: ref<DelayEvent> = new DelayEvent();
    delayEvent.SetUp(this);
    delayEvent.SetProperties();
    delayEvent.AddDeviceName(this.m_deviceName);
    return delayEvent;
  }

  public final func OnResetIntercom(evt: ref<DelayEvent>) -> EntityNotificationType {
    this.m_isCalling = false;
    this.m_sceneStarted = false;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionForceFollowTarget() -> ref<QuestLookAtTarget> {
    let action: ref<QuestLookAtTarget> = new QuestLookAtTarget();
    action.SetUp(this);
    action.SetPropertiesFromScripts(this.m_forceLookAt);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionStopFollowingTarget() -> ref<QuestStopLookAtTarget> {
    let action: ref<QuestStopLookAtTarget> = new QuestStopLookAtTarget();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final const func GetImmediateSlaves() -> array<ref<DeviceComponentPS>> {
    let immediateSlaves: array<ref<DeviceComponentPS>>;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(entityID, immediateSlaves);
    return immediateSlaves;
  }

  public final func RefreshSlaves_Event() -> Void {
    let evt: ref<RefreshSlavesEvent> = new RefreshSlavesEvent();
    this.GetPersistencySystem().QueuePSEvent(this.GetID(), this.GetClassName(), evt);
  }

  protected final func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    this.RefreshSlaves();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func RefreshSlaves() -> Void {
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as SurveillanceCameraControllerPS) {
        if this.m_forceFollow {
          this.ExecutePSAction(this.ActionForceFollowTarget(), devices[i]);
        } else {
          this.ExecutePSAction(this.ActionStopFollowingTarget(), devices[i]);
        };
      };
      i = i + 1;
    };
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().IntercomBlackboard;
  }
}
