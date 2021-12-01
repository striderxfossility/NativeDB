
public class DoorController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SetDoorType extends Event {

  public edit let doorTypeSideOne: EDoorType;

  public edit let doorTypeSideTwo: EDoorType;

  public final func GetFriendlyDescription() -> String {
    return "Set Door Type";
  }
}

public class SetCloseItself extends Event {

  public edit let automaticallyClosesItself: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Automatically Closes Itself";
  }
}

public class ResetDoorState extends Event {

  public final func GetFriendlyDescription() -> String {
    return "Reset Door To Default";
  }
}

public class DoorControllerPS extends ScriptableDeviceComponentPS {

  protected persistent let m_doorProperties: DoorSetup;

  private inline let m_doorSkillChecks: ref<EngDemoContainer>;

  protected persistent let m_isOpened: Bool;

  protected persistent let m_isLocked: Bool;

  protected persistent let m_isSealed: Bool;

  protected let m_alarmRaised: Bool;

  protected let m_isBusy: Bool;

  protected let m_isLiftDoor: Bool;

  protected persistent let m_isPlayerAuthorised: Bool;

  protected persistent let m_openingTokens: array<EntityID>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Door";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.SetDefaultDoorState();
    this.InitializeDoorTypes();
  }

  protected func GameAttached() -> Void {
    this.m_isLiftDoor = this.CheckIfLiftDoors();
  }

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_doorSkillChecks);
  }

  public const func IsStatic() -> Bool {
    if this.IsSealed() && !this.canPlayerToggleSealState() {
      return true;
    };
    if this.IsLocked() && !this.IsAuthorizationValid() && !this.canPlayerToggleLockState() && !this.HasAnySkillCheckActive() && !this.CanCreateAnyQuickHackActions() {
      return true;
    };
    return false;
  }

  public final const func IsClosingAutomatically() -> Bool {
    return this.m_doorProperties.m_automaticallyClosesItself;
  }

  public final const func GetOpeningTokensList() -> array<EntityID> {
    return this.m_openingTokens;
  }

  public final const quest func IsOpen() -> Bool {
    return this.m_isOpened;
  }

  public final const func IsLogicallyClosed() -> Bool {
    return !this.m_isOpened && !this.m_isLocked && !this.m_isSealed;
  }

  public final const quest func IsClosed() -> Bool {
    return !this.m_isOpened;
  }

  public final const quest func IsLocked() -> Bool {
    return this.m_isLocked;
  }

  public final const quest func IsUnlocked() -> Bool {
    return !this.m_isLocked;
  }

  public final const quest func IsSealed() -> Bool {
    return this.m_isSealed;
  }

  public final const func canPlayerToggleLockState() -> Bool {
    return this.m_doorProperties.m_canPlayerToggleLockState;
  }

  public final const func canPlayerToggleSealState() -> Bool {
    return this.m_doorProperties.m_canPlayerToggleSealState;
  }

  public final const func GetDoorType() -> EDoorType {
    return this.m_doorProperties.m_doorType;
  }

  public final const func GetDoorTypeSideTwo() -> EDoorType {
    return this.m_doorProperties.m_doorTypeSideTwo;
  }

  public final const func GetDoorTypeSideOne() -> EDoorType {
    return this.m_doorProperties.m_doorTypeSideOne;
  }

  public final const func GetDoorSkillcheckSide() -> EDoorSkillcheckSide {
    return this.m_doorProperties.m_skillCheckSide;
  }

  public final const func GetDoorAuthorizationSide() -> EDoorSkillcheckSide {
    return this.m_doorProperties.m_authorizationSide;
  }

  public final const func GetDoorTriggerSide() -> EDoorTriggerSide {
    return this.m_doorProperties.m_doorTriggerSide;
  }

  public final const func GetOpeningSpeed() -> Float {
    return this.m_doorProperties.m_openingSpeed;
  }

  public final const func GetOpeningTime() -> Float {
    return this.m_doorProperties.m_doorOpeningTime;
  }

  public final const func GetStimRange() -> Float {
    return this.m_doorProperties.m_doorOpeningStimRange;
  }

  public final const func IsShutter() -> Bool {
    return this.m_doorProperties.m_isShutter;
  }

  public final const func IsLiftDoor() -> Bool {
    return this.m_isLiftDoor;
  }

  public final const func IsBusy() -> Bool {
    return this.m_isBusy;
  }

  public final const func GetPaymentRecordID() -> TweakDBID {
    return this.m_doorProperties.m_paymentRecordID;
  }

  public final const func GetPaymentRecord() -> ref<ActionPayment_Record> {
    return TweakDBInterface.GetActionPaymentRecord(this.GetPaymentRecordID());
  }

  public final const func CanPayToUnlock() -> Bool {
    return this.m_doorProperties.m_canPayToUnlock;
  }

  public final const func ExposeQuickHakcsIfNotConnnectedToAP() -> Bool {
    return this.m_doorProperties.m_exposeQuickHacksIfNotConnectedToAP;
  }

  public final const func GetDoorState() -> EDoorStatus {
    if this.m_isOpened {
      return EDoorStatus.OPENED;
    };
    if this.m_isLocked {
      return EDoorStatus.LOCKED;
    };
    if this.m_isSealed {
      return EDoorStatus.SEALED;
    };
    return EDoorStatus.CLOSED;
  }

  public final const func IsSideOneActive() -> Bool {
    if NotEquals(this.GetDoorSkillcheckSide(), EDoorSkillcheckSide.TWO) {
      return true;
    };
    return false;
  }

  public final const func IsSideTwoActive() -> Bool {
    if NotEquals(this.GetDoorSkillcheckSide(), EDoorSkillcheckSide.ONE) {
      return true;
    };
    return false;
  }

  public const func GetDeviceStatusAction() -> ref<BaseDeviceStatus> {
    return this.ActionDoorStatus();
  }

  public final func SetNewDoorType(type: EDoorType) -> Void {
    this.m_doorProperties.m_doorType = type;
  }

  public final func SetTriggerSide(side: EDoorTriggerSide) -> Void {
    this.m_doorProperties.m_doorTriggerSide = side;
  }

  public final func SetIsLocked(isLokced: Bool) -> Void {
    this.m_isLocked = isLokced;
  }

  public final func SetIsBusy(isBusy: Bool) -> Void {
    this.m_isBusy = isBusy;
  }

  private final func InitializeDoorTypes() -> Void {
    this.m_doorProperties.m_doorTypeSideOne = this.m_doorProperties.m_doorType;
    if Equals(this.m_doorProperties.m_doorTypeSideTwo, EDoorType.NONE) {
      this.m_doorProperties.m_doorTypeSideTwo = this.m_doorProperties.m_doorTypeSideOne;
    };
  }

  protected final func SetDefaultDoorState() -> Void {
    switch this.m_doorProperties.m_initialDoorState {
      case EDoorStatus.OPENED:
        this.m_isOpened = true;
        break;
      case EDoorStatus.CLOSED:
        this.m_isOpened = false;
        break;
      case EDoorStatus.LOCKED:
        this.m_isOpened = false;
        this.m_isLocked = true;
        break;
      case EDoorStatus.SEALED:
        this.m_isOpened = false;
        this.m_isSealed = true;
        break;
      default:
        Log("DoorController / Unknown EDoorStatus - Debug ");
    };
  }

  protected final func CheckIfLiftDoors() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as ElevatorFloorTerminalControllerPS) {
        if this.IsLocked() && this.IsOpen() {
          this.m_isOpened = false;
        };
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected final func IsLiftFloorAuthorized() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as ElevatorFloorTerminalControllerPS) {
        return (parents[i] as ElevatorFloorTerminalControllerPS).IsPlayerAuthorized();
      };
      i += 1;
    };
    return false;
  }

  protected final func IsLiftAvailable() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetAncestors(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as LiftControllerPS) {
        return (parents[i] as LiftControllerPS).IsPlayerAuthorized() && (parents[i] as LiftControllerPS).IsON();
      };
      i += 1;
    };
    return false;
  }

  protected final func IsLiftUnauthorized() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    let result: Bool;
    this.GetAncestors(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as LiftControllerPS) && (parents[i] as LiftControllerPS).IsON() {
        result = (parents[i] as LiftControllerPS).IsPlayerAuthorized();
        return !result;
      };
      i += 1;
    };
    return false;
  }

  protected final const func IsLiftMoving() -> Bool {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as ElevatorFloorTerminalControllerPS) {
        return (parents[i] as ElevatorFloorTerminalControllerPS).IsLiftMoving();
      };
      i += 1;
    };
    return false;
  }

  public final func PushResaveData(data: DoorResaveData) -> Void;

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    return DoorViabilityInterpreter.Evaluate(this, hasActiveActions);
  }

  protected func GetInkWidgetTweakDBID(context: GetActionsContext) -> TweakDBID {
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && !context.ignoresAuthorization && !this.CanPayToUnlock() {
      if this.IsDeviceSecuredWithPassword() {
        return t"DevicesUIDefinitions.DoorKeypadWidget";
      };
      return t"DevicesUIDefinitions.DoorKeypadWidget";
    };
    return t"DevicesUIDefinitions.DoorDeviceWidget";
  }

  public func GetWidgetTypeName() -> CName {
    return n"GenericDeviceWidget";
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_door.widgetbrush";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.DoorDeviceBackground";
  }

  protected func GetWidgetVisualState() -> EWidgetState {
    let widgetState: EWidgetState;
    if Equals(this.GetDoorState(), EDoorStatus.OPENED) {
      widgetState = EWidgetState.ALLOWED;
    } else {
      if Equals(this.GetDoorState(), EDoorStatus.LOCKED) {
        widgetState = EWidgetState.LOCKED;
      } else {
        if Equals(this.GetDoorState(), EDoorStatus.SEALED) {
          widgetState = EWidgetState.SEALED;
        } else {
          if Equals(this.GetDoorState(), EDoorStatus.OPENED) {
            widgetState = EWidgetState.ALLOWED;
          } else {
            if Equals(this.GetDoorState(), EDoorStatus.CLOSED) && !this.IsPlayerAuthorized() {
              widgetState = EWidgetState.LOCKED;
            } else {
              widgetState = EWidgetState.ALLOWED;
            };
          };
        };
      };
    };
    return widgetState;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let actionCallElevator: ref<CallElevator>;
    let basedTestsPassed: Bool = this.GetActions(actions, context);
    if this.m_isLiftDoor {
      if this.IsON() {
        if this.IsOpen() {
          return false;
        };
        if this.IsLocked() && !this.IsLiftMoving() && this.IsLiftFloorAuthorized() && this.IsLiftAvailable() {
          actionCallElevator = this.ActionCallElevator();
          ArrayPush(actions, actionCallElevator);
        } else {
          if this.IsLiftUnauthorized() {
            ArrayPush(actions, this.ActionUnauthorized());
          } else {
            actionCallElevator = this.ActionCallElevator();
            actionCallElevator.SetInactiveWithReason(false, "LocKey#17796");
            ArrayPush(actions, actionCallElevator);
          };
        };
      };
      return false;
    };
    if !basedTestsPassed {
      return false;
    };
    if this.IsBusy() {
      return false;
    };
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return false;
    };
    if Equals(this.m_doorProperties.m_doorType, EDoorType.PHYSICAL) {
      return false;
    };
    if Equals(this.m_doorProperties.m_doorType, EDoorType.REMOTELY_CONTROLLED) && Equals(context.requestType, gamedeviceRequestType.Direct) {
      return false;
    };
    if Equals(this.m_doorProperties.m_doorType, EDoorType.AUTOMATIC) && NotEquals(context.requestType, gamedeviceRequestType.Internal) {
      return false;
    };
    if this.IsOFF() || this.IsUnpowered() || this.IsDisabled() {
      return false;
    };
    if DoorStatus.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionDoorStatus());
    };
    if TogglePower.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionTogglePower());
    };
    if Equals(this.GetDoorType(), EDoorType.AUTOMATIC) && Equals(context.requestType, gamedeviceRequestType.Internal) {
      if ToggleOpen.IsDefaultConditionMet(this, context) {
        ArrayPush(actions, this.ActionToggleOpen());
      };
    };
    if NotEquals(this.GetDoorType(), EDoorType.AUTOMATIC) {
      if ToggleOpen.IsDefaultConditionMet(this, context) {
        ArrayPush(actions, this.ActionToggleOpen());
      };
    };
    if ToggleLock.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleLock());
    };
    if ToggleSeal.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionToggleSeal());
    };
    if ForceOpen.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionForceOpen());
    };
    if SetOpened.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionSetOpened());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected func SetInactiveActionsWithExceptions(out outActions: array<ref<DeviceAction>>) -> Void {
    let actionAllowedClassNames: array<String>;
    let actionDisallowedClassNames: array<String>;
    let i: Int32;
    let inactiveReason: String;
    let sAction: ref<ScriptableDeviceAction>;
    this.SetInactiveActionsWithExceptions(outActions);
    if this.GetActionsRestrictionData(actionAllowedClassNames, actionDisallowedClassNames, inactiveReason) {
      if ArrayContains(actionAllowedClassNames, "ToggleOpen") {
        i = 0;
        while i < ArraySize(outActions) {
          sAction = outActions[i] as ActionSkillCheck;
          if IsDefined(sAction) {
            sAction.SetActive();
          };
          i += 1;
        };
      };
    };
  }

  protected func PushReturnActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let shouldReturn: Bool = this.PushReturnActions(outActions, context);
    if shouldReturn && !this.m_isLiftDoor && this.IsDeviceSecured() && !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) && PlayerUnauthorized.IsDefaultConditionMet(this, context) {
      ArrayPush(outActions, this.ActionUnauthorized());
    };
    if !shouldReturn && this.CanPayToAuthorize() && Pay.IsDefaultConditionMet(this, context) {
      shouldReturn = true;
      ArrayPush(outActions, this.ActionPay(context));
    };
    return shouldReturn;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return this.ExposeQuickHakcsIfNotConnnectedToAP() || this.IsConnectedToBackdoorDevice();
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction>;
    if this.ExposeQuickHakcsIfNotConnnectedToAP() || this.IsConnectedToBackdoorDevice() {
      currentAction = this.ActionQuickHackToggleOpen();
      currentAction.SetObjectActionID(t"DeviceAction.ToggleStateClassHack");
      if this.IsBusy() {
        currentAction.SetInactiveWithReason(!this.IsBusy(), "LocKey#42758");
      } else {
        currentAction.SetInactiveWithReason(QuickHackToggleOpen.IsDefaultConditionMet(this, context), "LocKey#7003");
      };
      ArrayPush(actions, currentAction);
      this.FinalizeGetQuickHackActions(actions, context);
    };
  }

  protected func GetMinigameActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionSetAuthorizationModuleOFF();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.AddDeviceName(this.m_deviceName);
    ArrayPush(actions, action);
  }

  public func GetQuestActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(actions, context);
    ArrayPush(actions, this.ActionQuestForceOpen());
    ArrayPush(actions, this.ActionQuestForceClose());
    ArrayPush(actions, this.ActionQuestForceCloseImmediate());
    ArrayPush(actions, this.ActionQuestForceOpenScene());
    ArrayPush(actions, this.ActionQuestForceCloseScene());
    ArrayPush(actions, this.ActionQuestForceLock());
    ArrayPush(actions, this.ActionQuestForceUnlock());
    ArrayPush(actions, this.ActionQuestForceSeal());
    ArrayPush(actions, this.ActionQuestForceUnseal());
  }

  protected func PushSkillCheckActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    let skillCheckAdded: Bool;
    if this.IsClosed() && !this.IsSealed() && this.IsTriggerValid(this.GetDoorSkillcheckSide()) {
      if this.m_skillCheckContainer.GetDemolitionSlot().IsActive() && ActionSkillCheck.IsDefaultConditionMet(this, context, false) {
        ArrayPush(outActions, this.ActionDemolition(context));
        skillCheckAdded = true;
      };
      if this.m_skillCheckContainer.GetEngineeringSlot().IsActive() && ActionSkillCheck.IsDefaultConditionMet(this, context, false) {
        ArrayPush(outActions, this.ActionEngineering(context));
        skillCheckAdded = true;
      };
    };
    return skillCheckAdded;
  }

  public final const func IsTriggerValid(side: EDoorSkillcheckSide) -> Bool {
    if Equals(side, EDoorSkillcheckSide.BOTH) {
      return true;
    };
    if Equals(side, EDoorSkillcheckSide.ONE) && Equals(this.GetDoorTriggerSide(), EDoorTriggerSide.ONE) {
      return true;
    };
    if Equals(side, EDoorSkillcheckSide.TWO) && Equals(this.GetDoorTriggerSide(), EDoorTriggerSide.TWO) {
      return true;
    };
    return false;
  }

  protected final const func ActionDoorStatus() -> ref<DoorStatus> {
    let action: ref<DoorStatus> = new DoorStatus();
    action.clearanceLevel = DefaultActionsParametersHolder.GetStatusClearance();
    action.SetUp(this);
    action.SetProperties(this);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  protected func ActionDoorOpeningToken() -> ref<DoorOpeningToken> {
    let action: ref<DoorOpeningToken>;
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnDoorOpeningToken(evt: ref<DoorOpeningToken>) -> EntityNotificationType {
    this.AddToken(evt.GetExecutor().GetEntityID());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public func ActionToggleOpen() -> ref<ToggleOpen> {
    let action: ref<ToggleOpen> = new ToggleOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsOpen());
    action.AddDeviceName(this.GetDeviceName());
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public func OnSecuritySystemOutput(evt: ref<SecuritySystemOutput>) -> EntityNotificationType {
    this.OnSecuritySystemOutput(evt);
    if this.IsOpen() && Equals(evt.GetCachedSecurityState(), ESecuritySystemState.COMBAT) {
      this.m_alarmRaised = true;
      if this.IsClosingAutomatically() {
        this.ExecutePSAction(this.ActionQuestForceLock(), this);
        this.ExecutePSAction(this.ActionToggleOpen(), this);
      };
    } else {
      if Equals(evt.GetCachedSecurityState(), ESecuritySystemState.SAFE) && this.m_alarmRaised {
        this.m_alarmRaised = false;
        this.ExecutePSAction(this.ActionQuestForceUnlock(), this);
      };
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final func OnToggleOpen(evt: ref<ToggleOpen>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Unpowered or Disabled");
    };
    if this.m_isKeyloggerInstalled && this.IsAuthorizationModuleOn() {
      this.TurnAuthorizationModuleOFF();
    };
    if this.IsOpen() {
      this.m_isOpened = false;
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus);
      };
      this.UseNotifier(evt);
      return EntityNotificationType.SendThisEventToEntity;
    };
    if !this.ToggleOpenOnDoor() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Failed Toggle");
    };
    if this.HasAnySkillCheckActive() && evt.GetExecutor().IsPlayer() {
      this.ResolveOtherSkillchecks();
    };
    this.DepleteToken(evt.GetExecutor().GetEntityID());
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnDoorCollision() -> Void {
    if !this.IsOpen() {
      this.ExecutePSAction(this.ActionToggleOpen(), this);
    };
  }

  public final func ActionSetOpened() -> ref<SetOpened> {
    let action: ref<SetOpened> = new SetOpened();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnSetOpened(evt: ref<SetOpened>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    if this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Sealed or Disabled");
    };
    this.m_isOpened = true;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func ActionSetClosed() -> ref<SetClosed> {
    let action: ref<SetClosed> = new SetClosed();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnSetClosed(evt: ref<SetClosed>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetAll();
    if this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Sealed or Disabled");
    };
    this.m_isOpened = false;
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ActionPay(context: GetActionsContext) -> ref<Pay> {
    let action: ref<Pay> = new Pay();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleLockClearance();
    action.SetUp(this);
    if TDBID.IsValid(this.GetPaymentRecordID()) {
      action.SetObjectActionID(this.GetPaymentRecordID());
    };
    action.SetExecutor(GetPlayer(this.GetGameInstance()));
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    action.SetDurationValue(1.50);
    return action;
  }

  public final func OnPay(evt: ref<Pay>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier>;
    if this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Sealed or Disabled");
    };
    if evt.IsStarted() && evt.CanPayCost() {
      this.ExecutePSActionWithDelay(evt, this, evt.GetDurationValue());
    } else {
      notifier = new ActionNotifier();
      notifier.SetAll();
      this.m_isOpened = true;
      this.m_isLocked = false;
      this.Notify(notifier, evt);
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func ActionQuickHackToggleOpen() -> ref<QuickHackToggleOpen> {
    let action: ref<QuickHackToggleOpen> = new QuickHackToggleOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.IsOpen());
    action.AddDeviceName(this.m_deviceName);
    if this.IsOpen() {
      action.CreateInteraction(t"Interactions.Close");
    } else {
      action.CreateInteraction(t"Interactions.Open");
    };
    return action;
  }

  public final func ActionToggleLock() -> ref<ToggleLock> {
    let action: ref<ToggleLock> = new ToggleLock();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleLockClearance();
    action.SetUp(this);
    action.SetProperties(this.IsLocked());
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleLock(evt: ref<ToggleLock>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    notifier.SetAll();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    if this.IsLocked() {
      this.ResolveOtherSkillchecks();
    };
    if !this.ToggleLockOnDoor() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Failed Toggle Lock");
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnForceLockElevator(evt: ref<ForceLockElevator>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    notifier.SetAll();
    if this.IsUnpowered() || this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    this.m_isLocked = true;
    this.m_isOpened = false;
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func OnForceUnlockAndOpenElevator(evt: ref<ForceUnlockAndOpenElevator>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    notifier.SetAll();
    if this.IsUnpowered() || this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    this.m_isLocked = false;
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected final func ActionToggleSeal() -> ref<ToggleSeal> {
    let action: ref<ToggleSeal> = new ToggleSeal();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleSealClearance();
    action.SetUp(this);
    action.SetProperties(this.IsSealed());
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  public final func OnToggleSeal(evt: ref<ToggleSeal>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    cachedStatus = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    if this.IsOpen() && !FromVariant(evt.prop.first) {
      this.OnToggleOpen(this.ActionToggleOpen());
    };
    if !this.ToggleSealOnDoor() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Failed Toggle");
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  protected func ActionDemolition(context: GetActionsContext) -> ref<ActionDemolition> {
    let action: ref<ActionDemolition> = this.ActionDemolition(context);
    action.SetDurationValue(3.00);
    return action;
  }

  private final func ActionCallElevator() -> ref<CallElevator> {
    let action: ref<CallElevator> = new CallElevator();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(0);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    return action;
  }

  public final func OnCallElevator(evt: ref<CallElevator>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus>;
    let callElevator: ref<CallElevator>;
    let devices: array<ref<DeviceComponentPS>>;
    let i: Int32;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.GetParents(devices);
    i = 0;
    while i < ArraySize(devices) {
      if IsDefined(devices[i] as ElevatorFloorTerminalControllerPS) {
        callElevator = this.ActionCallElevator();
        if IsDefined(callElevator) {
          this.GetPersistencySystem().QueuePSEvent(devices[i].GetID(), n"ElevatorFloorTerminalControllerPS", callElevator);
        };
      };
      i += 1;
    };
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  public final const func IsPlayerCarrying() -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).GetLocalInstanced(this.GetPlayerMainObject().GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return playerStateMachineBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
  }

  protected func OnActionDemolition(evt: ref<ActionDemolition>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionDemolition(evt);
    if evt.IsCompleted() {
      this.ResolveOtherSkillchecks();
      this.ForceDisableDevice();
    } else {
      this.ExecuteForceOpen(evt.GetExecutor());
      if this.IsPlayerCarrying() {
        this.RequestForceBodyDrop(evt.GetExecutor());
      };
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionEngineering(evt: ref<ActionEngineering>) -> EntityNotificationType {
    if !evt.WasPassed() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.OnActionEngineering(evt);
    if evt.IsCompleted() {
      RPGManager.GiveReward(evt.GetExecutor().GetGame(), t"RPGActionRewards.ExtractPartsDoor");
      this.ResolveOtherSkillchecks();
      this.OnForceOpen(this.ActionForceOpen());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnActionForceResetDevice(evt: ref<ActionForceResetDevice>) -> EntityNotificationType {
    if this.IsOpen() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.ExecuteForceOpen(evt.GetExecutor());
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func ExecuteForceOpen(executor: wref<GameObject>) -> Void {
    let actionForceOpen: ref<ForceOpen> = this.ActionForceOpen();
    actionForceOpen.SetExecutor(executor);
    actionForceOpen.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
    this.GetPersistencySystem().QueuePSDeviceEvent(actionForceOpen);
  }

  protected final func RequestForceBodyDrop(executor: wref<GameObject>) -> Void {
    let psmEvent: ref<PSMPostponedParameterBool> = new PSMPostponedParameterBool();
    psmEvent.id = n"forceDropBody";
    psmEvent.value = true;
    executor.QueueEvent(psmEvent);
  }

  protected final func OnActionInstallKeylogger(evt: ref<InstallKeylogger>) -> EntityNotificationType {
    this.m_isKeyloggerInstalled = true;
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  protected func ResolveOtherSkillchecks() -> Void {
    if IsDefined(this.m_skillCheckContainer) {
      if IsDefined(this.m_skillCheckContainer.GetDemolitionSlot()) && this.m_skillCheckContainer.GetDemolitionSlot().IsActive() {
        this.m_skillCheckContainer.GetDemolitionSlot().SetIsActive(false);
        this.m_skillCheckContainer.GetDemolitionSlot().SetIsPassed(true);
      };
      if IsDefined(this.m_skillCheckContainer.GetEngineeringSlot()) && this.m_skillCheckContainer.GetEngineeringSlot().IsActive() {
        this.m_skillCheckContainer.GetEngineeringSlot().SetIsActive(false);
        this.m_skillCheckContainer.GetEngineeringSlot().SetIsPassed(true);
      };
    };
    this.ResolveTerminalSkillchecks(this.GetMyEntityID());
  }

  public final func ResolveSkillchecks() -> Void {
    this.ResolveOtherSkillchecks();
  }

  public final const func CanPassAnySkillCheckOnParentTerminal(requester: ref<GameObject>) -> Bool {
    let i: Int32;
    let parent: ref<TerminalControllerPS>;
    let parents: array<ref<DeviceComponentPS>>;
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      parent = parents[i] as TerminalControllerPS;
      if parent == null {
      } else {
        if parent.IsSkillCheckActive() && parent.CanPassAnySkillCheck(requester) {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  protected final func ActionForceOpen() -> ref<ForceOpen> {
    let action: ref<ForceOpen> = new ForceOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetForceOpenClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnForceOpen(evt: ref<ForceOpen>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetInternalOnly();
    if this.IsDisabled() || this.IsSealed() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Sealed or Disabled");
    };
    this.m_isLocked = false;
    this.m_isOpened = true;
    this.m_doorProperties.m_automaticallyClosesItself = false;
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func ActionQuestForceOpen() -> ref<QuestForceOpen> {
    let action: ref<QuestForceOpen> = new QuestForceOpen();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceOpen(evt: ref<QuestForceOpen>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR OPENED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = true;
    this.m_isLocked = false;
    this.m_isSealed = false;
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func ActionQuestForceClose() -> ref<QuestForceClose> {
    let action: ref<QuestForceClose> = new QuestForceClose();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceClose(evt: ref<QuestForceClose>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR CLOSED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = false;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func ActionQuestForceCloseImmediate() -> ref<QuestForceCloseImmediate> {
    let action: ref<QuestForceCloseImmediate> = new QuestForceCloseImmediate();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceCloseImmediate(evt: ref<QuestForceCloseImmediate>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR CLOSED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = false;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActionQuestForceOpenScene() -> ref<QuestForceOpenScene> {
    let action: ref<QuestForceOpenScene> = new QuestForceOpenScene();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceOpenScene(evt: ref<QuestForceOpenScene>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR CLOSED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = true;
    this.m_isLocked = false;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActionQuestForceCloseScene() -> ref<QuestForceCloseScene> {
    let action: ref<QuestForceCloseScene> = new QuestForceCloseScene();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceCloseScene(evt: ref<QuestForceCloseScene>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR CLOSED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = false;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActionQuestForceLock() -> ref<QuestForceLock> {
    let action: ref<QuestForceLock> = new QuestForceLock();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceLock(evt: ref<QuestForceLock>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR LOCKED DESPITE WRONG STATE");
      };
    };
    this.m_isLocked = true;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func ActionQuestForceUnlock() -> ref<QuestForceUnlock> {
    let action: ref<QuestForceUnlock> = new QuestForceUnlock();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceUnlock(evt: ref<QuestForceUnlock>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR UNLOCKED DESPITE WRONG STATE");
      };
    };
    this.m_isLocked = false;
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  private final func ActionQuestForceSeal() -> ref<QuestForceSeal> {
    let action: ref<QuestForceSeal> = new QuestForceSeal();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceSeal(evt: ref<QuestForceSeal>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() || !this.m_doorProperties.m_canPlayerToggleSealState {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR SEALED DESPITE WRONG STATE");
      };
    };
    this.m_isOpened = false;
    this.m_isSealed = true;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  private final func ActionQuestForceUnseal() -> ref<QuestForceUnseal> {
    let action: ref<QuestForceUnseal> = new QuestForceUnseal();
    action.clearanceLevel = DefaultActionsParametersHolder.GetQuestClearance();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public final func OnQuestForceUnseal(evt: ref<QuestForceUnseal>) -> EntityNotificationType {
    let cachedStatus: ref<DoorStatus> = this.GetDeviceStatusAction() as DoorStatus;
    if this.IsUnpowered() || this.IsDisabled() {
      if !IsFinal() {
        this.LogActionDetails(evt, cachedStatus, "POTENTIAL ERROR: DOOR SEALED DESPITE WRONG STATE");
      };
    };
    this.m_isSealed = false;
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus, "QUEST");
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func SetNewDoorType(evt: ref<SetDoorType>) -> Void {
    this.m_doorProperties.m_doorType = evt.doorTypeSideOne;
    this.m_doorProperties.m_doorTypeSideTwo = evt.doorTypeSideTwo;
    this.InitializeDoorTypes();
  }

  public final func SetCloseItself(val: Bool) -> Void {
    this.m_doorProperties.m_automaticallyClosesItself = val;
  }

  public final func ResetToDefault() -> Void {
    this.SetDefaultDoorState();
    this.ErasePassedSkillchecks();
    this.InitializeSkillChecks(this.m_doorSkillChecks);
    if this.IsDisabled() {
      this.ForceDeviceON();
    };
  }

  public func OnSetAuthorizationModuleOFF(evt: ref<SetAuthorizationModuleOFF>) -> EntityNotificationType {
    this.OnSetAuthorizationModuleOFF(evt);
    this.ResolveOtherSkillchecks();
    if !this.IsSealed() {
      this.m_isLocked = false;
      this.m_isOpened = true;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendPSChangedEventToEntity;
  }

  public final func ActionUnauthorized() -> ref<PlayerUnauthorized> {
    let action: ref<PlayerUnauthorized> = new PlayerUnauthorized();
    action.clearanceLevel = DefaultActionsParametersHolder.GetToggleOpenClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isLiftDoor);
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction(this);
    return action;
  }

  protected final func ResolveTerminalSkillchecks(id: EntityID) -> Void {
    let i: Int32;
    let parents: array<ref<DeviceComponentPS>>;
    let evt: ref<ResolveSkillchecksEvent> = new ResolveSkillchecksEvent();
    this.GetParents(parents);
    i = 0;
    while i < ArraySize(parents) {
      if IsDefined(parents[i] as TerminalControllerPS) && parents[i].GetMyEntityID() != id {
        this.GetPersistencySystem().QueuePSEvent(parents[i].GetID(), parents[i].GetClassName(), evt);
      };
      i += 1;
    };
  }

  public final func OnQuickHackToggleOpen(evt: ref<QuickHackToggleOpen>) -> EntityNotificationType {
    let actionClose: ref<ToggleOpen>;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    this.TurnAuthorizationModuleOFF();
    if this.IsOpen() {
      actionClose = this.ActionToggleOpen();
      actionClose.SetExecutor(evt.GetExecutor());
      actionClose.RegisterAsRequester(PersistentID.ExtractEntityID(this.GetID()));
      this.GetPersistencySystem().QueuePSDeviceEvent(actionClose);
    } else {
      this.ExecuteForceOpen(evt.GetExecutor());
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected func OnActivateDevice(evt: ref<ActivateDevice>) -> EntityNotificationType {
    this.OnActivateDevice(evt);
    if this.IsUnpowered() {
      this.SetDeviceState(EDeviceStatus.ON);
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnAuthorizeUser(evt: ref<AuthorizeUser>) -> EntityNotificationType {
    let actionLock: ref<ToggleLock>;
    let actionOpen: ref<ToggleOpen>;
    let wasAuthorized: Bool;
    let notifier: ref<ActionNotifier> = new ActionNotifier();
    notifier.SetNone();
    if evt.GetRequesterID() == this.GetMyEntityID() && this.MasterUserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
      wasAuthorized = true;
    } else {
      if this.UserAuthorizationAttempt(evt.GetExecutor().GetEntityID(), evt.GetEnteredPassword()) {
        wasAuthorized = true;
      };
    };
    if wasAuthorized {
      if this.IsLocked() {
        actionLock = this.ActionToggleLock();
        actionLock.SetExecutor(evt.GetExecutor());
        actionLock.RegisterAsRequester(this.GetMyEntityID());
        this.GetPersistencySystem().QueuePSDeviceEvent(actionLock);
      } else {
        actionOpen = this.ActionToggleOpen();
        actionOpen.SetExecutor(evt.GetExecutor());
        actionOpen.RegisterAsRequester(this.GetMyEntityID());
        this.GetPersistencySystem().QueuePSDeviceEvent(actionOpen);
        this.ResolveOtherSkillchecks();
      };
    };
    this.Notify(notifier, evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func CanPayToAuthorize() -> Bool {
    return this.CanPayToUnlock();
  }

  public const func IsUserAuthorized(user: EntityID) -> Bool {
    if this.IsLocked() {
      if this.m_doorProperties.m_canPlayerToggleLockState {
        return true;
      };
      if this.IsDeviceSecured() && this.IsTriggerValid(this.GetDoorAuthorizationSide()) && this.IsUserAuthorized(user) {
        return true;
      };
      return false;
    };
    if this.IsTriggerValid(this.GetDoorAuthorizationSide()) {
      return this.IsUserAuthorized(user);
    };
    return true;
  }

  public final func RequiresAuthorization() -> Bool {
    if this.IsDeviceSecured() && this.IsTriggerValid(this.GetDoorAuthorizationSide()) && this.IsUserAuthorized(GetPlayerObject(this.GetGameInstance()).GetEntityID()) {
      return true;
    };
    return false;
  }

  public final func UpdatePlayerAuthorization() -> Void {
    this.m_isPlayerAuthorised = this.IsUserAuthorized(this.GetPlayerEntityID());
  }

  public final func WasPlayerAuthorized() -> Bool {
    return this.m_isPlayerAuthorised;
  }

  private final func ToggleOpenOnDoor() -> Bool {
    if this.IsSealed() || this.IsLocked() {
      return false;
    };
    if this.IsLogicallyClosed() {
      this.m_isOpened = true;
      return true;
    };
    this.m_isOpened = false;
    return true;
  }

  private final func ToggleLockOnDoor() -> Bool {
    if this.IsSealed() {
      return false;
    };
    if this.IsLocked() {
      this.m_isLocked = false;
      return true;
    };
    this.m_isLocked = true;
    return true;
  }

  private final func ToggleSealOnDoor() -> Bool {
    if this.IsSealed() {
      this.m_isSealed = false;
      return true;
    };
    this.m_isSealed = true;
    return true;
  }

  protected final func AddToken(id: EntityID) -> Bool {
    if !EntityID.IsDefined(id) {
      return false;
    };
    if ArrayContains(this.m_openingTokens, id) {
      return false;
    };
    ArrayPush(this.m_openingTokens, id);
    return true;
  }

  public final func DepleteToken(id: EntityID) -> Bool {
    if !EntityID.IsDefined(id) {
      return false;
    };
    return ArrayRemove(this.m_openingTokens, id);
  }

  protected func LogActionDetails(action: ref<ScriptableDeviceAction>, cachedStatus: ref<BaseDeviceStatus>, opt context: String, opt status: String, opt overrideStatus: Bool) -> Void {
    let doorType: String;
    if this.IsLogInExclusiveMode() && !this.m_debugDevice {
      return;
    };
    overrideStatus = true;
    switch this.m_doorProperties.m_doorType {
      case EDoorType.AUTOMATIC:
        doorType = "AUTOMATIC";
        break;
      case EDoorType.INTERACTIVE:
        doorType = "INTERACTIVE";
        break;
      case EDoorType.PHYSICAL:
        doorType = "PHYSICAL";
        break;
      case EDoorType.REMOTELY_CONTROLLED:
        doorType = "REMOTELYCONTROLLED";
        break;
      default:
        Log("LogActionDetails ( Door ) / Wrong door type");
    };
    status = this.ActionDoorStatus().GetCurrentDisplayString();
    this.LogActionDetails(action, cachedStatus, context, status, overrideStatus);
    Log("door type............. " + doorType);
  }

  public final func PushPersistentData(data: DoorPersistentData) -> Void {
    if this.IsInitialized() {
      return;
    };
    this.m_doorProperties.m_doorType = data.m_doorType;
    this.m_doorProperties.m_canPlayerToggleLockState = data.m_canPlayerToggleLockState;
    this.m_doorProperties.m_canPlayerToggleSealState = data.m_canPlayerToggleSealState;
    if !AuthorizationData.IsAuthorizationValid(this.m_authorizationProperties) {
      this.m_authorizationProperties.m_authorizationDataEntry.m_keycard = data.m_keycardName;
      this.m_authorizationProperties.m_authorizationDataEntry.m_password = data.m_passcode;
    };
    switch data.m_initialStatus {
      case EDoorStatus.OPENED:
        this.m_isOpened = true;
        break;
      case EDoorStatus.CLOSED:
        this.m_isOpened = false;
        break;
      case EDoorStatus.LOCKED:
        this.m_isOpened = false;
        this.m_isLocked = true;
        break;
      case EDoorStatus.SEALED:
        this.m_isOpened = false;
        this.m_isSealed = true;
        break;
      default:
        Log("DoorController / Unknown EDoorStatus - Debug ");
    };
  }
}
