
public class ApplyStatusEffectOnOwner extends StatusEffectTasks {

  @attrib(customEditor, "TweakDBGroupInheritance;StatusEffect")
  public edit let m_statusEffectID: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    StatusEffectHelper.ApplyStatusEffect(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectID);
  }
}

public class RemoveStatusEffectOnOwner extends StatusEffectTasks {

  @attrib(customEditor, "TweakDBGroupInheritance;StatusEffect")
  public edit let m_statusEffectID: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    StatusEffectHelper.RemoveStatusEffect(AIBehaviorScriptBase.GetPuppet(context), this.m_statusEffectID);
  }
}

public class MonitorStatusEffectBehavior extends StatusEffectTasks {

  @attrib(customEditor, "TweakDBGroupInheritance;StatusEffect")
  public edit let m_statusEffectID: TweakDBID;

  protected func Activate(context: ScriptExecutionContext) -> Void;

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if Equals(TweakDBInterface.GetStatusEffectRecord(this.m_statusEffectID).AIData().BehaviorType().Type(), gamedataStatusEffectAIBehaviorType.Stoppable) {
      StatusEffectHelper.RemoveStatusEffect(ScriptExecutionContext.GetOwner(context), this.m_statusEffectID);
    };
  }
}

public class UnconsciousManagerTask extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    if StatusEffectSystem.ObjectHasStatusEffect(ScriptExecutionContext.GetOwner(context), t"BaseStatusEffect.Unconscious") {
      this.SetUnconsciousBodyVisibleComponent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, true);
    };
  }

  protected func SetUnconsciousBodyVisibleComponent(puppet: ref<NPCPuppet>, state: Bool) -> Void {
    let detectMultEvent: ref<VisibleObjectDetectionMultEvent>;
    let visibleObjectPosition: Vector4;
    let visibleObject: ref<VisibleObjectComponent> = puppet.GetVisibleObjectComponent();
    visibleObject.Toggle(state);
    visibleObject.visibleObject.description = n"Unconscious";
    visibleObjectPosition = visibleObject.GetLocalPosition();
    visibleObjectPosition.Z = visibleObjectPosition.Z + 1.00;
    visibleObject.SetLocalPosition(visibleObjectPosition);
    detectMultEvent = new VisibleObjectDetectionMultEvent();
    detectMultEvent.multiplier = 100.00;
    puppet.QueueEvent(detectMultEvent);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.SetUnconsciousBodyVisibleComponent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, false);
  }
}

public class HeartAttackManagerTask extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.SetHeartAttackBodyVisibleComponent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, true);
  }

  protected func SetHeartAttackBodyVisibleComponent(puppet: ref<NPCPuppet>, state: Bool) -> Void {
    let visibleObjectPosition: Vector4;
    let visibleObject: ref<VisibleObjectComponent> = puppet.GetVisibleObjectComponent();
    visibleObject.Toggle(state);
    visibleObject.visibleObject.description = n"HeartAttack";
    visibleObjectPosition = visibleObject.GetLocalPosition();
    visibleObjectPosition.Z = visibleObjectPosition.Z + 1.00;
    visibleObject.SetLocalPosition(visibleObjectPosition);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.SetHeartAttackBodyVisibleComponent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, false);
  }
}

public class ToggleVisibleObjectComponent extends StatusEffectTasks {

  public edit let m_componentTargetState: Bool;

  public edit let m_visibleObjectDescription: CName;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let visibleObjectPosition: Vector4;
    let puppet: ref<ScriptedPuppet> = AIBehaviorScriptBase.GetPuppet(context);
    let visibleObject: ref<VisibleObjectComponent> = puppet.GetVisibleObjectComponent();
    visibleObject.Toggle(this.m_componentTargetState);
    visibleObject.visibleObject.description = this.m_visibleObjectDescription;
    visibleObjectPosition = visibleObject.GetLocalPosition();
    visibleObjectPosition.Z = visibleObjectPosition.Z + 1.00;
    visibleObject.SetLocalPosition(visibleObjectPosition);
  }
}

