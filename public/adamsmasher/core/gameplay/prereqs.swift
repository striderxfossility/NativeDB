
public native class IScriptablePrereq extends IPrereq {

  protected const func IsOnRegisterSupported() -> Bool {
    return true;
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void;

  protected func Initialize(record: TweakDBID) -> Void;

  protected const func OnApplied(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void;
}

public class DevelopmentCheckPrereq extends IScriptablePrereq {

  protected edit let requiredLevel: Float;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".requiredLevel");
    this.requiredLevel = TDB.GetFloat(tweakID);
  }
}

public class SkillCheckPrereqState extends PrereqState {

  public final const func GetSkillToCheck() -> gamedataProficiencyType {
    return (this.GetPrereq() as SkillCheckPrereq).GetSkillToCheck();
  }

  public final func UpdateSkillCheckPrereqData(obj: ref<GameObject>, newLevel: Int32) -> Void {
    let checkPassed: Bool = (this.GetPrereq() as SkillCheckPrereq).IsFulfilled(obj.GetGame(), this.GetContext());
    this.OnChanged(checkPassed);
  }
}

public class SkillCheckPrereq extends DevelopmentCheckPrereq {

  protected edit let skillToCheck: gamedataProficiencyType;

  public final const func GetSkillToCheck() -> gamedataProficiencyType {
    return this.skillToCheck;
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let request: ref<ModifySkillCheckPrereq>;
    let castedState: ref<SkillCheckPrereqState> = state as SkillCheckPrereqState;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      request = new ModifySkillCheckPrereq();
      request.Set(player, true, castedState);
      GameInstance.GetScriptableSystemsContainer(game).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
      return this.IsFulfilled(game, context);
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let request: ref<ModifySkillCheckPrereq>;
    let castedState: ref<SkillCheckPrereqState> = state as SkillCheckPrereqState;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      request = new ModifySkillCheckPrereq();
      request.Set(player, false, castedState);
      GameInstance.GetScriptableSystemsContainer(game).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: ref<PlayerPuppet> = GetPlayer(game);
    let skillLevel: Int32 = (GameInstance.GetScriptableSystemsContainer(game).Get(n"PlayerDevelopmentSystem") as PlayerDevelopmentSystem).GetProficiencyLevel(player, this.skillToCheck);
    return Cast(skillLevel) >= this.requiredLevel;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID;
    let type: CName;
    this.Initialize(recordID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".skillToCheck");
    type = TDB.GetCName(tweakID);
    this.skillToCheck = IntEnum(Cast(EnumValueFromName(n"gamedataProficiencyType", type)));
  }
}

public class StatCheckPrereqState extends PrereqState {

  public final const func GetStatToCheck() -> gamedataStatType {
    return (this.GetPrereq() as StatCheckPrereq).GetStatToCheck();
  }

  public final func UpdateStatCheckPrereqData(obj: ref<GameObject>, newValue: Float) -> Void {
    let checkPassed: Bool = (this.GetPrereq() as StatCheckPrereq).IsFulfilled(obj.GetGame(), this.GetContext());
    this.OnChanged(checkPassed);
  }
}

public class StatCheckPrereq extends DevelopmentCheckPrereq {

  protected edit let statToCheck: gamedataStatType;

  public final const func GetStatToCheck() -> gamedataStatType {
    return this.statToCheck;
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let request: ref<ModifyStatCheckPrereq>;
    let castedState: ref<StatCheckPrereqState> = state as StatCheckPrereqState;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      request = new ModifyStatCheckPrereq();
      request.Set(player, true, castedState);
      GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
      return true;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let request: ref<ModifyStatCheckPrereq>;
    let castedState: ref<StatCheckPrereqState> = state as StatCheckPrereqState;
    let player: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(player) {
      request = new ModifyStatCheckPrereq();
      request.Set(player, false, castedState);
      GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PlayerDevelopmentSystem").QueueRequest(request);
    };
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: ref<GameObject> = GetPlayer(game);
    let statValue: Float = GameInstance.GetStatsSystem(game).GetStatValue(Cast(player.GetEntityID()), this.statToCheck);
    return statValue >= this.requiredLevel;
  }

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID;
    let type: CName;
    this.Initialize(recordID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".statToCheck");
    type = TDB.GetCName(tweakID);
    this.statToCheck = IntEnum(Cast(EnumValueFromName(n"gamedataStatType", type)));
  }
}

