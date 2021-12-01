
public abstract class LocomotionTransition extends DefaultTransition {

  public let m_ownerRecordId: TweakDBID;

  public let m_statModifierGroupId: Uint64;

  public let m_statModifierTDBNameDefault: String;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statModifierTDBNameDefault = NameToString(this.GetStateName());
    DefaultTransition.UppercaseFirstChar(this.m_statModifierTDBNameDefault);
    this.m_statModifierTDBNameDefault = "player_locomotion_data_" + this.m_statModifierTDBNameDefault;
    this.m_statModifierTDBNameDefault = "Player" + NameToString(this.GetStateMachineName()) + "." + this.m_statModifierTDBNameDefault;
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let capsuleHeight: Float = this.GetStaticFloatParameterDefault("capsuleHeight", 1.00);
    let capsuleRadius: Float = this.GetStaticFloatParameterDefault("capsuleRadius", 1.00);
    return scriptInterface.CanCapsuleFit(capsuleHeight, capsuleRadius);
  }

  protected final func SetModifierGroupForState(scriptInterface: ref<StateGameScriptInterface>, opt statModifierTDBName: String) -> Void {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let ownerRecordId: TweakDBID = (scriptInterface.owner as gamePuppetBase).GetRecordID();
    if this.m_ownerRecordId != ownerRecordId {
      this.m_ownerRecordId = ownerRecordId;
      TDBID.Append(ownerRecordId, t"PlayerLocomotion");
      this.m_statModifierGroupId = TDBID.ToNumber(ownerRecordId);
    };
    statSystem.RemoveModifierGroup(Cast(scriptInterface.ownerEntityID), this.m_statModifierGroupId);
    statSystem.UndefineModifierGroup(this.m_statModifierGroupId);
    if Equals(statModifierTDBName, "") {
      statModifierTDBName = this.m_statModifierTDBNameDefault;
    };
    statSystem.DefineModifierGroupFromRecord(this.m_statModifierGroupId, TDBID.Create(statModifierTDBName));
    statSystem.ApplyModifierGroup(Cast(scriptInterface.ownerEntityID), this.m_statModifierGroupId);
  }

  protected final func ShowDebugText(text: String, scriptInterface: ref<StateGameScriptInterface>, out layerId: Uint32) -> Void {
    layerId = GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).DrawText(new Vector4(650.00, 100.00, 0.00, 0.00), text, gameDebugViewETextAlignment.Center, new Color(0u, 240u, 148u, 100u));
    GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).SetScale(layerId, new Vector4(1.50, 1.50, 0.00, 0.00));
  }

  protected final func ClearDebugText(layerId: Uint32, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameInstance.GetDebugVisualizerSystem(scriptInterface.owner.GetGame()).ClearLayer(layerId);
  }

  protected final func ResetFallingParameters(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentIntParameter(n"LandingType", EnumInt(LandingType.Off), true);
    stateContext.SetPermanentFloatParameter(n"ImpactSpeed", 0.00, true);
    stateContext.SetPermanentFloatParameter(n"InAirDuration", 0.00, true);
  }

  protected final func AddImpulseInMovingDirection(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, impulse: Float) -> Void {
    let direction: Vector4;
    if impulse == 0.00 {
      return;
    };
    direction = scriptInterface.GetOwnerMovingDirection();
    this.AddImpulse(stateContext, direction * impulse);
  }

  protected final func AddImpulse(stateContext: ref<StateContext>, impulse: Vector4) -> Void {
    stateContext.SetTemporaryVectorParameter(n"impulse", impulse, true);
  }

  protected final func AddVerticalImpulse(stateContext: ref<StateContext>, force: Float) -> Void {
    let impulse: Vector4;
    impulse.Z = force;
    this.AddImpulse(stateContext, impulse);
  }

  public final func SetCollisionFilter(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let simulationFilter: SimulationFilter;
    let zero: Bool = this.GetStaticBoolParameterDefault("collisionFilterPresetIsZero", false);
    if zero {
      simulationFilter = SimulationFilter.ZERO();
    } else {
      SimulationFilter.SimulationFilter_BuildFromPreset(simulationFilter, n"Player Collision");
    };
    scriptInterface.SetStateVectorParameter(physicsStateValue.SimulationFilter, ToVariant(simulationFilter));
  }

  public func SetLocomotionParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> ref<LocomotionParameters> {
    let locomotionParameters: ref<LocomotionParameters>;
    this.SetModifierGroupForState(scriptInterface);
    locomotionParameters = new LocomotionParameters();
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
    return locomotionParameters;
  }

  protected final func SetLocomotionCameraParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let param: StateResultCName = this.GetStaticCNameParameter("onEnterCameraParamsName");
    if param.valid {
      stateContext.SetPermanentCNameParameter(n"LocomotionCameraParams", param.value, true);
      this.UpdateCameraContext(stateContext, scriptInterface);
    };
  }

  protected final const func GetStateDefaultLocomotionParameters(out locomotionParameters: ref<LocomotionParameters>) -> Void {
    locomotionParameters.SetUpwardsGravity(this.GetStaticFloatParameterDefault("upwardsGravity", -16.00));
    locomotionParameters.SetDownwardsGravity(this.GetStaticFloatParameterDefault("downwardsGravity", -16.00));
    locomotionParameters.SetImperfectTurn(this.GetStaticBoolParameterDefault("imperfectTurn", false));
    locomotionParameters.SetSpeedBoostInputRequired(this.GetStaticBoolParameterDefault("speedBoostInputRequired", false));
    locomotionParameters.SetSpeedBoostMultiplyByDot(this.GetStaticBoolParameterDefault("speedBoostMultiplyByDot", false));
    locomotionParameters.SetUseCameraHeadingForMovement(this.GetStaticBoolParameterDefault("useCameraHeadingForMovement", false));
    locomotionParameters.SetCapsuleHeight(this.GetStaticFloatParameterDefault("capsuleHeight", 1.80));
    locomotionParameters.SetCapsuleRadius(this.GetStaticFloatParameterDefault("capsuleRadius", 0.40));
    locomotionParameters.SetIgnoreSlope(this.GetStaticBoolParameterDefault("ignoreSlope", false));
  }

  protected final func BroadcastStimuliFootstepSprint(context: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let broadcastFootstepStim: Bool = GameInstance.GetStatsSystem(context.owner.GetGame()).GetStatValue(Cast(context.owner.GetEntityID()), gamedataStatType.CanRunSilently) < 1.00;
    if broadcastFootstepStim {
      broadcaster = context.executionOwner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(context.executionOwner, gamedataStimType.FootStepSprint);
      };
    };
  }

  protected final func BroadcastStimuliFootstepRegular(context: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let broadcastFootstepStim: Bool = GameInstance.GetStatsSystem(context.owner.GetGame()).GetStatValue(Cast(context.owner.GetEntityID()), gamedataStatType.CanWalkSilently) < 1.00;
    if broadcastFootstepStim {
      broadcaster = context.executionOwner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(context.executionOwner, gamedataStimType.FootStepRegular);
      };
    };
  }

  protected final func SetDetailedState(scriptInterface: ref<StateGameScriptInterface>, state: gamePSMDetailedLocomotionStates) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.LocomotionDetailed, EnumInt(state));
  }

  public final const func IsTouchingGround(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let onGround: Bool = scriptInterface.IsOnGround();
    return onGround;
  }

  public final const func HasSecureFooting(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.CheckSecureFootingFailure(this.HasSecureFootingDetailedResult(stateContext, scriptInterface));
  }

  public final const func CheckSecureFootingFailure(const result: SecureFootingResult) -> Bool {
    return Equals(result.type, moveSecureFootingFailureType.Invalid);
  }

  public final const func HasSecureFootingDetailedResult(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> SecureFootingResult {
    return scriptInterface.HasSecureFooting();
  }

  protected final const func GetFallingSpeedBasedOnHeight(const scriptInterface: ref<StateGameScriptInterface>, height: Float) -> Float {
    let acc: Float;
    let speed: Float;
    if height <= 0.00 {
      return 0.00;
    };
    acc = AbsF(this.GetStaticFloatParameterDefault("upwardsGravity", this.GetStaticFloatParameterDefault("defaultGravity", -16.00)));
    speed = 0.00;
    if acc != 0.00 {
      speed = acc * SqrtF((2.00 * height) / acc);
    };
    return speed * -1.00;
  }

  protected final func GetSpeedBasedOnDistance(scriptInterface: ref<StateGameScriptInterface>, desiredDistance: Float) -> Float {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let deceleration: Float = this.GetStatFloatValue(scriptInterface, gamedataStatType.Deceleration, statSystem);
    return deceleration * SqrtF((2.00 * desiredDistance) / deceleration);
  }

  protected final const func IsCurrentFallSpeedTooFastToEnter(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let playerFallingTooFast: Float;
    let verticalSpeed: Float;
    if !scriptInterface.IsOnGround() {
      verticalSpeed = this.GetVerticalSpeed(scriptInterface);
      playerFallingTooFast = stateContext.GetFloatParameter(n"VeryHardLandingFallingSpeed", true);
      if verticalSpeed <= playerFallingTooFast {
        return true;
      };
    };
    return false;
  }

  protected final const func IsAiming(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetActionValue(n"CameraAim") > 0.00;
  }

  protected final const func WantsToDodge(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isInCooldown: Bool = StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeCooldown") || StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirCooldown");
    if isInCooldown {
      return false;
    };
    if scriptInterface.IsActionJustPressed(n"Dodge") {
      if scriptInterface.IsMoveInputConsiderable() {
        stateContext.SetConditionFloatParameter(n"DodgeDirection", scriptInterface.GetInputHeading(), true);
        return true;
      };
      if this.GetStaticBoolParameterDefault("dodgeWithNoMovementInput", false) {
        stateContext.SetConditionFloatParameter(n"DodgeDirection", -180.00, true);
        return true;
      };
    };
    if this.WantsToDodgeFromMovementInput(stateContext, scriptInterface) && GameplaySettingsSystem.GetMovementDodgeEnabled(scriptInterface.executionOwner) {
      return true;
    };
    return false;
  }

  protected final const func WantsToDodgeFromMovementInput(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"DodgeForward") {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", 0.00, true);
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"DodgeRight") {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", -90.00, true);
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"DodgeLeft") {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", 90.00, true);
      return true;
    };
    if scriptInterface.IsActionJustPressed(n"DodgeBack") {
      stateContext.SetConditionFloatParameter(n"DodgeDirection", -180.00, true);
      return true;
    };
    return false;
  }

  public final const func IsIdleForced(const stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetBoolParameter(n"ForceIdle", true);
  }

  public final const func IsWalkForced(const stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetBoolParameter(n"ForceWalk", true);
  }

  public final const func IsFreezeForced(const stateContext: ref<StateContext>) -> Bool {
    return stateContext.GetBoolParameter(n"ForceFreeze", true);
  }

  protected final func PlayRumbleBasedOnDodgeDirection(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let presetName: String;
    let movementDirection: EPlayerMovementDirection = DefaultTransition.GetMovementDirection(stateContext, scriptInterface);
    if Equals(movementDirection, EPlayerMovementDirection.Right) {
      presetName = "medium_pulse_right";
    } else {
      if Equals(movementDirection, EPlayerMovementDirection.Left) {
        presetName = "medium_pulse_left";
      } else {
        presetName = "medium_pulse";
      };
    };
    DefaultTransition.PlayRumble(scriptInterface, presetName);
  }

  protected final const func IsStatusEffectType(statusEffectRecord: ref<StatusEffect_Record>, type: gamedataStatusEffectType) -> Bool {
    let effectType: gamedataStatusEffectType = statusEffectRecord.StatusEffectType().Type();
    return Equals(effectType, type);
  }

  protected final func SpawnLandingFxGameEffect(attackId: TweakDBID, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let effect: ref<EffectInstance> = scriptInterface.GetGameEffectSystem().CreateEffectStatic(n"landing", n"fx", scriptInterface.executionOwner);
    let position: Vector4 = scriptInterface.executionOwner.GetWorldPosition();
    position.Z += 0.50;
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, 2.00);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, new Vector4(0.00, 0.00, -1.00, 0.00));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackId, ToVariant(attackId));
    effect.Run();
  }

  protected final const func ProcessSprintInputLock(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if stateContext.GetBoolParameter(n"sprintInputLock", true) && scriptInterface.GetActionValue(n"Sprint") == 0.00 && scriptInterface.GetActionValue(n"ToggleSprint") == 0.00 {
      stateContext.RemovePermanentBoolParameter(n"sprintInputLock");
    };
  }

  protected final const func SetupSprintInputLock(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.GetActionValue(n"Sprint") != 0.00 || scriptInterface.GetActionValue(n"ToggleSprint") != 0.00 {
      stateContext.SetPermanentBoolParameter(n"sprintInputLock", true, true);
    };
  }
}

public abstract class LocomotionEventsTransition extends LocomotionTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let blockAimingFor: Float = this.GetStaticFloatParameterDefault("softBlockAimingOnEnterFor", -1.00);
    if blockAimingFor > 0.00 {
      this.SoftBlockAimingForTime(stateContext, scriptInterface, blockAimingFor);
    };
    this.SetLocomotionParameters(stateContext, scriptInterface);
    this.SetCollisionFilter(scriptInterface);
    this.SetLocomotionCameraParameters(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void;

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.ProcessSprintInputLock(stateContext, scriptInterface);
  }

  protected final func ConsumeStaminaBasedOnLocomotionState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let staminaReduction: Float = 0.00;
    let stateName: CName = this.GetStateName();
    switch stateName {
      case n"sprint":
        if !RPGManager.HasStatFlag(scriptInterface.executionOwner, gamedataStatType.IsSprintStaminaFree) {
          staminaReduction = PlayerStaminaHelpers.GetSprintStaminaCost();
        };
        break;
      case n"swimmingFastDiving":
      case n"swimmingSurfaceFast":
        staminaReduction = PlayerStaminaHelpers.GetSprintStaminaCost();
        break;
      case n"slide":
        staminaReduction = PlayerStaminaHelpers.GetSlideStaminaCost();
        break;
      case n"hoverJump":
      case n"chargeJump":
      case n"doubleJump":
      case n"jump":
        staminaReduction = PlayerStaminaHelpers.GetJumpStaminaCost();
        break;
      case n"dodge":
        if !RPGManager.HasStatFlag(scriptInterface.executionOwner, gamedataStatType.IsDodgeStaminaFree) {
          staminaReduction = PlayerStaminaHelpers.GetDodgeStaminaCost();
        };
        break;
      case n"dodgeAir":
        if !RPGManager.HasStatFlag(scriptInterface.executionOwner, gamedataStatType.IsDodgeStaminaFree) {
          staminaReduction = PlayerStaminaHelpers.GetAirDodgeStaminaCost();
        };
        break;
      default:
        staminaReduction = 0.10;
    };
    if staminaReduction > 0.00 {
      PlayerStaminaHelpers.ModifyStamina(scriptInterface.executionOwner as PlayerPuppet, -staminaReduction);
    };
  }

  protected final func UpdateInputToggles(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustPressed(n"ToggleSprint") || scriptInterface.IsActionJustPressed(n"Sprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      return;
    };
    if scriptInterface.IsActionJustTapped(n"ToggleCrouch") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", true, true);
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return;
    };
  }
}

public abstract class LocomotionGroundDecisions extends LocomotionTransition {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  public const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func TestLadderMath(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, ladderParameter: ref<LadderDescription>) -> Bool {
    let inp: Bool = scriptInterface.IsMoveInputConsiderable();
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let playerVelocity: Vector4 = Vector4.Normalize2D(Vector4.RotByAngleXY(playerForward, scriptInterface.GetInputHeading()));
    let ladderPosition: Vector4 = ladderParameter.position + (ladderParameter.up * (ladderParameter.verticalStepBottom + ladderParameter.topHeightFromPosition)) / 2.00;
    let directionToLadder: Vector4 = ladderPosition - playerPosition;
    directionToLadder = Vector4.Normalize2D(directionToLadder);
    let ladderEntityAngle: Float = Rad2Deg(AcosF(ClampF(Vector4.Dot(playerForward, directionToLadder), -1.00, 1.00)));
    let playerMoveDirection: Float = Rad2Deg(AcosF(ClampF(Vector4.Dot(playerVelocity, -ladderParameter.normal), -1.00, 1.00)));
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("enterAngleThreshold", 35.00);
    let fromBottomFactor: Float = SgnF(Vector4.Dot(ladderParameter.up, directionToLadder));
    let inAir: Bool = !this.IsTouchingGround(scriptInterface);
    let playerMovingForward: Bool = !this.IsPlayerMovingBackwards(stateContext, scriptInterface);
    if inp {
      Log("");
    };
    if inAir && playerMovingForward {
      if fromBottomFactor > 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold {
        return true;
      };
      if fromBottomFactor < 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold {
        return true;
      };
    } else {
      if inp && playerMovingForward && fromBottomFactor > 0.00 && AbsF(ladderEntityAngle) < enterAngleThreshold && AbsF(playerMoveDirection) < enterAngleThreshold {
        return true;
      };
      return false;
    };
    return false;
  }

  public final static func CheckCrouchEnterCondition(const stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustTapped(n"ToggleCrouch") || stateContext.GetConditionBool(n"CrouchToggled") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", true, true);
      return true;
    };
    return scriptInterface.GetActionValue(n"Crouch") > 0.00;
  }

  protected final const func CrouchEnterCondition(const stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isFFByLine: Bool) -> Bool {
    let puppetPS: ref<ScriptedPuppetPS>;
    let paramName: CName = isFFByLine ? n"FFhintActive" : n"FFHoldLock";
    let puppet: ref<ScriptedPuppet> = scriptInterface.owner as ScriptedPuppet;
    if IsDefined(puppet) {
      puppetPS = puppet.GetPuppetPS();
    };
    if (scriptInterface.IsActionJustTapped(n"ToggleCrouch") || stateContext.GetConditionBool(n"CrouchToggled")) && !stateContext.GetBoolParameter(paramName, true) || IsDefined(puppetPS) && puppetPS.IsCrouch() {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", true, true);
      return true;
    };
    return scriptInterface.GetActionValue(n"Crouch") > 0.00;
  }

  protected final const func CrouchExitCondition(const stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isFFByLine: Bool) -> Bool {
    let paramName: CName = isFFByLine ? n"FFhintActive" : n"FFHoldLock";
    if (scriptInterface.IsActionJustReleased(n"Crouch") || scriptInterface.IsActionJustTapped(n"ToggleCrouch")) && !stateContext.GetBoolParameter(paramName, true) {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      return true;
    };
    if !stateContext.GetConditionBool(n"CrouchToggled") && scriptInterface.GetActionValue(n"Crouch") == 0.00 {
      return true;
    };
    return false;
  }
}

public abstract class LocomotionGroundEvents extends LocomotionEventsTransition {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_PlayerLocomotionStateMachine>;
    this.OnEnter(stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"enteredFallFromAirDodge");
    stateContext.SetPermanentIntParameter(n"currentNumberOfJumps", 0, true);
    stateContext.SetPermanentIntParameter(n"currentNumberOfAirDodges", 0, true);
    this.SetAudioParameter(n"RTPC_Vertical_Velocity", 0.00, scriptInterface);
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    animFeature = new AnimFeature_PlayerLocomotionStateMachine();
    animFeature.inAirState = false;
    scriptInterface.SetAnimationParameterFeature(n"LocomotionStateMachine", animFeature);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.Default));
    scriptInterface.GetAudioSystem().NotifyGameTone(n"EnterOnGround");
    this.StopEffect(scriptInterface, n"falling");
    stateContext.SetConditionBoolParameter(n"JumpPressed", false, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    scriptInterface.GetAudioSystem().NotifyGameTone(n"LeaveOnGround");
  }
}

public class ForceIdleDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsIdleForced(stateContext) || scriptInterface.IsSceneAnimationActive();
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let mountingInfo: MountingInfo = scriptInterface.GetMountingInfo(scriptInterface.executionOwner);
    return !this.IsIdleForced(stateContext) && !scriptInterface.IsSceneAnimationActive() && !IMountingFacility.InfoIsComplete(mountingInfo) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice);
  }
}