public class SetPlayerAsKiller extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let puppet: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if IsDefined(puppet) {
      puppet.SetMyKiller(GameInstance.GetPlayerSystem(puppet.GetGame()).GetLocalPlayerControlledGameObject());
    };
  }
}

public class SetPendingReactionBB extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, true);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    AIBehaviorScriptBase.GetPuppet(context).GetPuppetStateBlackboard().SetBool(GetAllBlackboardDefs().PuppetState.InPendingBehavior, false);
  }
}

public class BlindManagerTask extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let hostileThreats: array<TrackedLocation> = AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().GetHostileThreats(false);
    let i: Int32 = 0;
    while i < ArraySize(hostileThreats) {
      AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().SetThreatBaseMul(hostileThreats[i].entity, 0.00);
      i += 1;
    };
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    if !StatusEffectSystem.ObjectHasStatusEffectWithTag(AIBehaviorScriptBase.GetPuppet(context), n"ResetSquadSync") {
      AIBehaviorScriptBase.GetPuppet(context).GetTargetTrackerComponent().PullSquadSync(AISquadType.Combat);
    };
  }
}

public class CacheFXOnDefeated extends StatusEffectTasks {

  public let npcPuppet: wref<NPCPuppet>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let cacheFXEvent: ref<CacheStatusEffectFXEvent>;
    let j: Int32;
    let sfxToCache: array<wref<StatusEffectFX_Record>>;
    let vfxToCache: array<wref<StatusEffectFX_Record>>;
    this.npcPuppet = AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet;
    let appliedStatusEffects: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(this.npcPuppet);
    let i: Int32 = 0;
    while i < ArraySize(appliedStatusEffects) {
      j = 0;
      while j < appliedStatusEffects[i].GetRecord().GetVFXCount() {
        ArrayPush(vfxToCache, appliedStatusEffects[i].GetRecord().GetVFXItem(j));
        j += 1;
      };
      i += 1;
    };
    i = 0;
    while i < ArraySize(appliedStatusEffects) {
      j = 0;
      while j < appliedStatusEffects[i].GetRecord().GetSFXCount() {
        ArrayPush(sfxToCache, appliedStatusEffects[i].GetRecord().GetSFXItem(j));
        j += 1;
      };
      i += 1;
    };
    cacheFXEvent = new CacheStatusEffectFXEvent();
    cacheFXEvent.vfxToCache = vfxToCache;
    cacheFXEvent.sfxToCache = sfxToCache;
    this.npcPuppet.QueueEvent(cacheFXEvent);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    let removeFXEvent: ref<RemoveCachedStatusEffectFXEvent> = new RemoveCachedStatusEffectFXEvent();
    this.npcPuppet.QueueEvent(removeFXEvent);
  }
}

public class CacheStatusEffectAnimationTask extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    this.QueueStatusEffectAnimEvent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, false);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    this.QueueStatusEffectAnimEvent(AIBehaviorScriptBase.GetPuppet(context) as NPCPuppet, true);
  }

  protected func QueueStatusEffectAnimEvent(puppet: ref<NPCPuppet>, removeCachedStatusEffect: Bool) -> Void {
    let cacheStatusEffectAnim: ref<CacheStatusEffectAnimEvent> = new CacheStatusEffectAnimEvent();
    cacheStatusEffectAnim.removeCachedStatusEffect = removeCachedStatusEffect;
    puppet.QueueEvent(cacheStatusEffectAnim);
  }
}

public class CheckFriendlyNPCAboutToBeHit extends StatusEffectTasks {

  public inline edit let m_outStatusArgument: ref<AIArgumentMapping>;

  public inline edit let m_outPositionStatusArgument: ref<AIArgumentMapping>;

