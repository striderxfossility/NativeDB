
public class SpeakerController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class SpeakerControllerPS extends ScriptableDeviceComponentPS {

  protected let m_speakerSetup: SpeakerSetup;

  private let m_currentValue: CName;

  private let m_previousValue: CName;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
    if !IsStringValid(this.m_deviceName) {
      this.m_deviceName = "LocKey#166";
    };
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void {
    this.m_currentValue = this.GetSoundName(this.m_speakerSetup.m_defaultMusic);
  }

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionQuickHackDistraction();
    currentAction.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    ArrayPush(actions, currentAction);
    if this.IsGlitching() || this.IsDistracting() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7004");
    };
    if !this.IsPowered() {
      ScriptableDeviceComponentPS.SetActionsInactiveAll(actions, "LocKey#7013");
    };
    this.FinalizeGetQuickHackActions(actions, context);
  }

  public final func GetGlitchSFX() -> CName {
    return this.m_speakerSetup.m_glitchSFX;
  }

  public final func UseOnlyGlitchSFX() -> Bool {
    return this.m_speakerSetup.m_useOnlyGlitchSFX;
  }

  public final func GetCurrentStation() -> CName {
    return this.m_currentValue;
  }

  public final func SetCurrentStation(station: CName) -> Void {
    this.m_currentValue = station;
  }

  public final func GetRange() -> Float {
    return this.m_speakerSetup.m_range;
  }

  protected func ActionQuickHackDistraction() -> ref<QuickHackDistraction> {
    let action: ref<QuickHackDistraction> = new QuickHackDistraction();
    action.SetUp(this);
    action.SetProperties();
    action.AddDeviceName(this.m_deviceName);
    action.SetObjectActionID(t"DeviceAction.MalfunctionClassHack");
    action.CreateInteraction();
    action.SetDurationValue(this.GetDistractionDuration(action));
    return action;
  }

  public func OnQuickHackDistraction(evt: ref<QuickHackDistraction>) -> EntityNotificationType {
    let type: EntityNotificationType = this.OnQuickHackDistraction(evt);
    if Equals(type, EntityNotificationType.DoNotNotifyEntity) {
      return type;
    };
    if this.IsOFF() {
      this.ExecutePSAction(this.ActionToggleON());
    };
    if evt.IsStarted() {
      this.m_previousValue = this.m_currentValue;
      this.m_currentValue = this.GetSoundName(this.m_speakerSetup.m_distractionMusic);
    } else {
      this.m_currentValue = this.m_previousValue;
    };
    return EntityNotificationType.SendThisEventToEntity;
  }

  public final func OnChangeMusicAction(evt: ref<ChangeMusicAction>) -> EntityNotificationType {
    let notifier: ref<ActionNotifier>;
    if this.IsPowered() {
      notifier = new ActionNotifier();
      notifier.SetNone();
      if this.IsOFF() {
        this.ExecutePSAction(this.ActionToggleON());
      };
      this.Notify(notifier, evt);
      return EntityNotificationType.SendThisEventToEntity;
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  protected final func CreateDeafeningMusic() -> ref<MusicSettings> {
    let music: ref<PlayRadio> = new PlayRadio();
    music.SetStatusEffect(ESoundStatusEffects.DEAFENED);
    music.SetSoundName(this.m_speakerSetup.m_distractionMusic);
    return music;
  }

  protected final func GetSoundName(music: ERadioStationList) -> CName {
    if Equals(music, ERadioStationList.AGGRO_INDUSTRIAL) {
      return n"radio_station_02_aggro_ind";
    };
    if Equals(music, ERadioStationList.ELECTRO_INDUSTRIAL) {
      return n"radio_station_03_elec_ind";
    };
    if Equals(music, ERadioStationList.HIP_HOP) {
      return n"radio_station_04_hiphop";
    };
    if Equals(music, ERadioStationList.AGGRO_TECHNO) {
      return n"radio_station_07_aggro_techno";
    };
    if Equals(music, ERadioStationList.DOWNTEMPO) {
      return n"radio_station_09_downtempo";
    };
    if Equals(music, ERadioStationList.ATTITUDE_ROCK) {
      return n"radio_station_01_att_rock";
    };
    if Equals(music, ERadioStationList.POP) {
      return n"radio_station_05_pop";
    };
    if Equals(music, ERadioStationList.LATINO) {
      return n"radio_station_10_latino";
    };
    if Equals(music, ERadioStationList.METAL) {
      return n"radio_station_11_metal";
    };
    return n"station_none";
  }

  protected func GetDeviceIconTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceIcon";
  }

  protected func GetBackgroundTextureTweakDBID() -> TweakDBID {
    return t"DeviceIcons.RadioDeviceBackground";
  }
}
