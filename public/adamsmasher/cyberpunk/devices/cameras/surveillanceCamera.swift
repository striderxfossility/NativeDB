
public class SurveillanceCamera extends SensorDevice {

  private let m_virtualCam: ref<VirtualCameraComponent>;

  private let m_cameraHead: ref<IComponent>;

  private let m_cameraHeadPhysics: ref<IComponent>;

  private let m_verticalDecal1: ref<IComponent>;

  private let m_verticalDecal2: ref<IComponent>;

  private edit let m_meshDestrSupport: Bool;

  @default(SurveillanceCamera, true)
  private let m_shouldRotate: Bool;

  @default(SurveillanceCamera, false)
  private let m_canStreamVideo: Bool;

  @default(SurveillanceCamera, true)
  private let m_canDetectIntruders: Bool;

  private let m_currentAngle: Float;

  private let m_rotateLeft: Bool;

  private let m_targetPosition: Vector4;

  private let m_factOnFeedReceived: CName;

  private let m_questFactOnDetection: CName;

  private let m_lookAtEvent: ref<LookAtAddEvent>;

  public let m_currentYawModifier: Float;

  public let m_currentPitchModifier: Float;

  private final func SetForcedSensesTracing() -> Void {
    if this.GetDevicePS().IsON() && this.GetSensesComponent().IsEnabled() {
      GameInstance.GetDelaySystem(this.GetGame()).QueueTask(this, null, n"SetForcedSensesTracingTask", gameScriptTaskExecutionStage.Any);
    };
  }

  protected final func SetForcedSensesTracingTask(data: ref<ScriptTaskData>) -> Void {
    if (this.GetDevicePS() as SurveillanceCameraControllerPS).CanTagEnemies() {
      this.GetSensesComponent().SetForcedSensesTracing(gamedataSenseObjectType.Npc, EAIAttitude.AIA_Neutral);
      this.GetSensesComponent().SetForcedSensesTracing(gamedataSenseObjectType.Npc, EAIAttitude.AIA_Hostile);
      this.GetSensesComponent().SetTickDistanceOverride(100.00);
    } else {
      this.GetSensesComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Npc, EAIAttitude.AIA_Neutral);
      this.GetSensesComponent().RemoveForcedSensesTracing(gamedataSenseObjectType.Npc, EAIAttitude.AIA_Hostile);
      this.GetSensesComponent().SetTickDistanceOverride(-1.00);
    };
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"virtualcamera", n"VirtualCameraComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"updateComponent", n"UpdateComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"detectionAreaIndicator", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"main_red", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"right_point", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"middle_point", n"gameLightComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"stripes_points", n"gameLightComponent", false);
    if this.m_meshDestrSupport {
      EntityRequestComponentsInterface.RequestComponent(ri, n"cameraHead", n"IComponent", true);
      EntityRequestComponentsInterface.RequestComponent(ri, n"cameraHeadPhysics", n"IComponent", true);
      EntityRequestComponentsInterface.RequestComponent(ri, n"vertical_decal_1", n"IComponent", false);
      EntityRequestComponentsInterface.RequestComponent(ri, n"vertical_decal_2", n"IComponent", false);
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_virtualCam = EntityResolveComponentsInterface.GetComponent(ri, n"virtualcamera") as VirtualCameraComponent;
    ArrayPush(this.m_lightScanRefs, EntityResolveComponentsInterface.GetComponent(ri, n"main_red") as gameLightComponent);
    ArrayPush(this.m_lightAttitudeRefs, EntityResolveComponentsInterface.GetComponent(ri, n"stripes_points") as gameLightComponent);
    ArrayPush(this.m_lightInfoRefs, EntityResolveComponentsInterface.GetComponent(ri, n"middle_point") as gameLightComponent);
    ArrayPush(this.m_lightInfoRefs, EntityResolveComponentsInterface.GetComponent(ri, n"right_point") as gameLightComponent);
    if this.m_meshDestrSupport {
      this.m_cameraHead = EntityResolveComponentsInterface.GetComponent(ri, n"cameraHead");
      this.m_verticalDecal1 = EntityResolveComponentsInterface.GetComponent(ri, n"vertical_decal_1");
      this.m_verticalDecal2 = EntityResolveComponentsInterface.GetComponent(ri, n"vertical_decal_2");
      this.m_cameraHeadPhysics = EntityResolveComponentsInterface.GetComponent(ri, n"cameraHeadPhysics");
    };
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as SurveillanceCameraController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.SetSenseObjectType(gamedataSenseObjectType.Camera);
  }