  public inline edit let m_outPositionArgument: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let distanceBetweenActors: Float;
    let foundPointOnNavmesh: Bool;
    let i: Int32;
    let navmeshProbeDimensions: array<Float>;
    let navmeshProbeDistances: array<Float>;
    let navmeshTolerance: Vector4;
    let pointOnNavmesh: Vector4;
    let projectedDistance: Float;
    let projectedPosition: Vector4;
    let vehicle: wref<VehicleObject>;
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject();
    if NotEquals(owner.GetAttitudeTowards(player), EAIAttitude.AIA_Friendly) && NotEquals(owner.GetRecord().Priority().Type(), gamedataSpawnableObjectPriority.Quest) {
      ScriptExecutionContext.SetMappingValue(context, this.m_outStatusArgument, ToVariant(false));
      return;
    };
    if VehicleComponent.GetVehicle(owner.GetGame(), player, vehicle) {
      distanceBetweenActors = Vector4.Distance(owner.GetWorldPosition(), player.GetWorldPosition());
      projectedPosition = vehicle.GetWorldPosition() + vehicle.GetLinearVelocity() * TweakDBInterface.GetFloat(t"AIGeneralSettings.mountedPlayerHitPredictionTime", 2.00);
      projectedDistance = Vector4.Distance(owner.GetWorldPosition(), projectedPosition);
      if distanceBetweenActors <= TweakDBInterface.GetFloat(t"AIGeneralSettings.mountedPlayerMinDistanceForTeleport", 3.00) || projectedDistance <= TweakDBInterface.GetFloat(t"AIGeneralSettings.mountedPlayerMinDistanceForTeleport", 6.00) {
        ScriptExecutionContext.SetMappingValue(context, this.m_outStatusArgument, ToVariant(true));
        navmeshProbeDimensions = TDB.GetFloatArray(t"AIGeneralSettings.ragdollRecoveryInitialNavmeshProbeDimensions");
        navmeshTolerance = new Vector4(navmeshProbeDimensions[0], navmeshProbeDimensions[1], navmeshProbeDimensions[2], navmeshProbeDimensions[3]);
        navmeshProbeDistances = TDB.GetFloatArray(t"AIGeneralSettings.navmeshProbeDistancesFriendly");
        i = 0;
        while i < ArraySize(navmeshProbeDistances) {
          if GameInstance.GetAINavigationSystem(owner.GetGame()).TryToFindNavmeshPointAroundPoint(owner, owner.GetWorldPosition(), owner.GetWorldOrientation(), navmeshTolerance, TDB.GetInt(t"AIGeneralSettings.numberOfProbesPerDistance"), navmeshProbeDistances[i], pointOnNavmesh, false) && Vector4.Distance(pointOnNavmesh, player.GetWorldPosition()) > TweakDBInterface.GetFloat(t"AIGeneralSettings.mountedPlayerMinDistanceForTeleport", 3.00) {
            foundPointOnNavmesh = true;
            ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(pointOnNavmesh));
          } else {
            i += 1;
          };
        };
      };
    };
    ScriptExecutionContext.SetMappingValue(context, this.m_outPositionStatusArgument, ToVariant(foundPointOnNavmesh));
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    ScriptExecutionContext.SetMappingValue(context, this.m_outStatusArgument, ToVariant(false));
    ScriptExecutionContext.SetMappingValue(context, this.m_outPositionStatusArgument, ToVariant(false));
    ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(new Vector4()));
  }
}

public class CheckRagdollOutOfNavmeshTask extends StatusEffectTasks {

  public inline edit let m_outStatusArgument: ref<AIArgumentMapping>;

  public inline edit let m_outPositionStatusArgument: ref<AIArgumentMapping>;

