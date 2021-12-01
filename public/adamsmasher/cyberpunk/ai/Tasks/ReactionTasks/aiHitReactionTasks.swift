
public abstract class AIHitReactionTask extends AIbehaviortaskScript {

  protected let m_activationTimeStamp: Float;

  private let m_reactionDuration: Float;

  private let m_hitReactionAction: ref<ActionHitReactionScriptProxy>;

  private let m_hitReactionType: animHitReactionType;

  public final func Dispose() -> Void {
    this.m_hitReactionAction = null;
  }

  private func OnActivate(context: ScriptExecutionContext) -> Void;

  private func OnDectivate(context: ScriptExecutionContext) -> Void;

  private func GetHitReactionType() -> animHitReactionType {
    return IntEnum(0l);
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    return -1.00;
  }

  private func GetInterruptHitReaction(context: ScriptExecutionContext) -> Float {
    let equippedItem: wref<ItemObject>;
    let equippedItemRecord: wref<Item_Record>;
    let weapon: wref<WeaponObject>;
    let hitReactionComponent: ref<HitReactionComponent> = AIBehaviorScriptBase.GetHitReactionComponent(context);
    let meleeHitChainBeforeBreaking: Int32 = hitReactionComponent.GetMeleeMaxHitChain();
    let rangedHitChainBeforeBreaking: Int32 = hitReactionComponent.GetRangedMaxHitChain();
    if hitReactionComponent.GetHitReactionType() == EnumInt(animHitReactionType.Knockdown) || hitReactionComponent.GetHitReactionType() == EnumInt(animHitReactionType.GuardBreak) {
      return 0.00;
    };
    weapon = GameObject.GetActiveWeapon(ScriptExecutionContext.GetOwner(context));
    if (hitReactionComponent.GetHitCountInCombo() >= meleeHitChainBeforeBreaking && weapon.IsMelee() || hitReactionComponent.GetHitCountInCombo() >= rangedHitChainBeforeBreaking && weapon.IsRanged()) && hitReactionComponent.GetHitReactionData().hitSource != EnumInt(EAIHitSource.Ranged) && AIBehaviorScriptBase.GetPuppet(context).GetAIControllerComponent().CheckTweakCondition("DodgeAfterHitReactionCondition") {
      equippedItem = GameInstance.GetTransactionSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetItemInSlot(ScriptExecutionContext.GetOwner(context), t"AttachmentSlots.WeaponRight");
      if !IsDefined(equippedItem) {
        return 0.00;
      };
      equippedItemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(equippedItem.GetItemID()));
      if hitReactionComponent.GetHitReactionType() != EnumInt(animHitReactionType.GuardBreak) && hitReactionComponent.GetHitReactionType() != EnumInt(animHitReactionType.Block) && hitReactionComponent.GetHitReactionType() != EnumInt(animHitReactionType.Parry) && Equals(equippedItemRecord.ItemCategory().Type(), gamedataItemCategory.Weapon) {
        hitReactionComponent.ResetHitCount();
        if hitReactionComponent.GetHitReactionType() == EnumInt(animHitReactionType.Stagger) {
          return this.GetDesiredHitReactionDuration(context) - 0.45;
        };
        return this.GetDesiredHitReactionDuration(context) - 0.30;
      };
    };
    return 0.00;
  }

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_hitReactionAction = AIBehaviorScriptBase.GetHitReactionComponent(context).GetHitReactionProxyAction();
    this.m_reactionDuration = this.GetDesiredHitReactionDuration(context) - this.GetInterruptHitReaction(context);
    NPCPuppet.ChangeUpperBodyState(ScriptExecutionContext.GetOwner(context), gamedataNPCUpperBodyState.ChargedAttack);
    this.InitialiseReaction(context);
  }

  protected func Update(context: ScriptExecutionContext) -> AIbehaviorUpdateOutcome {
    if this.CheckForReevaluation(context) {
      this.InitialiseReaction(context);
    };
    if AIBehaviorScriptBase.GetAITime(context) < this.m_activationTimeStamp + this.m_reactionDuration {
      return AIbehaviorUpdateOutcome.IN_PROGRESS;
    };
    return AIbehaviorUpdateOutcome.SUCCESS;
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.OnDectivate(context);
    NPCPuppet.ChangeUpperBodyState(ScriptExecutionContext.GetOwner(context), gamedataNPCUpperBodyState.Normal);
    if IsDefined(this.m_hitReactionAction) {
      this.m_hitReactionAction.Stop();
    };
  }

  private final func CheckForReevaluation(context: ScriptExecutionContext) -> Bool {
    if !this.IsThisFrameActivationFrame(context) && AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent() != null {
      if AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitType == EnumInt(animHitReactionType.Block) || AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitType == EnumInt(animHitReactionType.Parry) {
        return true;
      };
      if AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitSource == 1 {
        return true;
      };
    };
    return false;
  }

  private final func AngleToAttackSource(context: ScriptExecutionContext, hitData: ref<AnimFeature_HitReactionsData>) -> Float {
    let finalAngleToAttackSource: Float;
    let finalHitDirection: Int32;
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
      finalHitDirection = GameObject.GetTargetAngleInInt(AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitInstigator(), AIBehaviorScriptBase.GetPuppet(context));
      if finalHitDirection == 0 {
        finalHitDirection = 4;
      };
      switch finalHitDirection {
        case 2:
          finalAngleToAttackSource = 0.00;
          break;
        case 3:
          finalAngleToAttackSource = 90.00;
          break;
        case 4:
          finalAngleToAttackSource = 180.00;
          break;
        case 1:
          finalAngleToAttackSource = 270.00;
          break;
        default:
      };
    };
    return finalAngleToAttackSource;
  }

  private final func IsThisFrameActivationFrame(context: ScriptExecutionContext) -> Bool {
    if this.m_activationTimeStamp == AIBehaviorScriptBase.GetAITime(context) {
      return true;
    };
    return false;
  }

  private final func InitialiseReaction(context: ScriptExecutionContext) -> Void {
    HitReactionComponent.ClearHitStim(ScriptExecutionContext.GetOwner(context));
    this.m_activationTimeStamp = AIBehaviorScriptBase.GetAITime(context);
    this.SendDataToAnimationGraph(context);
    this.SendDataToHitReactionComponent(context);
    this.OnActivate(context);
  }

  private final func SendDataToHitReactionComponent(context: ScriptExecutionContext) -> Void {
    let hitReactionBehaviorData: ref<HitReactionBehaviorData> = new HitReactionBehaviorData();
    hitReactionBehaviorData.m_hitReactionType = this.GetHitReactionType();
    hitReactionBehaviorData.m_hitReactionActivationTimeStamp = this.m_activationTimeStamp;
    hitReactionBehaviorData.m_hitReactionDuration = this.m_reactionDuration;
    let setLastHitDataEvent: ref<LastHitDataEvent> = new LastHitDataEvent();
    setLastHitDataEvent.hitReactionBehaviorData = hitReactionBehaviorData;
    AIBehaviorScriptBase.GetPuppet(context).QueueEvent(setLastHitDataEvent);
  }

  private final func SendDataToAnimationGraph(context: ScriptExecutionContext) -> Void {
    let instigatorYaw: Float;
    let victimYaw: Float;
    let weapon: ref<WeaponObject>;
    let owner: ref<NPCPuppet> = AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet;
    let hitData: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    hitData = AIBehaviorScriptBase.GetHitReactionComponent(context).GetHitReactionData();
    hitData.angleToAttack = this.AngleToAttackSource(context, hitData);
    if hitData.hitSource != 0 {
      instigatorYaw = Vector4.Heading(owner.GetHitReactionComponent().GetHitInstigator().GetWorldForward());
      victimYaw = Vector4.Heading(owner.GetWorldForward());
      hitData.hitDirectionWs = Vector4.RotByAngleXY(owner.GetWorldForward(), victimYaw - instigatorYaw);
    } else {
      hitData.hitDirectionWs = owner.GetLastHitAttackDirection();
    };
    if owner.GetBoolFromCharacterTweak("Hit_Initial_Rotation_Disabled") || Vector4.IsZero(hitData.hitDirectionWs) {
      hitData.useInitialRotation = false;
    } else {
      hitData.useInitialRotation = true;
    };
    hitData.initialRotationDuration = 0.10;
    if hitData.hitType == EnumInt(animHitReactionType.Block) {
      AnimationControllerComponent.ApplyFeatureToReplicate(owner, n"hit", hitData);
      AnimationControllerComponent.PushEventToReplicate(owner, n"PlayBlock");
    } else {
      if hitData.hitType == EnumInt(animHitReactionType.Parry) {
        AnimationControllerComponent.ApplyFeatureToReplicate(owner, n"hit", hitData);
        AnimationControllerComponent.PushEventToReplicate(owner, n"PlayParry");
      } else {
        if IsDefined(this.m_hitReactionAction) {
          if hitData.hitType == EnumInt(animHitReactionType.Pain) {
            if hitData.hitBodyPart == 2 || hitData.hitBodyPart == 3 {
              if owner.GetAIControllerComponent().CheckTweakCondition("WoundedArmHandgunCondition") {
                hitData.animVariation = 0;
              } else {
                if owner.GetAIControllerComponent().CheckTweakCondition("WoundedArmKnifeCondition") {
                  hitData.animVariation = 1;
                } else {
                  hitData.animVariation = 2;
                };
              };
            } else {
              weapon = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight") as WeaponObject;
              if !IsDefined(weapon) {
                weapon = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft") as WeaponObject;
              };
              if !this.HasDismemberedLeg(context) && (Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Name(), n"Wea_Handgun") || Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Name(), n"Wea_Revolver")) {
                hitData.animVariation = 0;
              } else {
                if !this.HasDismemberedLeg(context) && Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Name(), n"Wea_Knife") {
                  hitData.animVariation = 1;
                } else {
                  if !this.HasDismemberedLeg(context) && (Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Name(), n"Wea_Fists") || Equals(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(weapon.GetItemID())).ItemType().Name(), n"Cyb_StrongArms")) || !this.HasDismemberedLeg(context) && !IsDefined(weapon) {
                    hitData.animVariation = 2;
                  } else {
                    hitData.animVariation = 3;
                  };
                };
              };
            };
          };
          this.m_hitReactionAction.Stop();
          this.m_hitReactionAction.Setup(hitData);
          this.m_hitReactionAction.Launch();
          AnimationControllerComponent.ApplyFeatureToReplicate(owner, n"hit", hitData);
        };
      };
    };
  }

  protected final func SpawnAttackGameEffect(context: ScriptExecutionContext, gameEffect: EffectRef, startPosition: Vector4, endPosition: Vector4, duration: Float, colliderBoxSize: Vector4, statusEffect: String) -> Void {
    let attackDirectionWorld: Vector4;
    let attackEndPositionWorld: Vector4;
    let attackStartPositionWorld: Vector4;
    let puppetWorldForward: Vector4;
    let puppetWorldTransform: Transform;
    let storedEffect: ref<EffectInstance>;
    let npcPuppet: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    let puppetWorldPosition: Vector4 = npcPuppet.GetWorldPosition();
    puppetWorldPosition.Z += 1.50;
    puppetWorldForward = npcPuppet.GetWorldForward();
    Transform.SetPosition(puppetWorldTransform, puppetWorldPosition);
    Transform.SetOrientationFromDir(puppetWorldTransform, puppetWorldForward);
    attackStartPositionWorld = Transform.TransformPoint(puppetWorldTransform, startPosition);
    attackEndPositionWorld = Transform.TransformPoint(puppetWorldTransform, endPosition);
    attackDirectionWorld = attackEndPositionWorld - attackStartPositionWorld;
    storedEffect = GameInstance.GetGameEffectSystem(ScriptExecutionContext.GetOwner(context).GetGame()).CreateEffect(gameEffect, npcPuppet, npcPuppet);
    EffectData.SetVector(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.box, colliderBoxSize);
    EffectData.SetFloat(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, duration);
    EffectData.SetVector(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, attackStartPositionWorld);
    EffectData.SetQuat(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.rotation, Transform.GetOrientation(puppetWorldTransform));
    EffectData.SetVector(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, Vector4.Normalize(attackDirectionWorld));
    EffectData.SetFloat(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, Vector4.Length(attackDirectionWorld));
    if NotEquals(statusEffect, "") {
      EffectData.SetString(storedEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.effectName, statusEffect);
    };
    storedEffect.Run();
  }

  private final func HasDismemberedLeg(context: ScriptExecutionContext) -> Bool {
    if StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedLegLeft") || StatusEffectSystem.ObjectHasStatusEffect(AIBehaviorScriptBase.GetPuppet(context), t"BaseStatusEffect.DismemberedLegRight") {
      return true;
    };
    return false;
  }

  private final func GetBCVOName(context: ScriptExecutionContext) -> CName {
    let damage: Float = AIBehaviorScriptBase.GetHitReactionComponent(context).GetCumulatedDamage();
    let ownerHealth: Float = GameInstance.GetStatPoolsSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetStatPoolMaxPointValue(Cast(ScriptExecutionContext.GetOwner(context).GetEntityID()), gamedataStatPoolType.Health);
    if damage > ownerHealth * TweakDBInterface.GetFloat(t"AIGeneralSettings.damageThresholdBattleCry", 0.00) {
      return n"battlecry_curse";
    };
    return n"battlecry_morale";
  }
}

