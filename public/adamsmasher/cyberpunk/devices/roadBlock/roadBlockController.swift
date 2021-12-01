
public class RoadBlockController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class RoadBlockControllerPS extends ScriptableDeviceComponentPS {

  protected persistent let m_isBlocking: Bool;

  protected edit let m_negateAnimState: Bool;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForBlocking: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForUnblocking: TweakDBID;

  public final const quest func IsBlocking() -> Bool {
    return this.m_isBlocking;
  }

  public final const quest func IsNotBlocking() -> Bool {
    return !this.m_isBlocking;
  }

  public final const func NegateAnim() -> Bool {
    return this.m_negateAnimState;
  }

  protected func GameAttached() -> Void {
    if this.m_isBlocking {
      this.m_activationState = EActivationState.ACTIVATED;
    } else {
      this.m_activationState = EActivationState.DEACTIVATED;
    };
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if ToggleBlockade.IsDefaultConditionMet(this, context) {
      if Equals(context.requestType, gamedeviceRequestType.External) {
        ArrayPush(actions, this.ActionToggleBlockade());
      };
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleBlockade();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetInactiveWithReason(ToggleBlockade.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceRoadBlockadeActivate());
    ArrayPush(actions, this.ActionQuestForceRoadBlockadeDeactivate());
  }

  protected func ActionToggleBlockade() -> ref<ToggleBlockade> {
    let action: ref<ToggleBlockade> = new ToggleBlockade();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsBlocking(), this.m_nameForBlocking, this.m_nameForUnblocking);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  protected func ActionQuickHackToggleBlockade() -> ref<QuickHackToggleBlockade> {
    let action: ref<QuickHackToggleBlockade> = new QuickHackToggleBlockade();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsBlocking(), this.m_nameForBlocking, this.m_nameForUnblocking);
    action.AddDeviceName(this.GetDeviceName());
    if this.IsBlocking() {
      action.CreateInteraction(this.m_nameForBlocking);
    } else {
      action.CreateInteraction(this.m_nameForUnblocking);
    };
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func ActionQuestForceRoadBlockadeActivate() -> ref<QuestForceRoadBlockadeActivate> {
    let action: ref<QuestForceRoadBlockadeActivate> = new QuestForceRoadBlockadeActivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionQuestForceRoadBlockadeDeactivate() -> ref<QuestForceRoadBlockadeDeactivate> {
    let action: ref<QuestForceRoadBlockadeDeactivate> = new QuestForceRoadBlockadeDeactivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnToggleBlockade(evt: ref<ToggleBlockade>) -> EntityNotificationType {
    this.m_isBlocking = this.IsBlocking() ? false : true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuickHackToggleBlockade(evt: ref<QuickHackToggleBlockade>) -> EntityNotificationType {
    this.m_isBlocking = this.IsBlocking() ? false : true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceRoadBlockadeActivate(evt: ref<QuestForceRoadBlockadeActivate>) -> EntityNotificationType {
    this.m_isBlocking = true;
    this.NotifyParents();
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnQuestForceRoadBlockadeDeactivate(evt: ref<QuestForceRoadBlockadeDeactivate>) -> EntityNotificationType {
    this.m_isBlocking = false;
    this.NotifyParents();
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.ACTIVATED) && this.IsON() {
      this.OnActivateDevice(evt);
      this.m_isBlocking = true;
      this.NotifyParents();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.DEACTIVATED) && this.IsON() {
      this.OnDeactivateDevice(evt);
      this.m_isBlocking = false;
      this.NotifyParents();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceBackground";
  }
}