  public inline edit let m_outPositionArgument: ref<AIArgumentMapping>;

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let foundPointOnNavmesh: Bool;
    let i: Int32;
    let isFriendlyToPlayer: Bool;
    let lastValidNavmeshPosition: Vector4;
    let navmeshProbeDimensions: array<Float>;
    let navmeshProbeDistances: array<Float>;
    let navmeshTolerance: Vector4;
    let numberOfProbes: Int32;
    let ownerPosition: Vector4;
    let pointOnNavmesh: Vector4;
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if IsDefined(owner) {
      ownerPosition = owner.GetWorldPosition();
      navmeshProbeDimensions = TDB.GetFloatArray(t"AIGeneralSettings.ragdollRecoveryInitialNavmeshProbeDimensions");
      navmeshTolerance = new Vector4(navmeshProbeDimensions[0], navmeshProbeDimensions[1], navmeshProbeDimensions[2], navmeshProbeDimensions[3]);
      if GameInstance.GetAINavigationSystem(owner.GetGame()).IsPointOnNavmesh(owner, ownerPosition, navmeshTolerance, pointOnNavmesh) {
        ScriptExecutionContext.SetMappingValue(context, this.m_outStatusArgument, ToVariant(false));
      } else {
        ScriptExecutionContext.SetMappingValue(context, this.m_outStatusArgument, ToVariant(true));
        lastValidNavmeshPosition = owner.GetLastValidNavmeshPoint();
        if Vector4.Distance(owner.GetWorldPosition(), lastValidNavmeshPosition) <= TDB.GetFloat(t"AIGeneralSettings.ragdollRecoveryMinDistanceThreshold") {
          foundPointOnNavmesh = true;
          ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(lastValidNavmeshPosition));
        } else {
          isFriendlyToPlayer = Equals(owner.GetAttitudeTowards(GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject()), EAIAttitude.AIA_Friendly);
          navmeshProbeDimensions = TDB.GetFloatArray(t"AIGeneralSettings.ragdollRecoveryNavmeshProbeDimensions");
          navmeshTolerance = new Vector4(navmeshProbeDimensions[0], navmeshProbeDimensions[1], navmeshProbeDimensions[2], navmeshProbeDimensions[3]);
          numberOfProbes = TDB.GetInt(t"AIGeneralSettings.numberOfProbesPerDistance");
          GameInstance.GetAINavigationSystem(owner.GetGame()).IsPointOnNavmesh(owner, owner.GetLastValidNavmeshPoint(), navmeshTolerance, lastValidNavmeshPosition);
          if isFriendlyToPlayer {
            navmeshProbeDistances = TDB.GetFloatArray(t"AIGeneralSettings.navmeshProbeDistancesFriendly");
          } else {
            navmeshProbeDistances = TDB.GetFloatArray(t"AIGeneralSettings.navmeshProbeDistancesNonFriendly");
          };
          i = 0;
          while i < ArraySize(navmeshProbeDistances) {
            if GameInstance.GetAINavigationSystem(owner.GetGame()).TryToFindNavmeshPointAroundPoint(owner, ownerPosition, Quaternion.BuildFromDirectionVector(lastValidNavmeshPosition - ownerPosition, owner.GetWorldUp()), navmeshTolerance, numberOfProbes, navmeshProbeDistances[i], pointOnNavmesh, false) {
              foundPointOnNavmesh = true;
              ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(pointOnNavmesh));
            } else {
              i += 1;
            };
          };
          if (Equals(owner.GetPuppetRarity().Type(), gamedataNPCRarity.Boss) || isFriendlyToPlayer) && !foundPointOnNavmesh {
            navmeshProbeDimensions = TDB.GetFloatArray(t"AIGeneralSettings.lastValidNavmeshPosProbeDimensions");
            navmeshTolerance = new Vector4(navmeshProbeDimensions[0], navmeshProbeDimensions[1], navmeshProbeDimensions[2], navmeshProbeDimensions[3]);
            if !Vector4.IsZero(lastValidNavmeshPosition) && GameInstance.GetAINavigationSystem(owner.GetGame()).IsPointOnNavmesh(owner, lastValidNavmeshPosition, navmeshTolerance, pointOnNavmesh) {
              foundPointOnNavmesh = true;
              ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(pointOnNavmesh));
            };
          };
          if isFriendlyToPlayer && !foundPointOnNavmesh {
            if !foundPointOnNavmesh && GameInstance.GetAINavigationSystem(owner.GetGame()).GetNearestNavmeshPointBehind(GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerControlledGameObject(), navmeshTolerance.Z, numberOfProbes, pointOnNavmesh, true) {
              foundPointOnNavmesh = true;
              ScriptExecutionContext.SetMappingValue(context, this.m_outPositionArgument, ToVariant(pointOnNavmesh));
            };
          };
        };
        ScriptExecutionContext.SetMappingValue(context, this.m_outPositionStatusArgument, ToVariant(foundPointOnNavmesh));
      };
    };
  }
}

