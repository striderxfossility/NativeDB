
public class ActivatedDeviceTransfromAnim extends InteractiveDevice {

  private let m_animationState: Int32;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceController;
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    if !this.GetDevicePS().IsON() {
      this.m_animationState = 1;
      this.RefreshAnimation();
    };
  }

  protected func UpdateDeviceState(opt isDelayed: Bool) -> Bool {
    if this.UpdateDeviceState(isDelayed) {
      this.RefreshAnimation();
      return true;
    };
    return false;
  }

  protected const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    this.SetGameplayRoleToNone();
    this.RefreshAnimation();
    if (this.GetDevicePS() as ActivatedDeviceControllerPS).ShouldGlitchOnActivation() {
      this.StartGlitching(EGlitchState.DEFAULT, 1.00);
    };
  }

  protected cb func OnSpiderbotOrderCompletedEvent(evt: ref<SpiderbotOrderCompletedEvent>) -> Bool {
    this.SendSetIsSpiderbotInteractionOrderedEvent(false);
    GameInstance.GetActivityLogSystem(this.GetGame()).AddLog("SPIDERBOT HAS FINISHED ACTIVATING THE DEVICE ... ");
    (this.GetDevicePS() as ActivatedDeviceControllerPS).ActivateThisDevice();
    this.SetGameplayRoleToNone();
  }

  protected func RefreshAnimation() -> Void {
    let playEvent: ref<gameTransformAnimationPlayEvent> = new gameTransformAnimationPlayEvent();
    if this.GetDevicePS().IsDisabled() {
      this.SendSimpleAnimFeature(true, false, false);
      playEvent.animationName = n"disable";
      this.m_animationState = 0;
    } else {
      if this.GetDevicePS().IsON() && this.m_animationState == 0 || this.GetDevicePS().IsDistracting() {
        this.SendSimpleAnimFeature(true, false, false);
        playEvent.animationName = n"activate";
        this.m_animationState = 1;
      } else {
        if !this.GetDevicePS().IsON() && this.m_animationState == 1 {
          this.SendSimpleAnimFeature(false, false, false);
          playEvent.animationName = n"deactivate";
          this.m_animationState = 0;
        };
      };
    };
    playEvent.looping = false;
    playEvent.timesPlayed = 1u;
    playEvent.timeScale = (this.GetDevicePS() as ActivatedDeviceControllerPS).GetAnimationTime();
    if !this.m_wasAnimationFastForwarded {
      playEvent.timeScale = 100.00;
      this.m_wasAnimationFastForwarded = true;
    };
    this.QueueEvent(playEvent);
  }

  protected final func SendSimpleAnimFeature(bool1: Bool, bool2: Bool, bool3: Bool) -> Void {
    let animFeature: ref<AnimFeature_SimpleDevice> = new AnimFeature_SimpleDevice();
    animFeature.isOpen = bool1;
    animFeature.isOpenLeft = bool2;
    animFeature.isOpenRight = bool3;
    this.ApplyAnimFeatureToReplicate(this, n"device", animFeature);
  }

  protected final func SpawnVFXs(fx: FxResource) -> Void {
    let fxSystem: ref<FxSystem>;
    let position: WorldPosition;
    let transform: WorldTransform;
    if FxResource.IsValid(fx) {
      fxSystem = GameInstance.GetFxSystem(this.GetGame());
      WorldPosition.SetVector4(position, this.GetWorldPosition());
      WorldTransform.SetWorldPosition(transform, position);
      fxSystem.SpawnEffect(fx, transform);
    };
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, n"deviceWorkspot");
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    (this.GetDevicePS() as ActivatedDeviceControllerPS).ActivateThisDevice();
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    (this.GetDevicePS() as ActivatedDeviceControllerPS).ActivateThisDevice();
  }

  public const func DeterminGameplayRoleMappinRange(data: SDeviceMappinData) -> Float {
    let range: Float;
    if NotEquals(data.gameplayRole, IntEnum(1l)) {
      range = this.GetDistractionRange(DeviceStimType.Distract);
    };
    return range;
  }

  protected func StartGlitching(glitchState: EGlitchState, opt intensity: Float) -> Void {
    this.SpawnVFXs((this.GetDevicePS() as ActivatedDeviceControllerPS).GetVFX());
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.Start, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetActivationVFXname());
    this.RefreshAnimation();
  }

  protected func StopGlitching() -> Void {
    this.RefreshAnimation();
    GameObjectEffectHelper.ActivateEffectAction(this, gamedataFxActionType.BreakLoop, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetActivationVFXname());
  }
}
