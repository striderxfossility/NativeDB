
public class MoveObstacle extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"MoveObstacle";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"MoveObstacle", true, n"MoveObstacle", n"MoveObstacle");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    return true;
  }
}

public class MovableDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class MovableDeviceControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_MovableDeviceSetup: MovableDeviceSetup;

  protected inline let m_movableDeviceSkillChecks: ref<DemolitionContainer>;

  public final func GetActionName() -> String {
    return TDBID.ToStringDEBUG(this.m_movableDeviceSkillChecks.m_demolitionCheck.m_alternativeName);
  }

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_movableDeviceSkillChecks);
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let shouldGetAction: Bool = true;
    if this.m_MovableDeviceSetup.m_numberOfUses <= 0 {
      shouldGetAction = false;
    };
    if shouldGetAction {
      if Equals(this.m_movableDeviceSkillChecks.m_demolitionCheck.GetDifficulty(), EGameplayChallengeLevel.NONE) {
        ArrayPush(actions, this.ActionMoveObstacle(this.m_movableDeviceSkillChecks.m_demolitionCheck.m_alternativeName));
      } else {
        ArrayPush(actions, this.ActionDemolition(context));
      };
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func ActionMoveObstacle(interactionTweak: TweakDBID) -> ref<MoveObstacle> {
    let action: ref<MoveObstacle> = new MoveObstacle();
    action.clearanceLevel = 2;
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTweak);
    return action;
  }

  public final func OnActionMoveObstacle(evt: ref<MoveObstacle>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.m_MovableDeviceSetup.m_numberOfUses = this.m_MovableDeviceSetup.m_numberOfUses - 1;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.m_MovableDeviceSetup.m_numberOfUses = this.m_MovableDeviceSetup.m_numberOfUses - 1;
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func WasDeviceMoved() -> Bool {
    if this.m_MovableDeviceSetup.m_numberOfUses == 0 {
      return true;
    };
    return false;
  }
}
