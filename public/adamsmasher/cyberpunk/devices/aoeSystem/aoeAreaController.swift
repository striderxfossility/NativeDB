
public class AOEAreaController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class AOEAreaControllerPS extends MasterControllerPS {

  private persistent let m_AOEAreaSetup: AOEAreaSetup;

  public final func GetActionName() -> CName {
    return StringToName(TweakDBInterface.GetInteractionBaseRecord(this.m_AOEAreaSetup.m_actionName).Name());
  }

  public final func GetAreaEffect() -> TweakDBID {
    return this.m_AOEAreaSetup.m_areaEffect;
  }

  public final func GetEffectDuration() -> Float {
    return this.m_AOEAreaSetup.m_duration;
  }

  public final func BlocksVisibility() -> Bool {
    return this.m_AOEAreaSetup.m_blocksVisibility;
  }

  public final func IsDangerous() -> Bool {
    return this.m_AOEAreaSetup.m_isDangerous;
  }

  public final func EffectsOnlyActiveInArea() -> Bool {
    return this.m_AOEAreaSetup.m_effectsOnlyActiveInArea;
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    ArrayPush(outActions, this.ActionActivateDevice());
    ArrayPush(outActions, this.ActionDeactivateDevice());
    this.GetQuestActions(outActions, context);
  }

  protected func ActionDeactivateDevice() -> ref<DeactivateDevice> {
    let action: ref<DeactivateDevice> = this.ActionDeactivateDevice();
    action.SetProperties(n"DeactivateDevice");
    if TDBID.IsValid(this.m_AOEAreaSetup.m_actionWidgetRecord) {
      action.CreateActionWidgetPackage(this.m_AOEAreaSetup.m_actionWidgetRecord);
    } else {
      action.CreateActionWidgetPackage(t"DevicesUIDefinitions.VentilationSystemActionWidget");
    };
    return action;
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if !this.IsAreaActive() {
      ArrayPush(outActions, this.ActionActivateDevice());
    } else {
      ArrayPush(outActions, this.ActionDeactivateDevice());
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return false;
  }

  protected func GameAttached() -> Void {
    let activateAction: ref<ActivateDevice>;
    if this.m_AOEAreaSetup.m_activateOnStartup {
      activateAction = this.ActionActivateDevice();
      this.GetPersistencySystem().QueuePSDeviceEvent(activateAction);
    };
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    this.ToggleEffectors();
    if this.m_AOEAreaSetup.m_duration >= 0.00 {
      this.QueueDeactivateAction(this.m_AOEAreaSetup.m_duration);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnActionForceResetDevice(evt: ref<ActionForceResetDevice>) -> EntityNotificationType {
    this.GetPersistencySystem().QueuePSDeviceEvent(this.ActionActivateDevice());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func QueueDeactivateAction(delayTime: Float) -> Void {
    let deactivateAction: ref<DeactivateDevice> = this.ActionDeactivateDevice();
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayPSEvent(this.GetID(), n"AOEAreaControllerPS", deactivateAction, delayTime);
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    this.OnDeactivateDevice(evt);
    this.ToggleEffectors();
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ToggleEffectors() -> Void {
    let action: ref<ToggleAOEEffect>;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let entityID: EntityID = PersistentID.ExtractEntityID(this.GetID());
    GameInstance.GetDeviceSystem(this.GetGameInstance()).GetChildren(entityID, devices);
    i = 0;
    while i < ArraySize(devices) {
      action = (devices[i] as ScriptableDeviceComponentPS).GetActionByName(n"ToggleAOEEffect") as ToggleAOEEffect;
      if IsDefined(action) {
        this.GetPersistencySystem().QueuePSDeviceEvent(action);
      };
      i += 1;
    };
  }

  public final const quest func IsAreaActive() -> Bool {
    return Equals(this.GetActivationState(), EActivationState.ACTIVATED);
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if TDBID.IsValid(this.m_AOEAreaSetup.m_deviceWidgetRecord) {
      return this.m_AOEAreaSetup.m_deviceWidgetRecord;
    };
    return t"DevicesUIDefinitions.VentilationSystemDeviceWidget";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceIcon";
  }
}
