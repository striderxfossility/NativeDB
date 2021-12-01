
public class Katana extends WeaponObject {

  private edit let m_bentBulletTemplateName: CName;

  private edit let m_bulletBendingReferenceSlotName: CName;

  private let m_colliderComponent: ref<IComponent>;

  private let m_slotComponent: ref<SlotComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"BulletBendingCollider", n"entColliderComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"SlotComponent", n"entSlotComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_colliderComponent = EntityResolveComponentsInterface.GetComponent(ri, n"BulletBendingCollider");
    this.m_slotComponent = EntityResolveComponentsInterface.GetComponent(ri, n"SlotComponent") as SlotComponent;
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    GameObject.PlaySoundEvent(this, n"w_melee_katana_bending_sparks");
    GameObjectEffectHelper.StartEffectEvent(this, n"deflection", false);
    this.QueueEventToPlayerEntity();
  }

  protected final func QueueEventToPlayerEntity() -> Void {
    let playerID: EntityID = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject().GetEntityID();
    let magFieldHit: ref<MagFieldHitEvent> = new MagFieldHitEvent();
    this.QueueEventForEntityID(playerID, magFieldHit);
  }

  public final func GetSlotComponent() -> ref<SlotComponent> {
    return this.m_slotComponent;
  }

  protected cb func OnToggleCollider(evt: ref<ToggleBulletBendingEvent>) -> Bool {
    this.m_colliderComponent.Toggle(evt.m_enabled);
  }

  private final func CalculateBendingVector(hitPosition: Vector4) -> Vector4 {
    let distanceVector: Vector4;
    let referencePosition: Vector4;
    let slotTransform: WorldTransform;
    let bendingFactor: Float = TweakDBInterface.GetFloat(ItemID.GetTDBID(this.GetItemID()) + t".bulletBendingFactor", 1.00);
    if this.m_slotComponent.GetSlotTransform(this.m_bulletBendingReferenceSlotName, slotTransform) {
      referencePosition = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform));
    } else {
      referencePosition = this.GetWorldPosition();
    };
    distanceVector = hitPosition - referencePosition;
    return Vector4.Normalize(distanceVector) * bendingFactor / Vector4.Length2D(distanceVector);
  }
}

