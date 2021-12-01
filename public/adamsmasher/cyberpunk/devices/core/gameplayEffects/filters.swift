
public class IsAccessPointFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    if IsDefined(entity as AccessPoint) {
      return true;
    };
    return false;
  }
}

public class IsDeviceTargetValidFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let characterRecord: ref<Character_Record>;
    let data: ref<PuppetForceVisionAppearanceData>;
    let dataVariant: Variant;
    let reactionPreset: gamedataReactionPresetType;
    let target: ref<ScriptedPuppet> = EffectSingleFilterScriptContext.GetEntity(filterCtx) as ScriptedPuppet;
    if target == null || !ScriptedPuppet.IsActive(target) || !target.IsOnAutonomousAI() {
      return false;
    };
    characterRecord = TweakDBInterface.GetCharacterRecord(target.GetRecordID());
    if !IsDefined(characterRecord) {
      return false;
    };
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.forceVisionAppearanceData, dataVariant);
    data = FromVariant(dataVariant);
    if data != null {
      if !this.CanReactOnStimType(target, data.m_stimRecord) {
        return false;
      };
    };
    reactionPreset = characterRecord.ReactionPreset().Type();
    if Equals(reactionPreset, gamedataReactionPresetType.Corpo_Aggressive) || Equals(reactionPreset, gamedataReactionPresetType.Corpo_Passive) || Equals(reactionPreset, gamedataReactionPresetType.Ganger_Aggressive) || Equals(reactionPreset, gamedataReactionPresetType.Ganger_Passive) || Equals(reactionPreset, gamedataReactionPresetType.Police_Aggressive) || Equals(reactionPreset, gamedataReactionPresetType.Police_Passive) || Equals(reactionPreset, gamedataReactionPresetType.Mechanical_Aggressive) || Equals(reactionPreset, gamedataReactionPresetType.Mechanical_Passive) || Equals(reactionPreset, gamedataReactionPresetType.Mechanical_NonCombat) {
      return true;
    };
    return false;
  }

  private final func CanReactOnStimType(puppet: ref<ScriptedPuppet>, stimRecord: ref<Stim_Record>) -> Bool {
    let propagationType: gamedataStimPropagation;
    let returnValue: Bool = true;
    if stimRecord != null {
      propagationType = stimRecord.Propagation().Type();
      if Equals(propagationType, gamedataStimPropagation.Audio) && ScriptedPuppet.IsDeaf(puppet) {
        returnValue = false;
      };
    };
    return returnValue;
  }
}

public class OnlyNearest_AINavPath_Device extends EffectObjectGroupFilter_Scripted {

  public final func Process(out ctx: EffectScriptContext, out filterCtx: EffectGroupFilterScriptContext) -> Bool {
    let data: ref<PuppetForceVisionAppearanceData>;
    let dataVariant: Variant;
    let i: Int32;
    let j: Int32;
    let maxCount: Int32;
    let numAgents: Int32;
    let sortedTarget: ref<ScriptedPuppet>;
    let sortedTargets: array<HandleWithValue>;
    let source: ref<GameObject>;
    let target: ref<ScriptedPuppet>;
    let targets: array<ref<ScriptedPuppet>>;
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.forceVisionAppearanceData, dataVariant);
    data = FromVariant(dataVariant);
    if !IsDefined(data) {
      return false;
    };
    numAgents = EffectGroupFilterScriptContext.GetNumAgents(filterCtx);
    i = 0;
    while i < numAgents {
      target = EffectGroupFilterScriptContext.GetEntity(filterCtx, i) as ScriptedPuppet;
      if IsDefined(target) {
        ArrayPush(targets, target);
      };
      i = i + 1;
    };
    maxCount = data.m_investigationSlots;
    source = EffectScriptContext.GetSource(ctx) as GameObject;
    sortedTargets = this.SortTargetsByDistance(source, targets);
    ArrayClear(filterCtx.resultIndices);
    i = 0;
    while i < ArraySize(sortedTargets) {
      if ArraySize(filterCtx.resultIndices) >= maxCount {
      } else {
        sortedTarget = sortedTargets[i].handle as ScriptedPuppet;
        if sortedTarget != null {
          j = 0;
          while j < numAgents {
            target = EffectGroupFilterScriptContext.GetEntity(filterCtx, j) as ScriptedPuppet;
            if sortedTarget == target {
              ArrayPush(filterCtx.resultIndices, j);
            } else {
              j = j + 1;
            };
          };
        };
        i = i + 1;
      };
    };
    return true;
  }

  private final func SortTargetsByDistance(source: ref<GameObject>, targets: array<ref<ScriptedPuppet>>) -> array<HandleWithValue> {
    let closestNavDist: Float;
    let closestPath: ref<NavigationPath>;
    let currentDistance: Float;
    let j: Int32;
    let navDistance: Float;
    let path: ref<NavigationPath>;
    let singleSortedTarget: HandleWithValue;
    let sortedTargets: array<HandleWithValue>;
    let targetPos: Vector4;
    let posSources: array<Vector4> = (source as Device).GetNodePosition();
    let i: Int32 = 0;
    while i < ArraySize(targets) {
      targetPos = targets[i].GetWorldPosition();
      closestPath = null;
      j = 0;
      while j < ArraySize(posSources) {
        navDistance = Vector4.DistanceSquared(posSources[j], targetPos);
        if navDistance < closestNavDist || closestNavDist == 0.00 {
          path = GameInstance.GetAINavigationSystem(source.GetGame()).CalculatePathForCharacter(targetPos, posSources[j], 0.00, source);
          if IsDefined(path) {
            closestNavDist = navDistance;
            closestPath = path;
          };
        };
        j += 1;
      };
      if !IsDefined(closestPath) {
      } else {
        currentDistance = closestPath.CalculateLength();
        singleSortedTarget.value = currentDistance;
        singleSortedTarget.handle = targets[i];
        ArrayPush(sortedTargets, singleSortedTarget);
      };
      i += 1;
    };
    SortHandleWithValueArray(sortedTargets);
    return sortedTargets;
  }
}

