
public class BasicDistractionDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class BasicDistractionDeviceControllerPS extends ScriptableDeviceComponentPS {

  @attrib(category, "Distraction properties")
  @default(BasicDistractionDeviceControllerPS, EPlaystyleType.NETRUNNER)
  protected edit let m_distractorType: EPlaystyleType;

  protected inline let m_basicDistractionDeviceSkillChecks: ref<EngDemoContainer>;

  @attrib(category, "Distraction properties")
  protected edit const let m_effectOnSartNames: array<CName>;

  @attrib(category, "Distraction properties")
  @default(BasicDistractionDeviceControllerPS, EAnimationType.TRANSFORM)
  protected edit let m_animationType: EAnimationType;

  @attrib(category, "Tech design")
  protected edit let m_forceAnimationSystem: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_basicDistractionDeviceSkillChecks);
  }

  public final const func GetAnimationType() -> EAnimationType {
    return this.m_animationType;
  }

  public final const func GetForceAnimationSystem() -> Bool {
    return this.m_forceAnimationSystem;
  }

  public final const func GetEffectOnStartNames() -> array<CName> {
    return this.m_effectOnSartNames;
  }

  protected func ActionQuickHackDistraction() -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = new QuickHackDistraction();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    action.SetDurationValue(this.GetDistractionDuration(action));
    action.CreateInteraction();
    return action;
  }

  protected final func ActionSpiderbotDistractDevice() -> ref<SpiderbotDistractDevice> {
    let action: ref<SpiderbotDistractDevice> = new SpiderbotDistractDevice();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  protected final func ActionSpiderbotDistractDevicePerformed() -> ref<SpiderbotDistractDevicePerformed> {
    let action: ref<SpiderbotDistractDevicePerformed> = new SpiderbotDistractDevicePerformed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetSpiderbotClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func CanCreateAnySpiderbotActions() -> Bool {
    if Equals(this.m_distractorType, EPlaystyleType.TECHIE) {
      return true;
    };
    return false;
  }

  protected func GetSpiderbotActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    if Equals(this.m_distractorType, EPlaystyleType.NETRUNNER) {
      return;
    };
    if !this.IsDistracting() {
      ArrayPush(actions, this.ActionSpiderbotDistractDevice());
    };
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    if Equals(this.m_distractorType, EPlaystyleType.NETRUNNER) {
      return true;
    };
    return false;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    this.GetQuickHackActions(actions, context);
    if Equals(this.m_distractorType, EPlaystyleType.TECHIE) || Equals(this.m_distractorType, EPlaystyleType.NONE) {
      return;
    };
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final func OnSpiderbotDistractExplosiveDevice(evt: ref<SpiderbotDistractDevice>) -> EntityNotificationType {
    this.m_distractExecuted = true;
    let action: ref<ScriptableDeviceAction> = this.ActionSpiderbotDistractDevicePerformed();
    action.SetDurationValue(this.GetDistractionDuration(action));
    this.SendSpiderbotToPerformAction(action, evt.GetExecutor());
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnSpiderbotDistractExplosiveDevicePerformed(evt: ref<SpiderbotDistractDevicePerformed>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if evt.IsStarted() {
      this.m_distractExecuted = true;
      evt.SetCanTriggerStim(true);
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      this.m_distractExecuted = false;
      evt.SetCanTriggerStim(false);
    };
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }
}

public class SpiderbotDistractDevice extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDistractDevice";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#596", n"LocKey#596");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "SpiderbotDistraction";
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
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

public class SpiderbotDistractDevicePerformed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SpiderbotDistractDevicePerformed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"SpiderbotDistractDevicePerformed", n"SpiderbotDistractDevicePerformed");
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