public class AIRagdollDelegate extends ScriptBehaviorDelegate {

  public let ragdollInstigator: wref<GameObject>;

  public let closestNavmeshPoint: Vector4;

  public let ragdollOutOfNavmesh: Bool;

  public let isUnderwater: Bool;

  public let poseAllowsRecovery: Bool;

  public final func DoGetRagdollInstigator(context: ScriptExecutionContext) -> Bool {
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if IsDefined(owner) {
      if owner.GetRagdollInstigator(this.ragdollInstigator) {
        ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", this.ragdollInstigator);
        return true;
      };
    };
    return false;
  }

  public final func DoCheckWaterLevel(context: ScriptExecutionContext) -> Bool {
    let npc: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    return IsDefined(npc) && npc.KillIfUnderwater();
  }

  public final func DoCheckIfPoseAllowsRecovery(context: ScriptExecutionContext) -> Bool {
    let chestWorldTransform: WorldTransform;
    let floorAngle: Float;
    let hipsWorldTransform: WorldTransform;
    let legLeftWorldTransform: WorldTransform;
    let legRightWorldTransform: WorldTransform;
    let legsWorldPosition: Vector4;
    let owner: ref<NPCPuppet> = ScriptExecutionContext.GetOwner(context) as NPCPuppet;
    if IsDefined(owner) && Equals(owner.GetNPCType(), gamedataNPCType.Human) && owner.IsIncapacitated() {
      if owner.GetSlotComponent().GetSlotTransform(n"Hips", hipsWorldTransform) {
        if !this.HasSpaceToRecover(owner, TDB.GetFloatArray(t"AIGeneralSettings.ragdollRecoveryEnviroProbeDimensions"), hipsWorldTransform) {
          this.poseAllowsRecovery = false;
          return false;
        };
        if owner.GetSlotComponent().GetSlotTransform(n"Chest", chestWorldTransform) && owner.GetSlotComponent().GetSlotTransform(n"LegRight", legRightWorldTransform) && owner.GetSlotComponent().GetSlotTransform(n"LegLeft", legLeftWorldTransform) {
          legsWorldPosition = (WorldPosition.ToVector4(WorldTransform.GetWorldPosition(legRightWorldTransform)) + WorldPosition.ToVector4(WorldTransform.GetWorldPosition(legLeftWorldTransform))) / 2.00;
          if !this.TorsoAngleWithinParamters(TDB.GetFloat(t"AIGeneralSettings.ragdollRecoveryMaxAllowedTorsoAngle"), WorldPosition.ToVector4(WorldTransform.GetWorldPosition(hipsWorldTransform)), WorldPosition.ToVector4(WorldTransform.GetWorldPosition(chestWorldTransform)), legsWorldPosition) {
            this.poseAllowsRecovery = false;
            return false;
          };
        };
      };
      if SpatialQueriesHelper.GetFloorAngle(owner, floorAngle) && floorAngle >= TDB.GetFloat(t"AIGeneralSettings.ragdollRecoveryMaxAllowedFloorAngle") {
        this.poseAllowsRecovery = false;
        return false;
      };
    };
    this.poseAllowsRecovery = true;
    return true;
  }

