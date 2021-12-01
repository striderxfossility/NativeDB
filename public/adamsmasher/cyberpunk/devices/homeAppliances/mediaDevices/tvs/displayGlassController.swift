
public class DisplayGlassController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class DisplayGlassControllerPS extends ScriptableDeviceComponentPS {

  protected let m_isTinted: Bool;

  protected let m_useAppearances: Bool;

  protected let m_clearAppearance: CName;

  protected let m_tintedAppearance: CName;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func GameAttached() -> Void;

  public final const quest func IsTinted() -> Bool {
    return this.m_isTinted;
  }

  public final const func UsesAppearances() -> Bool {
    return this.m_useAppearances;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    if ToggleGlassTint.IsDefaultConditionMet(this, context) && Equals(context.requestType, gamedeviceRequestType.External) {
      ArrayPush(actions, this.ActionToggleGlassTint());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionToggleGlassTintHack();
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    currentAction.SetInactiveWithReason(ToggleGlassTint.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceTintGlass());
    ArrayPush(actions, this.ActionQuestForceClearGlass());
  }

  private final func ActionQuestForceTintGlass() -> ref<QuestForceTintGlass> {
    let action: ref<QuestForceTintGlass> = new QuestForceTintGlass();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceTintGlass(evt: ref<QuestForceTintGlass>) -> EntityNotificationType {
    this.m_isTinted = true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActionQuestForceClearGlass() -> ref<QuestForceClearGlass> {
    let action: ref<QuestForceClearGlass> = new QuestForceClearGlass();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceClearGlass(evt: ref<QuestForceClearGlass>) -> EntityNotificationType {
    this.m_isTinted = false;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnToggleGlassTint(evt: ref<ToggleGlassTint>) -> EntityNotificationType {
    this.m_isTinted = this.m_isTinted ? false : true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionToggleGlassTint() -> ref<ToggleGlassTint> {
    let action: ref<ToggleGlassTint> = new ToggleGlassTint();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isTinted);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleGlassTintHack(evt: ref<ToggleGlassTintHack>) -> EntityNotificationType {
    this.m_isTinted = this.m_isTinted ? false : true;
    this.NotifyParents();
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionToggleGlassTintHack() -> ref<ToggleGlassTintHack> {
    let action: ref<ToggleGlassTintHack> = new ToggleGlassTintHack();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isTinted);
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public final const func GetTintAppearance() -> CName {
    return this.m_tintedAppearance;
  }

  public final const func GetClearAppearance() -> CName {
    return this.m_clearAppearance;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }
}
