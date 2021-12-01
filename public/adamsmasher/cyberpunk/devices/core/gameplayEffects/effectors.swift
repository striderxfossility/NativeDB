
public class RemotelyConnectToAccessPoint extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let entity: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    let debugRemoteConnectionEvent: ref<DebugRemoteConnectionEvent> = new DebugRemoteConnectionEvent();
    entity.QueueEvent(debugRemoteConnectionEvent);
    return true;
  }
}

public class EffectExecutor_PuppetForceVisionAppearance extends EffectExecutor_Scripted {

  private final func GetForceVisionAppearanceData(ctx: EffectScriptContext) -> ref<PuppetForceVisionAppearanceData> {
    let data: ref<PuppetForceVisionAppearanceData>;
    let dataVariant: Variant;
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.forceVisionAppearanceData, dataVariant);
    data = FromVariant(dataVariant);
    if data == null {
      data = new PuppetForceVisionAppearanceData();
    };
    return data;
  }

  private final func SetForceVisionAppearanceData(ctx: EffectScriptContext, data: ref<PuppetForceVisionAppearanceData>) -> Void {
    EffectData.SetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.forceVisionAppearanceData, ToVariant(data));
  }

  private final func GetHighlightType(ctx: EffectScriptContext) -> EFocusForcedHighlightType {
    return this.GetForceVisionAppearanceData(ctx).m_highlightType;
  }

  private final func GetOutlineType(ctx: EffectScriptContext) -> EFocusOutlineType {
    return this.GetForceVisionAppearanceData(ctx).m_outlineType;
  }

  private final func GetTransitionTime(ctx: EffectScriptContext) -> Float {
    return this.GetForceVisionAppearanceData(ctx).m_transitionTime;
  }

  private final func GetPriority(ctx: EffectScriptContext) -> EPriority {
    return this.GetForceVisionAppearanceData(ctx).m_priority;
  }

  private final func IsSourceHighlighted(ctx: EffectScriptContext) -> Bool {
    return this.GetForceVisionAppearanceData(ctx).m_sourceHighlighted;
  }

  private final func GetEffectName(ctx: EffectScriptContext) -> String {
    return this.GetForceVisionAppearanceData(ctx).m_effectName;
  }

  public final func Init(ctx: EffectScriptContext) -> Bool {
    let communicationEvent: ref<CommunicationEvent>;
    let source: ref<GameObject> = EffectScriptContext.GetSource(ctx) as GameObject;
    if IsDefined(source) {
      communicationEvent = new CommunicationEvent();
      communicationEvent.name = n"ResetInvestigators";
      source.QueueEvent(communicationEvent);
    };
    return true;
  }

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let source: ref<GameObject> = EffectScriptContext.GetSource(ctx) as GameObject;
    this.UpdateSourceHighlight(source, ctx);
    return true;
  }

  public final func TargetAcquired(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let target: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    let source: ref<GameObject> = EffectScriptContext.GetSource(ctx) as GameObject;
    this.SendForceVisionApperaceEvent(true, target, source, ctx);
  }

  public final func TargetLost(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let target: ref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    let source: ref<GameObject> = EffectScriptContext.GetSource(ctx) as GameObject;
    this.SendForceVisionApperaceEvent(false, target, source, ctx);
  }

  private final func IsSourceValid(source: ref<GameObject>) -> Bool {
    let device: ref<Device> = source as Device;
    if device != null {
      return NotEquals(device.GetCurrentGameplayRole(), IntEnum(1l)) && device.IsActive();
    };
    return true;
  }

  private final func UpdateSourceHighlight(source: wref<GameObject>, ctx: EffectScriptContext) -> Void {
    let isSourceHighlighted: Bool = this.IsSourceHighlighted(ctx);
    let isSourceValid: Bool = this.IsSourceValid(source);
    if !isSourceHighlighted && isSourceValid {
      this.SendForceVisionApperaceEvent(true, source, source, ctx);
    } else {
      if isSourceHighlighted && !isSourceValid {
        this.SendForceVisionApperaceEvent(false, source, source, ctx);
      };
    };
  }

  private final func SendForceVisionApperaceEvent(enable: Bool, owner: wref<GameObject>, source: wref<GameObject>, ctx: EffectScriptContext) -> Void {
    let addTargetEvent: ref<AddForceHighlightTargetEvent>;
    let bbData: ref<PuppetForceVisionAppearanceData>;
    let evt: ref<ForceVisionApperanceEvent>;
    let highlight: ref<FocusForcedHighlightData>;
    let puppet: ref<ScriptedPuppet>;
    let updateInvestEvt: ref<UpdateWillingInvestigators>;
    if owner == null || source == null {
      return;
    };
    evt = new ForceVisionApperanceEvent();
    highlight = new FocusForcedHighlightData();
    updateInvestEvt = new UpdateWillingInvestigators();
    highlight.sourceID = source.GetEntityID();
    highlight.sourceName = StringToName(this.GetEffectName(ctx));
    highlight.highlightType = this.GetHighlightType(ctx);
    highlight.outlineType = this.GetOutlineType(ctx);
    highlight.inTransitionTime = this.GetTransitionTime(ctx);
    highlight.priority = this.GetPriority(ctx);
    highlight.isRevealed = Equals(highlight.highlightType, EFocusForcedHighlightType.DISTRACTION) || Equals(highlight.outlineType, EFocusOutlineType.DISTRACTION);
    evt.forcedHighlight = highlight;
    evt.apply = enable;
    owner.QueueEvent(evt);
    if owner == source {
      bbData = this.GetForceVisionAppearanceData(ctx);
      bbData.m_sourceHighlighted = enable;
      this.SetForceVisionAppearanceData(ctx, bbData);
      return;
    };
    puppet = owner as ScriptedPuppet;
    if enable {
      if IsDefined(puppet) {
        bbData = this.GetForceVisionAppearanceData(ctx);
        if owner != source {
          updateInvestEvt.investigator = owner.GetEntityID();
          source.QueueEvent(updateInvestEvt);
        };
      };
      addTargetEvent = new AddForceHighlightTargetEvent();
      addTargetEvent.targetID = owner.GetEntityID();
      addTargetEvent.effecName = highlight.sourceName;
      source.QueueEvent(addTargetEvent);
    };
  }
}

