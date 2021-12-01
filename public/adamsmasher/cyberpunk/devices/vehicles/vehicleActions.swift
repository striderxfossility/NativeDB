
public class ForceCarAlarm extends ActionBool {

  public final func SetProperties(isAlarmTriggered: Bool) -> Void {
    this.actionName = n"ForceCarAlarm";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isAlarmTriggered, n"LocKey#294", n"LocKey#294");
  }

  public final static func IsDefaultConditionMet(device: ref<VehicleComponentPS>, context: GetActionsContext) -> Bool {
    if ForceCarAlarm.IsAvailable(device) && ForceCarAlarm.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<VehicleComponentPS>) -> Bool {
    return true;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    return "StartAlarm";
  }
}

public class ForceDisableCarAlarm extends ActionBool {

  public final func SetProperties(isAlarmTriggered: Bool) -> Void {
    this.actionName = n"ForceDisableCarAlarm";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isAlarmTriggered, n"LocKey#295", n"LocKey#295");
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "DeactivateAlarm";
  }
}

public class ToggleVehicle extends ActionBool {

  public final func SetProperties(toggleOn: Bool) -> Void {
    this.actionName = n"ToggleVehicle";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, toggleOn, n"LocKey#296", n"LocKey#297");
  }

  public func GetTweakDBChoiceRecord() -> String {
    let toggleOffName: CName;
    let toggleOn: Bool;
    let toggleOnName: CName;
    DeviceActionPropertyFunctions.GetProperty_Bool(this.prop, toggleOn, toggleOffName, toggleOnName);
    return NameToString(toggleOn ? toggleOnName : toggleOffName);
  }
}

public class VehicleOpenTrunk extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"OpenTrunk";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#302", n"LocKey#302");
  }
}

public class VehicleCloseTrunk extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"CloseTrunk";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#303", n"LocKey#303");
  }
}

public class VehicleDumpBody extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"VehicleDumpBody";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#304", n"LocKey#304");
  }
}

public class VehicleTakeBody extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"VehicleTakeBody";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#305", n"LocKey#305");
  }
}

public class VehiclePlayerTrunk extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"PlayerTrunk";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#17845", n"LocKey#17845");
  }
}

public class VehicleOpenHood extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"OpenHood";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#302", n"LocKey#302");
  }
}

public class VehicleCloseHood extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"CloseHood";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#303", n"LocKey#303");
  }
}

public class VehicleDoorInteraction extends ActionBool {

  public let slotID: CName;

  public let isInteractionSource: Bool;

  public final func SetProperties(slotString: String, opt source: Bool, opt locked: Bool) -> Void {
    this.slotID = StringToName(slotString);
    if locked {
      this.actionName = StringToName("vehicle_door_locked");
    } else {
      this.actionName = n"";
    };
    this.isInteractionSource = source;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleDoorInteractionStateChange extends ActionBool {

  public let door: EVehicleDoor;

  public let newState: VehicleDoorInteractionState;

  public let source: String;

  public final func SetProperties(doorToChange: EVehicleDoor, desiredState: VehicleDoorInteractionState, reason: String) -> Void {
    this.actionName = n"";
    this.door = doorToChange;
    this.newState = desiredState;
    this.source = reason;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleDoorOpen extends ActionBool {

  public let slotID: CName;

  public let shouldAutoClose: Bool;

  public let autoCloseTime: Float;

  public final func SetProperties(slotString: String, opt autoClose: Bool, opt autoCloseDelay: Float) -> Void {
    this.actionName = n"";
    this.slotID = StringToName(slotString);
    this.shouldAutoClose = autoClose;
    this.autoCloseTime = autoCloseDelay;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleDoorClose extends ActionBool {

  public let slotID: CName;

  public let isInteractionSource: Bool;

  public final func SetProperties(slotString: String) -> Void {
    this.actionName = n"";
    this.slotID = StringToName(slotString);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleDoorDetached extends ActionBool {

  public let slotID: CName;

  public let isInteractionSource: Bool;

  public final func SetProperties(slotString: String, opt source: Bool) -> Void {
    this.actionName = n"";
    this.slotID = StringToName(slotString);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleQuestDoorLocked extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"vehicle_door_quest_locked";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, n"LocKey#23298", n"LocKey#23298");
  }
}

public class VehicleWindowOpen extends ActionBool {

  public let slotID: CName;

  public let speed: CName;

  public final func SetProperties(slotString: String) -> Void {
    this.actionName = n"";
    this.slotID = StringToName(slotString);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleWindowClose extends ActionBool {

  public let slotID: CName;

  public let speed: CName;

  public let isInteractionSource: Bool;

  public final func SetProperties(slotString: String) -> Void {
    this.actionName = n"";
    this.slotID = StringToName(slotString);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}

public class VehicleForceOccupantOut extends ActionBool {

  public let slotID: CName;

  public final func SetProperties(slotString: String) -> Void {
    this.actionName = StringToName("VehicleForceOccupantOut_" + slotString);
    this.slotID = StringToName(slotString);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, true, this.actionName, this.actionName);
  }
}
