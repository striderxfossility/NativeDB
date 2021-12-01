
public abstract class DeviceOperationBase extends IScriptable {

  @attrib(category, "Base Data")
  public let operationName: CName;

  @attrib(category, "Base Data")
  public let executeOnce: Bool;

  @attrib(category, "Base Data")
  @default(DeviceOperationBase, true)
  protected persistent let isEnabled: Bool;

  @attrib(category, "Base Data")
  public const let toggleOperations: array<SToggleDeviceOperationData>;

  @attrib(category, "Base Data")
  public let disableDevice: Bool;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.ResolveDisable(this.disableDevice, owner);
    if this.executeOnce {
      this.isEnabled = false;
    };
  }

  public final func SetIsEnabled(enabled: Bool) -> Void {
    this.isEnabled = enabled;
  }

  public final const func IsEnabled() -> Bool {
    return this.isEnabled;
  }

  public func Restore(owner: wref<GameObject>) -> Void;

  private final func ResolveDisable(disable: Bool, owner: wref<GameObject>) -> Void {
    let device: ref<Device>;
    if disable {
      device = owner as Device;
      if device == null {
        return;
      };
      device.GetDevicePS().ForceDisableDevice();
    };
  }
}

public class GenericDeviceOperation extends DeviceOperationBase {

  private let m_fxInstances: array<SVfxInstanceData>;

  public const let transformAnimations: array<STransformAnimationData>;

  public const let VFXs: array<SVFXOperationData>;

  public const let SFXs: array<SSFXOperationData>;

  public const let facts: array<SFactOperationData>;

  public const let components: array<SComponentOperationData>;

  public const let stims: array<SStimOperationData>;

  public const let statusEffects: array<SStatusEffectOperationData>;

  public const let damages: array<SDamageOperationData>;

  public const let items: array<SInventoryOperationData>;

  public let teleport: STeleportOperationData;

  public let meshesAppearence: CName;

  public let playerWorkspot: SWorkspotData;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveVFXs(this.VFXs, owner);
    this.ResolveSFXs(this.SFXs, owner);
    this.ResolveFacts(this.facts, owner);
    this.ResolveComponents(this.components, owner);
    this.ResolveMeshesAppearence(this.meshesAppearence, owner);
    this.ResolveTransformAnimations(this.transformAnimations, owner);
    this.ResolveWorkspots(this.playerWorkspot, owner);
    this.ResolveStims(this.stims, owner);
    this.ResolveStatusEffects(this.statusEffects, owner);
    this.ResolveDamages(this.damages, owner);
    this.ResolveItems(this.items, owner);
    this.ResolveTeleport(this.teleport, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveVFXs(this.VFXs, owner);
    this.ResolveSFXs(this.SFXs, owner);
    this.ResolveComponents(this.components, owner);
    this.ResolveMeshesAppearence(this.meshesAppearence, owner);
    this.ResolveTransformAnimations(this.transformAnimations, owner);
    this.ResolveStims(this.stims, owner);
    this.ResolveStatusEffects(this.statusEffects, owner);
    this.ResolveFacts(this.facts, owner, true);
  }

  private final func ResolveTeleport(teleportArg: STeleportOperationData, owner: wref<GameObject>) -> Void {
    let puppet: ref<GameObject>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    GameInstance.GetTeleportationFacility(owner.GetGame()).TeleportToNode(puppet, teleportArg.nodeRef);
  }

  private final func ResolveItems(itemsArg: array<SInventoryOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let puppet: ref<GameObject>;
    let transactionSystem: ref<TransactionSystem>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    i = 0;
    while i < ArraySize(itemsArg) {
      if Equals(itemsArg[i].operationType, EItemOperationType.ADD) {
        transactionSystem.GiveItem(puppet, ItemID.FromTDBID(itemsArg[i].itemName), itemsArg[i].quantity);
      } else {
        if Equals(itemsArg[i].operationType, EItemOperationType.REMOVE) {
          transactionSystem.RemoveItem(puppet, ItemID.FromTDBID(itemsArg[i].itemName), itemsArg[i].quantity);
        };
      };
      i += 1;
    };
  }

