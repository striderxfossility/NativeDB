
public abstract class AIDeathReactionsTask extends AIbehaviortaskScript {

  public inline edit let m_fastForwardAnimation: ref<AIArgumentMapping>;

  protected let m_hitData: ref<AnimFeature_HitReactionsData>;

  private let m_hitReactionAction: ref<ActionHitReactionScriptProxy>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let instigatorYaw: Float;
    let victimYaw: Float;
    let puppet: ref<NPCPuppet> = AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet;
    let npcType: gamedataNPCType = puppet.GetNPCType();
    AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().UpdateDeathHasBeenPlayed();
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Dead);
    this.m_hitData = new AnimFeature_HitReactionsData();
    this.m_hitData = this.GetHitData(context);
    this.m_hitData.hitType = this.GetDeathReactionType(context);
    if this.CanSkipDeathAnimation() && this.m_hitData.hitType == EnumInt(animHitReactionType.Ragdoll) {
      ScriptExecutionContext.GetOwner(context).QueueEvent(CreateForceRagdollEvent(n"AIDeathReactionTask - forced ragdoll"));
    } else {
      if this.m_hitData.hitSource != 0 {
        instigatorYaw = Vector4.Heading(AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitInstigator().GetWorldForward());
        victimYaw = Vector4.Heading(AIBehaviorScriptBase.GetPuppet(context).GetWorldForward());
        this.m_hitData.hitDirectionWs = Vector4.RotByAngleXY(AIBehaviorScriptBase.GetPuppet(context).GetWorldForward(), victimYaw - instigatorYaw);
      } else {
        this.m_hitData.hitDirectionWs = puppet.GetLastHitAttackDirection();
      };
      this.m_hitData.angleToAttack = this.AngleToAttackSource(context, this.m_hitData);
      this.m_hitData.initialRotationDuration = 0.10;
      if Equals(AIBehaviorScriptBase.GetPuppet(context).GetStanceStateFromBlackboard(), gamedataNPCStanceState.Cover) && this.m_hitData.hitIntensity != 3 && this.m_hitData.hitIntensity != 2 {
        this.m_hitData.hitIntensity = 4;
      };
      if !ScriptExecutionContext.GetArgumentBool(context, n"WasDeadOnInit") {
        if !this.PlayHitReactionAction(context) {
          this.TurnOnRagdoll(context, n"Death animation likely isnt streamed in!");
        } else {
          if (Equals(npcType, gamedataNPCType.Human) || Equals(npcType, gamedataNPCType.Android)) && this.IsFloorSteepEnoughToRagdoll(context) {
            GameInstance.GetDelaySystem(ScriptExecutionContext.GetOwner(context).GetGame()).DelayEvent(ScriptExecutionContext.GetOwner(context), CreateForceRagdollEvent(n"NPC died on sloped terrain"), TDB.GetFloat(t"AIGeneralSettings.ragdollFloorAngleActivationDelay"), true);
          };
        };
      };
      AnimationControllerComponent.ApplyFeatureToReplicate(AIBehaviorScriptBase.GetPuppet(context), n"hit", this.m_hitData);
      AnimationControllerComponent.PushEventToReplicate(AIBehaviorScriptBase.GetPuppet(context), n"hit");
    };
    if Equals(npcType, gamedataNPCType.Human) && AIBehaviorScriptBase.GetPuppet(context).ShouldSpawnBloodPuddle() {
      this.SpawnBloodPuddle(AIBehaviorScriptBase.GetPuppet(context));
    };
    this.StopMotionExtraction(context);
  }

  protected final func IsFloorSteepEnoughToRagdoll(context: ScriptExecutionContext) -> Bool {
    let floorAngle: Float;
    if SpatialQueriesHelper.GetFloorAngle(ScriptExecutionContext.GetOwner(context), floorAngle) && floorAngle >= TDB.GetFloat(t"AIGeneralSettings.maxAllowedIncapacitatedFloorAngle") {
      return true;
    };
    return false;
  }

  protected final func TurnOnRagdoll(context: ScriptExecutionContext, activationReason: CName) -> Void {
    let owner: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let hitPosition: Vector4 = owner.GetHitReactionComponent().GetHitPosition();
    let hitImpulse: Vector4 = owner.GetHitReactionComponent().GetHitDirection();
    let hitInfluenceRadius: Float = 100.00;
    owner.QueueEvent(CreateForceRagdollEvent(activationReason));
    GameInstance.GetDelaySystem(owner.GetGame()).DelayEvent(owner, CreateRagdollApplyImpulseEvent(hitPosition, hitImpulse, hitInfluenceRadius), 0.10, false);
    owner.GetHitReactionComponent().UpdateDeathHasBeenPlayed();
    this.ChangeHighLevelState(context);
  }

  protected func CanSkipDeathAnimation() -> Bool {
    return true;
  }

  protected func PlayHitReactionAction(context: ScriptExecutionContext) -> Bool {
    this.m_hitReactionAction = AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitReactionProxyAction();
    this.m_hitReactionAction.Stop();
    if !this.m_hitReactionAction.Setup(this.m_hitData, this.ShouldFastForward(context)) {
      this.m_hitReactionAction.Launch();
      return false;
    };
    this.m_hitReactionAction.Launch();
    return true;
  }

  protected func StopMotionExtraction(context: ScriptExecutionContext) -> Void {
    let evt: ref<HitReactionStopMotionExtraction>;
    let stopMotionExtractionDelay: Float = AIBehaviorScriptBase.GetPuppet(context).GetFloatFromCharacterTweak("deathReaction_motionDuration", -1.00);
    if stopMotionExtractionDelay > 0.00 {
      evt = new HitReactionStopMotionExtraction();
      GameInstance.GetDelaySystem(ScriptExecutionContext.GetOwner(context).GetGame()).DelayEvent(ScriptExecutionContext.GetOwner(context), evt, stopMotionExtractionDelay);
    };
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.Deactivate(context);
    if IsDefined(this.m_hitReactionAction) {
      this.m_hitReactionAction.Stop();
    };
    this.m_hitReactionAction = null;
  }

  public final static func ShouldUseRagdoll(owner: ref<ScriptedPuppet>) -> Bool {
    if !IsDefined(owner) {
      return false;
    };
    if owner.GetMovePolicesComponent().IsOnOffMeshLink() && NotEquals(owner.GetNPCType(), gamedataNPCType.Drone) {
      return true;
    };
    if owner.ShouldSkipDeathAnimation() {
      return true;
    };
    if GameInstance.GetWorkspotSystem(owner.GetGame()).IsActorInWorkspot(owner) && NotEquals(owner.GetNPCType(), gamedataNPCType.Drone) {
      return true;
    };
    return false;
  }

  protected func GetDeathReactionType(context: ScriptExecutionContext) -> Int32 {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if AIDeathReactionsTask.ShouldUseRagdoll(owner) {
      return EnumInt(animHitReactionType.Ragdoll);
    };
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"BrainMeltDeathAnimation") {
      return 10;
    };
    if IsDefined(owner) && Equals((owner as NPCPuppet).ShouldSkipDeathAnimation(), true) {
      return EnumInt(IntEnum(0l));
    };
    return EnumInt(animHitReactionType.Death);
  }

  protected final func ChangeHighLevelState(context: ScriptExecutionContext) -> Void {
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Dead);
  }

  protected final func SpawnBloodPuddle(puppet: wref<ScriptedPuppet>) -> Void {
    let evt: ref<BloodPuddleEvent> = new BloodPuddleEvent();
    if !IsDefined(puppet) || VehicleComponent.IsMountedToVehicle(puppet.GetGame(), puppet) {
      return;
    };
    evt = new BloodPuddleEvent();
    evt.m_slotName = n"Chest";
    evt.cyberBlood = NPCManager.HasVisualTag(puppet, n"CyberTorso");
    GameInstance.GetDelaySystem(puppet.GetGame()).DelayEvent(puppet, evt, 3.00);
  }

  protected func AngleToAttackSource(context: ScriptExecutionContext, hitData: ref<AnimFeature_HitReactionsData>) -> Float {
    let finalAngleToAttackSource: Float;
    let finalHitDirection: Int32;
    let newForwardLocalToWorldAngle: Float;
    let newLocalHitDirection: Vector4;
    if hitData.hitSource == 0 {
      switch (AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet).GetHitReactionComponent().GetHitReactionData().hitDirection {
        case 4:
          finalAngleToAttackSource = 180.00;
          break;
        case 1:
          finalAngleToAttackSource = 270.00;
          break;
        case 2:
          finalAngleToAttackSource = 0.00;
          break;
        case 3:
          finalAngleToAttackSource = 90.00;
          break;
        default:
      };
    } else {
      newForwardLocalToWorldAngle = Vector4.Heading(AIBehaviorScriptBase.GetPuppet(context).GetWorldForward());
      newLocalHitDirection = Vector4.RotByAngleXY(AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitSource().GetWorldForward(), newForwardLocalToWorldAngle);
      finalHitDirection = RoundMath((Vector4.Heading(newLocalHitDirection) + 180.00) / 90.00);
      if finalHitDirection == 0 {
        finalHitDirection = 4;
      };
      switch finalHitDirection {
        case 4:
          finalAngleToAttackSource = 180.00;
          break;
        case 1:
          finalAngleToAttackSource = 270.00;
          break;
        case 2:
          finalAngleToAttackSource = 0.00;
          break;
        case 3:
          finalAngleToAttackSource = 90.00;
          break;
        default:
      };
    };
    return finalAngleToAttackSource;
  }

  protected func GetHitData(context: ScriptExecutionContext) -> ref<AnimFeature_HitReactionsData> {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let animFeature: ref<AnimFeature_HitReactionsData> = owner.GetHitReactionComponent().GetHitReactionData();
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Drone) && !GameInstance.GetNavigationSystem(owner.GetGame()).IsOnGround(owner) {
      animFeature.animVariation = 10;
    };
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"BrainMeltDeathAnimation") {
      return this.BrainMeltDeathData(context);
    };
    return animFeature;
  }

  protected func ShouldFastForward(context: script_ref<ScriptExecutionContext>) -> Bool {
    let rawValue: Variant;
    if !IsDefined(this.m_fastForwardAnimation) {
      return false;
    };
    rawValue = ScriptExecutionContext.GetMappingValue(Deref(context), this.m_fastForwardAnimation);
    return FromVariant(rawValue);
  }

  protected final func BrainMeltDeathData(context: ScriptExecutionContext) -> ref<AnimFeature_HitReactionsData> {
    let animFeature: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    animFeature.hitIntensity = 1;
    animFeature.hitSource = 1;
    animFeature.hitType = 10;
    animFeature.npcMovementSpeed = 1;
    animFeature.hitDirection = 0;
    animFeature.npcMovementDirection = 0;
    animFeature.stance = 0;
    animFeature.animVariation = RandRange(0, AITweakParams.GetIntFromTweak(t"AIGeneralSettings", "numberOfBrainMeltAnimations"));
    return animFeature;
  }
}