public class ImpactReactionTask extends AIHitReactionTask {

  public let m_tweakDBPackage: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let hitData: ref<AnimFeature_HitReactionsData> = new AnimFeature_HitReactionsData();
    hitData = AIBehaviorScriptBase.GetHitReactionComponent(context).GetHitReactionData();
    if hitData.hitSource != 0 && ScriptedPuppet.CanRagdoll(ScriptExecutionContext.GetOwner(context)) {
      StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.UncontrolledMovement_RagdollOffLedge");
    };
    GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"hit_reaction_light", n"Scripts:ImpactReactionTask");
    broadcaster = ScriptExecutionContext.GetOwner(context).GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      broadcaster.TriggerSingleBroadcast(ScriptExecutionContext.GetOwner(context), gamedataStimType.Attention);
    };
    this.RemoveCamoStatusEffect(context);
    this.Activate(context);
  }

  private func GetHitReactionType() -> animHitReactionType {
    return animHitReactionType.Impact;
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    let duration: Float;
    this.m_tweakDBPackage = t"AIGeneralSettings";
    if AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitSource == 1 || AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitSource == 2 || AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitStimEvent().hitSource == 3 {
      duration = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "impact_melee_duration");
    } else {
      duration = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "impact_ranged_duration");
    };
    if duration > 0.00 {
      return duration;
    };
    return 0.60;
  }

  private final func RemoveCamoStatusEffect(context: ScriptExecutionContext) -> Void {
    let owner: wref<GameObject> = ScriptExecutionContext.GetOwner(context);
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.Cloaked");
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.CloakedOda");
  }
}

