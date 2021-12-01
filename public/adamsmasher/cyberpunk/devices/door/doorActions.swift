
public class Pay extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"Pay";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Pay", true, n"LocKey#3537", n"LocKey#3537");
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if Pay.IsAvailable(device) && Pay.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsSealed() {
      return false;
    };
    if !device.IsLocked() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleLockClearance()) {
      return true;
    };
    return false;
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.PayDeviceActionWidget";
  }
}

public class QuickHackToggleOpen extends ActionBool {

  public final func SetProperties(isOpen: Bool) -> Void {
    this.actionName = n"QuickHackToggleOpen";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuickHackToggleOpen", isOpen, n"LocKey#365", n"LocKey#366");
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if QuickHackToggleOpen.IsAvailable(device) && QuickHackToggleOpen.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() || device.IsSealed() {
      return false;
    };
    if device.IsConnectedToBackdoorDevice() || device.ExposeQuickHakcsIfNotConnnectedToAP() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return "HackOpen";
    };
    return "HackClose";
  }
}

public class DoorStatus extends BaseDeviceStatus {

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    this.SetProperties(deviceRef);
    this.actionName = n"DoorStatus";
    this.prop.second = ToVariant(EnumInt((deviceRef as DoorControllerPS).GetDoorState()));
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String;
    if FromVariant(this.prop.first) >= 0 {
      switch this.prop.second {
        case ToVariant(-2):
          str = "LocKey#17804";
          break;
        case ToVariant(-1):
          str = "LocKey#17805";
          break;
        case ToVariant(0):
          str = "LocKey#17806";
          break;
        case ToVariant(1):
          str = "LocKey#17807";
          break;
        default:
          Log("DoorDeviceStatus / Unhandled door state");
      };
    } else {
      return this.GetCurrentDisplayString();
    };
    return str;
  }

  public const func GetStatusValue() -> Int32 {
    if FromVariant(this.prop.first) > 0 {
      return FromVariant(this.prop.second);
    };
    return FromVariant(this.prop.first);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if DoorStatus.IsAvailable(device) && DoorStatus.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return BaseDeviceStatus.IsAvailable(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return BaseDeviceStatus.IsClearanceValid(clearance);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class DoorOpeningToken extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"DoorOpeningToken";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Open";
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    return ToggleOpen.IsDefaultConditionMet(device, context);
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    return ToggleOpen.IsAvailable(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    return ToggleOpen.IsClearanceValid(clearance);
  }
}

public class ToggleOpen extends ActionBool {

  public final func SetProperties(isOpen: Bool, opt altOpenChoice: CName, opt altCloseChoice: CName) -> Void {
    let nameOnFalse: CName;
    let nameOnTrue: CName;
    this.actionName = n"ToggleOpen";
    if IsNameValid(altOpenChoice) && IsNameValid(altCloseChoice) {
      nameOnTrue = altOpenChoice;
      nameOnFalse = altCloseChoice;
    } else {
      nameOnTrue = n"LocKey#273";
      nameOnFalse = n"LocKey#274";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Open", isOpen, nameOnTrue, nameOnFalse);
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if ToggleOpen.IsAvailable(device) && ToggleOpen.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsSealed() {
      return false;
    };
    if device.IsLocked() && device.IsClosed() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Open";
    };
    return "Close";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.DoorDeviceActionWidget";
  }
}

public class SetOpened extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetOpened";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Open";
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if SetOpened.IsAvailable(device) && SetOpened.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsSealed() {
      return false;
    };
    if device.IsOpen() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }
}

public class SetClosed extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"SetClosed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Close";
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if SetClosed.IsAvailable(device) && SetClosed.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsSealed() {
      return false;
    };
    if device.IsLocked() {
      return false;
    };
    if device.IsLogicallyClosed() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }
}

public class ToggleLock extends ActionBool {

  @default(ToggleLock, true)
  protected let m_shouldOpen: Bool;

  public func SetProperties(isLocked: Bool) -> Void {
    this.actionName = n"ToggleLock";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Lock", isLocked, n"LocKey#275", n"LocKey#276");
  }

  public final func SetShouldOpen(shouldOpen: Bool) -> Void {
    this.m_shouldOpen = shouldOpen;
  }

