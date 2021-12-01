
public class SurveillanceCameraStatus extends BaseDeviceStatus {

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    this.SetProperties(deviceRef);
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_IntRanged(n"STATUS", EnumInt(deviceRef.GetDeviceState()), EnumInt((deviceRef as SurveillanceCameraControllerPS).GetCameraState()), 0);
  }

  public const func GetCurrentDisplayString() -> String {
    let str: String;
    let baseStateValue: Int32 = FromVariant(this.prop.first);
    let extendedStateValue: Int32 = FromVariant(this.prop.second);
    if baseStateValue > 0 {
      switch extendedStateValue {
        case -1:
          str = "LocKey#17801";
          break;
        case 0:
          str = "LocKey#17802";
          break;
        case 1:
          str = "LocKey#17803";
          break;
        default:
          str = "Unknown State - DEBUG";
      };
      Log("SurveillanceCameraStatus / Unhandled camera state");
      return str;
    };
    return this.GetCurrentDisplayString();
  }

  public const func GetStatusValue() -> Int32 {
    if FromVariant(this.prop.first) > 0 {
      return FromVariant(this.prop.second);
    };
    return FromVariant(this.prop.first);
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if SurveillanceCameraStatus.IsAvailable(device) && SurveillanceCameraStatus.IsClearanceValid(context.clearance) {
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

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    return BaseDeviceStatus.IsContextValid(context);
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class QuestForceTakeControlOverCamera extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceTakeControlOverCamera";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceTakeControlOverCamera", true, n"QuestForceTakeControlOverCamera", n"QuestForceTakeControlOverCamera");
  }
}

public class QuestForceTakeControlOverCameraWithChain extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceTakeControlOverCameraWithChain";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceTakeControlOverCameraWithChain", true, n"QuestForceTakeControlOverCameraWithChain", n"QuestForceTakeControlOverCameraWithChain");
  }
}

public class QuestForceStopTakeControlOverCamera extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceStopTakeControlOverCamera";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceStopTakeControlOverCamera", true, n"QuestForceStopTakeControlOverCamera", n"QuestForceStopTakeControlOverCamera");
  }
}

public class ToggleTakeOverControl extends ActionBool {

  public let isRequestedFormOtherDevice: Bool;

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties(isDeviceUnderControl: Bool, opt createdAsQuickHack: Bool) -> Void {
    this.actionName = n"ToggleTakeOverControl";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, isDeviceUnderControl, n"LocKey#359", n"LocKey#17810");
    this.m_isQuickHack = createdAsQuickHack;
  }

  public func GetTweakDBChoiceRecord() -> String {
    if TDBID.IsValid(this.m_objectActionID) {
      return this.GetTweakDBChoiceRecord();
    };
    if !FromVariant(this.prop.first) {
      return "TakeControl";
    };
    return "StopTakingControl";
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleTakeOverControl.IsAvailable(device) && ToggleTakeOverControl.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      return true;
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetTakeOverControl()) {
      return true;
    };
    return false;
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.TakeControl");
  }
}

public class ToggleStreamFeed extends ActionBool {

  public let vRoomFake: Bool;

  protected func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties(isStreaming: Bool) -> Void {
    this.actionName = n"ToggleStreamFeed";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"ActionStream", isStreaming, n"LocKey#17811", n"LocKey#17812");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if ToggleStreamFeed.IsAvailable(device) && ToggleStreamFeed.IsClearanceValid(context.clearance) && ToggleStreamFeed.IsContextValid(context) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsON() {
      if (device as SurveillanceCameraControllerPS).CanStreamVideo() {
        return true;
      };
    };
    return false;
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetToggleStreamFeedClearance()) {
      return true;
    };
    return false;
  }

  public final static func IsContextValid(context: GetActionsContext) -> Bool {
    if Equals(context.requestType, gamedeviceRequestType.Direct) {
      return false;
    };
    return true;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "wrong_action";
  }
}

public class QuestForceReplaceStreamWithVideo extends ActionName {

  public final func SetProperties(binkPath: CName) -> Void {
    this.actionName = n"QuestForceReplaceStreamWithVideo";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Name(n"binkPath", binkPath);
  }
}

public class QuestForceStopReplacingStream extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceStopReplacingStream";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceStopReplacingStream", true, n"QuestForceStopReplacingStream", n"QuestForceStopReplacingStream");
  }
}

public class QuestForceScanEffect extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceScanEffect";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceScanEffect", true, n"QuestForceScanEffect", n"QuestForceScanEffect");
  }
}

public class QuestForceScanEffectStop extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestForceScanEffectStop";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestForceScanEffectStop", true, n"QuestForceScanEffectStop", n"QuestForceScanEffectStop");
  }
}

public class QuestSpotTargetReference extends ActionEntityReference {

  public let m_ForcedTarget: EntityID;

  public final func SetProperties() -> Void {
    let defaultPuppetRef: EntityReference;
    this.actionName = n"QuestSpotTargetReference";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_EntityReference(n"targetPuppetRef", defaultPuppetRef);
  }

  public final func SetPropertiesFromScripts(id: EntityID) -> Void {
    this.m_ForcedTarget = id;
    this.actionName = n"QuestSpotTargetReference";
  }
}

public class QuestFollowTarget extends ActionEntityReference {

  public let m_ForcedTarget: EntityID;

  public final func SetProperties() -> Void {
    let defaultPuppetRef: EntityReference;
    this.actionName = n"QuestFollowTarget";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_EntityReference(n"targetPuppetRef", defaultPuppetRef);
  }

  public final func SetPropertiesFromScripts(id: EntityID) -> Void {
    this.m_ForcedTarget = id;
    this.actionName = n"QuestFollowTarget";
  }
}

public class QuestStopFollowingTarget extends ActionBool {

  public let targetEntityID: EntityID;

  public final func SetProperties() -> Void {
    this.actionName = n"QuestStopFollowingTarget";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestStopFollowingTarget", true, n"QuestStopFollowingTarget", n"QuestStopFollowingTarget");
  }
}

public class QuestLookAtTarget extends ActionEntityReference {

  public let m_ForcedTarget: EntityID;

  public final func SetProperties() -> Void {
    let defaultPuppetRef: EntityReference;
    this.actionName = n"QuestLookAtTarget";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_EntityReference(n"targetPuppetRef", defaultPuppetRef);
  }

  public final func SetPropertiesFromScripts(id: EntityID) -> Void {
    this.m_ForcedTarget = id;
    this.actionName = n"QuestFollowTarget";
  }
}

public class QuestStopLookAtTarget extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestStopLookAtTarget";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestStopLookAtTarget", true, n"QuestStopLookAtTarget", n"QuestStopLookAtTarget");
  }
}

public class QuestSetDetectionToFalse extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestSetDetectionToFalse";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestSetDetectionToFalse", true, n"QuestSetDetectionToFalse", n"QuestSetDetectionToFalse");
  }
}

public class QuestSetDetectionToTrue extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuestSetDetectionToTrue";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuestSetDetectionToTrue", true, n"QuestSetDetectionToTrue", n"QuestSetDetectionToTrue");
  }
}

public class CameraTagSeenEnemies extends ActionBool {

  public func GetBaseCost() -> Int32 {
    if this.m_isQuickHack {
      return this.GetBaseCost();
    };
    return 0;
  }

  public final func SetProperties() -> Void {
    this.actionName = n"CameraTagSeenEnemies";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"CameraTagSeenEnemies", true, n"LocKey#11341", n"LocKey#11341");
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.ChangeToFriendlyIcon");
  }
}
