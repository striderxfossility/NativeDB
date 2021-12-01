
public class ApplyObjectActionEffector extends Effector {

  public let m_actionID: TweakDBID;

  public let m_triggered: Bool;

  public let m_probability: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_actionID = TDBID.Create(TweakDBInterface.GetString(record + t".actionID", ""));
    this.m_probability = TweakDBInterface.GetFloat(record + t".probability", 1.00);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let action: ref<PuppetAction>;
    let rand: Float;
    if !this.m_triggered {
      rand = RandRangeF(0.00, 1.00);
      if rand <= this.m_probability {
        action = new PuppetAction();
        action.RegisterAsRequester(owner.GetEntityID());
        action.SetExecutor(GetPlayer(owner.GetGame()));
        action.SetObjectActionID(this.m_actionID);
        action.SetUp((owner as ScriptedPuppet).GetPuppetPS());
        action.ProcessRPGAction(owner.GetGame());
        this.m_triggered = true;
      };
    };
  }
}

public class WeaponMalfunctionHudEffector extends Effector {

  public let m_bb: wref<IBlackboard>;

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_bb = GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().UI_Hacking);
    this.m_bb.SetBool(GetAllBlackboardDefs().UI_Hacking.ammoIndicator, true);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.m_bb.SetBool(GetAllBlackboardDefs().UI_Hacking.ammoIndicator, false);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.m_bb.SetBool(GetAllBlackboardDefs().UI_Hacking.ammoIndicator, false);
  }
}

public class MadnessEffector extends Effector {

  public let m_squadMembers: array<EntityID>;

  public let m_owner: wref<ScriptedPuppet>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void;

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let evt: ref<MadnessDebuff>;
    let link: ref<PuppetDeviceLinkPS>;
    let secSys: ref<SecuritySystemControllerPS>;
    this.m_owner = owner as ScriptedPuppet;
    if !IsDefined(this.m_owner) {
      return;
    };
    AISquadHelper.GetSquadmatesID(this.m_owner, this.m_squadMembers);
    GameObject.PlayVoiceOver(this.m_owner, n"stlh_call", n"Scripts:OnVoiceOverQuickHackFeedbackEvent");
    AIActionHelper.TargetAllSquadMembers(this.m_owner);
    link = this.m_owner.GetDeviceLink() as PuppetDeviceLinkPS;
    if IsDefined(link) {
      secSys = link.GetSecuritySystem();
      if IsDefined(secSys) {
        evt = new MadnessDebuff();
        evt.object = this.m_owner;
        link.GetPersistencySystem().QueuePSEvent(secSys.GetID(), secSys.GetClassName(), evt);
      };
    };
    NPCPuppet.SetTemporaryThreatCalculationType(this.m_owner, EAIThreatCalculationType.Madness);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void;

  protected func Uninitialize(game: GameInstance) -> Void {
    if !IsDefined(this.m_owner) || !this.m_owner.IsAttached() {
      return;
    };
    if ArraySize(this.m_squadMembers) == 0 {
      return;
    };
    NPCPuppet.RemoveTemporaryThreatCalculationType(this.m_owner);
  }
}

public class PingSquadEffector extends Effector {

  public let m_squadMembers: array<EntityID>;

  public let m_owner: wref<GameObject>;

  public let m_oldSquadAttitude: ref<AttitudeAgent>;

  public let m_quickhackLevel: Float;

  public let m_data: ref<FocusForcedHighlightData>;

