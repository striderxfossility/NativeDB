
public class DefaultTransition extends StateFunctor {

  public final func ForceFreeze(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceIdle", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceWalk", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceFreeze", true, true);
    stateContext.SetPermanentBoolParameter(n"ForceIdleVehicle", false, true);
  }

  public final func ForceIdle(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceIdle", true, true);
    stateContext.SetPermanentBoolParameter(n"ForceWalk", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceFreeze", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceIdleVehicle", false, true);
  }

  public final func ForceIdleVehicle(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceIdleVehicle", true, true);
    stateContext.SetPermanentBoolParameter(n"ForceIdle", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceWalk", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceFreeze", false, true);
  }

  public final func ResetForceFlags(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"ForceIdle", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceWalk", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceFreeze", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceEmptyHands", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceSafeState", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceReadyState", false, true);
    stateContext.SetPermanentBoolParameter(n"ForceIdleVehicle", false, true);
  }

  public final func SetBlackboardFloatVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Float, value: Float) -> Void {
    scriptInterface.localBlackboard.SetFloat(id, value);
    scriptInterface.localBlackboard.SignalFloat(id);
  }

  public final func SetBlackboardIntVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Int, value: Int32) -> Void {
    scriptInterface.localBlackboard.SetInt(id, value);
  }

  public final func SetBlackboardBoolVariable(scriptInterface: ref<StateGameScriptInterface>, id: BlackboardID_Bool, value: Bool) -> Void {
    scriptInterface.localBlackboard.SetBool(id, value);
  }

  public final const func GetBoolFromQuestDB(const scriptInterface: ref<StateGameScriptInterface>, varName: CName) -> Bool {
    return scriptInterface.GetQuestsSystem().GetFact(varName) != 0;
  }

  public final const func HoldAimingForTime(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const blockAimingFor: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"HoldAimingTillTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())) + blockAimingFor, true);
  }

  public final const func BlockAimingForTime(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const blockAimingFor: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"BlockAimingTillTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())) + blockAimingFor, true);
  }

  public final const func SoftBlockAimingForTime(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, const blockAimingFor: Float) -> Void {
    stateContext.SetPermanentFloatParameter(n"SoftBlockAimingTillTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())) + blockAimingFor, true);
    stateContext.SetTemporaryBoolParameter(n"InterruptAiming", true, true);
  }

  public final const func ResetSoftBlockAiming(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    stateContext.SetPermanentFloatParameter(n"SoftBlockAimingTillTimeStamp", EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())), true);
  }

  protected final const func HasTimeStampElapsed(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, timeStampName: CName) -> Bool {
    let timeStampValue: Float = stateContext.GetFloatParameter(timeStampName, true);
    if timeStampValue <= 0.00 {
      return false;
    };
    return EngineTime.ToFloat(GameInstance.GetSimTime(scriptInterface.owner.GetGame())) < timeStampValue;
  }

  protected final const func IsAimingSoftBlocked(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasTimeStampElapsed(stateContext, scriptInterface, n"SoftBlockAimingTillTimeStamp");
  }

  protected final const func IsAimingHeldForTime(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasTimeStampElapsed(stateContext, scriptInterface, n"HoldAimingTillTimeStamp");
  }

  protected final const func IsAimingBlockedForTime(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.HasTimeStampElapsed(stateContext, scriptInterface, n"BlockAimingTillTimeStamp");
  }

  public final const func GetStatFloatValue(const scriptInterface: ref<StateGameScriptInterface>, statType: gamedataStatType, statSystem: ref<StatsSystem>, opt object: ref<GameObject>) -> Float {
    let objectToLookAt: ref<GameObject>;
    let objectToLookAtID: StatsObjectID;
    let result: Float;
    if IsDefined(object) {
      objectToLookAt = object;
    } else {
      objectToLookAt = scriptInterface.owner;
    };
    objectToLookAtID = Cast(objectToLookAt.GetEntityID());
    result = statSystem.GetStatValue(objectToLookAtID, statType);
    return result;
  }

  protected final const func ShouldEnterSafe(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let takedownState: Int32;
    if !this.IsPlayerInCombat(scriptInterface) && (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtFriendly() && !this.ShouldIgnoreWeaponSafe(scriptInterface) {
      return true;
    };
    if DefaultTransition.IsInteractingWithTerminal(scriptInterface) {
      return true;
    };
    if this.IsSafeStateForced(stateContext, scriptInterface) {
      return true;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      return true;
    };
    takedownState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown);
    if takedownState == EnumInt(gamePSMTakedown.Takedown) || takedownState == EnumInt(gamePSMTakedown.Leap) || takedownState == EnumInt(gamePSMTakedown.Grapple) {
      return true;
    };
    if stateContext.IsStateActive(n"Zoom", n"zoomLevelScan") || stateContext.IsStateActive(n"Zoom", n"zoomLevel3") || stateContext.IsStateActive(n"Zoom", n"zoomLevel4") {
      return true;
    };
    return false;
  }

  protected final const func ShouldIgnoreWeaponSafe(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if (scriptInterface.executionOwner as PlayerPuppet).IsAimingAtChild() && this.IsEnemyVisible(scriptInterface, 50.00) {
      return true;
    };
    return false;
  }

  protected final const func IsEnemyVisible(const scriptInterface: ref<StateGameScriptInterface>, opt distance: Float) -> Bool {
    let isEnemyVisible: Bool = false;
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    isEnemyVisible = targetingSystem.IsAnyEnemyVisible(scriptInterface.executionOwner, distance);
    return isEnemyVisible;
  }

  protected final const func IsEnemyOrSensoryDeviceVisible(const scriptInterface: ref<StateGameScriptInterface>, opt distance: Float) -> Bool {
    let isEnemyVisible: Bool = false;
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    isEnemyVisible = targetingSystem.IsAnyEnemyOrSensorVisible(scriptInterface.executionOwner, distance);
    return isEnemyVisible;
  }

  public final static func GetDistanceToTarget(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let playerObject: ref<GameObject> = scriptInterface.executionOwner;
    let targetObject: ref<GameObject> = DefaultTransition.GetTargetObject(scriptInterface);
    return Vector4.Distance2D(playerObject.GetWorldPosition(), targetObject.GetWorldPosition());
  }

  public final static func GetTargetObject(const scriptInterface: ref<StateGameScriptInterface>, opt withinDistance: Float) -> ref<GameObject> {
    let angleOut: EulerAngles;
    let targetingSystem: ref<TargetingSystem> = scriptInterface.GetTargetingSystem();
    let targetObject: ref<GameObject> = targetingSystem.GetObjectClosestToCrosshair(scriptInterface.executionOwner, angleOut, TSQ_NPC());
    if !IsDefined(targetingSystem) || !IsDefined(targetObject) {
      return null;
    };
    if !targetObject.IsPuppet() || !ScriptedPuppet.IsActive(targetObject) {
      return null;
    };
    if Equals(GameObject.GetAttitudeTowards(targetObject, scriptInterface.executionOwner), EAIAttitude.AIA_Friendly) {
      return null;
    };
    if withinDistance <= 0.00 || Vector4.Distance(scriptInterface.executionOwner.GetWorldPosition(), targetObject.GetWorldPosition()) <= withinDistance {
      return targetObject;
    };
    return null;
  }

  protected final func RequestPlayerPositionAdjustment(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, target: ref<GameObject>, slideTime: Float, distanceRadius: Float, rotationDuration: Float, adjustPosition: Vector4, opt useParabolicMotion: Bool) -> Bool {
    let adjustRequest: ref<AdjustTransformWithDurations> = new AdjustTransformWithDurations();
    if IsDefined(target) {
      adjustRequest.SetTarget(target);
      adjustRequest.SetDistanceRadius(distanceRadius);
    };
    adjustRequest.SetPosition(adjustPosition);
    adjustRequest.SetSlideDuration(slideTime);
    adjustRequest.SetRotation(scriptInterface.executionOwner.GetWorldOrientation());
    adjustRequest.SetRotationDuration(rotationDuration);
    adjustRequest.SetGravity(this.GetStaticFloatParameterDefault("downwardsGravity", -16.00));
    adjustRequest.SetUseParabolicMotion(useParabolicMotion);
    stateContext.SetTemporaryScriptableParameter(n"adjustTransform", adjustRequest, true);
    return true;
  }

  protected final func RequestPlayerPositionAdjustmentWithCurve(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, slideTime: Float, distanceRadius: Float, adjustPosition: Vector4, adjustCurveName: CName) -> Bool {
    let adjustRequest: ref<AdjustTransformWithDurations> = new AdjustTransformWithDurations();
    adjustRequest.SetPosition(adjustPosition);
    adjustRequest.SetSlideDuration(slideTime);
    adjustRequest.SetRotationDuration(-1.00);
    adjustRequest.SetGravity(this.GetStaticFloatParameterDefault("downwardsGravity", -16.00));
    adjustRequest.SetDistanceRadius(distanceRadius);
    adjustRequest.SetUseParabolicMotion(true);
    adjustRequest.SetCurve(adjustCurveName);
    stateContext.SetTemporaryScriptableParameter(n"adjustTransform", adjustRequest, true);
    return true;
  }

  public final static func IsInteractingWithTerminal(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let interactionData: bbUIInteractionData;
    let interactionVariant: Variant;
    let uiBlackboard: ref<IBlackboard>;
    let isAiming: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim);
    if isAiming {
      return false;
    };
    uiBlackboard = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    interactionVariant = uiBlackboard.GetVariant(GetAllBlackboardDefs().UIGameData.InteractionData);
    if VariantIsValid(interactionVariant) {
      interactionData = FromVariant(interactionVariant);
      if interactionData.terminalInteractionActive {
        return true;
      };
    };
    return false;
  }

  public final static func HasActiveInteraction(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let interactionData: bbUIInteractionData;
    let uiBlackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIGameData);
    let interactionVariant: Variant = uiBlackboard.GetVariant(GetAllBlackboardDefs().UIGameData.InteractionData);
    if VariantIsValid(interactionVariant) {
      interactionData = FromVariant(interactionVariant);
      if bbUIInteractionData.HasAnyInteraction(interactionData) {
        return true;
      };
    };
    return false;
  }

  protected final const func IsDoorInteractionActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsDoorInteractionActive);
  }

  public const func GetStatusEffectRecord(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> wref<StatusEffect_Record> {
    let statusEffectRecord: wref<StatusEffect_Record> = stateContext.GetTemporaryScriptableParameter(StatusEffectHelper.GetAppliedStatusEffectKey()) as StatusEffect_Record;
    return statusEffectRecord;
  }

  public const func GetStatusEffectPlayerData(const scriptInterface: ref<StateGameScriptInterface>, const stateContext: ref<StateContext>) -> wref<StatusEffectPlayerData_Record> {
    return TweakDBInterface.GetStatusEffectRecord(this.GetStatusEffectRecord(stateContext, scriptInterface).GetID()).PlayerData();
  }

  public const func GetStatusEffectRecordData(const stateContext: ref<StateContext>) -> wref<StatusEffectPlayerData_Record> {
    let recordData: wref<StatusEffectPlayerData_Record> = stateContext.GetConditionScriptableParameter(n"PlayerStatusEffectRecordData") as StatusEffectPlayerData_Record;
    return recordData;
  }

  public const func IsPlayerTired(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Stamina) != EnumInt(gamePSMStamina.Rested);
  }

  public const func IsPlayerExhausted(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Stamina) == EnumInt(gamePSMStamina.Exhausted);
  }

  protected final func ChangeStatPoolValue(scriptInterface: ref<StateGameScriptInterface>, entityID: EntityID, statPoolType: gamedataStatPoolType, val: Float) -> Void {
    scriptInterface.GetStatPoolsSystem().RequestChangingStatPoolValue(Cast(entityID), statPoolType, val, null, false, false);
  }

  protected final const func GetStatPoolValue(const scriptInterface: ref<StateGameScriptInterface>, entityID: EntityID, statPool: gamedataStatPoolType, opt asPrecentage: Bool) -> Float {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    return statPoolsSystem.GetStatPoolValue(Cast(entityID), statPool, asPrecentage);
  }

  protected final const func HasStatPoolValueReachedMax(const scriptInterface: ref<StateGameScriptInterface>, entityID: EntityID, statPool: gamedataStatPoolType) -> Bool {
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    return statPoolsSystem.HasStatPoolValueReachedMax(Cast(entityID), statPool);
  }

  protected final func StartStatPoolDecay(const scriptInterface: ref<StateGameScriptInterface>, statPoolType: gamedataStatPoolType) -> Void {
    let mod: StatPoolModifier;
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    let entityID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    statPoolsSystem.GetModifier(entityID, statPoolType, gameStatPoolModificationTypes.Decay, mod);
    mod.enabled = true;
    statPoolsSystem.RequestSettingModifier(entityID, statPoolType, gameStatPoolModificationTypes.Decay, mod);
    statPoolsSystem.RequestResetingModifier(entityID, statPoolType, gameStatPoolModificationTypes.Regeneration);
  }

  protected final func StopStatPoolDecayAndRegenerate(const scriptInterface: ref<StateGameScriptInterface>, statPoolType: gamedataStatPoolType) -> Void {
    let mod: StatPoolModifier;
    let statPoolsSystem: ref<StatPoolsSystem> = scriptInterface.GetStatPoolsSystem();
    let entityID: StatsObjectID = Cast(scriptInterface.executionOwnerEntityID);
    statPoolsSystem.GetModifier(entityID, statPoolType, gameStatPoolModificationTypes.Regeneration, mod);
    mod.enabled = true;
    statPoolsSystem.RequestSettingModifier(entityID, statPoolType, gameStatPoolModificationTypes.Regeneration, mod);
    statPoolsSystem.RequestResetingModifier(entityID, statPoolType, gameStatPoolModificationTypes.Decay);
  }

  public final static func UppercaseFirstChar(out stringToChange: String) -> Void {
    let length: Int32 = StrLen(stringToChange);
    let firstChar: String = StrLeft(stringToChange, 1);
    let restOfTheString: String = StrRight(stringToChange, length - 1);
    firstChar = StrUpper(firstChar);
    stringToChange = firstChar + restOfTheString;
  }

  public final static func GetPlayerPuppet(const scriptInterface: ref<StateGameScriptInterface>) -> ref<PlayerPuppet> {
    return scriptInterface.executionOwner as PlayerPuppet;
  }

  public final static func PlayRumble(const scriptInterface: ref<StateGameScriptInterface>, presetName: String) -> Void {
    let rumbleName: CName = TDB.GetCName(TDBID.Create("rumble.local." + presetName));
    GameObject.PlaySound(DefaultTransition.GetPlayerPuppet(scriptInterface), rumbleName);
  }

  public final static func PlayRumbleLoop(const scriptInterface: ref<StateGameScriptInterface>, intensity: String) -> Void {
    let rumbleName: CName = TDB.GetCName(TDBID.Create("rumble.local." + "loop_" + intensity));
    GameObject.PlaySound(DefaultTransition.GetPlayerPuppet(scriptInterface), rumbleName);
  }

  public final static func StopRumbleLoop(const scriptInterface: ref<StateGameScriptInterface>, intensity: String) -> Void {
    let rumbleName: CName = TDB.GetCName(TDBID.Create("rumble.loopstop." + intensity));
    GameObject.PlaySound(DefaultTransition.GetPlayerPuppet(scriptInterface), rumbleName);
  }

  public final static func RemoveAllBreathingEffects(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BreathingLow");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BreathingMedium");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BreathingHeavy");
    StatusEffectHelper.RemoveStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.BreathingSick");
  }

  public final static func GetPlayerPosition(const scriptInterface: ref<StateGameScriptInterface>) -> Vector4 {
    let positionParameter: Variant = scriptInterface.GetStateVectorParameter(physicsStateValue.Position);
    let playerPosition: Vector4 = FromVariant(positionParameter);
    return playerPosition;
  }

  public final static func GetPlayerDistanceToGround(const scriptInterface: ref<StateGameScriptInterface>, downwardRaycastLength: Float) -> Float {
    return Vector4.Distance2D(DefaultTransition.GetPlayerPosition(scriptInterface), DefaultTransition.GetGroundPosition(scriptInterface, downwardRaycastLength));
  }

  public final static func GetDistanceToGround(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let distanceToGround: Float;
    let geometryDescription: ref<GeometryDescriptionQuery>;
    let geometryDescriptionResult: ref<GeometryDescriptionResult>;
    let queryFilter: QueryFilter;
    let currentPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    QueryFilter.AddGroup(queryFilter, n"Static");
    QueryFilter.AddGroup(queryFilter, n"Terrain");
    QueryFilter.AddGroup(queryFilter, n"PlayerBlocker");
    geometryDescription = new GeometryDescriptionQuery();
    geometryDescription.AddFlag(worldgeometryDescriptionQueryFlags.DistanceVector);
    geometryDescription.filter = queryFilter;
    geometryDescription.refPosition = currentPosition;
    geometryDescription.refDirection = new Vector4(0.00, 0.00, -1.00, 0.00);
    geometryDescription.primitiveDimension = new Vector4(0.50, 0.10, 0.10, 0.00);
    geometryDescription.maxDistance = 100.00;
    geometryDescription.maxExtent = 100.00;
    geometryDescription.probingPrecision = 10.00;
    geometryDescription.probingMaxDistanceDiff = 100.00;
    geometryDescriptionResult = scriptInterface.GetSpatialQueriesSystem().GetGeometryDescriptionSystem().QueryExtents(geometryDescription);
    if Equals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.NoGeometry) || NotEquals(geometryDescriptionResult.queryStatus, worldgeometryDescriptionQueryStatus.OK) {
      return -1.00;
    };
    distanceToGround = AbsF(geometryDescriptionResult.distanceVector.Z);
    return distanceToGround;
  }

  public final static func GetGroundPosition(const scriptInterface: ref<StateGameScriptInterface>, inLenght: Float) -> Vector4 {
    let findGround: TraceResult;
    let findWater: TraceResult;
    let position: Vector4;
    let playerFeetPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let startPosition: Vector4 = playerFeetPosition;
    startPosition.Z = startPosition.Z;
    let raycastLenght: Vector4 = playerFeetPosition;
    raycastLenght.Z -= inLenght;
    findGround = scriptInterface.RayCast(startPosition, raycastLenght, n"Static");
    findWater = scriptInterface.RayCast(startPosition, raycastLenght, n"Water");
    if TraceResult.IsValid(findGround) {
      position = Cast(findGround.position);
    } else {
      if TraceResult.IsValid(findWater) {
        position = Cast(findWater.position);
      };
    };
    return position;
  }

  protected final const func IsDeepEnoughToSwim(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let waterLevel: Float;
    let playerFeetPosition: Vector4 = DefaultTransition.GetPlayerPosition(scriptInterface);
    let depthRaycastDestination: Vector4 = playerFeetPosition;
    depthRaycastDestination.Z = depthRaycastDestination.Z - 2.00;
    let deepEnough: Bool = false;
    if scriptInterface.GetWaterLevel(playerFeetPosition, depthRaycastDestination, waterLevel) {
      deepEnough = playerFeetPosition.Z - waterLevel <= -0.90 + -0.10;
    };
    return deepEnough;
  }

  public final static func GetLinearVelocity(const scriptInterface: ref<StateGameScriptInterface>) -> Vector4 {
    let parameter: Variant = scriptInterface.GetStateVectorParameter(physicsStateValue.LinearVelocity);
    let velocity: Vector4 = FromVariant(parameter);
    return velocity;
  }

  public final static func GetUpVector() -> Vector4 {
    let up: Vector4;
    up.Z = 1.00;
    return up;
  }

  public final static func Get2DLinearSpeed(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let parameter: Variant = scriptInterface.GetStateVectorParameter(physicsStateValue.LinearVelocity);
    let velocity: Vector4 = FromVariant(parameter);
    return Vector4.Length2D(velocity);
  }

  protected final const func GetVerticalSpeed(const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let parameter: Variant = scriptInterface.GetStateVectorParameter(physicsStateValue.LinearVelocity);
    let velocity: Vector4 = FromVariant(parameter);
    return velocity.Z;
  }

  public final static func GetMovementDirection(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> EPlayerMovementDirection {
    let direction: EPlayerMovementDirection;
    let currentYaw: Float = DefaultTransition.GetYawMovementDirection(stateContext, scriptInterface);
    if currentYaw >= -45.00 && currentYaw <= 45.00 {
      direction = EPlayerMovementDirection.Forward;
    } else {
      if currentYaw > 45.00 && currentYaw < 135.00 {
        direction = EPlayerMovementDirection.Right;
      } else {
        if currentYaw >= 135.00 && currentYaw <= 180.00 || currentYaw <= -135.00 && currentYaw >= -180.00 {
          direction = EPlayerMovementDirection.Back;
        } else {
          if currentYaw > -135.00 && currentYaw < -45.00 {
            direction = EPlayerMovementDirection.Left;
          };
        };
      };
    };
    return direction;
  }

  public final static func GetYawMovementDirection(const stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let linearVel: Vector4 = DefaultTransition.GetLinearVelocity(scriptInterface);
    let playerForward: Vector4 = scriptInterface.executionOwner.GetWorldForward();
    return Vector4.GetAngleDegAroundAxis(linearVel, playerForward, DefaultTransition.GetUpVector());
  }

  public final static func GetMovementInputActionValue(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let x: Float = scriptInterface.GetActionValue(n"MoveX");
    let y: Float = scriptInterface.GetActionValue(n"MoveY");
    let res: Float = SqrtF(SqrF(x) + SqrF(y));
    return res;
  }

  protected final const func IsMovementInput(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsMoveInputConsiderable();
  }

  protected final const func IsPlayerMoving(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsPlayerMovingHorizontally(stateContext, scriptInterface) || this.IsPlayerMovingVertically(stateContext, scriptInterface);
  }

  protected final const func IsPlayerMovingHorizontally(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let playerVelocity: Vector4 = DefaultTransition.GetLinearVelocity(scriptInterface);
    let horizontalSpeed: Float = Vector4.Length2D(playerVelocity);
    return horizontalSpeed > 0.00;
  }

  protected final const func IsPlayerMovingVertically(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let verticalSpeed: Float = this.GetVerticalSpeed(scriptInterface);
    return verticalSpeed > 0.00 || verticalSpeed < 0.00;
  }

  protected final const func IsPlayerMovingBackwards(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let movementDirection: Float = this.GetHorizontalMovementDirection(stateContext, scriptInterface);
    if movementDirection >= 135.00 && movementDirection <= 180.00 || movementDirection <= -135.00 && movementDirection >= -180.00 {
      return true;
    };
    return false;
  }

  protected final const func GetHorizontalMovementDirection(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let linearVel: Vector4 = DefaultTransition.GetLinearVelocity(scriptInterface);
    let playerForward: Vector4 = scriptInterface.executionOwner.GetWorldForward();
    return Vector4.GetAngleDegAroundAxis(linearVel, playerForward, DefaultTransition.GetUpVector());
  }

  public final static func GetActiveLeftHandItem(const scriptInterface: ref<StateGameScriptInterface>) -> ref<ItemObject> {
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponLeft");
  }

  public final static func IsHeavyWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.GetActiveWeapon(scriptInterface).IsHeavyWeapon();
  }

  public final static func GetActiveWeapon(const scriptInterface: ref<StateGameScriptInterface>) -> ref<WeaponObject> {
    return scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
  }

  public final static func IsXYActionInputGreaterEqual(const scriptInterface: ref<StateGameScriptInterface>, threshold: Float) -> Bool {
    return AbsF(scriptInterface.GetActionValue(n"MoveX")) >= threshold || AbsF(scriptInterface.GetActionValue(n"MoveY")) >= threshold;
  }

  public final static func IsAxisButtonHeldGreaterEqual(const scriptInterface: ref<StateGameScriptInterface>, threshold: Float) -> Bool {
    return scriptInterface.GetActionValue(n"Forward") > 0.00 && scriptInterface.GetActionStateTime(n"Forward") > threshold || scriptInterface.GetActionValue(n"Right") > 0.00 && scriptInterface.GetActionStateTime(n"Right") > threshold || scriptInterface.GetActionValue(n"Back") > 0.00 && scriptInterface.GetActionStateTime(n"Back") > threshold || scriptInterface.GetActionValue(n"Left") > 0.00 && scriptInterface.GetActionStateTime(n"Left") > threshold;
  }

  public final const func IsSafeStateForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return (stateContext.GetBoolParameter(n"ForceSafeState", true) || stateContext.GetBoolParameter(n"ForceSafeStateByZone", true) || this.GetBoolFromQuestDB(scriptInterface, n"ForceSafeState")) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced);
  }

  protected final const func GetActionHoldTime(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, actionName: CName) -> Float {
    let holdTime: Float;
    if scriptInterface.GetActionValue(actionName) > 0.00 {
      holdTime = scriptInterface.GetActionStateTime(actionName);
      stateContext.SetConditionFloatParameter(n"InputHoldTime", holdTime, true);
    };
    return holdTime;
  }

  protected final func ToggleAudioAimDownSights(weapon: ref<WeaponObject>, toggleOn: Bool) -> Void {
    let ADSToggleEvent: ref<ToggleAimDownSightsEvent> = new ToggleAimDownSightsEvent();
    ADSToggleEvent.toggleOn = toggleOn;
    weapon.QueueEvent(ADSToggleEvent);
  }

  protected final func DisableCameraBobbing(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, b: Bool) -> Void {
    AnimationControllerComponent.SetInputBool(DefaultTransition.GetPlayerPuppet(scriptInterface), n"disable_camera_bobbing", b);
  }

  protected final func StartEffect(scriptInterface: ref<StateGameScriptInterface>, effectName: CName, opt blackboard: ref<worldEffectBlackboard>) -> Void {
    GameObjectEffectHelper.StartEffectEvent(scriptInterface.executionOwner, effectName, false, blackboard);
  }

  protected final func StopEffect(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    GameObjectEffectHelper.StopEffectEvent(scriptInterface.executionOwner, effectName);
  }

  protected final func BreakEffectLoop(scriptInterface: ref<StateGameScriptInterface>, effectName: CName) -> Void {
    GameObjectEffectHelper.BreakEffectLoopEvent(scriptInterface.executionOwner, effectName);
  }

  protected final func PlaySound(soundName: CName, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioEvent: ref<SoundPlayEvent> = new SoundPlayEvent();
    audioEvent.soundName = soundName;
    scriptInterface.owner.QueueEvent(audioEvent);
  }

  protected final func SetAudioParameter(paramName: CName, paramValue: Float, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let audioParam: ref<SoundParameterEvent> = new SoundParameterEvent();
    audioParam.parameterName = paramName;
    audioParam.parameterValue = paramValue;
    scriptInterface.owner.QueueEvent(audioParam);
  }

  protected final func PlaySoundMetadataEvent(evtName: CName, scriptInterface: ref<StateGameScriptInterface>, evtParam: Float) -> Void {
    let metadataEvent: ref<AudioEvent> = new AudioEvent();
    metadataEvent.eventName = evtName;
    metadataEvent.floatData = evtParam;
    metadataEvent.eventFlags = audioAudioEventFlags.Metadata;
    scriptInterface.owner.QueueEvent(metadataEvent);
  }

  protected final func SetSurfaceMaterialProbingDirection(direction: gameaudioeventsSurfaceDirection, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let directionChangedEvent: ref<NotifySurfaceDirectionChangedEvent> = new NotifySurfaceDirectionChangedEvent();
    directionChangedEvent.surfaceDirection = direction;
    scriptInterface.owner.QueueEvent(directionChangedEvent);
  }

  protected final func AdjustPlayerPosition(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, target: ref<GameObject>, duration: Float, distanceRadius: Float, curveName: CName) -> Bool {
    let adjustRequest: ref<AdjustTransformWithDurations>;
    let position: Vector4;
    let vecToTarget: Vector4;
    if !IsDefined(target) || duration <= 0.00 {
      return false;
    };
    adjustRequest = new AdjustTransformWithDurations();
    vecToTarget = target.GetWorldPosition() - scriptInterface.executionOwner.GetWorldPosition();
    position = Vector4.Normalize(vecToTarget) * -0.10;
    adjustRequest.SetDistanceRadius(distanceRadius);
    adjustRequest.SetTarget(target);
    adjustRequest.SetSlideDuration(duration);
    adjustRequest.SetPosition(position);
    adjustRequest.SetRotationDuration(-1.00);
    if IsNameValid(curveName) {
      adjustRequest.SetCurve(curveName);
    };
    stateContext.SetTemporaryScriptableParameter(n"adjustTransform", adjustRequest, true);
    return true;
  }

  public final static func HasMeleeWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    return IsDefined(weapon) ? weapon.IsMelee() : false;
  }

  public final static func IsRangedWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    return IsDefined(weapon) ? weapon.IsRanged() : false;
  }

  public final static func IsChargeRangedWeapon(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let game: GameInstance = scriptInterface.owner.GetGame();
    let weapon: ref<WeaponObject> = GameInstance.GetTransactionSystem(game).GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if weapon.IsRanged() {
        return Equals(weapon.GetCurrentTriggerMode().Type(), gamedataTriggerMode.Charge);
      };
    };
    return false;
  }

  public final static func IsChargingWeapon(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let weapon: ref<WeaponObject> = scriptInterface.GetTransactionSystem().GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) && weapon.IsRanged() {
      return WeaponObject.GetWeaponChargeNormalized(weapon) > 0.00;
    };
    return false;
  }

  public final static func HasRightWeaponEquipped(const scriptInterface: ref<StateGameScriptInterface>, opt checkForTag: Bool) -> Bool {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let weapon: ref<WeaponObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(weapon) {
      if checkForTag && !transactionSystem.HasTag(scriptInterface.executionOwner, n"Weapon", weapon.GetItemID()) {
        return false;
      };
      return true;
    };
    return false;
  }

  protected final func StartPool(statPoolsSystem: ref<StatPoolsSystem>, weaponEntityID: EntityID, poolType: gamedataStatPoolType, opt rangeEnd: Float, opt valuePerSec: Float) -> Void {
    let mod: StatPoolModifier;
    statPoolsSystem.GetModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Regeneration, mod);
    mod.enabled = true;
    if rangeEnd > 0.00 {
      mod.rangeEnd = rangeEnd;
    };
    if valuePerSec > 0.00 {
      mod.valuePerSec = valuePerSec;
    };
    statPoolsSystem.RequestSettingModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Regeneration, mod);
    statPoolsSystem.RequestResetingModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Decay);
  }

  protected final func StopPool(statPoolsSystem: ref<StatPoolsSystem>, weaponEntityID: EntityID, poolType: gamedataStatPoolType, startDecay: Bool) -> Void {
    let mod: StatPoolModifier;
    statPoolsSystem.RequestResetingModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Regeneration);
    if startDecay {
      statPoolsSystem.GetModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Decay, mod);
      mod.enabled = true;
      statPoolsSystem.RequestSettingModifier(Cast(weaponEntityID), poolType, gameStatPoolModificationTypes.Decay, mod);
    };
  }

  protected final const func GetWeaponItemTag(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, tag: CName, opt itemID: ItemID) -> Bool {
    let weapon: ref<WeaponObject> = DefaultTransition.GetActiveWeapon(scriptInterface);
    return weapon.WeaponHasTag(tag);
  }

  public final static func GetWeaponItemType(const scriptInterface: ref<StateGameScriptInterface>, weapon: ref<WeaponObject>, out itemType: gamedataItemType) -> Bool {
    if !IsDefined(weapon) {
      return false;
    };
    itemType = weapon.GetWeaponRecord().ItemType().Type();
    return true;
  }

  public final static func IsInWorkspot(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let workspotSystem: ref<WorkspotGameSystem> = scriptInterface.GetWorkspotSystem();
    let res: Bool = workspotSystem.IsActorInWorkspot(scriptInterface.executionOwner);
    return res;
  }

  protected final const func GetCurrentTier(const stateContext: ref<StateContext>) -> GameplayTier {
    let sceneTier: ref<SceneTier> = stateContext.GetPermanentScriptableParameter(n"SceneTier") as SceneTier;
    if IsDefined(sceneTier) {
      return sceneTier.GetTier();
    };
    return GameplayTier.Tier1_FullGameplay;
  }

  protected final const func GetCurrentSceneTierData(const stateContext: ref<StateContext>) -> ref<SceneTierData> {
    let sceneTier: ref<SceneTier> = stateContext.GetPermanentScriptableParameter(n"SceneTier") as SceneTier;
    if IsDefined(sceneTier) {
      return sceneTier.GetTierData();
    };
    return null;
  }

  protected final const func IsInMinigame(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInMinigame);
  }

  protected final const func IsUploadingQuickHack(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.IsUploadingQuickHack) > 0;
  }

  public final static func IsInRpgContext(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let ics: ref<InputContextSystem> = scriptInterface.GetScriptableSystem(n"InputContextSystem") as InputContextSystem;
    return ics.IsActiveContextRPG();
  }

  protected final const func IsCameraPitchAcceptable(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, cameraPitchThreshold: Float) -> Bool {
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let angles: EulerAngles = Transform.ToEulerAngles(cameraWorldTransform);
    return angles.Pitch < cameraPitchThreshold;
  }

  protected final const func GetCameraYaw(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Float {
    let cameraWorldTransform: Transform = scriptInterface.GetCameraWorldTransform();
    let result: Float = Vector4.GetAngleDegAroundAxis(Transform.GetForward(cameraWorldTransform), scriptInterface.owner.GetWorldForward(), DefaultTransition.GetUpVector());
    return result;
  }

  protected final const func IsPlayerInCombat(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.InCombat);
  }

  protected final const func IsInSafeSceneTier(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let tier: Int32 = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    return tier > EnumInt(gamePSMHighLevel.SceneTier1) && tier <= EnumInt(gamePSMHighLevel.SceneTier5);
  }

  protected final const func GetSceneTier(const scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
  }

  protected final const func ForceDisableVisionMode(stateContext: ref<StateContext>) -> Void {
    stateContext.SetPermanentBoolParameter(n"forceDisableVision", true, true);
  }

  protected final const func ForceDisableRadialWheel(const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let radialMenuCloseEvt: ref<ForceRadialWheelShutdown> = new ForceRadialWheelShutdown();
    scriptInterface.executionOwner.QueueEvent(radialMenuCloseEvt);
  }

  protected final const func CheckItemCategoryInQuickWheel(const scriptInterface: ref<StateGameScriptInterface>, compareToType: gamedataItemCategory) -> Bool {
    let inInventory: Bool;
    let itemValid: Bool;
    let quickSlotID: ItemID;
    let quickSlotRecord: ref<Item_Record>;
    let game: GameInstance = scriptInterface.executionOwner.GetGame();
    let ts: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let eqs: ref<EquipmentSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"EquipmentSystem") as EquipmentSystem;
    if !IsDefined(eqs) {
      return false;
    };
    quickSlotID = eqs.GetItemIDFromHotkey(scriptInterface.executionOwner, EHotkey.RB);
    itemValid = ItemID.IsValid(quickSlotID);
    inInventory = ts.GetItemQuantity(scriptInterface.executionOwner, quickSlotID) > 0;
    quickSlotRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(quickSlotID));
    return Equals(quickSlotRecord.ItemCategory().Type(), compareToType) && itemValid && inInventory;
  }

  protected final const func IsQuickWheelItemACyberdeck(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let checkSuccessful: Bool;
    let itemRecord: wref<Item_Record>;
    let itemTags: array<CName>;
    let quickSlotID: ItemID;
    let eqs: ref<EquipmentSystem> = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
    if !IsDefined(eqs) {
      return false;
    };
    quickSlotID = eqs.GetItemIDFromHotkey(scriptInterface.executionOwner, EHotkey.RB);
    itemRecord = RPGManager.GetItemRecord(quickSlotID);
    itemTags = itemRecord.Tags();
    checkSuccessful = ItemID.IsValid(quickSlotID) && ArrayContains(itemTags, n"Cyberdeck");
    return checkSuccessful;
  }

  protected final const func IsInFocusMode(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
  }

  protected final const func SetZoomStateAnimFeature(scriptInterface: ref<StateGameScriptInterface>, shouldAim: Bool) -> Void {
    let af: ref<AnimFeature_AimPlayer> = new AnimFeature_AimPlayer();
    if shouldAim {
      af.SetZoomState(animAimState.Aimed);
    } else {
      af.SetZoomState(animAimState.Unaimed);
    };
    af.SetAimInTime(0.20);
    af.SetAimOutTime(0.20);
    scriptInterface.SetAnimationParameterFeature(n"AnimFeature_AimPlayer", af);
  }

  protected final const func GetSceneSystemInterface(const scriptInterface: ref<StateGameScriptInterface>) -> ref<SceneSystemInterface> {
    return scriptInterface.GetSceneSystem().GetScriptInterface();
  }

  protected final func PrepareGameEffectAoEAttack(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, attackRecord: ref<Attack_Record>) -> Bool {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let statMods: array<ref<gameStatModifierData>>;
    let attackRadius: Float = attackRecord.Range();
    attackContext.record = attackRecord;
    attackContext.instigator = scriptInterface.executionOwner;
    attackContext.source = scriptInterface.executionOwner;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(scriptInterface.executionOwner);
    if !IsDefined(attack) {
      return false;
    };
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, attackRadius);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, attackRadius);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, scriptInterface.executionOwner.GetWorldPosition());
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    attack.StartAttack();
    return true;
  }

  protected final const func IsPlayerInBraindance(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetSceneSystem().GetScriptInterface().IsRewindableSectionActive();
  }

  protected final const func GetBraindanceSystem(const scriptInterface: ref<StateGameScriptInterface>) -> ref<BraindanceSystem> {
    let bdSys: ref<BraindanceSystem> = scriptInterface.GetScriptableSystem(n"BraindanceSystem") as BraindanceSystem;
    return bdSys;
  }

  protected final const func IsInPhotoMode(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let photoModeSys: ref<PhotoModeSystem> = GameInstance.GetPhotoModeSystem(scriptInterface.executionOwner.GetGame());
    return photoModeSys.IsPhotoModeActive();
  }

  protected final const func SendEquipmentSystemWeaponManipulationRequest(const scriptInterface: ref<StateGameScriptInterface>, requestType: EquipmentManipulationAction, opt equipAnimType: gameEquipAnimationType) -> Void {
    let eqs: ref<EquipmentSystem> = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
    let request: ref<EquipmentSystemWeaponManipulationRequest> = new EquipmentSystemWeaponManipulationRequest();
    request.owner = scriptInterface.executionOwner;
    request.requestType = requestType;
    if NotEquals(equipAnimType, gameEquipAnimationType.Default) {
      request.equipAnimType = equipAnimType;
    };
    eqs.QueueRequest(request);
  }

  protected final const func SendDrawItemRequest(const scriptInterface: ref<StateGameScriptInterface>, item: ItemID, opt equipAnimType: gameEquipAnimationType) -> Void {
    let drawItem: ref<DrawItemRequest> = new DrawItemRequest();
    let equipmentSystem: wref<EquipmentSystem> = scriptInterface.GetScriptableSystem(n"EquipmentSystem") as EquipmentSystem;
    drawItem.owner = scriptInterface.executionOwner;
    drawItem.itemID = item;
    if NotEquals(equipAnimType, gameEquipAnimationType.Default) {
      drawItem.equipAnimationType = equipAnimType;
    };
    equipmentSystem.QueueRequest(drawItem);
  }

  protected final const func IsItemMeleeWeapon(item: ItemID) -> Bool {
    let tags: array<CName> = TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(item)).Tags();
    return ArrayContains(tags, WeaponObject.GetMeleeWeaponTag());
  }

  protected final const func GetLeftHandItemFromParam(const stateContext: ref<StateContext>) -> ItemID {
    let wrapper: ref<ItemIdWrapper> = stateContext.GetPermanentScriptableParameter(n"leftHandItem") as ItemIdWrapper;
    if IsDefined(wrapper) {
      return wrapper.itemID;
    };
    return ItemID.undefined();
  }

  protected final const func GetRightHandItemFromParam(const stateContext: ref<StateContext>) -> ItemID {
    let wrapper: ref<ItemIdWrapper> = stateContext.GetPermanentScriptableParameter(n"rightHandItem") as ItemIdWrapper;
    if IsDefined(wrapper) {
      return wrapper.itemID;
    };
    return ItemID.undefined();
  }

  protected final const func IsLookingAtEnemyNPC(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let npc: ref<ScriptedPuppet>;
    let game: GameInstance = scriptInterface.executionOwner.GetGame();
    let hudManager: ref<HUDManager> = GameInstance.GetScriptableSystemsContainer(game).Get(n"HUDManager") as HUDManager;
    if IsDefined(hudManager) {
      npc = GameInstance.FindEntityByID(game, hudManager.GetCurrentTargetID()) as ScriptedPuppet;
      return IsDefined(npc) && npc.IsHostile();
    };
    return false;
  }

  protected final const func GetHudManager(const scriptInterface: ref<StateGameScriptInterface>) -> ref<HUDManager> {
    let hudManager: ref<HUDManager> = scriptInterface.GetScriptableSystem(n"HUDManager") as HUDManager;
    return hudManager;
  }

  public final func SetGameplayCameraParameters(scriptInterface: ref<StateGameScriptInterface>, tweakDBPath: String) -> Void {
    let animFeature: ref<AnimFeature_CameraGameplay>;
    let cameraParameters: ref<GameplayCameraData>;
    this.GetGameplayCameraParameters(cameraParameters, tweakDBPath);
    animFeature = new AnimFeature_CameraGameplay();
    animFeature.is_forward_offset = cameraParameters.is_forward_offset;
    animFeature.forward_offset_value = cameraParameters.forward_offset_value;
    animFeature.upperbody_pitch_weight = cameraParameters.upperbody_pitch_weight;
    animFeature.upperbody_yaw_weight = cameraParameters.upperbody_yaw_weight;
    animFeature.is_pitch_off = cameraParameters.is_pitch_off;
    animFeature.is_yaw_off = cameraParameters.is_yaw_off;
    scriptInterface.SetAnimationParameterFeature(n"CameraGameplay", animFeature);
  }

  public final func GetGameplayCameraParameters(out cameraParameters: ref<GameplayCameraData>, tweakDBPath: String) -> Void {
    cameraParameters = new GameplayCameraData();
    cameraParameters.is_forward_offset = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "is_forward_offset"), 0.00);
    cameraParameters.forward_offset_value = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "forward_offset_value"), 0.00);
    cameraParameters.upperbody_pitch_weight = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "upperbody_pitch_weight"), 0.00);
    cameraParameters.upperbody_yaw_weight = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "upperbody_yaw_weight"), 0.00);
    cameraParameters.is_pitch_off = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "is_pitch_off"), 0.00);
    cameraParameters.is_yaw_off = TweakDBInterface.GetFloat(TDBID.Create("player." + tweakDBPath + "." + "is_yaw_off"), 0.00);
  }

  public final static func DEBUG_IsSwimmingForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.DEBUG_IsSurfaceSwimmingForced(stateContext, scriptInterface) || DefaultTransition.DEBUG_IsDivingForced(stateContext, scriptInterface);
  }

  public final static func DEBUG_IsSurfaceSwimmingForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.ForceSwim");
  }

  public final static func DEBUG_IsDivingForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.ForceDive");
  }

  protected final const func IsInTier2Locomotion(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Tier2Locomotion");
  }

  protected final const func IsCrouchForced(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ForceCrouch");
  }

  protected final const func IsVaultingClimbingRestricted(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return this.IsInTier2Locomotion(scriptInterface) || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoJump") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"BodyCarryingGeneric");
  }

  protected final const func IsUsingMeleeForced(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Melee");
  }

  protected final const func IsUsingFistsForced(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Fists");
  }

  protected final const func IsUsingFirearmsForced(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"Firearms") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoUnequip") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FirearmsNoSwitch") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"ShootingRangeCompetition");
  }

  protected final const func IsNoCombatActionsForced(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoCombat") && !StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"FastForward") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleScene");
  }

  protected final const func IsVehicleCameraChangeBlocked(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleFPP") || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleCombatNoInterruptions");
  }

  protected final const func IsVehicleExitCombatModeBlocked(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleCombatBlockExit");
  }

  protected final const func HasAnyValidWeaponAvailable(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return EquipmentSystem.GetFirstAvailableWeapon(scriptInterface.executionOwner) != ItemID.undefined();
  }

  protected final const func IsUsingLeftHandAllowed(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if LeftHandCyberwareHelper.IsProjectileLauncherInCooldown(scriptInterface) {
      return false;
    };
    if StatusEffectSystem.ObjectHasStatusEffectOfType(scriptInterface.executionOwner, gamedataStatusEffectType.Stunned) {
      return false;
    };
    if this.IsNoCombatActionsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingFirearmsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingFistsForced(scriptInterface) {
      return false;
    };
    if this.IsUsingMeleeForced(scriptInterface) {
      return false;
    };
    if this.IsCarryingBody(scriptInterface) {
      return false;
    };
    return true;
  }

  protected final const func IsUsingConsumableRestricted(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let tier: Int32;
    if PlayerGameplayRestrictions.IsHotkeyRestricted(scriptInterface.executionOwner.GetGame(), EHotkey.DPAD_UP) {
      return true;
    };
    tier = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel);
    if tier >= EnumInt(gamePSMHighLevel.SceneTier3) && tier <= EnumInt(gamePSMHighLevel.SceneTier5) {
      return true;
    };
    if this.IsCarryingBody(scriptInterface) {
      return true;
    };
    return false;
  }

  protected final const func GetTakedownAction(const stateContext: ref<StateContext>) -> ETakedownActionType {
    let param: StateResultCName = stateContext.GetPermanentCNameParameter(n"ETakedownActionType");
    let enumName: CName = param.value;
    return IntEnum(Cast(EnumValueFromName(n"ETakedownActionType", enumName)));
  }

  public final const func IsVehicleBlockingCombat(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle) {
      return false;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Combat) {
      return false;
    };
    return !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToCombatVehicle);
  }

  public final const func IsEmptyHandsForced(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneAimForced) && !scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.SceneSafeForced) && (stateContext.GetBoolParameter(n"ForceEmptyHands", true) || stateContext.GetBoolParameter(n"ForceEmptyHandsByZone", true) || Cast(scriptInterface.GetQuestsSystem().GetFact(n"ForceEmptyHands")) || stateContext.GetBoolParameter(n"InVehicle", true) || this.IsNoCombatActionsForced(scriptInterface));
  }

  protected final const func CheckGenericEquipItemConditions(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.CanEquipItem(stateContext) && scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.HighLevel) < EnumInt(gamePSMHighLevel.SceneTier5) && !stateContext.IsStateActive(n"Locomotion", n"vault") && !stateContext.GetBoolParameter(n"UninteruptibleReload", true) && (!this.IsEmptyHandsForced(stateContext, scriptInterface) || this.HasActiveConsumable(scriptInterface)) && !this.IsInItemWheelState(stateContext) && NotEquals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"entering") && NotEquals(stateContext.GetStateMachineCurrentState(n"Vehicle"), n"switchSeats") && !this.IsVehicleBlockingCombat(scriptInterface);
  }

  protected final const func IsCarryingBody(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
  }

  protected final const func IsExaminingDevice(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsUIZoomDevice);
  }

  protected final const func HasActiveConsumable(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let consumable: ItemID = EquipmentSystem.GetData(scriptInterface.executionOwner).GetActiveConsumable();
    return ItemID.IsValid(consumable);
  }

  public final const func IsInItemWheelState(const stateContext: ref<StateContext>) -> Bool {
    let quickSlotsStateName: CName = stateContext.GetStateMachineCurrentState(n"QuickSlots");
    return Equals(quickSlotsStateName, n"WeaponWheel") || Equals(quickSlotsStateName, n"VehicleWheel") || Equals(quickSlotsStateName, n"InteractionWheel");
  }

  public final const func IsInEmptyHandsState(const stateContext: ref<StateContext>) -> Bool {
    let upperBodyStateName: CName = stateContext.GetStateMachineCurrentState(n"UpperBody");
    return Equals(upperBodyStateName, n"emptyHands") || Equals(upperBodyStateName, n"forceEmptyHands") || Equals(upperBodyStateName, n"forceSafe");
  }

  public final const func IsInUpperBodyState(const stateContext: ref<StateContext>, upperBodyStateName: CName) -> Bool {
    let upperBodyState: CName = stateContext.GetStateMachineCurrentState(n"UpperBody");
    return Equals(upperBodyState, upperBodyStateName);
  }

  public final const func IsInHighLevelState(const stateContext: ref<StateContext>, highLevelStateName: CName) -> Bool {
    let highLevelState: CName = stateContext.GetStateMachineCurrentState(n"HighLevel");
    return Equals(highLevelState, highLevelStateName);
  }

  public final const func IsInWeaponReloadState(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload);
  }

  public final const func IsWeaponStateBlockingAiming(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.Reload);
  }

  public final static func GetBlackboardIntVariable(const executionOwner: ref<GameObject>, id: BlackboardID_Int) -> Int32 {
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(executionOwner.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(executionOwner.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  public final const func IsInVisionModeActiveState(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus);
  }

  public final const func IsInTakedownState(const stateContext: ref<StateContext>) -> Bool {
    return stateContext.IsStateMachineActive(n"LocomotionTakedown");
  }

  public final const func IsInLocomotionState(const stateContext: ref<StateContext>, locomotionStateName: CName) -> Bool {
    let locomotionState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    return Equals(locomotionState, locomotionStateName);
  }

  public final const func GetLocomotionState(const stateContext: ref<StateContext>) -> CName {
    let locomotionState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    return locomotionState;
  }

  public final const func IsInVehicleState(const stateContext: ref<StateContext>, vehicleStateName: CName) -> Bool {
    let vehicleState: CName = stateContext.GetStateMachineCurrentState(n"Vehicle");
    return Equals(vehicleState, vehicleStateName);
  }

  public final const func IsInInputContextState(const stateContext: ref<StateContext>, inputContextStateName: CName) -> Bool {
    let inputContextState: CName = stateContext.GetStateMachineCurrentState(n"InputContext");
    return Equals(inputContextState, inputContextStateName);
  }

  public final const func IsInLadderState(const stateContext: ref<StateContext>) -> Bool {
    let ladderState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    return Equals(ladderState, n"ladder") || Equals(ladderState, n"ladderSprint") || Equals(ladderState, n"ladderSlide") || Equals(ladderState, n"ladderCrouch") || Equals(ladderState, n"ladderJump");
  }

  public final const func IsInMeleeState(const stateContext: ref<StateContext>, meleeStateName: CName) -> Bool {
    let identifier: StateMachineIdentifier;
    identifier.definitionName = n"Melee";
    identifier.referenceName = n"WeaponRight";
    let meleeState: CName = stateContext.GetStateMachineCurrentStateWithIdentifier(identifier);
    return Equals(meleeState, meleeStateName);
  }

  protected final const func IsInSlidingState(const stateContext: ref<StateContext>) -> Bool {
    let slidingState: CName = stateContext.GetStateMachineCurrentState(n"Locomotion");
    return Equals(slidingState, n"slide") || Equals(slidingState, n"slideAfterFall") || Equals(slidingState, n"slideFall");
  }

  public final const func CompareSMState(const smName: CName, const smState: CName, const stateContext: ref<StateContext>) -> Bool {
    let smCurrentState: CName = stateContext.GetStateMachineCurrentState(smName);
    return Equals(smCurrentState, smState);
  }

  public final const func CompareSMStateWithIden(const definitionName: CName, const referenceName: CName, const smState: CName, const stateContext: ref<StateContext>) -> Bool {
    let identifier: StateMachineIdentifier;
    identifier.definitionName = definitionName;
    identifier.referenceName = referenceName;
    let smCurrentState: CName = stateContext.GetStateMachineCurrentStateWithIdentifier(identifier);
    return Equals(smCurrentState, smState);
  }

  public final const func CompareSMState(const smName: CName, const smState: array<CName>, const stateContext: ref<StateContext>) -> Bool {
    let smCurrentState: CName = stateContext.GetStateMachineCurrentState(smName);
    let i: Int32 = 0;
    while i < ArraySize(smState) {
      if Equals(smCurrentState, smState[i]) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  protected final const func CheckActiveConsumable(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let ts: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let itemValid: Bool = ItemID.IsValid(EquipmentSystem.GetData(scriptInterface.owner).GetActiveConsumable());
    let inInventory: Bool = ts.GetItemQuantity(scriptInterface.owner, EquipmentSystem.GetData(scriptInterface.owner).GetActiveConsumable()) > 0;
    return itemValid && inInventory;
  }

  protected final const func GetItemInRightHandSlot(const scriptInterface: ref<StateGameScriptInterface>) -> ref<ItemObject> {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    return transactionSystem.GetItemInSlot(scriptInterface.owner, t"AttachmentSlots.WeaponRight");
  }

  protected final const func GetItemInLeftHandSlot(const scriptInterface: ref<StateGameScriptInterface>) -> ref<ItemObject> {
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    return transactionSystem.GetItemInSlot(scriptInterface.owner, t"AttachmentSlots.WeaponLeft");
  }

  protected final const func IsRightHandInEquippedState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"RightHand";
    return stateContext.IsStateActiveWithIdentifier(smIden, n"equipped");
  }

  protected final const func IsRightHandInUnequippedState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"RightHand";
    let state: CName = stateContext.GetStateMachineCurrentStateWithIdentifier(smIden);
    return Equals(state, n"") || Equals(state, n"unequipped");
  }

  protected final const func IsRightHandChangingEquipState(const stateContext: ref<StateContext>) -> Bool {
    return this.IsRightHandInUnequippingState(stateContext) || this.IsRightHandInEquippingState(stateContext);
  }

  protected final const func IsRightHandInUnequippingState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"RightHand";
    return stateContext.IsStateActiveWithIdentifier(smIden, n"unequipCycle");
  }

  protected final const func IsRightHandInEquippingState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"RightHand";
    return stateContext.IsStateActiveWithIdentifier(smIden, n"equipCycle");
  }

  protected final const func IsLeftHandInEquippedState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"LeftHand";
    return stateContext.IsStateActiveWithIdentifier(smIden, n"equipped");
  }

  protected final const func IsLeftHandInUnequippedState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"LeftHand";
    let state: CName = stateContext.GetStateMachineCurrentStateWithIdentifier(smIden);
    return Equals(state, n"") || Equals(state, n"unequipped");
  }

  protected final const func IsLeftHandInUnequippingState(const stateContext: ref<StateContext>) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = n"LeftHand";
    return stateContext.IsStateActiveWithIdentifier(smIden, n"unequipCycle");
  }

  protected final const func GetReferenceNameFromEquipmentSide(side: EEquipmentSide) -> CName {
    switch side {
      case EEquipmentSide.Left:
        return n"LeftHand";
      case EEquipmentSide.Right:
        return n"RightHand";
      default:
        return n"error DT01";
    };
  }

  protected final const func GetStateNameFromEquipmentState(equipmentState: EEquipmentState) -> CName {
    switch equipmentState {
      case EEquipmentState.Unequipped:
        return n"unequipped";
      case EEquipmentState.Equipped:
        return n"equipped";
      case EEquipmentState.Equipping:
        return n"equipCycle";
      case EEquipmentState.Unequipping:
        return n"unequipCycle";
      case EEquipmentState.FirstEquip:
        return n"firstEquip";
      default:
        return n"error DT02";
    };
  }

  protected final const func CheckEquipmentStateMachineState(const stateContext: ref<StateContext>, SMSide: EEquipmentSide, compareToState: EEquipmentState) -> Bool {
    let smIden: StateMachineIdentifier;
    smIden.definitionName = n"Equipment";
    smIden.referenceName = this.GetReferenceNameFromEquipmentSide(SMSide);
    let smMissing: Bool = stateContext.IsStateMachineActiveWithIdentifier(smIden);
    return stateContext.IsStateActiveWithIdentifier(smIden, this.GetStateNameFromEquipmentState(compareToState)) || Equals(compareToState, EEquipmentState.Unequipped) && smMissing;
  }

  protected final const func IsInFirstEquip(const stateContext: ref<StateContext>) -> Bool {
    let result: StateResultBool = stateContext.GetConditionBoolParameter(n"firstEquip");
    return result.valid && result.value;
  }

  protected final const func AreChoiceHubsActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let interactonsBlackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
    let interactionData: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
    let data: DialogChoiceHubs = FromVariant(interactonsBlackboard.GetVariant(interactionData.DialogChoiceHubs));
    return ArraySize(data.choiceHubs) > 0;
  }

  protected final const func GetLootData(const scriptInterface: ref<StateGameScriptInterface>) -> LootData {
    let interactonsBlackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
    let interactionData: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
    let data: LootData = FromVariant(interactonsBlackboard.GetVariant(interactionData.LootData));
    return data;
  }

  protected final const func IsLootDataActive(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let data: LootData = this.GetLootData(scriptInterface);
    return data.isActive;
  }

  protected final const func ItemsInLootData(const scriptInterface: ref<StateGameScriptInterface>) -> Int32 {
    let data: LootData = this.GetLootData(scriptInterface);
    let items: array<ItemID> = data.itemIDs;
    return ArraySize(items);
  }

  protected final const func CheckConsumableLootDataCondition(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsLootDataActive(scriptInterface) {
      return this.ItemsInLootData(scriptInterface) <= 1;
    };
    return true;
  }

  protected final const func SetItemIDWrapperPermanentParameter(stateContext: ref<StateContext>, parameterName: CName, item: ItemID) -> Void {
    let wrapper: ref<ItemIdWrapper> = new ItemIdWrapper();
    wrapper.itemID = item;
    stateContext.SetPermanentScriptableParameter(parameterName, wrapper, true);
  }

  protected final const func GetItemIDFromWrapperPermanentParameter(stateContext: ref<StateContext>, parameterName: CName) -> ItemID {
    let wrapper: ref<ItemIdWrapper> = stateContext.GetPermanentScriptableParameter(parameterName) as ItemIdWrapper;
    if IsDefined(wrapper) {
      return wrapper.itemID;
    };
    return ItemID.undefined();
  }

  protected final const func ClearItemIDWrapperPermanentParameter(stateContext: ref<StateContext>, parameterName: CName) -> Void {
    stateContext.RemovePermanentScriptableParameter(parameterName);
  }

  protected final const func IsPlayerInAnyMenu(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let blackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
    let uiSystemBB: ref<UI_SystemDef> = GetAllBlackboardDefs().UI_System;
    return blackboard.GetBool(uiSystemBB.IsInMenu);
  }

  protected final const func SendDataTrackingRequest(scriptInterface: ref<StateGameScriptInterface>, telemetryData: ETelemetryData, modifyValue: Int32) -> Void {
    let request: ref<ModifyTelemetryVariable> = new ModifyTelemetryVariable();
    request.dataTrackingFact = telemetryData;
    request.value = modifyValue;
    scriptInterface.GetScriptableSystem(n"DataTrackingSystem").QueueRequest(request);
  }

  protected final func RequestVehicleCameraPerspective(scriptInterface: ref<StateGameScriptInterface>, requestedCameraPerspective: vehicleCameraPerspective) -> Void {
    let camEvent: ref<vehicleRequestCameraPerspectiveEvent> = new vehicleRequestCameraPerspectiveEvent();
    camEvent.cameraPerspective = requestedCameraPerspective;
    scriptInterface.executionOwner.QueueEvent(camEvent);
  }

  protected final func SetVehicleCameraSceneMode(scriptInterface: ref<StateGameScriptInterface>, sceneMode: Bool) -> Void {
    let camEvent: ref<vehicleCameraSceneEnableEvent> = new vehicleCameraSceneEnableEvent();
    camEvent.scene = sceneMode;
    scriptInterface.executionOwner.QueueEvent(camEvent);
  }

  protected final const func IsInSafeZone(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return Equals(IntEnum(scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Zones)), gamePSMZones.Safe);
  }

  protected final func TutorialSetFact(scriptInterface: ref<StateGameScriptInterface>, factName: CName) -> Void {
    let questSystem: ref<QuestsSystem> = scriptInterface.GetQuestsSystem();
    if questSystem.GetFact(factName) == 0 && questSystem.GetFact(n"disable_tutorials") == 0 {
      questSystem.SetFact(factName, 1);
    };
  }

  protected final const func TutorialAddFact(scriptInterface: ref<StateGameScriptInterface>, factName: CName, add: Int32) -> Void {
    let val: Int32;
    let questSystem: ref<QuestsSystem> = scriptInterface.GetQuestsSystem();
    if questSystem.GetFact(n"disable_tutorials") == 0 {
      val = questSystem.GetFact(factName) + add;
      questSystem.SetFact(factName, val);
    };
  }

  protected final const func IsQuickHackPanelOpened(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let bb: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    return bb.GetBool(GetAllBlackboardDefs().UI_QuickSlotsData.quickhackPanelOpen);
  }

  protected final const func IsRadialWheelOpen(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let bb: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_QuickSlotsData);
    return bb.GetBool(GetAllBlackboardDefs().UI_QuickSlotsData.UIRadialContextRequest);
  }

  protected final const func IsTimeDilationActive(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>, timeDilationReason: CName) -> Bool {
    let timeSystem: ref<TimeSystem> = scriptInterface.GetTimeSystem();
    return timeSystem.IsTimeDilationActive(timeDilationReason);
  }

  protected final const func ThreatsOnPlayerThreatList(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return DefaultTransition.GetPlayerPuppet(scriptInterface).GetTargetTrackerComponent().HasHostileThreat(false);
  }

  protected final const func IsPlayerInSecuritySystem(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let overlappedZones: array<PersistentID> = DefaultTransition.GetPlayerPuppet(scriptInterface).GetOverlappedSecurityZones();
    return ArraySize(overlappedZones) > 0;
  }

  protected final const func IsInStealthLocomotion(const stateContext: ref<StateContext>) -> Bool {
    return this.CompareSMState(n"Locomotion", n"crouch", stateContext);
  }

  protected final const func ShowInputHint(const scriptInterface: ref<StateGameScriptInterface>, actionName: CName, source: CName, label: String, opt holdIndicationType: inkInputHintHoldIndicationType, opt enableHoldAnimation: Bool) -> Void {
    let data: InputHintData;
    let evt: ref<UpdateInputHintEvent>;
    if this.IsDisplayingInputHintBlocked(scriptInterface, actionName) {
      return;
    };
    data.action = actionName;
    data.source = source;
    data.localizedLabel = label;
    data.holdIndicationType = holdIndicationType;
    data.enableHoldAnimation = enableHoldAnimation;
    evt = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = true;
    evt.targetHintContainer = n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
  }

  protected final const func RemoveInputHint(const scriptInterface: ref<StateGameScriptInterface>, actionName: CName, source: CName) -> Void {
    let data: InputHintData;
    data.action = actionName;
    data.source = source;
    let evt: ref<UpdateInputHintEvent> = new UpdateInputHintEvent();
    evt.data = data;
    evt.show = false;
    evt.targetHintContainer = n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
  }

  protected final const func RemoveInputHintsBySource(const scriptInterface: ref<StateGameScriptInterface>, source: CName) -> Void {
    let evt: ref<DeleteInputHintBySourceEvent> = new DeleteInputHintBySourceEvent();
    evt.source = source;
    evt.targetHintContainer = n"GameplayInputHelper";
    scriptInterface.GetUISystem().QueueEvent(evt);
  }

  protected final const func IsDisplayingInputHintBlocked(const scriptInterface: ref<StateGameScriptInterface>, actionName: CName) -> Bool {
    switch actionName {
      case n"RangedAttack":
        return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoCombat") || !this.HasAnyValidWeaponAvailable(scriptInterface);
      case n"Jump":
        return StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"GameplayRestriction.NoJump");
      case n"Exit":
        return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"VehicleScene");
      case n"ToggleVehCamera":
        return this.IsVehicleCameraChangeBlocked(scriptInterface);
      case n"WeaponWheel":
        return this.IsNoCombatActionsForced(scriptInterface) || this.IsVehicleExitCombatModeBlocked(scriptInterface);
      case n"Dodge":
        return this.IsInTier2Locomotion(scriptInterface) || StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"PhoneCall");
      case n"SwitchItem":
        return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoCombat") || !EquipmentSystem.HasItemInArea(scriptInterface.executionOwner, gamedataEquipmentArea.Weapon);
      case n"DropCarriedObject":
        return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"BodyCarryingNoDrop");
      case n"QuickMelee":
        return StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"NoQuickMelee");
      default:
        return false;
    };
  }

  protected final const func GetCancelChargeButtonInput(const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.IsActionJustPressed(n"CancelChargingCG");
  }

  protected final const func ProcessCombatGadgetActionInputCaching(const scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    if scriptInterface.IsActionJustHeld(n"UseCombatGadget") && !stateContext.GetBoolParameter(n"cgCached", true) {
      stateContext.SetPermanentBoolParameter(n"cgCached", true, true);
    } else {
      if stateContext.GetBoolParameter(n"cgCached", true) && scriptInterface.GetActionValue(n"UseCombatGadget") == 0.00 {
        stateContext.RemovePermanentBoolParameter(n"cgCached");
      };
    };
  }

  protected final const func TriggerNoiseStim(owner: wref<GameObject>, takedownActionType: ETakedownActionType) -> Void {
    let broadcaster: ref<StimBroadcasterComponent> = owner.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerNoiseStim(owner, takedownActionType);
    };
  }

  protected final func ActivateDamageProjection(newState: Bool, weapon: ref<WeaponObject>, scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let blackboard: ref<IBlackboard>;
    let game: GameInstance = scriptInterface.executionOwner.GetGame();
    let damageSystem: ref<DamageSystem> = GameInstance.GetDamageSystem(game);
    damageSystem.ClearPreviewTargetStruct();
    if IsDefined(weapon) {
      damageSystem.SetPreviewLock(!newState);
      weapon.GetCurrentAttack().SetDamageProjectionActive(newState);
      stateContext.SetPermanentBoolParameter(n"DamagePreviewActive", true, true);
    };
    if !newState {
      GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_NameplateData);
      if IsDefined(blackboard) {
        blackboard.SetInt(GetAllBlackboardDefs().UI_NameplateData.DamageProjection, 0, true);
      };
      damageSystem.ClearPreviewTargetStruct();
      stateContext.RemovePermanentBoolParameter(n"DamagePreviewActive");
    };
  }

  protected final func IsNameplateVisible(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let blackboard: ref<IBlackboard> = scriptInterface.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_NameplateData);
    return blackboard.GetBool(GetAllBlackboardDefs().UI_NameplateData.IsVisible);
  }

  protected final func HandleDamagePreview(weapon: ref<WeaponObject>, scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>) -> Void {
    let inStealth: Bool = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Combat) == EnumInt(gamePSMCombat.Stealth);
    if inStealth && this.CanWeaponSilentKill(weapon, scriptInterface) && this.IsNameplateVisible(scriptInterface) && !stateContext.GetBoolParameter(n"DamagePreviewActive", true) {
      this.ActivateDamageProjection(true, weapon, scriptInterface, stateContext);
    } else {
      if stateContext.GetBoolParameter(n"DamagePreviewActive", true) && (!inStealth || !this.IsNameplateVisible(scriptInterface) || !this.CanWeaponSilentKill(weapon, scriptInterface)) {
        this.ActivateDamageProjection(false, weapon, scriptInterface, stateContext);
      };
    };
  }

  protected final const func CanWeaponSilentKill(weapon: ref<WeaponObject>, scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return scriptInterface.GetStatsSystem().GetStatValue(Cast(weapon.GetEntityID()), gamedataStatType.CanSilentKill) > 0.00;
  }

  protected final const func UsingJohnnyReplacer(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return (scriptInterface.executionOwner as gamePuppetBase).GetRecordID() == t"Character.johnny_replacer";
  }

  protected final const func IsPlayingAsReplacer(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return (scriptInterface.executionOwner as gamePuppetBase).GetRecordID() != t"Character.Player_Puppet_Base";
  }

  protected final const func IsFastForwardByLine(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    return GameplaySettingsSystem.GetIsFastForwardByLine(scriptInterface.executionOwner);
  }

  protected final const func CheckIsFastForwardByLine(scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let gss: ref<GameplaySettingsSystem> = GameInstance.GetScriptableSystemsContainer(scriptInterface.owner.GetGame()).Get(n"GameplaySettingsSystem") as GameplaySettingsSystem;
    return gss.GetIsFastForwardByLine();
  }

  protected final const func GetFFParamsForCrouch(scriptInterface: ref<StateGameScriptInterface>) -> CName {
    let param: CName = this.CheckIsFastForwardByLine(scriptInterface) ? n"FFhintActive" : n"FFHoldLock";
    return param;
  }

  protected final func UpdateCameraContext(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let consumableStartupFirstFrame: Bool;
    let item: ItemID;
    let param: StateResultCName;
    let sceneTier: GameplayTier = this.GetCurrentTier(stateContext);
    if Equals(sceneTier, GameplayTier.Tier4_FPPCinematic) {
      this.UpdateCameraParams(n"Tier4Scene", scriptInterface);
      return;
    };
    if Equals(sceneTier, GameplayTier.Tier3_LimitedGameplay) {
      this.UpdateTier3CameraParams(stateContext, scriptInterface);
      return;
    };
    if stateContext.IsStateMachineActive(n"Vehicle") {
      param = stateContext.GetPermanentCNameParameter(n"VehicleCameraParams");
      if param.valid && NotEquals(param.value, n"") {
        this.UpdateCameraParams(param.value, scriptInterface);
        return;
      };
    };
    consumableStartupFirstFrame = stateContext.GetBoolParameter(n"CameraContext_ConsumableStartup", false);
    if consumableStartupFirstFrame || stateContext.IsStateActive(n"Consumable", n"consumableUse") || stateContext.IsStateActive(n"Consumable", n"consumableStartup") {
      item = DefaultTransition.GetActiveLeftHandItem(scriptInterface).GetItemID();
      if ItemID.IsValid(item) {
        this.UpdateCameraParams(n"UseConsumable", scriptInterface);
        return;
      };
    };
    if stateContext.GetBoolParameter(n"setLadderEnterClimbCameraContext", true) {
      this.UpdateCameraParams(n"LadderEnterClimb", scriptInterface);
      return;
    };
    if stateContext.GetBoolParameter(n"setLadderClimbCameraContext", true) {
      this.UpdateCameraParams(n"LadderClimb", scriptInterface);
      return;
    };
    if stateContext.GetBoolParameter(n"setLadderCameraContext", true) {
      this.UpdateCameraParams(n"Ladder", scriptInterface);
      return;
    };
    if stateContext.GetBoolParameter(n"setBodyCarryContext", true) {
      this.UpdateCameraParams(n"BodyCarry", scriptInterface);
      return;
    };
    if stateContext.GetBoolParameter(n"setBodyPickUpContext", true) {
      this.UpdateCameraParams(n"BodyPickUp", scriptInterface);
      return;
    };
    if stateContext.GetBoolParameter(n"setBodyCarryFriendlyContext", true) {
      this.UpdateCameraParams(n"BodyCarryFriendly", scriptInterface);
      return;
    };
    if Equals(sceneTier, GameplayTier.Tier2_StagedGameplay) && StatusEffectSystem.ObjectHasStatusEffectWithTag(scriptInterface.executionOwner, n"SpaceShuttleInterior") {
      this.UpdateCameraParams(n"SpaceShuttleInterior", scriptInterface);
      return;
    };
    param = stateContext.GetPermanentCNameParameter(n"LocomotionCameraParams");
    if param.valid {
      this.UpdateCameraParams(param.value, scriptInterface);
    };
  }

  private final func UpdateTier3CameraParams(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let sceneTier3Data: ref<SceneTier3Data> = this.GetCurrentSceneTierData(stateContext) as SceneTier3Data;
    let cameraSettings: Tier3CameraSettings = sceneTier3Data.cameraSettings;
    let setCameraParamsEvent: ref<SetCameraParamsWithOverridesEvent> = new SetCameraParamsWithOverridesEvent();
    setCameraParamsEvent.paramsName = n"Tier3Scene";
    setCameraParamsEvent.yawMaxLeft = cameraSettings.yawLeftLimit;
    setCameraParamsEvent.yawMaxRight = -cameraSettings.yawRightLimit;
    setCameraParamsEvent.pitchMax = cameraSettings.pitchTopLimit;
    setCameraParamsEvent.pitchMin = -cameraSettings.pitchBottomLimit;
    setCameraParamsEvent.sensitivityMultX = cameraSettings.yawSpeedMultiplier;
    setCameraParamsEvent.sensitivityMultY = cameraSettings.pitchSpeedMultiplier;
    scriptInterface.executionOwner.QueueEvent(setCameraParamsEvent);
  }

  protected final func UpdateCameraParams(cameraParams: CName, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let setCameraParamsEvent: ref<SetCameraParamsEvent> = new SetCameraParamsEvent();
    setCameraParamsEvent.paramsName = cameraParams;
    scriptInterface.executionOwner.QueueEvent(setCameraParamsEvent);
  }

  protected final static func UpdateAimAssist(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let hasMeleeEquipped: Bool;
    let inLefthandCW: Bool;
    let inMeleeAssistState: Bool;
    let inSprint: Bool;
    let leftHandCWState: Int32;
    let meleeState: Int32;
    let playerPuppet: ref<PlayerPuppet> = scriptInterface.executionOwner as PlayerPuppet;
    if !IsDefined(playerPuppet) {
      return;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision) == EnumInt(gamePSMVision.Focus) {
      playerPuppet.ApplyAimAssistSettings("Settings_Scanning");
      return;
    };
    if scriptInterface.executionOwner.GetTakeOverControlSystem().IsDeviceControlled() {
      playerPuppet.ApplyAimAssistSettings("Settings_Default");
      return;
    };
    leftHandCWState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware);
    if leftHandCWState == EnumInt(gamePSMLeftHandCyberware.Charge) {
      playerPuppet.ApplyAimAssistSettings("Settings_LeftHandCyberwareCharge");
      return;
    };
    inLefthandCW = stateContext.IsStateMachineActive(n"LeftHandCyberware") && leftHandCWState != EnumInt(gamePSMLeftHandCyberware.Unequip) && leftHandCWState != EnumInt(gamePSMLeftHandCyberware.StartUnequip);
    if inLefthandCW {
      playerPuppet.ApplyAimAssistSettings("Settings_LeftHandCyberware");
      return;
    };
    hasMeleeEquipped = DefaultTransition.HasMeleeWeaponEquipped(scriptInterface);
    inSprint = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion) == EnumInt(gamePSMLocomotionStates.Sprint);
    if !inSprint && hasMeleeEquipped {
      meleeState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon);
      inMeleeAssistState = meleeState == EnumInt(gamePSMMeleeWeapon.Block) || meleeState == EnumInt(gamePSMMeleeWeapon.Deflect) || meleeState == EnumInt(gamePSMMeleeWeapon.DeflectAttack);
      playerPuppet.ApplyAimAssistSettings(inMeleeAssistState ? "Settings_MeleeCombat" : "Settings_MeleeCombatIdle");
      return;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.UpperBody) == EnumInt(gamePSMUpperBodyStates.Aim) {
      playerPuppet.ApplyAimAssistSettings(scriptInterface.HasStatFlag(gamedataStatType.CanWeaponSnapToLimbs) ? "Settings_AimingLimbCyber" : "Settings_Aiming");
      return;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Weapon) == EnumInt(gamePSMRangedWeaponStates.QuickMelee) {
      playerPuppet.ApplyAimAssistSettings("Settings_QuickMelee");
      return;
    };
    if scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vehicle) == EnumInt(gamePSMVehicle.Combat) {
      playerPuppet.ApplyAimAssistSettings("Settings_VehicleCombat");
      return;
    };
    if inSprint {
      playerPuppet.ApplyAimAssistSettings("Settings_Sprinting");
      return;
    };
    playerPuppet.ApplyAimAssistSettings(scriptInterface.HasStatFlag(gamedataStatType.CanWeaponSnapToLimbs) ? "Settings_LimbCyber" : "Settings_Default");
  }

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, value: Float) -> Void;

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void;

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void;

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void;

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void;
}

