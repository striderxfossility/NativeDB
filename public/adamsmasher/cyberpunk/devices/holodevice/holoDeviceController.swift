
public class HoloDeviceController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class HoloDeviceControllerPS extends ScriptableDeviceComponentPS {

  private persistent let m_isPlaying: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#222";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func ActionTogglePlay() -> ref<TogglePlay> {
    let action: ref<TogglePlay> = new TogglePlay();
    action.clearanceLevel = DefaultActionsParametersHolder.GetInteractiveClearance();
    action.SetUp(this);
    action.SetProperties(this.m_isPlaying);
    action.AddDeviceName(this.m_deviceName);
    return action;
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if !this.IsUserAuthorized(context.processInitiatorObject.GetEntityID()) {
      return false;
    };
    if TogglePlay.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionTogglePlay());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  public final func OnPlay(evt: ref<TogglePlay>) -> EntityNotificationType {
    let cachedStatus: ref<BaseDeviceStatus> = this.GetDeviceStatusAction();
    if this.IsUnpowered() || this.IsDisabled() {
      return this.SendActionFailedEvent(evt, evt.GetRequesterID(), "Disabled or Unpowered");
    };
    this.m_isPlaying = !this.m_isPlaying;
    evt.prop.first = ToVariant(this.m_isPlaying);
    this.UseNotifier(evt);
    if !IsFinal() {
      this.LogActionDetails(evt, cachedStatus);
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public const func GetClearance() -> ref<Clearance> {
    return Clearance.CreateClearance(2, 2);
  }

  public final func IsPlaying() -> Bool {
    return this.m_isPlaying;
  }

  protected func LogActionDetails(action: ref<ScriptableDeviceAction>, cachedStatus: ref<BaseDeviceStatus>, opt context: String, opt status: String, opt overrideStatus: Bool) -> Void {
    if this.IsLogInExclusiveMode() && !this.m_debugDevice {
      return;
    };
    this.LogActionDetails(action, cachedStatus, context);
    Log("isPlaying type........ " + BoolToString(this.m_isPlaying));
  }
}
