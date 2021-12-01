
public class Speaker extends InteractiveDevice {

  protected let m_soundEventPlaying: Bool;

  protected let m_soundEvent: CName;

  protected edit let m_effectRef: EffectRef;

  protected let m_deafGameEffect: ref<EffectInstance>;

  protected let m_targets: array<wref<ScriptedPuppet>>;

  protected let m_statusEffect: TweakDBID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SpeakerController;
  }

  protected cb func OnPersitentStateInitialized(evt: ref<GameAttachedEvent>) -> Bool {
    super.OnPersitentStateInitialized(evt);
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.PlayAllSounds();
    this.UpdateDeviceState();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.StopAllSounds();
    this.UpdateDeviceState();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    GameObject.PlaySound(this, (this.GetDevicePS() as SpeakerControllerPS).GetGlitchSFX());
    if (this.GetDevicePS() as SpeakerControllerPS).UseOnlyGlitchSFX() {
      GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
    } else {
      GameObject.AudioSwitch(this, n"radio_station", (this.GetDevicePS() as SpeakerControllerPS).GetCurrentStation(), n"radio");
    };
  }

  protected func StopGlitching() -> Void {
    if (this.GetDevicePS() as SpeakerControllerPS).UseOnlyGlitchSFX() {
      GameObject.StopSound(this, (this.GetDevicePS() as SpeakerControllerPS).GetGlitchSFX());
    };
    GameObject.AudioSwitch(this, n"radio_station", (this.GetDevicePS() as SpeakerControllerPS).GetCurrentStation(), n"radio");
    this.StopGameEffect();
  }

  protected cb func OnChangeMusicAction(evt: ref<ChangeMusicAction>) -> Bool {
    let settings: ref<MusicSettings> = evt.GetMusicSettings();
    this.StopAllSounds();
    if IsDefined(settings as PlayRadio) {
      this.m_soundEventPlaying = false;
      (this.GetDevicePS() as SpeakerControllerPS).SetCurrentStation(settings.GetSoundName());
    } else {
      if IsDefined(settings as PlaySoundEvent) {
        this.m_soundEventPlaying = true;
        this.m_soundEvent = settings.GetSoundName();
      };
    };
    if this.GetDevicePS().IsON() {
      this.PlayAllSounds();
      this.StartGameEffect(settings.GetStatusEffect());
    };
  }

  protected final func StopAllSounds() -> Void {
    if this.m_soundEventPlaying {
      GameObject.StopSound(this, this.m_soundEvent);
    } else {
      GameObject.AudioSwitch(this, n"radio_station", n"station_none", n"radio");
    };
  }

  protected final func PlayAllSounds() -> Void {
    if this.m_soundEventPlaying {
      GameObject.PlaySound(this, this.m_soundEvent);
    } else {
      GameObject.AudioSwitch(this, n"radio_station", (this.GetDevicePS() as SpeakerControllerPS).GetCurrentStation(), n"radio");
    };
  }

  protected final func StartGameEffect(effect: ESoundStatusEffects) -> Void {
    let evt: ref<DelayEvent>;
    let newStatusEffect: TweakDBID;
    this.StopGameEffect();
    if Equals(effect, ESoundStatusEffects.DEAFENED) {
      newStatusEffect = t"BaseStatusEffect.Deaf";
    } else {
      if Equals(effect, ESoundStatusEffects.SUPRESS_NOISE) {
        newStatusEffect = t"BaseStatusEffect.SuppressNoise";
      };
    };
    this.m_statusEffect = newStatusEffect;
    if TDBID.IsValid(this.m_statusEffect) {
      evt = new DelayEvent();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 1.00);
    };
  }

  protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
    this.CreateGameEffect();
  }

  protected final func CreateGameEffect() -> Void {
    this.m_deafGameEffect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(this.m_effectRef, this);
    EffectData.SetFloat(this.m_deafGameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, (this.GetDevicePS() as SpeakerControllerPS).GetRange());
    EffectData.SetVector(this.m_deafGameEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, this.GetAcousticQuerryStartPoint());
    this.m_deafGameEffect.Run();
  }

  protected final func StopGameEffect() -> Void {
    let i: Int32;
    if TDBID.IsValid(this.m_statusEffect) {
      i = 0;
      while i < ArraySize(this.m_targets) {
        this.RemoveStatusEffect(this.m_targets[i]);
        i += 1;
      };
    };
    if IsDefined(this.m_deafGameEffect) {
      this.m_deafGameEffect.Terminate();
      this.m_deafGameEffect = null;
    };
    ArrayClear(this.m_targets);
  }

  protected cb func OnTargetAcquired(evt: ref<TargetAcquiredEvent>) -> Bool {
    if !ArrayContains(this.m_targets, evt.target) {
      ArrayPush(this.m_targets, evt.target);
    };
    this.ApplyStatusEffect(evt.target);
  }

  protected cb func OnTargetLost(evt: ref<TargetLostEvent>) -> Bool {
    let i: Int32 = ArrayFindFirst(this.m_targets, evt.target);
    if i >= 0 {
      ArrayErase(this.m_targets, i);
    };
    this.RemoveStatusEffect(evt.target);
  }

  protected final func ApplyStatusEffect(target: wref<GameObject>) -> Void {
    if TDBID.IsValid(this.m_statusEffect) {
      StatusEffectHelper.ApplyStatusEffect(target, this.m_statusEffect, this.GetEntityID());
    };
  }

  protected final func RemoveStatusEffect(target: wref<GameObject>) -> Void {
    if TDBID.IsValid(this.m_statusEffect) {
      StatusEffectHelper.RemoveStatusEffect(target, this.m_statusEffect);
    };
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
