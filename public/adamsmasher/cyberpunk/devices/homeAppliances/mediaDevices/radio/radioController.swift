
public class RadioController extends MediaDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class RadioControllerPS extends MediaDeviceControllerPS {

  protected let m_radioSetup: RadioSetup;

  protected let m_stations: array<RadioStationsMap>;

  private let m_stationsInitialized: Bool;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#96";
    };
    this.InitializeRadioStations();
  }

  protected func GameAttached() -> Void {
    this.InitializeRadioStations();
    this.m_amountOfStations = ArraySize(this.m_stations);
    this.m_activeChannelName = this.m_stations[this.m_activeStation].channelName;
    this.m_isInteractive = this.m_radioSetup.m_isInteractive;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  public final func GetGlitchSFX() -> CName {
    return this.m_radioSetup.m_glitchSFX;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    action.SetDurationValue(this.GetDistractionDuration(action));
    action.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, action);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final const func GetStationByIndex(index: Int32) -> RadioStationsMap {
    let invalidStation: RadioStationsMap;
    if index < 0 || index >= ArraySize(this.m_stations) {
      return invalidStation;
    };
    return this.m_stations[index];
  }

  public func OnNextStation(evt: ref<NextStation>) -> EntityNotificationType {
    this.OnNextStation(evt);
    this.m_activeChannelName = this.m_stations[this.m_activeStation].channelName;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func OnPreviousStation(evt: ref<PreviousStation>) -> EntityNotificationType {
    this.OnPreviousStation(evt);
    this.m_activeChannelName = this.m_stations[this.m_activeStation].channelName;
    return EntityNotificationType.SendThisEventToEntity;
  }

  public func GetActiveStationIndex() -> Int32 {
    if !this.m_dataInitialized {
      this.m_dataInitialized = true;
      this.m_activeStation = EnumInt(this.m_radioSetup.m_startingStation);
    };
    return this.m_activeStation;
  }

  public final const func GetActiveStationEnumValue() -> ERadioStationList {
    let returnValue: ERadioStationList;
    if this.m_activeStation >= 0 && this.m_activeStation < ArraySize(this.m_stations) {
      returnValue = this.m_stations[this.m_activeStation].stationID;
    } else {
      returnValue = ERadioStationList.NONE;
    };
    return returnValue;
  }

  public final func OnSpiderbotDistraction(evt: ref<SpiderbotDistraction>) -> EntityNotificationType {
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func CauseDistraction() -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    this.ExecutePSAction(action);
  }

  protected func ActionQuickHackDistraction() -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = new QuickHackDistraction();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  public func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> EntityNotificationType {
    let type: EntityNotificationType = this.OnQuickHackDistraction(evt);
    if Equals(type, EntityNotificationType.DoNotNotifyEntity) {
      return type;
    };
    if evt.IsStarted() {
      if this.IsOFF() {
        this.ExecutePSAction(this.ActionSetDeviceON());
      };
      this.ExecutePSAction(this.ActionNextStation());
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func PushResaveData(data: RadioResaveData) -> Void;

  private final func InitializeRadioStations() -> Void {
    if this.m_stationsInitialized {
      return;
    };
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_02_aggro_ind", "Gameplay-Devices-Radio-RadioStationAggroIndie", ERadioStationList.AGGRO_INDUSTRIAL));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_03_elec_ind", "Gameplay-Devices-Radio-RadioStationElectroIndie", ERadioStationList.ELECTRO_INDUSTRIAL));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_04_hiphop", "Gameplay-Devices-Radio-RadioStationHipHop", ERadioStationList.HIP_HOP));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_07_aggro_techno", "Gameplay-Devices-Radio-RadioStationAggroTechno", ERadioStationList.AGGRO_TECHNO));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_09_downtempo", "Gameplay-Devices-Radio-RadioStationDownTempo", ERadioStationList.DOWNTEMPO));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_01_att_rock", "Gameplay-Devices-Radio-RadioStationAttRock", ERadioStationList.ATTITUDE_ROCK));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_05_pop", "Gameplay-Devices-Radio-RadioStationPop", ERadioStationList.POP));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_10_latino", "Gameplay-Devices-Radio-RadioStationLatino", ERadioStationList.LATINO));
    ArrayPush(this.m_stations, this.CreateRadioStation(n"radio_station_11_metal", "Gameplay-Devices-Radio-RadioStationMetal", ERadioStationList.METAL));
    this.m_stationsInitialized = true;
  }

  private final func CreateRadioStation(SoundEvt: CName, ChannelName: String, stationID: ERadioStationList) -> RadioStationsMap {
    let station: RadioStationsMap;
    station.soundEvent = SoundEvt;
    station.channelName = ChannelName;
    station.stationID = stationID;
    return station;
  }

  protected func DetermineGameplayViability(context: GetActionsContext, hasActiveActions: Bool) -> Bool {
    return RadioViabilityInterpreter.Evaluate(this, hasActiveActions);
  }

  public func GetDeviceIconPath() -> String {
    return "base/gameplay/gui/brushes/devices/icon_radio.widgetbrush";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceBackground";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceIcon";
  }

  public func GetDeviceWidget(context: GetActionsContext) -> SDeviceWidgetPackage {
    let widgetData: SDeviceWidgetPackage = this.GetDeviceWidget(context);
    widgetData.deviceStatus = "LocKey#42211";
    widgetData.textData = this.GetDeviceStatusTextData();
    return widgetData;
  }
}