public class DefaultTransitionStatListener extends ScriptStatsListener {

  public let m_transitionOwner: wref<DefaultTransition>;

  public func OnStatChanged(ownerID: StatsObjectID, statType: gamedataStatType, diff: Float, total: Float) -> Void {
    this.m_transitionOwner.OnStatChanged(ownerID, statType, diff, total);
  }
}

public class DefaultTransitionStatusEffectListener extends ScriptStatusEffectListener {

  public let m_transitionOwner: wref<DefaultTransition>;

  public func OnStatusEffectApplied(statusEffect: wref<StatusEffect_Record>) -> Void {
    this.m_transitionOwner.OnStatusEffectApplied(statusEffect);
  }

  public func OnStatusEffectRemoved(statusEffect: wref<StatusEffect_Record>) -> Void {
    this.m_transitionOwner.OnStatusEffectRemoved(statusEffect);
  }
}

public class DefaultTransitionAttachmentSlotsCallback extends AttachmentSlotsScriptCallback {

  public let m_transitionOwner: wref<DefaultTransition>;

  public func OnItemEquipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_transitionOwner.OnItemEquipped(slot, item);
  }

  public func OnItemUnequipped(slot: TweakDBID, item: ItemID) -> Void {
    this.m_transitionOwner.OnItemUnequipped(slot, item);
  }
}