  public final const func ShouldOpen() -> Bool {
    return this.m_shouldOpen;
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if ToggleLock.IsAvailable(device, context.requestType) && ToggleLock.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>, requestType: gamedeviceRequestType) -> Bool {
    if device.IsDisabled() || device.IsSealed() {
      return false;
    };
    if Equals(requestType, gamedeviceRequestType.Internal) {
      return true;
    };
    if device.canPlayerToggleLockState() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleLockClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Lock";
    };
    return "Unlock";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.DoorDeviceActionWidget";
  }
}

public class ToggleSeal extends ActionBool {

  public final func SetProperties(isSealed: Bool) -> Void {
    this.actionName = n"ToggleSeal";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Seal", isSealed, n"LocKey#277", n"LocKey#278");
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if ToggleSeal.IsAvailable(device) && ToggleSeal.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if !device.canPlayerToggleSealState() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleSealClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if !FromVariant(this.prop.first) {
      return "Seal";
    };
    return "Unseal";
  }

  public func GetInkWidgetTweakDBID() -> TweakDBID {
    return t"DevicesUIDefinitions.DoorDeviceActionWidget";
  }
}

public class ForceOpen extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceOpen";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ForceOpen", true, n"LocKey#537", n"LocKey#537");
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if ForceOpen.IsAvailable(device) && ForceOpen.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetForceOpenClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "force_open";
  }
}

public class ForceLockElevator extends ToggleLock {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceLockElevator";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ForceLockElevator", true, n"LocKey#275", n"LocKey#276");
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>, requestType: gamedeviceRequestType) -> Bool {
    return true;
  }
}

public class ForceUnlockAndOpenElevator extends ToggleLock {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceUnlockAndOpenElevator";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ForceUnlockAndOpenElevator", false, n"LocKey#275", n"LocKey#276");
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>, requestType: gamedeviceRequestType) -> Bool {
    return true;
  }
}

public class PlayerUnauthorized extends ActionBool {

  protected let m_isLiftDoor: Bool;

  public final func SetProperties(isLift: Bool) -> Void {
    this.m_isLiftDoor = isLift;
    this.actionName = n"PlayerUnauthorized";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"PlayerUnauthorized", false, n"LocKey#78162", n"LocKey#78162");
  }

  public final func CreateInteraction(device: ref<DoorControllerPS>, opt actions: array<ref<DeviceAction>>) -> Void {
    this.m_hasInteraction = true;
    this.interactionChoice.choiceMetaData.tweakDBName = this.GetTweakDBChoiceRecord();
    ChoiceTypeWrapper.SetType(this.interactionChoice.choiceMetaData.type, gameinteractionsChoiceType.CheckFailed);
    DeviceHelper.PushActionsIntoInteractionChoice(this.interactionChoice, actions);
  }

  public final static func IsDefaultConditionMet(device: ref<DoorControllerPS>, context: GetActionsContext) -> Bool {
    if PlayerUnauthorized.IsAvailable(device) && PlayerUnauthorized.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<DoorControllerPS>) -> Bool {
    if !device.IsON() || device.IsSealed() {
      return false;
    };
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleOpenClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if this.m_isLiftDoor {
      return "UnauthorizedElevator";
    };
    return "Unauthorized";
  }
}

public class QuestForceOpen extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceOpen";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceOpen", true, n"QuestForceOpen", n"QuestForceOpen");
  }
}

public class QuestForceClose extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceClose";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceClose", true, n"QuestForceClose", n"QuestForceClose");
  }
}

public class QuestForceCloseImmediate extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceCloseImmediate";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceCloseImmediate", true, n"QuestForceCloseImmediate", n"QuestForceCloseImmediate");
  }
}

public class QuestForceOpenScene extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceOpenScene";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceOpenScene", true, n"QuestForceOpenScene", n"QuestForceOpenScene");
  }
}

public class QuestForceCloseScene extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceCloseScene";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceCloseScene", true, n"QuestForceCloseScene", n"QuestForceCloseScene");
  }
}

public class QuestForceLock extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceLock";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceLock", true, n"QuestForceLock", n"QuestForceLock");
  }
}

public class QuestForceUnlock extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceUnlock";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceUnlock", true, n"QuestForceUnlock", n"QuestForceUnlock");
  }
}

public class QuestForceSeal extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceSeal";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceSeal", true, n"QuestForceSeal", n"QuestForceSeal");
  }
}

public class QuestForceUnseal extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"ForceUnseal";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceUnseal", true, n"QuestForceUnseal", n"QuestForceUnseal");
  }
}