  protected func ResolveGameplayState() -> Void {
    this.ResolveGameplayState();
    this.RegisterToGameSessionDataSystem((this.GetDevicePS() as SurveillanceCameraControllerPS).CanTagEnemies());
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.RegisterToGameSessionDataSystem(false);
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func IsSurveillanceCamera() -> Bool {
    return true;
  }

  protected const func GetScannerName() -> String {
    return "LocKey#100";
  }

  public func SetAsIntrestingTarget(target: wref<GameObject>) -> Bool {
    return this.SetAsIntrestingTarget(target);
  }

  public func OnValidTargetAppears(target: wref<GameObject>) -> Void {
    let puppet: ref<ScriptedPuppet>;
    this.OnValidTargetAppears(target);
    (this.GetDevicePS() as SurveillanceCameraControllerPS).ThreatDetected(true);
    this.RequestAlarm();
    puppet = target as ScriptedPuppet;
    if (this.GetDevicePS() as SurveillanceCameraControllerPS).CanTagEnemies() && target.IsActive() {
      if IsDefined(puppet) && puppet.IsAggressive() {
        GameObject.TagObject(puppet);
      };
    };
  }

  public func OnCurrentTargetAppears(target: wref<GameObject>) -> Void {
    let puppet: ref<ScriptedPuppet> = target as ScriptedPuppet;
    if (this.GetDevicePS() as SurveillanceCameraControllerPS).ShouldRevealEnemies() {
      ScriptedPuppet.RequestRevealOutline(puppet, true, this.GetEntityID());
    };
    this.RequestAlarm();
    GameObject.PlaySoundEvent(this, n"q001_sc_00a_before_mission_tbug_hack");
    if !this.GetDevicePS().GetSecuritySystem().IsSystemInCombat() {
      this.SetWarningMessage("LocKey#53158");
    };
    this.OnCurrentTargetAppears(target);
  }

  private final func SetWarningMessage(lockey: String) -> Void {
    let simpleScreenMessage: SimpleScreenMessage;
    simpleScreenMessage.isShown = true;
    simpleScreenMessage.duration = 5.00;
    simpleScreenMessage.message = lockey;
    simpleScreenMessage.isInstant = true;
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(simpleScreenMessage), true);
  }

  public func OnValidTargetDisappears(target: wref<GameObject>) -> Void {
    let puppet: ref<ScriptedPuppet> = target as ScriptedPuppet;
    ScriptedPuppet.RequestRevealOutline(puppet, false, this.GetEntityID());
    if (this.GetDevicePS() as SurveillanceCameraControllerPS).CanTagEnemies() {
      GameObject.UntagObject(puppet);
    };
  }

  public func OnAllValidTargetsDisappears() -> Void {
    this.OnAllValidTargetsDisappears();
    (this.GetDevicePS() as SurveillanceCameraControllerPS).ThreatDetected(false);
    this.RequestAlarm();
  }

  protected cb func OnEnterShapeEvent(evt: ref<EnterShapeEvent>) -> Bool;

  protected cb func OnExitShapeEvent(evt: ref<ExitShapeEvent>) -> Bool;

  protected func PushPersistentData() -> Void {
    (this.GetDevicePS() as SurveillanceCameraControllerPS).PushPersistentData();
    this.PushPersistentData();
  }

  protected func RestoreDeviceState() -> Void {
    this.RestoreDeviceState();
  }

  protected func DeactivateDevice() -> Void {
    this.DeactivateDevice();
    this.TurnOffDevice();
  }

  protected func TurnOffDevice() -> Void {
    this.TurnOffDevice();
    this.TurnOffCamera();
  }

  protected func TurnOnDevice() -> Void {
    this.TurnOnDevice();
    this.TurnOnCamera();
  }

  protected func CutPower() -> Void {
    this.CutPower();
    this.TurnOffCamera();
  }