public class StaggerReactionTask extends AIHitReactionTask {

  public let m_tweakDBPackage: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"hit_reaction_heavy", n"Scripts:StaggerReactionTask");
    StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.HitReactionStagger");
    this.RemoveCamoStatusEffect(context);
    if ScriptedPuppet.IsPlayerCompanion(ScriptExecutionContext.GetOwner(context)) {
      GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"battlecry_curse", n"Scripts:CompanionStaggerReactionTask");
    };
    if ScriptedPuppet.CanRagdoll(ScriptExecutionContext.GetOwner(context)) {
      StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.UncontrolledMovement_RagdollOffLedge");
    };
    this.Activate(context);
  }

  private func GetHitReactionType() -> animHitReactionType {
    return animHitReactionType.Stagger;
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    let duration: Float;
    this.m_tweakDBPackage = t"AIGeneralSettings";
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let valid: Bool = IsDefined(puppet.GetHitReactionComponent()) && IsDefined(puppet.GetHitReactionComponent().GetHitStimEvent());
    if valid && (puppet.GetHitReactionComponent().GetHitStimEvent().hitSource == EnumInt(EAIHitSource.MeleeSharp) || puppet.GetHitReactionComponent().GetHitStimEvent().hitSource == EnumInt(EAIHitSource.MeleeBlunt)) {
      duration = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "stagger_melee_duration");
    } else {
      if valid && puppet.GetHitReactionComponent().GetHitStimEvent().hitSource == EnumInt(EAIHitSource.QuickMelee) && puppet.GetHitReactionComponent().GetHitStimEvent().hitDirection == 4 {
        duration = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "quickMelee_duration");
      } else {
        duration = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "stagger_ranged_duration");
      };
    };
    if duration > 0.00 {
      return duration;
    };
    return 1.50;
  }

  private final func RemoveCamoStatusEffect(context: ScriptExecutionContext) -> Void {
    let owner: wref<GameObject> = ScriptExecutionContext.GetOwner(context);
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.Cloaked");
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.CloakedOda");
  }
}