  private final func HasSpaceToRecover(owner: ref<NPCPuppet>, queryDimensions: array<Float>, originTransform: WorldTransform) -> Bool {
    let fitTestOvelap: TraceResult;
    let overlapSuccessDynamic: Bool;
    let overlapSuccessStatic: Bool;
    let overlapSuccessVehicle: Bool;
    let queryOrientation: EulerAngles;
    let queryPosition: Vector4;
    let queryPositionTrace: TraceResult;
    let vehicleCheckTrace: TraceResult;
    let queryExtents: Vector4 = new Vector4(queryDimensions[0] * 0.50, queryDimensions[1] * 0.50, queryDimensions[2] * 0.50, queryDimensions[3]);
    let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(owner.GetGame());
    GameInstance.GetSpatialQueriesSystem(owner.GetGame()).SyncRaycastByCollisionPreset(WorldPosition.ToVector4(WorldTransform.GetWorldPosition(originTransform)) + new Vector4(0.00, 0.00, 0.10, 0.00), WorldPosition.ToVector4(WorldTransform.GetWorldPosition(originTransform)) + new Vector4(0.00, 0.00, -0.70, 0.00), n"Vehicle Chassis", vehicleCheckTrace);
    if TraceResult.IsValid(vehicleCheckTrace) {
      return false;
    };
    GameInstance.GetSpatialQueriesSystem(owner.GetGame()).SyncRaycastByCollisionPreset(WorldPosition.ToVector4(WorldTransform.GetWorldPosition(originTransform)) + new Vector4(0.00, 0.00, 0.10, 0.00), WorldPosition.ToVector4(WorldTransform.GetWorldPosition(originTransform)) + new Vector4(0.00, 0.00, -5.00, 0.00), n"World Static", queryPositionTrace);
    if TraceResult.IsValid(queryPositionTrace) {
      queryPosition = Cast(queryPositionTrace.position);
    } else {
      queryPosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(originTransform));
    };
    queryPosition.Z += queryExtents.Z + 0.10;
    queryOrientation = Quaternion.ToEulerAngles(owner.GetWorldOrientation());
    overlapSuccessStatic = sqs.Overlap(queryExtents, queryPosition, queryOrientation, n"Static", fitTestOvelap);
    overlapSuccessDynamic = sqs.Overlap(queryExtents, queryPosition, queryOrientation, n"Dynamic", fitTestOvelap);
    overlapSuccessVehicle = sqs.Overlap(queryExtents, queryPosition, queryOrientation, n"Vehicle", fitTestOvelap);
    return !overlapSuccessStatic && !overlapSuccessDynamic && !overlapSuccessVehicle;
  }

  private final func TorsoAngleWithinParamters(maxAllowedAngle: Float, hipsPosition: Vector4, chestPosition: Vector4, legsPosition: Vector4) -> Bool {
    let torsoAngle: Float = 180.00 - Vector4.GetAngleBetween(chestPosition - hipsPosition, legsPosition - hipsPosition);
    if torsoAngle > maxAllowedAngle {
      return false;
    };
    return true;
  }

  public final func DoClearActiveStatusEffect(context: ScriptExecutionContext) -> Bool {
    let removeStatusEffectEvent: ref<RemoveStatusEffectEvent>;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if ScriptedPuppet.IsDefeated(puppet) || !ScriptedPuppet.IsAlive(puppet) || StatusEffectSystem.ObjectHasStatusEffect(puppet, t"BaseStatusEffect.Unconscious") {
      StatusEffectHelper.RemoveStatusEffect(puppet, t"BaseStatusEffect.NonInteractable");
    } else {
      removeStatusEffectEvent = new RemoveStatusEffectEvent();
      removeStatusEffectEvent.effectID = t"BaseStatusEffect.NonInteractable";
      GameInstance.GetDelaySystem(puppet.GetGame()).DelayEvent(puppet, removeStatusEffectEvent, 1.25, true);
    };
    return true;
  }

  public final func DoHandleDownedSignals(context: ScriptExecutionContext) -> Bool {
    let signalID: Uint32;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    let signalHandler: ref<AISignalHandlerComponent> = puppet.GetSignalHandlerComponent();
    if StatusEffectSystem.ObjectHasStatusEffectOfType(puppet, gamedataStatusEffectType.Defeated) && !signalHandler.IsHighestPriority(EnumValueToName(n"gamedataStatusEffectType", EnumInt(gamedataStatusEffectType.Defeated)), signalID) {
      this.SendDownedSignal(context, puppet, EnumValueToName(n"gamedataStatusEffectType", EnumInt(gamedataStatusEffectType.Defeated)));
    } else {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(puppet, gamedataStatusEffectType.DefeatedWithRecover) {
        this.SendStatusEffectSignal(context, puppet, EnumValueToName(n"gamedataStatusEffectType", EnumInt(gamedataStatusEffectType.DefeatedWithRecover)));
      } else {
        if !ScriptedPuppet.IsAlive(puppet) && !signalHandler.IsHighestPriority(n"death", signalID) {
          this.SendDownedSignal(context, puppet, n"death");
        };
      };
    };
    ScriptExecutionContext.SetArgumentObject(context, n"StimTarget", null);
    return true;
  }

  private final func SendStatusEffectSignal(context: ScriptExecutionContext, puppet: ref<ScriptedPuppet>, seTypeTag: CName) -> Void {
    let signal: AIGateSignal;
    signal.priority = 9.00;
    signal.lifeTime = RPGManager.GetStatRecord(gamedataStatType.MaxDuration).Max();
    AIGateSignal.AddTag(signal, n"reactive");
    AIGateSignal.AddTag(signal, n"statusEffects");
    AIGateSignal.AddTag(signal, seTypeTag);
    puppet.GetSignalHandlerComponent().AddSignal(signal, false);
  }

  private final func SendDownedSignal(context: ScriptExecutionContext, puppet: ref<ScriptedPuppet>, downedTypeTag: CName) -> Void {
    let signal: AIGateSignal;
    signal.priority = 9.00;
    signal.lifeTime = RPGManager.GetStatRecord(gamedataStatType.MaxDuration).Max();
    AIGateSignal.AddTag(signal, n"downed");
    AIGateSignal.AddTag(signal, downedTypeTag);
    puppet.GetSignalHandlerComponent().AddSignal(signal, false);
  }

  public final func DoHandleRagdollReaction(context: ScriptExecutionContext) -> Bool {
    let broadcaster: ref<StimBroadcasterComponent>;
    let investigateData: stimInvestigateData;
    let puppet: ref<ScriptedPuppet> = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
    if ScriptedPuppet.IsAlive(puppet) {
      if !IsDefined(this.ragdollInstigator) {
        broadcaster = (GameInstance.GetPlayerSystem(ScriptExecutionContext.GetOwner(context).GetGame()).GetLocalPlayerControlledGameObject() as ScriptedPuppet).GetStimBroadcasterComponent();
      } else {
        if this.ragdollInstigator.GetEntityID() != ScriptExecutionContext.GetOwner(context).GetEntityID() {
          broadcaster = this.ragdollInstigator.GetStimBroadcasterComponent();
        };
      };
      if IsDefined(broadcaster) {
        investigateData.skipReactionDelay = true;
        investigateData.skipInitialAnimation = true;
        broadcaster.SendDrirectStimuliToTarget(ScriptExecutionContext.GetOwner(context), gamedataStimType.Combat, ScriptExecutionContext.GetOwner(context), investigateData);
      };
      this.ragdollInstigator = null;
    };
    return true;
  }
}

public class RemoveStatusEffectsOnStoryTier extends StatusEffectTasks {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    let appliedEffects: array<ref<StatusEffect>> = StatusEffectHelper.GetAppliedEffects(ScriptExecutionContext.GetOwner(context));
    let i: Int32 = 0;
    while i < ArraySize(appliedEffects) {
      if appliedEffects[i].GetRecord().RemoveOnStoryTier() {
        StatusEffectHelper.RemoveStatusEffect(ScriptExecutionContext.GetOwner(context), appliedEffects[i]);
      };
      i += 1;
    };
  }
}

public class ForceAnimationOffScreen extends AIbehaviortaskScript {

  protected func Activate(context: ScriptExecutionContext) -> Void {
    GameObject.ToggleForcedVisibilityInAnimSystemEvent(ScriptExecutionContext.GetOwner(context), n"AIForceAnimationOffScreenTask", true);
  }

  protected func Deactivate(context: ScriptExecutionContext) -> Void {
    GameObject.ToggleForcedVisibilityInAnimSystemEvent(ScriptExecutionContext.GetOwner(context), n"AIForceAnimationOffScreenTask", false);
  }
}