public class ApplyJammer extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let evt: ref<SetJammedEvent> = new SetJammedEvent();
    let entity: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx) as SensorDevice;
    if IsDefined(entity) {
      evt.newJammedState = true;
      evt.instigator = EffectScriptContext.GetInstigator(ctx) as WeaponObject;
      entity.QueueEvent(evt);
      return true;
    };
    return false;
  }
}

public class ApplyJammerFromCw extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let evt: ref<SensorJammed> = new SensorJammed();
    evt.sensor = EffectExecutionScriptContext.GetTarget(applierCtx) as SensorDevice;
    let entity: ref<Entity> = EffectScriptContext.GetWeapon(ctx);
    entity.QueueEvent(evt);
    return true;
  }
}

public class EMP extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    return true;
  }

  public final func TargetAcquired(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let device: ref<Device>;
    let unpowerEVT: ref<EMPHitEvent>;
    let target: ref<GameObject> = EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject;
    if target == null {
      return;
    };
    if IsDefined(target as ScriptedPuppet) {
      StatusEffectHelper.ApplyStatusEffect(target, t"BaseStatusEffect.EMP");
    };
    device = target as Device;
    if device != null {
      unpowerEVT = new EMPHitEvent();
      device.QueueEvent(unpowerEVT);
    };
  }
}

public class EMPExplosion extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let unpowerEVT: ref<EMPHitEvent>;
    let device: ref<Device> = EffectExecutionScriptContext.GetTarget(applierCtx) as Device;
    if device != null {
      unpowerEVT = new EMPHitEvent();
      device.QueueEvent(unpowerEVT);
    };
    return true;
  }
}

public class EffectExecutor_PingNetwork extends EffectExecutor_Scripted {