public class ForceIdleEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.AverageNormal);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal);
  }
}

public class WorkspotDecisions extends LocomotionGroundDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.IsInWorkspot(scriptInterface);
  }

  protected final const func ExitCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !DefaultTransition.IsInWorkspot(scriptInterface) || this.IsInMinigame(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class WorkspotEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if DefaultTransition.GetPlayerPuppet(scriptInterface).HasWorkspotTag(n"DisableCameraControl") {
      this.SetWorkspotAnimFeature(scriptInterface);
    };
    if DefaultTransition.GetPlayerPuppet(scriptInterface).HasWorkspotTag(n"Grab") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
    stateContext.SetTemporaryBoolParameter(n"requestSandevistanDeactivation", true, true);
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, EnumInt(gamePSMWorkspotState.Workspot));
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Workspot));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, EnumInt(gamePSMWorkspotState.Default));
    this.ResetWorkspotAnimFeature(scriptInterface);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.IsInWorkspot, EnumInt(gamePSMWorkspotState.Default));
    this.ResetWorkspotAnimFeature(scriptInterface);
  }

  protected final func SetWorkspotAnimFeature(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_AerialTakedown> = new AnimFeature_AerialTakedown();
    animFeature.state = 1;
    scriptInterface.SetAnimationParameterFeature(n"AerialTakedown", animFeature);
  }

  protected final func ResetWorkspotAnimFeature(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_AerialTakedown> = new AnimFeature_AerialTakedown();
    animFeature.state = 0;
    scriptInterface.SetAnimationParameterFeature(n"AerialTakedown", animFeature);
  }
}

public class ForceWalkDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsWalkForced(stateContext);
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsWalkForced(stateContext);
  }
}

public class ForceWalkEvents extends LocomotionGroundEvents {

  public let m_storedSpeedValue: Float;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class ForceFreezeDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsFreezeForced(stateContext);
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsFreezeForced(stateContext);
  }

  protected final const func ToWorkspot(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsInMinigame(scriptInterface) && DefaultTransition.IsInWorkspot(scriptInterface);
  }
}

public class ForceFreezeEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().DisableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().EnableQueriesForOwner(scriptInterface.owner, gamePlayerObstacleSystemQueryType.Climb_Vault, gamePlayerObstacleSystemQueryType.Covers, gamePlayerObstacleSystemQueryType.AverageNormal);
  }
}

public class InitialDecisions extends LocomotionGroundDecisions {

  protected final const func ToCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }
}

public class StandDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  public const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsTouchingGround(scriptInterface) && this.GetVerticalSpeed(scriptInterface) <= 0.50;
  }
}

public class StandEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.PushAnimationEvent(n"StandEnter");
    stateContext.SetConditionBoolParameter(n"blockEnteringSlide", false, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    this.PlaySound(n"lcm_falling_wind_loop_end", scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Stand);
  }

  protected final func OnTick(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let footstepStimuliSpeedThreshold: Float;
    let playerSpeed: Float;
    if this.IsTouchingGround(scriptInterface) {
      playerSpeed = scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed);
      footstepStimuliSpeedThreshold = this.GetStaticFloatParameterDefault("footstepStimuliSpeedThreshold", 2.50);
      if playerSpeed > footstepStimuliSpeedThreshold {
        this.BroadcastStimuliFootstepRegular(scriptInterface);
      };
    };
  }
}

public class AimWalkDecisions extends LocomotionGroundDecisions {

  public let m_callbackIDs: array<ref<CallbackHandle>>;

  private let m_isBlocking: Bool;

  private let m_isAiming: Bool;

  private let m_inFocusMode: Bool;

  private let m_isLeftHandChanging: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    this.OnAttach(stateContext, scriptInterface);
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Melee, this, n"OnMeleeChanged", true));
      ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.UpperBody, this, n"OnUpperBodyChanged", true));
      ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.Vision, this, n"OnVisionChanged", true));
      ArrayPush(this.m_callbackIDs, scriptInterface.localBlackboard.RegisterListenerInt(allBlackboardDef.PlayerStateMachine.LeftHandCyberware, this, n"OnLeftHandCyberwareChanged", true));
    };
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    ArrayClear(this.m_callbackIDs);
  }

  protected final func UpdateEnterConditionEnabled() -> Void {
    this.EnableOnEnterCondition(this.m_isBlocking || this.m_isAiming || this.m_inFocusMode || this.m_isLeftHandChanging);
  }

  protected cb func OnMeleeChanged(value: Int32) -> Bool {
    this.m_isBlocking = value == EnumInt(gamePSMMelee.Block);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnUpperBodyChanged(value: Int32) -> Bool {
    this.m_isAiming = value == EnumInt(gamePSMUpperBodyStates.Aim);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnVisionChanged(value: Int32) -> Bool {
    this.m_inFocusMode = value == EnumInt(gamePSMVision.Focus);
    this.UpdateEnterConditionEnabled();
  }

  protected cb func OnLeftHandCyberwareChanged(value: Int32) -> Bool {
    this.m_isLeftHandChanging = value == EnumInt(gamePSMLeftHandCyberware.Charge);
    this.UpdateEnterConditionEnabled();
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.m_isBlocking && DefaultTransition.HasMeleeWeaponEquipped(scriptInterface) && scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.IsNotSlowedDuringBlock) > 0.00 {
      return false;
    };
    return true;
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.IsOnEnterConditionEnabled() || !this.EnterCondition(stateContext, scriptInterface);
  }
}

public class AimWalkEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.AimWalk);
  }
}

public class CrouchDecisions extends LocomotionGroundDecisions {

  public let m_gameplaySettings: wref<GameplaySettingsSystem>;

  public let m_executionOwner: wref<GameObject>;

  public let m_callbackID: ref<CallbackHandle>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_crouchPressed: Bool;

  private let m_toggleCrouchPressed: Bool;

  private let m_forcedCrouch: Bool;

  private let m_controllingDevice: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let allBlackboardDef: ref<AllBlackboardDefinitions>;
    this.m_gameplaySettings = GameplaySettingsSystem.GetGameplaySettingsSystemInstance(scriptInterface.executionOwner);
    if IsDefined(scriptInterface.localBlackboard) {
      allBlackboardDef = GetAllBlackboardDefs();
      this.m_callbackID = scriptInterface.localBlackboard.RegisterListenerBool(allBlackboardDef.PlayerStateMachine.IsControllingDevice, this, n"OnControllingDeviceChange");
      this.OnControllingDeviceChange(scriptInterface.localBlackboard.GetBool(allBlackboardDef.PlayerStateMachine.IsControllingDevice));
    };
    scriptInterface.executionOwner.RegisterInputListener(this, n"Crouch");
    scriptInterface.executionOwner.RegisterInputListener(this, n"ToggleCrouch");
    this.m_crouchPressed = scriptInterface.GetActionValue(n"Crouch") > 0.00;
    this.m_toggleCrouchPressed = scriptInterface.GetActionValue(n"ToggleCrouch") > 0.00;
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_executionOwner = scriptInterface.executionOwner;
    this.m_forcedCrouch = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"ForceCrouch");
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_callbackID = null;
    this.m_statusEffectListener = null;
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_forcedCrouch {
      if statusEffect.GameplayTagsContains(n"ForceCrouch") {
        this.m_forcedCrouch = true;
        this.EnableOnEnterCondition(true);
      };
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_forcedCrouch {
      if statusEffect.GameplayTagsContains(n"ForceCrouch") {
        this.m_forcedCrouch = StatusEffectSystem.ObjectHasStatusEffectWithTag(this.m_executionOwner, n"ForceCrouch");
      };
    };
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"Crouch") {
      this.m_crouchPressed = ListenerAction.GetValue(action) > 0.00;
      if this.m_crouchPressed {
        this.EnableOnEnterCondition(true);
      };
    } else {
      if Equals(ListenerAction.GetName(action), n"ToggleCrouch") {
        this.m_toggleCrouchPressed = ListenerAction.GetValue(action) > 0.00;
        if this.m_toggleCrouchPressed {
          this.EnableOnEnterCondition(true);
        };
      };
    };
  }

  protected cb func OnControllingDeviceChange(value: Bool) -> Bool {
    this.m_controllingDevice = value;
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isFFByLine: Bool;
    let shouldCrouch: Bool;
    let superResult: Bool;
    if this.m_controllingDevice {
      return true;
    };
    isFFByLine = this.m_gameplaySettings.GetIsFastForwardByLine();
    if isFFByLine && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ForceStand") {
      if !scriptInterface.HasStatFlag(gamedataStatType.CanCrouch) || stateContext.GetBoolParameter(n"FFhintActive", true) || !scriptInterface.HasStatFlag(gamedataStatType.FFInputLock) {
        if scriptInterface.IsActionJustHeld(n"ToggleCrouch") {
          stateContext.SetConditionBoolParameter(n"CrouchToggled", true, true);
          stateContext.SetPermanentBoolParameter(n"HoldInputFastForwardLock", true, true);
          return true;
        };
        return false;
      };
    };
    superResult = this.EnterCondition(stateContext, scriptInterface) && scriptInterface.HasStatFlag(gamedataStatType.CanCrouch);
    shouldCrouch = this.CrouchEnterCondition(stateContext, scriptInterface, isFFByLine) || this.m_forcedCrouch;
    if !this.m_crouchPressed && !this.m_toggleCrouchPressed && !this.m_forcedCrouch && !stateContext.GetConditionBool(n"CrouchToggled") {
      this.EnableOnEnterCondition(false);
    };
    return shouldCrouch && superResult && this.IsTouchingGround(scriptInterface);
  }

  protected const func ToCrouch(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    return true;
  }

  protected const func ToStand(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isFFByLine: Bool;
    if this.m_controllingDevice {
      return false;
    };
    isFFByLine = this.m_gameplaySettings.GetIsFastForwardByLine();
    if isFFByLine {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FastForwardCrouchLock") || stateContext.GetBoolParameter(n"FFhintActive", true) || !scriptInterface.HasStatFlag(gamedataStatType.FFInputLock) {
        if scriptInterface.IsActionJustHeld(n"ToggleCrouch") {
          stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
          stateContext.SetPermanentBoolParameter(n"HoldInputFastForwardLock", true, true);
          return true;
        };
        return false;
      };
      if !scriptInterface.HasStatFlag(gamedataStatType.CanCrouch) && !stateContext.GetBoolParameter(n"FFhintActive", true) {
        return true;
      };
    } else {
      if !scriptInterface.HasStatFlag(gamedataStatType.CanCrouch) && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FastForward") && !stateContext.GetBoolParameter(n"FFRestriction", true) && !stateContext.GetBoolParameter(n"TriggerFF", true) {
        return true;
      };
    };
    if this.CrouchExitCondition(stateContext, scriptInterface, isFFByLine) && !this.m_forcedCrouch {
      return true;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ForceStand") {
      return true;
    };
    return false;
  }

  protected const func ToSprint(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let visionToggled: StateResultBool = stateContext.GetPermanentBoolParameter(n"VisionToggled");
    if this.m_controllingDevice {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanSprint) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().CoverAction.coverActionStateId) == 3 {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) || visionToggled.valid && visionToggled.value {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.Charge) {
      return false;
    };
    if scriptInterface.GetActionValue(n"AttackA") > 0.00 {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Melee) == EnumInt(gamePSMMelee.Block) || this.IsInMeleeState(stateContext, n"meleeChargedHold") {
      return false;
    };
    if DefaultTransition.IsChargingWeapon(scriptInterface) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon) == EnumInt(gamePSMMeleeWeapon.ChargedHold) && !stateContext.GetBoolParameter(n"canSprintWhileCharging", true) {
      return false;
    };
    if !stateContext.GetConditionBool(n"SprintToggled") && scriptInterface.IsActionJustReleased(n"ToggleSprint") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoSlide") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
    };
    if scriptInterface.GetActionValue(n"Crouch") == 0.00 && (scriptInterface.GetActionValue(n"Sprint") > 0.00 || scriptInterface.GetActionValue(n"ToggleSprint") > 0.00 || stateContext.GetConditionBool(n"SprintToggled")) && scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) >= 1.00 && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoSlide") {
      return true;
    };
    return false;
  }
}

public class CrouchEvents extends LocomotionGroundEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let puppet: ref<ScriptedPuppet> = scriptInterface.owner as ScriptedPuppet;
    if IsDefined(puppet) {
      puppet.GetPuppetPS().SetCrouch(true);
    };
    this.OnEnter(stateContext, scriptInterface);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoSlide") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    };
    scriptInterface.GetAudioSystem().NotifyGameTone(n"EnterCrouch");
    scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().OnEnterCrouch(scriptInterface.owner);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
    if DefaultTransition.HasMeleeWeaponEquipped(scriptInterface) {
      scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.owner);
    };
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Crouch);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let puppet: ref<ScriptedPuppet> = scriptInterface.owner as ScriptedPuppet;
    if IsDefined(puppet) {
      puppet.GetPuppetPS().SetCrouch(false);
    };
    this.OnExit(stateContext, scriptInterface);
    scriptInterface.GetAudioSystem().NotifyGameTone(n"LeaveCrouch");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
    if DefaultTransition.HasMeleeWeaponEquipped(scriptInterface) {
      scriptInterface.GetTargetingSystem().AimSnap(scriptInterface.owner);
    };
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SprintDecisions extends LocomotionGroundDecisions {

  private let m_sprintPressed: Bool;

  private let m_toggleSprintPressed: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Sprint");
    scriptInterface.executionOwner.RegisterInputListener(this, n"ToggleSprint");
    this.m_sprintPressed = scriptInterface.GetActionValue(n"Sprint") > 0.00;
    this.m_toggleSprintPressed = scriptInterface.GetActionValue(n"ToggleSprint") > 0.00;
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetName(action), n"Sprint") {
      this.m_sprintPressed = ListenerAction.GetValue(action) > 0.00;
      if this.m_sprintPressed {
        this.EnableOnEnterCondition(true);
      };
    } else {
      if Equals(ListenerAction.GetName(action), n"ToggleSprint") {
        this.m_toggleSprintPressed = ListenerAction.GetValue(action) > 0.00;
        if this.m_toggleSprintPressed {
          this.EnableOnEnterCondition(true);
        };
      };
    };
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let isAiming: Bool;
    let isChargingCyberware: Bool;
    let lastShotTime: StateResultFloat;
    let minLinearVelocityThreshold: Float;
    let minStickInputThreshold: Float;
    let superResult: Bool;
    if !this.m_sprintPressed && !this.m_toggleSprintPressed && !stateContext.GetConditionBool(n"SprintToggled") {
      this.EnableOnEnterCondition(false);
      return false;
    };
    superResult = this.EnterCondition(stateContext, scriptInterface) && this.IsTouchingGround(scriptInterface);
    minLinearVelocityThreshold = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
    minStickInputThreshold = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if !scriptInterface.HasStatFlag(gamedataStatType.CanSprint) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() || AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold || DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold || scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return false;
    };
    isAiming = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    if isAiming {
      return false;
    };
    isChargingCyberware = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware) == EnumInt(gamePSMLeftHandCyberware.Charge);
    if isChargingCyberware {
      return false;
    };
    if DefaultTransition.IsChargingWeapon(scriptInterface) {
      return false;
    };
    if !MeleeTransition.MeleeSprintStateCondition(stateContext, scriptInterface) {
      return false;
    };
    lastShotTime = stateContext.GetPermanentFloatParameter(n"LastShotTime");
    if lastShotTime.valid {
      if EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.GetGame())) - lastShotTime.value < this.GetStaticFloatParameterDefault("sprintDisableTimeAfterShoot", -2.00) {
        return false;
      };
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSprinting) && scriptInterface.GetActionValue(n"RangedAttack") > 0.00 {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().CoverAction.coverActionStateId) == 3 {
      return false;
    };
    if this.m_toggleSprintPressed && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
    };
    if !superResult {
      return false;
    };
    if stateContext.GetConditionBool(n"SprintToggled") && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
      return true;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload) {
      if scriptInterface.IsActionJustPressed(n"Sprint") && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
        return true;
      };
    } else {
      if this.m_sprintPressed && !stateContext.GetBoolParameter(n"sprintInputLock", true) {
        return true;
      };
    };
    return false;
  }

  protected const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let minLinearVelocityThreshold: Float;
    let minStickInputThreshold: Float;
    if !scriptInterface.HasStatFlag(gamedataStatType.CanSprint) {
      return true;
    };
    if stateContext.GetBoolParameter(n"InterruptSprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if this.GetInStateTime() >= 0.30 {
      minLinearVelocityThreshold = this.GetStaticFloatParameterDefault("minLinearVelocityThreshold", 0.50);
      if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) < minLinearVelocityThreshold {
        stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
        return true;
      };
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", 45.00);
    if !scriptInterface.IsMoveInputConsiderable() || !(AbsF(scriptInterface.GetInputHeading()) <= enterAngleThreshold) {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    minStickInputThreshold = this.GetStaticFloatParameterDefault("minStickInputThreshold", 0.90);
    if stateContext.GetConditionBool(n"SprintToggled") && DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) <= minStickInputThreshold {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Sprint") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    return false;
  }
}

public class SprintEvents extends LocomotionGroundEvents {

  public let m_previousStimTimeStamp: Float;

  public let m_reloadModifier: ref<gameStatModifierData>;

  public let m_isInSecondSprint: Bool;