public native class gameEffectExecutor_KatanaBulletBending extends EffectExecutor_Scripted {

  public final native func SpawnFX(tag: CName, object: ref<GameObject>, from: Vector4, to: Vector4, attachSlotName: CName) -> Void;

  public final func Process(ctx: EffectScriptContext, target: ref<Entity>, hitPosition: Vector4) -> Void {
    let hitDirection: Vector4;
    let weapon: ref<Katana> = target as Katana;
    EffectData.GetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.forward, hitDirection);
    if IsDefined(weapon) {
      this.SpawnRicochet(weapon, hitPosition, hitDirection);
      EffectData.SetVector(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.raycastEnd, hitPosition);
    };
  }

  private final func SpawnRicochet(katana: ref<Katana>, out hitPosition: Vector4, hitDirection: Vector4) -> Void {
    let hitPositionLocal: Vector4;
    let playerOrientation: Quaternion;
    let ricochetDirection: Vector4;
    let ricochetDirectionLocal: Vector4;
    let slotTransform: WorldTransform;
    let itemRecordPath: TweakDBID = ItemID.GetTDBID(katana.GetItemID());
    let slotName: CName = TweakDBInterface.GetCName(itemRecordPath + t".magneticFieldSlotName", n"");
    let ricochetReferenceOffset: Float = TweakDBInterface.GetFloat(itemRecordPath + t".bulletRicochetReferenceOffset", 0.00);
    let ricochetBendFactor: Float = TweakDBInterface.GetFloat(itemRecordPath + t".bulletRicochetBendFactor", 1.00);
    let bladeLength: Float = TweakDBInterface.GetFloat(itemRecordPath + t".bladeLength", 1.00);
    let ricochetLocalY: Float = TweakDBInterface.GetFloat(itemRecordPath + t".ricochetLocalY", -0.50);
    let ricochetLocalZOffsetMax: Float = TweakDBInterface.GetFloat(itemRecordPath + t".ricochetLocalZOffsetMax", 0.10);
    let hitPositionLogicalLocalOffset: Vector3 = TweakDBInterface.GetVector3(itemRecordPath + t".hitPositionLogicalLocalOffset", new Vector3(0.00, 0.00, 0.00));
    let hitPositionVisualLocalOffset: Vector3 = TweakDBInterface.GetVector3(itemRecordPath + t".hitPositionVisualLocalOffset", new Vector3(0.00, 0.00, 0.00));
    katana.GetSlotComponent().GetSlotTransform(slotName, slotTransform);
    playerOrientation = GetPlayer(GetGameInstance()).GetWorldOrientation();
    WorldTransform.SetOrientation(slotTransform, playerOrientation);
    hitPositionLocal = WorldPosition.ToVector4(WorldTransform.TransformPoint(WorldTransform.GetInverse(slotTransform), hitPosition));
    hitPositionLocal.X = SgnF(hitPositionLocal.X) * 0.01;
    hitPositionLocal.Y = 0.00;
    hitPositionLocal.Z = ClampF(hitPositionLocal.Z + RandNoiseF(0, ricochetLocalZOffsetMax), -bladeLength * 0.50, bladeLength * 0.50);
    hitPositionLocal += new Vector4(hitPositionLogicalLocalOffset.X, hitPositionLogicalLocalOffset.Y, hitPositionLogicalLocalOffset.Z, 0.00);
    ricochetDirectionLocal.X = hitPositionLocal.X;
    ricochetDirectionLocal.Y = ricochetLocalY;
    ricochetDirectionLocal.Z = (hitPositionLocal.Z + ricochetReferenceOffset) * ricochetBendFactor;
    ricochetDirection = Vector4.Normalize(Transform.TransformVector(WorldTransform._ToXForm(slotTransform), ricochetDirectionLocal));
    hitPositionLocal += new Vector4(hitPositionVisualLocalOffset.X, hitPositionVisualLocalOffset.Y, hitPositionVisualLocalOffset.Z, 0.00);
    hitPosition = WorldPosition.ToVector4(WorldTransform.TransformPoint(slotTransform, hitPositionLocal));
    this.SpawnRicochetFx(katana, hitPosition, ricochetDirection, slotName);
  }

  private final func SpawnBeamSpark(katana: ref<Katana>, bladeTransform: Transform, hitPosition: Vector4, slotName: CName) -> Void {
    let positionOnBlade: Vector4;
    let bladePositionOffsetMax: Float = TweakDBInterface.GetFloat(ItemID.GetTDBID(katana.GetItemID()) + t".bladePositionOffsetMax", 0.00);
    let bladeLength: Float = TweakDBInterface.GetFloat(ItemID.GetTDBID(katana.GetItemID()) + t".bladeLength", 1.00);
    let hitPositionLocal: Vector4 = Transform.TransformPoint(Transform.GetInverse(bladeTransform), hitPosition);
    hitPositionLocal.X = 0.00;
    hitPositionLocal.Y = 0.00;
    hitPositionLocal.Z += RandNoiseF(0, bladePositionOffsetMax, -bladePositionOffsetMax);
    hitPositionLocal.Z = ClampF(hitPositionLocal.Z, -bladeLength * 0.50, bladeLength * 0.50);
    positionOnBlade = Transform.TransformPoint(bladeTransform, hitPositionLocal);
    this.SpawnFX(n"lightning", katana, positionOnBlade, hitPosition, slotName);
  }

  private final func SpawnRicochetFx(katana: ref<Katana>, position: Vector4, direction: Vector4, slotName: CName) -> Void {
    let targetPosition: Vector4 = position + Vector4.Normalize(direction) * 50.00;
    this.SpawnFX(n"sparks", katana, position, targetPosition, slotName);
    this.SpawnFX(n"trail", katana, position, targetPosition, slotName);
  }
}
