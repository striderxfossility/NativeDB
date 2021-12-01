
public class ProjectileLaunchHelper extends IScriptable {

  public final static func SpawnProjectileFromScreenCenter(ownerObject: ref<GameObject>, projectileTemplateName: CName, itemObj: ref<ItemObject>) -> Bool {
    let componentPosition: Vector4;
    let targetComponent: ref<IPlacedComponent>;
    let targetingSystem: ref<TargetingSystem> = GameInstance.GetTargetingSystem(ownerObject.GetGame());
    let launchEvent: ref<gameprojectileSpawnerLaunchEvent> = new gameprojectileSpawnerLaunchEvent();
    launchEvent.launchParams.logicalPositionProvider = targetingSystem.GetDefaultCrosshairPositionProvider(ownerObject);
    launchEvent.launchParams.logicalOrientationProvider = targetingSystem.GetDefaultCrosshairOrientationProvider(ownerObject);
    launchEvent.templateName = projectileTemplateName;
    launchEvent.owner = ownerObject;
    if NotEquals(projectileTemplateName, n"knife") {
      targetComponent = ProjectileTargetingHelper.GetTargetingComponent(ownerObject, TSQ_NPC());
      if IsDefined(targetComponent) {
        componentPosition = ProjectileTargetingHelper.GetTargetingComponentsWorldPosition(targetComponent);
        launchEvent.projectileParams.trackedTargetComponent = targetComponent;
        launchEvent.projectileParams.targetPosition = componentPosition;
      };
    };
    itemObj.QueueEvent(launchEvent);
    return true;
  }

  public final static func SetLinearLaunchTrajectory(projectileComponent: ref<ProjectileComponent>, velocity: Float) -> Bool {
    let linearParams: ref<LinearTrajectoryParams>;
    if velocity <= 0.00 {
      return false;
    };
    linearParams = new LinearTrajectoryParams();
    linearParams.startVel = velocity;
    projectileComponent.AddLinear(linearParams);
    return true;
  }

  public final static func SetParabolicLaunchTrajectory(projectileComponent: ref<ProjectileComponent>, gravitySimulation: Float, velocity: Float, energyLossFactorAfterCollision: Float) -> Bool {
    let parabolicParams: ref<ParabolicTrajectoryParams>;
    if velocity <= 0.00 {
      return false;
    };
    parabolicParams = ParabolicTrajectoryParams.GetAccelVelParabolicParams(new Vector4(0.00, 0.00, gravitySimulation, 0.00), velocity);
    projectileComponent.SetEnergyLossFactor(energyLossFactorAfterCollision, energyLossFactorAfterCollision);
    projectileComponent.AddParabolic(parabolicParams);
    return true;
  }

  public final static func SetCurvedLaunchTrajectory(projectileComponent: ref<ProjectileComponent>, opt targetObject: wref<GameObject>, targetComponent: ref<IPlacedComponent>, startVelocity: Float, linearTimeRatio: Float, interpolationTimeRatio: Float, returnTimeMargin: Float, bendTimeRatio: Float, bendFactor: Float, halfLeanAngle: Float, endLeanAngle: Float, angleInterpolationDuration: Float) -> Bool {
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    if !IsDefined(targetComponent) && !IsDefined(targetObject) || startVelocity <= 0.00 || linearTimeRatio <= 0.00 || interpolationTimeRatio <= 0.00 {
      return false;
    };
    followCurveParams.startVelocity = startVelocity;
    followCurveParams.linearTimeRatio = linearTimeRatio;
    followCurveParams.interpolationTimeRatio = interpolationTimeRatio;
    followCurveParams.returnTimeMargin = returnTimeMargin;
    followCurveParams.bendTimeRatio = bendTimeRatio;
    followCurveParams.bendFactor = bendFactor;
    followCurveParams.halfLeanAngle = halfLeanAngle;
    followCurveParams.endLeanAngle = endLeanAngle;
    followCurveParams.angleInterpolationDuration = angleInterpolationDuration;
    followCurveParams.targetComponent = targetComponent;
    followCurveParams.target = targetObject;
    projectileComponent.AddFollowCurve(followCurveParams);
    return true;
  }

