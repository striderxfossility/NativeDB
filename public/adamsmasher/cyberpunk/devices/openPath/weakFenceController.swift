
public class WeakFenceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class WeakFenceControllerPS extends ScriptableDeviceComponentPS {

  public inline let m_weakfenceSkillChecks: ref<EngDemoContainer>;

  protected persistent let m_weakFenceSetup: WeakFenceSetup;

  protected func LogicReady() -> Void {
    this.LogicReady();
    if !this.m_weakFenceSetup.m_hasGenericInteraction {
      this.InitializeSkillChecks(this.m_weakfenceSkillChecks);
    };
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if this.m_weakFenceSetup.m_hasGenericInteraction && !this.IsDisabled() {
      ArrayPush(actions, this.ActionActivateDevice("BreakWeakFence"));
    };
    return true;
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    action.ResetCaption();
    action.CreateInteraction(context.processInitiatorObject, "BreakWeakFence");
    return action;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.DisableDevice();
    this.OnActionEngineering(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionActivateDevice(interactionName: String) -> ref<ActivateDevice> {
    let action: ref<ActivateDevice> = new ActivateDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.CreateInteraction(interactionName);
    return action;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    this.DisableDevice();
    return EntityNotificationType.SendThisEventToEntity;
  }
}
