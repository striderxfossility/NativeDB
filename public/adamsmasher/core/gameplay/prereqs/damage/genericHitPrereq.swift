
public class GenericHitPrereqState extends PrereqState {

  public let m_listener: ref<HitCallback>;

  public let m_hitEvent: ref<gameHitEvent>;

  public final func SetHitEvent(hitEvent: ref<gameHitEvent>) -> Void {
    this.m_hitEvent = hitEvent;
  }

  public final const func GetHitEvent() -> ref<gameHitEvent> {
    return this.m_hitEvent;
  }

  public func Evaluate(hitEvent: ref<gameHitEvent>) -> Bool {
    let result: Bool;
    let prereq: ref<GenericHitPrereq> = this.GetPrereq() as GenericHitPrereq;
    let i: Int32 = 0;
    while i < ArraySize(prereq.m_conditions) {
      result = prereq.m_conditions[i].Evaluate(hitEvent);
      if !result {
        return false;
      };
      i += 1;
    };
    if hitEvent.target.IsPlayer() && hitEvent.attackData.GetInstigator().IsPlayer() && Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.PressureWave) {
      return false;
    };
    return true;
  }

  protected final func GetObjectToCheck(obj: String, hitEvent: ref<gameHitEvent>) -> wref<GameObject> {
    switch obj {
      case "Instigator":
        return hitEvent.attackData.GetInstigator();
      case "Source":
        return hitEvent.attackData.GetSource();
      case "Target":
        return hitEvent.target;
      default:
        return null;
    };
  }
}

public class GenericHitPrereq extends IScriptablePrereq {

  @default(HitDamageOverTimePrereq, true)
  @default(HitDistanceCoveredPrereq, true)
  @default(HitIsHumanPrereq, true)
  @default(HitIsMovingPrereq, true)
  @default(HitIsRarityPrereq, true)
  @default(HitIsTheSameTargetPrereq, true)
  @default(HitStatPoolComparisonPrereq, true)
  @default(HitStatPoolPrereq, true)
  @default(HitStatusEffectPresentPrereq, true)
  public let m_isSync: Bool;

  @default(HitDamageOverTimePrereq, gameDamageCallbackType.HitTriggered)
  @default(HitDistanceCoveredPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitIsHumanPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitIsMovingPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitIsRarityPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitIsTheSameTargetPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitStatPoolComparisonPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitStatPoolPrereq, gameDamageCallbackType.HitTriggered)
  @default(HitStatusEffectPresentPrereq, gameDamageCallbackType.HitTriggered)
  @default(TargetKilledPrereq, gameDamageCallbackType.HitTriggered)
  public let m_callbackType: gameDamageCallbackType;

  @default(HitDistanceCoveredPrereq, gameDamagePipelineStage.PreProcess)
  @default(HitIsHumanPrereq, gameDamagePipelineStage.Process)
  @default(HitIsMovingPrereq, gameDamagePipelineStage.Process)
  @default(HitIsRarityPrereq, gameDamagePipelineStage.PreProcess)
  @default(HitIsTheSameTargetPrereq, gameDamagePipelineStage.Process)
  @default(HitStatPoolComparisonPrereq, gameDamagePipelineStage.Process)
  @default(HitStatPoolPrereq, gameDamagePipelineStage.Process)
  @default(HitStatusEffectPresentPrereq, gameDamagePipelineStage.Process)
  @default(TargetKilledPrereq, gameDamagePipelineStage.PostProcess)
  public let m_pipelineStage: gameDamagePipelineStage;

  public let m_attackType: gamedataAttackType;