  public let m_sprintModifier: ref<gameStatModifierData>;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_previousStimTimeStamp = -1.00;
    this.m_isInSecondSprint = false;
    this.OnEnter(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Sprint));
    DefaultTransition.UpdateAimAssist(stateContext, scriptInterface);
    this.SetupSprintInputLock(stateContext, scriptInterface);
    stateContext.SetConditionBoolParameter(n"blockEnteringSlide", false, true);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    stateContext.SetTemporaryBoolParameter(n"CancelGrenadeAction", true, true);
    this.ForceDisableVisionMode(stateContext);
    this.StartEffect(scriptInterface, n"locomotion_sprint");
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload) {
      stateContext.SetTemporaryBoolParameter(n"InterruptReload", true, true);
    };
    if !this.GetStaticBoolParameterDefault("enableTwoStepSprint_EXPERIMENTAL", false) {
      this.AddMaxSpeedModifier(stateContext, scriptInterface);
    };
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Sprint);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let isReloading: Bool;
    let isShooting: Bool;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    this.UpdateFootstepSprintStim(stateContext, scriptInterface);
    isReloading = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload);
    isShooting = scriptInterface.GetActionValue(n"RangedAttack") > 0.00;
    this.EvaluateTwoStepSprint(stateContext, scriptInterface);
    if (isReloading && !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSprinting) || isShooting && !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponShootWhileSprinting)) && !IsDefined(this.m_reloadModifier) {
      AnimationControllerComponent.SetInputFloat(scriptInterface.executionOwner, n"sprint", 0.00);
      this.EnableReloadStatModifier(true, stateContext, scriptInterface);
    } else {
      if !(isReloading || isShooting) && IsDefined(this.m_reloadModifier) {
        AnimationControllerComponent.SetInputFloat(scriptInterface.executionOwner, n"sprint", 1.00);
        this.EnableReloadStatModifier(false, stateContext, scriptInterface);
      };
    };
  }

  private final func EvaluateTwoStepSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetStaticBoolParameterDefault("enableTwoStepSprint_EXPERIMENTAL", false) {
      if this.ShouldEnterSecondSprint(stateContext, scriptInterface) {
        this.m_isInSecondSprint = true;
        this.AddMaxSpeedModifier(stateContext, scriptInterface);
      } else {
        if this.m_isInSecondSprint && this.GetInStateTime() >= 0.50 && scriptInterface.IsActionJustPressed(n"ToggleSprint") {
          this.m_isInSecondSprint = false;
          this.RemoveMaxSpeedModifier(stateContext, scriptInterface);
        };
      };
    };
  }

  private final func AddMaxSpeedModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    this.m_sprintModifier = RPGManager.CreateStatModifierUsingCurve(gamedataStatType.MaxSpeed, gameStatModifierType.Additive, gamedataStatType.Reflexes, n"locomotion_stats", n"max_speed_in_sprint");
    statSystem.AddModifier(Cast(scriptInterface.ownerEntityID), this.m_sprintModifier);
  }

  private final func RemoveMaxSpeedModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    if IsDefined(this.m_sprintModifier) {
      statSystem.RemoveModifier(Cast(scriptInterface.ownerEntityID), this.m_sprintModifier);
      this.m_sprintModifier = null;
    };
  }

  private final func ShouldEnterSecondSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.m_isInSecondSprint && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("minTimeToEnterTwoStepSprint", 0.00) && scriptInterface.IsActionJustPressed(n"ToggleSprint");
  }

  private final func CleanupTwoStepSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_isInSecondSprint = false;
    this.RemoveMaxSpeedModifier(stateContext, scriptInterface);
  }

  protected final const func GetReloadModifier(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let modifierStart: Float = this.GetStaticFloatParameterDefault("reloadModifierStart", -2.00);
    let modifierEnd: Float = this.GetStaticFloatParameterDefault("reloadModifierEnd", -2.00);
    let modifierRange: Float = modifierEnd - modifierStart;
    let statValue: Float = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.Reflexes);
    let lerp: Float = (statValue - 1.00) / 19.00;
    let result: Float = modifierStart + lerp * modifierRange;
    return result;
  }

  protected func EnableReloadStatModifier(enable: Bool, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let reloadModifierAmount: Float;
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    if enable && !IsDefined(this.m_reloadModifier) {
      reloadModifierAmount = this.GetReloadModifier(scriptInterface);
      this.m_reloadModifier = RPGManager.CreateStatModifier(gamedataStatType.MaxSpeed, gameStatModifierType.Additive, reloadModifierAmount);
      scriptInterface.GetStatsSystem().AddModifier(ownerID, this.m_reloadModifier);
    } else {
      if !enable && IsDefined(this.m_reloadModifier) {
        scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_reloadModifier);
        this.m_reloadModifier = null;
      };
    };
  }

  protected final func UpdateFootstepSprintStim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= this.m_previousStimTimeStamp + 0.20 {
      this.m_previousStimTimeStamp = this.GetInStateTime();
      this.BroadcastStimuliFootstepSprint(scriptInterface);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanupTwoStepSprint(stateContext, scriptInterface);
    this.EnableReloadStatModifier(false, stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    stateContext.SetPermanentFloatParameter(n"SprintingStoppedTimeStamp", scriptInterface.GetNow(), true);
    this.StopEffect(scriptInterface, n"locomotion_sprint");
    this.OnExit(stateContext, scriptInterface);
  }

  protected func OnExitToJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanupTwoStepSprint(stateContext, scriptInterface);
    this.EnableReloadStatModifier(false, stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    stateContext.SetPermanentFloatParameter(n"SprintingStoppedTimeStamp", scriptInterface.GetNow(), true);
    this.StopEffect(scriptInterface, n"locomotion_sprint");
    this.OnExit(stateContext, scriptInterface);
  }

  protected func OnExitToChargeJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanupTwoStepSprint(stateContext, scriptInterface);
    this.EnableReloadStatModifier(false, stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"locomotion_sprint");
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.CleanupTwoStepSprint(stateContext, scriptInterface);
    this.EnableReloadStatModifier(false, stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"locomotion_sprint");
  }
}

public class SlideFallDecisions extends LocomotionAirDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.ShouldFall(stateContext, scriptInterface);
  }

  protected final const func ToSlide(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func ToFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let fallingSpeedThreshold: Float;
    let height: Float;
    let verticalSpeed: Float;
    if AbsF(this.GetCameraYaw(stateContext, scriptInterface)) >= this.GetStaticFloatParameterDefault("maxCameraYawToExit", 95.00) {
      return true;
    };
    if this.GetStaticBoolParameterDefault("backInputExitsSlide", false) && scriptInterface.GetActionValue(n"MoveY") < -0.50 {
      return true;
    };
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) <= this.GetStaticFloatParameterDefault("minSpeedToExit", 2.00) && NotEquals(stateContext.GetStateMachineCurrentState(n"TimeDilation"), n"kerenzikov") {
      return true;
    };
    height = this.GetStaticFloatParameterDefault("heightToEnterFall", 0.00);
    if height > 0.00 {
      fallingSpeedThreshold = this.GetFallingSpeedBasedOnHeight(scriptInterface, height);
      verticalSpeed = this.GetVerticalSpeed(scriptInterface);
      if verticalSpeed <= fallingSpeedThreshold {
        return true;
      };
    };
    return false;
  }
}

public class SlideFallEvents extends LocomotionAirEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.SlideFall);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.SlideFall));
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
  }
}

public class SlideDecisions extends CrouchDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let angle: Float;
    let currentSpeed: Float;
    let secureFootingResult: SecureFootingResult;
    let velocity: Vector4;
    let superResult: Bool = this.EnterCondition(stateContext, scriptInterface);
    if !superResult {
      return false;
    };
    if stateContext.GetConditionBool(n"blockEnteringSlide") {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoSlide") {
      return false;
    };
    velocity = DefaultTransition.GetLinearVelocity(scriptInterface);
    angle = Vector4.GetAngleBetween(scriptInterface.executionOwner.GetWorldForward(), velocity);
    if AbsF(angle) > 45.00 {
      return false;
    };
    currentSpeed = Vector4.Length2D(velocity);
    secureFootingResult = scriptInterface.HasSecureFooting();
    if Equals(secureFootingResult.type, moveSecureFootingFailureType.Slope) {
      return true;
    };
    if currentSpeed < this.GetStaticFloatParameterDefault("minSpeedToEnter", 4.50) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() {
      return false;
    };
    return true;
  }

  protected const func ToCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    if this.ShouldExit(stateContext, scriptInterface) {
      return scriptInterface.GetActionValue(n"Crouch") > 0.00 || stateContext.GetConditionBool(n"CrouchToggled");
    };
    return false;
  }

  protected const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    if this.GetInStateTime() < this.GetStaticFloatParameterDefault("minTimeToExit", 1.00) {
      return false;
    };
    if !stateContext.GetConditionBool(n"CrouchToggled") && scriptInterface.GetActionValue(n"Crouch") <= 0.00 {
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Crouch") || scriptInterface.IsActionJustPressed(n"Sprint") || scriptInterface.IsActionJustPressed(n"ToggleSprint") || scriptInterface.IsActionJustPressed(n"Jump") || scriptInterface.IsActionJustTapped(n"ToggleCrouch") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      return true;
    };
    return this.ShouldExit(stateContext, scriptInterface);
  }

  protected const func ShouldExit(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isKerenzikovEnd: Bool;
    let isKerenzikovStateActive: Bool;
    if AbsF(this.GetCameraYaw(stateContext, scriptInterface)) >= this.GetStaticFloatParameterDefault("maxCameraYawToExit", 95.00) {
      return true;
    };
    isKerenzikovStateActive = Equals(stateContext.GetStateMachineCurrentState(n"TimeDilation"), n"kerenzikov");
    if this.GetStaticBoolParameterDefault("backInputExitsSlide", false) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("minTimeToExit", 0.70) && scriptInterface.GetActionValue(n"MoveY") < -0.50 {
      return true;
    };
    if scriptInterface.GetOwnerStateVectorParameterFloat(physicsStateValue.LinearSpeed) <= this.GetStaticFloatParameterDefault("minSpeedToExit", 3.00) {
      return !isKerenzikovStateActive;
    };
    isKerenzikovEnd = isKerenzikovStateActive && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff");
    if isKerenzikovEnd {
      return true;
    };
    return false;
  }
}

public class SlideEvents extends CrouchEvents {

  public let m_rumblePlayed: Bool;

  public let m_addDecelerationModifier: ref<gameStatModifierData>;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    this.m_rumblePlayed = false;
    if this.GetStaticBoolParameterDefault("pushAnimEventOnEnter", false) {
      scriptInterface.PushAnimationEvent(n"Slide");
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileSliding) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload) {
      stateContext.SetTemporaryBoolParameter(n"InterruptReload", true, true);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Slide));
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Slide);
  }

  public final func OnEnterFromSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.BroadcastStimuliFootstepSprint(scriptInterface);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func AddDecelerationStatModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, enable: Bool) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    if enable && !IsDefined(this.m_addDecelerationModifier) {
      this.m_addDecelerationModifier = RPGManager.CreateStatModifier(gamedataStatType.Deceleration, gameStatModifierType.Additive, this.GetStaticFloatParameterDefault("backInputDecelerationModifier", 8.00));
      scriptInterface.GetStatsSystem().AddModifier(ownerID, this.m_addDecelerationModifier);
    } else {
      if !enable && IsDefined(this.m_addDecelerationModifier) {
        scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_addDecelerationModifier);
        this.m_addDecelerationModifier = null;
      };
    };
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    if !this.m_rumblePlayed && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("rumbleDelay", 0.50) {
      this.m_rumblePlayed = true;
      DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleName", "medium_slow"));
    };
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("minTimeToExit", 1.00) {
      this.UpdateInputToggles(stateContext, scriptInterface);
    };
    if this.GetStaticBoolParameterDefault("backInputDeceleratesSlide", false) {
      this.EvaluateSlideDeceleration(stateContext, scriptInterface);
    };
  }

  private final func EvaluateSlideDeceleration(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("minTimeToAllowDeceleration", 0.10) && scriptInterface.GetActionValue(n"MoveY") < -0.50 && !stateContext.GetBoolParameter(n"isDecelerating", true) {
      stateContext.SetPermanentBoolParameter(n"isDecelerating", true, true);
      this.AddDecelerationStatModifier(stateContext, scriptInterface, true);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  public final func OnExitToCrouch(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Crouch));
    scriptInterface.SetAnimationParameterFloat(n"crouch", 1.00);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  private final func CleanUpOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.AddDecelerationStatModifier(stateContext, scriptInterface, false);
    stateContext.RemovePermanentBoolParameter(n"isDecelerating");
  }
}

public class DodgeDecisions extends LocomotionGroundDecisions {

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Dodge");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeDirection");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeForward");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeRight");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeLeft");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeBack");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    this.EnableOnEnterCondition(false);
    if this.WantsToDodge(stateContext, scriptInterface) {
      if !scriptInterface.HasStatFlag(gamedataStatType.HasDodge) {
        return false;
      };
      if this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetKerenzikovKey()) {
        return false;
      };
      if !scriptInterface.HasStatFlag(gamedataStatType.CanAimWhileDodging) && stateContext.IsStateActive(n"UpperBody", n"aimingState") && DefaultTransition.IsRangedWeaponEquipped(scriptInterface) {
        return false;
      };
      return true;
    };
    return false;
  }

  protected const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isKerenzikovEnd: Bool;
    let isKerenzikovActive: Bool = this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetKerenzikovKey());
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeBuff") {
      return !isKerenzikovActive;
    };
    isKerenzikovEnd = isKerenzikovActive && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff");
    if isKerenzikovEnd {
      return true;
    };
    return false;
  }
}

public class DodgeEvents extends LocomotionGroundEvents {

  public let m_blockStatFlag: ref<gameStatModifierData>;

  public let m_decelerationModifier: ref<gameStatModifierData>;

  @default(DodgeEvents, false)
  public let m_pressureWaveCreated: Bool;

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    let questSystem: ref<QuestsSystem> = scriptInterface.GetQuestsSystem();
    let dodgeHeading: Float = stateContext.GetConditionFloat(n"DodgeDirection");
    this.OnEnter(stateContext, scriptInterface);
    this.Dodge(stateContext, scriptInterface);
    this.PlayRumbleBasedOnDodgeDirection(stateContext, scriptInterface);
    questSystem.SetFact(n"gmpl_player_dodged", questSystem.GetFact(n"gmpl_player_dodged") + 1);
    scriptInterface.PushAnimationEvent(n"Dodge");
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeBuff");
    if dodgeHeading < -45.00 || dodgeHeading > 45.00 {
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeInvulnerability");
    };
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    this.m_blockStatFlag = RPGManager.CreateStatModifier(gamedataStatType.IsDodging, gameStatModifierType.Additive, 1.00);
    scriptInterface.GetStatsSystem().AddModifier(ownerID, this.m_blockStatFlag);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Dodge);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Dodge));
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if !this.m_pressureWaveCreated && this.GetInStateTime() >= 0.15 {
      this.m_pressureWaveCreated = true;
      this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.Dodge"));
    };
    if scriptInterface.IsActionJustPressed(n"Jump") {
      stateContext.SetConditionBoolParameter(n"JumpPressed", true, true);
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpOnExit(stateContext, scriptInterface);
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  private final func CleanUpOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    this.m_pressureWaveCreated = false;
    scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_blockStatFlag);
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeBuff");
    this.EnableMovementDecelerationStatModifier(stateContext, scriptInterface, false);
  }

  protected final func Dodge(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let dodgeHeading: Float;
    let impulse: Vector4;
    let impulseValue: Float;
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, PlayerStaminaHelpers.GetExhaustedStatusEffectID()) {
      this.EnableMovementDecelerationStatModifier(stateContext, scriptInterface, true);
      impulseValue = this.GetStaticFloatParameterDefault("impulseNoStamina", 4.80);
    } else {
      this.EnableMovementDecelerationStatModifier(stateContext, scriptInterface, false);
      impulseValue = this.GetStaticFloatParameterDefault("impulse", 13.00);
    };
    dodgeHeading = stateContext.GetConditionFloat(n"DodgeDirection");
    impulse = Vector4.FromHeading(AngleNormalize180(scriptInterface.executionOwner.GetWorldYaw() + dodgeHeading)) * impulseValue;
    this.AddImpulse(stateContext, impulse);
  }

  protected func EnableMovementDecelerationStatModifier(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, enable: Bool) -> Void {
    let ownerID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    if enable && !IsDefined(this.m_decelerationModifier) {
      this.m_decelerationModifier = RPGManager.CreateStatModifier(gamedataStatType.Deceleration, gameStatModifierType.Additive, this.GetStaticFloatParameterDefault("movementDecelerationNoStamina", -90.00));
      scriptInterface.GetStatsSystem().AddModifier(ownerID, this.m_decelerationModifier);
    } else {
      if !enable && IsDefined(this.m_decelerationModifier) {
        scriptInterface.GetStatsSystem().RemoveModifier(ownerID, this.m_decelerationModifier);
        this.m_decelerationModifier = null;
      };
    };
  }
}

public class ClimbDecisions extends LocomotionGroundDecisions {

  public const let stateBodyDone: Bool;

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let climbInfo: ref<PlayerClimbInfo>;
    let enterAngleThreshold: Float;
    let isObstacleSuitable: Bool;
    let preClimbAnimFeature: ref<AnimFeature_PreClimbing>;
    let isPathClear: Bool = false;
    let isInAcceptableAerialState: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Jump) || this.IsInLocomotionState(stateContext, n"dodgeAir") || stateContext.GetBoolParameter(n"enteredFallFromAirDodge", true);
    if !isInAcceptableAerialState && !(stateContext.GetConditionBool(n"JumpPressed") || scriptInterface.IsActionJustPressed(n"Jump")) {
      return false;
    };
    climbInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    isObstacleSuitable = climbInfo.climbValid && this.OverlapFitTest(scriptInterface, climbInfo);
    if isObstacleSuitable {
      isPathClear = this.TestClimbingPath(scriptInterface, climbInfo, DefaultTransition.GetPlayerPosition(scriptInterface));
      isObstacleSuitable = isObstacleSuitable && isPathClear;
    };
    preClimbAnimFeature = new AnimFeature_PreClimbing();
    preClimbAnimFeature.valid = 0.00;
    if isObstacleSuitable {
      preClimbAnimFeature.edgePositionLS = scriptInterface.TransformInvPointFromObject(climbInfo.descResult.topPoint);
      preClimbAnimFeature.valid = 1.00;
    };
    stateContext.SetConditionScriptableParameter(n"PreClimbAnimFeature", preClimbAnimFeature, true);
    if isObstacleSuitable {
      if this.IsVaultingClimbingRestricted(scriptInterface) {
        return false;
      };
      if !this.ForwardAngleTest(stateContext, scriptInterface, climbInfo) {
        return false;
      };
      if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
        return false;
      };
      if AbsF(scriptInterface.GetInputHeading()) > 45.00 || this.IsPlayerMovingBackwards(stateContext, scriptInterface) {
        return false;
      };
      if this.IsCameraPitchAcceptable(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("cameraPitchThreshold", -30.00)) {
        return false;
      };
      if stateContext.IsStateActive(n"Locomotion", n"chargeJump") && this.GetVerticalSpeed(scriptInterface) > 0.00 {
        return false;
      };
      enterAngleThreshold = this.GetStaticFloatParameterDefault("inputAngleThreshold", -180.00);
      if !(AbsF(scriptInterface.GetInputHeading()) <= enterAngleThreshold) {
        return false;
      };
      if !MeleeTransition.MeleeUseExplorationCondition(stateContext, scriptInterface) {
        return false;
      };
      return isObstacleSuitable;
    };
    return false;
  }

  public final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }

  public final const func ToCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }

  private final const func ForwardAngleTest(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>) -> Bool {
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let obstaclePosition: Vector4 = climbInfo.descResult.collisionNormal;
    let forwardAngleDifference: Float = Vector4.GetAngleBetween(-obstaclePosition, playerForward);
    let enterAngleThreshold: Float = this.GetStaticFloatParameterDefault("obstacleEnterAngleThreshold", -180.00);
    if forwardAngleDifference < enterAngleThreshold && forwardAngleDifference - 180.00 < enterAngleThreshold {
      return true;
    };
    return false;
  }

  private final const func TestClimbingPath(const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>, playerPosition: Vector4) -> Bool {
    let fitTestOvelap1: TraceResult;
    let fitTestOvelap2: TraceResult;
    let overlapPosition2: Vector4;
    let overlapResult1: Bool;
    let overlapResult2: Bool;
    let playerCapsuleDimensions: Vector4;
    let rayCastDestinationPosition1: Vector4;
    let rayCastDestinationPosition2: Vector4;
    let rayCastResult1: Bool;
    let rayCastResult2: Bool;
    let rayCastSourcePosition2: Vector4;
    let rayCastTraceResult1: TraceResult;
    let rayCastTraceResult2: TraceResult;
    let rotation1: EulerAngles;
    let rotation2: EulerAngles;
    let groundTolerance: Float = 0.05;
    let tolerance: Float = 0.15;
    playerCapsuleDimensions.X = this.GetStaticFloatParameterDefault("capsuleRadius", 0.40);
    playerCapsuleDimensions.Y = -1.00;
    playerCapsuleDimensions.Z = -1.00;
    let climbDestination: Vector4 = climbInfo.descResult.topPoint + DefaultTransition.GetUpVector() * (playerCapsuleDimensions.X + tolerance);
    let overlapPosition1: Vector4 = playerPosition;
    overlapPosition1.Z = climbDestination.Z;
    let rayCastSourcePosition1: Vector4 = playerPosition;
    rayCastSourcePosition1.Z += groundTolerance;
    rayCastDestinationPosition1 = overlapPosition1;
    rayCastTraceResult1 = scriptInterface.RayCast(rayCastSourcePosition1, rayCastDestinationPosition1, n"Simple Environment Collision");
    rayCastResult1 = TraceResult.IsValid(rayCastTraceResult1);
    if !rayCastResult1 {
      overlapResult1 = scriptInterface.Overlap(playerCapsuleDimensions, overlapPosition1, rotation1, n"Simple Environment Collision", fitTestOvelap1);
    };
    if !rayCastResult1 && !overlapResult1 {
      overlapPosition2 = climbDestination;
      rayCastSourcePosition2 = overlapPosition1;
      rayCastDestinationPosition2 = overlapPosition2;
      rayCastTraceResult2 = scriptInterface.RayCast(rayCastSourcePosition2, rayCastDestinationPosition2, n"Simple Environment Collision");
      rayCastResult2 = TraceResult.IsValid(rayCastTraceResult2);
      if !rayCastResult2 {
        overlapResult2 = scriptInterface.Overlap(playerCapsuleDimensions, overlapPosition2, rotation2, n"Simple Environment Collision", fitTestOvelap2);
      };
    };
    return !rayCastResult1 && !overlapResult1 && !rayCastResult2 && !overlapResult2;
  }

  private final const func OverlapFitTest(const scriptInterface: ref<StateGameScriptInterface>, climbInfo: ref<PlayerClimbInfo>) -> Bool {
    let fitTestOvelap: TraceResult;
    let playerCapsuleDimensions: Vector4;
    let rotation: EulerAngles;
    let tolerance: Float = 0.15;
    playerCapsuleDimensions.X = this.GetStaticFloatParameterDefault("capsuleRadius", 0.40);
    playerCapsuleDimensions.Y = -1.00;
    playerCapsuleDimensions.Z = -1.00;
    let queryPosition: Vector4 = climbInfo.descResult.topPoint + DefaultTransition.GetUpVector() * (playerCapsuleDimensions.X + tolerance);
    let crouchOverlap: Bool = scriptInterface.Overlap(playerCapsuleDimensions, queryPosition, rotation, n"Simple Environment Collision", fitTestOvelap);
    return !crouchOverlap;
  }
}