public class DeadOnInitTask extends AIbehaviortaskScript {

  @default(DeadOnInitTask, true)
  public edit let m_preventSkippingDeathAnimation: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: ref<NPCPuppet>;
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Dead);
    puppet = AIBehaviorScriptBase.GetNPCPuppet(context);
    if IsDefined(puppet) {
      if this.m_preventSkippingDeathAnimation {
        puppet.SetSkipDeathAnimation(false);
      };
    };
    puppet.DisableCollision();
  }
}

public class DeathIsRagdollCondition extends AIbehaviorconditionScript {

  protected func Check(context: ScriptExecutionContext) -> AIbehaviorConditionOutcomes {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    return Cast(AIDeathReactionsTask.ShouldUseRagdoll(owner));
  }
}

public class WithoutHitDataDeathTask extends AIDeathReactionsTask {

  protected func GetHitData(context: ScriptExecutionContext) -> ref<AnimFeature_HitReactionsData> {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Crippled") {
      return this.BleedingDeathData(context);
    };
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"BrainMeltDeathAnimation") {
      return this.BrainMeltDeathData(context);
    };
    return this.DebugDeathData(context);
  }

  protected func GetDeathReactionType(context: ScriptExecutionContext) -> Int32 {
    let owner: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Drone) || StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"Crippled") {
      return EnumInt(animHitReactionType.Death);
    };
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && StatusEffectSystem.ObjectHasStatusEffectWithTag(owner, n"BrainMeltDeathAnimation") {
      return 10;
    };
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && ScriptExecutionContext.GetArgumentBool(context, n"WasDeadOnInit") {
      return 0;
    };
    return EnumInt(animHitReactionType.Ragdoll);
  }

  private func BleedingDeathData(context: ScriptExecutionContext) -> ref<AnimFeature_HitReactionsData> {
    let animFeature: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    animFeature.hitIntensity = 1;
    animFeature.hitSource = 0;
    animFeature.hitType = 7;
    animFeature.npcMovementSpeed = 0;
    animFeature.hitDirection = 1;
    animFeature.npcMovementDirection = 0;
    animFeature.stance = 1;
    if StatusEffectSystem.ObjectHasStatusEffectOfType(ScriptExecutionContext.GetOwner(context), gamedataStatusEffectType.Wounded) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"LeftArm") {
        animFeature.hitBodyPart = 2;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"RightArm") {
        animFeature.hitBodyPart = 3;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"LeftLeg") {
        animFeature.hitBodyPart = 5;
      };
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(ScriptExecutionContext.GetOwner(context), n"RightLeg") {
        animFeature.hitBodyPart = 6;
      };
    };
    return animFeature;
  }

  private func DebugDeathData(context: ScriptExecutionContext) -> ref<AnimFeature_HitReactionsData> {
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let animFeature: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    animFeature.hitIntensity = 1;
    animFeature.hitSource = 0;
    animFeature.hitType = EnumInt(animHitReactionType.Ragdoll);
    animFeature.hitBodyPart = 4;
    animFeature.npcMovementSpeed = 0;
    animFeature.hitDirection = 4;
    animFeature.npcMovementDirection = 0;
    animFeature.stance = 2;
    if Equals(puppet.GetNPCType(), gamedataNPCType.Drone) {
      animFeature.hitType = EnumInt(animHitReactionType.Death);
      animFeature.animVariation = 10;
      GameInstance.GetDelaySystem(puppet.GetGame()).DelayEvent(puppet, CreateForceRagdollEvent(n"Drone aerial death fallback event"), TweakDBInterface.GetFloat(puppet.GetRecordID() + t".airDeathRagdollDelay", 1.00), true);
    };
    if IsDefined(puppet) && Equals(puppet.GetNPCType(), gamedataNPCType.Human) && ScriptExecutionContext.GetArgumentBool(context, n"WasDeadOnInit") {
      animFeature = new AnimFeature_HitReactionsData();
    };
    return animFeature;
  }
}