  public let m_conditions: array<ref<BaseHitPrereqCondition>>;

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: wref<GameObject> = context as GameObject;
    let castedState: ref<GenericHitPrereqState> = state as GenericHitPrereqState;
    if Equals(this.m_callbackType, gameDamageCallbackType.HitTriggered) {
      castedState.m_listener = new HitTriggeredCallback();
    } else {
      if Equals(this.m_callbackType, gameDamageCallbackType.HitReceived) {
        castedState.m_listener = new HitReceivedCallback();
      } else {
        if Equals(this.m_callbackType, gameDamageCallbackType.PipelineProcessed) {
          castedState.m_listener = new PipelineProcessedCallback();
        };
      };
    };
    castedState.m_listener.RegisterState(castedState);
    if this.m_isSync {
      GameInstance.GetDamageSystem(game).RegisterSyncListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType, this.m_pipelineStage, DMGPipelineType.All);
    } else {
      GameInstance.GetDamageSystem(game).RegisterListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType, DMGPipelineType.All);
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let owner: ref<GameObject> = context as GameObject;
    let castedState: ref<GenericHitPrereqState> = state as GenericHitPrereqState;
    if this.m_isSync {
      GameInstance.GetDamageSystem(game).UnregisterSyncListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType, this.m_pipelineStage);
    } else {
      GameInstance.GetDamageSystem(game).UnregisterListener(castedState.m_listener, owner.GetEntityID(), this.m_callbackType);
    };
    castedState.m_listener = null;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let condition: ref<BaseHitPrereqCondition>;
    let conds: array<wref<HitPrereqCondition_Record>>;
    let i: Int32;
    let str: String;
    ArrayClear(this.m_conditions);
    this.m_isSync = TweakDBInterface.GetBool(recordID + t".isSynchronous", false);
    str = TweakDBInterface.GetString(recordID + t".callbackType", "HitTriggered");
    this.m_callbackType = IntEnum(Cast(EnumValueFromString("gameDamageCallbackType", str)));
    str = TweakDBInterface.GetString(recordID + t".pipelineStage", "Process");
    this.m_pipelineStage = IntEnum(Cast(EnumValueFromString("gameDamagePipelineStage", str)));
    TweakDBInterface.GetHitPrereqRecord(recordID).Conditions(conds);
    i = 0;
    while i < ArraySize(conds) {
      condition = this.CreateHitCondition(conds[i]);
      if IsDefined(condition) {
        ArrayPush(this.m_conditions, condition);
      };
      i += 1;
    };
  }

  private final func CreateHitCondition(record: ref<HitPrereqCondition_Record>) -> ref<BaseHitPrereqCondition> {
    let condition: ref<BaseHitPrereqCondition>;
    let type: gamedataHitPrereqConditionType = record.Type().Type();
    switch type {
      case gamedataHitPrereqConditionType.AttackSubType:
        condition = new AttackSubtypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.AttackType:
        condition = new AttackTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.BodyPart:
        condition = new BodyPartHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.DamageOverTimeType:
        condition = new DamageOverTimeTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.DamageType:
        condition = new DamageTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.DistanceCovered:
        condition = new DistanceCoveredHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.HitFlag:
        condition = new HitFlagHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.InstigatorType:
        condition = new InstigatorTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.SameTarget:
        condition = new SameTargetHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.SourceType:
        condition = new SourceTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.StatPool:
        condition = new StatPoolHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.StatPoolComparison:
        condition = new StatPoolComparisonHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.StatusEffectPresent:
        condition = new StatusEffectPresentHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.TargetKilled:
        condition = new TargetKilledHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.TargetNPCRarity:
        condition = new TargetNPCRarityHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.TargetNPCType:
        condition = new TargetNPCTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.AgentMoving:
        condition = new AgentMovingHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.AmmoState:
        condition = new AmmoStateHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.WeaponType:
        condition = new WeaponTypeHitPrereqCondition();
        break;
      case gamedataHitPrereqConditionType.TargetType:
        condition = new TargetTypeHitPrereqCondition();
        break;
      default:
        return null;
    };
    condition.SetData(record.GetID());
    return condition;
  }
}

public class HitCallback extends ScriptedDamageSystemListener {

  protected let m_state: wref<GenericHitPrereqState>;

  public func RegisterState(state: ref<PrereqState>) -> Void {
    this.m_state = state as GenericHitPrereqState;
  }

  protected func UpdateState(hitEvent: ref<gameHitEvent>) -> Void {
    let checkPassed: Bool;
    this.m_state.SetHitEvent(hitEvent);
    checkPassed = this.m_state.Evaluate(hitEvent);
    if checkPassed {
      this.m_state.OnChangedRepeated(false);
    };
  }
}

public class HitTriggeredCallback extends HitCallback {

  protected func OnHitTriggered(hitEvent: ref<gameHitEvent>) -> Void {
    this.UpdateState(hitEvent);
  }

  protected func OnHitReceived(hitEvent: ref<gameHitEvent>) -> Void;
}

public class HitReceivedCallback extends HitCallback {

  protected func OnHitTriggered(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnHitReceived(hitEvent: ref<gameHitEvent>) -> Void {
    this.UpdateState(hitEvent);
  }
}

public class PipelineProcessedCallback extends HitCallback {

  protected func OnHitTriggered(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnHitReceived(hitEvent: ref<gameHitEvent>) -> Void;

  protected func OnPipelineProcessed(hitEvent: ref<gameHitEvent>) -> Void {
    this.UpdateState(hitEvent);
  }
}