public class KnockdownReactionTask extends AIHitReactionTask {

  public let m_tweakDBPackage: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.RemoveCamoStatusEffect(context);
    StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.HitReactionKnockdown");
    if ScriptedPuppet.CanRagdoll(ScriptExecutionContext.GetOwner(context)) {
      StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.UncontrolledMovement_Default");
    };
    GameObject.PlayVoiceOver(ScriptExecutionContext.GetOwner(context), n"hit_reaction_heavy", n"Scripts:KnockdownReactionTask");
    this.Activate(context);
  }

  private func GetHitReactionType() -> animHitReactionType {
    return animHitReactionType.Knockdown;
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    this.m_tweakDBPackage = t"AIGeneralSettings";
    let duration: Float = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "knockdown_duration");
    if duration > 0.00 {
      return duration;
    };
    return 4.00;
  }

  private final func RemoveCamoStatusEffect(context: ScriptExecutionContext) -> Void {
    let owner: wref<GameObject> = ScriptExecutionContext.GetOwner(context);
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.Cloaked");
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffect.CloakedOda");
  }
}

public class PainReactionTask extends AIHitReactionTask {

  protected let m_weaponOverride: ref<AnimFeature_WeaponOverride>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.m_weaponOverride = new AnimFeature_WeaponOverride();
    this.m_weaponOverride.state = 1;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"weaponOverride", this.m_weaponOverride);
    if ScriptedPuppet.CanRagdoll(ScriptExecutionContext.GetOwner(context)) {
      StatusEffectHelper.ApplyStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.UncontrolledMovement_RagdollOffLedge");
    };
    this.Activate(context);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.m_weaponOverride.state = 0;
    AnimationControllerComponent.ApplyFeatureToReplicate(ScriptExecutionContext.GetOwner(context), n"weaponOverride", this.m_weaponOverride);
    this.Deactivate(context);
  }

  private func GetHitReactionType() -> animHitReactionType {
    return animHitReactionType.Pain;
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    return 2.20;
  }
}

