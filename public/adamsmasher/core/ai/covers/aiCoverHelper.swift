
public class AICoverHelper extends IScriptable {

  public final static func CoverExposureMethodNameToEnum(exposureMethodName: CName) -> AICoverExposureMethod {
    switch exposureMethodName {
      case n"Standing_Step_Left":
        return AICoverExposureMethod.Standing_Step_Left;
      case n"Standing_Step_Right":
        return AICoverExposureMethod.Standing_Step_Right;
      case n"Standing_Lean_Left":
        return AICoverExposureMethod.Standing_Lean_Left;
      case n"Standing_Lean_Right":
        return AICoverExposureMethod.Standing_Lean_Right;
      case n"Standing_Blind_Left":
        return AICoverExposureMethod.Standing_Blind_Left;
      case n"Standing_Blind_Right":
        return AICoverExposureMethod.Standing_Blind_Right;
      case n"Crouching_Step_Left":
        return AICoverExposureMethod.Crouching_Step_Left;
      case n"Crouching_Step_Right":
        return AICoverExposureMethod.Crouching_Step_Right;
      case n"Crouching_Lean_Left":
        return AICoverExposureMethod.Crouching_Lean_Left;
      case n"Crouching_Lean_Right":
        return AICoverExposureMethod.Crouching_Lean_Right;
      case n"Crouching_Blind_Left":
        return AICoverExposureMethod.Crouching_Blind_Left;
      case n"Crouching_Blind_Right":
        return AICoverExposureMethod.Crouching_Blind_Right;
      case n"Crouching_Blind_Top":
        return AICoverExposureMethod.Crouching_Blind_Top;
      case n"Lean_Over":
        return AICoverExposureMethod.Lean_Over;
      case n"Stand_Up":
        return AICoverExposureMethod.Stand_Up;
      default:
    };
    return AICoverExposureMethod.Count;
  }

  public final static func CoverHeightNameToEnum(coverHeight: CName) -> gameCoverHeight {
    switch coverHeight {
      case n"Low":
        return gameCoverHeight.Low;
      case n"High":
        return gameCoverHeight.High;
      case n"Invalid":
        return gameCoverHeight.Invalid;
      default:
    };
    return gameCoverHeight.Invalid;
  }

  public final static func CoverActionNameToEnum(actionName: CName) -> EAICoverAction {
    switch actionName {
      case n"StepOut":
        return EAICoverAction.StepOut;
      case n"LeanOut":
        return EAICoverAction.LeanOut;
      case n"StepUp":
        return EAICoverAction.StepUp;
      case n"LeanOver":
        return EAICoverAction.LeanOver;
      case n"Undefined":
        return EAICoverAction.Undefined;
      default:
    };
    return EAICoverAction.Undefined;
  }

  public final static func GetCoverBlackboard(puppet: ref<ScriptedPuppet>) -> ref<IBlackboard> {
    return puppet.GetAIControllerComponent().GetCoverBlackboard();
  }

  public final static func GetCoverManager(puppet: ref<ScriptedPuppet>) -> ref<CoverManager> {
    return GameInstance.GetCoverManager(puppet.GetGame());
  }

