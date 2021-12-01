
public class SetGlobalTvChannel extends Event {

  @attrib(customEditor, "TweakDBGroupInheritance;ChannelData")
  public edit let m_channel: TweakDBID;

  public final func GetFriendlyDescription() -> String {
    return "Set Global TV Channel";
  }
}

public class SetGlobalTvOnly extends Event {

  public edit let m_isGlobalTvOnly: Bool;

  public final func GetFriendlyDescription() -> String {
    return "Set Global TV Only";
  }
}

public class TV extends InteractiveDevice {

  private let m_channels: array<STvChannel>;

  private let m_initialActiveChannel: Int32;

  @default(TV, SECURED)
  private let m_securedText: String;

  private let m_isInteractive: Bool;

  @default(TV, true)
  private let m_muteInterface: Bool;

  @default(TV, false)
  private let useWhiteNoiseFX: Bool;

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  protected edit let m_isTVMoving: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"tv_ui", n"worlduiWidgetComponent", false);
    super.OnRequestComponents(ri);
  }

  protected func PushPersistentData() -> Void {
    let data: MediaDeviceData;
    this.PushPersistentData();
    if this.m_initialActiveChannel >= 0 && this.m_initialActiveChannel <= ArraySize(this.m_channels) {
      data.m_initialStation = this.m_initialActiveChannel;
    } else {
      data.m_initialStation = 0;
    };
    data.m_amountOfStations = ArraySize(this.m_channels);
    data.m_activeChannelName = this.GetChannelName(this.m_initialActiveChannel);
    data.m_isInteractive = this.m_isInteractive;
    (this.GetDevicePS() as TVControllerPS).PushPersistentData(data);
  }

  public func ResavePersistentData(ps: ref<PersistentState>) -> Bool {
    let mediaData: MediaResaveData;
    let psDevice: ref<TVControllerPS>;
    let tvData: TVResaveData;
    this.ResavePersistentData(ps);
    psDevice = ps as TVControllerPS;
    mediaData.m_mediaDeviceData.m_initialStation = this.m_initialActiveChannel;
    mediaData.m_mediaDeviceData.m_amountOfStations = ArraySize(this.m_channels);
    mediaData.m_mediaDeviceData.m_activeChannelName = this.GetChannelName(this.m_initialActiveChannel);
    mediaData.m_mediaDeviceData.m_isInteractive = this.m_isInteractive;
    tvData.m_mediaResaveData = mediaData;
    tvData.m_channels = this.m_channels;
    tvData.m_securedText = StringToName(this.m_securedText);
    tvData.m_muteInterface = this.m_muteInterface;
    tvData.m_useWhiteNoiseFX = this.useWhiteNoiseFX;
    psDevice.PushResaveData(tvData);
    return true;
  }

  protected func IsDeviceMovableScript() -> Bool {
    return this.m_isTVMoving;
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_uiComponent = EntityResolveComponentsInterface.GetComponent(ri, n"tv_ui") as worlduiWidgetComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as TVController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if (this.GetDevicePS() as TVControllerPS).IsInterfaceMuted() {
      this.ToggleSoundEmmiter(true);
    };
    if !this.GetDevicePS().IsInteractive() {
      this.ToggleDirectLayer(false);
    };
    if this.IsUIdirty() && this.m_isInsideLogicArea {
      this.RefreshUI();
    };
  }

  public const func IsReadyForUI() -> Bool {
    return this.m_isVisible || this.GetDevicePS().ForceResolveGameplayStateOnAttach();
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    GameInstance.GetGlobalTVSystem(this.GetGame()).UnregisterTVChannelFromEntity(this);
  }

  protected func CreateBlackboard() -> Void {
    this.m_blackboard = IBlackboard.Create(GetAllBlackboardDefs().TVDeviceBlackboard);
  }

  public const func GetBlackboardDef() -> ref<DeviceBaseBlackboardDef> {
    return this.GetDevicePS().GetBlackboardDef();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public final const func IsInteractive() -> Bool {
    return this.GetDevicePS().IsInteractive();
  }

  protected cb func OnToggleON(evt: ref<ToggleON>) -> Bool {
    super.OnToggleON(evt);
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnTogglePower(evt: ref<TogglePower>) -> Bool {
    super.OnTogglePower(evt);
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnNextChannel(evt: ref<NextStation>) -> Bool {
    let currentIndex: Int32 = (this.GetDevicePS() as TVControllerPS).GetActiveStationIndex();
    this.SelectChannel(currentIndex);
    (this.GetDevicePS() as TVControllerPS).PassChannelName(this.GetChannelName(currentIndex));
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnPreviousChannel(evt: ref<PreviousStation>) -> Bool {
    let currentIndex: Int32 = (this.GetDevicePS() as TVControllerPS).GetActiveStationIndex();
    this.SelectChannel(currentIndex);
    (this.GetDevicePS() as TVControllerPS).PassChannelName(this.GetChannelName(currentIndex));
    this.TriggerArreaEffectDistraction(this.GetDefaultDistractionAreaEffectData(), evt.GetExecutor());
  }

  protected cb func OnQuestSetChannel(evt: ref<QuestSetChannel>) -> Bool {
    this.SelectChannel((this.GetDevicePS() as TVControllerPS).GetActiveStationIndex());
  }

  protected cb func OnQuestSetGlobalChannel(evt: ref<SetGlobalTvChannel>) -> Bool {
    let idx: Int32 = (this.GetDevicePS() as TVControllerPS).GetGlobalTVChannelIDX(evt.m_channel);
    if idx >= 0 {
      (this.GetDevicePS() as TVControllerPS).SetActiveStationIndex(idx);
      this.SelectChannel(idx);
    };
  }

  protected cb func OnQuestSetGlobalTvOnly(evt: ref<SetGlobalTvOnly>) -> Bool {
    (this.GetDevicePS() as TVControllerPS).SetIsGlobalTvOnly(evt.m_isGlobalTvOnly);
    this.SelectChannel((this.GetDevicePS() as TVControllerPS).GetActiveStationIndex());
  }

  public final const func GetDefaultGlitchVideoPath() -> ResRef {
    return (this.GetDevicePS() as TVControllerPS).GetDefaultGlitchVideoPath();
  }

  public final const func GetBroadcastGlitchVideoPath() -> ResRef {
    return (this.GetDevicePS() as TVControllerPS).GetBroadcastGlitchVideoPath();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    let glitchData: GlitchData;
    glitchData.state = glitchState;
    glitchData.intensity = intensity;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().TVDeviceBlackboard.GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObject.PlaySound(this, n"dev_screen_glitch_distraction");
  }

  protected func StopGlitching() -> Void {
    let glitchData: GlitchData;
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    glitchData.state = EGlitchState.NONE;
    this.GetBlackboard().SetVariant(GetAllBlackboardDefs().TVDeviceBlackboard.GlitchData, ToVariant(glitchData));
    this.GetBlackboard().FireCallbacks();
    GameObject.StopSound(this, n"dev_screen_glitch_distraction");
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
  }

  protected cb func OnStopShortGlitch(evt: ref<StopShortGlitchEvent>) -> Bool {
    this.m_isShortGlitchActive = false;
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
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

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnScreen();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffScreen();
  }

  private final func ToggleSoundEmmiter(mute: Bool) -> Void {
    if mute {
      GameObject.PlaySound(this, n"mute_tv_emitter");
    } else {
      GameObject.PlaySound(this, n"unmute_tv_emitterr");
    };
  }

  private final func SelectChannel(currentChannelIDX: Int32) -> Void {
    this.GetBlackboard().SetInt(GetAllBlackboardDefs().TVDeviceBlackboard.CurrentChannel, currentChannelIDX);
    this.GetBlackboard().FireCallbacks();
  }

  private final const func GetChannelName(index: Int32) -> String {
    return (this.GetDevicePS() as TVControllerPS).GetChannelName(index);
  }

  private final func SelectChannel(channelName: String) -> Void {
    let channelId: Int32 = this.GetChannelId(channelName);
    this.GetBlackboard().SetInt(GetAllBlackboardDefs().TVDeviceBlackboard.CurrentChannel, channelId);
  }

  private final func GetChannelId(channelName: String) -> Int32 {
    return (this.GetDevicePS() as TVControllerPS).GetChannelID(channelName);
  }

  public final const func GetChannelData(channelIDX: Int32) -> STvChannel {
    return (this.GetDevicePS() as TVControllerPS).GetChannelData(channelIDX);
  }

  protected func TurnOffScreen() -> Void {
    this.m_uiComponent.Toggle(false);
    GameInstance.GetGlobalTVSystem(this.GetGame()).UnregisterTVChannelFromEntity(this);
    this.ToggleSoundEmmiter(true);
    this.RefreshUI();
  }

  protected func TurnOnScreen() -> Void {
    this.m_uiComponent.Toggle(true);
    if !(this.GetDevicePS() as TVControllerPS).IsInterfaceMuted() {
      this.ToggleSoundEmmiter(false);
    };
    this.RefreshUI();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Distract;
  }

  protected func ApplyActiveStatusEffect(target: EntityID, statusEffect: TweakDBID) -> Void {
    if this.IsActiveStatusEffectValid() && this.GetDevicePS().IsGlitching() {
      GameInstance.GetStatusEffectSystem(this.GetGame()).ApplyStatusEffect(target, statusEffect);
    };
  }

  protected func UploadActiveProgramOnNPC(targetID: EntityID) -> Void {
    let evt: ref<ExecutePuppetActionEvent>;
    if this.IsActiveProgramToUploadOnNPCValid() && this.GetDevicePS().IsGlitching() {
      evt = new ExecutePuppetActionEvent();
      evt.actionID = this.GetActiveProgramToUploadOnNPC();
      this.QueueEventForEntityID(targetID, evt);
    };
  }

  protected cb func OnQuestMuteSounds(evt: ref<QuestMuteSounds>) -> Bool {
    this.ToggleSoundEmmiter((this.GetDevicePS() as TVControllerPS).IsInterfaceMuted());
  }

  protected cb func OnQuestToggleInteractivity(evt: ref<QuestToggleInteractivity>) -> Bool;

  public final const func GetGlobalTVChannels() -> array<wref<ChannelData_Record>> {
    return (this.GetDevicePS() as TVControllerPS).GetGlobalTVChannels();
  }
}