  public let m_squadName: CName;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_quickhackLevel = TweakDBInterface.GetFloat(record + t".level", 1.00);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if !IsDefined(owner) {
      return;
    };
    AISquadHelper.GetSquadmatesID(owner as ScriptedPuppet, this.m_squadMembers);
    this.m_squadName = AISquadHelper.GetSquadName(owner as ScriptedPuppet);
    if !IsNameValid(this.m_squadName) {
      return;
    };
    this.MarkSquad(true, owner);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.MarkSquad(false, owner);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if !IsDefined(this.m_owner) || !this.m_owner.IsAttached() {
      return;
    };
    this.MarkSquad(false, this.m_owner);
  }

  public final func MarkSquad(mark: Bool, root: ref<GameObject>) -> Void {
    let game: GameInstance;
    let i: Int32;
    let networkSystem: ref<NetworkSystem>;
    let pingID: TweakDBID;
    let playerID: EntityID;
    let statusEffectsystem: ref<StatusEffectSystem>;
    let target: wref<GameObject>;
    if !IsDefined(root) {
      return;
    };
    game = root.GetGame();
    if !GameInstance.IsValid(game) {
      return;
    };
    networkSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"NetworkSystem") as NetworkSystem;
    if !IsDefined(networkSystem) {
      return;
    };
    if mark {
      if networkSystem.IsSquadMarkedWithPing(this.m_squadName) {
        return;
      };
      this.RegisterMarkedSquadInNetworkSystem(game);
    } else {
      if !networkSystem.IsSquadMarkedWithPing(this.m_squadName) {
        return;
      };
      this.UnregisterMarkedSquadInNetworkSystem(game);
    };
    statusEffectsystem = GameInstance.GetStatusEffectSystem(game);
    if !IsDefined(statusEffectsystem) {
      return;
    };
    pingID = this.GetPingLevel(this.m_quickhackLevel);
    playerID = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject().GetEntityID();
    i = 0;
    while i < ArraySize(this.m_squadMembers) {
      target = GameInstance.FindEntityByID(game, this.m_squadMembers[i]) as GameObject;
      if !IsDefined(target) || target == root {
      } else {
        if mark {
          if !statusEffectsystem.HasStatusEffect(this.m_squadMembers[i], pingID) {
            StatusEffectHelper.ApplyStatusEffect(target, pingID, playerID);
          };
        } else {
          if statusEffectsystem.HasStatusEffect(this.m_squadMembers[i], pingID) {
            StatusEffectHelper.RemoveStatusEffect(target, pingID);
          };
        };
      };
      i += 1;
    };
  }

  private final func RegisterMarkedSquadInNetworkSystem(game: GameInstance) -> Void {
    let request: ref<AddPingedSquadRequest>;
    if GameInstance.IsValid(game) {
      request = new AddPingedSquadRequest();
      request.squadName = this.m_squadName;
      GameInstance.QueueScriptableSystemRequest(game, n"NetworkSystem", request);
    };
  }

  private final func UnregisterMarkedSquadInNetworkSystem(game: GameInstance) -> Void {
    let request: ref<RemovePingedSquadRequest>;
    if GameInstance.IsValid(game) {
      request = new RemovePingedSquadRequest();
      request.squadName = this.m_squadName;
      GameInstance.QueueScriptableSystemRequest(game, n"NetworkSystem", request);
    };
  }

  public final func GetPingLevel(level: Float) -> TweakDBID {
    switch level {
      case 1.00:
        return t"BaseStatusEffect.Ping";
      case 2.00:
        return t"BaseStatusEffect.PingLevel2";
      case 3.00:
        return t"BaseStatusEffect.PingLevel3";
      case 4.00:
        return t"BaseStatusEffect.PingLevel4";
      default:
        return t"BaseStatusEffect.Ping";
    };
    return t"BaseStatusEffect.Ping";
  }
}

public class RefreshPingEffector extends Effector {

  public let m_squadMembers: array<EntityID>;

  public let m_owner: wref<GameObject>;

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    let statValue: Float = GameInstance.GetStatsSystem(owner.GetGame()).GetStatValue(Cast(GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject().GetEntityID()), gamedataStatType.RefreshesPingOnQuickhack);
    AISquadHelper.GetSquadmatesID(owner as ScriptedPuppet, this.m_squadMembers);
    ArrayPush(this.m_squadMembers, owner.GetEntityID());
    if !IsDefined(owner) {
      return;
    };
    if statValue == 1.00 {
      this.RefreshSquad(owner);
    };
  }

  public final func RefreshSquad(root: ref<GameObject>) -> Void {
    let appliedEffects: array<ref<StatusEffect>>;
    let j: Int32;
    let pingRecord: ref<StatusEffect_Record>;
    let tags: array<CName>;
    let target: wref<GameObject>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_squadMembers) {
      target = GameInstance.FindEntityByID(root.GetGame(), this.m_squadMembers[i]) as GameObject;
      GameInstance.GetStatusEffectSystem(target.GetGame()).GetAppliedEffects(target.GetEntityID(), appliedEffects);
      if !IsDefined(target) || ArraySize(appliedEffects) == 0 {
      } else {
        j = 0;
        while j < ArraySize(appliedEffects) {
          pingRecord = appliedEffects[j].GetRecord();
          tags = pingRecord.GameplayTags();
          if ArrayContains(tags, n"Ping") {
            StatusEffectHelper.ApplyStatusEffect(target, pingRecord.GetID(), GameInstance.GetPlayerSystem(target.GetGame()).GetLocalPlayerMainGameObject().GetEntityID());
          };
          j += 1;
        };
      };
      i += 1;
    };
  }
}