  public final static func SetCustomTargetPositionToFollow(projectileComponent: ref<ProjectileComponent>, localToWorld: Matrix, startVelocity: Float, distance: Float, sideOffset: Float, height: Float, linearTimeRatio: Float, interpolationTimeRatio: Float, returnTimeMargin: Float, bendTimeRatio: Float, bendFactor: Float, accuracy: Float, halfLeanAngle: Float, endLeanAngle: Float, angleInterpolationDuration: Float) -> Bool {
    let customTargetPosition: Vector4;
    let followCurveParams: ref<FollowCurveTrajectoryParams> = new FollowCurveTrajectoryParams();
    if startVelocity <= 0.00 {
      return false;
    };
    followCurveParams.startVelocity = startVelocity;
    followCurveParams.linearTimeRatio = linearTimeRatio;
    followCurveParams.interpolationTimeRatio = interpolationTimeRatio;
    followCurveParams.returnTimeMargin = returnTimeMargin;
    followCurveParams.bendTimeRatio = bendTimeRatio;
    followCurveParams.bendFactor = bendFactor;
    followCurveParams.accuracy = accuracy;
    followCurveParams.halfLeanAngle = halfLeanAngle;
    followCurveParams.endLeanAngle = endLeanAngle;
    followCurveParams.angleInterpolationDuration = angleInterpolationDuration;
    customTargetPosition = Matrix.GetTranslation(localToWorld) + Matrix.GetAxisY(localToWorld) * distance - Matrix.GetAxisX(localToWorld) * sideOffset + Matrix.GetAxisZ(localToWorld) * height;
    followCurveParams.targetPosition = customTargetPosition;
    projectileComponent.AddFollowCurve(followCurveParams);
    return true;
  }
}

public class ProjectileGameEffectHelper extends IScriptable {

  public final static func FillProjectileHitAoEData(source: wref<GameObject>, instigator: wref<GameObject>, position: Vector4, radius: Float, opt attackRecord: ref<Attack_Record>, opt weapon: wref<WeaponObject>) -> Bool {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let flag: SHitFlag;
    let hitFlags: array<SHitFlag>;
    let i: Int32;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = attackRecord;
    attackContext.instigator = instigator;
    attackContext.source = source;
    attackContext.weapon = weapon;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(instigator);
    if !IsDefined(attack) {
      return false;
    };
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, radius);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, radius);
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    i = 0;
    while i < attackRecord.GetHitFlagsCount() {
      flag.flag = IntEnum(Cast(EnumValueFromString("hitFlag", attackRecord.GetHitFlagsItem(i))));
      flag.source = n"Attack";
      ArrayPush(hitFlags, flag);
      i += 1;
    };
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.flags, ToVariant(hitFlags));
    attack.StartAttack();
    return true;
  }

  public final static func FillProjectileHitData(source: wref<GameObject>, user: wref<GameObject>, projectileComponent: ref<ProjectileComponent>, eventData: ref<gameprojectileHitEvent>) -> Bool {
    let effectData: EffectData;
    let effect: ref<EffectInstance> = projectileComponent.GetGameEffectInstance();
    if !IsDefined(effect) {
      return false;
    };
    effectData = effect.GetSharedData();
    EffectData.SetVariant(effectData, GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    effect.Run();
    return true;
  }

  public final static func RunEffectFromAttack(instigator: wref<GameObject>, source: wref<GameObject>, weapon: wref<WeaponObject>, attackRecord: ref<Attack_Record>, eventData: ref<gameprojectileHitEvent>) -> Bool {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let statMods: array<ref<gameStatModifierData>>;
    attackContext.record = attackRecord;
    attackContext.instigator = instigator;
    attackContext.source = source;
    attackContext.weapon = weapon;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    if !IsDefined(attack) {
      return false;
    };
    attack.GetStatModList(statMods);
    effect = attack.PrepareAttack(instigator);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(attack));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.projectileHitEvent, ToVariant(eventData));
    effect.Run();
    return true;
  }
}

public class ProjectileTargetingHelper extends IScriptable {