  public final static func GetCurrentCoverStance(puppet: ref<ScriptedPuppet>) -> CName {
    return AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.currentCoverStance);
  }

  public final static func GetCurrentCoverStance(puppet: ref<ScriptedPuppet>, out coverStance: gameCoverHeight) -> Void {
    let coverStanceName: CName = AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.currentCoverStance);
    coverStance = AICoverHelper.CoverHeightNameToEnum(coverStanceName);
  }

  public final static func SetCurrentCoverStance(puppet: ref<ScriptedPuppet>, value: gameCoverHeight) -> Void {
    AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.currentCoverStance, EnumValueToName(n"gameCoverHeight", Cast(EnumInt(value))));
  }

  public final static func SetCurrentCoverStance(puppet: ref<ScriptedPuppet>, value: CName) -> Void {
    AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.currentCoverStance, value);
  }

  public final static func GetDesiredCoverStance(puppet: ref<ScriptedPuppet>) -> CName {
    return AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.desiredCoverStance);
  }

  public final static func GetDesiredCoverStance(puppet: ref<ScriptedPuppet>, out coverStance: gameCoverHeight) -> Void {
    let coverStanceName: CName = AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.desiredCoverStance);
    coverStance = AICoverHelper.CoverHeightNameToEnum(coverStanceName);
  }

  public final static func SetDesiredCoverStance(puppet: ref<ScriptedPuppet>, value: CName) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.desiredCoverStance, value);
  }

  public final static func SetDesiredCoverStance(puppet: ref<ScriptedPuppet>, value: gameCoverHeight) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.desiredCoverStance, EnumValueToName(n"gameCoverHeight", Cast(EnumInt(value))));
  }

  public final static func GetCoverExposureMethod(puppet: ref<ScriptedPuppet>) -> CName {
    return AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.exposureMethod);
  }

  public final static func GetFallbackCoverExposureMethod(puppet: ref<ScriptedPuppet>, out method: AICoverExposureMethod) -> Void {
    let methodName: CName = AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.fallbackExposureMethod);
    method = IntEnum(Cast(EnumValueFromName(n"AICoverExposureMethod", methodName)));
  }

  public final static func GetCoverExposureMethod(puppet: ref<ScriptedPuppet>, out method: AICoverExposureMethod) -> Void {
    let methodName: CName = AICoverHelper.GetCoverBlackboard(puppet).GetName(GetAllBlackboardDefs().AICover.exposureMethod);
    method = IntEnum(Cast(EnumValueFromName(n"AICoverExposureMethod", methodName)));
  }

  public final static func HasAnyCoverLastAvailableExposureMethod(puppet: ref<ScriptedPuppet>) -> Bool {
    return AICoverHelper.GetCoverBlackboard(puppet).GetUint(GetAllBlackboardDefs().AICover.lastAvailableMethods) != 0u;
  }

  public final static func GetRandomCoverLastAvailableExposureMethod(puppet: ref<ScriptedPuppet>, out method: AICoverExposureMethod) -> Void {
    let i: Int32;
    let randomOffset: Uint32;
    let tmp: Uint32;
    let lastAvailableMethods: Uint32 = AICoverHelper.GetCoverBlackboard(puppet).GetUint(GetAllBlackboardDefs().AICover.lastAvailableMethods);
    method = AICoverExposureMethod.Count;
    if lastAvailableMethods != 0u {
      randomOffset = Cast(RandRange(0, EnumInt(AICoverExposureMethod.Count)));
      i = 0;
      while i < EnumInt(AICoverExposureMethod.Count) {
        tmp = (Cast(i) + randomOffset) % EnumInt(AICoverExposureMethod.Count);
        if Cast(lastAvailableMethods & Cast(PowF(2.00, Cast(tmp)))) {
          method = IntEnum(tmp);
        };
        i += 1;
      };
    };
  }

  public final static func SetCoverExposureMethod(puppet: ref<ScriptedPuppet>, value: CName) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.exposureMethod, value);
  }

  public final static func SetCoverExposureMethod(puppet: ref<ScriptedPuppet>, value: AICoverExposureMethod) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.exposureMethod, EnumValueToName(n"AICoverExposureMethod", Cast(EnumInt(value))));
  }

  public final static func SetFallbackCoverExposureMethod(puppet: ref<ScriptedPuppet>, value: AICoverExposureMethod) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetName(GetAllBlackboardDefs().AICover.fallbackExposureMethod, EnumValueToName(n"AICoverExposureMethod", Cast(EnumInt(value))));
  }

  public final static func SetCoverLastAvailableExposureMethod(puppet: ref<ScriptedPuppet>, opt exposureMethods: array<AICoverExposureMethod>) -> Void {
    let methodsMask: Uint32 = 0u;
    let i: Int32 = 0;
    while i < ArraySize(exposureMethods) {
      methodsMask = methodsMask | Cast(PowF(2.00, Cast(EnumInt(exposureMethods[i]))));
      i += 1;
    };
    methodsMask = methodsMask & ~Cast(PowF(2.00, Cast(EnumInt(AICoverExposureMethod.Standing_Step_Left))));
    methodsMask = methodsMask & ~Cast(PowF(2.00, Cast(EnumInt(AICoverExposureMethod.Standing_Step_Right))));
    methodsMask = methodsMask & ~Cast(PowF(2.00, Cast(EnumInt(AICoverExposureMethod.Crouching_Step_Left))));
    methodsMask = methodsMask & ~Cast(PowF(2.00, Cast(EnumInt(AICoverExposureMethod.Crouching_Step_Right))));
    AICoverHelper.GetCoverBlackboard(puppet).SetUint(GetAllBlackboardDefs().AICover.lastAvailableMethods, methodsMask);
  }

  public final static func GetCoverNPCCurrentlyExposed(puppet: ref<ScriptedPuppet>) -> Bool {
    return AICoverHelper.GetCoverBlackboard(puppet).GetBool(GetAllBlackboardDefs().AICover.currentlyExposed);
  }

  public final static func SetCoverNPCCurrentlyExposed(puppet: ref<ScriptedPuppet>, value: Bool) -> Void {
    return AICoverHelper.GetCoverBlackboard(puppet).SetBool(GetAllBlackboardDefs().AICover.currentlyExposed, value);
  }

  public final static func IsCurrentlyInCover(puppet: ref<ScriptedPuppet>) -> Bool {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      return false;
    };
    return cm.IsCoverRegular(cm.GetCurrentCover(puppet));
  }

  public final static func IsCurrentlyInShootingSpot(puppet: ref<ScriptedPuppet>) -> Bool {
    let id: Uint64;
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      return false;
    };
    id = cm.GetCurrentCover(puppet);
    if id > 0u {
      return !cm.IsCoverRegular(id);
    };
    return false;
  }

  public final static func IsCurrentlyInSmartObject(puppet: ref<ScriptedPuppet>) -> Bool {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      return false;
    };
    return cm.GetCurrentCover(puppet) > 0u;
  }

  public final static func GetCurrentCover(puppet: ref<ScriptedPuppet>) -> Uint64 {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      return 0u;
    };
    return cm.GetCurrentCover(puppet);
  }

  public final static func IsStandingExposureMethod(exposureMethodName: CName) -> Bool {
    switch exposureMethodName {
      case n"Lean_Over":
        return false;
      case n"Crouching_Step_Left":
        return false;
      case n"Crouching_Step_Right":
        return false;
      case n"Crouching_Lean_Left":
        return false;
      case n"Crouching_Lean_Right":
        return false;
      case n"Crouching_Blind_Left":
        return false;
      case n"Crouching_Blind_Right":
        return false;
      case n"Crouching_Blind_Top":
        return false;
      default:
        return true;
    };
  }

  public final static func IsUnsafeExposureMethod(exposureMethodName: CName) -> Bool {
    switch exposureMethodName {
      case n"Standing_Step_Left":
        return false;
      case n"Standing_Step_Right":
        return false;
      case n"Crouching_Step_Left":
        return false;
      case n"Crouching_Step_Right":
        return false;
      case n"Stand_Up":
        return false;
      default:
        return true;
    };
  }

  public final static func FillEmptyCoverExposureMethodArray() -> array<AICoverExposureMethod> {
    let allExposureMethods: array<AICoverExposureMethod>;
    ArrayResize(allExposureMethods, 15);
    allExposureMethods[0] = AICoverExposureMethod.Standing_Step_Left;
    allExposureMethods[1] = AICoverExposureMethod.Standing_Step_Right;
    allExposureMethods[2] = AICoverExposureMethod.Standing_Lean_Left;
    allExposureMethods[3] = AICoverExposureMethod.Standing_Lean_Right;
    allExposureMethods[4] = AICoverExposureMethod.Crouching_Step_Left;
    allExposureMethods[5] = AICoverExposureMethod.Crouching_Step_Right;
    allExposureMethods[6] = AICoverExposureMethod.Crouching_Lean_Left;
    allExposureMethods[7] = AICoverExposureMethod.Crouching_Lean_Right;
    allExposureMethods[8] = AICoverExposureMethod.Lean_Over;
    allExposureMethods[9] = AICoverExposureMethod.Stand_Up;
    allExposureMethods[10] = AICoverExposureMethod.Standing_Blind_Left;
    allExposureMethods[11] = AICoverExposureMethod.Standing_Blind_Right;
    allExposureMethods[12] = AICoverExposureMethod.Crouching_Blind_Left;
    allExposureMethods[13] = AICoverExposureMethod.Crouching_Blind_Right;
    allExposureMethods[14] = AICoverExposureMethod.Crouching_Blind_Top;
    return allExposureMethods;
  }

  public final static func FillEmptyCoverExposureMethodNameArray() -> array<CName> {
    let allExposureMethods: array<CName>;
    ArrayResize(allExposureMethods, 15);
    allExposureMethods[0] = n"Standing_Step_Left";
    allExposureMethods[1] = n"Standing_Step_Right";
    allExposureMethods[2] = n"Standing_Lean_Left";
    allExposureMethods[3] = n"Standing_Lean_Right";
    allExposureMethods[4] = n"Crouching_Step_Left";
    allExposureMethods[5] = n"Crouching_Step_Right";
    allExposureMethods[6] = n"Crouching_Lean_Left";
    allExposureMethods[7] = n"Crouching_Lean_Right";
    allExposureMethods[8] = n"Lean_Over";
    allExposureMethods[9] = n"Stand_Up";
    allExposureMethods[10] = n"Standing_Blind_Left";
    allExposureMethods[11] = n"Standing_Blind_Right";
    allExposureMethods[12] = n"Crouching_Blind_Left";
    allExposureMethods[13] = n"Crouching_Blind_Right";
    allExposureMethods[14] = n"Crouching_Blind_Top";
    return allExposureMethods;
  }

  public final static func UnregisterLastCover(puppet: ref<ScriptedPuppet>) -> Void {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found for UnregisterLastCover");
      return;
    };
    cm.UnregisterCoverOccupant(puppet);
  }

  public final static func RegisterNewCover(puppet: ref<ScriptedPuppet>, coverId: Uint64) -> Void {
    let cm: ref<CoverManager>;
    if coverId == 0u {
      if coverId == 0u {
        LogAICoverError("ERROR: no cover found in RegisterNewCover");
        return;
      };
    };
    cm = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in RegisterNewCover");
      return;
    };
    cm.RegisterCoverOccupant(coverId, puppet);
  }

  public final static func GetAbsAngleFromCoverToTargetPosition(puppet: wref<ScriptedPuppet>, coverID: Uint64, targetPosition: Vector4) -> Float {
    let vecToTarget: Vector4 = targetPosition - GameInstance.GetCoverManager(puppet.GetGame()).GetCoverPosition(coverID);
    let absAngleToTarget: Float = AbsF(Vector4.GetAngleDegAroundAxis(vecToTarget, GameInstance.GetCoverManager(puppet.GetGame()).GetCoverWorldForward(coverID), GameInstance.GetCoverManager(puppet.GetGame()).GetCoverWorldUp(coverID)));
    return absAngleToTarget;
  }

  public final static func GetAbsAngleFromCoverToCombatTarget(puppet: ref<ScriptedPuppet>, targetPosition: Vector4, coverID: Uint64) -> Float {
    let absAngleToTarget: Float;
    let cm: ref<CoverManager>;
    let vecToTarget: Vector4;
    if Vector4.IsZero(targetPosition) || coverID == 0u {
      return -1.00;
    };
    cm = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetAbsAngleFromCoverToCombatTarget");
      return -1.00;
    };
    vecToTarget = targetPosition - cm.GetCoverPosition(coverID);
    absAngleToTarget = AbsF(Vector4.GetAngleDegAroundAxis(vecToTarget, cm.GetCoverWorldForward(coverID), cm.GetCoverWorldUp(coverID)));
    return absAngleToTarget;
  }

  public final static func GetAbsAngleFromCoverToMovementTarget(puppet: ref<ScriptedPuppet>, movementTargetPos: Vector4, coverID: Uint64) -> Float {
    let absAngleToTarget: Float;
    let vecToTarget: Vector4;
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetAbsAngleFromCoverToMovementTarget");
      return -1.00;
    };
    vecToTarget = movementTargetPos - cm.GetCoverPosition(coverID);
    absAngleToTarget = AbsF(Vector4.GetAngleDegAroundAxis(vecToTarget, cm.GetCoverWorldForward(coverID), cm.GetCoverWorldUp(coverID)));
    return absAngleToTarget;
  }

  public final static func GetCoverHeight(puppet: ref<ScriptedPuppet>, coverID: Uint64) -> gameCoverHeight {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetCoverHeight");
      return gameCoverHeight.Invalid;
    };
    return cm.GetCoverHeight(coverID);
  }

  public final static func GetCoverType(puppet: ref<ScriptedPuppet>, coverID: Uint64, out shootingSpot: Bool) -> gameCoverHeight {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetCoverHeight");
      return gameCoverHeight.Invalid;
    };
    if cm.IsShootingSpot(coverID) {
      shootingSpot = true;
    };
    return cm.GetCoverHeight(coverID);
  }

  public final static func NotifyGotDamageInCover(puppet: ref<ScriptedPuppet>, coverID: Uint64, damageTime: EngineTime, executingCoverAction: Bool) -> Void {
    let statesComponent: ref<NPCStatesComponent> = puppet.GetStatesComponent();
    let isShooting: Bool = false;
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in NotifyGotDamageInCover");
      return;
    };
    if IsDefined(statesComponent) {
      isShooting = Equals(statesComponent.GetCurrentUpperBodyState(), gamedataNPCUpperBodyState.Shoot);
    };
    return cm.NotifyGotDamageInCover(coverID, damageTime, executingCoverAction, isShooting);
  }

  public final static func GetCoverRemainingHealthPerc(puppet: wref<ScriptedPuppet>, coverID: Uint64) -> Float {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in CoverRemainingHealthPerc");
      return -1.00;
    };
    return cm.GetCoverRemainingHealthPercentage(coverID);
  }

  public final static func HasCoverExposureMethods(const puppetOwner: wref<ScriptedPuppet>, const coverID: Uint64, const target: wref<GameObject>, const exposureMethods: array<AICoverExposureMethod>) -> Bool {
    let i: Int32;
    let j: Int32;
    let usableExposureSpots: array<gameAvailableExposureMethodResult>;
    if ArraySize(exposureMethods) == 0 {
      return true;
    };
    usableExposureSpots = GameInstance.GetCoverManager(puppetOwner.GetGame()).GetUsableExposureSpotsForCover(coverID, target);
    i = 0;
    while i < ArraySize(usableExposureSpots) {
      j = 0;
      while j < ArraySize(exposureMethods) {
        if usableExposureSpots[i].distanceToTarget == 0.00 && Equals(usableExposureSpots[i].method, exposureMethods[j]) {
        } else {
          j += 1;
        };
      };
      if j >= ArraySize(exposureMethods) {
        return false;
      };
      i += 1;
    };
    return true;
  }

  public final static func HasCoverExposureMethods(const ownerPuppet: wref<ScriptedPuppet>, const coverID: Uint64, const target: wref<GameObject>, const exposureMethods: array<CName>) -> Bool {
    let methods: array<AICoverExposureMethod>;
    let i: Int32 = 0;
    while i < ArraySize(exposureMethods) {
      ArrayPush(methods, AICoverHelper.CoverExposureMethodNameToEnum(exposureMethods[i]));
      i += 1;
    };
    return AICoverHelper.HasCoverExposureMethods(ownerPuppet, coverID, target, methods);
  }

  public final static func GetAvailableExposureSpots(puppet: wref<ScriptedPuppet>, coverID: Uint64, const target: wref<GameObject>, requestedExposureMethods: array<AICoverExposureMethod>, lineOfSightTolerance: Float, opt exposureMethodPriority: array<wref<AIExposureMethodType_Record>>) -> array<AICoverExposureMethod> {
    let availableExposureMethods: array<AICoverExposureMethod>;
    let i: Int32;
    let j: Int32;
    let validExposureSpots: array<gameAvailableExposureMethodResult>;
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetAvailableExposureSpots");
      return availableExposureMethods;
    };
    if ArraySize(requestedExposureMethods) == 0 {
      requestedExposureMethods = AICoverHelper.FillEmptyCoverExposureMethodArray();
    };
    validExposureSpots = cm.GetUsableExposureSpotsForCover(coverID, target);
    i = 0;
    while i < ArraySize(validExposureSpots) {
      j = 0;
      while j < ArraySize(requestedExposureMethods) {
        if validExposureSpots[i].distanceToTarget <= lineOfSightTolerance && Equals(validExposureSpots[i].method, requestedExposureMethods[j]) {
          ArrayPush(availableExposureMethods, requestedExposureMethods[j]);
        };
        j += 1;
      };
      i += 1;
    };
    return availableExposureMethods;
  }

  public final static func GetAvailableExposureSpots(puppet: wref<ScriptedPuppet>, coverID: Uint64, const target: wref<GameObject>, record: wref<AISubActionCover_Record>, lineOfSightTolerance: Float, opt exposureMethodPriority: array<wref<AIExposureMethodType_Record>>) -> array<AICoverExposureMethod> {
    let allAvailableExposureMethods: array<AICoverExposureMethod>;
    return AICoverHelper.GetAvailableExposureSpots(puppet, coverID, target, record, lineOfSightTolerance, exposureMethodPriority, allAvailableExposureMethods);
  }

  public final static func GetAvailableExposureSpots(puppet: wref<ScriptedPuppet>, coverID: Uint64, const target: wref<GameObject>, record: wref<AISubActionCover_Record>, lineOfSightTolerance: Float, opt exposureMethodPriority: array<wref<AIExposureMethodType_Record>>, out allAvailableExposureMethods: array<AICoverExposureMethod>) -> array<AICoverExposureMethod> {
    let coverCommandParams: wref<CoverCommandParams>;
    let coverExposureMethods: array<CName>;
    let i: Int32;
    let j: Int32;
    let noCollisionExposureMethods: array<AICoverExposureMethod>;
    let requestedExposureMethods: array<AICoverExposureMethod>;
    let tmpVariant: Variant;
    let validExposureSpots: array<gameAvailableExposureMethodResult>;
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in GetAvailableExposureSpots");
      return allAvailableExposureMethods;
    };
    tmpVariant = AICoverHelper.GetCoverBlackboard(puppet).GetVariant(GetAllBlackboardDefs().AICover.commandExposureMethods);
    if VariantIsValid(tmpVariant) {
      coverCommandParams = FromVariant(tmpVariant);
    };
    coverCommandParams = FromVariant(AICoverHelper.GetCoverBlackboard(puppet).GetVariant(GetAllBlackboardDefs().AICover.commandExposureMethods));
    if IsDefined(coverCommandParams) {
      requestedExposureMethods = coverCommandParams.exposureMethods;
    } else {
      coverExposureMethods = record.CoverExposureMethods();
      ArrayResize(requestedExposureMethods, ArraySize(coverExposureMethods));
      i = 0;
      while i < ArraySize(coverExposureMethods) {
        requestedExposureMethods[i] = AICoverHelper.CoverExposureMethodNameToEnum(coverExposureMethods[i]);
        i += 1;
      };
    };
    if ArraySize(requestedExposureMethods) == 0 {
      requestedExposureMethods = AICoverHelper.FillEmptyCoverExposureMethodArray();
    };
    validExposureSpots = cm.GetUsableExposureSpotsForCover(coverID, target);
    i = 0;
    while i < ArraySize(validExposureSpots) {
      j = 0;
      while j < ArraySize(requestedExposureMethods) {
        if validExposureSpots[i].distanceToTarget <= lineOfSightTolerance && Equals(validExposureSpots[i].method, requestedExposureMethods[j]) {
          if validExposureSpots[i].distanceToTarget == 0.00 {
            ArrayPush(noCollisionExposureMethods, requestedExposureMethods[j]);
          } else {
            if ArraySize(noCollisionExposureMethods) == 0 {
              ArrayPush(allAvailableExposureMethods, requestedExposureMethods[j]);
            };
          };
        };
        j += 1;
      };
      i += 1;
    };
    if ArraySize(noCollisionExposureMethods) > 0 {
      allAvailableExposureMethods = noCollisionExposureMethods;
      return AICoverHelper.ReturnHighestPriorityMethods(puppet, record, noCollisionExposureMethods);
    };
    return AICoverHelper.ReturnHighestPriorityMethods(puppet, record, allAvailableExposureMethods);
  }

  public final static func CalculateCoverExposureMethod(puppet: wref<ScriptedPuppet>, const target: wref<GameObject>, coverID: Uint64, record: wref<AISubActionCover_Record>, lineOfSightTolerance: Float, trackedLocation: TrackedLocation, out exposureMethods: array<AICoverExposureMethod>) -> AICoverExposureMethod {
    let exposureMethod: AICoverExposureMethod;
    let lastExposureMethod: AICoverExposureMethod;
    let tmpMethods: array<AICoverExposureMethod>;
    AICoverHelper.GetCoverExposureMethod(puppet, lastExposureMethod);
    tmpMethods = AICoverHelper.GetAvailableExposureSpots(puppet, coverID, target, record, lineOfSightTolerance, exposureMethods);
    if ArraySize(tmpMethods) == 0 {
      return AICoverExposureMethod.Count;
    };
    if ArraySize(tmpMethods) > 1 {
      ArrayRemove(tmpMethods, lastExposureMethod);
    };
    exposureMethod = tmpMethods[RandRange(0, ArraySize(tmpMethods))];
    return exposureMethod;
  }

  public final static func ReturnHighestPriorityMethods(puppet: ref<ScriptedPuppet>, record: wref<AISubActionCover_Record>, exposureMethods: array<AICoverExposureMethod>) -> array<AICoverExposureMethod> {
    let candidates: array<AICoverExposureMethod>;
    let exposureMethodPriority: array<wref<AIExposureMethodType_Record>>;
    let i: Int32;
    let j: Int32;
    let presence: array<Int32>;
    let priority: array<Int32>;
    let hitReactionComponent: ref<HitReactionComponent> = puppet.GetHitReactionComponent();
    let previousHitDelay: Float = EngineTime.ToFloat(GameInstance.GetSimTime(puppet.GetGame())) - hitReactionComponent.GetLastHitTimeStamp();
    if IsDefined(hitReactionComponent) && record.PrioritizeBlindFireAfterHit() > 0.00 && previousHitDelay < record.PrioritizeBlindFireAfterHit() {
      ArrayResize(exposureMethodPriority, 1);
      exposureMethodPriority[0] = TweakDBInterface.GetAIExposureMethodTypeRecord(t"AIExposureMethodType.BlindFire");
    } else {
      record.ExposureMethodPriority(exposureMethodPriority);
    };
    i = 0;
    while i < ArraySize(exposureMethodPriority) {
      priority = exposureMethodPriority[i].Priority();
      ArrayClear(presence);
      ArrayResize(presence, 15);
      j = 0;
      while j < ArraySize(exposureMethods) {
        presence[EnumInt(exposureMethods[j])] = 1;
        j += 1;
      };
      j = 0;
      while j < ArraySize(priority) {
        if presence[priority[j]] == 1 {
          ArrayPush(candidates, IntEnum(priority[j]));
        };
        j += 1;
      };
      if ArraySize(candidates) > 0 {
        return candidates;
      };
      i += 1;
    };
    return exposureMethods;
  }

  public final static func GetCoverStanceFromExposureSpot(puppet: ref<ScriptedPuppet>, exposureSpot: AICoverExposureMethod) -> gameCoverHeight {
    switch exposureSpot {
      case AICoverExposureMethod.Standing_Step_Left:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Standing_Step_Right:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Standing_Lean_Left:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Standing_Lean_Right:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Crouching_Step_Left:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Crouching_Step_Right:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Crouching_Lean_Left:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Crouching_Lean_Right:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Lean_Over:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Stand_Up:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Standing_Blind_Left:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Standing_Blind_Right:
        return gameCoverHeight.High;
      case AICoverExposureMethod.Crouching_Blind_Left:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Crouching_Blind_Right:
        return gameCoverHeight.Low;
      case AICoverExposureMethod.Crouching_Blind_Top:
        return gameCoverHeight.Low;
      default:
        return AICoverHelper.CoverHeightNameToEnum(AICoverHelper.GetCurrentCoverStance(puppet));
    };
  }

  public final static func LeaveCoverImmediately(puppet: ref<ScriptedPuppet>) -> Bool {
    let cm: ref<CoverManager> = AICoverHelper.GetCoverManager(puppet);
    if !IsDefined(cm) {
      LogAICoverError("ERROR: no Cover Manager found in LeaveCoverImmediately");
      return false;
    };
    cm.LeaveCoverImmediately(puppet);
    return true;
  }

  public final static func GetCurrentCoverId(puppet: ref<ScriptedPuppet>) -> Uint64 {
    let cm: ref<CoverManager>;
    if !IsDefined(puppet) {
      return 0u;
    };
    cm = GameInstance.GetCoverManager(puppet.GetGame());
    if !IsDefined(cm) {
      return 0u;
    };
    return cm.GetCurrentCover(puppet);
  }
}
