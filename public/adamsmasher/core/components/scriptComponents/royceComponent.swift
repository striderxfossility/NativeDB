
public class RoyceComponent extends ScriptableComponent {

  private let m_owner: wref<NPCPuppet>;

  private let m_npcCollisionComponent: ref<SimpleColliderComponent>;

  public final func OnGameAttach() -> Void {
    this.m_owner = this.GetOwner() as NPCPuppet;
  }

  protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
    let enableColliderEvent: ref<EnableColliderDelayEvent> = new EnableColliderDelayEvent();
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.Defeated") {
      if IsDefined(this.m_npcCollisionComponent) {
        GameInstance.GetDelaySystem(this.m_owner.GetGame()).DelayEvent(this.m_owner, enableColliderEvent, 0.10);
      };
    };
  }

  protected cb func OnDeathAfterDefeatedRoyce(evt: ref<gameDeathEvent>) -> Bool {
    this.m_npcCollisionComponent.Toggle(true);
  }

  protected cb func OnEnableColliderDelayEvent(enableColliderEvent: ref<EnableColliderDelayEvent>) -> Bool {
    this.m_npcCollisionComponent.Toggle(true);
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"npcCollision", n"SimpleColliderComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_npcCollisionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"npcCollision") as SimpleColliderComponent;
  }

  protected cb func OnAudioEvent(evt: ref<AudioEvent>) -> Bool {
    let evtFootstep: ref<HeavyFootstepEvent> = new HeavyFootstepEvent();
    let player: wref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
    if !IsDefined(player) {
      return false;
    };
    if Equals(evt.eventName, n"lcm_npc_exo_") {
      evtFootstep.instigator = this.m_owner;
      evtFootstep.audioEventName = evt.eventName;
      player.QueueEvent(evtFootstep);
    };
  }

  protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
    if (this.GetOwner() as ScriptedPuppet).GetHitReactionComponent().GetHitStimEvent().hitBodyPart == EnumInt(EAIHitBodyPart.Head) {
      this.StartEffect(n"death_head_explode");
      StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Royce.HeadExploded", this.m_owner.GetEntityID());
    };
  }

  private final func StartEffect(effectName: CName) -> Void {
    let spawnEffectEvent: ref<entSpawnEffectEvent> = new entSpawnEffectEvent();
    spawnEffectEvent.effectName = effectName;
    this.m_owner.QueueEvent(spawnEffectEvent);
  }

  protected cb func OnShotOnShield(hitEvent: ref<gameHitEvent>) -> Bool {
    let empty: HitShapeData;
    let hitShapeData: HitShapeData = hitEvent.hitRepresentationResult.hitShapes[0];
    if NotEquals(hitShapeData, empty) && Equals(HitShapeUserDataBase.GetHitReactionZone(hitShapeData.userData as HitShapeUserDataBase), EHitReactionZone.Special) {
      this.StartEffect(n"weakspot_compensating");
    };
  }
}

public class RoyceHealthChangeListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<NPCPuppet>;

  private let m_royceComponent: ref<RoyceComponent>;

  private let m_weakspots: array<wref<WeakspotObject>>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void;
}
