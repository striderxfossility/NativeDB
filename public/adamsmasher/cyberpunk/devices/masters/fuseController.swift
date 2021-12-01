
public class FuseController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class FuseControllerPS extends MasterControllerPS {

  @attrib(category, "City Light System")
  protected inline persistent let m_timeTableSetup: ref<DeviceTimeTableManager>;

  @attrib(category, "City Light System")
  @default(FuseControllerPS, 5)
  protected persistent let m_maxLightsSwitchedAtOnce: Int32;

  @attrib(rangeMax, "1.0f")
  @attrib(category, "City Light System")
  @attrib(rangeMin, "0.0f")
  @default(FuseControllerPS, 1.0f)
  protected persistent let m_timeToNextSwitch: Float;

  @attrib(category, "City Light System")
  @default(FuseControllerPS, ELightSwitchRandomizerType.RANDOM_PROGRESSIVE)
  protected persistent let m_lightSwitchRandomizerType: ELightSwitchRandomizerType;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice")
  private let m_alternativeNameForON: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice")
  private let m_alternativeNameForOFF: TweakDBID;

  private let m_isCLSInitialized: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#116";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.InitializeCLS();
    if this.IsUnpowered() {
      this.RefreshPowerOnSlaves_Event();
    } else {
      if this.m_timeTableSetup == null || !this.m_timeTableSetup.IsValid() {
        this.RefreshSlaves_Event();
      };
    };
  }

  public const func GetExpectedSlaveState() -> EDeviceStatus {
    return this.GetDeviceState();
  }

  public final const func GetTimetableSetup() -> ref<DeviceTimeTableManager> {
    return this.m_timeTableSetup;
  }

  protected const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(29, 29);
  }

  public func ActionToggleON() -> ref<ToggleON> {
    let action: ref<ToggleON> = new ToggleON();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOnClearance();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState, this.m_alternativeNameForON, this.m_alternativeNameForOFF);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if this.IsDisabled() {
      return false;
    };
    if ToggleON.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(outActions, this.ActionToggleON());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func OnQuestForceON(evt: ref<QuestForceON>) -> EntityNotificationType {
    this.OnQuestForceON(evt);
    this.RefreshSlaves_Event(false, true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnQuestForceOFF(evt: ref<QuestForceOFF>) -> EntityNotificationType {
    this.OnQuestForceOFF(evt);
    this.RefreshSlaves_Event(false, true);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceON(evt: ref<SetDeviceON>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() || this.IsUnpowered() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.ON);
    this.RefreshSlaves_Event();
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceOFF(evt: ref<SetDeviceOFF>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() || this.IsUnpowered() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.SetDeviceState(EDeviceStatus.OFF);
    this.RefreshSlaves_Event();
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDeviceUnpowered(evt: ref<SetDeviceUnpowered>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    this.UnpowerDevice();
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnSetDevicePowered(evt: ref<SetDevicePowered>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled");
    };
    this.PowerDevice();
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnToggleON(evt: ref<ToggleON>) -> EntityNotificationType {
    this.OnToggleON(evt);
    this.RefreshSlaves_Event();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func PowerDevice() -> Void {
    let stateFromCLS: EDeviceStatus = EDeviceStatus.DISABLED;
    if this.IsConnectedToCLS() {
      stateFromCLS = this.GetCityLightSystem().GetFuseStateByID(this.GetID());
    };
    if NotEquals(stateFromCLS, EDeviceStatus.DISABLED) {
      this.SetDeviceState(stateFromCLS);
    } else {
      this.SetDeviceState(EDeviceStatus.ON);
    };
    this.RefreshPowerOnSlaves_Event();
  }

  public func UnpowerDevice() -> Void {
    this.UnpowerDevice();
    this.RefreshPowerOnSlaves_Event();
  }

  private final func RefreshSlaves(devices: array<ref<DeviceComponentPS>>, opt force: Bool) -> Void {
    let action: ref<DeviceAction>;
    let i: Int32;
    if this.IsUnpowered() {
      this.RefreshPowerOnSlaves(devices);
      return;
    };
    if this.IsConnectedToCLS() {
      this.RefreshCLSoNslaves(this.GetDeviceState(), false, devices);
      return;
    };
    devices = this.GetImmediateSlaves();
    i = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        if this.IsON() {
          if force {
            action = (devices[i] as ScriptableDeviceComponentPS).ActionQuestForceON();
          } else {
            action = (devices[i] as ScriptableDeviceComponentPS).ActionSetDeviceON();
          };
        } else {
          if force {
            action = (devices[i] as ScriptableDeviceComponentPS).ActionQuestForceOFF();
          } else {
            action = (devices[i] as ScriptableDeviceComponentPS).ActionSetDeviceOFF();
          };
        };
        if IsDefined(action) {
          (action as ScriptableDeviceAction).RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
          this.GetPersistencySystem().QueuePSDeviceEvent(action);
        };
      };
      i = i + 1;
    };
  }

  private final func RefreshPowerOnSlaves(devices: array<ref<DeviceComponentPS>>) -> Void {
    let restorePower: Bool;
    if this.IsConnectedToCLS() {
      restorePower = this.IsON();
      this.RefreshCLSoNslaves(this.GetDeviceState(), restorePower, devices);
      return;
    };
    if !this.IsON() {
      this.CutPowerOnSlaveDevices(devices);
    } else {
      this.RestorePowerOnSlaveDevices(devices);
    };
  }

  private final func RestorePowerOnSlaveDevices(devices: array<ref<DeviceComponentPS>>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let device: ref<ScriptableDeviceComponentPS>;
    devices = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        device = devices[i] as ScriptableDeviceComponentPS;
        if IsDefined(device) {
          action = device.ActionSetDevicePowered();
        };
        if IsDefined(action) {
          this.ExecutePSAction(action, device);
        };
      };
      i = i + 1;
    };
  }

  private final func CutPowerOnSlaveDevices(devices: array<ref<DeviceComponentPS>>) -> Void {
    let action: ref<ScriptableDeviceAction>;
    let device: ref<ScriptableDeviceComponentPS>;
    devices = this.GetImmediateSlaves();
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == this {
      } else {
        device = devices[i] as ScriptableDeviceComponentPS;
        if IsDefined(device) {
          action = device.ActionSetDeviceUnpowered();
        };
        if IsDefined(action) {
          this.ExecutePSAction(action, device);
        };
      };
      i = i + 1;
    };
  }

  protected func OnRefreshSlavesEvent(evt: ref<RefreshSlavesEvent>) -> EntityNotificationType {
    this.RefreshSlaves(evt.devices, evt.force);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnRefreshPowerOnSlavesEvent(evt: ref<RefreshPowerOnSlavesEvent>) -> EntityNotificationType {
    this.RefreshPowerOnSlaves(evt.devices);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func IsCLSInitialized() -> Bool {
    return this.m_isCLSInitialized;
  }

  protected final func OnInitializeCLSEvent(evt: ref<InitializeCLSEvent>) -> EntityNotificationType {
    this.InitializeCLS();
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnDeviceTimetableEvent(evt: ref<DeviceTimetableEvent>) -> EntityNotificationType {
    if Equals(evt.state, EDeviceStatus.ON) {
      this.ExecutePSAction(this.ActionSetDeviceON(), this);
    } else {
      if Equals(evt.state, EDeviceStatus.OFF) {
        this.ExecutePSAction(this.ActionSetDeviceOFF(), this);
      } else {
        if Equals(evt.state, EDeviceStatus.UNPOWERED) {
          this.ExecutePSAction(this.ActionSetDeviceUnpowered(), this);
        };
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func OnRefreshCLSoNslaves(evt: ref<RefreshCLSOnSlavesEvent>) -> EntityNotificationType {
    if NotEquals(evt.state, this.GetDeviceState()) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.RefreshCLSoNslaves(evt.state, evt.restorePower, evt.slaves);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func RefreshCLSoNslaves(state: EDeviceStatus, restorePower: Bool, devices: array<ref<DeviceComponentPS>>) -> Void {
    let delay: Float;
    let excessDevices: array<ref<DeviceComponentPS>>;
    let id: EntityID;
    let totalEventsSent: Int32;
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if devices[i] == null || !devices[i].IsAttachedToGame() {
      } else {
        if totalEventsSent >= this.m_maxLightsSwitchedAtOnce {
          ArrayPush(excessDevices, devices[i]);
        } else {
          id = PersistentID.ExtractEntityID(devices[i].GetID());
          if EntityID.IsDefined(id) {
            this.SendDeviceTimeTableEvent(id, state, restorePower);
            totalEventsSent += 1;
          };
        };
      };
      i += 1;
    };
    if ArraySize(excessDevices) > 0 {
      if Equals(this.m_lightSwitchRandomizerType, ELightSwitchRandomizerType.NONE) {
        delay = this.m_timeToNextSwitch;
      } else {
        if Equals(this.m_lightSwitchRandomizerType, ELightSwitchRandomizerType.RANDOM_PROGRESSIVE) {
          delay += this.GetLightSwitchDelayValue();
        } else {
          delay = this.GetLightSwitchDelayValue();
        };
      };
      this.SendCLSRefreshByEvent(excessDevices, state, restorePower, delay);
    };
  }

  private final func GetLightSwitchDelayValue() -> Float {
    let delay: Float;
    if this.m_timeToNextSwitch == 0.00 {
      delay = 0.00;
    } else {
      delay = RandRangeF(0.00, this.m_timeToNextSwitch);
    };
    return delay;
  }

  private final func SendCLSRefreshByEvent(devices: array<ref<DeviceComponentPS>>, state: EDeviceStatus, restorePower: Bool, delay: Float) -> Void {
    let evt: ref<RefreshCLSOnSlavesEvent> = new RefreshCLSOnSlavesEvent();
    evt.state = state;
    evt.slaves = devices;
    evt.restorePower = restorePower;
    if delay > 0.00 {
      this.QueuePSEventWithDelay(this, evt, delay);
    } else {
      this.QueuePSEvent(this, evt);
    };
  }

  private final func SendDeviceTimeTableEvent(targetID: EntityID, state: EDeviceStatus, restorePower: Bool) -> Void {
    let evt: ref<DeviceTimetableEvent> = new DeviceTimetableEvent();
    evt.state = state;
    evt.requesterID = PersistentID.ExtractEntityID(this.GetID());
    evt.restorePower = restorePower;
    this.GetPersistencySystem().QueueEntityEvent(targetID, evt);
  }

  private final func SendDeviceTimeTableEventWithDelay(targetID: EntityID, state: EDeviceStatus, restorePower: Bool, delay: Float) -> Void {
    let evt: ref<DeviceTimetableEvent> = new DeviceTimetableEvent();
    evt.state = state;
    evt.requesterID = PersistentID.ExtractEntityID(this.GetID());
    evt.restorePower = restorePower;
    this.QueuePSEventWithDelay(this, evt, delay);
  }

  protected final func OnDealyedTimetableEvent(evt: ref<DelayedTimetableEvent>) -> EntityNotificationType {
    let id: EntityID;
    if evt.eventToForward != null && evt.targetPS != null {
      if evt.targetPS.IsAttachedToGame() {
        id = PersistentID.ExtractEntityID(evt.targetPS.GetID());
        if EntityID.IsDefined(id) {
          this.GetPersistencySystem().QueueEntityEvent(id, evt);
        };
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func GetDeviceStateByCLS() -> EDeviceStatus {
    let cls: ref<CityLightSystem>;
    let clsState: ECLSForcedState;
    let deviceState: EDeviceStatus;
    if !this.IsDisabled() && !this.IsUnpowered() {
      deviceState = this.m_deviceState;
    } else {
      if this.IsConnectedToCLS() && !this.m_isCLSInitialized {
        cls = this.GetCityLightSystem();
        if IsDefined(cls) {
          clsState = cls.GetState();
          if Equals(clsState, ECLSForcedState.DEFAULT) {
            deviceState = this.m_timeTableSetup.GetDeviceStateForActiveEntry(this.GetGameInstance());
          } else {
            if Equals(clsState, ECLSForcedState.ForcedON) {
              deviceState = EDeviceStatus.ON;
            } else {
              if Equals(clsState, ECLSForcedState.ForcedOFF) {
                deviceState = EDeviceStatus.OFF;
              };
            };
          };
        } else {
          deviceState = this.m_deviceState;
        };
      } else {
        deviceState = this.m_deviceState;
      };
    };
    return deviceState;
  }

  private final func InitializeCLS() -> Void {
    let cls: ref<CityLightSystem>;
    let clsState: ECLSForcedState;
    let lights: array<ref<LazyDevice>>;
    let request: ref<RegisterTimetableRequest>;
    let requesterData: PSOwnerData;
    if this.m_isCLSInitialized {
      return;
    };
    this.m_isCLSInitialized = true;
    if this.m_timeTableSetup != null && this.m_timeTableSetup.IsValid() {
      request = new RegisterTimetableRequest();
      request.timeTable = this.m_timeTableSetup.GetTimeTable();
      requesterData.id = this.GetID();
      requesterData.className = this.GetClassName();
      request.requesterData = requesterData;
      if !IsFinal() {
        this.GetLazyChildren(lights);
        request.lights = ArraySize(lights);
      };
      cls = this.GetCityLightSystem();
      if IsDefined(cls) {
        cls.QueueRequest(request);
        clsState = cls.GetState();
      };
      if !this.IsDisabled() && !this.IsUnpowered() {
        if Equals(clsState, ECLSForcedState.DEFAULT) {
          this.SetDeviceState(this.m_timeTableSetup.GetDeviceStateForActiveEntry(this.GetGameInstance()));
        } else {
          if Equals(clsState, ECLSForcedState.ForcedON) {
            this.SetDeviceState(EDeviceStatus.ON);
          } else {
            if Equals(clsState, ECLSForcedState.ForcedOFF) {
              this.SetDeviceState(EDeviceStatus.OFF);
            };
          };
        };
      };
    };
  }

  public const func IsConnectedToCLS() -> Bool {
    return this.m_timeTableSetup != null && this.m_timeTableSetup.IsValid();
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.GeneratorDeviceBackground";
  }
}