public class ClimbEvents extends LocomotionGroundEvents {

  public let m_ikHandEvents: array<ref<IKTargetAddEvent>>;

  public let m_shouldIkHands: Bool;

  public let m_framesDelayingAnimStart: Int32;

  private final func GetClimbParameter(scriptInterface: ref<StateGameScriptInterface>) -> ref<ClimbParameters> {
    let climbSpeed: Float;
    let climbTypeKey: String;
    let obstacleHeight: Float;
    let climbParameters: ref<ClimbParameters> = new ClimbParameters();
    let statSystem: ref<StatsSystem> = scriptInterface.GetStatsSystem();
    let direction: Vector4 = scriptInterface.GetOwnerForward();
    let directionOffset: Vector4 = direction * this.GetStaticFloatParameterDefault("capsuleRadius", 0.00);
    let climbInfo: ref<PlayerClimbInfo> = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    climbParameters.SetObstacleFrontEdgePosition(climbInfo.descResult.topPoint);
    climbParameters.SetObstacleFrontEdgeNormal(climbInfo.descResult.collisionNormal);
    climbParameters.SetObstacleVerticalDestination(climbInfo.descResult.topPoint - directionOffset);
    climbParameters.SetObstacleSurfaceNormal(climbInfo.descResult.topNormal);
    climbParameters.SetObstacleHorizontalDestination(climbInfo.descResult.topPoint + direction * this.GetStaticFloatParameterDefault("forwardStep", 0.50));
    obstacleHeight = climbInfo.descResult.topPoint.Z - playerPosition.Z;
    if obstacleHeight > this.GetStaticFloatParameterDefault("highThreshold", 1.00) {
      climbParameters.SetClimbType(0);
      climbTypeKey = "High";
      this.m_shouldIkHands = true;
    } else {
      if obstacleHeight > this.GetStaticFloatParameterDefault("midThreshold", 1.00) {
        climbParameters.SetClimbType(1);
        climbTypeKey = "Mid";
        this.m_shouldIkHands = true;
      } else {
        climbParameters.SetClimbType(2);
        climbTypeKey = "Low";
        this.m_shouldIkHands = false;
      };
    };
    climbSpeed = this.GetStatFloatValue(scriptInterface, gamedataStatType.ClimbSpeedModifier, statSystem);
    if climbSpeed <= 0.00 {
      climbSpeed = 1.00;
    };
    climbParameters.SetHorizontalDuration(climbSpeed * this.GetStaticFloatParameterDefault("horizontalDuration" + climbTypeKey, 10.00));
    climbParameters.SetVerticalDuration(climbSpeed * this.GetStaticFloatParameterDefault("verticalDuration" + climbTypeKey, 10.00));
    climbParameters.SetAnimationNameApproach(this.GetStaticCNameParameterDefault("animationNameApproach", n""));
    return climbParameters;
  }

  private final func CreateIKConstraint(scriptInterface: ref<StateGameScriptInterface>, const handData: HandIKDescriptionResult, const refUpVector: Vector4, const ikChainName: CName) -> Void {
    let ikEvent: ref<IKTargetAddEvent> = new IKTargetAddEvent();
    let edgeSlop: Vector4 = handData.grabPointStart - handData.grabPointEnd;
    let handNormal: Vector4 = Vector4.Cross(edgeSlop, refUpVector);
    handNormal = Vector4.Normalize(handNormal);
    handNormal.Z = 0.30;
    handNormal = Vector4.Normalize(handNormal);
    let handOrientation: Matrix = Matrix.BuildFromDirectionVector(handNormal, edgeSlop);
    ikEvent.SetStaticTarget(handData.grabPointEnd + edgeSlop * 0.50);
    ikEvent.SetStaticOrientationTarget(Matrix.ToQuat(handOrientation));
    ikEvent.request.transitionIn = 0.00;
    ikEvent.request.priority = -100;
    ikEvent.bodyPart = ikChainName;
    scriptInterface.owner.QueueEvent(ikEvent);
    ArrayPush(this.m_ikHandEvents, ikEvent);
  }

  private final func AddHandIK(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let climbInfo: ref<PlayerClimbInfo> = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    this.CreateIKConstraint(scriptInterface, climbInfo.descResult.leftHandData, new Vector4(0.00, 0.00, 1.00, 0.00), n"ikLeftArm");
    this.CreateIKConstraint(scriptInterface, climbInfo.descResult.rightHandData, new Vector4(0.00, 0.00, -1.00, 0.00), n"ikRightArm");
  }

  private final func RemoveHandIK(scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ikEvent: ref<IKTargetAddEvent>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_ikHandEvents) {
      ikEvent = this.m_ikHandEvents[i];
      if !IsDefined(ikEvent) {
      } else {
        IKTargetRemoveEvent.QueueRemoveIkTargetRemoveEvent(scriptInterface.owner, ikEvent);
      };
      i += 1;
    };
    ArrayClear(this.m_ikHandEvents);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    GameObject.PlayVoiceOver(scriptInterface.owner, n"climbStart", n"Scripts:ClimbEvents");
    stateContext.SetTemporaryScriptableParameter(n"climbInfo", this.GetClimbParameter(scriptInterface), true);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Climb);
    DefaultTransition.PlayRumble(scriptInterface, "light_fast");
    this.m_framesDelayingAnimStart = 0;
  }

  public func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_framesDelayingAnimStart = this.m_framesDelayingAnimStart + 1;
    if this.m_framesDelayingAnimStart == 3 {
      scriptInterface.SetAnimationParameterFeature(n"PreClimb", stateContext.GetConditionScriptableParameter(n"PreClimbAnimFeature") as AnimFeature_PreClimbing);
      stateContext.RemoveConditionScriptableParameter(n"PreClimbAnimFeature");
      if this.m_shouldIkHands {
        this.AddHandIK(scriptInterface);
      };
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.RemoveHandIK(scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.RemoveHandIK(scriptInterface);
  }
}

public class VaultDecisions extends LocomotionGroundDecisions {

  public const let stateBodyDone: Bool;

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  private final const func SpeedTest(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, vaultInfo: ref<PlayerClimbInfo>) -> Bool {
    let minDetectionRange: Float = this.GetStaticFloatParameterDefault("minDetectionRange", 0.40);
    let midObstacleDepth: Float = this.GetStaticFloatParameterDefault("minExtent", 0.01);
    let maxSpeedNormalizer: Float = this.GetStaticFloatParameterDefault("maxSpeedNormalizer", 8.50);
    let detectionRange: Float = this.GetStaticFloatParameterDefault("detectionRange", 2.00);
    let linearVelocity: Vector4 = DefaultTransition.GetLinearVelocity(scriptInterface);
    let normalizedSpeed: Float = MinF(1.00, Vector4.Length(linearVelocity) / maxSpeedNormalizer);
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let offsetFromObstacle: Vector4 = vaultInfo.descResult.topPoint - playerPosition;
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let offsetFromObstacleInVelocityVector: Vector4 = playerForward * Vector4.Dot(playerForward, offsetFromObstacle);
    let offsetFromObstacleInVelocityVectorMag: Float = Vector4.Length(offsetFromObstacleInVelocityVector);
    let maxExtent: Float = this.GetStaticFloatParameterDefault("maxExtent", 2.10);
    let obstacleExtent: Float = vaultInfo.descResult.topExtent;
    let maxClimbableDistanceFromCurve: Float = minDetectionRange + (detectionRange - minDetectionRange) * normalizedSpeed + 0.05;
    let maxClimbableExtentFromCurve: Float = midObstacleDepth + (maxExtent - midObstacleDepth) * normalizedSpeed;
    let resVelocity: Bool = offsetFromObstacleInVelocityVectorMag < maxClimbableDistanceFromCurve;
    let resDepth: Bool = obstacleExtent < maxClimbableExtentFromCurve;
    return resVelocity && resDepth;
  }

  protected final const func FitTest(const scriptInterface: ref<StateGameScriptInterface>, playerCapsuleDimensions: Vector4, vaultInfo: ref<PlayerClimbInfo>) -> Bool {
    let fitTest: TraceResult;
    let rotation: EulerAngles;
    let playerForward: Vector4 = scriptInterface.GetOwnerForward();
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let distance: Float = vaultInfo.descResult.topExtent;
    let direction: Vector4 = playerForward * distance;
    direction = Vector4.Normalize(direction);
    let queryPosition: Vector4 = vaultInfo.descResult.topPoint + DefaultTransition.GetUpVector() * playerCapsuleDimensions.X + 0.01;
    let freeSpace: Bool = !scriptInterface.Sweep(playerCapsuleDimensions, queryPosition, rotation, direction, distance, n"Simple Environment Collision", false, fitTest);
    let deltaZ: Bool = vaultInfo.descResult.behindPoint.Z - playerPosition.Z <= 0.40;
    return freeSpace && deltaZ;
  }

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Jump");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let enterAngleThreshold: Float;
    let playerCapsuleDimensions: Vector4;
    let vaultInfo: ref<PlayerClimbInfo>;
    this.EnableOnEnterCondition(false);
    if !scriptInterface.IsActionJustPressed(n"Jump") {
      return false;
    };
    if this.IsVaultingClimbingRestricted(scriptInterface) {
      return false;
    };
    if this.GetStaticBoolParameterDefault("requireDirectionalInputToVault", false) && !scriptInterface.IsMoveInputConsiderable() {
      return false;
    };
    enterAngleThreshold = this.GetStaticFloatParameterDefault("enterAngleThreshold", -180.00);
    if AbsF(scriptInterface.GetInputHeading()) > enterAngleThreshold {
      return false;
    };
    if !MeleeTransition.MeleeUseExplorationCondition(stateContext, scriptInterface) {
      return false;
    };
    vaultInfo = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    playerCapsuleDimensions.X = this.GetStaticFloatParameterDefault("capsuleRadius", 0.40);
    playerCapsuleDimensions.Y = -1.00;
    playerCapsuleDimensions.Z = -1.00;
    return vaultInfo.vaultValid && this.FitTest(scriptInterface, playerCapsuleDimensions, vaultInfo) && this.SpeedTest(stateContext, scriptInterface, vaultInfo);
  }

  public final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }

  public final const func ToCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.stateBodyDone;
  }
}

public class VaultEvents extends LocomotionGroundEvents {

  protected final func GetVaultParameter(scriptInterface: ref<StateGameScriptInterface>) -> ref<VaultParameters> {
    let behindZ: Float;
    let landingPoint: Vector4;
    let obstacleEnd: Vector4;
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let vaultParameters: ref<VaultParameters> = new VaultParameters();
    let climbInfo: ref<PlayerClimbInfo> = scriptInterface.GetSpatialQueriesSystem().GetPlayerObstacleSystem().GetCurrentClimbInfo(scriptInterface.owner);
    let direction: Vector4 = scriptInterface.GetOwnerForward();
    vaultParameters.SetObstacleFrontEdgePosition(climbInfo.descResult.topPoint);
    vaultParameters.SetObstacleFrontEdgeNormal(climbInfo.descResult.collisionNormal);
    vaultParameters.SetObstacleVerticalDestination(climbInfo.descResult.topPoint);
    vaultParameters.SetObstacleSurfaceNormal(climbInfo.descResult.topNormal);
    obstacleEnd = climbInfo.obstacleEnd;
    behindZ = MaxF(climbInfo.descResult.behindPoint.Z, playerPosition.Z);
    landingPoint.X = obstacleEnd.X;
    landingPoint.Y = obstacleEnd.Y;
    landingPoint.Z = behindZ;
    vaultParameters.SetObstacleDestination(landingPoint + direction * this.GetStaticFloatParameterDefault("forwardStep", 0.50));
    vaultParameters.SetObstacleDepth(climbInfo.descResult.topExtent);
    vaultParameters.SetMinSpeed(this.GetStaticFloatParameterDefault("minSpeed", 3.50));
    return vaultParameters;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    stateContext.SetTemporaryScriptableParameter(n"vaultInfo", this.GetVaultParameter(scriptInterface), true);
    scriptInterface.PushAnimationEvent(n"Vault");
    GameObject.PlayVoiceOver(scriptInterface.owner, n"Vault", n"Scripts:VaultEvents");
    if !scriptInterface.HasStatFlag(gamedataStatType.CanWeaponReloadWhileVaulting) {
      stateContext.SetTemporaryBoolParameter(n"InterruptReload", true, true);
    };
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Vault);
    DefaultTransition.PlayRumble(scriptInterface, "medium_pulse");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Vault));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    stateContext.SetPermanentBoolParameter(n"ForceSafeState", false, true);
  }
}

public class LadderDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected final const func TestParameters(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, out ladderParameter: ref<LadderDescription>) -> Bool {
    let ladderFinishedParameter: StateResultBool;
    ladderParameter = stateContext.GetTemporaryScriptableParameter(n"usingLadder") as LadderDescription;
    if !IsDefined(ladderParameter) {
      ladderParameter = stateContext.GetConditionScriptableParameter(n"usingLadder") as LadderDescription;
      ladderFinishedParameter = stateContext.GetTemporaryBoolParameter(n"exitLadder");
      if ladderFinishedParameter.valid && ladderFinishedParameter.value {
        stateContext.RemoveConditionScriptableParameter(n"usingLadder");
        return false;
      };
      if !IsDefined(ladderParameter) {
        return false;
      };
    } else {
      stateContext.SetConditionScriptableParameter(n"usingLadder", ladderParameter, true);
    };
    return true;
  }

  protected final const func IsLadderEnterInProgress(const stateContext: ref<StateContext>) -> Bool {
    let isEntering: StateResultBool = stateContext.GetPermanentBoolParameter(n"setLadderEnterInputContext");
    if isEntering.valid && isEntering.value {
      return true;
    };
    return false;
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let finishedLadder: StateResultBool = stateContext.GetTemporaryBoolParameter(n"finishedLadderAction");
    return finishedLadder.valid && finishedLadder.value;
  }

  protected final const func ToLadderCrouch(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustPressed(n"Crouch") || scriptInterface.IsActionJustTapped(n"ToggleCrouch") {
      return true;
    };
    return false;
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isActionEnterLadder: Bool;
    let isActionEnterLadderParam: StateResultBool;
    let ladderParameter: ref<LadderDescription>;
    let testMath: Bool;
    let testParameters: Bool = this.TestParameters(stateContext, scriptInterface, ladderParameter);
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoLadder") {
      return false;
    };
    isActionEnterLadderParam = stateContext.GetTemporaryBoolParameter(n"actionEnterLadder");
    isActionEnterLadder = isActionEnterLadderParam.valid && isActionEnterLadderParam.value;
    if ladderParameter == null && !isActionEnterLadder {
      return false;
    };
    if !MeleeTransition.MeleeUseExplorationCondition(stateContext, scriptInterface) {
      return false;
    };
    testMath = this.TestLadderMath(stateContext, scriptInterface, ladderParameter);
    return testParameters && testMath || isActionEnterLadder;
  }
}

public class LadderEvents extends LocomotionGroundEvents {

  @default(LadderEvents, 0.f)
  public let m_ladderClimbCameraTimeStamp: Float;

  protected func SendLadderEnterStyleToGraph(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, enterStyle: Int32) -> Void {
    let animFeature: ref<AnimFeature_LadderEnterStyleData> = new AnimFeature_LadderEnterStyleData();
    animFeature.enterStyle = enterStyle;
    scriptInterface.SetAnimationParameterFeature(n"LadderEnterStyleData", animFeature);
  }