  public final static func GetTargetingComponent(ownerObject: wref<GameObject>, filterBy: TargetSearchQuery) -> ref<IPlacedComponent> {
    let angleDist: EulerAngles;
    let component: ref<IPlacedComponent> = GameInstance.GetTargetingSystem(ownerObject.GetGame()).GetComponentClosestToCrosshair(ownerObject, angleDist, filterBy);
    return component;
  }

  public final static func GetTargetingComponentsWorldPosition(targetComponent: ref<IPlacedComponent>) -> Vector4 {
    let componentPositionMatrix: Matrix = targetComponent.GetLocalToWorld();
    let componentPosition: Vector4 = Matrix.GetTranslation(componentPositionMatrix);
    return componentPosition;
  }

  public final static func GetObjectCurrentPosition(obj: wref<GameObject>) -> Vector4 {
    let positionParameter: Variant = ToVariant(obj.GetWorldPosition());
    let objectPosition: Vector4 = FromVariant(positionParameter);
    return objectPosition;
  }
}

public class ProjectileHitHelper extends IScriptable {

  public final static func GetHitObject(hitInstance: gameprojectileHitInstance) -> wref<GameObject> {
    let object: ref<GameObject> = hitInstance.hitObject as GameObject;
    return object;
  }
}

public class ProjectileHelper extends IScriptable {

  public final static func SpawnTrailVFX(projectileComponent: ref<ProjectileComponent>) -> Void {
    projectileComponent.SpawnTrailVFX();
  }

  public final static func FindExplosiveHitAttack(attackRecord: ref<Attack_Record>) -> ref<Attack_GameEffect_Record> {
    let attackProjectile: ref<Attack_Projectile_Record>;
    let explosionAttackRecord: ref<Attack_GameEffect_Record> = null;
    let attackGameEffect: ref<Attack_GameEffect_Record> = attackRecord as Attack_GameEffect_Record;
    if IsDefined(attackGameEffect) {
      explosionAttackRecord = attackGameEffect.ExplosionAttackHandle();
    } else {
      attackProjectile = attackRecord as Attack_Projectile_Record;
      if IsDefined(attackProjectile) {
        explosionAttackRecord = attackProjectile.ExplosionAttackHandle();
      };
    };
    return explosionAttackRecord;
  }

  public final static func GetPSMBlackboardIntVariable(user: wref<GameObject>, id: BlackboardID_Int) -> Int32 {
    let playerPuppet: ref<GameObject> = GameInstance.GetPlayerSystem(user.GetGame()).GetLocalPlayerMainGameObject();
    let blackboardSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(user.GetGame());
    let blackboard: ref<IBlackboard> = blackboardSystem.GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    return blackboard.GetInt(id);
  }

  public final static func SpawnExplosionAttack(attackRecord: ref<Attack_Record>, weapon: wref<WeaponObject>, instigator: wref<GameObject>, source: wref<GameObject>, opt pos: Vector4, opt duration: Float) -> ref<EffectInstance> {
    let attackContext: AttackInitContext;
    let effect: ref<EffectInstance>;
    let effectData: EffectData;
    let effectDataDef: ref<EffectSharedDataDef>;
    let range: Float;
    attackContext.record = attackRecord;
    attackContext.instigator = instigator;
    attackContext.source = source;
    attackContext.weapon = weapon;
    let attack: ref<Attack_GameEffect> = IAttack.Create(attackContext) as Attack_GameEffect;
    if IsDefined(attack) {
      effect = attack.PrepareAttack(instigator);
      range = attackRecord.Range();
      effectData = effect.GetSharedData();
      effectDataDef = GetAllBlackboardDefs().EffectSharedData;
      if range > 0.00 {
        EffectData.SetFloat(effectData, effectDataDef.range, range);
        EffectData.SetFloat(effectData, effectDataDef.radius, range);
      };
      EffectData.SetVector(effect.GetSharedData(), effectDataDef.position, pos);
      if duration > 0.00 {
        EffectData.SetFloat(effectData, effectDataDef.duration, duration);
      };
      EffectData.SetVariant(effectData, effectDataDef.attack, ToVariant(attack));
      GameInstance.GetDebugDrawHistorySystem(instigator.GetGame()).DrawWireSphere(pos, range, new Color(255u, 0u, 0u, 255u), "ProjectileExplosionAttack");
      attack.StartAttack();
    };
    return effect;
  }
}
