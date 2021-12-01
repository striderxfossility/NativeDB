
public class RetractableAdController extends BaseAnimatedDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class RetractableAdControllerPS extends BaseAnimatedDeviceControllerPS {

  protected let m_isControlled: Bool;

  public final const quest func IsConnected() -> Bool {
    return this.m_isControlled;
  }

  public final const quest func IsNotConnected() -> Bool {
    return !this.m_isControlled;
  }

  protected func GameAttached() -> Void {
    this.GameAttached();
    this.ControlledByMaster();
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleActivate();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, currentAction);
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    currentAction.SetInactiveWithReason(this.IsActive(), "LocKey#53172");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected final func ControlledByMaster() -> Void {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as RoadBlockTrapControllerPS) {
        this.m_isControlled = true;
      };
      i += 1;
    };
  }

  public final func GetTrapController() -> ref<RoadBlockTrapControllerPS> {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    let trap: ref<RoadBlockTrapControllerPS>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as RoadBlockTrapControllerPS) {
        trap = parents[i] as RoadBlockTrapControllerPS;
      };
      i += 1;
    };
    return trap;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }
}