public class SetFriendlyEffector extends Effector {

  public let m_target: wref<GameObject>;

  public let m_duration: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_duration = TweakDBInterface.GetFloat(record + t".duration", 10.00);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    let puppet: ref<ScriptedPuppet> = this.m_target as ScriptedPuppet;
    if !IsDefined(puppet) || !puppet.IsAttached() {
      return;
    };
    if Equals(puppet.GetNPCType(), gamedataNPCType.Drone) {
      StatusEffectHelper.ApplyStatusEffect(puppet, t"BaseStatusEffect.ForceKill");
    };
    if Equals(puppet.GetNPCType(), gamedataNPCType.Android) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(puppet, gamedataStatusEffectType.AndroidTurnOn) {
        GameInstance.GetStatusEffectSystem(puppet.GetGame()).RemoveStatusEffect(this.m_target.GetEntityID(), t"BaseStatusEffect.AndroidTurnOn");
        StatusEffectHelper.ApplyStatusEffect(puppet, t"BaseStatusEffect.AndroidTurnOff");
      };
    };
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let currentRole: ref<AIRole>;
    let smi: ref<SquadScriptInterface>;
    this.m_target = owner;
    let player: ref<ScriptedPuppet> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject() as ScriptedPuppet;
    this.ChangeAttitude(owner, player);
    AIActionHelper.SetFriendlyTargetAllSquadMembers(owner);
    if AISquadHelper.GetSquadMemberInterface(player, smi) {
      smi.Join(owner);
    };
    currentRole = (owner as ScriptedPuppet).GetAIControllerComponent().GetCurrentRole();
    if Equals(currentRole.GetRoleEnum(), EAIRole.Follower) {
      AIHumanComponent.SetCurrentRole(owner, new AINoRole());
    };
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Drone) {
      this.SetAnimFeature(owner as ScriptedPuppet);
    };
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Android) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(owner, gamedataStatusEffectType.AndroidTurnOff) {
        StatusEffectHelper.ApplyStatusEffect(owner, t"BaseStatusEffect.AndroidTurnOn");
      };
    };
    if RPGManager.GetStatValueFromObject(owner.GetGame(), GetPlayer(owner.GetGame()), gamedataStatType.CanBuffMechanicalsOnTakeControl) > 0.00 {
      StatusEffectHelper.ApplyStatusEffect(owner, t"BaseStatusEffect.CombatHacking_Area_04_Perk_1_Buff_Level_1");
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Drone) {
      StatusEffectHelper.ApplyStatusEffect(owner, t"BaseStatusEffect.ForceKill");
    };
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Android) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(owner, gamedataStatusEffectType.AndroidTurnOn) {
        GameInstance.GetStatusEffectSystem(owner.GetGame()).RemoveStatusEffect(owner.GetEntityID(), t"BaseStatusEffect.AndroidTurnOn");
        StatusEffectHelper.ApplyStatusEffect(owner, t"BaseStatusEffect.AndroidTurnOff");
      };
    };
  }

  protected final func ChangeAttitude(owner: wref<GameObject>, target: wref<GameObject>) -> Bool {
    let currentTarget: wref<GameObject>;
    let i: Int32;
    let ownerAttitudeAgent: ref<AttitudeAgent>;
    let targetAttitudeAgent: ref<AttitudeAgent>;
    let targetSquadMembers: array<wref<Entity>>;
    if !IsDefined(owner) || !IsDefined(target) {
      return false;
    };
    ownerAttitudeAgent = owner.GetAttitudeAgent();
    targetAttitudeAgent = target.GetAttitudeAgent();
    if !IsDefined(ownerAttitudeAgent) || !IsDefined(targetAttitudeAgent) {
      return false;
    };
    if AISquadHelper.GetSquadmates(target as ScriptedPuppet, targetSquadMembers) {
      i = 0;
      while i < ArraySize(targetSquadMembers) {
        currentTarget = targetSquadMembers[i] as GameObject;
        if !IsDefined(currentTarget) || currentTarget == owner {
        } else {
          ownerAttitudeAgent.SetAttitudeTowards(currentTarget.GetAttitudeAgent(), EAIAttitude.AIA_Friendly);
        };
        i += 1;
      };
    };
    ownerAttitudeAgent.SetAttitudeGroup(targetAttitudeAgent.GetAttitudeGroup());
    ownerAttitudeAgent.SetAttitudeTowards(targetAttitudeAgent, EAIAttitude.AIA_Friendly);
    return true;
  }

  protected final func SetAnimFeature(owner: wref<ScriptedPuppet>) -> Void {
    let setFriendlyOverride: ref<AnimFeature_StatusEffect> = new AnimFeature_StatusEffect();
    setFriendlyOverride.state = 1;
    setFriendlyOverride.duration = 8.00;
    AnimationControllerComponent.ApplyFeatureToReplicate(owner, n"SetFriendlyOverride", setFriendlyOverride);
  }
}