  public final func OnEnterFromJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 1);
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnEnterFromDoubleJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 2);
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnEnterFromChargeJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 3);
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnEnterFromDodgeAir(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 4);
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnEnterFromFall(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 5);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let ignoreUpdatingCameraParemeters: Bool;
    let locomotionState: CName;
    let cameraContextDirty: Bool = false;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if this.GetInStateTime() >= this.GetCameraInputLockDuration(stateContext) {
      this.SetLadderEnterInProgress(stateContext, false);
    };
    locomotionState = stateContext.GetStateMachineCurrentState(n"Locomotion");
    ignoreUpdatingCameraParemeters = Equals(locomotionState, n"ladderCrouch") || Equals(locomotionState, n"ladderJump") || Equals(locomotionState, n"ladderSprint") || Equals(locomotionState, n"ladderSlide");
    if ignoreUpdatingCameraParemeters {
      cameraContextDirty = this.UseLadderEnterClimbCameraContext(stateContext, false) || cameraContextDirty;
      cameraContextDirty = this.UseLadderCameraContext(stateContext, false) || cameraContextDirty;
      cameraContextDirty = this.UseLadderClimbCameraContext(stateContext, false) || cameraContextDirty;
    } else {
      if this.GetInStateTime() >= this.GetStaticFloatParameterDefault("ladderEnterCameraMinActiveTime", 0.00) && !stateContext.GetBoolParameter(n"isEnterClimbCameraContextSet", true) {
        stateContext.SetPermanentBoolParameter(n"isEnterClimbCameraContextSet", true, true);
        cameraContextDirty = this.UseLadderEnterClimbCameraContext(stateContext, false) || cameraContextDirty;
        cameraContextDirty = this.UseLadderCameraContext(stateContext, true) || cameraContextDirty;
      };
      if this.WantsToUseLadderClimbCameraContext(stateContext, scriptInterface) && !this.IsPlayerLookingAtTheLadder(stateContext, scriptInterface) && !stateContext.GetBoolParameter(n"isLadderClimbCameraContextSet", true) {
        stateContext.SetPermanentBoolParameter(n"isLadderClimbCameraContextSet", true, true);
        stateContext.RemovePermanentBoolParameter(n"isLadderCameraContextSet");
        this.m_ladderClimbCameraTimeStamp = this.GetInStateTime();
        cameraContextDirty = this.UseLadderCameraContext(stateContext, false) || cameraContextDirty;
        cameraContextDirty = this.UseLadderClimbCameraContext(stateContext, true) || cameraContextDirty;
      };
      if this.GetInStateTime() >= this.m_ladderClimbCameraTimeStamp + this.GetStaticFloatParameterDefault("climbCameraMinActiveTime", 0.00) && !stateContext.GetBoolParameter(n"isLadderCameraContextSet", true) {
        stateContext.RemovePermanentBoolParameter(n"isLadderClimbCameraContextSet");
        stateContext.SetPermanentBoolParameter(n"isLadderCameraContextSet", true, true);
        this.m_ladderClimbCameraTimeStamp = 0.00;
        cameraContextDirty = this.UseLadderClimbCameraContext(stateContext, false) || cameraContextDirty;
        cameraContextDirty = this.UseLadderCameraContext(stateContext, true) || cameraContextDirty;
      };
    };
    if cameraContextDirty {
      this.UpdateCameraContext(stateContext, scriptInterface);
    };
  }

  protected final func WantsToUseLadderClimbCameraContext(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsMoveInputConsiderable() && DefaultTransition.GetMovementInputActionValue(stateContext, scriptInterface) >= this.GetStaticFloatParameterDefault("minStickInputToSwapToClimbCamera", 0.00) && this.IsMovingVertically(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func IsPlayerLookingAtTheLadder(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let staticQueryFilter: QueryFilter;
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    QueryFilter.AddGroup(staticQueryFilter, n"Interaction");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.refPosition = Transform.GetPosition(cameraWorldTransform);
    geometryDescription.refDirection = Transform.GetForward(cameraWorldTransform);
    geometryDescription.filter = staticQueryFilter;
    geometryDescription.primitiveDimension = new Vector4(0.10, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 2.00;
    geometryDescription.maxExtent = 0.50;
    geometryDescription.probingPrecision = 0.05;
    geometryDescription.probingMaxDistanceDiff = 2.00;
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.DistanceVector);
    geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.NoGeometry) {
      return false;
    };
    return true;
  }

  protected final func IsMovingVertically(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    return verticalSpeed != 0.00;
  }

  protected final func UseLadderClimbCameraContext(stateContext: ref<StateContext>, value: Bool) -> Bool {
    let oldState: Bool = stateContext.GetBoolParameter(n"setLadderClimbCameraContext", true);
    if NotEquals(oldState, value) {
      stateContext.SetPermanentBoolParameter(n"setLadderClimbCameraContext", value, true);
      return true;
    };
    return false;
  }

  protected final func UseLadderEnterClimbCameraContext(stateContext: ref<StateContext>, value: Bool) -> Bool {
    let oldState: Bool = stateContext.GetBoolParameter(n"setLadderEnterClimbCameraContext", true);
    if NotEquals(oldState, value) {
      stateContext.SetPermanentBoolParameter(n"setLadderEnterClimbCameraContext", value, true);
      return true;
    };
    return false;
  }

  protected final func UseLadderCameraContext(stateContext: ref<StateContext>, value: Bool) -> Bool {
    let oldState: Bool = stateContext.GetBoolParameter(n"setLadderCameraContext", true);
    if NotEquals(oldState, value) {
      stateContext.SetPermanentBoolParameter(n"setLadderCameraContext", value, true);
      return true;
    };
    return false;
  }

  protected final func SetLadderEnterInProgress(stateContext: ref<StateContext>, value: Bool) -> Void {
    stateContext.SetPermanentBoolParameter(n"setLadderEnterInputContext", value, true);
  }

  protected final func SetCameraInputLockDuration(stateContext: ref<StateContext>) -> Void {
    let inputBlockDuration: Float;
    let isActionEnterLadder: StateResultBool = stateContext.GetTemporaryBoolParameter(n"actionEnterLadder");
    if isActionEnterLadder.valid && isActionEnterLadder.value {
      inputBlockDuration = this.GetStaticFloatParameterDefault("enterFromTopBlockCameraInput", 0.00);
    } else {
      inputBlockDuration = this.GetStaticFloatParameterDefault("enterBlockCameraInput", 0.00);
    };
    stateContext.SetPermanentFloatParameter(n"ladderEnterInputBlockDuration", inputBlockDuration, true);
  }

  protected final func GetCameraInputLockDuration(stateContext: ref<StateContext>) -> Float {
    let paramResult: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ladderEnterInputBlockDuration");
    return paramResult.value;
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_ladderClimbCameraTimeStamp = 0.00;
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Ladder);
    this.UseLadderEnterClimbCameraContext(stateContext, true);
    this.UpdateCameraContext(stateContext, scriptInterface);
    this.SetLadderEnterInProgress(stateContext, true);
    this.SetCameraInputLockDuration(stateContext);
  }

  protected final func OnExitToStand(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let direction: Vector4;
    let impulse: Vector4 = direction * this.GetStaticFloatParameterDefault("exitToStandPushMagnitude", 3.00);
    this.OnExit(stateContext, scriptInterface);
    this.AddImpulse(stateContext, impulse);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  protected final func OnExitToLadderSprint(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface, true);
  }

  protected final func OnExitToLadderSlide(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface, true);
  }

  protected final func OnExitToLadderJump(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  protected final func OnExitToLadderCrouch(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  protected final func OnExitToKnockdown(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  protected final func OnExitToStunned(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpLadderState(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpLadderState(stateContext, scriptInterface);
    this.OnForcedExit(stateContext, scriptInterface);
  }

  protected final func CleanUpLadderState(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, opt preserveScriptedCondition: Bool) -> Void {
    this.SendLadderEnterStyleToGraph(stateContext, scriptInterface, 0);
    this.UseLadderEnterClimbCameraContext(stateContext, false);
    this.UseLadderCameraContext(stateContext, false);
    this.UseLadderClimbCameraContext(stateContext, false);
    this.UpdateCameraContext(stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(n"isEnterClimbCameraContextSet");
    this.SetLadderEnterInProgress(stateContext, false);
    stateContext.RemovePermanentFloatParameter(n"ladderEnterInputBlockDuration");
    if !preserveScriptedCondition {
      stateContext.RemoveConditionScriptableParameter(n"usingLadder");
    };
  }
}

public class LadderSprintDecisions extends LadderDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsLadderEnterInProgress(stateContext) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() || this.GetVerticalSpeed(scriptInterface) < 0.00 {
      return false;
    };
    if scriptInterface.IsActionJustPressed(n"ToggleSprint") || stateContext.GetConditionBool(n"SprintToggled") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
      return true;
    };
    if scriptInterface.GetActionValue(n"Sprint") > 0.00 || scriptInterface.GetActionValue(n"ToggleSprint") > 0.00 {
      return true;
    };
    return false;
  }

  protected final const func ToLadder(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptSprint") {
      return true;
    };
    if !scriptInterface.IsMoveInputConsiderable() {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if !stateContext.GetConditionBool(n"SprintToggled") && scriptInterface.GetActionValue(n"Sprint") == 0.00 {
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Sprint") || scriptInterface.IsActionJustPressed(n"AttackA") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    return false;
  }
}

public class LadderSprintEvents extends LadderEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
  }

  protected final func OnExitToLadder(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpLadderState(stateContext, scriptInterface, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.LadderSprint);
    this.m_ladderClimbCameraTimeStamp = 0.00;
    this.UseLadderEnterClimbCameraContext(stateContext, true);
    this.SetLadderEnterInProgress(stateContext, true);
    this.SetCameraInputLockDuration(stateContext);
  }
}

public class LadderSlideDecisions extends LadderDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsLadderEnterInProgress(stateContext) {
      return false;
    };
    if !scriptInterface.IsMoveInputConsiderable() || this.GetVerticalSpeed(scriptInterface) > 0.00 {
      return false;
    };
    if scriptInterface.IsActionJustPressed(n"ToggleSprint") || stateContext.GetConditionBool(n"SprintToggled") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", true, true);
      return true;
    };
    if scriptInterface.GetActionValue(n"Sprint") > 0.00 || scriptInterface.GetActionValue(n"ToggleSprint") > 0.00 {
      return true;
    };
    return false;
  }

  protected final const func ToLadder(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if stateContext.GetBoolParameter(n"InterruptSprint") {
      return true;
    };
    if !scriptInterface.IsMoveInputConsiderable() || this.GetVerticalSpeed(scriptInterface) > 0.00 {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    if !stateContext.GetConditionBool(n"SprintToggled") && scriptInterface.GetActionValue(n"Sprint") == 0.00 {
      return true;
    };
    if scriptInterface.IsActionJustReleased(n"Sprint") || scriptInterface.IsActionJustPressed(n"AttackA") {
      stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
      return true;
    };
    return false;
  }
}

public class LadderSlideEvents extends LadderEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected final func OnExitToLadder(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CleanUpLadderState(stateContext, scriptInterface, true);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.LadderSlide);
  }
}

public class LadderJumpEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let cameraEntityRightDot: Float;
    let cameraTransform: Transform;
    let horizontalCameraDirection: Vector4;
    let jumpDirection: Vector4;
    let ownerRight: Vector4;
    let ownerTransform: Transform;
    let pitchAngle: Float = this.GetStaticFloatParameterDefault("pitchAngle", 45.00);
    let rightMultiplier: Float = 0.00;
    let forwardMultiplier: Float = 0.00;
    let angleToleranceForLateralJump: Float = 0.00;
    let sideDirectionAbs: Float = 0.00;
    this.OnEnter(stateContext, scriptInterface);
    ownerTransform = scriptInterface.GetOwnerTransform();
    ownerRight = Transform.GetRight(ownerTransform);
    cameraTransform = scriptInterface.GetCameraWorldTransform();
    horizontalCameraDirection = Transform.GetForward(cameraTransform);
    horizontalCameraDirection.Z = 0.00;
    horizontalCameraDirection = Vector4.Normalize(horizontalCameraDirection);
    ownerRight.Z = 0.00;
    ownerRight = Vector4.Normalize(ownerRight);
    cameraEntityRightDot = Rad2Deg(AcosF(Vector4.Dot(horizontalCameraDirection, ownerRight)));
    angleToleranceForLateralJump = this.GetStaticFloatParameterDefault("angleToleranceForLateralJump", 30.00);
    sideDirectionAbs = AbsF(cameraEntityRightDot);
    if sideDirectionAbs < 90.00 - angleToleranceForLateralJump {
      if angleToleranceForLateralJump > 0.00 {
        rightMultiplier = 1.00;
      };
    } else {
      if sideDirectionAbs > 90.00 + angleToleranceForLateralJump {
        rightMultiplier = -1.00;
      } else {
        forwardMultiplier = -1.00;
      };
    };
    jumpDirection.X = rightMultiplier;
    jumpDirection.Y = forwardMultiplier;
    jumpDirection.Z = SinF(Deg2Rad(pitchAngle));
    jumpDirection = Vector4.Normalize(jumpDirection);
    jumpDirection = Transform.TransformVector(ownerTransform, jumpDirection);
    this.AddImpulse(stateContext, jumpDirection * this.GetStaticFloatParameterDefault("impulseStrength", 4.00));
    stateContext.SetTemporaryBoolParameter(n"finishedLadderAction", true, true);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.LadderJump);
  }
}

public abstract class LocomotionAirDecisions extends LocomotionTransition {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return true;
  }

  protected final const func ShouldFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let regularLandingFallingSpeed: Float;
    let verticalSpeed: Float;
    if this.IsTouchingGround(scriptInterface) {
      return false;
    };
    this.IsTouchingGround(scriptInterface);
    if scriptInterface.IsOnMovingPlatform() {
      return false;
    };
    if stateContext.GetBoolParameter(n"isAttacking", true) {
      return true;
    };
    regularLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("regularLandingHeight", 0.10));
    verticalSpeed = this.GetVerticalSpeed(scriptInterface);
    return verticalSpeed < regularLandingFallingSpeed;
  }

  protected final const func GetLandingType(const stateContext: ref<StateContext>) -> Int32 {
    return stateContext.GetIntParameter(n"LandingType", true);
  }

  protected const func ToRegularLand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32 = this.GetLandingType(stateContext);
    if !this.IsTouchingGround(scriptInterface) || this.GetVerticalSpeed(scriptInterface) > 0.00 {
      return false;
    };
    return landingType <= EnumInt(LandingType.Regular);
  }

  protected final const func ToHardLand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32;
    if !this.IsTouchingGround(scriptInterface) || this.GetVerticalSpeed(scriptInterface) > 0.00 {
      return false;
    };
    landingType = this.GetLandingType(stateContext);
    return landingType == EnumInt(LandingType.Hard);
  }

  protected final const func ToVeryHardLand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32;
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    landingType = this.GetLandingType(stateContext);
    return landingType == EnumInt(LandingType.VeryHard);
  }

  protected final const func ToSuperheroLand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32 = this.GetLandingType(stateContext);
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    return landingType == EnumInt(LandingType.Superhero);
  }

  protected final const func ToDeathLand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let landingType: Int32;
    if !this.IsTouchingGround(scriptInterface) {
      return false;
    };
    landingType = this.GetLandingType(stateContext);
    return landingType == EnumInt(LandingType.Death);
  }
}

public abstract class LocomotionAirEvents extends LocomotionEventsTransition {

  @default(LocomotionAirEvents, false)
  public let m_maxSuperheroFallHeight: Bool;

  @default(AirThrustersEvents, false)
  @default(DodgeAirEvents, false)
  @default(LocomotionAirEvents, true)
  public let m_updateInputToggles: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let animFeature: ref<AnimFeature_PlayerLocomotionStateMachine>;
    let deathLandingFallingSpeed: Float;
    let hardLandingFallingSpeed: Float;
    let regularLandingFallingSpeed: Float;
    let safeLandingFallingSpeed: Float;
    let veryHardLandingFallingSpeed: Float;
    this.OnEnter(stateContext, scriptInterface);
    regularLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("regularLandingHeight", 0.10));
    safeLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("safeLandingHeight", 0.10));
    hardLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("hardLandingHeight", 1.00));
    veryHardLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("veryHardLandingHeight", 1.00));
    deathLandingFallingSpeed = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("deathLanding", 1.00));
    stateContext.SetPermanentFloatParameter(n"RegularLandingFallingSpeed", regularLandingFallingSpeed, true);
    stateContext.SetPermanentFloatParameter(n"SafeLandingFallingSpeed", safeLandingFallingSpeed, true);
    stateContext.SetPermanentFloatParameter(n"HardLandingFallingSpeed", hardLandingFallingSpeed, true);
    stateContext.SetPermanentFloatParameter(n"VeryHardLandingFallingSpeed", veryHardLandingFallingSpeed, true);
    stateContext.SetPermanentFloatParameter(n"DeathLandingFallingSpeed", deathLandingFallingSpeed, true);
    animFeature = new AnimFeature_PlayerLocomotionStateMachine();
    animFeature.inAirState = true;
    scriptInterface.SetAnimationParameterFeature(n"LocomotionStateMachine", animFeature);
    scriptInterface.PushAnimationEvent(n"InAir");
    scriptInterface.GetTargetingSystem().SetIsMovingFast(scriptInterface.owner, true);
    this.m_maxSuperheroFallHeight = false;
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let deathLandingFallingSpeed: Float;
    let hardLandingFallingSpeed: Float;
    let horizontalSpeed: Float;
    let isInSuperheroFall: Bool;
    let landingAnimFeature: ref<AnimFeature_Landing>;
    let landingType: LandingType;
    let maxAllowedDistanceToGround: Float;
    let playerVelocity: Vector4;
    let regularLandingFallingSpeed: Float;
    let safeLandingFallingSpeed: Float;
    let verticalSpeed: Float;
    let veryHardLandingFallingSpeed: Float;
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if this.IsTouchingGround(scriptInterface) {
      this.ResetFallingParameters(stateContext);
      return;
    };
    verticalSpeed = this.GetVerticalSpeed(scriptInterface);
    if this.m_updateInputToggles && verticalSpeed < this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("minFallHeightToConsiderInputToggles", 0.00)) {
      this.UpdateInputToggles(stateContext, scriptInterface);
    };
    if scriptInterface.IsActionJustPressed(n"Jump") {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
      return;
    };
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BerserkPlayerBuff") && verticalSpeed < this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("minFallHeightToEnterSuperheroFall", 0.00)) {
      stateContext.SetTemporaryBoolParameter(n"requestSuperheroLandActivation", true, true);
    };
    regularLandingFallingSpeed = stateContext.GetFloatParameter(n"RegularLandingFallingSpeed", true);
    safeLandingFallingSpeed = stateContext.GetFloatParameter(n"SafeLandingFallingSpeed", true);
    hardLandingFallingSpeed = stateContext.GetFloatParameter(n"HardLandingFallingSpeed", true);
    veryHardLandingFallingSpeed = stateContext.GetFloatParameter(n"VeryHardLandingFallingSpeed", true);
    deathLandingFallingSpeed = stateContext.GetFloatParameter(n"DeathLandingFallingSpeed", true);
    isInSuperheroFall = stateContext.IsStateActive(n"Locomotion", n"superheroFall");
    maxAllowedDistanceToGround = this.GetStaticFloatParameterDefault("maxDistToGroundFromSuperheroFall", 20.00);
    if isInSuperheroFall && !this.m_maxSuperheroFallHeight {
      this.StartEffect(scriptInterface, n"falling");
      this.PlaySound(n"lcm_falling_wind_loop", scriptInterface);
      if DefaultTransition.GetDistanceToGround(scriptInterface) >= maxAllowedDistanceToGround {
        this.m_maxSuperheroFallHeight = true;
        return;
      };
      landingType = LandingType.Superhero;
    } else {
      if verticalSpeed <= deathLandingFallingSpeed && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap) {
        landingType = LandingType.Death;
        this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.DeathFall));
      } else {
        if verticalSpeed <= veryHardLandingFallingSpeed && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MeleeLeap) {
          landingType = LandingType.VeryHard;
          this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.VeryFastFall));
        } else {
          if verticalSpeed <= hardLandingFallingSpeed {
            landingType = LandingType.Hard;
            if this.GetLandingType(stateContext) != EnumInt(LandingType.Hard) {
              this.StartEffect(scriptInterface, n"falling");
            };
            this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.FastFall));
          } else {
            if verticalSpeed <= safeLandingFallingSpeed {
              landingType = LandingType.Regular;
              this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.RegularFall));
              playerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
              horizontalSpeed = Vector4.Length2D(playerVelocity);
              if horizontalSpeed <= this.GetStaticFloatParameterDefault("maxHorizontalSpeedToAerialTakedown", 0.00) {
                this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Fall, EnumInt(gamePSMFallStates.SafeFall));
              };
            } else {
              if verticalSpeed <= regularLandingFallingSpeed {
                if this.GetLandingType(stateContext) != EnumInt(LandingType.Regular) {
                  this.PlaySound(n"lcm_falling_wind_loop", scriptInterface);
                };
                landingType = LandingType.Regular;
              } else {
                landingType = LandingType.Off;
              };
            };
          };
        };
      };
    };
    stateContext.SetPermanentIntParameter(n"LandingType", EnumInt(landingType), true);
    stateContext.SetPermanentFloatParameter(n"ImpactSpeed", verticalSpeed, true);
    stateContext.SetPermanentFloatParameter(n"InAirDuration", this.GetInStateTime(), true);
    landingAnimFeature = new AnimFeature_Landing();
    landingAnimFeature.impactSpeed = verticalSpeed;
    landingAnimFeature.type = EnumInt(landingType);
    scriptInterface.SetAnimationParameterFeature(n"Landing", landingAnimFeature);
    this.SetAudioParameter(n"RTPC_Vertical_Velocity", verticalSpeed, scriptInterface);
    this.SetAudioParameter(n"RTPC_Landing_Type", Cast(EnumInt(landingType)), scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.StopEffect(scriptInterface, n"falling");
    this.PlaySound(n"lcm_falling_wind_loop_end", scriptInterface);
    scriptInterface.GetTargetingSystem().SetIsMovingFast(scriptInterface.owner, false);
  }

  protected final const func GetLandingType(const stateContext: ref<StateContext>) -> Int32 {
    return stateContext.GetIntParameter(n"LandingType", true);
  }
}

public class FallDecisions extends LocomotionAirDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let shouldFall: Bool = this.ShouldFall(stateContext, scriptInterface);
    if shouldFall {
      scriptInterface.GetAudioSystem().NotifyGameTone(n"StartFalling");
    };
    return shouldFall;
  }
}

public class FallEvents extends LocomotionAirEvents {

  public final func OnEnterFromDodgeAir(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentBoolParameter(n"enteredFallFromAirDodge", true, true);
    this.OnEnter(stateContext, scriptInterface);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.PlaySound(n"lcm_falling_wind_loop", scriptInterface);
    scriptInterface.PushAnimationEvent(n"Fall");
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Fall);
  }
}

public class UnsecureFootingFallDecisions extends FallDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let linearVelocity: Vector4;
    let secureFootingResult: SecureFootingResult;
    if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
      return false;
    };
    secureFootingResult = scriptInterface.HasSecureFooting();
    linearVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
    return Equals(secureFootingResult.type, moveSecureFootingFailureType.Edge) && linearVelocity.Z < this.GetStaticFloatParameterDefault("minVerticalVelocityToEnter", -0.30);
  }
}

