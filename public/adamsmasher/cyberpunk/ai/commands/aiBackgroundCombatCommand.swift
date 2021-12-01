
public class AIBackgroundCombatCommandParams extends ScriptedAICommandParams {

  public inline edit const let m_steps: array<AIBackgroundCombatStep>;

  public final func GetCommandName() -> String {
    return "Background Combat";
  }

  public func CreateCommand() -> ref<AICommand> {
    let command: ref<AIBackgroundCombatCommand> = new AIBackgroundCombatCommand();
    command.m_steps = this.m_steps;
    return command;
  }
}

public class AIAnimationTask extends AIbehaviortaskScript {

  @attrib(customEditor, "TweakDBGroupInheritance;AIAction")
  protected edit let m_record: TweakDBID;

  protected inline edit let m_animVariation: ref<AIArgumentMapping>;

  protected let m_actionRecord: wref<AIAction_Record>;

  protected let m_actionDebugName: String;

  @default(AIAnimationTask, -1)
  protected let m_animVariationValue: Int32;

  protected let m_phaseRecord: wref<AIActionPhase_Record>;

  protected let m_actionPhase: EAIActionPhase;

  protected let m_phaseActivationTime: Float;

  protected let m_phaseDuration: Float;

  private final func GetPhaseDuration() -> Float {
    let duration: Float;
    let phaseRecord: ref<AIActionPhase_Record> = this.m_phaseRecord;
    if IsDefined(phaseRecord) {
      duration = phaseRecord.AnimationDuration();
      if duration >= 0.00 {
        return duration;
      };
      duration = phaseRecord.Duration();
      return duration;
    };
    return 0.00;
  }

  private final func SendAnimData(context: ScriptExecutionContext, animData: ref<AIActionAnimData_Record>) -> Void {
    let animFeatureName: CName;
    let animSlot: ref<AIActionAnimSlot_Record>;
    let animVariation: Int32;
    let i: Int32;
    let items: array<wref<ItemObject>>;
    let slideParams: ActionAnimationSlideParams;
    let animFeature: ref<AnimFeature_AIAction> = new AnimFeature_AIAction();
    let animProxy: ref<ActionAnimationScriptProxy> = AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().GetActionAnimationScriptProxy();
    if !IsDefined(animProxy) {
      return;
    };
    animFeatureName = animData.AnimFeature();
    if Equals(this.m_actionPhase, EAIActionPhase.Inactive) {
      animProxy.Stop();
      animProxy.Setup(animFeatureName, animFeature, false, false, false, false, animData.UpdateMovePolicy(), slideParams, null, animData.MarginToPlayer());
      animProxy.Launch();
    } else {
      animFeature.state = EnumInt(this.m_actionPhase);
      animFeature.stateDuration = this.m_phaseDuration;
      if this.m_animVariationValue >= 0 {
        animFeature.animVariation = this.m_animVariationValue;
      } else {
        if IsDefined(animData.AnimVariationSubAction()) {
          if TweakAISubAction.GetAnimVariation(context, animData.AnimVariationSubAction(), animVariation) {
            animFeature.animVariation = animVariation;
          } else {
            animFeature.animVariation = animData.AnimVariation();
          };
        } else {
          animFeature.animVariation = animData.AnimVariation();
        };
      };
      animSlot = animData.AnimSlot();
      animProxy.Stop();
      animProxy.Setup(animFeatureName, animFeature, animSlot.UseRootMotion(), animSlot.UsePoseMatching(), animSlot.ResetRagdollOnStart(), animSlot.UseDynamicObjectsCheck(), animData.UpdateMovePolicy(), slideParams, null, animData.MarginToPlayer());
      animProxy.Launch();
    };
    if AIActionHelper.GetItemsFromWeaponSlots(ScriptExecutionContext.GetOwner(context), items) {
      i = 0;
      while i < ArraySize(items) {
        AnimationControllerComponent.ApplyFeatureToReplicate(items[i], animFeatureName, animFeature);
        i += 1;
      };
    };
  }