public class AndroidTurnOnEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Android) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(owner, gamedataStatusEffectType.AndroidTurnOff) {
        GameInstance.GetStatusEffectSystem(owner.GetGame()).RemoveStatusEffect(owner.GetEntityID(), t"BaseStatusEffect.AndroidTurnOff");
      };
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void;

  protected func Uninitialize(game: GameInstance) -> Void;
}

public class AndroidTurnOffEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    if Equals((owner as ScriptedPuppet).GetNPCType(), gamedataNPCType.Android) {
      if StatusEffectSystem.ObjectHasStatusEffectOfType(owner, gamedataStatusEffectType.AndroidTurnOn) {
        GameInstance.GetStatusEffectSystem(owner.GetGame()).RemoveStatusEffect(owner.GetEntityID(), t"BaseStatusEffect.AndroidTurnOn");
      };
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void;

  protected func Uninitialize(game: GameInstance) -> Void;
}

public class SpreadInitEffector extends Effector {

  public let m_objectActionRecord: wref<ObjectAction_Record>;

  public let m_effectorRecord: ref<SpreadInitEffector_Record>;

  public let m_player: wref<PlayerPuppet>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_effectorRecord = TweakDBInterface.GetSpreadInitEffectorRecord(record);
    if IsDefined(this.m_effectorRecord) {
      this.m_objectActionRecord = this.m_effectorRecord.ObjectAction();
    };
    this.m_player = GetPlayer(game);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let range: Float;
    let spreadCount: Int32;
    let statsSystem: ref<StatsSystem>;
    if !IsDefined(owner) || !IsDefined(this.m_objectActionRecord) || !IsDefined(this.m_effectorRecord) {
      return;
    };
    if !IsDefined(this.m_player) {
      return;
    };
    statsSystem = GameInstance.GetStatsSystem(this.m_player.GetGame());
    if !IsDefined(statsSystem) {
      return;
    };
    spreadCount = this.m_effectorRecord.SpreadCount();
    if spreadCount < 0 {
      spreadCount = Cast(statsSystem.GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.QuickHackSpreadNumber));
    };
    range = Cast(this.m_effectorRecord.SpreadDistance());
    if range < 0.00 {
      range = statsSystem.GetStatValue(Cast(this.m_player.GetEntityID()), gamedataStatType.QuickHackSpreadDistance);
    };
    spreadCount += this.m_effectorRecord.BonusJumps();
    if spreadCount <= 0 || range <= 0.00 {
      return;
    };
    HackingDataDef.AddItemToSpreadMap(this.m_player, this.m_objectActionRecord.ObjectActionUI(), spreadCount, range);
  }
}

public class SpreadEffector extends Effector {

  public let m_objectActionRecord: wref<ObjectAction_Record>;