  private final func ResolveVFXs(VFXsArg: array<SVFXOperationData>, owner: wref<GameObject>) -> Void {
    let effectBlackboard: ref<worldEffectBlackboard>;
    let fxInstance: ref<FxInstance>;
    let i: Int32;
    let position: WorldPosition;
    let target: ref<GameEntity>;
    let targetID: EntityID;
    let transform: WorldTransform;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(VFXsArg) {
      targetID = Cast(ResolveNodeRefWithEntityID(VFXsArg[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameEntity;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(VFXsArg[i].operationType, EEffectOperationType.START) {
          if FxResource.IsValid(VFXsArg[i].vfxResource) {
            if !IsNameValid(VFXsArg[i].vfxName) {
              VFXsArg[i].vfxName = StringToName(IntToString(i));
            };
            fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
            if fxInstance != null {
              this.RemoveFxInstance(VFXsArg[i].vfxName);
              fxInstance.Kill();
            };
            WorldPosition.SetVector4(position, target.GetWorldPosition());
            WorldTransform.SetWorldPosition(transform, position);
            fxInstance = this.CreateFxInstance(owner, VFXsArg[i].vfxName, VFXsArg[i].vfxResource, transform);
            fxInstance.SetBlackboardValue(n"change_size", VFXsArg[i].size);
            this.StoreFxInstance(VFXsArg[i].vfxName, fxInstance);
          } else {
            effectBlackboard = new worldEffectBlackboard();
            effectBlackboard.SetValue(n"change_size", VFXsArg[i].size);
            GameObjectEffectHelper.StartEffectEvent(target as GameObject, VFXsArg[i].vfxName, VFXsArg[i].shouldPersist, effectBlackboard);
          };
        } else {
          if Equals(VFXsArg[i].operationType, EEffectOperationType.STOP) {
            fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
            if fxInstance == null {
              GameObjectEffectHelper.StopEffectEvent(target as GameObject, VFXsArg[i].vfxName);
            } else {
              this.RemoveFxInstance(VFXsArg[i].vfxName);
              fxInstance.Kill();
            };
          } else {
            if Equals(VFXsArg[i].operationType, EEffectOperationType.BRAKE_LOOP) {
              fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
              if fxInstance == null {
                GameObjectEffectHelper.BreakEffectLoopEvent(target as GameObject, VFXsArg[i].vfxName);
              } else {
                fxInstance.BreakLoop();
              };
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func ResolveSFXs(SFXsArg: array<SSFXOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(SFXsArg) {
      GameObject.PlaySoundEvent(owner, SFXsArg[i].sfxName);
      i += 1;
    };
  }

  private final func ResolveFacts(factsArg: array<SFactOperationData>, owner: wref<GameObject>, opt restore: Bool) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(factsArg) {
      if IsNameValid(factsArg[i].factName) {
        if Equals(factsArg[i].operationType, EMathOperationType.Add) {
          if !restore || GetFact(owner.GetGame(), factsArg[i].factName) < factsArg[i].factValue {
            AddFact(owner.GetGame(), factsArg[i].factName, factsArg[i].factValue);
          };
        } else {
          SetFactValue(owner.GetGame(), factsArg[i].factName, factsArg[i].factValue);
        };
      };
      i += 1;
    };
  }

  private final func ResolveComponents(componentsData: array<SComponentOperationData>, owner: wref<GameObject>) -> Void {
    let evt: ref<ToggleComponentsEvent> = new ToggleComponentsEvent();
    evt.componentsData = componentsData;
    owner.QueueEvent(evt);
  }

  private final func ResolveMeshesAppearence(appearanceName: CName, owner: wref<GameObject>) -> Void {
    if owner == null {
      return;
    };
    if IsNameValid(appearanceName) {
      GameObject.SetMeshAppearanceEvent(owner, appearanceName);
    };
  }

  private final func ResolveTransformAnimations(animations: array<STransformAnimationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let pauseEvent: ref<gameTransformAnimationPauseEvent>;
    let playEvent: ref<gameTransformAnimationPlayEvent>;
    let resetEvent: ref<gameTransformAnimationResetEvent>;
    let skipEvent: ref<gameTransformAnimationSkipEvent>;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(animations) {
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PLAY) {
        playEvent = new gameTransformAnimationPlayEvent();
        playEvent.animationName = animations[i].animationName;
        playEvent.timeScale = animations[i].playData.timeScale;
        playEvent.looping = animations[i].playData.looping;
        playEvent.timesPlayed = animations[i].playData.timesPlayed;
        owner.QueueEvent(playEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PAUSE) {
        pauseEvent = new gameTransformAnimationPauseEvent();
        pauseEvent.animationName = animations[i].animationName;
        owner.QueueEvent(pauseEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.RESET) {
        resetEvent = new gameTransformAnimationResetEvent();
        resetEvent.animationName = animations[i].animationName;
        owner.QueueEvent(resetEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.SKIP) {
        skipEvent = new gameTransformAnimationSkipEvent();
        skipEvent.animationName = animations[i].animationName;
        skipEvent.time = animations[i].skipData.time;
        skipEvent.skipToEnd = animations[i].skipData.skipToEnd;
        owner.QueueEvent(skipEvent);
        return;
      };
      i += 1;
    };
  }

  private final func ResolveWorkspots(workspot: SWorkspotData, owner: wref<GameObject>) -> Void {
    let player: ref<GameObject>;
    let device: ref<Device> = owner as Device;
    if device == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(device.GetGame()).GetLocalPlayerMainGameObject();
    if player == null {
      return;
    };
    if Equals(workspot.operationType, EWorkspotOperationType.ENTER) {
      if IsNameValid(workspot.componentName) {
        this.EnterWorkspot(device, player, workspot.freeCamera, workspot.componentName);
      };
    } else {
      if Equals(workspot.operationType, EWorkspotOperationType.LEAVE) {
        this.LeaveWorkspot(player);
      };
    };
  }

  private final func ResolveStims(stimsArg: array<SStimOperationData>, owner: wref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let stimType: gamedataStimType;
    let target: ref<GameObject>;
    let targetID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(stimsArg) {
      stimType = Device.MapStimType(stimsArg[i].stimType);
      targetID = Cast(ResolveNodeRefWithEntityID(stimsArg[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameObject;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(stimType, gamedataStimType.Invalid) {
        } else {
          broadcaster = target.GetStimBroadcasterComponent();
          if IsDefined(broadcaster) {
            if Equals(stimsArg[i].operationType, EEffectOperationType.START) {
              broadcaster.SetSingleActiveStimuli(owner, stimType, stimsArg[i].lifeTime, stimsArg[i].radius);
            } else {
              broadcaster.RemoveActiveStimuliByName(owner, stimType);
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func ResolveStatusEffects(statusEffectsArg: array<SStatusEffectOperationData>, owner: wref<GameObject>) -> Void {
    let effect: ref<EffectInstance>;
    let i: Int32;
    let position: Vector4;
    if owner == null {
      return;
    };
    position = owner.GetWorldPosition();
    i = 0;
    while i < ArraySize(statusEffectsArg) {
      if statusEffectsArg[i].range > 0.00 {
        effect = GameInstance.GetGameEffectSystem(owner.GetGame()).CreateEffectStatic(n"applyStatusEffect", n"inRange", owner);
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + statusEffectsArg[i].offset);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, statusEffectsArg[i].range);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, statusEffectsArg[i].duration);
        EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statusEffect, ToVariant(statusEffectsArg[i].effect.statusEffect));
        effect.Run();
      };
      i += 1;
    };
  }

  private final func ResolveDamages(damagesArg: array<SDamageOperationData>, owner: wref<GameObject>) -> Void {
    let attackContext: AttackInitContext;
    let damageEffect: ref<EffectInstance>;
    let explosionAttack: ref<Attack_GameEffect>;
    let i: Int32;
    let player: ref<GameObject>;
    let position: Vector4;
    let statMods: array<ref<gameStatModifierData>>;
    if owner == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    position = owner.GetWorldPosition();
    attackContext.instigator = player;
    attackContext.source = owner;
    i = 0;
    while i < ArraySize(damagesArg) {
      if damagesArg[i].range > 0.00 {
        attackContext.record = TweakDBInterface.GetAttackRecord(damagesArg[i].damageType);
        explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
        damageEffect = explosionAttack.PrepareAttack(owner);
        explosionAttack.GetStatModList(statMods);
        EffectData.SetFloat(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, damagesArg[i].range);
        EffectData.SetVector(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + damagesArg[i].offset);
        EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
        EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
        explosionAttack.StartAttack();
      };
      i += 1;
    };
  }

  protected func EnterWorkspot(target: ref<Device>, activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(target, activator, freeCamera, componentName);
  }

  protected func LeaveWorkspot(activator: ref<GameObject>) -> Void {
    let direction: Vector4;
    let orientation: Quaternion;
    let workspotSystem: ref<WorkspotGameSystem>;
    Quaternion.SetIdentity(orientation);
    direction = new Vector4(0.00, 0.00, 0.00, 1.00);
    workspotSystem = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.StopInDevice(activator, direction, orientation);
  }

  private final func GetFxInstance(id: CName) -> ref<FxInstance> {
    let fx: ref<FxInstance>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        fx = this.m_fxInstances[i].fx;
        if fx == null {
          ArrayErase(this.m_fxInstances, i);
        };
      } else {
        i += 1;
      };
    };
    return fx;
  }

  private final func RemoveFxInstance(id: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        ArrayErase(this.m_fxInstances, i);
      } else {
        i += 1;
      };
    };
  }

  private final func CreateFxInstance(owner: wref<GameObject>, id: CName, resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(owner.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  private final func StoreFxInstance(id: CName, fx: ref<FxInstance>) -> Void {
    let fxInstanceData: SVfxInstanceData;
    fxInstanceData.id = id;
    fxInstanceData.fx = fx;
    ArrayPush(this.m_fxInstances, fxInstanceData);
  }
}

public class ToggleComponentsDeviceOperation extends DeviceOperationBase {

  public const let components: array<SComponentOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveComponents(this.components, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveComponents(this.components, owner);
  }

  private final func ResolveComponents(componentsData: array<SComponentOperationData>, owner: wref<GameObject>) -> Void {
    let evt: ref<ToggleComponentsEvent> = new ToggleComponentsEvent();
    evt.componentsData = componentsData;
    owner.QueueEvent(evt);
  }
}

public class PlayTransformAnimationDeviceOperation extends DeviceOperationBase {

  public const let transformAnimations: array<STransformAnimationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveTransformAnimations(this.transformAnimations, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveTransformAnimations(this.transformAnimations, owner);
  }

  private final func ResolveTransformAnimations(animations: array<STransformAnimationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let pauseEvent: ref<gameTransformAnimationPauseEvent>;
    let playEvent: ref<gameTransformAnimationPlayEvent>;
    let resetEvent: ref<gameTransformAnimationResetEvent>;
    let skipEvent: ref<gameTransformAnimationSkipEvent>;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(animations) {
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PLAY) {
        playEvent = new gameTransformAnimationPlayEvent();
        playEvent.animationName = animations[i].animationName;
        playEvent.timeScale = animations[i].playData.timeScale;
        playEvent.looping = animations[i].playData.looping;
        playEvent.timesPlayed = animations[i].playData.timesPlayed;
        owner.QueueEvent(playEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.PAUSE) {
        pauseEvent = new gameTransformAnimationPauseEvent();
        pauseEvent.animationName = animations[i].animationName;
        owner.QueueEvent(pauseEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.RESET) {
        resetEvent = new gameTransformAnimationResetEvent();
        resetEvent.animationName = animations[i].animationName;
        owner.QueueEvent(resetEvent);
        return;
      };
      if Equals(animations[i].operationType, ETransformAnimationOperationType.SKIP) {
        skipEvent = new gameTransformAnimationSkipEvent();
        skipEvent.animationName = animations[i].animationName;
        skipEvent.time = animations[i].skipData.time;
        skipEvent.skipToEnd = animations[i].skipData.skipToEnd;
        owner.QueueEvent(skipEvent);
        return;
      };
      i += 1;
    };
  }
}

public class FactsDeviceOperation extends DeviceOperationBase {

  public const let facts: array<SFactOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveFacts(this.facts, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveFacts(this.facts, owner, true);
  }

  private final func ResolveFacts(factsArg: array<SFactOperationData>, owner: wref<GameObject>, opt restore: Bool) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(factsArg) {
      if IsNameValid(factsArg[i].factName) {
        if Equals(factsArg[i].operationType, EMathOperationType.Add) {
          if !restore || GetFact(owner.GetGame(), factsArg[i].factName) < factsArg[i].factValue {
            AddFact(owner.GetGame(), factsArg[i].factName, factsArg[i].factValue);
          };
        } else {
          SetFactValue(owner.GetGame(), factsArg[i].factName, factsArg[i].factValue);
        };
      };
      i += 1;
    };
  }
}

public class PlayEffectDeviceOperation extends DeviceOperationBase {

  public const let VFXs: array<SVFXOperationData>;

  private let m_fxInstances: array<SVfxInstanceData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveVFXs(this.VFXs, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveVFXs(this.VFXs, owner);
  }

  private final func ResolveVFXs(VFXsArg: array<SVFXOperationData>, owner: wref<GameObject>) -> Void {
    let effectBlackboard: ref<worldEffectBlackboard>;
    let fxInstance: ref<FxInstance>;
    let i: Int32;
    let position: WorldPosition;
    let target: ref<GameEntity>;
    let targetID: EntityID;
    let transform: WorldTransform;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(VFXsArg) {
      targetID = Cast(ResolveNodeRefWithEntityID(VFXsArg[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameEntity;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(VFXsArg[i].operationType, EEffectOperationType.START) {
          if FxResource.IsValid(VFXsArg[i].vfxResource) {
            if !IsNameValid(VFXsArg[i].vfxName) {
              VFXsArg[i].vfxName = StringToName(IntToString(i));
            };
            fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
            if fxInstance != null {
              this.RemoveFxInstance(VFXsArg[i].vfxName);
              fxInstance.Kill();
            };
            WorldPosition.SetVector4(position, target.GetWorldPosition());
            WorldTransform.SetWorldPosition(transform, position);
            fxInstance = this.CreateFxInstance(owner, VFXsArg[i].vfxName, VFXsArg[i].vfxResource, transform);
            fxInstance.SetBlackboardValue(n"change_size", VFXsArg[i].size);
            this.StoreFxInstance(VFXsArg[i].vfxName, fxInstance);
          } else {
            effectBlackboard = new worldEffectBlackboard();
            effectBlackboard.SetValue(n"change_size", VFXsArg[i].size);
            GameObjectEffectHelper.StartEffectEvent(target as GameObject, VFXsArg[i].vfxName, VFXsArg[i].shouldPersist, effectBlackboard);
          };
        } else {
          if Equals(VFXsArg[i].operationType, EEffectOperationType.STOP) {
            fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
            if fxInstance == null {
              GameObjectEffectHelper.StopEffectEvent(target as GameObject, VFXsArg[i].vfxName);
            } else {
              this.RemoveFxInstance(VFXsArg[i].vfxName);
              fxInstance.Kill();
            };
          } else {
            if Equals(VFXsArg[i].operationType, EEffectOperationType.BRAKE_LOOP) {
              fxInstance = this.GetFxInstance(VFXsArg[i].vfxName);
              if fxInstance == null {
                GameObjectEffectHelper.BreakEffectLoopEvent(target as GameObject, VFXsArg[i].vfxName);
              } else {
                fxInstance.BreakLoop();
              };
            };
          };
        };
      };
      i += 1;
    };
  }

  private final func GetFxInstance(id: CName) -> ref<FxInstance> {
    let fx: ref<FxInstance>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        fx = this.m_fxInstances[i].fx;
        if fx == null {
          ArrayErase(this.m_fxInstances, i);
        };
      } else {
        i += 1;
      };
    };
    return fx;
  }

  private final func RemoveFxInstance(id: CName) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_fxInstances) {
      if Equals(this.m_fxInstances[i].id, id) {
        ArrayErase(this.m_fxInstances, i);
      } else {
        i += 1;
      };
    };
  }

  private final func CreateFxInstance(owner: wref<GameObject>, id: CName, resource: FxResource, transform: WorldTransform) -> ref<FxInstance> {
    let fxSystem: ref<FxSystem> = GameInstance.GetFxSystem(owner.GetGame());
    let fx: ref<FxInstance> = fxSystem.SpawnEffect(resource, transform);
    return fx;
  }

  private final func StoreFxInstance(id: CName, fx: ref<FxInstance>) -> Void {
    let fxInstanceData: SVfxInstanceData;
    fxInstanceData.id = id;
    fxInstanceData.fx = fx;
    ArrayPush(this.m_fxInstances, fxInstanceData);
  }
}

public class StimDeviceOperation extends DeviceOperationBase {

  public const let stims: array<SStimOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.ResolveStims(this.stims, owner);
    if this.executeOnce {
      this.isEnabled = false;
    };
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveStims(this.stims, owner);
  }

  private final func ResolveStims(stimsArg: array<SStimOperationData>, owner: wref<GameObject>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let stimType: gamedataStimType;
    let target: ref<GameObject>;
    let targetID: EntityID;
    let i: Int32 = 0;
    while i < ArraySize(stimsArg) {
      stimType = Device.MapStimType(stimsArg[i].stimType);
      targetID = Cast(ResolveNodeRefWithEntityID(stimsArg[i].nodeRef, owner.GetEntityID()));
      target = GameInstance.FindEntityByID(owner.GetGame(), targetID) as GameObject;
      if target == null {
        target = owner;
      };
      if target == null {
      } else {
        if Equals(stimType, gamedataStimType.Invalid) {
        } else {
          broadcaster = target.GetStimBroadcasterComponent();
          if IsDefined(broadcaster) {
            if Equals(stimsArg[i].operationType, EEffectOperationType.START) {
              broadcaster.SetSingleActiveStimuli(owner, stimType, stimsArg[i].lifeTime, stimsArg[i].radius);
            } else {
              broadcaster.RemoveActiveStimuliByName(owner, stimType);
            };
          };
        };
      };
      i += 1;
    };
  }
}

public class PlaySoundDeviceOperation extends DeviceOperationBase {

  public const let SFXs: array<SSFXOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveSFXs(this.SFXs, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveSFXs(this.SFXs, owner);
  }

  private final func ResolveSFXs(SFXsArg: array<SSFXOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    if owner == null {
      return;
    };
    i = 0;
    while i < ArraySize(SFXsArg) {
      if Equals(SFXsArg[i].operationType, EEffectOperationType.START) {
        GameObject.PlaySound(owner, SFXsArg[i].sfxName);
      } else {
        if Equals(SFXsArg[i].operationType, EEffectOperationType.STOP) {
          GameObject.StopSound(owner, SFXsArg[i].sfxName);
        };
      };
      i += 1;
    };
  }
}

public class ApplyStatusEffectDeviceOperation extends DeviceOperationBase {

  public const let statusEffects: array<SStatusEffectOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveStatusEffects(this.statusEffects, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveStatusEffects(this.statusEffects, owner);
  }

  private final func ResolveStatusEffects(statusEffectsArg: array<SStatusEffectOperationData>, owner: wref<GameObject>) -> Void {
    let effect: ref<EffectInstance>;
    let i: Int32;
    let position: Vector4;
    if owner == null {
      return;
    };
    position = owner.GetWorldPosition();
    i = 0;
    while i < ArraySize(statusEffectsArg) {
      if statusEffectsArg[i].range > 0.00 {
        effect = GameInstance.GetGameEffectSystem(owner.GetGame()).CreateEffectStatic(n"applyStatusEffect", n"inRange", owner);
        EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + statusEffectsArg[i].offset);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, statusEffectsArg[i].range);
        EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.duration, statusEffectsArg[i].duration);
        EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statusEffect, ToVariant(statusEffectsArg[i].effect.statusEffect));
        effect.Run();
      };
      i += 1;
    };
  }
}

public class ApplyDamageDeviceOperation extends DeviceOperationBase {

  public const let damages: array<SDamageOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveDamages(this.damages, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveDamages(this.damages, owner);
  }

  private final func ResolveDamages(damagesArg: array<SDamageOperationData>, owner: wref<GameObject>) -> Void {
    let attackContext: AttackInitContext;
    let attackRecord: ref<Attack_Record>;
    let damageEffect: ref<EffectInstance>;
    let explosionAttack: ref<Attack_GameEffect>;
    let i: Int32;
    let player: ref<GameObject>;
    let position: Vector4;
    let range: Float;
    let statMods: array<ref<gameStatModifierData>>;
    if owner == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    position = owner.GetWorldPosition();
    attackContext.instigator = player;
    attackContext.source = owner;
    i = 0;
    while i < ArraySize(damagesArg) {
      attackRecord = TweakDBInterface.GetAttackRecord(damagesArg[i].damageType);
      if attackRecord == null {
      } else {
        if damagesArg[i].range <= 0.00 {
          range = attackRecord.Range();
        } else {
          range = damagesArg[i].range;
        };
        if range > 0.00 {
          attackContext.record = attackRecord;
          explosionAttack = IAttack.Create(attackContext) as Attack_GameEffect;
          damageEffect = explosionAttack.PrepareAttack(owner);
          explosionAttack.GetStatModList(statMods);
          EffectData.SetFloat(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, range);
          EffectData.SetVector(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, position + damagesArg[i].offset);
          EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attack, ToVariant(explosionAttack));
          EffectData.SetVariant(damageEffect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackStatModList, ToVariant(statMods));
          explosionAttack.StartAttack();
        };
      };
      i += 1;
    };
  }
}

public class ItemsDeviceOperation extends DeviceOperationBase {

  public const let items: array<SInventoryOperationData>;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveItems(this.items, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveItems(this.items, owner);
  }

  private final func ResolveItems(itemsArg: array<SInventoryOperationData>, owner: wref<GameObject>) -> Void {
    let i: Int32;
    let puppet: ref<GameObject>;
    let transactionSystem: ref<TransactionSystem>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    i = 0;
    while i < ArraySize(itemsArg) {
      if Equals(itemsArg[i].operationType, EItemOperationType.ADD) {
        transactionSystem.GiveItem(puppet, ItemID.FromTDBID(itemsArg[i].itemName), itemsArg[i].quantity);
      } else {
        if Equals(itemsArg[i].operationType, EItemOperationType.REMOVE) {
          transactionSystem.RemoveItem(puppet, ItemID.FromTDBID(itemsArg[i].itemName), itemsArg[i].quantity);
        };
      };
      i += 1;
    };
  }
}

public class TeleportDeviceOperation extends DeviceOperationBase {

  public let teleport: STeleportOperationData;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveTeleport(this.teleport, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveTeleport(this.teleport, owner);
  }

  private final func ResolveTeleport(teleportArg: STeleportOperationData, owner: wref<GameObject>) -> Void {
    let puppet: ref<GameObject>;
    if owner == null {
      return;
    };
    puppet = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if puppet == null {
      return;
    };
    GameInstance.GetTeleportationFacility(owner.GetGame()).TeleportToNode(puppet, teleportArg.nodeRef);
  }
}

public class MeshAppearanceDeviceOperation extends DeviceOperationBase {

  public let meshesAppearence: CName;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveMeshesAppearence(this.meshesAppearence, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveMeshesAppearence(this.meshesAppearence, owner);
  }

  private final func ResolveMeshesAppearence(appearanceName: CName, owner: wref<GameObject>) -> Void {
    if owner == null {
      return;
    };
    if IsNameValid(appearanceName) {
      GameObject.SetMeshAppearanceEvent(owner, appearanceName);
    };
  }
}

public class PlayerWokrspotDeviceOperation extends DeviceOperationBase {

  public let playerWorkspot: SWorkspotData;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveWorkspots(this.playerWorkspot, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void;

  private final func ResolveWorkspots(workspot: SWorkspotData, owner: wref<GameObject>) -> Void {
    let player: ref<GameObject>;
    let device: ref<Device> = owner as Device;
    if device == null {
      return;
    };
    player = GameInstance.GetPlayerSystem(device.GetGame()).GetLocalPlayerMainGameObject();
    if player == null {
      return;
    };
    if Equals(workspot.operationType, EWorkspotOperationType.ENTER) {
      if IsNameValid(workspot.componentName) {
        this.EnterWorkspot(device, player, workspot.freeCamera, workspot.componentName);
      };
    } else {
      if Equals(workspot.operationType, EWorkspotOperationType.LEAVE) {
        this.LeaveWorkspot(player);
      };
    };
  }

  protected func EnterWorkspot(target: ref<Device>, activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(target, activator, freeCamera, componentName);
  }

  protected func LeaveWorkspot(activator: ref<GameObject>) -> Void {
    let direction: Vector4;
    let orientation: Quaternion;
    let workspotSystem: ref<WorkspotGameSystem>;
    Quaternion.SetIdentity(orientation);
    direction = new Vector4(0.00, 0.00, 0.00, 1.00);
    workspotSystem = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.StopInDevice(activator, direction, orientation);
  }
}

public class PlayBinkDeviceOperation extends DeviceOperationBase {

  public let bink: SBinkperationData;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveBink(this.bink, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveBink(this.bink, owner);
  }

  private final func ResolveBink(binkData: SBinkperationData, owner: wref<GameObject>) -> Void {
    let evt: ref<PlayBinkEvent>;
    if owner == null {
      return;
    };
    evt = new PlayBinkEvent();
    evt.data = binkData;
    owner.QueueEvent(evt);
  }
}

public class ToggleCustomActionDeviceOperation extends DeviceOperationBase {

  public let customActionID: CName;

  public let enabled: Bool;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveCustomActionState(this.customActionID, this.enabled, owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveCustomActionState(this.customActionID, this.enabled, owner);
  }

  private final func ResolveCustomActionState(actionID: CName, state: Bool, owner: wref<GameObject>) -> Void {
    let device: ref<Device>;
    let evt: ref<ToggleCustomActionEvent>;
    if owner == null {
      return;
    };
    device = owner as Device;
    if device == null {
      return;
    };
    if !IsNameValid(actionID) {
      return;
    };
    evt = new ToggleCustomActionEvent();
    evt.enabled = state;
    evt.actionID = actionID;
    GameInstance.GetPersistencySystem(device.GetGame()).QueuePSEvent(device.GetDevicePS().GetID(), device.GetDevicePS().GetClassName(), evt);
  }
}

public class ToggleOffMeshConnectionsDeviceOperation extends DeviceOperationBase {

  public let enable: Bool;

  public let affectsPlayer: Bool;

  public let affectsNPCs: Bool;

  public func Execute(owner: wref<GameObject>) -> Void {
    this.Execute(owner);
    this.ResolveOffMeshConnections(owner);
  }

  public func Restore(owner: wref<GameObject>) -> Void {
    this.ResolveOffMeshConnections(owner);
  }

  private final func ResolveOffMeshConnections(owner: wref<GameObject>) -> Void {
    let device: ref<Device>;
    let evt: ref<ToggleOffMeshConnections>;
    if owner == null {
      return;
    };
    evt = new ToggleOffMeshConnections();
    evt.enable = this.enable;
    evt.affectsPlayer = this.affectsPlayer;
    evt.affectsNPCs = this.affectsNPCs;
    device.QueueEvent(evt);
  }
}