  protected cb func OnToggleStreamFeed(evt: ref<ToggleStreamFeed>) -> Bool {
    this.UpdateDeviceState();
    this.ToggleFeed((this.GetDevicePS() as SurveillanceCameraControllerPS).ShouldStream());
  }

  protected cb func OnToggleCamera(evt: ref<ToggleON>) -> Bool {
    this.UpdateDeviceState();
    this.GetDevicePS().IsON() ? this.TurnOnCamera() : this.TurnOffCamera();
  }

  private final func TurnOnCamera() -> Void {
    this.RequestAlarm();
    this.SetForcedSensesTracing();
  }

  private final func TurnOffCamera() -> Void {
    this.ToggleFeed(false);
    this.ToggleAreaIndicator(false);
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    super.OnDeath(evt);
    if this.m_meshDestrSupport {
      this.m_cameraHead.Toggle(false);
      this.m_verticalDecal1.Toggle(false);
      this.m_verticalDecal2.Toggle(false);
      this.m_cameraHeadPhysics.Toggle(true);
    };
  }

  protected cb func OnSetDeviceAttitude(evt: ref<SetDeviceAttitude>) -> Bool {
    super.OnSetDeviceAttitude(evt);
    this.SetForcedSensesTracing();
    this.RegisterToGameSessionDataSystem(true);
  }

  protected cb func OnCameraTagLockEvent(evt: ref<CameraTagLockEvent>) -> Bool {
    (this.GetDevicePS() as SurveillanceCameraControllerPS).SetTagLockFromSystem(evt.isLocked);
    this.SetForcedSensesTracing();
  }

  private final func RegisterToGameSessionDataSystem(add: Bool) -> Void {
    let cameraTagLimitData: ref<CameraTagLimitData> = new CameraTagLimitData();
    cameraTagLimitData.add = add;
    cameraTagLimitData.object = this;
    GameSessionDataSystem.AddDataEntryRequest(this.GetGame(), EGameSessionDataType.CameraTagLimit, ToVariant(cameraTagLimitData));
  }

  private final func ToggleFeed(shouldBeOn: Bool) -> Void {
    this.m_virtualCam.Toggle(shouldBeOn);
    if shouldBeOn {
      SetFactValue(this.GetGame(), this.m_factOnFeedReceived, 1);
    } else {
      SetFactValue(this.GetGame(), this.m_factOnFeedReceived, 0);
      (this.GetDevicePS() as SurveillanceCameraControllerPS).ClearFeedReceivers();
    };
  }

  private final func RequestAlarm() -> Void {
    if (this.GetDevicePS() as SurveillanceCameraControllerPS).IsDetecting() {
      SetFactValue(this.GetGame(), (this.GetDevicePS() as SurveillanceCameraControllerPS).GetQuestFactOnDetection(), 1);
    } else {
      SetFactValue(this.GetGame(), (this.GetDevicePS() as SurveillanceCameraControllerPS).GetQuestFactOnDetection(), 0);
    };
  }

  protected func OverrideLookAtSetupHor(out lookAtEntityEvent: ref<LookAtAddEvent>) -> Void {
    lookAtEntityEvent.request.limits.softLimitDegrees = (this.GetDevicePS() as SurveillanceCameraControllerPS).GetBehaviourMaxRotationAngle() * 2.00;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Alarm;
  }

  protected cb func OnActionEngineering(evt: ref<ActionEngineering>) -> Bool {
    GameObject.PlaySoundEvent(this, n"dev_surveillance_camera_fry_circuit");
    this.UpdateDeviceState();
  }

  protected cb func OnTCSTakeOverControlActivate(evt: ref<TCSTakeOverControlActivate>) -> Bool {
    super.OnTCSTakeOverControlActivate(evt);
    GameObjectEffectHelper.StartEffectEvent(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"fish_eye");
  }

  protected cb func OnTCSTakeOverControlDeactivate(evt: ref<TCSTakeOverControlDeactivate>) -> Bool {
    super.OnTCSTakeOverControlDeactivate(evt);
    GameObjectEffectHelper.StopEffectEvent(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject(), n"fish_eye");
  }
}
