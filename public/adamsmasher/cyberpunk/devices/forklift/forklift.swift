
public class forklift extends InteractiveDevice {

  protected let m_animFeature: ref<AnimFeature_ForkliftDevice>;

  protected let m_animationController: ref<AnimationControllerComponent>;

  protected let m_isPlayerUnder: Bool;

  protected let m_cargoBox: ref<PhysicalMeshComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"animController", n"AnimationControllerComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"cargo_box", n"PhysicalMeshComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_animationController = EntityResolveComponentsInterface.GetComponent(ri, n"animController") as AnimationControllerComponent;
    this.m_animationController.Toggle(true);
    this.m_cargoBox = EntityResolveComponentsInterface.GetComponent(ri, n"cargo_box") as PhysicalMeshComponent;
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ForkliftController;
    this.m_isPlayerUnder = false;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.m_animFeature = new AnimFeature_ForkliftDevice();
    this.UpdateAnimState();
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    let forkliftCompleteActivateEvent: ref<ForkliftCompleteActivateEvent> = new ForkliftCompleteActivateEvent();
    if !(this.GetDevicePS() as ForkliftControllerPS).IsForkliftUp() {
      if this.m_isPlayerUnder {
        (GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet).Kill(this);
        this.m_cargoBox.ToggleCollision(false);
      };
    };
    this.UpdateAnimState();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, forkliftCompleteActivateEvent, (this.GetDevicePS() as ForkliftControllerPS).GetLiftingAnimationTime());
  }

  private final func UpdateAnimState() -> Void {
    this.m_animFeature.isDown = !(this.GetDevicePS() as ForkliftControllerPS).IsForkliftUp();
    this.m_animFeature.isUp = (this.GetDevicePS() as ForkliftControllerPS).IsForkliftUp();
    this.m_animFeature.distract = this.GetDevicePS().IsDistracting();
    AnimationControllerComponent.ApplyFeature(this, n"ForkliftAnimFeature", this.m_animFeature);
    if !this.m_wasAnimationFastForwarded {
      this.FastForwardAnimations();
    };
  }

  protected cb func OnForkliftCompleteActivateEvent(evt: ref<ForkliftCompleteActivateEvent>) -> Bool {
    (this.GetDevicePS() as ForkliftControllerPS).ChangeState(EDeviceStatus.ON);
    this.RefreshDeviceInteractions();
  }

  protected final func RefreshDeviceInteractions() -> Void {
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.RefreshInteraction(gamedeviceRequestType.Direct, playerPuppet);
    this.UpdateAnimState();
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.UpdateAnimState();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, n"fx_distraction");
  }

  protected func StopGlitching() -> Void {
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, n"fx_distraction");
    this.RefreshDeviceInteractions();
  }

  protected cb func OnPlayerEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    this.m_isPlayerUnder = true;
  }

  protected cb func OnPlayerExit(evt: ref<AreaExitedEvent>) -> Bool {
    this.m_isPlayerUnder = false;
  }
}
