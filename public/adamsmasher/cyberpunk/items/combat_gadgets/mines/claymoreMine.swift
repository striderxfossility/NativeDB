
public class ClaymoreMine extends WeaponObject {

  private let m_visualComponent: ref<MeshComponent>;

  private let m_triggerAreaIndicator: ref<MeshComponent>;

  private let m_shootCollision: ref<SimpleColliderComponent>;

  private let m_triggerComponent: ref<TriggerComponent>;

  @default(ClaymoreMine, true)
  private let m_alive: Bool;

  @default(ClaymoreMine, false)
  private let m_armed: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ClaymoreMesh", n"MeshComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"TriggerAreaIndicator", n"MeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"ShootCollision", n"SimpleColliderComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_visualComponent = EntityResolveComponentsInterface.GetComponent(ri, n"ClaymoreMesh") as MeshComponent;
    this.m_triggerAreaIndicator = EntityResolveComponentsInterface.GetComponent(ri, n"TriggerAreaIndicator") as MeshComponent;
    this.m_shootCollision = EntityResolveComponentsInterface.GetComponent(ri, n"ShootCollision") as SimpleColliderComponent;
    this.m_triggerComponent = EntityResolveComponentsInterface.GetComponent(ri, n"Trigger") as TriggerComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    let mineArmEvent: ref<MineArmEvent> = new MineArmEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, mineArmEvent, 2.00);
    this.AdjustRotation();
  }

  protected cb func OnProjectileInitialize(eventData: ref<gameprojectileSetUpEvent>) -> Bool;

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let sourceIsPlayer: Bool = evt.attackData.GetInstigator() == GetPlayer(this.GetGame());
    if this.m_alive && sourceIsPlayer {
      this.Explode();
    };
  }

  private final func AdjustRotation() -> Void {
    let normal: Vector4 = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().Mines).GetVector4(GetAllBlackboardDefs().Mines.CurrentNormal);
    let rotation: EulerAngles = Vector4.ToRotation(normal);
    this.m_visualComponent.SetLocalOrientation(EulerAngles.ToQuat(rotation));
    this.m_triggerComponent.SetLocalOrientation(EulerAngles.ToQuat(rotation));
    this.m_shootCollision.SetLocalOrientation(EulerAngles.ToQuat(rotation));
  }

  protected cb func OnAreaEnter(evt: ref<AreaEnteredEvent>) -> Bool {
    let activatorID: EntityID = EntityGameInterface.GetEntity(evt.activator).GetEntityID();
    let sourceIsPlayer: Bool = activatorID == GetPlayer(this.GetGame()).GetEntityID();
    if this.m_armed && this.m_alive && !sourceIsPlayer {
      this.Explode();
    };
  }

  protected cb func OnAreaExit(evt: ref<AreaExitedEvent>) -> Bool;

  private final func Explode() -> Void {
    let despawnEvent: ref<MineDespawnEvent>;
    let explosionRadius: Float = TDB.GetFloat(t"weapons.E3_grenade.damageRadius");
    let impulseRadius: Float = TDB.GetFloat(t"weapons.E3_grenade.physicalImpulseRadius");
    let attackRecord: ref<Attack_Record> = TweakDBInterface.GetAttackRecord(t"Attacks.FragGrenade");
    CombatGadgetHelper.SpawnAttack(this, explosionRadius, attackRecord, GetPlayer(this.GetGame()));
    CombatGadgetHelper.SpawnPhysicalImpulse(this, impulseRadius);
    GameObject.PlayMetadataEvent(this, n"exploded");
    GameInstance.GetAudioSystem(this.GetGame()).PlayShockwave(n"explosion", this.GetWorldPosition());
    this.m_alive = false;
    this.m_visualComponent.Toggle(false);
    despawnEvent = new MineDespawnEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, despawnEvent, 0.50);
  }

  protected cb func OnRelease(evt: ref<MineDespawnEvent>) -> Bool {
    let objectPool: ref<ObjectPoolSystem> = GameInstance.GetObjectPoolSystem(this.GetGame());
    objectPool.Release(this);
  }

  protected cb func OnArmed(evt: ref<MineArmEvent>) -> Bool {
    this.m_armed = true;
  }

  protected cb func OnScanningEvent(evt: ref<ScanningEvent>) -> Bool {
    if Equals(evt.state, gameScanningState.Complete) {
      this.ToggleTriggerAreaIndicator(true);
    };
  }

  protected cb func OnScanningLookedAt(evt: ref<ScanningLookAtEvent>) -> Bool {
    super.OnScanningLookedAt(evt);
    if this.m_scanningComponent.IsScanned() {
      if evt.state {
        this.ToggleTriggerAreaIndicator(evt.state);
      };
    };
  }

  protected final func ToggleTriggerAreaIndicator(visible: Bool) -> Void {
    this.m_triggerAreaIndicator.Toggle(visible);
  }

  protected cb func OnMinePlace(evt: ref<PlaceMineEvent>) -> Bool {
    let item: ItemID = ItemID.FromTDBID(t"Items.claymore_mine");
    let m_position: Vector4 = evt.m_position;
    GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().Mines).SetVector4(GetAllBlackboardDefs().Mines.CurrentNormal, evt.m_normal);
    GameInstance.GetLootManager(this.GetGame()).SpawnItemDrop(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject(), item, m_position);
  }
}