  private edit let m_fxResource: FxResource;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let duration: Float;
    let fxResource: FxResource;
    let fxVariant: Variant;
    let linkData: SNetworkLinkData;
    let registerLinkRequest: ref<RegisterPingNetworkLinkRequest>;
    let source: ref<GameObject>;
    let target: ref<GameObject>;
    if this.GetNetworkSystem(ctx).IsPingLinksLimitReached() || !this.GetNetworkSystem(ctx).HasAnyActivePingWithRevealNetwork() {
      return true;
    };
    source = EffectScriptContext.GetSource(ctx) as GameObject;
    target = EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject;
    if !this.IsTargetValid(target, source, ctx) {
      return true;
    };
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.fxResource, fxVariant);
    fxResource = FromVariant(fxVariant);
    if !FxResource.IsValid(fxResource) {
      fxResource = this.m_fxResource;
    };
    EffectData.GetFloat(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.duration, duration);
    registerLinkRequest = new RegisterPingNetworkLinkRequest();
    linkData.masterID = source.GetEntityID();
    linkData.drawLink = true;
    linkData.linkType = ELinkType.FREE;
    linkData.isDynamic = target.IsNetworkLinkDynamic() || source.IsNetworkLinkDynamic();
    linkData.revealMaster = false;
    linkData.revealSlave = false;
    linkData.fxResource = fxResource;
    linkData.isPing = true;
    linkData.permanent = Equals(this.GetNetworkSystem(ctx).GetPingType(source.GetEntityID()), EPingType.SPACE);
    linkData.masterPos = source.GetNetworkBeamEndpoint();
    linkData.slavePos = target.GetNetworkBeamEndpoint();
    linkData.slaveID = target.GetEntityID();
    if !this.GetNetworkSystem(ctx).HasNetworkLink(linkData) {
      ArrayPush(registerLinkRequest.linksData, linkData);
    };
    if ArraySize(registerLinkRequest.linksData) > 0 {
      this.GetNetworkSystem(ctx).QueueRequest(registerLinkRequest);
    };
    return true;
  }

  public final func TargetLost(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void;

  private final func ShouldRevealObject(object: ref<GameObject>) -> Bool {
    let device: ref<Device> = object as Device;
    if IsDefined(device) {
      return device.GetDevicePS().HasNetworkBackdoor();
    };
    return false;
  }

  private final func GetFxResource(object: ref<GameObject>) -> FxResource {
    let resource: FxResource;
    let device: ref<Device> = object as Device;
    if IsDefined(device) {
      if device.GetDevicePS().IsBreached() {
        resource = device.GetFxResourceByKey(n"networkLinkBreached");
      } else {
        resource = device.GetFxResourceByKey(n"networkLinkDefault");
      };
    };
    return resource;
  }

  private final func IsTargetValid(target: ref<GameObject>, source: ref<GameObject>, ctx: EffectScriptContext) -> Bool {
    if source == null || target == null {
      return false;
    };
    if (target as ScriptedPuppet) == null && (target as Device) == null {
      return false;
    };
    if source == target {
      return false;
    };
    if IsDefined(target as PlayerPuppet) || IsDefined(source as PlayerPuppet) {
      return false;
    };
    if IsDefined(target as ItemObject) || IsDefined(source as ItemObject) {
      return false;
    };
    if IsDefined(target as ScriptedPuppet) && IsDefined(source as Device) || IsDefined(source as ScriptedPuppet) && IsDefined(target as Device) {
      return false;
    };
    if IsDefined(target as Device) && !(target as Device).ShouldRevealDevicesGrid() || IsDefined(source as Device) && !(source as Device).ShouldRevealDevicesGrid() {
      return false;
    };
    return true;
  }

  protected final const func GetNetworkSystem(ctx: EffectScriptContext) -> ref<NetworkSystem> {
    return GameInstance.GetScriptableSystemsContainer(EffectScriptContext.GetGameInstance(ctx)).Get(n"NetworkSystem") as NetworkSystem;
  }
}

public class EffectExecutor_MuteBubble extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    return true;
  }

  public final func TargetAcquired(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    if this.IsTargetValid(ctx, applierCtx) {
      GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).ApplyStatusEffect(EffectExecutionScriptContext.GetTarget(applierCtx).GetEntityID(), t"BaseStatusEffect.MuteAudioStims");
      GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).ApplyStatusEffect(EffectExecutionScriptContext.GetTarget(applierCtx).GetEntityID(), t"BaseStatusEffect.JamCommuniations");
    };
  }

  public final func TargetLost(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).RemoveStatusEffect(EffectExecutionScriptContext.GetTarget(applierCtx).GetEntityID(), t"BaseStatusEffect.MuteAudioStims");
    GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).RemoveStatusEffect(EffectExecutionScriptContext.GetTarget(applierCtx).GetEntityID(), t"BaseStatusEffect.JamCommuniations");
  }

  private final const func IsTargetValid(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let statusEffect: Bool = GameInstance.GetStatusEffectSystem(EffectScriptContext.GetGameInstance(ctx)).HasStatusEffect(EffectExecutionScriptContext.GetTarget(applierCtx).GetEntityID(), t"BaseStatusEffect.MuteAudioStims");
    return IsDefined(EffectExecutionScriptContext.GetTarget(applierCtx)) && !statusEffect;
  }
}

public abstract class EffectExecutor_Device extends EffectExecutor_Scripted {

  @default(EffectExecutor_Device, 0.0f)
  public edit let m_maxDelay: Float;

