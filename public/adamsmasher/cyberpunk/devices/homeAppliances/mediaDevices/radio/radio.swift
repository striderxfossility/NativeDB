
public class Radio extends InteractiveDevice {

  private let m_stations: array<RadioStationsMap>;

  private let m_startingStation: Int32;

  private let m_isInteractive: Bool;

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"audio", n"soundComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"radio_ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"radio_ui") as worlduiWidgetComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as RadioController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  protected cb func OnToggleON(evt: ref<ToggleON>) -> Bool {
    super.OnToggleON(evt);
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnTogglePower(evt: ref<TogglePower>) -> Bool {
    super.OnTogglePower(evt);
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    let mediaData: MediaResaveData;
    let psDevice: ref<RadioControllerPS>;
    let radioData: RadioResaveData;
    this.ResavePersistentData(ps);
    mediaData.m_mediaDeviceData.m_initialStation = this.m_startingStation;
    mediaData.m_mediaDeviceData.m_amountOfStations = ArraySize(this.m_stations);
    mediaData.m_mediaDeviceData.m_activeChannelName = this.m_stations[this.m_startingStation].channelName;
    mediaData.m_mediaDeviceData.m_isInteractive = this.m_isInteractive;
    radioData.m_mediaResaveData = mediaData;
    radioData.m_stations = this.m_stations;
    psDevice.PushResaveData(radioData);
    return true;
  }

  protected func RestoreDeviceState() -> Void {
    this.RestoreDeviceState();
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  private final func PlayGivenStation() -> Void {
    let isMetal: Bool;
    let stationIndex: Int32 = (this.GetDevicePS() as RadioControllerPS).GetActiveStationIndex();
    let station: RadioStationsMap = (this.GetDevicePS() as RadioControllerPS).GetStationByIndex(stationIndex);
    GameObject.AudioSwitch(this, n"radio_station", station.soundEvent, n"radio");
    isMetal = Equals(station.soundEvent, n"radio_station_11_metal") ? true : false;
    this.MetalItUp(isMetal);
  }

  private final func MetalItUp(isMetal: Bool) -> Void {
    if NotEquals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.INVULNERABLE) {
      if isMetal {
        this.GetDevicePS().SetDurabilityType(EDeviceDurabilityType.INDESTRUCTIBLE);
      } else {
        this.GetDevicePS().SetDurabilityType(EDeviceDurabilityType.DESTRUCTIBLE);
      };
    };
  }

  protected cb func OnNextStation(evt: ref<NextStation>) -> Bool {
    this.PlayGivenStation();
    this.UpdateDeviceState();
    this.RefreshUI();
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnPreviousStation(evt: ref<PreviousStation>) -> Bool {
    this.PlayGivenStation();
    this.UpdateDeviceState();
    this.RefreshUI();
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnQuestSetChannel(evt: ref<QuestSetChannel>) -> Bool {
    this.PlayGivenStation();
    this.RefreshUI();
  }

  protected cb func OnSpiderbotDistraction(evt: ref<SpiderbotDistraction>) -> Bool {
    this.OrderSpiderbot();
  }

  protected cb func OnSpiderbotOrderCompletedEvent(evt: ref<SpiderbotOrderCompletedEvent>) -> Bool {
    this.SendSetIsSpiderbotInteractionOrderedEvent(false);
    GameInstance.GetActivityLogSystem(this.GetGame()).AddLog("SPIDERBOT HAS FINISHED ACTIVATING THE DEVICE ... ");
    (this.GetDevicePS() as RadioControllerPS).CauseDistraction();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    if IsDefined(this.m_uiComponent) {
      this.m_uiComponent.Toggle(true);
    };
    this.PlayGivenStation();
    this.UpdateDeviceState();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"radio_idle");
    this.RefreshUI();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
    this.UpdateDeviceState();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"radio_idle");
    this.RefreshUI();
  }

  protected func CutPower() -> Void {
    this.CutPower();
    if IsDefined(this.m_uiComponent) {
      this.m_uiComponent.Toggle(false);
    };
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"radio_idle");
    this.UpdateDeviceState();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    if IsDefined(this.m_uiComponent) {
      this.m_uiComponent.Toggle(false);
    };
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Kill, n"radio_idle");
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    this.UpdateDeviceState();
    GameObject.PlaySound(this, (this.GetDevicePS() as RadioControllerPS).GetGlitchSFX());
  }

  protected func StopGlitching() -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
  }

  private final func StartShortGlitch() -> Void {
    let evt: ref<StopShortGlitchEvent>;
    if this.GetDevicePS().IsGlitching() {
      return;
    };
    if !this.m_isShortGlitchActive {
      evt = new StopShortGlitchEvent();
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
      this.m_shortGlitchDelayID = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.25);
      this.m_isShortGlitchActive = true;
    };
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
  }
}
