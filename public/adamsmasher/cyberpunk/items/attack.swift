
public native class gameAttackComputed extends IScriptable {

  public final native func GetTotalAttackValue(statPoolType: gamedataStatPoolType) -> Float;

  public final native func GetAttackValue(damageType: gamedataDamageType) -> Float;

  public final native func SetAttackValue(value: Float, opt damageType: gamedataDamageType) -> Void;

  public final native func AddAttackValue(value: Float, opt damageType: gamedataDamageType) -> Void;

  public final native func MultAttackValue(value: Float, opt damageType: gamedataDamageType) -> Void;

  public final native func GetAttackValues() -> array<Float>;

  public final native func SetAttackValues(attackValues: array<Float>) -> Void;

  public final native func GetOriginalAttackValues() -> array<Float>;

  public final func GetDominatingDamageType() -> gamedataDamageType {
    let currentValue: Float;
    let dmgIndex: Int32;
    let highestValue: Float = 0.00;
    let i: Int32 = 0;
    while i < EnumInt(gamedataDamageType.Count) {
      currentValue = this.GetAttackValue(IntEnum(i));
      if currentValue > highestValue {
        highestValue = currentValue;
        dmgIndex = i;
      };
      i += 1;
    };
    return IntEnum(dmgIndex);
  }
}

public native class Attack_Continuous extends Attack_GameEffect {

  public final native func GetRunningContinuousEffect() -> ref<EffectInstance>;

  public func OnTick(weapon: ref<WeaponObject>) -> Void;

  public func OnStop(weapon: ref<WeaponObject>) -> Void;
}

public class Attack_Beam extends Attack_Continuous {

  public func OnTick(weapon: ref<WeaponObject>) -> Void {
    let beamEffect: ref<EffectInstance>;
    if IsDefined(weapon) {
      beamEffect = this.GetRunningContinuousEffect();
      if IsDefined(beamEffect) {
        EffectData.SetVector(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, weapon.GetWorldPosition());
        EffectData.SetVector(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, weapon.GetWorldForward());
        EffectData.SetFloat(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.minRayAngleDiff, 2.00);
      };
    };
  }
}

public class LaserSight extends Attack_Beam {

  private let previousTarget: wref<Entity>;

  public func OnTick(weapon: ref<WeaponObject>) -> Void {
    let beamEffect: ref<EffectInstance>;
    let target: wref<Entity>;
    let targetComponent: wref<IComponent>;
    let targetComponentVariant: Variant;
    this.OnTick(weapon);
    if IsDefined(weapon) {
      beamEffect = this.GetRunningContinuousEffect();
      if IsDefined(beamEffect) {
        EffectData.GetVariant(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.targetComponent, targetComponentVariant);
        if VariantIsValid(targetComponentVariant) {
          targetComponent = FromVariant(targetComponentVariant);
        };
        if IsDefined(targetComponent) {
          target = targetComponent.GetEntity();
        };
        this.HandleTargetEvents(weapon, target);
      };
    };
  }

  public func OnStop(weapon: ref<WeaponObject>) -> Void {
    this.HandleTargetEvents(weapon, null);
  }

  private final func HandleTargetEvents(weapon: ref<WeaponObject>, target: wref<Entity>) -> Void {
    let evt: ref<BeingTargetByLaserSightUpdateEvent>;
    if IsDefined(this.previousTarget) && this.previousTarget != target {
      evt = new BeingTargetByLaserSightUpdateEvent();
      evt.weapon = weapon;
      evt.state = LaserTargettingState.End;
      LogAI("Queue end");
      this.previousTarget.QueueEvent(evt);
    };
    if IsDefined(target) {
      evt = new BeingTargetByLaserSightUpdateEvent();
      evt.weapon = weapon;
      if this.previousTarget != target {
        LogAI("Queue start");
        evt.state = LaserTargettingState.Start;
      } else {
        LogAI("Queue update");
        evt.state = LaserTargettingState.Update;
      };
      target.QueueEvent(evt);
    };
    this.previousTarget = target;
  }
}

public class RoyceLaserSight extends Attack_Beam {

  private let previousTarget: wref<Entity>;

  public func OnTick(weapon: ref<WeaponObject>) -> Void {
    let beamEffect: ref<EffectInstance>;
    let target: wref<Entity>;
    let targetComponent: wref<IComponent>;
    let targetComponentVariant: Variant;
    this.OnTick(weapon);
    if IsDefined(weapon) {
      beamEffect = this.GetRunningContinuousEffect();
      if IsDefined(beamEffect) {
        EffectData.GetVariant(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.targetComponent, targetComponentVariant);
        targetComponent = FromVariant(targetComponentVariant);
        if IsDefined(targetComponent) {
          target = targetComponent.GetEntity();
        };
        this.HandleTargetEvents(weapon, target);
      };
    };
  }

  public func OnStop(weapon: ref<WeaponObject>) -> Void {
    this.HandleTargetEvents(weapon, null);
  }

  private final func HandleTargetEvents(weapon: ref<WeaponObject>, target: wref<Entity>) -> Void {
    let evt: ref<BeingTargetByLaserSightUpdateEvent>;
    if IsDefined(this.previousTarget) && this.previousTarget != target {
      evt = new BeingTargetByLaserSightUpdateEvent();
      evt.weapon = weapon;
      evt.state = LaserTargettingState.End;
      LogAI("Queue end");
      this.previousTarget.QueueEvent(evt);
    };
    if IsDefined(target) {
      evt = new BeingTargetByLaserSightUpdateEvent();
      evt.weapon = weapon;
      if this.previousTarget != target {
        LogAI("Queue start");
        evt.state = LaserTargettingState.Start;
      } else {
        LogAI("Queue update");
        evt.state = LaserTargettingState.Update;
      };
      target.QueueEvent(evt);
    };
    this.previousTarget = target;
  }
}

public class Bombus_Flame_Beam extends Attack_Continuous {

  public func OnTick(weapon: ref<WeaponObject>) -> Void {
    let beamEffect: ref<EffectInstance>;
    if IsDefined(weapon) {
      beamEffect = this.GetRunningContinuousEffect();
      if IsDefined(beamEffect) {
        EffectData.SetVector(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, weapon.GetWorldPosition());
        EffectData.SetVector(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, weapon.GetWorldForward());
        EffectData.SetFloat(beamEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.minRayAngleDiff, 1.00);
      };
    };
  }
}

public static func PreloadGameEffectAttackResources(attackRecord: ref<Attack_GameEffect_Record>, effectSystem: ref<EffectSystem>) -> Void {
  if IsDefined(attackRecord) {
    effectSystem.PreloadStaticEffectResources(attackRecord.EffectName(), attackRecord.EffectTag());
  };
}

public static func ReleaseGameEffectAttackResources(attackRecord: ref<Attack_GameEffect_Record>, effectSystem: ref<EffectSystem>) -> Void {
  if IsDefined(attackRecord) {
    effectSystem.ReleaseStaticEffectResources(attackRecord.EffectName(), attackRecord.EffectTag());
  };
}
