
public class SpiderbotActivateActivator extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotActivateActivator";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#388", n"LocKey#388");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotActivateActivator";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if !AIActionHelper.CheckFlatheadStatPoolRequirements(device.GetGameInstance(), "DeviceAction") {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return true;
    };
    return false;
  }
}

public class ActivatorController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ActivatorControllerPS extends MasterControllerPS {

  @attrib(category, "AvailableInteractions")
  @default(ActivatorControllerPS, false)
  private let m_hasSpiderbotInteraction: Bool;

  @attrib(category, "AvailableInteractions")
  private let m_spiderbotInteractionLocationOverride: NodeRef;

  @attrib(category, "AvailableInteractions")
  @default(ActivatorControllerPS, true)
  private let m_hasSimpleInteraction: Bool;

  @attrib(category, "InteractionNamesSetup")
  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  private let m_alternativeInteractionName: TweakDBID;

  @attrib(category, "InteractionNamesSetup")
  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  private let m_alternativeSpiderbotInteractionName: TweakDBID;

  @attrib(category, "InteractionNamesSetup")
  @attrib(customEditor, "TweakDBGroupInheritance;Interactions.InteractionChoice;Interactions.MountChoice")
  private let m_alternativeQuickHackName: TweakDBID;

  private inline let m_activatorSkillChecks: ref<GenericContainer>;

  @default(ActivatorControllerPS, ToggleActivate)
  private let m_alternativeInteractionString: String;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_activatorSkillChecks);
  }

  public func GetActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(outActions, context);
    if this.m_hasSimpleInteraction {
      ArrayPush(outActions, this.ActionToggleActivation(this.m_alternativeInteractionName));
    };
    this.SetActionIllegality(outActions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionToggleActivation(this.m_alternativeQuickHackName);
    currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    if this.m_hasSpiderbotInteraction && this.IsPowered() {
      return true;
    };
    return false;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if this.m_hasSpiderbotInteraction && this.IsPowered() && GameInstance.GetStatsSystem(this.GetGameInstance()).GetStatBoolValue(Cast(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetEntityID()), gamedataStatType.HasSpiderBotControl) {
      if AIActionHelper.CheckFlatheadStatPoolRequirements(this.GetGameInstance(), "DeviceAction") {
        ArrayPush(actions, this.ActionSpiderbotActivateActivator(this.m_alternativeSpiderbotInteractionName));
      };
    };
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceActivate());
  }

  public final func GetSpiderbotInteractionLocationOverride() -> NodeRef {
    return this.m_spiderbotInteractionLocationOverride;
  }

  public final func ActivateConnectedDevices() -> Void {
    let activateAction: ref<ActivateDevice>;
    let devices: array<ref<DeviceComponentPS>> = this.GetImmediateSlaves();
    this.m_hasSpiderbotInteraction = false;
    let i: Int32 = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as VentilationAreaControllerPS) {
        this.ExtractActionFromSlave(devices[i], n"ActivateDevice", activateAction);
      } else {
        if IsDefined(devices[i] as AOEAreaControllerPS) {
          this.ExtractActionFromSlave(devices[i], n"ActivateDevice", activateAction);
        } else {
          activateAction = this.ActionActivateDevice();
        };
      };
      if IsDefined(activateAction) {
        this.ExecutePSAction(activateAction, devices[i]);
      };
      i += 1;
    };
  }

  protected func ActionEngineering(context: GetActionsContext) -> ref<ActionEngineering> {
    let additionalActions: array<ref<DeviceAction>>;
    let action: ref<ActionEngineering> = this.ActionEngineering(context);
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetAvailableOnUnpowered();
    action.CreateInteraction(context.processInitiatorObject, additionalActions);
    return action;
  }

  protected func ActionDemolition(context: GetActionsContext) -> ref<ActionDemolition> {
    let action: ref<ActionDemolition>;
    let additionalActions: array<ref<DeviceAction>>;
    ArrayPush(additionalActions, this.ActionToggleActivation());
    action = this.ActionDemolition(context);
    action.SetAvailableOnUnpowered();
    action.CreateInteraction(context.processInitiatorObject, additionalActions);
    return action;
  }

  public func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      this.DisableDevice();
      this.ActivateConnectedDevices();
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ResolveActionHackingCompleted(evt: ref<ActionHacking>) -> Void {
    this.ResolveActionHackingCompleted(evt);
    if NotEquals(evt.GetAttributeCheckType(), EDeviceChallengeSkill.Invalid) {
      this.DisableDevice();
      this.ActivateConnectedDevices();
    };
  }

  protected final func ActionToggleActivation(interactionTDBID: TweakDBID) -> ref<ToggleActivation> {
    let action: ref<ToggleActivation> = new ToggleActivation();
    action.SetUp(this);
    action.SetProperties(this.m_deviceState);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(this.m_alternativeInteractionString, interactionTDBID);
    return action;
  }

  protected final func ActionSpiderbotActivateActivator(interactionTDBID: TweakDBID) -> ref<SpiderbotActivateActivator> {
    let action: ref<SpiderbotActivateActivator> = new SpiderbotActivateActivator();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(interactionTDBID);
    return action;
  }

  public final func OnSpiderbotActivateActivator(evt: ref<SpiderbotActivateActivator>) -> EntityNotificationType {
    this.m_isSpiderbotInteractionOrdered = true;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> EntityNotificationType {
    this.DisableDevice();
    return this.OnDisassembleDevice(evt);
  }

  public func OnToggleActivation(evt: ref<ToggleActivation>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if this.IsEnabled() {
      this.DisableDevice();
      this.ActivateConnectedDevices();
      this.m_hasSpiderbotInteraction = false;
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func OnQuestForceActivate(evt: ref<QuestForceActivate>) -> EntityNotificationType {
    this.UseNotifier(evt);
    if this.IsEnabled() {
      this.DisableDevice();
      this.ActivateConnectedDevices();
      this.m_hasSpiderbotInteraction = false;
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }
}
