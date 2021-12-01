
public class DestructibleMasterLight extends DestructibleMasterDevice {

  private let m_lightComponents: array<ref<gameLightComponent>>;

  private const let m_lightDefinitions: array<LightPreset>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_lightDefinitions) {
      if IsNameValid(this.m_lightDefinitions[i].lightSourcesName) {
        EntityRequestComponentsInterface.RequestComponent(ri, this.m_lightDefinitions[i].lightSourcesName, n"gameLightComponent", true);
      };
      i += 1;
    };
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_lightDefinitions) {
      ArrayPush(this.m_lightComponents, EntityResolveComponentsInterface.GetComponent(ri, this.m_lightDefinitions[i].lightSourcesName) as gameLightComponent);
      this.ApplyPreset(this.m_lightComponents[i], this.m_lightDefinitions[i].preset);
      i += 1;
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as DestructibleMasterLightController;
  }

  protected cb func OnPhysicalDestructionEvent(evt: ref<PhysicalDestructionEvent>) -> Bool {
    super.OnPhysicalDestructionEvent(evt);
    this.GetDevicePS().ForceDisableDevice();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected const func ShouldRegisterToHUD() -> Bool {
    if this.m_forceRegisterInHudManager {
      return true;
    };
    return false;
  }

  private final func ApplyPreset(light: ref<gameLightComponent>, preset: TweakDBID) -> Void {
    let lightSettings: gameLightSettings;
    let presetColor: Color;
    let envLightRecord: ref<EnvLight_Record> = TweakDBInterface.GetEnvLightRecord(preset);
    light.SetTemperature(envLightRecord.Temperature());
    lightSettings = light.GetDefaultSettings();
    lightSettings.intensity = envLightRecord.Intensity();
    lightSettings.radius = envLightRecord.Radius();
    this.CreateColorFromIntArray(envLightRecord.Color(), presetColor);
    lightSettings.color = presetColor;
    light.SetParameters(lightSettings);
  }

  private final func CreateColorFromIntArray(ints: array<Int32>, out color: Color) -> Bool {
    if ArraySize(ints) != 3 {
      if !IsFinal() {
        LogDevices(this, "ElectricLight \\ CreateColorFromIntArray \\ WRONG PRESET PROVIDED - Light for " + this.GetDeviceName() + " has wrong color", ELogType.WARNING);
      };
      color = new Color(255u, 0u, 0u, 255u);
      return false;
    };
    color.Red = Cast(ints[0]);
    color.Green = Cast(ints[1]);
    color.Blue = Cast(ints[2]);
    color.Alpha = 255u;
    return true;
  }

  protected func CutPower() -> Void {
    this.TurnOffLights();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnLights();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffLights();
  }

  private final func TurnOnLights() -> Void {
    let evt: ref<ToggleLightEvent>;
    if Equals(this.GetDevicePS().GetDurabilityState(), EDeviceDurabilityState.BROKEN) {
      return;
    };
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.INDESTRUCTIBLE) {
      GameObjectEffectHelper.StartEffectEvent(this, n"light_on_destr");
    };
    evt = new ToggleLightEvent();
    evt.toggle = true;
    this.QueueEvent(evt);
  }

  private final func TurnOffLights() -> Void {
    let evt: ref<ToggleLightEvent> = new ToggleLightEvent();
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.INDESTRUCTIBLE) {
      GameObjectEffectHelper.StopEffectEvent(this, n"light_on_destr");
    };
    evt.toggle = false;
    this.QueueEvent(evt);
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    if AttackData.IsBullet(hit.attackData.GetAttackType()) || AttackData.IsExplosion(hit.attackData.GetAttackType()) {
      this.ReactToHit(hit);
    };
  }

  protected func ReactToHit(hit: ref<gameHitEvent>) -> Void {
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.INDESTRUCTIBLE) {
      GameObjectEffectHelper.StartEffectEvent(this, n"light_on_destr");
    };
    if Equals(this.GetDevicePS().GetDurabilityType(), EDeviceDurabilityType.DESTRUCTIBLE) {
      this.GetDevicePS().SetDurabilityState(EDeviceDurabilityState.BROKEN);
      this.TurnOffDevice();
    };
  }

  protected cb func OnEMPHitEvent(evt: ref<EMPHitEvent>) -> Bool {
    let empEnded: ref<EMPEnded>;
    if this.IsActive() {
      GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"emp_hit");
      this.ExecuteAction(this.GetDevicePS().ActionSetDeviceUnpowered());
      empEnded = new EMPEnded();
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, empEnded, evt.lifetime);
    };
  }

  protected cb func OnEMPEnded(evt: ref<EMPEnded>) -> Bool {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"emp_hit");
    this.ExecuteAction(this.GetDevicePS().ActionSetDevicePowered());
  }
}