  public let m_player: wref<PlayerPuppet>;

  public let m_effectorRecord: ref<SpreadEffector_Record>;

  public let m_spreadToAllTargetsInTheArea: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let instigatorPrereqs: array<wref<IPrereq_Record>>;
    this.m_effectorRecord = TweakDBInterface.GetSpreadEffectorRecord(record);
    this.m_spreadToAllTargetsInTheArea = TweakDBInterface.GetBool(record + t".spreadToAllTargetsInTheArea", false);
    if IsDefined(this.m_effectorRecord) {
      this.m_objectActionRecord = this.m_effectorRecord.ObjectAction();
    };
    this.m_player = GetPlayer(game);
    if IsDefined(this.m_player) {
      this.m_objectActionRecord.InstigatorPrereqs(instigatorPrereqs);
      if !RPGManager.CheckPrereqs(instigatorPrereqs, this.m_player) {
        this.m_objectActionRecord = null;
        return;
      };
    };
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let effect: ref<EffectInstance>;
    let range: Float;
    let spreadCount: Int32;
    if !IsDefined(owner) || !IsDefined(this.m_objectActionRecord) {
      return;
    };
    if !IsDefined(this.m_player) {
      return;
    };
    if !HackingDataDef.GetValuesFromSpreadMap(this.m_player, this.m_objectActionRecord.ObjectActionUI(), spreadCount, range) {
      return;
    };
    if spreadCount <= 0 {
      return;
    };
    effect = GameInstance.GetGameEffectSystem(owner.GetGame()).CreateEffectStatic(n"forceVisionAppearanceOnNPC", this.m_effectorRecord.EffectTag(), this.m_player);
    if !IsDefined(effect) {
      return;
    };
    EffectData.SetVector(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.position, owner.GetWorldPosition());
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.radius, range);
    EffectData.SetFloat(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.maxPathLength, range * 2.00);
    EffectData.SetEntity(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, owner);
    EffectData.SetVariant(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.statusEffect, ToVariant(this.m_objectActionRecord));
    EffectData.SetInt(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.attackNumber, spreadCount);
    EffectData.SetBool(effect.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.debugBool, this.m_spreadToAllTargetsInTheArea);
    if !effect.Run() {
      return;
    };
  }
}

public class EffectExecutor_Spread extends EffectExecutor_Scripted {

  public let m_objectActionRecord: wref<ObjectAction_Record>;

  public let m_prevEntity: wref<Entity>;

  public let m_player: wref<PlayerPuppet>;

  public let m_spreadToAllTargetsInTheArea: Bool;

  public final func Init(ctx: EffectScriptContext) -> Bool {
    let variantValue: Variant;
    this.m_player = GetPlayer(EffectScriptContext.GetGameInstance(ctx));
    if !IsDefined(this.m_player) {
      return false;
    };
    if !EffectData.GetEntity(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.entity, this.m_prevEntity) {
      return false;
    };
    if !EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.statusEffect, variantValue) {
      return false;
    };
    if !EffectData.GetBool(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.debugBool, this.m_spreadToAllTargetsInTheArea) {
      return false;
    };
    this.m_objectActionRecord = FromVariant(variantValue);
    if !IsDefined(this.m_objectActionRecord) {
      return false;
    };
    return true;
  }

  public final func Process(ctx: EffectScriptContext, applierCtx: EffectExecutionScriptContext) -> Bool {
    let action: ref<AIQuickHackAction>;
    let i: Int32;
    let prereqsToCheck: array<wref<IPrereq_Record>>;
    let result: Bool;
    let targetActionRecords: array<wref<ObjectAction_Record>>;
    let targetPrereqs: array<wref<ObjectActionPrereq_Record>>;
    let target: wref<ScriptedPuppet> = EffectExecutionScriptContext.GetTarget(applierCtx) as ScriptedPuppet;
    if !IsDefined(target) || !ScriptedPuppet.IsActive(target) {
      return true;
    };
    if target.IsPlayer() {
      return true;
    };
    if target == this.m_prevEntity {
      return true;
    };
    if Equals(GameObject.GetAttitudeTowards(target, this.m_player), EAIAttitude.AIA_Friendly) {
      return true;
    };
    if !target.IsAggressive() {
      return true;
    };
    if !target.IsQuickHackAble() {
      return true;
    };
    target.GetRecord().ObjectActions(targetActionRecords);
    i = 0;
    while i < ArraySize(targetActionRecords) {
      if targetActionRecords[i].ObjectActionUI() == this.m_objectActionRecord.ObjectActionUI() {
        result = true;
      } else {
        i += 1;
      };
    };
    if Equals(result, false) {
      return true;
    };
    if this.m_objectActionRecord.GetTargetActivePrereqsCount() > 0 {
      this.m_objectActionRecord.TargetActivePrereqs(targetPrereqs);
      i = 0;
      while i < ArraySize(targetPrereqs) {
        if targetPrereqs[i].GetFailureConditionPrereqCount() > 0 {
          targetPrereqs[i].FailureConditionPrereq(prereqsToCheck);
          if !RPGManager.CheckPrereqs(prereqsToCheck, target) {
            return true;
          };
        };
        i += 1;
      };
    };
    result = HackingDataDef.DecrementCountFromSpreadMap(this.m_player, this.m_objectActionRecord.ObjectActionUI());
    action = new AIQuickHackAction();
    action.RegisterAsRequester(target.GetEntityID());
    action.SetExecutor(this.m_player);
    action.SetObjectActionID(this.m_objectActionRecord.GetID());
    action.SetUp(target.GetPuppetPS());
    action.ProcessRPGAction(target.GetGame());
    if this.m_spreadToAllTargetsInTheArea && result {
      return true;
    };
    return false;
  }
}

