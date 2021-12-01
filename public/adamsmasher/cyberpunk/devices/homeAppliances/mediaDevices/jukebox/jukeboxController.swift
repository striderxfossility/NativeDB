
public class JukeboxControllerPS extends ScriptableDeviceComponentPS {

  protected let m_jukeboxSetup: JukeboxSetup;

  protected let m_stations: array<RadioStationsMap>;

  protected persistent let m_activeStation: Int32;

  @default(JukeboxControllerPS, true)
  protected let m_isPlaying: Bool;

  protected func Initialize() -> Void {
    this.Initialize();
    this.InitializeStations();
  }

  protected func GameAttached() -> Void {
    this.m_activeStation = EnumInt(this.m_jukeboxSetup.m_startingStation);
  }

  public func GetActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Bool {
    this.GetActions(actions, context);
    if Equals(context.requestType, gamedeviceRequestType.Remote) {
      return false;
    };
    if TogglePlay.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionTogglePlay());
    };
    if NextStation.IsDefaultConditionMet(this, context) {
      ArrayPush(actions, this.ActionPreviousStation());
      ArrayPush(actions, this.ActionNextStation());
    };
    this.SetActionIllegality(actions, this.m_illegalActions.regularActions);
    return true;
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let action: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    action.SetInactiveWithReason(!this.IsDistracting(), "LocKey#7004");
    ArrayPush(actions, action);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final const func GetPaymentRecordID() -> TweakDBID {
    return this.m_jukeboxSetup.m_paymentRecordID;
  }

  protected final func ActionTogglePlay() -> ref<TogglePlay> {
    let action: ref<TogglePlay> = new TogglePlay();
    action.SetUp(this);
    action.SetProperties(!this.m_isPlaying);
    action.AddDeviceName(this.m_deviceName);
    action.CreateActionWidgetPackage();
    return action;
  }

  protected final func ActionPreviousStation() -> ref<PreviousStation> {
    let action: ref<PreviousStation> = new PreviousStation();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetExecutor(GetPlayer(this.GetGameInstance()));
    action.SetInkWidgetTweakDBID(t"DevicesUIDefinitions.JukeboxPreviousActionWidget");
    action.CreateActionWidgetPackage();
    if TDBID.IsValid(this.GetPaymentRecordID()) {
      action.SetObjectActionID(this.GetPaymentRecordID());
    };
    return action;
  }

  public final func ActionNextStation() -> ref<NextStation> {
    let action: ref<NextStation> = new NextStation();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetExecutor(GetPlayer(this.GetGameInstance()));
    action.SetInkWidgetTweakDBID(t"DevicesUIDefinitions.JukeboxNextActionWidget");
    action.CreateActionWidgetPackage();
    if TDBID.IsValid(this.GetPaymentRecordID()) {
      action.SetObjectActionID(this.GetPaymentRecordID());
    };
    return action;
  }

  protected func ActionQuickHackDistraction() -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = this.ActionQuickHackDistraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    return action;
  }

  public final func GetActiveStationIndex() -> Int32 {
    return this.m_activeStation;
  }

  public final func GetActiveStationSoundEvent() -> CName {
    return this.m_stations[this.m_activeStation].soundEvent;
  }

  public final func GetGlitchSFX() -> CName {
    return this.m_jukeboxSetup.m_glitchSFX;
  }

  public final func IsPlaying() -> Bool {
    return this.m_isPlaying;
  }

  public final func OnTogglePlay(evt: ref<TogglePlay>) -> EntityNotificationType {
    if !this.IsON() {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    this.m_isPlaying = FromVariant(evt.prop.first);
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnNextStation(evt: ref<NextStation>) -> EntityNotificationType {
    if !this.IsON() || !evt.CanPayCost(GetPlayer(this.GetGameInstance())) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if this.m_activeStation + 1 == ArraySize(this.m_stations) {
      this.m_activeStation = 0;
    } else {
      this.m_activeStation += 1;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnPreviousStation(evt: ref<PreviousStation>) -> EntityNotificationType {
    if !this.IsON() || !evt.CanPayCost(GetPlayer(this.GetGameInstance())) {
      return EntityNotificationType.DoNotNotifyEntity;
    };
    if this.m_activeStation - 1 < 0 {
      this.m_activeStation = ArraySize(this.m_stations) - 1;
    } else {
      this.m_activeStation -= 1;
    };
    this.UseNotifier(evt);
    return EntityNotificationType.SendThisEventToEntity;
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

  private final func InitializeStations() -> Void {
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_02_aggro_ind", "Gameplay-Devices-Radio-RadioStationAggroIndie"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_03_elec_ind", "Gameplay-Devices-Radio-RadioStationElectroIndie"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_04_hiphop", "Gameplay-Devices-Radio-RadioStationHipHop"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_07_aggro_techno", "Gameplay-Devices-Radio-RadioStationAggroTechno"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_09_downtempo", "Gameplay-Devices-Radio-RadioStationDownTempo"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_01_att_rock", "Gameplay-Devices-Radio-RadioStationAttRock"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_05_pop", "Gameplay-Devices-Radio-RadioStationPop"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_10_latino", "Gameplay-Devices-Radio-RadioStationLatino"));
    ArrayPush(this.m_stations, this.CreateStation(n"radio_station_11_metal", "Gameplay-Devices-Radio-RadioStationMetal"));
  }

  private final func CreateStation(SoundEvt: CName, ChannelName: String) -> RadioStationsMap {
    let station: RadioStationsMap;
    station.soundEvent = SoundEvt;
    station.channelName = ChannelName;
    return station;
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceBackground";
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return GetAllBlackboardDefs().JukeboxBlackboard;
  }
}
