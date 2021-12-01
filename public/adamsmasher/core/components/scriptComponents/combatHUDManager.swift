
public class EffectExecutor_GameObjectOutline extends EffectExecutor_Scripted {

  public edit let m_outlineType: EOutlineType;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let data: OutlineData;
    let evt: ref<OutlineRequestEvent>;
    let id: CName;
    let target: ref<Entity>;
    if Equals(this.m_outlineType, EOutlineType.RED) {
      id = n"EffectExecutor_GameObjectOutline_RED";
    } else {
      id = n"EffectExecutor_GameObjectOutline_GREEN";
    };
    target = EffectExecutionScriptContext.GetTarget(applierCtx);
    evt = new OutlineRequestEvent();
    data.outlineType = this.m_outlineType;
    data.outlineStrength = 1.00;
    evt.outlineRequest = OutlineRequest.CreateRequest(id, true, data);
    target.QueueEvent(evt);
    return true;
  }
}

public class AddTargetToHighlightEvent extends Event {

  public let m_target: CombatTarget;

  public final func Create(puppet: ref<ScriptedPuppet>) -> Void {
    this.m_target.m_puppet = puppet;
    this.m_target.m_hasTime = false;
  }

  public final func Create(puppet: ref<ScriptedPuppet>, highlightTime: Float) -> Void {
    this.m_target.m_puppet = puppet;
    this.m_target.m_hasTime = true;
    this.m_target.m_highlightTime = highlightTime;
  }
}

public class CombatHUDManager extends ScriptableComponent {

  public let m_isRunning: Bool;

  public let m_targets: array<CombatTarget>;

  @default(CombatHUDManager, 1.0f)
  public let m_interval: Float;

  public let m_timeSinceLastUpdate: Float;

  private final func OnAddTargetToHighlightEvent(evt: ref<AddTargetToHighlightEvent>) -> Void {
    let removeTargetEvent: ref<RemoveTargetFromHighlightEvent>;
    let revealEvent: ref<RevealRequestEvent> = new RevealRequestEvent();
    revealEvent.CreateRequest(true, this.GetOwner().GetEntityID());
    if !this.TargetExists(evt.m_target.m_puppet) {
      evt.m_target.m_puppet.QueueEvent(revealEvent);
      ArrayPush(this.m_targets, evt.m_target);
      if evt.m_target.m_hasTime {
        removeTargetEvent = new RemoveTargetFromHighlightEvent();
        removeTargetEvent.m_target = evt.m_target.m_puppet;
        this.GetDelaySystem().DelayEvent(this.GetOwner(), removeTargetEvent, evt.m_target.m_highlightTime);
      };
    };
  }

  private final func OnRemoveTargetFromHighlightEvent(evt: ref<RemoveTargetFromHighlightEvent>) -> Void {
    let revealEvent: ref<RevealRequestEvent> = new RevealRequestEvent();
    revealEvent.CreateRequest(false, this.GetOwner().GetEntityID());
    if this.TargetExists(evt.m_target) {
      this.RemoveTarget(evt.m_target);
      evt.m_target.QueueEvent(revealEvent);
    };
  }

  private final func TargetExists(puppet: ref<ScriptedPuppet>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_targets) {
      if this.m_targets[i].m_puppet == puppet {
        return true;
      };
      i += 1;
    };
    return false;
  }

  private final func OnToggleChargeHighlightEvent(evt: ref<ToggleChargeHighlightEvent>) -> Void {
    if evt.m_active {
      this.HandleChargeMode();
    } else {
      this.ClearHUD();
    };
  }

  private final func RemoveTarget(target: wref<ScriptedPuppet>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_targets) {
      if this.m_targets[i].m_puppet == target {
        ArrayErase(this.m_targets, i);
      } else {
        i += 1;
      };
    };
  }

  private final func ClearHUD() -> Void {
    let i: Int32;
    let revealRequestEvent: ref<RevealRequestEvent> = new RevealRequestEvent();
    revealRequestEvent.CreateRequest(false, this.GetOwner().GetEntityID());
    i = 0;
    while i < ArraySize(this.m_targets) {
      this.GetOwner().QueueEventForEntityID(this.m_targets[i].m_puppet.GetEntityID(), revealRequestEvent);
      i += 1;
    };
    ArrayClear(this.m_targets);
  }

  private final func DetermineProperHandlingMode(activeWeapon: ref<WeaponObject>) -> Void {
    let triggerMode: ref<TriggerMode_Record> = activeWeapon.GetCurrentTriggerMode();
    let triggerType: gamedataTriggerMode = triggerMode.Type();
    switch triggerType {
      case gamedataTriggerMode.Charge:
        this.HandleChargeMode();
    };
  }

  private final func HandleChargeMode() -> Void {
    let aimForward: Vector4;
    let aimPosition: Vector4;
    let coneAngle: Float;
    let distance: Float;
    let distanceRecord: ref<HudEnhancer_Record>;
    let effectCone: ref<EffectInstance>;
    let effectRaycast: ref<EffectInstance>;
    this.GetTargetingSystem().GetDefaultCrosshairData(this.GetOwner(), aimPosition, aimForward);
    distanceRecord = TweakDBInterface.GetHudEnhancerRecord(t"HudEnhancer.ChargeWeapon");
    distance = distanceRecord.Distance();
    coneAngle = TDB.GetFloat(t"HudEnhancer.ChargeWeapon.coneAngle");
    effectCone = this.GetGameEffectSystem().CreateEffectStatic(n"weaponShoot", n"pierce_preview_cone", this.GetOwner());
    EffectData.SetVector(effectCone.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, aimPosition);
    EffectData.SetVector(effectCone.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, aimForward);
    EffectData.SetFloat(effectCone.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, distance);
    EffectData.SetFloat(effectCone.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.angle, coneAngle);
    effectRaycast = this.GetGameEffectSystem().CreateEffectStatic(n"weaponShoot", n"pierce_preview_raycast", this.GetOwner());
    EffectData.SetVector(effectRaycast.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, aimPosition);
    EffectData.SetVector(effectRaycast.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.forward, aimForward);
    EffectData.SetFloat(effectRaycast.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.range, distance);
    EffectData.SetBool(effectRaycast.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.fallback_weaponPierce, true);
    EffectData.SetFloat(effectRaycast.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.fallback_weaponPierceChargeLevel, 0.00);
  }
}
