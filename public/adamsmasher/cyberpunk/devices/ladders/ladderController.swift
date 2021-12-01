
public class LadderController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class LadderControllerPS extends ScriptableDeviceComponentPS {

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if EnterLadder.IsPlayerInAcceptableState(this, context) {
      ArrayPush(actions, this.ActionEnterLadder());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
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
