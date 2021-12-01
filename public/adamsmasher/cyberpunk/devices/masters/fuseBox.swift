
public class FuseBox extends InteractiveMasterDevice {

  private let m_isShortGlitchActive: Bool;

  private let m_shortGlitchDelayID: DelayID;

  @default(FuseBox, 0)
  protected edit let m_numberOfComponentsToON: Int32;

  @default(FuseBox, 0)
  protected edit let m_numberOfComponentsToOFF: Int32;

  protected edit const let m_indexesOfComponentsToOFF: array<Int32>;

  public let m_mesh: ref<MeshComponent>;

  private let m_componentsON: array<ref<IPlacedComponent>>;

  private let m_componentsOFF: array<ref<IPlacedComponent>>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let componentName: String;
    let i: Int32;
    EntityRequestComponentsInterface.RequestComponent(ri, n"stand_generator", n"MeshComponent", false);
    super.OnRequestComponents(ri);
    i = 0;
    while i < this.m_numberOfComponentsToON {
      componentName = "componentON_" + i;
      EntityRequestComponentsInterface.RequestComponent(ri, StringToName(componentName), n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      componentName = "componentOFF_" + i;
      EntityRequestComponentsInterface.RequestComponent(ri, StringToName(componentName), n"IPlacedComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let componentName: String;
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"stand_generator") as MeshComponent;
    let i: Int32 = 0;
    while i < this.m_numberOfComponentsToON {
      componentName = "componentON_" + i;
      ArrayPush(this.m_componentsON, EntityResolveComponentsInterface.GetComponent(ri, StringToName(componentName)) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      componentName = "componentOFF_" + i;
      ArrayPush(this.m_componentsOFF, EntityResolveComponentsInterface.GetComponent(ri, StringToName(componentName)) as IPlacedComponent);
      i += 1;
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as FuseBoxController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.ToggleComponentsON_OFF(false);
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.ToggleComponentsON_OFF(true);
  }

  protected final func ToggleComponentsON_OFF(visible: Bool) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_indexesOfComponentsToOFF) {
      this.m_componentsOFF[this.m_indexesOfComponentsToOFF[i]].Toggle(visible);
      i += 1;
    };
  }

  protected func ResolveGameplayState() -> Void {
    if (this.GetDevicePS() as FuseBoxControllerPS).IsOverloaded() {
      this.ToggleVisibility(false);
    };
    this.ResolveGameplayState();
  }

  protected cb func OnOverloadDevice(evt: ref<OverloadDevice>) -> Bool {
    if evt.IsStarted() {
      this.StartOverloading(evt.GetClassName());
    } else {
      this.StopOverloading();
    };
  }

  private final func StartOverloading(effectName: CName) -> Void {
    let areaEffect: ref<AreaEffectData>;
    let empEffect: ref<EffectInstance>;
    let position: Vector4;
    let actionIndex: Int32 = this.GetFxResourceMapper().GetAreaEffectDataIndexByName(effectName);
    if actionIndex < 0 {
      return;
    };
    areaEffect = this.GetFxResourceMapper().GetAreaEffectDataByIndex(actionIndex);
    position = this.GetAcousticQuerryStartPoint();
    empEffect = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffectStatic(n"emp", n"emp", this);
    EffectData.SetVector(empEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetFloat(empEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, areaEffect.stimRange);
    empEffect.Run();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"emp");
    this.StartGlitching(EGlitchState.DEFAULT, 1.00);
    this.ToggleVisibility(false);
  }

  private final func StopOverloading() -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"smoke");
    if !this.GetDevicePS().IsGlitching() {
      this.StopGlitching();
    };
  }

  protected func ToggleVisibility(visible: Bool) -> Void {
    let i: Int32;
    this.m_mesh.Toggle(visible);
    i = 0;
    while i < this.m_numberOfComponentsToON {
      this.m_componentsON[i].Toggle(!visible);
      i += 1;
    };
    i = 0;
    while i < this.m_numberOfComponentsToOFF {
      this.m_componentsOFF[i].Toggle(visible);
      i += 1;
    };
    this.SetGameplayRoleToNone();
    this.GetDevicePS().ForceDisableDevice();
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    if (this.GetDevicePS() as FuseBoxControllerPS).IsGenerator() {
      return EGameplayRole.Distract;
    };
    if this.GetDevicePS().IsOFF() || this.GetDevicePS().IsDisabled() {
      return IntEnum(1l);
    };
    return EGameplayRole.CutPower;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    let evt: ref<AdvertGlitchEvent>;
    if intensity == 0.00 {
      intensity = 1.00;
    };
    evt = new AdvertGlitchEvent();
    evt.SetShouldGlitch(intensity);
    this.QueueEvent(evt);
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"smoke");
  }

  protected func StopGlitching() -> Void {
    let evt: ref<AdvertGlitchEvent> = new AdvertGlitchEvent();
    evt.SetShouldGlitch(0.00);
    this.QueueEvent(evt);
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"smoke");
  }

  protected cb func OnHitEvent(hit: ref<gameHitEvent>) -> Bool {
    super.OnHitEvent(hit);
    this.StartShortGlitch();
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
      GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Kill, n"smoke");
    };
  }

  protected const func HasAnyDirectInteractionActive() -> Bool {
    if this.IsDead() {
      return false;
    };
    return true;
  }
}