public class NPCRevealedPrereq extends IScriptablePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npcOwner: ref<NPCPuppet>;
    let castedState: ref<NPCRevealedPrereqState> = state as NPCRevealedPrereqState;
    if IsDefined(context as NPCPuppet) {
      npcOwner = context as NPCPuppet;
    };
    castedState.m_listener = new PuppetListener();
    castedState.m_listener.RegisterOwner(castedState);
    ScriptedPuppet.AddListener(npcOwner, castedState.m_listener);
    return npcOwner.IsRevealed();
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<NPCRevealedPrereqState> = state as NPCRevealedPrereqState;
    ScriptedPuppet.RemoveListener(context as GameObject, castedState.m_listener);
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npcOwner: ref<NPCPuppet>;
    if IsDefined(context as NPCPuppet) {
      npcOwner = context as NPCPuppet;
    };
    return npcOwner.IsRevealed();
  }
}

public class GameObjectRevealedRedPrereq extends IScriptablePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject>;
    let castedState: ref<GameObjectRevealedRedPrereqState> = state as GameObjectRevealedRedPrereqState;
    if IsDefined(context as GameObject) {
      owner = context as GameObject;
    };
    castedState.m_listener = new GameObjectListener();
    castedState.m_listener.RegisterOwner(castedState);
    GameObject.AddListener(owner, castedState.m_listener);
    return owner.ShouldEnableOutlineRed();
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<GameObjectRevealedRedPrereqState> = state as GameObjectRevealedRedPrereqState;
    GameObject.RemoveListener(context as GameObject, castedState.m_listener);
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject>;
    if IsDefined(context as GameObject) {
      owner = context as GameObject;
    };
    return owner.ShouldEnableOutlineRed();
  }
}

public class GameObjectRevealedGreenPrereq extends IScriptablePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject>;
    let castedState: ref<GameObjectRevealedGreenPrereqState> = state as GameObjectRevealedGreenPrereqState;
    if IsDefined(context as GameObject) {
      owner = context as GameObject;
    };
    castedState.m_listener = new GameObjectListener();
    castedState.m_listener.RegisterOwner(castedState);
    GameObject.AddListener(owner, castedState.m_listener);
    return owner.ShouldEnableOutlineGreen();
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<GameObjectRevealedGreenPrereqState> = state as GameObjectRevealedGreenPrereqState;
    GameObject.RemoveListener(context as GameObject, castedState.m_listener);
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject>;
    if IsDefined(context as GameObject) {
      owner = context as GameObject;
    };
    return owner.ShouldEnableOutlineGreen();
  }
}

public class RevealAccessPointPrereq extends IScriptablePrereq {

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let owner: ref<GameObject>;
    let castedState: ref<RevealAccessPointPrereqState> = state as RevealAccessPointPrereqState;
    if IsDefined(context as GameObject) {
      owner = context as GameObject;
    };
    castedState.m_listener = new GameObjectListener();
    castedState.m_listener.RegisterOwner(castedState);
    GameObject.AddListener(owner, castedState.m_listener);
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<RevealAccessPointPrereqState> = state as RevealAccessPointPrereqState;
    GameObject.RemoveListener(context as GameObject, castedState.m_listener);
    castedState.m_listener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let accessPoint: ref<AccessPoint> = context as AccessPoint;
    if IsDefined(accessPoint) {
      return accessPoint.IsRevealed();
    };
    return false;
  }
}

public class NPCDeadPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let health: Float;
    let npcOwner: ref<NPCPuppet>;
    let npcOwnerID: StatsObjectID;
    let statPoolsSystem: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
    if IsDefined(context as NPCPuppet) {
      npcOwner = context as NPCPuppet;
      npcOwnerID = Cast(npcOwner.GetEntityID());
      health = statPoolsSystem.GetStatPoolValue(npcOwnerID, gamedataStatPoolType.Health);
      if health <= 0.00 {
        return true;
      };
    };
    return false;
  }
}

