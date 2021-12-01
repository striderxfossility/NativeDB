
public class SlidingLadderController extends BaseAnimatedDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SlidingLadderControllerPS extends BaseAnimatedDeviceControllerPS {

  @default(SlidingLadderControllerPS, true)
  protected let m_isShootable: Bool;

  @default(SlidingLadderControllerPS, 1.0f)
  protected let m_animationTime: Float;

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if this.m_hasInteraction && this.IsNotActive() {
      ArrayPush(actions, this.ActionToggleActivate());
    } else {
      if this.IsActive() && EnterLadder.IsPlayerInAcceptableState(this, context) {
        ArrayPush(actions, this.ActionEnterLadder());
      };
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void;

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return false;
  }

  public final func SetActive() -> Void {
    this.m_activationState = EActivationState.ACTIVATED;
    this.m_isActive = true;
  }

  public final func IsShootable() -> Bool {
    return this.m_isShootable;
  }

  public final func GetAnimTime() -> Float {
    return this.m_animationTime;
  }

  protected final func ActionEnterLadder() -> ref<EnterLadder> {
    let action: ref<EnterLadder> = new EnterLadder();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnEnterLadder(evt: ref<EnterLadder>) -> EntityNotificationType {
    EnterLadder.PushOnEnterLadderEventToPSM(this.GetPlayerMainObject());
    return EntityNotificationType.SendThisEventToEntity;
  }
}