public class IsSourceDeviceActveFilter extends EffectObjectGroupFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, out filterCtx: EffectGroupFilterScriptContext) -> Bool {
    let device: ref<Device> = EffectScriptContext.GetSource(ctx) as Device;
    if !IsDefined(device) || Equals(device.GetCurrentGameplayRole(), IntEnum(1l)) || !device.IsActive() {
      ArrayClear(filterCtx.resultIndices);
    };
    return true;
  }
}

public class CanAIReactToStimTypeFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let puppet: ref<ScriptedPuppet> = EffectSingleFilterScriptContext.GetEntity(filterCtx) as ScriptedPuppet;
    return IsDefined(puppet) && puppet.IsOnAutonomousAI();
  }
}

public class IsDeviceFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    return IsDefined(entity as Device);
  }
}

public class IsPlayerFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    return IsDefined(entity as PlayerPuppet);
  }
}

public class IsCoverDevice extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    return IsDefined(entity as RetractableAd) || IsDefined(entity as RoadBlockTrap);
  }
}

public class IsNotWeakspotFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    if IsDefined(entity as WeakspotObject) {
      return false;
    };
    return true;
  }
}

public class IsNotInstigatorWeakspotFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let weakSpotObjectOwner: ref<Entity>;
    let instigator: ref<Entity> = EffectScriptContext.GetInstigator(ctx);
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let weakSpotObject: ref<WeakspotObject> = entity as WeakspotObject;
    if IsDefined(weakSpotObject) {
      weakSpotObjectOwner = weakSpotObject.GetOwner();
    };
    if IsDefined(entity as WeakspotObject) && weakSpotObjectOwner == instigator {
      return false;
    };
    return true;
  }
}

public class EffectFilter_DamageOverTime extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let cycleDuration: Float;
    let lastTimeApplied: Float;
    let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(EffectScriptContext.GetGameInstance(ctx)));
    EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.dotLastApplicationTime, lastTimeApplied);
    if lastTimeApplied == 0.00 {
      EffectData.SetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.dotLastApplicationTime, currentTime);
      return true;
    };
    EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.dotCycleDuration, cycleDuration);
    if currentTime - lastTimeApplied >= cycleDuration {
      EffectData.SetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.dotLastApplicationTime, currentTime);
      return true;
    };
    return false;
  }
}

public class OnlySingleStatusEffectFromInstigator extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let attack: ref<IAttack>;
    let effects: array<wref<StatusEffectAttackData_Record>>;
    let i: Int32;
    let puppet: ref<NPCPuppet>;
    let variant: Variant;
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.attack, variant);
    attack = FromVariant(variant);
    puppet = EffectSingleFilterScriptContext.GetEntity(filterCtx) as NPCPuppet;
    attack.GetRecord().StatusEffects(effects);
    if IsDefined(puppet) {
      i = 0;
      while i < ArraySize(effects) {
        if StatusEffectHelper.HasStatusEffectFromInstigator(puppet, effects[i].StatusEffect().GetID(), EffectScriptContext.GetInstigator(ctx).GetEntityID()) {
          return false;
        };
        i += 1;
      };
    };
    return true;
  }
}

public class NotInDefeated extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let puppet: ref<NPCPuppet> = EffectSingleFilterScriptContext.GetEntity(filterCtx) as NPCPuppet;
    if IsDefined(puppet) {
      return !StatusEffectSystem.ObjectHasStatusEffect(puppet, t"BaseStatusEffect.Defeated");
    };
    return true;
  }
}

public class IgnoreFriendlyTargets extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let target: wref<GameObject> = EffectSingleFilterScriptContext.GetEntity(filterCtx) as GameObject;
    let targetAsWeakspot: ref<WeakspotObject> = target as WeakspotObject;
    if IsDefined(targetAsWeakspot) {
      target = targetAsWeakspot.GetOwner();
    };
    if Equals(GameObject.GetAttitudeBetween(target, EffectScriptContext.GetInstigator(ctx) as GameObject), EAIAttitude.AIA_Friendly) {
      return false;
    };
    return true;
  }
}

public class IgnorePlayerMountedVehicle extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    let vehicle: ref<VehicleObject> = entity as VehicleObject;
    if IsDefined(vehicle) {
      return !vehicle.IsPlayerMounted();
    };
    return true;
  }
}

public class IgnorePlayerIfMountedToVehicle extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    if IsDefined(entity as PlayerPuppet) {
      return !VehicleComponent.IsMountedToVehicle(EffectScriptContext.GetGameInstance(ctx), entity.GetEntityID());
    };
    return true;
  }
}

public class IgnoreAlreadyAffectedEntities extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let affectedEntities: array<EntityID>;
    let tempVariant: Variant;
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.targets, tempVariant);
    affectedEntities = FromVariant(tempVariant);
    if IsDefined(entity) && !ArrayContains(affectedEntities, entity.GetEntityID()) {
      ArrayPush(affectedEntities, entity.GetEntityID());
      EffectData.SetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.targets, ToVariant(affectedEntities));
      return true;
    };
    return false;
  }
}

public class IsLootContainer extends EffectObjectSingleFilter_Scripted {

  public edit let m_invert: Bool;

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let entity: ref<Entity> = EffectSingleFilterScriptContext.GetEntity(filterCtx);
    if IsDefined(entity as gameLootContainerBase) {
      return this.m_invert ? false : true;
    };
    return this.m_invert ? true : false;
  }
}