public class UnsecureFootingFallEvents extends FallEvents {

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class AirThrustersDecisions extends LocomotionAirDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let autoActivationNearGround: Bool;
    let minInputHoldTime: Float;
    let shouldFall: Bool = this.ShouldFall(stateContext, scriptInterface);
    if shouldFall {
      scriptInterface.GetAudioSystem().NotifyGameTone(n"StartFalling");
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasAirThrusters) && !this.GetStaticBoolParameterDefault("debug_Enable_Air_Thrusters", false) {
      return false;
    };
    minInputHoldTime = this.GetStaticFloatParameterDefault("minInputHoldTime", 0.15);
    if scriptInterface.GetActionValue(n"Jump") > 0.00 && scriptInterface.GetActionStateTime(n"Jump") > minInputHoldTime {
      return DefaultTransition.GetDistanceToGround(scriptInterface) >= this.GetStaticFloatParameterDefault("minDistanceToGround", 0.00);
    };
    autoActivationNearGround = this.GetStaticBoolParameterDefault("autoActivationAboutToHitGround", true);
    if autoActivationNearGround && this.IsFallHeightAcceptable(stateContext, scriptInterface) {
      return DefaultTransition.GetDistanceToGround(scriptInterface) <= this.GetStaticFloatParameterDefault("autoActivationDistanceToGround", 0.00);
    };
    return false;
  }

  protected final const func IsFallHeightAcceptable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let acceptableFallingSpeed: Float = this.GetFallingSpeedBasedOnHeight(scriptInterface, this.GetStaticFloatParameterDefault("minFallHeight", 3.00));
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    if verticalSpeed <= acceptableFallingSpeed {
      return true;
    };
    return false;
  }

  protected final const func ToFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.HasStatFlag(gamedataStatType.HasAirThrusters) {
      return true;
    };
    if this.GetStaticBoolParameterDefault("autoTransitionToFall", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.00) {
      return true;
    };
    if !this.GetStaticBoolParameterDefault("autoTransitionToFall", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.00) && (scriptInterface.IsActionJustTapped(n"ToggleCrouch") || scriptInterface.IsActionJustPressed(n"Crouch")) {
      return true;
    };
    if this.GetStaticBoolParameterDefault("allowCancelingWithCrouchAction", true) && scriptInterface.IsActionJustTapped(n"ToggleCrouch") || scriptInterface.IsActionJustPressed(n"Crouch") {
      return true;
    };
    if DefaultTransition.GetDistanceToGround(scriptInterface) <= this.GetStaticFloatParameterDefault("minDistanceToGround", 0.00) {
      return true;
    };
    return false;
  }

  protected final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsTouchingGround(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func ToDoubleJump(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.HasStatFlag(gamedataStatType.HasDoubleJump) {
      return false;
    };
    if stateContext.GetIntParameter(n"currentNumberOfJumps", true) >= 2 {
      return false;
    };
    if stateContext.GetConditionBool(n"JumpPressed") || scriptInterface.IsActionJustPressed(n"Jump") {
      return true;
    };
    return false;
  }
}

public class AirThrustersEvents extends LocomotionAirEvents {

  protected func SendAnimFeatureDataToGraph(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: Int32) -> Void {
    let animFeature: ref<AnimFeature_AirThrusterData> = new AnimFeature_AirThrusterData();
    animFeature.state = state;
    scriptInterface.SetAnimationParameterFeature(n"AirThrusterData", animFeature);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SendAnimFeatureDataToGraph(stateContext, scriptInterface, 1);
    scriptInterface.SetAnimationParameterFloat(n"crouch", 0.00);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    this.StopEffect(scriptInterface, n"falling");
    this.PlaySound(n"q115_thruster_start", scriptInterface);
    this.PlayEffectOnItem(scriptInterface, n"thrusters");
    this.SetUpwardsThrustStats(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.AirThrusters);
    DefaultTransition.PlayRumbleLoop(scriptInterface, "light");
  }

  private final func GetActiveFeetAreaItem(scriptInterface: ref<StateGameScriptInterface>) -> ref<ItemObject> {
    let es: ref<EquipmentSystem> = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
    let feetItem: ref<ItemObject> = es.GetActiveWeaponObject(scriptInterface.executionOwner, gamedataEquipmentArea.Feet);
    return feetItem;
  }

  private final func PlayEffectOnItem(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent>;
    if IsDefined(this.GetActiveFeetAreaItem(scriptInterface)) {
      spawnEffectEvent = new entSpawnEffectEvent();
      spawnEffectEvent.effectName = effectName;
      this.GetActiveFeetAreaItem(scriptInterface).GetOwner().QueueEvent(spawnEffectEvent);
    };
  }

  protected final func StopEffectOnItem(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    let killEffectEvent: ref<entKillEffectEvent>;
    if IsDefined(this.GetActiveFeetAreaItem(scriptInterface)) {
      killEffectEvent = new entKillEffectEvent();
      killEffectEvent.effectName = effectName;
      this.GetActiveFeetAreaItem(scriptInterface).GetOwner().QueueEvent(killEffectEvent);
    };
  }

  private final func SetUpwardsThrustStats(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let locomotionParameters: ref<LocomotionParameters> = new LocomotionParameters();
    this.SetModifierGroupForState(scriptInterface);
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    locomotionParameters.SetUpwardsGravity(this.GetStaticFloatParameterDefault("upwardsGravity", -16.00));
    locomotionParameters.SetDownwardsGravity(this.GetStaticFloatParameterDefault("downwardsGravity", -4.00));
    locomotionParameters.SetDoJump(true);
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SendAnimFeatureDataToGraph(stateContext, scriptInterface, 0);
    this.PlaySound(n"q115_thruster_stop", scriptInterface);
    this.StopEffectOnItem(scriptInterface, n"thrusters");
    DefaultTransition.StopRumbleLoop(scriptInterface, "light");
  }
}

public class AirHoverDecisions extends LocomotionAirDecisions {

  private let m_executionOwner: wref<GameObject>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_hasStatusEffect: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_executionOwner = scriptInterface.executionOwner;
    this.UpdateHasStatusEffect();
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = null;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if !this.m_hasStatusEffect {
      this.m_hasStatusEffect = statusEffect.GetID() == t"BaseStatusEffect.BerserkPlayerBuff";
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if this.m_hasStatusEffect {
      if statusEffect.GetID() == t"BaseStatusEffect.BerserkPlayerBuff" {
        this.UpdateHasStatusEffect();
      };
    };
  }

  protected final func UpdateHasStatusEffect() -> Void {
    this.m_hasStatusEffect = StatusEffectSystem.ObjectHasStatusEffect(this.m_executionOwner, t"BaseStatusEffect.BerserkPlayerBuff");
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isInAcceptableAerialState: Bool;
    let shouldFall: Bool = this.ShouldFall(stateContext, scriptInterface);
    if shouldFall {
      scriptInterface.GetAudioSystem().NotifyGameTone(n"StartFalling");
    };
    if !this.m_hasStatusEffect {
      return false;
    };
    if DefaultTransition.IsHeavyWeaponEquipped(scriptInterface) {
      return false;
    };
    isInAcceptableAerialState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Jump);
    if stateContext.GetBoolParameter(n"requestSuperheroLandActivation") && isInAcceptableAerialState {
      if this.IsDistanceToGroundAcceptable(stateContext, scriptInterface) && this.IsFallSpeedAcceptable(stateContext, scriptInterface) {
        return true;
      };
    };
    return false;
  }

  protected final const func IsDistanceToGroundAcceptable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if DefaultTransition.GetDistanceToGround(scriptInterface) <= this.GetStaticFloatParameterDefault("minDistanceToGround", 2.00) {
      return false;
    };
    return true;
  }

  protected final const func IsFallSpeedAcceptable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    let playerFallingTooFast: Float = stateContext.GetFloatParameter(n"VeryHardLandingFallingSpeed", true);
    if verticalSpeed <= playerFallingTooFast {
      return false;
    };
    return true;
  }

  protected final const func ToSuperheroFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.GetStaticBoolParameterDefault("autoTransitionToSuperheroFall", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("maxAirHoverTime", 0.00) {
      return true;
    };
    if !this.GetStaticBoolParameterDefault("autoTransitionToSuperheroFall", true) && this.GetInStateTime() >= this.GetStaticFloatParameterDefault("maxAirHoverTime", 0.00) && (scriptInterface.IsActionJustTapped(n"ToggleCrouch") || scriptInterface.IsActionJustPressed(n"Crouch")) {
      return true;
    };
    return false;
  }
}

public class AirHoverEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let verticalSpeed: Float;
    this.OnEnter(stateContext, scriptInterface);
    verticalSpeed = this.GetVerticalSpeed(scriptInterface);
    scriptInterface.PushAnimationEvent(n"AirHover");
    this.PlaySound(n"lcm_wallrun_out", scriptInterface);
    this.AddUpwardsImpulse(stateContext, scriptInterface, verticalSpeed);
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", true, true);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.AirHover);
  }

  private final func AddUpwardsImpulse(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, verticalSpeed: Float) -> Void {
    let verticalImpulse: Float;
    if verticalSpeed <= -0.50 {
      verticalImpulse = this.GetStaticFloatParameterDefault("verticalUpwardsImpulse", 4.00);
      this.AddVerticalImpulse(stateContext, verticalImpulse);
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class SuperheroFallEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.PlaySound(n"Player_double_jump", scriptInterface);
    scriptInterface.PushAnimationEvent(n"SuperHeroFall");
    this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("downwardsImpulseStrength", 0.00));
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.SuperheroFall);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
  }
}

public class JumpDecisions extends LocomotionAirDecisions {

  protected let m_jumpPressed: Bool;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Jump");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.m_jumpPressed = ListenerAction.GetValue(action) > 0.00;
    this.EnableOnEnterCondition(true);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let jumpPressedFlag: Bool = stateContext.GetConditionBool(n"JumpPressed");
    if !jumpPressedFlag && !this.m_jumpPressed {
      this.EnableOnEnterCondition(false);
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanJump) {
      return false;
    };
    if scriptInterface.HasStatFlag(gamedataStatType.HasChargeJump) || scriptInterface.HasStatFlag(gamedataStatType.HasAirHover) {
      if this.GetActionHoldTime(stateContext, scriptInterface, n"Jump") < 0.15 && stateContext.GetConditionFloat(n"InputHoldTime") < 0.20 && scriptInterface.IsActionJustReleased(n"Jump") {
        return true;
      };
    } else {
      if jumpPressedFlag || scriptInterface.IsActionJustPressed(n"Jump") {
        return true;
      };
    };
    return false;
  }
}

public class JumpEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    if !DefaultTransition.IsInRpgContext(scriptInterface) {
      stateContext.SetPermanentBoolParameter(n"VisionToggled", false, true);
    };
    scriptInterface.PushAnimationEvent(n"Jump");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Jump));
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Jump);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class DoubleJumpDecisions extends JumpDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let currentNumberOfJumps: Int32;
    let jumpPressedFlag: Bool = stateContext.GetConditionBool(n"JumpPressed");
    if !jumpPressedFlag && !this.m_jumpPressed {
      this.EnableOnEnterCondition(false);
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.HasDoubleJump) {
      return false;
    };
    if scriptInterface.HasStatFlag(gamedataStatType.HasChargeJump) || scriptInterface.HasStatFlag(gamedataStatType.HasAirHover) {
      return false;
    };
    if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
      return false;
    };
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) {
      return false;
    };
    currentNumberOfJumps = stateContext.GetIntParameter(n"currentNumberOfJumps", true);
    if currentNumberOfJumps >= this.GetStaticIntParameterDefault("numberOfMultiJumps", 1) {
      return false;
    };
    if jumpPressedFlag || scriptInterface.IsActionJustPressed(n"Jump") {
      return true;
    };
    return false;
  }
}

public class DoubleJumpEvents extends LocomotionAirEvents {

  public final func OnEnterFromAirThrusters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentIntParameter(n"currentNumberOfJumps", 1, true);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentNumberOfJumps: Int32;
    this.OnEnter(stateContext, scriptInterface);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    currentNumberOfJumps = stateContext.GetIntParameter(n"currentNumberOfJumps", true);
    currentNumberOfJumps += 1;
    stateContext.SetPermanentIntParameter(n"currentNumberOfJumps", currentNumberOfJumps, true);
    this.PlaySound(n"lcm_player_double_jump", scriptInterface);
    DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleOnEnter", "medium_fast"));
    scriptInterface.PushAnimationEvent(n"DoubleJump");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Jump));
    stateContext.SetConditionBoolParameter(n"JumpPressed", false, true);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.DoubleJump);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class ChargeJumpDecisions extends LocomotionAirDecisions {

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Jump");
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustReleased(action) {
      this.EnableOnEnterCondition(true);
    };
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    this.EnableOnEnterCondition(false);
    if stateContext.GetConditionFloat(n"InputHoldTime") > 0.15 && scriptInterface.IsActionJustReleased(n"Jump") && scriptInterface.HasStatFlag(gamedataStatType.HasChargeJump) {
      if scriptInterface.HasStatFlag(gamedataStatType.HasAirHover) {
        return false;
      };
      if this.IsPlayerInAnyMenu(scriptInterface) || this.IsRadialWheelOpen(scriptInterface) {
        return false;
      };
      if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
        return false;
      };
      if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) {
        return false;
      };
      return true;
    };
    return false;
  }
}

public class ChargeJumpEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let inputHoldTime: Float;
    this.OnEnter(stateContext, scriptInterface);
    inputHoldTime = stateContext.GetConditionFloat(n"InputHoldTime");
    scriptInterface.PushAnimationEvent(n"ChargeJump");
    this.PlaySound(n"lcm_player_double_jump", scriptInterface);
    DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleOnEnter", "medium_fast"));
    this.StartEffect(scriptInterface, n"charged_jump");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.PressureWave"));
    this.SpawnLandingFxGameEffect(t"Attacks.PressureWave", scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Jump));
    this.SetChargeJumpParameters(stateContext, scriptInterface, inputHoldTime);
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.ChargeJump);
  }

  private final func SetChargeJumpParameters(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, inputHoldTime: Float) -> Void {
    let downwardsGravity: Float;
    let nameSuffix: String;
    let upwardsGravity: Float;
    if inputHoldTime >= this.GetStaticFloatParameterDefault("minHoldTime", 0.10) && inputHoldTime <= this.GetStaticFloatParameterDefault("medChargeHoldTime", 0.20) {
      upwardsGravity = this.GetStaticFloatParameterDefault("upwardsGravityMinCharge", -16.00);
      downwardsGravity = this.GetStaticFloatParameterDefault("downwardsGravityMinCharge", -16.00);
      nameSuffix = "Low";
    } else {
      if inputHoldTime > this.GetStaticFloatParameterDefault("medChargeHoldTime", 0.20) && inputHoldTime <= this.GetStaticFloatParameterDefault("maxChargeHoldTime", 0.30) {
        upwardsGravity = this.GetStaticFloatParameterDefault("upwardsGravityMedCharge", -16.00);
        downwardsGravity = this.GetStaticFloatParameterDefault("downwardsGravityMedCharge", -16.00);
        nameSuffix = "Medium";
      } else {
        if inputHoldTime >= this.GetStaticFloatParameterDefault("maxChargeHoldTime", 0.30) {
          upwardsGravity = this.GetStaticFloatParameterDefault("upwardsGravityMaxCharge", -16.00);
          downwardsGravity = this.GetStaticFloatParameterDefault("downwardsGravityMaxCharge", -20.00);
          nameSuffix = "High";
          this.AddVerticalImpulse(stateContext, this.GetStaticFloatParameterDefault("verticalImpulse", 2.00));
        };
      };
    };
    this.UpdateChargeJumpStats(stateContext, scriptInterface, upwardsGravity, downwardsGravity, nameSuffix);
  }

  private final func UpdateChargeJumpStats(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, upwardsGravity: Float, downwardsGravity: Float, nameSuffix: String) -> Void {
    let locomotionParameters: ref<LocomotionParameters> = new LocomotionParameters();
    let statModifierTDBName: String = this.m_statModifierTDBNameDefault + nameSuffix;
    this.SetModifierGroupForState(scriptInterface, statModifierTDBName);
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    locomotionParameters.SetUpwardsGravity(upwardsGravity);
    locomotionParameters.SetDownwardsGravity(downwardsGravity);
    locomotionParameters.SetDoJump(true);
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
  }
}

public class HoverJumpDecisions extends LocomotionAirDecisions {

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Jump");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    this.EnableOnEnterCondition(ListenerAction.GetValue(action) > 0.00);
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if scriptInterface.IsActionJustHeld(n"Jump") {
      if !scriptInterface.HasStatFlag(gamedataStatType.HasAirHover) {
        return false;
      };
      if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
        return false;
      };
      if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) {
        return false;
      };
      return true;
    };
    return false;
  }
}

public class HoverJumpEvents extends LocomotionAirEvents {

  protected func SendHoverJumpStateToGraph(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: Int32) -> Void {
    let animFeature: ref<AnimFeature_HoverJumpData> = new AnimFeature_HoverJumpData();
    animFeature.state = state;
    scriptInterface.SetAnimationParameterFeature(n"HoverJumpData", animFeature);
  }

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SendHoverJumpStateToGraph(stateContext, scriptInterface, 1);
    this.PlaySound(n"lcm_player_double_jump", scriptInterface);
    DefaultTransition.PlayRumble(scriptInterface, this.GetStaticStringParameterDefault("rumbleOnEnter", "medium_fast"));
    this.StartEffect(scriptInterface, n"charged_jump");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.PressureWave"));
    this.SpawnLandingFxGameEffect(t"Attacks.PressureWave", scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Jump));
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.HoverJump);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HoverJumpPlayerBuff");
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    if !stateContext.GetBoolParameter(n"isAboutToLand", true) && verticalSpeed <= -1.00 && DefaultTransition.GetDistanceToGround(scriptInterface) <= 1.00 {
      this.SendHoverJumpStateToGraph(stateContext, scriptInterface, 2);
      stateContext.SetPermanentBoolParameter(n"isAboutToLand", true, true);
    };
    if this.CanHover(stateContext, scriptInterface) && scriptInterface.GetActionValue(n"CameraAim") == 0.00 && scriptInterface.GetActionValue(n"Jump") > 0.00 {
      this.AddUpwardsThrust(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("verticalImpulse", 4.00));
      if !stateContext.GetBoolParameter(n"isHovering", true) {
        stateContext.RemovePermanentBoolParameter(n"isStabilising");
        stateContext.SetPermanentBoolParameter(n"isHovering", true, true);
        this.UpdateHoverJumpStats(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("upwardsGravityOnThrust", -10.00), this.GetStaticFloatParameterDefault("downwardsGravityOnThrust", -5.00), "");
      };
    };
    if this.CanHover(stateContext, scriptInterface) && this.GetStaticBoolParameterDefault("stabilizeOnAim", false) && scriptInterface.GetActionValue(n"CameraAim") > 0.00 {
      if !stateContext.GetBoolParameter(n"isStabilising", true) {
        if verticalSpeed <= -0.50 {
          this.AddUpwardsThrust(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("verticalImpulseStabilize", 4.00));
        };
        stateContext.RemovePermanentBoolParameter(n"isHovering");
        stateContext.SetPermanentBoolParameter(n"isStabilising", true, true);
        this.UpdateHoverJumpStats(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("upwardsGravityOnStabilize", -10.00), this.GetStaticFloatParameterDefault("downwardsGravityOnStabilize", -3.00), "Thrust");
        this.PlaySound(n"lcm_wallrun_in", scriptInterface);
      };
    } else {
      this.UpdateHoverJumpStats(stateContext, scriptInterface, this.GetStaticFloatParameterDefault("upwardsGravity", -16.00), this.GetStaticFloatParameterDefault("downwardsGravity", -16.00), "");
    };
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  private final func CanHover(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HoverJumpPlayerBuff");
  }

  private final func UpdateHoverJumpStats(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, upwardsGravity: Float, downwardsGravity: Float, nameSuffix: String) -> Void {
    let locomotionParameters: ref<LocomotionParameters> = new LocomotionParameters();
    let statModifierTDBName: String = this.m_statModifierTDBNameDefault + nameSuffix;
    this.SetModifierGroupForState(scriptInterface, statModifierTDBName);
    this.GetStateDefaultLocomotionParameters(locomotionParameters);
    locomotionParameters.SetUpwardsGravity(upwardsGravity);
    locomotionParameters.SetDownwardsGravity(downwardsGravity);
    locomotionParameters.SetDoJump(true);
    stateContext.SetTemporaryScriptableParameter(n"locomotionParameters", locomotionParameters, true);
  }

  private final func AddUpwardsThrust(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, verticalImpulse: Float) -> Void {
    if verticalImpulse > 0.00 {
      this.AddVerticalImpulse(stateContext, verticalImpulse);
    };
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.CleanUpOnExit(stateContext, scriptInterface);
  }

  private final func CleanUpOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendHoverJumpStateToGraph(stateContext, scriptInterface, 0);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.Default));
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HoverJumpPlayerBuff");
    this.UpdateHoverJumpStats(stateContext, scriptInterface, -16.00, -16.00, "");
    stateContext.RemovePermanentBoolParameter(n"isStabilising");
    stateContext.RemovePermanentBoolParameter(n"isHovering");
    stateContext.RemovePermanentBoolParameter(n"isAboutToLand");
  }
}

