
public class ToggleAOEEffect extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ToggleAOEEffect";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleAOEEffect", true, n"LocKey#17809", n"LocKey#17809");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class AOEEffectorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class AOEEffectorControllerPS extends ActivatedDeviceControllerPS {

  protected persistent const let m_effectsToPlay: array<CName>;

  private final func ActionToggleAOEEffect() -> ref<ToggleAOEEffect> {
    let action: ref<ToggleAOEEffect> = new ToggleAOEEffect();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func GetEffectsToPlay() -> array<CName> {
    return this.m_effectsToPlay;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    ArrayPush(actions, this.ActionToggleAOEEffect());
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnToggleAOEEffect(evt: ref<ToggleAOEEffect>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if this.IsON() {
      this.SetDeviceState(EDeviceStatus.OFF);
    } else {
      this.SetDeviceState(EDeviceStatus.ON);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }
}