  private final func StartPhase(context: ScriptExecutionContext, newPhase: EAIActionPhase) -> Void {
    let animData: ref<AIActionAnimData_Record>;
    let phaseRecord: ref<AIActionPhase_Record>;
    this.m_actionPhase = newPhase;
    this.m_phaseActivationTime = AIBehaviorScriptBase.GetAITime(context);
    let action: ref<AIAction_Record> = this.m_actionRecord;
    switch this.m_actionPhase {
      case EAIActionPhase.Startup:
        phaseRecord = action.Startup();
        break;
      case EAIActionPhase.Loop:
        phaseRecord = action.Loop();
        break;
      case EAIActionPhase.Recovery:
        phaseRecord = action.Recovery();
        break;
      default:
        phaseRecord = null;
    };
    this.m_phaseRecord = phaseRecord;
    if IsDefined(phaseRecord) {
      this.m_phaseDuration = phaseRecord.Duration();
    } else {
      this.m_phaseDuration = 0.00;
    };
    animData = action.AnimData();
    if IsDefined(animData) && (IsDefined(phaseRecord) || Equals(this.m_actionPhase, EAIActionPhase.Inactive)) {
      this.SendAnimData(context, animData);
    };
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_actionDebugName = "<no action>";
    TweakAIActionRecord.GetActionRecord(context, this.m_record, this.m_actionDebugName, this.m_actionRecord);
    if IsDefined(this.m_animVariation) {
      this.m_animVariationValue = FromVariant(ScriptExecutionContext.GetMappingValue(context, this.m_animVariation));
    };
    this.m_actionPhase = EAIActionPhase.Inactive;
    this.m_phaseDuration = 0.00;
    this.StartPhase(context, EAIActionPhase.Startup);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void;

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let currentPhaseDuration: Float;
    if !IsDefined(this.m_actionRecord) {
      return AIbehaviorUpdateOutcome.FAILURE;
    };
    currentPhaseDuration = AIBehaviorScriptBase.GetAITime(context) - this.m_phaseActivationTime;
    if currentPhaseDuration >= this.m_phaseDuration {
      switch this.m_actionPhase {
        case EAIActionPhase.Startup:
          this.StartPhase(context, EAIActionPhase.Loop);
          break;
        case EAIActionPhase.Loop:
          this.StartPhase(context, EAIActionPhase.Recovery);
          break;
        case EAIActionPhase.Recovery:
          this.StartPhase(context, EAIActionPhase.Inactive);
          return AIbehaviorUpdateOutcome.SUCCESS;
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  public func GetDescription(context: ScriptExecutionContext) -> String {
    return this.m_actionDebugName;
  }
}

public class AIBackgroundCombatDelegate extends ScriptBehaviorDelegate {

  private let m_command: ref<AIBackgroundCombatCommand>;

  private let m_execute: Bool;

  private let m_steps: array<AIBackgroundCombatStep>;

  private let m_currentStep: Int32;

  private let m_desiredCover: NodeRef;

  private let m_desiredCoverExposureMethod: AICoverExposureMethod;

  private let m_desiredDestination: NodeRef;

  private let m_hasDesiredTarget: Bool;

  private let m_desiredTarget: EntityReference;

  private let m_desiredCoverId: Uint64;

  private let m_currentCoverId: Uint64;

  private let m_currentTarget: wref<GameObject>;

  private let m_canFireFromCover: Bool;

  private let m_canFireOutOfCover: Bool;

  private final func SetExecute(context: ScriptExecutionContext, value: Bool) -> Void {
    this.m_execute = value;
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"ExecuteChanged");
  }

  private final func SetDesiredCover(context: ScriptExecutionContext, cover: NodeRef, exposureMethod: AICoverExposureMethod) -> Void {
    let exposureMethodIndex: Int32;
    let exposureMethods: array<gameAvailableExposureMethodResult>;
    this.m_desiredCover = cover;
    this.m_desiredCoverExposureMethod = exposureMethod;
    let cm: ref<CoverManager> = GameInstance.GetCoverManager(ScriptExecutionContext.GetOwner(context).GetGame());
    if IsDefined(cm) {
      this.m_desiredCoverId = cm.NodeRefToObjectId(cover);
      exposureMethods = cm.GetUsableExposureSpotsForCover(this.m_desiredCoverId, this.m_currentTarget);
      if ArraySize(exposureMethods) > 0 {
        exposureMethodIndex = RandRange(0, ArraySize(exposureMethods));
        this.m_desiredCoverExposureMethod = exposureMethods[exposureMethodIndex].method;
      };
    };
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"DesiredCoverChanged");
  }

  private final func SetDesiredDestination(context: ScriptExecutionContext, destination: NodeRef) -> Void {
    this.m_desiredDestination = destination;
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"DesiredDestinationChanged");
  }

