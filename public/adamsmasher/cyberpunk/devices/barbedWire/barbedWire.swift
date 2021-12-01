
public class BarbedWire extends ActivatedDeviceTrap {

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as BarbedWireController;
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if IsDefined(activator) && this.CanAttackActivator(activator) && IsDefined(activator as PlayerPuppet) {
      super.OnAreaEnter(evt);
    };
  }

  protected final func CanAttackActivator(activator: wref<GameObject>) -> Bool {
    let validVehicle: wref<VehicleObject>;
    if VehicleComponent.GetVehicle(activator.GetGame(), activator, validVehicle) {
      return false;
    };
    return true;
  }
}

public class TriggerNotifier_BarbedWire extends TriggerNotifier_Script {

  @attrib(customEditor, "TweakDBGroupInheritance;Attacks.Trap_Attack_Base")
  public let attackType: TweakDBID;

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool;

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool;

  protected final func GetInstanceClassName() -> CName {
    return n"TriggerNotifier_BarbedWireInstance";
  }
}

public class TriggerNotifier_BarbedWireInstance extends TriggerNotifier_ScriptInstance {

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activator: wref<GameObject> = EntityGameInterface.GetEntity(evt.activator) as GameObject;
    if IsDefined(activator) && this.CanAttackActivator(activator) {
      this.DoAttack(this.GetNotifier() as TriggerNotifier_BarbedWire.attackType, activator);
    };
  }

  protected final func CanAttackActivator(activator: wref<GameObject>) -> Bool {
    if VehicleComponent.IsMountedToVehicle(activator.GetGame(), activator) {
      return false;
    };
    return true;
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool;

  protected final func DoAttack(attackRecord: TweakDBID, target: ref<GameObject>) -> Void {
    let hitFlags: array<SHitFlag>;
    let attack: ref<Attack_GameEffect> = RPGManager.PrepareGameEffectAttack(target.GetGame(), target, target, attackRecord, hitFlags, target);
    if IsDefined(attack) {
      attack.StartAttack();
    };
  }
}
