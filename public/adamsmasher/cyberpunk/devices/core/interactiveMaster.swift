
public class InteractiveMasterDevice extends InteractiveDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().MasterDeviceBaseBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected cb func OnSlaveStateChanged(evt: ref<PSDeviceChangedEvent>) -> Bool {
    this.m_isUIdirty = true;
    super.OnSlaveStateChanged(evt);
  }

  protected cb func OnRequestSlaveThumbnailWidgetsUpdate(evt: ref<RequestThumbnailWidgetsUpdateEvent>) -> Bool {
    this.RequestThumbnailWidgetsUpdate(this.GetBlackboard());
  }

  public const func GetDefaultGlitchVideoPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  public const func GetBroadcastGlitchVideoPath() -> ResRef {
    return r"base\\movies\\misc\\distraction_generic.bk2";
  }

  protected cb func OnDeviceWidgetUpdate(evt: ref<RequestDeviceWidgetUpdateEvent>) -> Bool {
    if PersistentID.IsDefined(evt.requester) {
      this.RequestDeviceWidgetsUpdate(this.GetBlackboard(), evt.requester);
    } else {
      this.RequestDeviceWidgetsUpdate(this.GetBlackboard());
    };
  }

  protected cb func OnRequestSlaveDevicesWidgetsUpdate(evt: ref<RequestDeviceWidgetsUpdateEvent>) -> Bool {
    this.RequestDeviceWidgetsUpdate(this.GetBlackboard(), evt.requesters);
  }

  protected func RequestThumbnailWidgetsUpdate(blackboard: ref<IBlackboard>) -> Void {
    (this.GetDevicePS() as MasterControllerPS).RequestThumbnailWidgetsUpdate(blackboard);
  }

  protected final func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>, devices: array<PersistentID>) -> Void {
    (this.GetDevicePS() as MasterControllerPS).RequestDeviceWidgetsUpdate(blackboard, devices);
  }

  protected final func RequestDeviceWidgetsUpdate(blackboard: ref<IBlackboard>, deviceID: PersistentID) -> Void {
    (this.GetDevicePS() as MasterControllerPS).RequestDeviceWidgetsUpdate(blackboard, deviceID);
  }

  public const func ShouldShowTerminalTitle() -> Bool {
    return false;
  }

  protected func NotifyConnectionHighlightSystem(IsHighlightON: Bool, IsHighlightedByMasterDevice: Bool) -> Bool {
    let highlightEvent: ref<NotifyHighlightedDevice>;
    let i: Int32;
    let slaveDevices: array<ref<DeviceComponentPS>>;
    if !this.NotifyConnectionHighlightSystem(IsHighlightON, IsHighlightedByMasterDevice) {
      return false;
    };
    slaveDevices = (this.GetDevicePS() as MasterControllerPS).GetImmediateSlaves();
    highlightEvent = new NotifyHighlightedDevice();
    highlightEvent.IsDeviceHighlighted = IsHighlightON;
    highlightEvent.IsNotifiedByMasterDevice = true;
    i = 0;
    while i < ArraySize(slaveDevices) {
      GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(slaveDevices[i].GetID(), slaveDevices[i].GetClassName(), highlightEvent);
      i += 1;
    };
    return true;
  }

  protected cb func OnSetAsQuestImportantEvent(evt: ref<SetAsQuestImportantEvent>) -> Bool {
    super.OnSetAsQuestImportantEvent(evt);
    if evt.PropagateToSlaves() {
      (this.GetDevicePS() as MasterControllerPS).SetSlavesAsQuestImportant(evt.IsImportant());
    };
  }

  protected cb func OnPerformedAction(evt: ref<PerformedAction>) -> Bool {
    let authOffAction: ref<SetAuthorizationModuleOFF>;
    let skillcheckAction: ref<ActionSkillCheck>;
    super.OnPerformedAction(evt);
    skillcheckAction = evt.m_action as ActionSkillCheck;
    authOffAction = evt.m_action as SetAuthorizationModuleOFF;
    if IsDefined(authOffAction) {
      this.SucceedGameplayObjective(this.GetDevicePS().GetControlPanelObjectiveData());
    };
    if IsDefined(skillcheckAction) {
      if skillcheckAction.IsCompleted() {
        this.SucceedGameplayObjective(this.GetDevicePS().GetControlPanelObjectiveData());
      };
    };
  }
}