public class NPCIncapacitatedPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let state: gamedataNPCHighLevelState;
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    if IsDefined(npcOwner) {
      state = npcOwner.GetHighLevelStateFromBlackboard();
      if Equals(state, gamedataNPCHighLevelState.Unconscious) || Equals(state, gamedataNPCHighLevelState.Dead) || ScriptedPuppet.IsDefeated(npcOwner) || ScriptedPuppet.IsNanoWireHacked(npcOwner) {
        return true;
      };
    };
    return false;
  }
}

public class NPCGrappledByPlayerPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    let mountingInfo: MountingInfo = GameInstance.GetMountingFacility(npcOwner.GetGame()).GetMountingInfoSingleWithObjects(npcOwner);
    let isNPCMounted: Bool = EntityID.IsDefined(mountingInfo.childId);
    let mountingSlotName: CName = mountingInfo.slotId.id;
    if IsDefined(context as NPCPuppet) && isNPCMounted && Equals(mountingSlotName, n"grapple") {
      return true;
    };
    return false;
  }
}

public class SinglePlayerPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    return !GameInstance.GetRuntimeInfo(game).IsMultiplayer();
  }
}

public class NPCNotMountedToVehiclePrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    let isNPCMounted: Bool = VehicleComponent.IsMountedToVehicle(game, npcOwner.GetEntityID());
    if IsDefined(context as NPCPuppet) && !isNPCMounted {
      return true;
    };
    return false;
  }
}

public class NPCIsHumanoidPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let npcOwner: ref<NPCPuppet> = context as NPCPuppet;
    if IsDefined(npcOwner) {
      return Equals(npcOwner.GetNPCType(), gamedataNPCType.Human);
    };
    return true;
  }
}

public class PuppetNotBossPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let isBoss: Bool;
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(puppet) {
      isBoss = puppet.IsBoss();
    } else {
      isBoss = false;
    };
    return !isBoss;
  }
}

public class NotReplacerPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      if !playerControlledObject.IsReplacer() {
        return true;
      };
    };
    return false;
  }
}

public class NotJohnnyReplacerPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      if !playerControlledObject.IsJohnnyReplacer() {
        return true;
      };
    };
    return false;
  }
}

public class NotVRReplacerPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      if !playerControlledObject.IsVRReplacer() {
        return true;
      };
    };
    return false;
  }
}

public class PlayerDeadPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let playerOwner: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(playerOwner) {
      if playerOwner.IsDead() {
        return true;
      };
    };
    return false;
  }
}

public class PuppetIncapacitatedPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let puppet: ref<gamePuppetBase> = context as gamePuppetBase;
    if IsDefined(puppet) {
      return puppet.IsIncapacitated();
    };
    return false;
  }
}

public class PlayerNotCarryingPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let playerCarrying: Bool;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      blackboard = GameInstance.GetBlackboardSystem(game).GetLocalInstanced(playerControlledObject.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerCarrying = blackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.Carrying);
    } else {
      playerCarrying = false;
    };
    return !playerCarrying;
  }
}

public class PlayerNotGrapplingPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let blackboard: ref<IBlackboard>;
    let playerGrappling: Bool;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      blackboard = GameInstance.GetBlackboardSystem(game).GetLocalInstanced(playerControlledObject.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerGrappling = blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.EnteringGrapple) || blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Grapple) || blackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Takedown) == EnumInt(gamePSMTakedown.Takedown);
    } else {
      playerGrappling = false;
    };
    return !playerGrappling;
  }
}

public class DisableAllWorldInteractionsNotEnabledPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let isDisablingRequested: Bool;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      isDisablingRequested = StatusEffectSystem.ObjectHasStatusEffectWithTag(playerControlledObject, n"NoWorldInteractions");
    } else {
      isDisablingRequested = false;
    };
    return !isDisablingRequested;
  }
}

public class DisableAllVehicleInteractionsNotEnabledPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let isDisablingRequested: Bool;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    if IsDefined(playerControlledObject) {
      isDisablingRequested = StatusEffectSystem.ObjectHasStatusEffectWithTag(playerControlledObject, n"VehicleNoInteraction");
    } else {
      isDisablingRequested = false;
    };
    return !isDisablingRequested;
  }
}

public class PlayerHasTakedownWeaponEquippedPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let i: Int32;
    let record: ref<Item_Record>;
    let tags: array<CName>;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    let weaponObj: ref<WeaponObject> = GameInstance.GetTransactionSystem(playerControlledObject.GetGame()).GetItemInSlot(playerControlledObject, t"AttachmentSlots.WeaponRight") as WeaponObject;
    let itemID: ItemID = weaponObj.GetItemID();
    if IsDefined(playerControlledObject) && ItemID.IsValid(itemID) {
      record = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
      tags = record.Tags();
      i = 0;
      while i < ArraySize(tags) {
        if Equals(tags[i], n"TakedownWeapon") {
          return true;
        };
        i += 1;
      };
    };
    return false;
  }
}

public class PlayerHasMantisBladesEquippedPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let friendlyName: String;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    let weaponObj: ref<WeaponObject> = GameInstance.GetTransactionSystem(playerControlledObject.GetGame()).GetItemInSlot(playerControlledObject, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(playerControlledObject) && IsDefined(weaponObj) {
      friendlyName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponObj.GetItemID())).FriendlyName();
      if Equals(friendlyName, "mantis_blade") {
        return true;
      };
    };
    return false;
  }
}

public class IsNpcMountedInSlotPrereqState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnMountingStateChanged() -> Void {
    let prereq: ref<IsNpcMountedInSlotPrereq> = this.GetPrereq() as IsNpcMountedInSlotPrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsNpcMountedInSlotPrereq extends IScriptablePrereq {

  protected let slotName: CName;

  protected let isCheckInverted: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".slotname");
    this.slotName = TDB.GetCName(tweakID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".isCheckInverted");
    this.isCheckInverted = TDB.GetBool(tweakID);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    let castedState: ref<IsNpcMountedInSlotPrereqState> = state as IsNpcMountedInSlotPrereqState;
    if IsDefined(vehicle) {
      persistentId = CreatePersistentID(vehicle.GetEntityID(), vehicle.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsNpcMountedInSlotPrereqState> = state as IsNpcMountedInSlotPrereqState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    if IsDefined(player) && IsDefined(vehicle) {
      if vehicle.GetVehiclePS().IsSlotOccupiedByNPC(this.slotName) {
        if VehicleComponent.IsSlotOccupiedByActivePassenger(game, vehicle.GetEntityID(), this.slotName) {
          return !this.isCheckInverted;
        };
      };
    };
    return this.isCheckInverted;
  }
}

public class CanPlayerHijackMountedNpcPrereqState extends PrereqState {

  public let mountingListener: ref<gameScriptedPrereqMountingListenerWrapper>;

