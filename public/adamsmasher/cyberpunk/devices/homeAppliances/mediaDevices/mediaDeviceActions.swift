
public class MediaDeviceStatus extends BaseDeviceStatus {

  public func SetProperties(const deviceRef: ref<ScriptableDeviceComponentPS>) -> Void {
    let statusValue: Int32;
    this.SetProperties(deviceRef);
    statusValue = EnumInt(deviceRef.GetDeviceState());
    this.prop.second = ToVariant((deviceRef as MediaDeviceControllerPS).GetActiveStationName());
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_MediaStatus(n"MediaStatus", statusValue, (deviceRef as MediaDeviceControllerPS).GetActiveStationName());
  }

  public const func GetCurrentDisplayString() -> String {
    let baseStateValue: Int32;
    let channelName: String;
    let str: String;
    if DeviceActionPropertyFunctions.GetProperty_MediaStatus(this.prop, baseStateValue, channelName) {
      if baseStateValue > 1 {
        baseStateValue = 1;
      };
      if baseStateValue > 0 {
        str = "LocKey#2256";
        return str;
      };
      return this.GetCurrentDisplayString();
    };
    Log("MediaDeviceStatus / Problem with acquiring station name");
    return str;
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if MediaDeviceStatus.IsAvailable(device) && MediaDeviceStatus.IsClearanceValid(context.clearance) {
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

public class NextStation extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"NextStation";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Next Station", true, n"LocKey#252", n"LocKey#252");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if NextStation.IsAvailable(device) && NextStation.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return BasicAvailabilityTest(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Next";
  }
}

public class PreviousStation extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"PreviousStation";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"Previous Station", true, n"LocKey#253", n"LocKey#253");
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if PreviousStation.IsAvailable(device) && PreviousStation.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    return BasicAvailabilityTest(device);
  }

  public final static func IsClearanceValid(clearance: ref<Clearance>) -> Bool {
    if Clearance.IsInRange(clearance, DefaultActionsParametersHolder.GetInteractiveClearance()) {
      return true;
    };
    return false;
  }

  public func GetTweakDBChoiceRecord() -> String {
    return "Previous";
  }
}

public class QuestToggleInteractivity extends ActionBool {

  public final func SetProperties(enable: Bool) -> Void {
    if enable {
      this.actionName = n"QuestEnableInteractivity";
    } else {
      this.actionName = n"QuestDisableInteractivity";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, enable, n"QuestToggleInteractivity", n"QuestToggleInteractivity");
  }
}

public class QuestMuteSounds extends ActionBool {

  public final func SetProperties(mute: Bool) -> Void {
    if mute {
      this.actionName = n"QuestMuteSounds";
    } else {
      this.actionName = n"QuestUnMuteSounds";
    };
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(this.actionName, mute, n"QuestMuteSounds", n"QuestMuteSounds");
  }
}

public class QuestSetChannel extends ActionInt {

  public final func SetProperties(channel: Int32) -> Void {
    this.actionName = n"SetChannel";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Int(n"SetChannel", channel);
  }
}

public class QuickHackDistraction extends ActionBool {

  public final func SetProperties() -> Void {
    this.actionName = n"QuickHackDistraction";
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"QuickHackDistraction", true, n"LocKey#6990", n"LocKey#6990");
  }

  public final func SetProperties(interaction: CName) -> Void {
    this.actionName = interaction;
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(interaction, true, interaction, interaction);
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.DistractIcon");
  }
}

public class GlitchScreen extends ActionBool {

  public final func SetProperties(isGlitching: Bool, actionID: TweakDBID, programID: TweakDBID) -> Void {
    let currentDisplayName: CName;
    this.SetAttachedProgramTweakDBID(programID);
    this.SetObjectActionID(actionID);
    currentDisplayName = StringToName(LocKeyToString(this.GetObjectActionRecord().ObjectActionUI().Caption()));
    this.prop = DeviceActionPropertyFunctions.SetUpProperty_Bool(n"GlitchScreen", isGlitching, currentDisplayName, currentDisplayName);
  }

  public const func GetInteractionIcon() -> wref<ChoiceCaptionIconPart_Record> {
    return this.GetInteractionIcon();
  }

  public final static func IsDefaultConditionMet(device: ref<ScriptableDeviceComponentPS>, context: GetActionsContext) -> Bool {
    if GlitchScreen.IsAvailable(device) && GlitchScreen.IsClearanceValid(context.clearance) {
      return true;
    };
    return false;
  }

  public final static func IsAvailable(device: ref<ScriptableDeviceComponentPS>) -> Bool {
    if device.IsDisabled() {
      return false;
    };
    if device.IsUnpowered() {
      return false;
    };
    if device.IsDeviceSecured() {
      return false;
    };
    if !device.IsON() {
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

  public func GetTweakDBChoiceRecord() -> String {
    return this.GetTweakDBChoiceRecord();
  }

  public func GetAttachedProgramTweakDBID() -> TweakDBID {
    if TDBID.IsValid(this.m_attachedProgram) {
      return this.m_attachedProgram;
    };
    return t"QuickHack.DeviceSuicideHack";
  }
}