  protected final func QueueEventOnDevice(device: wref<InteractiveDevice>, evt: ref<ActionBool>) -> Void {
    let delay: Float = this.m_maxDelay > 0.00 ? RandRangeF(0.00, this.m_maxDelay) : 0.00;
    if delay > 0.00 {
      GameInstance.GetDelaySystem(device.GetGame()).DelayPSEvent(device.GetDevicePS().GetID(), device.GetDevicePS().GetClassName(), evt, delay);
    } else {
      GameInstance.GetPersistencySystem(device.GetGame()).QueuePSEvent(device.GetDevicePS().GetID(), device.GetDevicePS().GetClassName(), evt);
    };
  }
}

public class EffectExecutor_SetDeviceOFF extends EffectExecutor_Device {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let evt: ref<DeactivateDevice>;
    let device: wref<InteractiveDevice> = EffectExecutionScriptContext.GetTarget(applierCtx) as InteractiveDevice;
    if IsDefined(device) {
      if IsDefined(device as RoadBlockTrap) {
        return false;
      };
      evt = new DeactivateDevice();
      evt.SetProperties();
      this.QueueEventOnDevice(device, evt);
    };
    return true;
  }
}

public class EffectExecutor_SetDeviceON extends EffectExecutor_Device {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let evt: ref<ActivateDevice>;
    let owner: ref<Entity> = EffectScriptContext.GetInstigator(ctx);
    let device: wref<InteractiveDevice> = EffectExecutionScriptContext.GetTarget(applierCtx) as InteractiveDevice;
    if IsDefined(device) {
      if IsDefined(device as RoadBlockTrap) {
      } else {
        if IsDefined(owner) && Vector4.Distance(owner.GetWorldPosition(), device.GetWorldPosition()) <= 3.00 {
          return true;
        };
      };
      evt = new ActivateDevice();
      evt.SetProperties();
      this.QueueEventOnDevice(device, evt);
    };
    return true;
  }
}

public class EffectExecutor_ToggleDevice extends EffectExecutor_Device {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let evt: ref<ToggleActivate>;
    let device: wref<InteractiveDevice> = EffectExecutionScriptContext.GetTarget(applierCtx) as InteractiveDevice;
    if IsDefined(device) {
      evt = new ToggleActivate();
      this.QueueEventOnDevice(device, evt);
    };
    return true;
  }
}

public class EffectExecutor_GrenadeTargetTracker extends EffectExecutor_Scripted {

  public edit const let m_potentialTargetSlots: array<CName>;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    return true;
  }

  public final func TargetAcquired(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let targetAcquiredEvent: ref<GrenadeTrackerTargetAcquiredEvent>;
    let targetSlot: CName;
    let target: ref<NPCPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as NPCPuppet;
    if this.IsTargetValid(target, ctx, applierCtx, targetSlot) {
      targetAcquiredEvent = new GrenadeTrackerTargetAcquiredEvent();
      targetAcquiredEvent.target = target;
      targetAcquiredEvent.targetSlot = targetSlot;
      EffectScriptContext.GetSource(ctx).QueueEvent(targetAcquiredEvent);
    };
  }

  public final func TargetLost(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let targetLostEvent: ref<GrenadeTrackerTargetLostEvent>;
    let target: ref<NPCPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as NPCPuppet;
    if IsDefined(target) {
      targetLostEvent = new GrenadeTrackerTargetLostEvent();
      targetLostEvent.target = target;
      EffectScriptContext.GetSource(ctx).QueueEvent(targetLostEvent);
    };
  }

  private final const func IsTargetValid(target: ref<NPCPuppet>, ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext, out targetSlot: CName) -> Bool {
    if !IsDefined(target) {
      return false;
    };
    if ScriptedPuppet.IsAlive(target) && !ScriptedPuppet.IsDefeated(target) && !ScriptedPuppet.IsUnconscious(target) && !ScriptedPuppet.IsPlayerCompanion(target) && NotEquals(target.GetAttitudeTowards(EffectScriptContext.GetInstigator(ctx) as GameObject), EAIAttitude.AIA_Friendly) && !target.IsCrowd() && this.IsTargetReachable(ctx, target, targetSlot) {
      return true;
    };
    return false;
  }

  private final const func IsTargetReachable(ctx: EffectScriptContext, target: ref<NPCPuppet>, out targetSlot: CName) -> Bool {
    let endPoint: Vector4;
    let i: Int32;
    let slotComponent: ref<SlotComponent>;
    let slotTransform: WorldTransform;
    let sourcePosition: Vector4;
    let startPoint: Vector4;
    if ArraySize(this.m_potentialTargetSlots) == 0 {
      return true;
    };
    sourcePosition = EffectScriptContext.GetSource(ctx).GetWorldPosition();
    slotComponent = target.GetSlotComponent();
    i = 0;
    while i < ArraySize(this.m_potentialTargetSlots) {
      if slotComponent.GetSlotTransform(this.m_potentialTargetSlots[i], slotTransform) {
        if this.GetAngleBetweenSourceUpAndTarget(sourcePosition, WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform))) > 150.00 {
          startPoint = sourcePosition + new Vector4(0.00, 0.00, -0.50, 0.00);
        } else {
          startPoint = sourcePosition + new Vector4(0.00, 0.00, 0.50, 0.00);
        };
        endPoint = WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform)) + Vector4.Normalize(startPoint - WorldPosition.ToVector4(WorldTransform.GetWorldPosition(slotTransform))) * 0.30;
        if this.IsPointReachable(ctx, startPoint, endPoint) {
          targetSlot = this.m_potentialTargetSlots[i];
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  private final const func GetAngleBetweenSourceUpAndTarget(sourcePosition: Vector4, targetPosition: Vector4) -> Float {
    let vectorToTarget: Vector4 = targetPosition - sourcePosition;
    let angle: Float = Vector4.GetAngleBetween(new Vector4(0.00, 0.00, 1.00, 0.00), vectorToTarget);
    return angle;
  }

  private final const func IsPointReachable(ctx: EffectScriptContext, startPoint: Vector4, endPoint: Vector4) -> Bool {
    let raycastResult: TraceResult;
    GameInstance.GetSpatialQueriesSystem(EffectScriptContext.GetGameInstance(ctx)).SyncRaycastByCollisionPreset(startPoint, endPoint, n"World Static", raycastResult);
    return !TraceResult.IsValid(raycastResult);
  }
}

