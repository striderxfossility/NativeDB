
public class GameplayLightController extends ElectricLightController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class GameplayLightControllerPS extends ElectricLightControllerPS {

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleON();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetInactiveWithReason(ToggleON.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(actions, currentAction);
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    if !ScriptableDeviceAction.IsDefaultConditionMet(this, context) {
      currentAction.SetInactiveWithReason(false, "LocKey#7003");
    };
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }
}
