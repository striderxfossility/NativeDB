
public class DiodeControlComponent extends ScriptableComponent {

  private edit const let m_affectedLights: array<CName>;

  @default(DiodeControlComponent, false)
  private let m_lightsState: Bool;

  private let m_primaryLightPreset: DiodeLightPreset;

  private let m_secondaryLightPreset: DiodeLightPreset;

  private let m_secondaryPresetActive: Bool;

  private let m_secondaryPresetRemovalID: DelayID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_affectedLights) {
      if IsNameValid(this.m_affectedLights[i]) {
        EntityRequestComponentsInterface.RequestComponent(ri, this.m_affectedLights[i], n"gameLightComponent", true);
      };
      i += 1;
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    if IsDefined(owner as ScriptedPuppet) && Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Drone) && !StatusEffectSystem.ObjectHasStatusEffect(owner, t"BaseStatusEffect.SystemCollapse") {
      DiodeControlComponent.ActivateLightPreset(owner, TweakDBInterface.GetLightPresetRecord(t"MechanicalLightPreset.Reset"));
    } else {
      DiodeControlComponent.ActivateLightPreset(owner, TweakDBInterface.GetLightPresetRecord(t"MechanicalLightPreset.TurnOff"));
      DiodeControlComponent.ActivateLightPreset(owner, TweakDBInterface.GetLightPresetRecord(t"MechanicalLightPreset.Reset"), 0.20);
    };
  }

  public final static func ActivateLightPreset(owner: ref<GameObject>, lightPreset: wref<LightPreset_Record>, opt delay: Float) -> Void {
    let preset: DiodeLightPreset;
    preset.state = lightPreset.On();
    preset.colorMax = lightPreset.ColorMax();
    preset.colorMin = lightPreset.ColorMin();
    preset.overrideColorMin = lightPreset.OverrideColorMin();
    preset.strength = lightPreset.Strength();
    preset.curve = lightPreset.Curve();
    preset.time = lightPreset.Time();
    preset.loop = lightPreset.Loop();
    preset.duration = lightPreset.Duration();
    preset.force = lightPreset.Force();
    let applyPresetEvent: ref<ApplyDiodeLightPresetEvent> = new ApplyDiodeLightPresetEvent();
    applyPresetEvent.preset = preset;
    if delay <= 0.00 {
      owner.QueueEvent(applyPresetEvent);
    } else {
      GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, applyPresetEvent, delay, true);
    };
  }

  protected cb func OnApplyDiodeLightPresetEvent(evt: ref<ApplyDiodeLightPresetEvent>) -> Bool {
    if evt.preset.duration <= 0.00 && (evt.preset.time <= 0.00 || evt.preset.loop) {
      this.ApplyPrimaryPreset(evt.preset, evt.delay, evt.preset.force);
    } else {
      if evt.preset.duration <= 0.00 && evt.preset.time > 0.00 && !evt.preset.loop {
        evt.preset.duration = evt.preset.time;
      };
      this.ApplySecondaryPreset(evt.preset, evt.delay, evt.preset.duration);
    };
  }

  private final func ApplyPrimaryPreset(preset: DiodeLightPreset, delay: Float, force: Bool) -> Void {
    if this.m_secondaryPresetActive && force {
      this.GetDelaySystem().CancelDelay(this.m_secondaryPresetRemovalID);
      this.m_secondaryLightPreset = new DiodeLightPreset();
      this.m_secondaryPresetActive = false;
    };
    if !this.m_secondaryPresetActive || force {
      this.ApplyPreset(preset, delay);
    };
    this.m_primaryLightPreset = preset;
  }

  private final func ApplySecondaryPreset(preset: DiodeLightPreset, delay: Float, duration: Float) -> Void {
    let removeSecondaryPresetEvent: ref<RemoveSecondaryDiodeLightPresetEvent>;
    if this.m_secondaryPresetActive {
      this.GetDelaySystem().CancelDelay(this.m_secondaryPresetRemovalID);
    };
    this.ApplyPreset(preset, delay);
    this.m_secondaryLightPreset = preset;
    this.m_secondaryPresetActive = true;
    removeSecondaryPresetEvent = new RemoveSecondaryDiodeLightPresetEvent();
    this.m_secondaryPresetRemovalID = this.GetDelaySystem().DelayEvent(this.GetOwner(), removeSecondaryPresetEvent, duration, true);
  }

  protected cb func OnRemoveSecondaryDiodeLightPresetEvent(evt: ref<RemoveSecondaryDiodeLightPresetEvent>) -> Bool {
    this.ApplyPreset(this.m_primaryLightPreset);
    this.m_secondaryLightPreset = new DiodeLightPreset();
    this.m_secondaryPresetActive = false;
  }

  private final func ApplyPreset(preset: DiodeLightPreset, opt delay: Float) -> Void {
    if NotEquals(preset.state, this.m_lightsState) {
      this.ToggleDiodes(preset.state);
    };
    if ArraySize(preset.colorMax) == 0 {
      preset.colorMax = this.m_secondaryPresetActive ? this.m_secondaryLightPreset.colorMax : this.m_primaryLightPreset.colorMax;
      preset.overrideColorMin = true;
    };
    if preset.overrideColorMin {
      this.QueueLightSettings(preset.colorMin, 1.00, 0.00, n"", false, delay);
      this.QueueLightSettings(preset.colorMax, preset.strength, preset.time, preset.curve, preset.loop, delay + 0.01);
    } else {
      this.QueueLightSettings(preset.colorMax, preset.strength, preset.time, preset.curve, preset.loop, delay);
    };
  }

  private final func QueueLightSettings(colorValues: array<Int32>, strength: Float, time: Float, curve: CName, loop: Bool, delay: Float) -> Void {
    let changeSettingsEvent: ref<ChangeDiodeLightSettingsEvent>;
    if delay <= 0.00 {
      this.ChangeLightSettings(colorValues, strength, time, curve, loop);
    } else {
      changeSettingsEvent = new ChangeDiodeLightSettingsEvent();
      changeSettingsEvent.colorValues = colorValues;
      changeSettingsEvent.strength = strength;
      changeSettingsEvent.time = time;
      changeSettingsEvent.curve = curve;
      changeSettingsEvent.loop = loop;
      if delay < 0.10 {
        this.GetDelaySystem().DelayEventNextFrame(this.GetOwner(), changeSettingsEvent);
      } else {
        this.GetDelaySystem().DelayEvent(this.GetOwner(), changeSettingsEvent, delay, true);
      };
    };
  }

  protected cb func OnChangeDiodeLightSettingsEvent(evt: ref<ChangeDiodeLightSettingsEvent>) -> Bool {
    this.ChangeLightSettings(evt.colorValues, evt.strength, evt.time, evt.curve, evt.loop);
  }

  private final func ChangeLightSettings(colorValues: array<Int32>, strength: Float, time: Float, curve: CName, loop: Bool) -> Void {
    let changeSettingsEvent: ref<ChangeLightByNameEvent>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_affectedLights) {
      changeSettingsEvent = new ChangeLightByNameEvent();
      changeSettingsEvent.componentName = this.m_affectedLights[i];
      changeSettingsEvent.settings = new ScriptLightSettings(strength, new Color(Cast(colorValues[0]), Cast(colorValues[1]), Cast(colorValues[2]), Cast(colorValues[3])));
      changeSettingsEvent.time = time;
      changeSettingsEvent.curve = curve;
      changeSettingsEvent.loop = loop;
      this.GetOwner().QueueEvent(changeSettingsEvent);
      i += 1;
    };
  }

  private final func ToggleDiodes(state: Bool) -> Void {
    let toggleLightEvent: ref<ToggleLightByNameEvent>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_affectedLights) {
      toggleLightEvent = new ToggleLightByNameEvent();
      toggleLightEvent.componentName = this.m_affectedLights[i];
      toggleLightEvent.toggle = state;
      this.GetOwner().QueueEvent(toggleLightEvent);
      i += 1;
    };
    this.m_lightsState = state;
  }
}