public class EffectExecutor_TrackTargets extends EffectExecutor_Scripted {

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    return true;
  }

  public final func TargetAcquired(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let targetAcquiredEvent: ref<TargetAcquiredEvent>;
    let target: ref<GameObject> = EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject;
    let source: ref<Entity> = EffectScriptContext.GetSource(ctx);
    if this.IsTargetValid(target, ctx, applierCtx) {
      targetAcquiredEvent = new TargetAcquiredEvent();
      targetAcquiredEvent.target = target as ScriptedPuppet;
      source.QueueEvent(targetAcquiredEvent);
    };
  }

  public final func TargetLost(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Void {
    let targetLostEvent: ref<TargetLostEvent>;
    let target: ref<GameObject> = EffectExecutionScriptContext.GetTarget(applierCtx) as GameObject;
    let source: ref<Entity> = EffectScriptContext.GetSource(ctx);
    if this.IsTargetValid(target, ctx, applierCtx) {
      targetLostEvent = new TargetLostEvent();
      targetLostEvent.target = target as ScriptedPuppet;
      source.QueueEvent(targetLostEvent);
    };
  }

  private final const func IsTargetValid(target: ref<GameObject>, ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    if ScriptedPuppet.IsAlive(target as ScriptedPuppet) {
      return true;
    };
    return false;
  }
}

public class EffectExecutor_SendActionSignal extends EffectExecutor_Scripted {

  public edit let m_signalName: CName;

  @default(EffectExecutor_SendActionSignal, 0.0f)
  public edit let m_signalDuration: Float;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let target: ref<NPCPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as NPCPuppet;
    if IsDefined(target) {
      ScriptedPuppet.SendActionSignal(target, this.m_signalName, this.m_signalDuration);
    };
    return true;
  }
}

public class EffectExecutor_VisualEffectAtTarget extends EffectExecutor_Scripted {

  public edit let m_effect: FxResource;

  public edit let m_ignoreTimeDilation: Bool;

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let transform: WorldTransform;
    let worldPosition: WorldPosition;
    let target: ref<Entity> = EffectExecutionScriptContext.GetTarget(applierCtx);
    if IsDefined(target) {
      WorldPosition.SetVector4(worldPosition, target.GetWorldPosition());
      WorldTransform.SetWorldPosition(transform, worldPosition);
      WorldTransform.SetOrientation(transform, target.GetWorldOrientation());
      EffectScriptContext.SpawnEffect(ctx, this.m_effect, transform, this.m_ignoreTimeDilation);
      return true;
    };
    return false;
  }

  public final func Preload(ctx: EffectPreloadScriptContext) -> Void {
    EffectPreloadScriptContext.PreloadFxResource(ctx, this.m_effect);
  }
}
