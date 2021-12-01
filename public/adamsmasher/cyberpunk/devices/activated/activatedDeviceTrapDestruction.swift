
public class ActivatedDeviceTrapDestruction extends ActivatedDeviceTrap {

  protected const let m_physicalMeshNames: array<CName>;

  protected let m_physicalMeshes: array<ref<PhysicalMeshComponent>>;

  protected const let m_hideMeshNames: array<CName>;

  protected let m_hideMeshes: array<ref<IPlacedComponent>>;

  protected const let m_hitColliderNames: array<CName>;

  protected let m_hitColliders: array<ref<IPlacedComponent>>;

  protected let m_impulseVector: Vector4;

  protected edit const let physicalMeshImpactVFX: array<FxResource>;

  protected edit const let m_componentsToEnableNames: array<CName>;

  protected let m_componentsToEnable: array<ref<IPlacedComponent>>;

  protected let hitCount: Int32;

  protected let m_wasAttackPerformed: Bool;

  protected let m_alreadyPlayedVFXComponents: array<CName>;

  protected let m_shouldCheckPhysicalCollisions: Bool;

  protected let m_lastEntityHit: wref<IScriptable>;

  protected let m_timeToActivatePhysics: Float;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"animationSlots", n"SlotComponent", false);
    i = 0;
    while i < ArraySize(this.m_physicalMeshNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_physicalMeshNames[i], n"PhysicalMeshComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hideMeshNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_hideMeshNames[i], n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hitColliderNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_hitColliderNames[i], n"IPlacedComponent", true);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_componentsToEnableNames) {
      EntityRequestComponentsInterface.RequestComponent(ri, this.m_componentsToEnableNames[i], n"IPlacedComponent", true);
      i += 1;
    };
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let i: Int32;
    super.OnTakeControl(ri);
    i = 0;
    while i < ArraySize(this.m_physicalMeshNames) {
      ArrayPush(this.m_physicalMeshes, EntityResolveComponentsInterface.GetComponent(ri, this.m_physicalMeshNames[i]) as PhysicalMeshComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hideMeshNames) {
      ArrayPush(this.m_hideMeshes, EntityResolveComponentsInterface.GetComponent(ri, this.m_hideMeshNames[i]) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hitColliderNames) {
      ArrayPush(this.m_hitColliders, EntityResolveComponentsInterface.GetComponent(ri, this.m_hitColliderNames[i]) as IPlacedComponent);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_componentsToEnableNames) {
      ArrayPush(this.m_componentsToEnable, EntityResolveComponentsInterface.GetComponent(ri, this.m_componentsToEnableNames[i]) as IPlacedComponent);
      i += 1;
    };
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ActivatedDeviceController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    if this.GetDevicePS().IsActivated() {
      this.HidePhysicalMeshes();
      this.HideMeshes();
      this.EnableComponents();
    };
  }

  protected cb func OnActivateDevice(evt: ref<ActivateDevice>) -> Bool {
    let vfxEnableTimer: ref<TimerEvent> = new TimerEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, vfxEnableTimer, (this.GetDevicePS() as ActivatedDeviceControllerPS).GetAnimationTime());
    this.ActivatePhysicalMeshes();
    this.HideMeshes();
    this.RefreshAnimation();
    this.SetGameplayRoleToNone();
  }

  protected cb func OnTimerEvent(evt: ref<TimerEvent>) -> Bool {
    this.m_shouldCheckPhysicalCollisions = true;
  }

  protected cb func OnTrapPhysicsActivationEvent(evt: ref<TrapPhysicsActivationEvent>) -> Bool;

  protected final func ActivatePhysicalMeshes() -> Void {
    let rotatedVector: Vector4 = Vector4.RotByAngleXY(this.m_impulseVector, -this.GetWorldYaw());
    let i: Int32 = 0;
    while i < ArraySize(this.m_physicalMeshes) {
      this.m_physicalMeshes[i].CreatePhysicalBodyInterface().SetIsKinematic(false);
      this.m_physicalMeshes[i].CreatePhysicalBodyInterface().AddLinearImpulse(rotatedVector, false);
      i += 1;
    };
    i = 0;
    while i < ArraySize(this.m_hideMeshes) {
      this.m_hideMeshes[i].Toggle(false);
      i += 1;
    };
  }

  protected final func HidePhysicalMeshes() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_physicalMeshes) {
      this.m_physicalMeshes[i].Toggle(false);
      i += 1;
    };
  }

  protected final func EnableComponents() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_physicalMeshes) {
      this.m_componentsToEnable[i].Toggle(true);
      i += 1;
    };
  }

  protected final func HideMeshes() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_hideMeshes) {
      this.m_hideMeshes[i].Toggle(false);
      i += 1;
    };
  }

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool {
    let i: Int32;
    if !this.GetDevicePS().IsDisabled() {
      i = 0;
      while i < ArraySize(this.m_hitColliders) {
        if this.m_hitColliders[i] == evt.hitComponent {
          this.hitCount = this.hitCount + 1;
          if this.hitCount > 0 && !this.GetDevicePS().IsON() {
            (this.GetDevicePS() as ActivatedDeviceControllerPS).ActivateThisDevice();
          };
        };
        i += 1;
      };
    };
  }

  protected cb func OnPhysicalCollisionEvent(evt: ref<PhysicalCollisionEvent>) -> Bool {
    let i: Int32;
    let position: WorldPosition;
    let transform: WorldTransform;
    if !this.m_shouldCheckPhysicalCollisions {
      return false;
    };
    if evt.otherEntity != this && !ArrayContains(this.m_alreadyPlayedVFXComponents, (evt.myComponent as IPlacedComponent).GetName()) {
      this.m_lastEntityHit = evt.otherEntity;
      ArrayPush(this.m_alreadyPlayedVFXComponents, (evt.myComponent as IPlacedComponent).GetName());
      if !this.m_wasAttackPerformed {
        this.DoAttack((this.GetDevicePS() as ActivatedDeviceControllerPS).GetAttackType());
        this.m_wasAttackPerformed = true;
        this.Distract();
      };
      i = 0;
      while i < ArraySize(this.physicalMeshImpactVFX) {
        if FxResource.IsValid(this.physicalMeshImpactVFX[i]) {
          WorldPosition.SetVector4(position, evt.worldPosition);
          WorldTransform.SetWorldPosition(transform, position);
          this.CreateFxInstance(this.physicalMeshImpactVFX[i], transform);
        };
        i += 1;
      };
    };
  }

  public final func GetLastEntityHit() -> wref<IScriptable> {
    return this.m_lastEntityHit;
  }

  private final func CreateFxInstance(resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(this.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  protected func RefreshAnimation() -> Void {
    let m_animFeature: ref<AnimFeature_SimpleDevice>;
    if this.GetDevicePS().IsActivated() {
      m_animFeature = new AnimFeature_SimpleDevice();
      m_animFeature.isOpen = true;
      AnimationControllerComponent.ApplyFeature(this, n"deviceCrates", m_animFeature);
    };
  }
}

public class EffectObjectProvider_PhysicalCollisionTrapEntities extends EffectObjectProvider_Scripted {

  public final func Process(ctx: EffectScriptContext, providerCtx: EffectProviderScriptContext) -> Void {
    let lastEntityHit: wref<IScriptable>;
    let entitiesInArea: array<ref<Entity>> = (EffectScriptContext.GetSource(ctx) as ActivatedDeviceTrap).GetEntitiesInArea();
    let i: Int32 = 0;
    while i < ArraySize(entitiesInArea) {
      EffectProviderScriptContext.AddTarget(ctx, providerCtx, entitiesInArea[i]);
      i += 1;
    };
    lastEntityHit = (EffectScriptContext.GetSource(ctx) as ActivatedDeviceTrapDestruction).GetLastEntityHit();
    if IsDefined(lastEntityHit as ScriptedPuppet) && !ArrayContains(entitiesInArea, lastEntityHit as Entity) {
      EffectProviderScriptContext.AddTarget(ctx, providerCtx, lastEntityHit as Entity);
    };
  }
}
