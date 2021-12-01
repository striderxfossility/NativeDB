
public class NcartTimetableController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class NcartTimetableControllerPS extends ScriptableDeviceComponentPS {

  private let m_ncartTimetableSetup: NcartTimetableSetup;

  private persistent let m_currentTimeToDepart: Int32;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#1653";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
    this.ResetTimeToDepart();
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenSuicide", t"QuickHack.DeviceSuicideHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenBlind", t"QuickHack.BlindHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenHeartAttack", t"QuickHack.HeartAttackHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    currentAction = this.ActionGlitchScreen(t"DeviceAction.GlitchScreenGrenade", t"QuickHack.GrenadeHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    ArrayPush(outActions, currentAction);
    if !GlitchScreen.IsDefaultConditionMet(this, context) {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7003");
    };
    currentAction = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    currentAction.SetDurationValue(this.GetDistractionDuration(currentAction));
    currentAction.SetInactiveWithReason(ScriptableDeviceAction.IsDefaultConditionMet(this, context), "LocKey#7003");
    ArrayPush(outActions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(outActions, "LocKey#7004");
    };
    this.FinalizeGetQuickHackActions(outActions, context);
  }

  public func GetQuestActions(out outActions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    this.GetQuestActions(outActions, context);
  }

  public final const func GetDepartFrequency() -> Int32 {
    return this.m_ncartTimetableSetup.departFrequency;
  }

  public final const func GetUiUpdateFrequency() -> Float {
    return Cast(this.m_ncartTimetableSetup.uiUpdateFrequency);
  }

  public final const func GetCurrentTimeToDepart() -> Int32 {
    return this.m_currentTimeToDepart;
  }

  public final const func GetCurrentTimeToDepartAsString() -> String {
    let secondString: String;
    let timeString: String;
    let time: GameTime = GameTime.MakeGameTime(0, 0, 0, this.m_currentTimeToDepart);
    let seconds: Int32 = GameTime.Seconds(time);
    if seconds < 10 {
      secondString = "0" + IntToString(seconds);
    } else {
      secondString = IntToString(seconds);
    };
    timeString = IntToString(GameTime.Minutes(time)) + ":" + secondString;
    return timeString;
  }

  public final func UpdateCurrentTimeToDepart() -> Void {
    this.m_currentTimeToDepart -= this.m_ncartTimetableSetup.uiUpdateFrequency;
    if this.m_currentTimeToDepart <= 0 {
      this.ResetTimeToDepart();
    };
  }

  private final func ResetTimeToDepart() -> Void {
    let time: GameTime = GameTime.MakeGameTime(0, 0, this.m_ncartTimetableSetup.departFrequency, 0);
    this.m_currentTimeToDepart = GameTime.GetSeconds(time);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().NcartTimetableBlackboard;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }
}