public class DodgeAirDecisions extends LocomotionAirDecisions {

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    scriptInterface.executionOwner.RegisterInputListener(this, n"Dodge");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeDirection");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeForward");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeRight");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeLeft");
    scriptInterface.executionOwner.RegisterInputListener(this, n"DodgeBack");
    this.EnableOnEnterCondition(false);
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    scriptInterface.executionOwner.UnregisterInputListener(this);
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if ListenerAction.IsButtonJustPressed(action) {
      this.EnableOnEnterCondition(true);
    };
  }

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let currentNumberOfAirDodges: Int32;
    this.EnableOnEnterCondition(false);
    if !scriptInterface.HasStatFlag(gamedataStatType.HasDodgeAir) {
      return false;
    };
    if !scriptInterface.HasStatFlag(gamedataStatType.CanAimWhileDodging) && this.IsInUpperBodyState(stateContext, n"aimingState") {
      return false;
    };
    if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
      return false;
    };
    currentNumberOfAirDodges = stateContext.GetIntParameter(n"currentNumberOfAirDodges", true);
    if currentNumberOfAirDodges >= this.GetStaticIntParameterDefault("numberOfAirDodges", 1) {
      return false;
    };
    if this.WantsToDodge(stateContext, scriptInterface) {
      return true;
    };
    return false;
  }

  protected const func ToFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let isKerenzikovEnd: Bool;
    let isKerenzikovStateActive: Bool = Equals(stateContext.GetStateMachineCurrentState(n"TimeDilation"), n"kerenzikov");
    if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirBuff") {
      return !isKerenzikovStateActive;
    };
    isKerenzikovEnd = isKerenzikovStateActive && !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.KerenzikovPlayerBuff");
    if isKerenzikovEnd {
      return true;
    };
    return false;
  }
}

public class DodgeAirEvents extends LocomotionAirEvents {

  protected func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentNumberOfAirDodges: Int32;
    this.OnEnter(stateContext, scriptInterface);
    currentNumberOfAirDodges = stateContext.GetIntParameter(n"currentNumberOfAirDodges", true);
    currentNumberOfAirDodges += 1;
    stateContext.SetPermanentIntParameter(n"currentNumberOfAirDodges", currentNumberOfAirDodges, true);
    this.Dodge(stateContext, scriptInterface);
    this.PlayRumbleBasedOnDodgeDirection(stateContext, scriptInterface);
    scriptInterface.PushAnimationEvent(n"Dodge");
    stateContext.SetConditionBoolParameter(n"SprintToggled", false, true);
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirBuff");
    this.ConsumeStaminaBasedOnLocomotionState(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Locomotion, EnumInt(gamePSMLocomotionStates.DodgeAir));
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if scriptInterface.IsActionJustPressed(n"Jump") {
      stateContext.SetConditionBoolParameter(n"JumpPressed", true, true);
    };
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirBuff");
  }

  protected final func Dodge(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impulseValue: Float = this.GetStaticFloatParameterDefault("impulse", 10.00);
    let dodgeHeading: Float = stateContext.GetConditionFloat(n"DodgeDirection");
    let impulse: Vector4 = Vector4.FromHeading(AngleNormalize180(scriptInterface.executionOwner.GetWorldYaw() + dodgeHeading)) * impulseValue;
    this.AddImpulse(stateContext, impulse);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.DodgeAir);
  }
}

public abstract class AbstractLandDecisions extends LocomotionGroundDecisions {

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }
}

public abstract class AbstractLandEvents extends LocomotionGroundEvents {

  @default(AbstractLandEvents, false)
  public let m_blockLandingStimBroadcasting: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let bottomCollisionFound: Bool;
    let bottomCollisionNormal: Vector4;
    let capsuleRadius: Float;
    let collisionIndex: Int32;
    let collisionReport: array<ControllerHit>;
    let fallEvent: ref<PSMFall>;
    let hit: ControllerHit;
    let impactSpeed: Float;
    let playerPosition: Vector4;
    let playerPositionCentreOfSphere: Vector4;
    let touchNormal: Vector4;
    let up: Vector4 = DefaultTransition.GetUpVector();
    this.OnEnter(stateContext, scriptInterface);
    impactSpeed = AbsF(stateContext.GetFloatParameter(n"ImpactSpeed", true));
    this.SetAudioParameter(n"RTPC_Landing_Type", 0.00, scriptInterface);
    fallEvent = new PSMFall();
    fallEvent.SetSpeed(impactSpeed);
    scriptInterface.owner.QueueEvent(fallEvent);
    scriptInterface.PushAnimationEvent(n"Land");
    capsuleRadius = FromVariant(scriptInterface.GetStateVectorParameter(physicsStateValue.Radius));
    playerPosition = DefaultTransition.GetPlayerPosition(scriptInterface);
    collisionReport = scriptInterface.GetCollisionReport();
    playerPositionCentreOfSphere = playerPosition + up * capsuleRadius;
    bottomCollisionFound = false;
    collisionIndex = 0;
    while collisionIndex < ArraySize(collisionReport) && !bottomCollisionFound {
      hit = collisionReport[collisionIndex];
      touchNormal = Vector4.Normalize(playerPositionCentreOfSphere - hit.worldPos);
      if touchNormal.Z > 0.00 && bottomCollisionNormal.Z < touchNormal.Z {
        bottomCollisionNormal = touchNormal;
        if bottomCollisionNormal.Z < 1.00 {
          bottomCollisionFound = true;
        };
      };
      collisionIndex += 1;
    };
    this.ResetFallingParameters(stateContext);
  }

  protected final func BroadcastLandingStim(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, stimType: gamedataStimType) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let impactSpeed: StateResultFloat;
    let speedThresholdToSendStim: Float;
    let broadcastLandingStim: Bool = scriptInterface.GetStatsSystem().GetStatValue(Cast(scriptInterface.ownerEntityID), gamedataStatType.CanLandSilently) < 1.00;
    if !broadcastLandingStim || this.m_blockLandingStimBroadcasting {
      this.m_blockLandingStimBroadcasting = false;
      return;
    };
    if LocomotionGroundDecisions.CheckCrouchEnterCondition(stateContext, scriptInterface) && Equals(stimType, gamedataStimType.LandingRegular) {
      return;
    };
    impactSpeed = stateContext.GetPermanentFloatParameter(n"ImpactSpeed");
    speedThresholdToSendStim = this.GetFallingSpeedBasedOnHeight(scriptInterface, 1.20);
    if impactSpeed.value < speedThresholdToSendStim {
      broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, stimType);
      };
    };
  }

  protected final func EvaluatePlayingLandingVFX(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impactSpeed: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ImpactSpeed");
    let minFallSpeed: Float = this.GetFallingSpeedBasedOnHeight(scriptInterface, 2.00);
    if impactSpeed.value < minFallSpeed {
      this.StartEffect(scriptInterface, n"landing_regular");
    };
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnExit(stateContext, scriptInterface);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.Default));
  }
}

public abstract class FailedLandingAbstractDecisions extends AbstractLandDecisions {

  public final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("duration", 2.50);
  }
}

public abstract class FailedLandingAbstractEvents extends AbstractLandEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
  }
}

public class RegularLandEvents extends AbstractLandEvents {

  public final func OnEnterFromLadderCrouch(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_blockLandingStimBroadcasting = true;
    this.OnEnter(stateContext, scriptInterface);
  }

  public final func OnEnterFromUnsecureFootingFall(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetConditionBoolParameter(n"blockEnteringSlide", true, true);
    this.OnEnter(stateContext, scriptInterface);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    GameObject.PlayVoiceOver(scriptInterface.owner, n"regularLanding", n"Scripts:RegularLandEvents");
    this.EvaluateTransitioningToSlideAfterLanding(stateContext, scriptInterface);
    this.ShouldTriggerDestruction(stateContext, scriptInterface);
    this.EvaluatePlayingLandingVFX(stateContext, scriptInterface);
    this.BroadcastLandingStim(stateContext, scriptInterface, gamedataStimType.LandingRegular);
    this.OnEnter(stateContext, scriptInterface);
    this.TryPlayRumble(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.RegularLand);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.RegularLand));
  }

  protected final func EvaluateTransitioningToSlideAfterLanding(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let currentSpeed: Float;
    let inAirTime: StateResultFloat;
    let velocity: Vector4;
    if !stateContext.GetConditionBool(n"CrouchToggled") {
      return;
    };
    inAirTime = stateContext.GetPermanentFloatParameter(n"InAirDuration");
    velocity = DefaultTransition.GetLinearVelocity(scriptInterface);
    currentSpeed = Vector4.Length2D(velocity);
    if inAirTime.valid && inAirTime.value > 0.70 && currentSpeed < 5.00 || inAirTime.valid && inAirTime.value < 0.50 {
      stateContext.SetConditionBoolParameter(n"blockEnteringSlide", true, true);
    };
  }

  protected final func TryPlayRumble(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impactSpeed: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ImpactSpeed");
    let inAirTime: StateResultFloat = stateContext.GetPermanentFloatParameter(n"InAirDuration");
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsControllingDevice) {
      return;
    };
    if stateContext.GetConditionBool(n"CrouchToggled") && impactSpeed.valid && impactSpeed.value > this.GetFallingSpeedBasedOnHeight(scriptInterface, 1.20) {
      return;
    };
    if impactSpeed.valid && impactSpeed.value < this.GetFallingSpeedBasedOnHeight(scriptInterface, 0.66) {
      DefaultTransition.PlayRumble(scriptInterface, "light_pulse");
    } else {
      if inAirTime.valid && inAirTime.value > 0.33 {
        DefaultTransition.PlayRumble(scriptInterface, "light_pulse");
      };
    };
  }

  protected final func ShouldTriggerDestruction(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impactSpeed: StateResultFloat = stateContext.GetPermanentFloatParameter(n"ImpactSpeed");
    if impactSpeed.value < this.GetFallingSpeedBasedOnHeight(scriptInterface, 2.50) {
      this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.PressureWave"));
      this.SpawnLandingFxGameEffect(t"Attacks.PressureWave", scriptInterface);
    };
  }
}

public class HardLandEvents extends FailedLandingAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.StartEffect(scriptInterface, n"landing_hard");
    GameObject.PlayVoiceOver(scriptInterface.owner, n"hardLanding", n"Scripts:HardLandEvents");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.HardLanding"));
    this.SpawnLandingFxGameEffect(t"Attacks.HardLanding", scriptInterface);
    this.BroadcastLandingStim(stateContext, scriptInterface, gamedataStimType.LandingHard);
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.HardLand);
    DefaultTransition.PlayRumble(scriptInterface, "medium_pulse");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.HardLand));
  }
}

public class VeryHardLandEvents extends FailedLandingAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.StartEffect(scriptInterface, n"landing_very_hard");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.VeryHardLanding"));
    this.SpawnLandingFxGameEffect(t"Attacks.VeryHardLanding", scriptInterface);
    GameObject.PlayVoiceOver(scriptInterface.owner, n"veryhardLanding", n"Scripts:VeryHardLandEvents");
    this.BroadcastLandingStim(stateContext, scriptInterface, gamedataStimType.LandingVeryHard);
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.VeryHardLand);
    DefaultTransition.PlayRumble(scriptInterface, "heavy_fast");
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.VeryHardLand));
  }
}

public class DeathLandEvents extends FailedLandingAbstractEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.StartEffect(scriptInterface, n"landing_death");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.DeathLanding"));
    this.SpawnLandingFxGameEffect(t"Attacks.DeathLanding", scriptInterface);
    GameObject.PlayVoiceOver(scriptInterface.owner, n"veryhardLanding", n"Scripts:DeathLandEvents");
    this.BroadcastLandingStim(stateContext, scriptInterface, gamedataStimType.LandingVeryHard);
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.DeathLand);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.DeathLand));
  }
}

public class SuperheroLandDecisions extends AbstractLandDecisions {

  public final const func ToSuperheroLandRecovery(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.77);
  }
}

public class SuperheroLandEvents extends AbstractLandEvents {

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    this.OnEnter(stateContext, scriptInterface);
    scriptInterface.PushAnimationEvent(n"SuperheroLand");
    this.PlaySound(n"lcm_wallrun_in", scriptInterface);
    this.StartEffect(scriptInterface, n"stagger_effect");
    stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    DefaultTransition.PlayRumble(scriptInterface, "heavy_fast");
    this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.SuperheroLanding"));
    this.SpawnLandingFxGameEffect(t"Attacks.SuperheroLanding", scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.SuperheroLand);
    broadcaster = scriptInterface.executionOwner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(scriptInterface.executionOwner, gamedataStimType.LandingVeryHard);
    };
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.SuperheroLand));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.Default));
  }
}

public class SuperheroLandRecoveryDecisions extends AbstractLandDecisions {

  public final const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.GetInStateTime() >= this.GetStaticFloatParameterDefault("stateDuration", 0.40);
  }
}

public class SuperheroLandRecoveryEvents extends AbstractLandEvents {

  protected func SendAnimFeature(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: Int32) -> Void {
    let animFeature: ref<AnimFeature_SuperheroLand> = new AnimFeature_SuperheroLand();
    animFeature.state = state;
    scriptInterface.SetAnimationParameterFeature(n"SuperheroLand", animFeature);
  }

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.SuperheroLandRecovery);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.SuperheroLandRecovery));
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SendAnimFeature(stateContext, scriptInterface, 0);
    stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", false, true);
    this.SetBlackboardIntVariable(scriptInterface, GetAllBlackboardDefs().PlayerStateMachine.Landing, EnumInt(gamePSMLandingState.Default));
  }
}

public abstract class WallCollisionHelpers extends IScriptable {

  public final static func GetWallCollision(const scriptInterface: ref<StateGameScriptInterface>, playerPosition: Vector4, up: Vector4, capsuleRadius: Float, out wallCollision: ControllerHit) -> Bool {
    let hit: ControllerHit;
    let touchDirection: Vector4;
    let collisionReport: array<ControllerHit> = scriptInterface.GetCollisionReport();
    let playerPositionCentreOfSphere: Vector4 = playerPosition + up * capsuleRadius;
    let sideCollisionFound: Bool = false;
    let collisionIndex: Int32 = 0;
    while collisionIndex < ArraySize(collisionReport) && !sideCollisionFound {
      hit = collisionReport[collisionIndex];
      touchDirection = Vector4.Normalize(hit.worldPos - playerPositionCentreOfSphere);
      if touchDirection.Z >= 0.00 {
        wallCollision = hit;
        return true;
      };
      collisionIndex += 1;
    };
    return false;
  }
}

public class StatusEffectDecisions extends LocomotionGroundDecisions {

  private let m_executionOwner: wref<GameObject>;

  private let m_statusEffectListener: ref<DefaultTransitionStatusEffectListener>;

  private let m_statusEffectEnumName: String;

  protected func OnAttach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnAttach(stateContext, scriptInterface);
    this.m_statusEffectEnumName = this.GetStaticStringParameterDefault("statusEffectEnumName", "");
    this.m_statusEffectListener = new DefaultTransitionStatusEffectListener();
    this.m_statusEffectListener.m_transitionOwner = this;
    scriptInterface.GetStatusEffectSystem().RegisterListener(scriptInterface.owner.GetEntityID(), this.m_statusEffectListener);
    this.m_executionOwner = scriptInterface.executionOwner;
    this.EnableOnEnterCondition(StatusEffectSystem.ObjectHasStatusEffectOfTypeName(this.m_executionOwner, this.m_statusEffectEnumName));
  }

  protected final func OnDetach(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.m_statusEffectListener = null;
  }

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    if Equals(this.m_statusEffectEnumName, statusEffect.StatusEffectType().EnumName()) {
      this.EnableOnEnterCondition(true);
    };
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    if Equals(this.m_statusEffectEnumName, statusEffect.StatusEffectType().EnumName()) {
      this.EnableOnEnterCondition(StatusEffectSystem.ObjectHasStatusEffectOfTypeName(this.m_executionOwner, this.m_statusEffectEnumName));
    };
  }

  protected const func InternalEnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.InternalEnterCondition(stateContext, scriptInterface);
  }

  public const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let statusEffectRecord: wref<StatusEffect_Record> = stateContext.GetTemporaryScriptableParameter(StatusEffectHelper.GetAppliedStatusEffectKey()) as StatusEffect_Record;
    if IsDefined(statusEffectRecord) {
      return Equals(this.m_statusEffectEnumName, statusEffectRecord.StatusEffectType().EnumName());
    };
    return false;
  }

  protected const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.HasMovementAffiliatedStatusEffect(stateContext, scriptInterface);
  }

  protected const func ToRegularFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !this.HasMovementAffiliatedStatusEffect(stateContext, scriptInterface) && !this.IsTouchingGround(scriptInterface);
  }

  private final const func HasMovementAffiliatedStatusEffect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let statusEffectRecord: wref<StatusEffect_Record> = stateContext.GetConditionScriptableParameter(n"AffectMovementStatusEffectRecord") as StatusEffect_Record;
    return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.owner, statusEffectRecord.GetID());
  }
}

public class StatusEffectEvents extends LocomotionGroundEvents {

  public let m_statusEffectRecord: wref<StatusEffect_Record>;

  public let m_playerStatusEffectRecordData: wref<StatusEffectPlayerData_Record>;

