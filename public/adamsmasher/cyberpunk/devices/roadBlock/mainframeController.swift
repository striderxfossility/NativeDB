
public class MainframeController extends BaseAnimatedDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MainframeControllerPS extends BaseAnimatedDeviceControllerPS {

  protected let m_factName: ComputerQuickHackData;

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    this.ExecutePSActionWithDelay(this.ActionSetQuestFact(), this, 20.00);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionSetQuestFact() -> ref<FactQuickHack> {
    let action: ref<FactQuickHack> = new FactQuickHack();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.SetProperties(this.m_factName);
    return action;
  }

  public final func OnSetQuestFact(evt: ref<FactQuickHack>) -> EntityNotificationType {
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
