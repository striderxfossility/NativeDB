
public class BillboardDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class BillboardDeviceControllerPS extends ScriptableDeviceComponentPS {

  @attrib(category, "Audio")
  @attrib(customEditor, "AudioEvent")
  @default(BillboardDeviceControllerPS, amb_int_custom_megabuilding_01_adverts_interactive_nicola_01_select_q110)
  public let m_glitchSFX: CName;

  @attrib(category, "Lightning")
  @default(BillboardDeviceControllerPS, true)
  public let m_useLights: Bool;

  @attrib(category, "Lightning")
  public const let m_lightsSettings: array<EditableGameLightSettings>;

  @attrib(category, "Appearances")
  @default(BillboardDeviceControllerPS, true)
  public let m_useDeviceAppearence: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "Gameplay-Devices-DisplayNames-Billboard";
    };
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

  public const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(2, 2);
  }

  public final const func GetGlitchSFX() -> CName {
    return this.m_glitchSFX;
  }

  public final const func IsUsingLights() -> Bool {
    return this.m_useLights;
  }

  public final const func IsUsingDeviceAppearence() -> Bool {
    return this.m_useDeviceAppearence;
  }

  public final const func GetLightsSettings() -> array<EditableGameLightSettings> {
    return this.m_lightsSettings;
  }

  protected func LogActionDetails(action: ref<ScriptableDeviceAction>, cachedStatus: ref<BaseDeviceStatus>, opt context: String, opt status: String, opt overrideStatus: Bool) -> Void {
    if this.IsLogInExclusiveMode() && !this.m_debugDevice {
      return;
    };
    this.LogActionDetails(action, cachedStatus, context);
    Log("isPlaying type........ " + BoolToString(this.m_isGlitching));
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.ScreenDeviceIcon";
  }
}