public class SyncAnimDeathTask extends WithoutHitDataDeathTask {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().UpdateDeathHasBeenPlayed();
    NPCPuppet.ChangeHighLevelState(ScriptExecutionContext.GetOwner(context), gamedataNPCHighLevelState.Dead);
  }
}

public class ForcedRagdollDeathTask extends AIDeathReactionsTask {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.TurnOnRagdoll(context, n"The ragdoll was forced on the NPC by the behavior tree");
  }
}

public class VehicleDeathTask extends AIDeathReactionsTask {

  public let m_vehNPCDeathData: ref<AnimFeature_VehicleNPCDeathData>;

  public let m_previousState: gamedataNPCHighLevelState;

  @default(VehicleDeathTask, 0.44f)
  public let m_timeToRagdoll: Float;

  public let m_hasRagdolled: Bool;

  public let m_activationTimeStamp: Float;

  private let m_readyToUnmount: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_readyToUnmount = false;
    this.m_vehNPCDeathData = new AnimFeature_VehicleNPCDeathData();
    this.m_previousState = IntEnum(AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().GetInt(GetAllBlackboardDefs().PuppetState.HighLevel));
    if VehicleComponent.IsMountedToVehicle(AIBehaviorScriptBase.GetPuppet(context).GetGame(), AIBehaviorScriptBase.GetPuppet(context)) {
      GameInstance.GetWorkspotSystem(AIBehaviorScriptBase.GetPuppet(context).GetGame()).HardResetPlaybackToStart(AIBehaviorScriptBase.GetPuppet(context));
    };
    this.Activate(context);
    this.m_vehNPCDeathData.deathType = this.GetVehicleDeathType(context);
    this.m_vehNPCDeathData.side = this.m_hitData.hitDirection;
    this.SendVehNPCDeathData(context);
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    if this.m_vehNPCDeathData.deathType != EnumInt(animNPCVehicleDeathType.Ragdoll) {
      AIBehaviorScriptBase.GetNPCPuppet(context).SetDisableRagdoll(true);
    };
  }

  protected func CanSkipDeathAnimation() -> Bool {
    return false;
  }

  protected func PlayHitReactionAction(context: ScriptExecutionContext) -> Bool {
    return true;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetNPCPuppet(context).SetDisableRagdoll(false);
    ScriptExecutionContext.GetOwner(context).QueueEvent(CreateForceRagdollEvent(n"VehicleDeathTask_Deactivate"));
    this.Deactivate(context);
  }

  protected final func GetVehicleDeathType(context: ScriptExecutionContext) -> Int32 {
    let mountInfo: MountingInfo;
    let slotName: CName;
    let slotNames: array<CName>;
    let vehType: String;
    VehicleComponent.GetVehicleType(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context), vehType);
    mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
    slotName = mountInfo.slotId.id;
    if Equals(vehType, "Bike") {
      return EnumInt(animNPCVehicleDeathType.Ragdoll);
    };
    VehicleComponent.GetPassengersSlotNames(slotNames);
    if !ArrayContains(slotNames, slotName) {
      return EnumInt(animNPCVehicleDeathType.Ragdoll);
    };
    if Equals(this.m_previousState, gamedataNPCHighLevelState.Combat) {
      if Equals(slotName, VehicleComponent.GetDriverSlotName()) {
        return EnumInt(animNPCVehicleDeathType.Combat);
      };
      return EnumInt(animNPCVehicleDeathType.Ragdoll);
    };
    return EnumInt(animNPCVehicleDeathType.Relaxed);
  }

  protected func GetDeathReactionType(context: ScriptExecutionContext) -> Int32 {
    return EnumInt(animHitReactionType.Death);
  }

  protected final func SendVehNPCDeathData(context: ScriptExecutionContext) -> Void {
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"VehicleNPCDeathData", this.m_vehNPCDeathData);
    AnimationControllerComponent.PushEventToReplicate(ScriptExecutionContext.GetOwner(context), n"VehicleNPCDeathData");
    if VehicleComponent.IsDriver(ScriptExecutionContext.GetOwner(context).GetGame(), ScriptExecutionContext.GetOwner(context)) {
      this.SendAIEventToMountedVehicle(context, n"DriverDead");
    };
  }

  protected final func SendAIEventToMountedVehicle(context: ScriptExecutionContext, eventName: CName) -> Bool {
    let evt: ref<AIEvent>;
    let vehicle: wref<GameObject>;
    if !IsNameValid(eventName) || !AIBehaviorScriptBase.GetAIComponent(context).GetAssignedVehicle(ScriptExecutionContext.GetOwner(context).GetGame(), vehicle) {
      return false;
    };
    evt = new AIEvent();
    evt.name = eventName;
    vehicle.QueueEvent(evt);
    return true;
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    let knockOverBike: ref<KnockOverBikeEvent>;
    let mountInfo: MountingInfo;
    let workspotSystem: ref<WorkspotGameSystem>;
    if this.m_readyToUnmount {
      workspotSystem = GameInstance.GetWorkspotSystem(AIBehaviorScriptBase.GetPuppet(context).GetGame());
      workspotSystem.UnmountFromVehicle(null, ScriptExecutionContext.GetOwner(context), true);
      AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    if this.m_vehNPCDeathData.deathType == EnumInt(animNPCVehicleDeathType.Ragdoll) {
      if !this.m_hasRagdolled && AIBehaviorScriptBase.GetAITime(context) - this.m_activationTimeStamp >= this.m_timeToRagdoll {
        mountInfo = GameInstance.GetMountingFacility(ScriptExecutionContext.GetOwner(context).GetGame()).GetMountingInfoSingleWithObjects(ScriptExecutionContext.GetOwner(context));
        ScriptExecutionContext.GetOwner(context).QueueEvent(CreateForceRagdollWithCustomFilterDataEvent(n"RagdollVehicle", n"VehicleDeathTask_Update"));
        this.m_readyToUnmount = true;
        this.m_hasRagdolled = true;
        knockOverBike = new KnockOverBikeEvent();
        knockOverBike.forceKnockdown = true;
        knockOverBike.applyDirectionalForce = true;
        GameInstance.FindEntityByID(ScriptExecutionContext.GetOwner(context).GetGame(), mountInfo.parentId).QueueEvent(knockOverBike);
      };
    };
    return AIbehaviorUpdateOutcome.IN_PROGRESS;
  }
}

public class SetSkipDeathAnimationTask extends AIbehaviortaskScript {

  public edit let m_value: Bool;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: ref<NPCPuppet> = AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet;
    if IsDefined(puppet) {
      puppet.SetSkipDeathAnimation(this.m_value);
    };
  }
}
