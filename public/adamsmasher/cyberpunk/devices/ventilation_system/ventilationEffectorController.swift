
public class ToggleEffect extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ToggleEffect";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ToggleEffect", true, n"LocKey#17809", n"LocKey#17809");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class VentilationEffectorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class VentilationEffectorControllerPS extends ActivatedDeviceControllerPS {

  private final func ActionToggleEffect() -> ref<ToggleEffect> {
    let action: ref<ToggleEffect> = new ToggleEffect();
    action.clearanceLevel = 1;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    ArrayPush(actions, this.ActionToggleEffect());
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnToggleEffect(evt: ref<ToggleEffect>) -> EntityNotificationType {
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

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.VentilationDeviceBackground";
  }
}