public class SortOut_Contagion extends EffectObjectGroupFilter_Scripted {

  public final func Process(out ctx: EffectScriptContext, out filterCtx: EffectGroupFilterScriptContext) -> Bool {
    let dataObjectAction: Variant;
    let i: Int32;
    let j: Int32;
    let numAgents: Int32;
    let sortedTarget: ref<ScriptedPuppet>;
    let sortedTargets: array<ref<ScriptedPuppet>>;
    let target: ref<ScriptedPuppet>;
    let targets: array<ref<ScriptedPuppet>>;
    if !EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.statusEffect, dataObjectAction) {
      return false;
    };
    if !this.IsContagion(FromVariant(dataObjectAction)) {
      return false;
    };
    numAgents = EffectGroupFilterScriptContext.GetNumAgents(filterCtx);
    i = 0;
    while i < numAgents {
      target = EffectGroupFilterScriptContext.GetEntity(filterCtx, i) as ScriptedPuppet;
      if IsDefined(target) {
        ArrayPush(targets, target);
      };
      i = i + 1;
    };
    sortedTargets = this.SortTargetsByStatusEffect(targets);
    ArrayClear(filterCtx.resultIndices);
    i = 0;
    while i < ArraySize(sortedTargets) {
      sortedTarget = sortedTargets[i];
      if sortedTarget != null {
        j = 0;
        while j < numAgents {
          target = EffectGroupFilterScriptContext.GetEntity(filterCtx, j) as ScriptedPuppet;
          if sortedTarget == target {
            ArrayPush(filterCtx.resultIndices, j);
          } else {
            j = j + 1;
          };
        };
      };
      i += 1;
    };
    return true;
  }

  private final func IsContagion(objectAction: ref<ObjectAction_Record>) -> Bool {
    if StrContains(objectAction.ObjectActionUI().Name(), "ContagionHack") {
      return true;
    };
    return false;
  }

  private final func SortTargetsByStatusEffect(targets: array<ref<ScriptedPuppet>>) -> array<ref<ScriptedPuppet>> {
    let sortedTargets: array<ref<ScriptedPuppet>>;
    let sortedTargetsWithStatus: array<ref<ScriptedPuppet>>;
    let sortedTargetsWithoutStatus: array<ref<ScriptedPuppet>>;
    let i: Int32 = ArraySize(targets);
    while i > 0 {
      if !StatusEffectSystem.ObjectHasStatusEffectWithTag(targets[i], n"ContagionPoison") {
        ArrayInsert(sortedTargetsWithoutStatus, 0, targets[i]);
      };
      i -= 1;
    };
    i = 0;
    while i < ArraySize(targets) {
      if StatusEffectSystem.ObjectHasStatusEffectWithTag(targets[i], n"ContagionPoison") {
        ArrayPush(sortedTargetsWithStatus, targets[i]);
      };
      i += 1;
    };
    sortedTargets = sortedTargetsWithoutStatus;
    i = ArraySize(sortedTargetsWithoutStatus);
    while i < ArraySize(sortedTargetsWithoutStatus) + ArraySize(sortedTargetsWithStatus) {
      ArrayInsert(sortedTargets, i, sortedTargetsWithStatus[i - ArraySize(sortedTargetsWithoutStatus)]);
      i += 1;
    };
    return sortedTargets;
  }
}

