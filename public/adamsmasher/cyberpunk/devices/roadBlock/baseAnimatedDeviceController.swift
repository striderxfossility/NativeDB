
public class BaseAnimatedDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class BaseAnimatedDeviceControllerPS extends ScriptableDeviceComponentPS {

  protected persistent let m_isActive: Bool;

  protected let m_hasInteraction: Bool;

  protected let m_randomizeAnimationTime: Bool;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForActivation: TweakDBID;

  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  protected let m_nameForDeactivation: TweakDBID;

  public final const quest func IsActive() -> Bool {
    return this.m_isActive;
  }

  public final const quest func IsNotActive() -> Bool {
    return !this.m_isActive;
  }

  public final const func Randomize() -> Bool {
    return this.m_randomizeAnimationTime;
  }

  protected func GameAttached() -> Void {
    if this.m_isActive {
      this.m_activationState = EActivationState.ACTIVATED;
    } else {
      this.m_activationState = EActivationState.DEACTIVATED;
    };
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if this.m_hasInteraction || Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionToggleActivate());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackToggleActivate();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceActivate());
    ArrayPush(actions, this.ActionQuestForceDeactivate());
  }

  protected func ActionToggleActivate() -> ref<ToggleActivate> {
    let action: ref<ToggleActivate> = new ToggleActivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsActive(), this.m_nameForActivation, this.m_nameForDeactivation);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  protected func ActionQuickHackToggleActivate() -> ref<QuickHackToggleActivate> {
    let action: ref<QuickHackToggleActivate> = new QuickHackToggleActivate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsActive(), this.m_nameForActivation, this.m_nameForDeactivation);
    action.AddDeviceName(this.GetDeviceName());
    if this.IsActive() {
      action.CreateInteraction(this.m_nameForActivation);
    } else {
      action.CreateInteraction(this.m_nameForDeactivation);
    };
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnToggleActivate(evt: ref<ToggleActivate>) -> EntityNotificationType {
    this.OnToggleActivate(evt);
    this.m_isActive = this.IsActive() ? false : true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnQuickHackToggleActivate(evt: ref<QuickHackToggleActivate>) -> EntityNotificationType {
    this.m_isActive = this.IsActive() ? false : true;
    this.m_activationState = this.IsActive() ? EActivationState.ACTIVATED : EActivationState.DEACTIVATED;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.ACTIVATED) && this.IsON() {
      this.OnActivateDevice(evt);
      this.m_isActive = true;
      this.NotifyParents();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnDeactivateDevice(evt: ref<DeactivateDevice>) -> EntityNotificationType {
    if NotEquals(this.m_activationState, EActivationState.DEACTIVATED) && this.IsON() {
      this.OnDeactivateDevice(evt);
      this.m_isActive = false;
      this.NotifyParents();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