  protected final func OnMountingStateChanged() -> Void {
    let prereq: ref<CanPlayerHijackMountedNpcPrereq> = this.GetPrereq() as CanPlayerHijackMountedNpcPrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class CanPlayerHijackMountedNpcPrereq extends IScriptablePrereq {

  protected let slotName: CName;

  protected let isCheckInverted: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".slotname");
    this.slotName = TDB.GetCName(tweakID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".isCheckInverted");
    this.isCheckInverted = TDB.GetBool(tweakID);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    let castedState: ref<CanPlayerHijackMountedNpcPrereqState> = state as CanPlayerHijackMountedNpcPrereqState;
    if IsDefined(vehicle) {
      castedState.mountingListener = gameScriptedPrereqMountingListenerWrapper.CreateVehicleListener(game, vehicle.GetEntityID(), castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<CanPlayerHijackMountedNpcPrereqState> = state as CanPlayerHijackMountedNpcPrereqState;
    castedState.mountingListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let attitude: EAIAttitude;
    let mountingSlotID: MountingSlotId;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    if IsDefined(player) && IsDefined(vehicle) {
      if VehicleComponent.IsSlotOccupiedByActivePassenger(game, vehicle.GetEntityID(), this.slotName) {
        mountingSlotID.id = this.slotName;
        VehicleComponent.GetAttitudeOfPassenger(game, vehicle.GetEntityID(), mountingSlotID, attitude);
        if Equals(attitude, EAIAttitude.AIA_Neutral) {
          return !this.isCheckInverted;
        };
      };
    };
    return this.isCheckInverted;
  }
}

public class IsNpcPlayingMountingAnimationPrereqState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnPSStateChanged() -> Void {
    let prereq: ref<IsNpcPlayingMountingAnimationPrereq> = this.GetPrereq() as IsNpcPlayingMountingAnimationPrereq;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsNpcPlayingMountingAnimationPrereq extends IScriptablePrereq {

  protected let slotName: CName;

  protected let isCheckInverted: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".slotname");
    this.slotName = TDB.GetCName(tweakID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".isCheckInverted");
    this.isCheckInverted = TDB.GetBool(tweakID);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    let castedState: ref<IsNpcPlayingMountingAnimationPrereqState> = state as IsNpcPlayingMountingAnimationPrereqState;
    if IsDefined(vehicle) {
      persistentId = CreatePersistentID(vehicle.GetEntityID(), vehicle.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsNpcPlayingMountingAnimationPrereqState> = state as IsNpcPlayingMountingAnimationPrereqState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    if IsDefined(player) && IsDefined(vehicle) {
      if VehicleComponent.IsSlotOccupied(game, vehicle.GetEntityID(), this.slotName) {
        if !vehicle.GetVehiclePS().IsSlotOccupiedByNPC(this.slotName) {
          return !this.isCheckInverted;
        };
      };
    };
    return this.isCheckInverted;
  }
}

public class IsVehicleDoorLockedState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnPSStateChanged() -> Void {
    let prereq: ref<IsVehicleDoorLocked> = this.GetPrereq() as IsVehicleDoorLocked;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsVehicleDoorLocked extends IScriptablePrereq {

  protected let slotName: CName;

  protected let isCheckInverted: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".slotname");
    this.slotName = TDB.GetCName(tweakID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".isCheckInverted");
    this.isCheckInverted = TDB.GetBool(tweakID);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    let castedState: ref<IsVehicleDoorLockedState> = state as IsVehicleDoorLockedState;
    if IsDefined(vehicle) {
      persistentId = CreatePersistentID(vehicle.GetEntityID(), vehicle.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsVehicleDoorLockedState> = state as IsVehicleDoorLockedState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let doorEnum: EVehicleDoor;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    if IsDefined(player) && IsDefined(vehicle) {
      vehicle.GetVehiclePS().GetVehicleDoorEnum(doorEnum, this.slotName);
      if Equals(vehicle.GetVehiclePS().GetDoorInteractionState(doorEnum), VehicleDoorInteractionState.Locked) {
        return !this.isCheckInverted;
      };
    };
    return this.isCheckInverted;
  }
}

public class IsVehicleDoorQuestLockedState extends PrereqState {

  public let psListener: ref<gameScriptedPrereqPSChangeListenerWrapper>;

  protected final func OnPSStateChanged() -> Void {
    let prereq: ref<IsVehicleDoorQuestLocked> = this.GetPrereq() as IsVehicleDoorQuestLocked;
    this.OnChanged(prereq.IsFulfilled(GetGameInstance(), this.GetContext()));
  }
}

public class IsVehicleDoorQuestLocked extends IScriptablePrereq {

  protected let slotName: CName;

  protected let isCheckInverted: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    let tweakID: TweakDBID = recordID;
    TDBID.Append(tweakID, t".slotname");
    this.slotName = TDB.GetCName(tweakID);
    tweakID = recordID;
    TDBID.Append(tweakID, t".isCheckInverted");
    this.isCheckInverted = TDB.GetBool(tweakID);
  }

  protected const func OnRegister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Bool {
    let persistentId: PersistentID;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    let castedState: ref<IsVehicleDoorQuestLockedState> = state as IsVehicleDoorQuestLockedState;
    if IsDefined(vehicle) {
      persistentId = CreatePersistentID(vehicle.GetEntityID(), vehicle.GetPSClassName());
      castedState.psListener = gameScriptedPrereqPSChangeListenerWrapper.CreateListener(game, persistentId, castedState);
      return false;
    };
    return false;
  }

  protected const func OnUnregister(state: ref<PrereqState>, game: GameInstance, context: ref<IScriptable>) -> Void {
    let castedState: ref<IsVehicleDoorQuestLockedState> = state as IsVehicleDoorQuestLockedState;
    castedState.psListener = null;
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let doorEnum: EVehicleDoor;
    let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
    let vehicle: ref<VehicleObject> = context as VehicleObject;
    if IsDefined(player) && IsDefined(vehicle) {
      vehicle.GetVehiclePS().GetVehicleDoorEnum(doorEnum, this.slotName);
      if Equals(vehicle.GetVehiclePS().GetDoorInteractionState(doorEnum), VehicleDoorInteractionState.QuestLocked) {
        return !this.isCheckInverted;
      };
    };
    return this.isCheckInverted;
  }
}

public class PlayerHasNanoWiresEquippedPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let friendlyName: String;
    let playerControlledObject: ref<GameObject> = GameInstance.GetPlayerSystem(game).GetLocalPlayerControlledGameObject();
    let weaponObj: ref<WeaponObject> = GameInstance.GetTransactionSystem(playerControlledObject.GetGame()).GetItemInSlot(playerControlledObject, t"AttachmentSlots.WeaponRight") as WeaponObject;
    if IsDefined(playerControlledObject) && IsDefined(weaponObj) {
      friendlyName = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(weaponObj.GetItemID())).FriendlyName();
      if Equals(friendlyName, "mono_wires") {
        return true;
      };
    };
    return false;
  }
}

public class IsMultiplayerGamePrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    return IsMultiplayer();
  }
}

public class PlayerHasCPOMissionDataPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let playerPuppet: ref<PlayerPuppet> = context as PlayerPuppet;
    if IsDefined(playerPuppet) {
      return playerPuppet.HasCPOMissionData();
    };
    return false;
  }
}

public class SelectedForMultiplayerChoiceDialog extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let entity: ref<Entity>;
    let factName: String;
    if !GameInstance.GetRuntimeInfo(game).IsMultiplayer() {
      return true;
    };
    entity = context as Entity;
    factName = GameInstance.GetSceneSystem(game).GetPeerIdDialogChoiceFactName();
    return GameInstance.GetQuestsSystem(game).GetFactStr(factName) == Cast(entity.GetControllingPeerID());
  }
}

public class PlayerCanTakeCPOMissionDataPrereq extends InteractionScriptedCondition {

  public const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>, const hotSpotLayer: wref<HotSpotLayerDefinition>) -> Bool {
    let currentDataOwner: ref<PlayerPuppet> = hotSpotObject as PlayerPuppet;
    let receivingPlayer: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    if IsDefined(currentDataOwner) && IsDefined(receivingPlayer) {
      if !currentDataOwner.m_CPOMissionDataState.m_ownerDecidesOnTransfer && currentDataOwner.HasCPOMissionData() && !receivingPlayer.HasCPOMissionData() {
        return true;
      };
    };
    return false;
  }
}

public class PlayerCanGiveCPOMissionDataPrereq extends InteractionScriptedCondition {

  public const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>, const hotSpotLayer: wref<HotSpotLayerDefinition>) -> Bool {
    let currentDataOwner: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    let receivingPlayer: ref<PlayerPuppet> = hotSpotObject as PlayerPuppet;
    if IsDefined(currentDataOwner) && IsDefined(receivingPlayer) {
      if currentDataOwner.m_CPOMissionDataState.m_ownerDecidesOnTransfer && currentDataOwner.HasCPOMissionData() && !receivingPlayer.HasCPOMissionData() {
        return true;
      };
    };
    return false;
  }
}

public class AccessPointHasCPOMissionDataPrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let device: ref<CPOMissionDataAccessPoint> = context as CPOMissionDataAccessPoint;
    if IsDefined(device) {
      return device.HasDataToDownload();
    };
    return false;
  }
}

public class AccessPointIsBlocked extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let device: ref<CPOMissionDevice> = context as CPOMissionDevice;
    if IsDefined(device) {
      return device.IsBlocked();
    };
    return false;
  }
}

public class IsScannerTarget extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let blackBoard: ref<IBlackboard>;
    let entityID: EntityID;
    let object: wref<GameObject> = context as GameObject;
    if IsDefined(object) {
      blackBoard = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Scanner);
      entityID = blackBoard.GetEntityID(GetAllBlackboardDefs().UI_Scanner.ScannedObject);
      return entityID == object.GetEntityID();
    };
    return false;
  }
}

public class AccessPointCompatibleWithUser extends InteractionScriptedCondition {