public class GuardbreakReactionTask extends AIHitReactionTask {

  public let m_tweakDBPackage: TweakDBID;

  private func GetHitReactionType() -> animHitReactionType {
    return animHitReactionType.GuardBreak;
  }

  private func GetDesiredHitReactionDuration(context: ScriptExecutionContext) -> Float {
    this.m_tweakDBPackage = t"AIGeneralSettings";
    let duration: Float = AITweakParams.GetFloatFromTweak(this.m_tweakDBPackage, "guardbreak_duration");
    if duration > 0.00 {
      return duration;
    };
    return 1.00;
  }
}

public class BlockReactionTask extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().UpdateBlockCount();
  }
}

public class ParryReactionTask extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().UpdateParryCount();
  }
}

public class DodgeReactionTask extends AIbehaviortaskScript {

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().UpdateDodgeCount();
  }
}

public class InitCombatAfterHit extends AIbehaviortaskScript {

  public let target: wref<GameObject>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetPuppetReactionBlackboard().SetBool(GetAllBlackboardDefs().PuppetReaction.blockReactionFlag, true);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    AIBehaviorScriptBase.GetPuppet(context).GetStimReactionComponent().GetPuppetReactionBlackboard().SetBool(GetAllBlackboardDefs().PuppetReaction.blockReactionFlag, false);
    this.target = AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitSource();
    broadcaster = this.target.GetStimBroadcasterComponent();
    if IsDefined(broadcaster) {
      if this.target.IsPuppet() || this.target.IsDevice() {
        broadcaster.SendDrirectStimuliToTarget(ScriptExecutionContext.GetOwner(context), gamedataStimType.CombatHit, AIBehaviorScriptBase.GetPuppet(context));
      } else {
        this.target = AIBehaviorScriptBase.GetPuppet(context).GetHitReactionComponent().GetHitInstigator();
        broadcaster.SendDrirectStimuliToTarget(ScriptExecutionContext.GetOwner(context), gamedataStimType.CombatHit, AIBehaviorScriptBase.GetPuppet(context));
      };
    };
  }
}
