
public class ChestPressController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class ChestPressControllerPS extends ScriptableDeviceComponentPS {

  protected inline let m_chestPressSkillChecks: ref<EngDemoContainer>;

  private let m_factOnQHack: CName;

  private let m_wasWeighHacked: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_chestPressSkillChecks);
  }

  public final func PushPersistentData() -> Void {
    if this.IsInitialized() {
      return;
    };
  }

  public final func GetFactOnQHack() -> CName {
    return this.m_factOnQHack;
  }

  protected final func ActionChestPressWeightHack() -> ref<ChestPressWeightHack> {
    let action: ref<ChestPressWeightHack> = new ChestPressWeightHack();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func ActionE3Hack_QuestPlayAnimationWeightLift() -> ref<E3Hack_QuestPlayAnimationWeightLift> {
    let action: ref<E3Hack_QuestPlayAnimationWeightLift> = new E3Hack_QuestPlayAnimationWeightLift();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected final func ActionE3Hack_QuestPlayAnimationKillNPC() -> ref<E3Hack_QuestPlayAnimationKillNPC> {
    let action: ref<E3Hack_QuestPlayAnimationKillNPC> = new E3Hack_QuestPlayAnimationKillNPC();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionChestPressWeightHack();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    currentAction.SetInactiveWithReason(!this.m_wasWeighHacked, "LocKey#7004");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
    ArrayPush(outActions, this.ActionE3Hack_QuestPlayAnimationWeightLift());
    ArrayPush(outActions, this.ActionE3Hack_QuestPlayAnimationKillNPC());
  }

  private final func OnChestPressWeightHack(evt: ref<ChestPressWeightHack>) -> EntityNotificationType {
    this.m_wasWeighHacked = true;
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnE3Hack_QuestPlayAnimationWeightLift(evt: ref<E3Hack_QuestPlayAnimationWeightLift>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func OnE3Hack_QuestPlayAnimationKillNPC(evt: ref<E3Hack_QuestPlayAnimationKillNPC>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }
}

public class ChestPressWeightHack extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ChestPressWeightHack";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#600", n"LocKey#600");
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.DistractIcon");
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return true;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return true;
  }
}

public class E3Hack_QuestPlayAnimationWeightLift extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"E3Hack_QuestPlayAnimationWeightLift";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"E3Hack_QuestPlayAnimationWeightLift", n"E3Hack_QuestPlayAnimationWeightLift");
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return true;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return true;
  }
}

public class E3Hack_QuestPlayAnimationKillNPC extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"E3Hack_QuestPlayAnimationKillNPC";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"E3Hack_QuestPlayAnimationKillNPC", n"E3Hack_QuestPlayAnimationKillNPC");
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return true;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return true;
  }
}