  private final func SetDesiredTarget(context: ScriptExecutionContext, target: EntityReference) -> Void {
    this.m_hasDesiredTarget = true;
    this.m_desiredTarget = this.m_steps[this.m_currentStep].m_argument;
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"DesiredTargetChanged");
  }

  public final func DoStartCommand(context: ScriptExecutionContext) -> Bool {
    let i: Int32;
    ArrayClear(this.m_steps);
    i = 0;
    while i < ArraySize(this.m_command.m_steps) {
      ArrayPush(this.m_steps, this.m_command.m_steps[i]);
      i += 1;
    };
    this.m_currentStep = 0;
    this.m_hasDesiredTarget = false;
    this.SetExecute(context, true);
    return true;
  }

  public final func DoEndCommand(context: ScriptExecutionContext) -> Bool {
    this.SetExecute(context, false);
    ArrayClear(this.m_steps);
    this.m_currentStep = -1;
    return true;
  }

  public final func DoExecuteCurrentStep(context: ScriptExecutionContext) -> Bool {
    if ArraySize(this.m_steps) == 0 {
      return false;
    };
    if this.m_currentStep >= ArraySize(this.m_steps) {
      this.m_currentStep = 0;
    };
    switch this.m_steps[this.m_currentStep].m_type {
      case EAIBackgroundCombatStep.ChangeCover:
        if Equals((ScriptExecutionContext.GetOwner(context) as ScriptedPuppet).GetNPCType(), gamedataNPCType.Drone) {
          this.SetDesiredDestination(context, this.m_steps[this.m_currentStep].m_argument.reference);
        } else {
          this.SetDesiredCover(context, this.m_steps[this.m_currentStep].m_argument.reference, this.m_steps[this.m_currentStep].m_exposureMethod);
        };
        break;
      case EAIBackgroundCombatStep.ChangeTarget:
        this.SetDesiredTarget(context, this.m_steps[this.m_currentStep].m_argument);
    };
    return true;
  }

  public final func DoStartNextStep(context: ScriptExecutionContext) -> Bool {
    let delay: Float;
    let maxTime: Float;
    let minTime: Float;
    let nextStepEvent: ref<AIEvent>;
    if ArraySize(this.m_steps) == 0 {
      return false;
    };
    this.m_currentStep += 1;
    if this.m_currentStep >= ArraySize(this.m_steps) {
      this.m_currentStep = 0;
    };
    minTime = this.m_steps[this.m_currentStep].m_timeMin;
    maxTime = this.m_steps[this.m_currentStep].m_timeMax;
    if maxTime > minTime {
      delay = RandRangeF(minTime, maxTime);
    } else {
      delay = minTime;
    };
    nextStepEvent = new AIEvent();
    nextStepEvent.name = n"AIBackgroundCommandNextStepEvent";
    if delay > 0.00 {
      GameInstance.GetDelaySystem(ScriptExecutionContext.GetOwner(context).GetGame()).DelayEvent(ScriptExecutionContext.GetOwner(context), nextStepEvent, delay, true);
    } else {
      ScriptExecutionContext.GetOwner(context).QueueEvent(nextStepEvent);
    };
    return true;
  }

  public final func DoAllowCoverChange(context: ScriptExecutionContext) -> Bool {
    if this.m_desiredCoverId != this.m_currentCoverId {
      ScriptExecutionContext.InvokeBehaviorCallback(context, n"BackgroundCombat_CoverChangeAllowed");
    };
    return true;
  }

  public final func DoStartCoverChange() -> Bool {
    this.m_canFireFromCover = false;
    this.m_canFireOutOfCover = true;
    return true;
  }

  public final func DoCompleteCoverChange() -> Bool {
    this.m_currentCoverId = this.m_desiredCoverId;
    this.m_canFireFromCover = true;
    this.m_canFireOutOfCover = false;
    return true;
  }

  public final func DoEnableShootingFromCover(context: ScriptExecutionContext) -> Bool {
    this.m_canFireFromCover = true;
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"BackgroundCombat_FireFromCoverChanged");
    return true;
  }

  public final func DoDisableShootingFromCover(context: ScriptExecutionContext) -> Bool {
    this.m_canFireFromCover = false;
    ScriptExecutionContext.InvokeBehaviorCallback(context, n"BackgroundCombat_FireFromCoverChanged");
    return true;
  }

  public final func DoCompleteTargetChange(context: ScriptExecutionContext) -> Bool {
    let game: GameInstance;
    let globalRef: GlobalNodeRef;
    if this.m_hasDesiredTarget {
      game = ScriptExecutionContext.GetOwner(context).GetGame();
      if !GetGameObjectFromEntityReference(this.m_desiredTarget, game, this.m_currentTarget) {
        globalRef = ResolveNodeRef(this.m_desiredTarget.reference, Cast(GlobalNodeID.GetRoot()));
        this.m_currentTarget = GameInstance.FindEntityByID(game, Cast(globalRef)) as GameObject;
      };
      if this.m_currentTarget == ScriptExecutionContext.GetOwner(context) {
        return false;
      };
      ScriptExecutionContext.SetArgumentObject(context, n"CombatTarget", this.m_currentTarget);
      AIActionHelper.SetCommandCombatTarget(context, this.m_currentTarget, EnumInt(PersistenceSource.SetNewCombatTarget));
    };
    return true;
  }
}
