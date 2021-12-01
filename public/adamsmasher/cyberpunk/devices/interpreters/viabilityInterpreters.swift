
public class BasicViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<ScriptableDeviceComponentPS>, hasActiveActions: Bool) -> EViabilityDecision {
    if hasActiveActions {
      return EViabilityDecision.VIABLE;
    };
    if device.IsDisabled() {
      return EViabilityDecision.NONVIABLE;
    };
    if device.IsMarkedAsQuest() {
      return EViabilityDecision.VIABLE;
    };
    return EViabilityDecision.INCONCLUSIVE;
  }
}

public class SurveillanceCameraViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<SurveillanceCameraControllerPS>, hasActiveActions: Bool) -> Bool {
    let basicCheckResult: EViabilityDecision = BasicViabilityInterpreter.Evaluate(device, hasActiveActions);
    if Equals(basicCheckResult, EViabilityDecision.VIABLE) {
      return true;
    };
    if Equals(basicCheckResult, EViabilityDecision.NONVIABLE) {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    if device.IsQuickHacksExposed() {
      return true;
    };
    return false;
  }
}

public class MasterViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<MasterControllerPS>, hasActiveActions: Bool) -> Bool {
    if device.IsDisabled() || device.IsUnpowered() {
      return false;
    };
    return true;
  }
}

public class TVViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<MediaDeviceControllerPS>, hasActiveActions: Bool) -> Bool {
    let basicCheckResult: EViabilityDecision = BasicViabilityInterpreter.Evaluate(device, hasActiveActions);
    if Equals(basicCheckResult, EViabilityDecision.VIABLE) {
      return true;
    };
    if Equals(basicCheckResult, EViabilityDecision.NONVIABLE) {
      return false;
    };
    if device.IsDisabled() || device.IsUnpowered() {
      return false;
    };
    return true;
  }
}

public class RadioViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<RadioControllerPS>, hasActiveActions: Bool) -> Bool {
    let basicCheckResult: EViabilityDecision = BasicViabilityInterpreter.Evaluate(device, hasActiveActions);
    if Equals(basicCheckResult, EViabilityDecision.VIABLE) {
      return true;
    };
    if Equals(basicCheckResult, EViabilityDecision.NONVIABLE) {
      return false;
    };
    return false;
  }
}

public class DoorViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<DoorControllerPS>, hasActiveActions: Bool) -> Bool {
    let basicCheckResult: EViabilityDecision = BasicViabilityInterpreter.Evaluate(device, hasActiveActions);
    if device.IsOpen() {
      return false;
    };
    if Equals(basicCheckResult, EViabilityDecision.VIABLE) {
      return true;
    };
    if Equals(basicCheckResult, EViabilityDecision.NONVIABLE) {
      return false;
    };
    if Equals(device.GetDoorType(), EDoorType.REMOTELY_CONTROLLED) {
      return false;
    };
    if device.IsSealed() || device.IsLocked() {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    return true;
  }
}

public class ElevatorFloorViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<DoorControllerPS>, hasActiveActions: Bool) -> Bool {
    let basicCheckResult: EViabilityDecision = BasicViabilityInterpreter.Evaluate(device, hasActiveActions);
    if Equals(basicCheckResult, EViabilityDecision.VIABLE) {
      return true;
    };
    if Equals(basicCheckResult, EViabilityDecision.NONVIABLE) {
      return false;
    };
    if Equals(device.GetDoorType(), EDoorType.AUTOMATIC) {
      return false;
    };
    return true;
  }
}

public class SmartWindowViabilityInterpreter extends IScriptable {

  public final static func Evaluate(device: ref<SmartWindowControllerPS>, hasActiveActions: Bool) -> Bool {
    if device.IsOFF() {
      return true;
    };
    return false;
  }
}
