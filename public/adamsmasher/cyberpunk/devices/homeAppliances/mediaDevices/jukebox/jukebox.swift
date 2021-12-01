
public class JukeboxController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class Jukebox extends InteractiveDevice {

  protected let m_uiComponentBig: wref<IWorldWidgetComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ui", n"worlduiWidgetComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"bigAdvertScreen", n"worlduiWidgetComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ui") as worlduiWidgetComponent;
    this.m_uiComponentBig = EntityResolveComponentsInterface.GetComponent(ri, n"bigAdvertScreen") as worlduiWidgetComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as JukeboxController;
  }

  public final func IsPlaying() -> Bool {
    return (this.GetDevicePS() as JukeboxControllerPS).IsPlaying();
  }

  protected final func PlayGivenStation() -> Void {
    GameObject.AudioSwitch(this, n"radio_station", (this.GetDevicePS() as JukeboxControllerPS).GetActiveStationSoundEvent(), n"radio");
    this.SendDataToUIBlackboard(true);
  }

  protected final func StopPlayingStation() -> Void {
    GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
    this.SendDataToUIBlackboard(false);
  }

  protected cb func OnTogglePlay(evt: ref<TogglePlay>) -> Bool {
    if this.IsPlaying() {
      this.PlayGivenStation();
    } else {
      this.StopPlayingStation();
    };
  }

  protected cb func OnNextStation(evt: ref<NextStation>) -> Bool {
    this.PlayGivenStation();
  }

  protected cb func OnPreviousStation(evt: ref<PreviousStation>) -> Bool {
    this.PlayGivenStation();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.AdvertGlitch(true, this.GetGlitchData(glitchState));
    GameObject.PlaySoundEvent(this, (this.GetDevicePS() as JukeboxControllerPS).GetGlitchSFX());
    this.RefreshUI();
  }

  protected func StopGlitching() -> Void {
    this.AdvertGlitch(false, this.GetGlitchData(EGlitchState.NONE));
  }

  protected func TurnOnDevice() -> Void {
    this.m_uiComponent.Toggle(true);
    this.m_uiComponentBig.Toggle(true);
    this.PlayGivenStation();
    this.UpdateDeviceState();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.m_uiComponent.Toggle(false);
    this.m_uiComponentBig.Toggle(false);
    this.StopPlayingStation();
    this.UpdateDeviceState();
  }

  protected final func AdvertGlitch(start: Bool, data: GlitchData) -> Void {
    this.SimpleGlitch(start);
    this.GetBlackboard().SetVariant(this.GetBlackboardDef().GlitchData, ToVariant(data), true);
    this.GetBlackboard().FireCallbacks();
  }

  protected final func SimpleGlitch(on: Bool) -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    if on {
      evt.SetShouldGlitch(1.00);
    } else {
      evt.SetShouldGlitch(0.00);
    };
    this.QueueEvent(evt);
  }

  protected final func GetGlitchData(glitchState: EGlitchState) -> GlitchData {
    let data: GlitchData;
    data.state = glitchState;
    if NotEquals(glitchState, EGlitchState.NONE) {
      data.intensity = 1.00;
    };
    return data;
  }

  protected final func SendDataToUIBlackboard(isPlaying: Bool) -> Void {
    this.GetBlackboard().SetBool(this.GetBlackboardDef() as JukeboxBlackboardDef.IsPlaying, isPlaying);
    this.GetBlackboard().FireCallbacks();
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().JukeboxBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }
}