  public final const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>, const hotSpotLayer: wref<HotSpotLayerDefinition>) -> Bool {
    let device: ref<CPOMissionDataAccessPoint> = hotSpotObject as CPOMissionDataAccessPoint;
    let playerPuppet: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    if IsDefined(device) && IsDefined(playerPuppet) {
      if NotEquals(device.GetCompatibleDeviceName(), n"") || NotEquals(playerPuppet.GetCompatibleCPOMissionDeviceName(), n"") {
        return Equals(device.GetCompatibleDeviceName(), playerPuppet.GetCompatibleCPOMissionDeviceName());
      };
      return true;
    };
    return false;
  }
}

public class PlayerControlsDevicePrereq extends IScriptablePrereq {

  @default(PlayerControlsDevicePrereq, true)
  private let m_inverse: Bool;

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    if this.m_inverse {
      return !(GameInstance.GetScriptableSystemsContainer(game).Get(n"TakeOverControlSystem") as TakeOverControlSystem).IsDeviceControlled();
    };
    return (GameInstance.GetScriptableSystemsContainer(game).Get(n"TakeOverControlSystem") as TakeOverControlSystem).IsDeviceControlled();
  }

  protected func Initialize(record: TweakDBID) -> Void {
    let tweakID: TweakDBID = record;
    TDBID.Append(tweakID, t".invert");
    this.m_inverse = TDB.GetBool(tweakID);
  }
}

public class PlayerNotInBraindancePrereq extends IScriptablePrereq {

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    return !GameInstance.GetSceneSystem(game).GetScriptInterface().IsRewindableSectionActive();
  }
}

public static exec func EffectorOn(gi: GameInstance, record: String) -> Void {
  let tdbid: TweakDBID = TDBID.Create(record);
  if TDBID.IsValid(tdbid) {
    GameInstance.GetEffectorSystem(gi).ApplyEffector(GetPlayer(gi).GetEntityID(), GetPlayer(gi), tdbid);
  };
}

public static exec func EffectorOnW(gi: GameInstance, record: String) -> Void {
  let player: ref<PlayerPuppet>;
  let wpn: wref<WeaponObject>;
  let tdbid: TweakDBID = TDBID.Create(record);
  if TDBID.IsValid(tdbid) {
    player = GetPlayer(gi);
    wpn = ScriptedPuppet.GetActiveWeapon(player);
    GameInstance.GetEffectorSystem(gi).ApplyEffector(wpn.GetEntityID(), wpn, tdbid);
  };
}

public static exec func EffectorOff(gi: GameInstance, record: String) -> Void {
  GameInstance.GetEffectorSystem(gi).RemoveEffector(GetPlayer(gi).GetEntityID(), TDBID.Create(record));
}

public class CPOMissionPlayerVoted extends InteractionScriptedCondition {

  public const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>, const hotSpotLayer: wref<HotSpotLayerDefinition>) -> Bool {
    let device: ref<CPOVotingDevice> = hotSpotObject as CPOVotingDevice;
    let playerPuppet: ref<PlayerPuppet> = activatorObject as PlayerPuppet;
    if IsDefined(device) && IsDefined(playerPuppet) {
      if NotEquals(device.GetCompatibleDeviceName(), n"") {
        return playerPuppet.GetCPOMissionVoted(device.GetCompatibleDeviceName());
      };
    };
    return false;
  }
}

public class CPOMissionPlayerNotVoted extends CPOMissionPlayerVoted {

  public const func Test(const activatorObject: wref<GameObject>, const hotSpotObject: wref<GameObject>, const hotSpotLayer: wref<HotSpotLayerDefinition>) -> Bool {
    return !this.Test(activatorObject, hotSpotObject, hotSpotLayer);
  }
}

public class PuppetMortalPrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  protected func Initialize(record: TweakDBID) -> Void {
    let tweakID: TweakDBID = record;
    TDBID.Append(tweakID, t".invert");
    this.m_invert = TDB.GetBool(tweakID);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let puppet: ref<ScriptedPuppet> = context as ScriptedPuppet;
    if !IsDefined(puppet) {
      return this.m_invert ? true : false;
    };
    if GameInstance.GetGodModeSystem(puppet.GetGame()).HasGodMode(puppet.GetEntityID(), gameGodModeType.Immortal) {
      return this.m_invert ? true : false;
    };
    if GameInstance.GetGodModeSystem(puppet.GetGame()).HasGodMode(puppet.GetEntityID(), gameGodModeType.Invulnerable) {
      return this.m_invert ? true : false;
    };
    return this.m_invert ? false : true;
  }
}