public class RevealPlayerPositionEffector extends Effector {

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void;

  protected func ActionOn(owner: ref<GameObject>) -> Void;

  protected func ActionOff(owner: ref<GameObject>) -> Void;
}

public class ForceMoveInCombatEffector extends Effector {

  public let m_target: wref<GameObject>;

  public let m_duration: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_duration = TweakDBInterface.GetFloat(record + t".duration", 30.00);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let end: AIPositionSpec;
    let endWorldPosition: WorldPosition;
    let moveCommand: ref<AIMoveToCommand>;
    let targetPosition: Vector4;
    this.m_target = owner;
    let AIcomponent: ref<AIHumanComponent> = (owner as ScriptedPuppet).GetAIControllerComponent();
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if Equals((owner as ScriptedPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      targetPosition = player.GetWorldPosition();
      WorldPosition.SetVector4(endWorldPosition, targetPosition);
      AIPositionSpec.SetWorldPosition(end, endWorldPosition);
      moveCommand = new AIMoveToCommand();
      moveCommand.movementTarget = end;
      moveCommand.ignoreNavigation = false;
      moveCommand.desiredDistanceFromTarget = 2.00;
      moveCommand.movementType = moveMovementType.Run;
      moveCommand.finishWhenDestinationReached = true;
      AIcomponent.SendCommand(moveCommand);
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffects.WhistleLvl3");
  }
}

public class ForceMoveInCombatCallInEffector extends Effector {

  public let m_target: wref<GameObject>;

  public let m_duration: Float;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_duration = TweakDBInterface.GetFloat(record + t".duration", 30.00);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let AIcomponent: ref<AIHumanComponent>;
    let calledObject: ref<GameObject>;
    let end: AIPositionSpec;
    let endWorldPosition: WorldPosition;
    let moveCommand: ref<AIMoveToCommand>;
    let player: ref<GameObject>;
    let squadMembers: array<EntityID>;
    let targetPosition: Vector4;
    if !AISquadHelper.GetSquadmatesID(owner, squadMembers) {
      return;
    };
    this.m_target = owner;
    calledObject = GameInstance.FindEntityByID(owner.GetGame(), squadMembers[0]) as GameObject;
    AIcomponent = (calledObject as ScriptedPuppet).GetAIControllerComponent();
    player = GameInstance.GetPlayerSystem(owner.GetGame()).GetLocalPlayerMainGameObject();
    if Equals((owner as ScriptedPuppet).GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Combat) {
      targetPosition = owner.GetWorldPosition();
      WorldPosition.SetVector4(endWorldPosition, targetPosition);
      AIPositionSpec.SetEntity(end, EntityGameInterface.GetEntity(owner.GetEntity()));
      moveCommand = new AIMoveToCommand();
      AIPositionSpec.SetEntity(moveCommand.facingTarget, EntityGameInterface.GetEntity(player.GetEntity()));
      moveCommand.movementTarget = end;
      moveCommand.ignoreNavigation = false;
      moveCommand.desiredDistanceFromTarget = 1.00;
      moveCommand.movementType = moveMovementType.Run;
      moveCommand.finishWhenDestinationReached = true;
      AIcomponent.SendCommand(moveCommand);
      GameObject.PlayVoiceOver(calledObject, n"stlh_call", n"Scripts:OnVoiceOverQuickHackFeedbackEvent");
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    StatusEffectHelper.RemoveStatusEffect(owner, t"BaseStatusEffects.CommsCallInLevel3");
  }
}