  public let m_animFeatureStatusEffect: ref<AnimFeature_StatusEffect>;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnEnter(stateContext, scriptInterface);
    this.m_statusEffectRecord = this.GetStatusEffectRecord(stateContext, scriptInterface);
    this.m_playerStatusEffectRecordData = this.GetStatusEffectPlayerData(scriptInterface, stateContext);
    stateContext.SetConditionScriptableParameter(n"AffectMovementStatusEffectRecord", this.m_statusEffectRecord, true);
    stateContext.SetConditionScriptableParameter(n"PlayerStatusEffectRecordData", this.m_playerStatusEffectRecordData, true);
    if this.ShouldForceUnequipWeapon() {
      stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", true, true);
    };
    this.ProcessStatusEffectBasedOnType(scriptInterface, stateContext, this.GetStatusEffectType(scriptInterface, stateContext));
    if this.ShouldRotateToSource() {
      this.RotateToKnockdownSource(stateContext, scriptInterface);
    };
  }

  protected final func RotateToKnockdownSource(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let adjustRequest: ref<AdjustTransformWithDurations>;
    let direction: Vector4 = this.GetStatusEffectHitDirection(scriptInterface);
    if Vector4.IsZero(direction) {
      return;
    };
    adjustRequest = new AdjustTransformWithDurations();
    adjustRequest.SetPosition(new Vector4(0.00, 0.00, 0.00, 0.00));
    adjustRequest.SetSlideDuration(-1.00);
    adjustRequest.SetRotation(Quaternion.BuildFromDirectionVector(-direction, new Vector4(0.00, 0.00, 1.00, 0.00)));
    adjustRequest.SetRotationDuration(0.50);
    stateContext.SetTemporaryScriptableParameter(n"adjustTransform", adjustRequest, true);
  }

  private final func ProcessStatusEffectBasedOnType(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, type: gamedataStatusEffectType) -> Void {
    if !IsDefined(this.m_statusEffectRecord) {
      return;
    };
    if !this.ShouldUseCustomAdditives(scriptInterface, type) {
      if Equals(type, gamedataStatusEffectType.Stunned) {
        scriptInterface.PushAnimationEvent(n"StaggerHit");
        if !StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.Parry") {
          stateContext.SetPermanentBoolParameter(n"InterruptMelee", this.m_playerStatusEffectRecordData.ForceSafeWeapon(), true);
        };
      };
      this.SendCameraShakeDataToGraph(scriptInterface, stateContext, this.GetCameraShakeStrength());
      this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.Start);
    };
    this.ApplyCounterForce(scriptInterface, stateContext, this.GetImpulseDistance(), this.GetScaleImpulseDistance());
  }

  private final func SendCameraShakeDataToGraph(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, camShakeStrength: Float) -> Void {
    let animFeatureHitReaction: ref<AnimFeature_PlayerHitReactionData> = new AnimFeature_PlayerHitReactionData();
    animFeatureHitReaction.hitStrength = camShakeStrength;
    scriptInterface.SetAnimationParameterFeature(n"HitReactionData", animFeatureHitReaction);
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
  }

  protected final const func GetTimeInStatusEffect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let timeInState: Float;
    let startTime: StateResultFloat = stateContext.GetPermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey());
    if !startTime.valid {
      return 0.00;
    };
    timeInState = EngineTime.ToFloat(GameInstance.GetTimeSystem(scriptInterface.owner.GetGame()).GetSimTime()) - startTime.value;
    return timeInState;
  }

  public func OnForcedExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.OnForcedExit(stateContext, scriptInterface);
    this.DefaultOnExit(stateContext, scriptInterface);
  }

  public func OnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.DefaultOnExit(stateContext, scriptInterface);
  }

  protected final func OnExitToFall(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.DefaultOnExit(stateContext, scriptInterface);
    scriptInterface.PushAnimationEvent(n"StraightToFall");
  }

  protected func CommonOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.RemoveStatusEffect(scriptInterface, stateContext);
    if this.ShouldForceUnequipWeapon() {
      stateContext.SetPermanentBoolParameter(n"forcedTemporaryUnequip", false, true);
    };
    stateContext.RemovePermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey());
  }

  protected final func DefaultOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if IsDefined(this.m_animFeatureStatusEffect) {
      this.m_animFeatureStatusEffect.Clear();
    };
    scriptInterface.SetAnimationParameterFeature(n"StatusEffect", this.m_animFeatureStatusEffect);
    if this.GetStaticBoolParameterDefault("forceExitToStand", false) {
      stateContext.SetConditionBoolParameter(n"CrouchToggled", false, true);
    };
    this.CommonOnExit(stateContext, scriptInterface);
  }

  protected func SendStatusEffectAnimDataToGraph(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: EKnockdownStates) -> Void {
    if !IsDefined(this.m_animFeatureStatusEffect) {
      this.m_animFeatureStatusEffect = new AnimFeature_StatusEffect();
    };
    stateContext.SetPermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey(), EngineTime.ToFloat(GameInstance.GetTimeSystem(scriptInterface.owner.GetGame()).GetSimTime()), true);
    StatusEffectHelper.PopulateStatusEffectAnimData(scriptInterface.owner, this.m_statusEffectRecord, state, this.GetStatusEffectHitDirection(scriptInterface), this.m_animFeatureStatusEffect);
    scriptInterface.SetAnimationParameterFeature(n"StatusEffect", this.m_animFeatureStatusEffect);
  }

  protected final func ApplyCounterForce(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, desiredDistance: Float, scaleDistance: Bool) -> Void {
    let direction: Vector4;
    let ev: ref<PSMImpulse>;
    let impulseDir: Vector4;
    let speed: Float;
    if desiredDistance <= 0.00 {
      return;
    };
    direction = this.GetStatusEffectHitDirection(scriptInterface);
    direction.Z = 0.00;
    if scaleDistance {
      desiredDistance *= Vector4.Length2D(direction);
    };
    if Vector4.IsZero(direction) {
      direction = scriptInterface.owner.GetWorldForward() * -1.00;
    } else {
      Vector4.Normalize2D(direction);
    };
    speed = this.GetSpeedBasedOnDistance(scriptInterface, desiredDistance);
    impulseDir = direction * speed;
    ev = new PSMImpulse();
    ev.id = n"impulse";
    ev.impulse = impulseDir;
    scriptInterface.owner.QueueEvent(ev);
  }

  private final const func RemoveStatusEffect(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.owner, this.m_statusEffectRecord.GetID());
    stateContext.RemoveConditionScriptableParameter(n"PlayerStatusEffectRecordData");
  }

  private final const func GetStatusEffectType(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> gamedataStatusEffectType {
    return this.m_statusEffectRecord.StatusEffectType().Type();
  }

  protected final const func GetStatusEffectRemainingDuration(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> Float {
    return StatusEffectHelper.GetStatusEffectByID(scriptInterface.owner, this.m_statusEffectRecord.GetID()).GetRemainingDuration();
  }

  protected final const func GetStatusEffectHitDirection(const scriptInterface: ref<StateGameScriptInterface>) -> Vector4 {
    return StatusEffectHelper.GetStatusEffectByID(scriptInterface.owner, this.m_statusEffectRecord.GetID()).GetDirection();
  }

  protected final const func GetStartupAnimDuration() -> Float {
    return this.m_playerStatusEffectRecordData.StartupAnimDuration();
  }

  protected final const func ShouldRotateToSource() -> Bool {
    return this.m_playerStatusEffectRecordData.RotateToSource();
  }

  protected final const func GetAirRecoveryAnimDuration() -> Float {
    return this.m_playerStatusEffectRecordData.AirRecoveryAnimDuration();
  }

  protected final const func GetRecoveryAnimDuration() -> Float {
    return this.m_playerStatusEffectRecordData.RecoveryAnimDuration();
  }

  protected final const func GetLandAnimDuration() -> Float {
    return this.m_playerStatusEffectRecordData.LandAnimDuration();
  }

  private final const func GetImpulseDistance() -> Float {
    return this.m_playerStatusEffectRecordData.ImpulseDistance();
  }

  private final const func GetScaleImpulseDistance() -> Bool {
    return this.m_playerStatusEffectRecordData.ScaleImpulseDistance();
  }

  private final const func GetCameraShakeStrength() -> Float {
    return this.m_playerStatusEffectRecordData.CameraShakeStrength();
  }

  private final const func ShouldForceUnequipWeapon() -> Bool {
    return this.m_playerStatusEffectRecordData.ForceUnequipWeapon();
  }

  protected final const func ShouldUseCustomAdditives(const scriptInterface: ref<StateGameScriptInterface>, type: gamedataStatusEffectType) -> Bool {
    return Equals(type, gamedataStatusEffectType.Stunned) && StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"UseCustomAdditives");
  }
}

public class KnockdownDecisions extends StatusEffectDecisions {

  protected const func ToStand(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let canExit: StateResultBool = stateContext.GetTemporaryBoolParameter(StatusEffectHelper.GetCanExitKnockdownKey());
    if canExit.valid {
      return this.ToStand(stateContext, scriptInterface);
    };
    return false;
  }

  protected const func ToRegularFall(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let canExit: StateResultBool = stateContext.GetTemporaryBoolParameter(StatusEffectHelper.GetCanExitKnockdownKey());
    if canExit.valid {
      return this.ToRegularFall(stateContext, scriptInterface);
    };
    return false;
  }

  protected const func ToSecondaryKnockdown(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let canTriggerSecondaryKnockdown: StateResultBool = stateContext.GetPermanentBoolParameter(StatusEffectHelper.TriggerSecondaryKnockdownKey());
    if canTriggerSecondaryKnockdown.valid {
      return this.EnterCondition(stateContext, scriptInterface);
    };
    return false;
  }
}

public class KnockdownEvents extends StatusEffectEvents {

  public let m_cachedPlayerVelocity: Vector4;

  public let m_secondaryKnockdownDir: Vector4;

  public let m_secondaryKnockdownTimer: Float;

  public let m_playedImpactAnim: Bool;

  public let m_frictionForceApplied: Bool;

  public let m_frictionForceAppliedLastFrame: Bool;

  public let m_delayDamageFrame: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.Knockdown);
    this.OnEnter(stateContext, scriptInterface);
    this.m_playedImpactAnim = false;
    this.m_frictionForceApplied = false;
    this.m_frictionForceAppliedLastFrame = false;
    this.m_delayDamageFrame = false;
    this.m_secondaryKnockdownTimer = -1.00;
    this.m_cachedPlayerVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
  }

  protected func CommonOnExit(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    this.CommonOnExit(stateContext, scriptInterface);
    stateContext.RemovePermanentBoolParameter(StatusEffectHelper.TriggerSecondaryKnockdownKey());
  }

  protected func SendStatusEffectAnimDataToGraph(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, state: EKnockdownStates) -> Void {
    if Equals(state, EKnockdownStates.Land) && this.m_animFeatureStatusEffect.state != EnumInt(state) {
      this.SetModifierGroupForState(scriptInterface, "PlayerLocomotion.player_locomotion_data_KnockdownLand");
    };
    this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, state);
  }

  private final func UpdateStatusEffectAnimStates(timeDelta: Float, scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    switch IntEnum(this.m_animFeatureStatusEffect.state) {
      case EKnockdownStates.Start:
        if this.GetTimeInStatusEffect(stateContext, scriptInterface) >= this.GetStartupAnimDuration() {
          if this.IsTouchingGround(scriptInterface) {
            this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.Land);
          } else {
            this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.FallLoop);
          };
        };
        break;
      case EKnockdownStates.FallLoop:
        if this.IsTouchingGround(scriptInterface) {
          this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.Land);
        } else {
          if this.GetStatusEffectRemainingDuration(scriptInterface, stateContext) <= this.GetAirRecoveryAnimDuration() {
            this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.AirRecovery);
          };
        };
        break;
      case EKnockdownStates.Land:
        if this.GetTimeInStatusEffect(stateContext, scriptInterface) >= this.GetLandAnimDuration() && this.GetStatusEffectRemainingDuration(scriptInterface, stateContext) <= this.GetRecoveryAnimDuration() {
          this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.Recovery);
        };
        break;
      case EKnockdownStates.Recovery:
        if this.GetTimeInStatusEffect(stateContext, scriptInterface) >= this.GetRecoveryAnimDuration() {
          stateContext.SetTemporaryBoolParameter(StatusEffectHelper.GetCanExitKnockdownKey(), true, true);
        };
        break;
      case EKnockdownStates.AirRecovery:
        if this.IsTouchingGround(scriptInterface) {
          this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.Land);
        } else {
          if this.GetTimeInStatusEffect(stateContext, scriptInterface) >= this.GetAirRecoveryAnimDuration() {
            stateContext.SetTemporaryBoolParameter(StatusEffectHelper.GetCanExitKnockdownKey(), true, true);
          };
        };
        break;
      default:
    };
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let collisionFrictionForce: Vector4;
    let currentVelocity: Vector4;
    let frictionForceScale: Float;
    let impulseEvent: ref<PSMImpulse>;
    let startupInterruptPoint: Float;
    let velocityChangeDir: Vector4;
    let velocityChangeMag: Float;
    let impactDirection: Int32 = -1;
    let playImpact: Bool = false;
    let triggerSecondaryKnockdown: Bool = false;
    this.UpdateStatusEffectAnimStates(timeDelta, scriptInterface, stateContext);
    this.UpdateQueuedSecondaryKnockdown(stateContext, scriptInterface, timeDelta);
    this.OnUpdate(timeDelta, stateContext, scriptInterface);
    if this.m_frictionForceAppliedLastFrame {
      this.m_frictionForceAppliedLastFrame = false;
      return;
    };
    currentVelocity = DefaultTransition.GetLinearVelocity(scriptInterface);
    velocityChangeDir = currentVelocity - this.m_cachedPlayerVelocity;
    velocityChangeMag = Vector4.Length(velocityChangeDir);
    if velocityChangeMag > 0.00 {
      velocityChangeDir *= 1.00 / velocityChangeMag;
    };
    if velocityChangeMag > 7.00 && Vector4.Dot(velocityChangeDir, this.m_cachedPlayerVelocity) < 0.00 {
      if !this.m_delayDamageFrame {
        this.m_delayDamageFrame = true;
        playImpact = true;
        impactDirection = GameObject.GetLocalAngleForDirectionInInt(velocityChangeDir, scriptInterface.owner);
        currentVelocity = this.m_cachedPlayerVelocity;
      } else {
        this.m_delayDamageFrame = false;
        frictionForceScale = 0.00;
        if velocityChangeMag > 25.00 {
          frictionForceScale = 0.90;
          this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.HardWallImpact"));
          triggerSecondaryKnockdown = true;
        } else {
          if velocityChangeMag > 15.00 {
            frictionForceScale = 0.60;
            this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.MediumWallImpact"));
            triggerSecondaryKnockdown = true;
          } else {
            frictionForceScale = 0.30;
            this.PrepareGameEffectAoEAttack(stateContext, scriptInterface, TweakDBInterface.GetAttackRecord(t"Attacks.LightWallImpact"));
            triggerSecondaryKnockdown = Vector4.Length2D(collisionFrictionForce) < 1.00;
          };
        };
        if frictionForceScale > 0.00 {
          if !this.m_frictionForceApplied {
            this.m_frictionForceApplied = true;
            this.m_frictionForceAppliedLastFrame = true;
            impulseEvent = new PSMImpulse();
            impulseEvent.id = n"impulse";
            impulseEvent.impulse = currentVelocity * -frictionForceScale;
            currentVelocity += impulseEvent.impulse;
            scriptInterface.owner.QueueEvent(impulseEvent);
          };
        };
      };
    } else {
      this.m_delayDamageFrame = false;
    };
    if NotEquals(playImpact, this.m_animFeatureStatusEffect.playImpact) {
      if !this.m_playedImpactAnim {
        this.m_playedImpactAnim = playImpact;
      };
      if playImpact {
        this.m_animFeatureStatusEffect.playImpact = true;
        this.m_animFeatureStatusEffect.impactDirection = impactDirection;
      } else {
        this.m_animFeatureStatusEffect.playImpact = false;
      };
      scriptInterface.SetAnimationParameterFeature(n"StatusEffect", this.m_animFeatureStatusEffect);
    };
    if this.m_playedImpactAnim && this.m_animFeatureStatusEffect.state == EnumInt(EKnockdownStates.Start) {
      startupInterruptPoint = this.m_playerStatusEffectRecordData.StartupAnimInterruptPoint();
      if startupInterruptPoint >= 0.00 {
        if this.GetTimeInStatusEffect(stateContext, scriptInterface) >= startupInterruptPoint {
          this.SendStatusEffectAnimDataToGraph(stateContext, scriptInterface, EKnockdownStates.FallLoop);
        };
      };
    };
    if triggerSecondaryKnockdown {
      this.QueueSecondaryKnockdown(stateContext, scriptInterface, velocityChangeDir);
    };
    this.m_cachedPlayerVelocity = currentVelocity;
  }

  protected final func QueueSecondaryKnockdown(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, knockdownDir: Vector4) -> Void {
    let startupInterruptPoint: Float;
    if this.m_secondaryKnockdownTimer <= 0.00 {
      this.m_secondaryKnockdownTimer = 0.10;
      this.m_secondaryKnockdownDir = knockdownDir;
      if this.m_animFeatureStatusEffect.state == EnumInt(EKnockdownStates.Start) {
        startupInterruptPoint = this.m_playerStatusEffectRecordData.StartupAnimInterruptPoint();
        if startupInterruptPoint < 0.00 {
          startupInterruptPoint = this.m_playerStatusEffectRecordData.StartupAnimDuration();
        };
        this.m_secondaryKnockdownTimer += startupInterruptPoint - this.GetTimeInStatusEffect(stateContext, scriptInterface);
      };
    };
  }

  protected final func UpdateQueuedSecondaryKnockdown(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, deltaTime: Float) -> Void {
    let statusEffectRecord: wref<StatusEffect_Record>;
    let stackcount: Uint32 = 1u;
    if this.m_secondaryKnockdownTimer > 0.00 && this.m_animFeatureStatusEffect.state < EnumInt(EKnockdownStates.Land) {
      this.m_secondaryKnockdownTimer -= deltaTime;
      if this.m_secondaryKnockdownTimer <= 0.00 {
        stateContext.SetPermanentBoolParameter(StatusEffectHelper.TriggerSecondaryKnockdownKey(), true, true);
        statusEffectRecord = TweakDBInterface.GetStatusEffectRecord(t"BaseStatusEffect.SecondaryKnockdown");
        GameInstance.GetStatusEffectSystem(scriptInterface.owner.GetGame()).ApplyStatusEffect(scriptInterface.executionOwnerEntityID, statusEffectRecord.GetID(), GameObject.GetTDBID(scriptInterface.owner), scriptInterface.ownerEntityID, stackcount, this.m_secondaryKnockdownDir);
      };
    };
  }

  protected final func DidPlayerCollideWithWall(scriptInterface: ref<StateGameScriptInterface>, out wallCollision: ControllerHit) -> Bool {
    let playerPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let capsuleRadius: Float = FromVariant(scriptInterface.GetStateVectorParameter(physicsStateValue.Radius));
    return WallCollisionHelpers.GetWallCollision(scriptInterface, playerPosition, DefaultTransition.GetUpVector(), capsuleRadius, wallCollision);
  }
}

public class ForcedKnockdownDecisions extends KnockdownDecisions {

  protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasForcedStatusEffect(stateContext, scriptInterface);
  }

  private final const func HasForcedStatusEffect(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(this.GetStaticStringParameterDefault("statusEffectEnumName", ""), this.GetForcedStatusEffectName(stateContext, scriptInterface));
  }

  private final const func GetForcedStatusEffectName(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> String {
    let statusEffectName: String;
    let statusEffectRecord: wref<StatusEffect_Record> = stateContext.GetPermanentScriptableParameter(StatusEffectHelper.GetForceKnockdownKey()) as StatusEffect_Record;
    if IsDefined(statusEffectRecord) {
      statusEffectName = statusEffectRecord.StatusEffectType().EnumName();
    };
    return statusEffectName;
  }
}

public class ForcedKnockdownEvents extends KnockdownEvents {

  public let m_firstUpdate: Bool;

  public func OnEnter(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let initialVelocity: StateResultVector;
    let originalStartTime: StateResultFloat;
    let statusEffectRecord: wref<StatusEffect_Record> = stateContext.GetPermanentScriptableParameter(StatusEffectHelper.GetForceKnockdownKey()) as StatusEffect_Record;
    stateContext.RemovePermanentScriptableParameter(StatusEffectHelper.GetForceKnockdownKey());
    initialVelocity = stateContext.GetPermanentVectorParameter(StatusEffectHelper.GetForcedKnockdownImpulseKey());
    stateContext.RemovePermanentVectorParameter(StatusEffectHelper.GetForcedKnockdownImpulseKey());
    stateContext.SetTemporaryScriptableParameter(StatusEffectHelper.GetAppliedStatusEffectKey(), statusEffectRecord, true);
    originalStartTime = stateContext.GetPermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey());
    this.OnEnter(stateContext, scriptInterface);
    if initialVelocity.valid {
      this.m_cachedPlayerVelocity = initialVelocity.value;
    };
    if originalStartTime.valid {
      stateContext.SetPermanentFloatParameter(StatusEffectHelper.GetStateStartTimeKey(), originalStartTime.value, true);
    };
    this.m_firstUpdate = true;
  }

  protected func OnUpdate(timeDelta: Float, stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    if this.m_firstUpdate {
      this.m_firstUpdate = false;
    } else {
      this.OnUpdate(timeDelta, stateContext, scriptInterface);
    };
  }
}
