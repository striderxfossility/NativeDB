
public class SubCharacterSystem extends ScriptableSystem {

  private persistent let m_uniqueSubCharacters: array<SSubCharacter>;

  private let m_scriptSpawnedFlathead: Bool;

  private let m_isDespawningFlathead: Bool;

  private func OnAttach() -> Void;

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void;

  private final func AddSubCharacter(character: ref<ScriptedPuppet>) -> Void {
    let equipRequest: ref<EquipRequest>;
    let equipmentData: ref<EquipmentSystemPlayerData>;
    let i: Int32;
    let itemID: ItemID;
    let startingEquipment: array<wref<Item_Record>>;
    let subCharacter: SSubCharacter;
    let subCharType: gamedataSubCharacter = TweakDBInterface.GetSubCharacterRecord(character.GetRecordID()).Type();
    if Equals(subCharType, gamedataSubCharacter.Flathead) {
      if this.IsFlatheadFollowing() {
        if this.m_scriptSpawnedFlathead {
          this.m_isDespawningFlathead = true;
          GameInstance.GetCompanionSystem(this.GetGameInstance()).DespawnSubcharacter(t"Character.spiderbot_new");
          LogError("[Companion System] Flathead spawned from quest/scene graph. Please remove this spawn (unless it\'s Q003 or Q005).");
        } else {
          this.m_scriptSpawnedFlathead = false;
        };
      };
    };
    if !this.SubCharacterExists(subCharType) || this.m_isDespawningFlathead {
      subCharacter.persistentID = character.GetPersistentID();
      subCharacter.subCharType = subCharType;
      equipmentData = new EquipmentSystemPlayerData();
      equipmentData.SetOwner(character);
      equipmentData.OnInitialize();
      subCharacter.equipmentData = equipmentData;
      ArrayPush(this.m_uniqueSubCharacters, subCharacter);
      TweakDBInterface.GetSubCharacterRecord(character.GetRecordID()).StartingEquippedItems(startingEquipment);
      i = 0;
      while i < ArraySize(startingEquipment) {
        itemID = ItemID.CreateQuery(startingEquipment[i].GetID());
        equipRequest = new EquipRequest();
        equipRequest.itemID = itemID;
        equipmentData.OnEquipRequest(equipRequest);
        i += 1;
      };
    } else {
      this.m_uniqueSubCharacters[this.GetSubCharacterIndex(subCharType)].equipmentData.SetOwner(character);
      i = 0;
      while i < ArraySize(this.m_uniqueSubCharacters) {
        this.m_uniqueSubCharacters[i].equipmentData.OnRestored();
        i += 1;
      };
    };
    if Equals(subCharType, gamedataSubCharacter.Flathead) {
      this.AddFlathead();
    };
  }

  private final func RemoveSubCharacter(subCharType: gamedataSubCharacter) -> Void {
    if !this.SubCharacterExists(subCharType) {
      LogWarning("[SubCharacterSystem] Trying to remove a subcharacter of type " + ToString(subCharType) + ", but a subCharacter of that type has not been spawned.");
    };
    ArrayErase(this.m_uniqueSubCharacters, this.GetSubCharacterIndex(subCharType));
    if Equals(subCharType, gamedataSubCharacter.Flathead) {
      this.RemoveFlathead();
      this.m_isDespawningFlathead = false;
    };
  }

  private final func AddFlathead() -> Void {
    let autocraftActivateRequest: ref<AutocraftActivateRequest>;
    let autocraftSystem: ref<AutocraftSystem>;
    let followerRole: ref<AIFollowerRole> = new AIFollowerRole();
    followerRole.SetFollowTarget(GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject());
    AIHumanComponent.SetCurrentRole(this.GetFlathead(), followerRole);
    autocraftSystem = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"AutocraftSystem") as AutocraftSystem;
    autocraftActivateRequest = new AutocraftActivateRequest();
    autocraftSystem.QueueRequest(autocraftActivateRequest);
    this.ShowFlatheadUI(true);
  }

  private final func RemoveFlathead() -> Void {
    let autocraftSystem: ref<AutocraftSystem> = GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"AutocraftSystem") as AutocraftSystem;
    let autocraftDeactivateRequest: ref<AutocraftDeactivateRequest> = new AutocraftDeactivateRequest();
    autocraftDeactivateRequest.resetMemory = true;
    autocraftSystem.QueueRequest(autocraftDeactivateRequest);
    this.ShowFlatheadUI(false);
  }

  private final func ShowFlatheadUI(value: Bool) -> Void {
    let bbCompanion: ref<UI_CompanionDef> = GetAllBlackboardDefs().UI_Companion;
    GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(bbCompanion).SetBool(bbCompanion.flatHeadSpawned, value, true);
  }

  private final const func SubCharacterExists(subCharType: gamedataSubCharacter) -> Bool {
    return this.GetSubCharacterIndex(subCharType) >= 0;
  }

  private final const func GetSubCharacterIndex(subCharType: gamedataSubCharacter) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_uniqueSubCharacters) {
      if Equals(this.m_uniqueSubCharacters[i].subCharType, subCharType) {
        return i;
      };
      i += 1;
    };
    return -1;
  }

  public final const func GetAllSubCharacters() -> array<SSubCharacter> {
    return this.m_uniqueSubCharacters;
  }

  public final const func GetSubCharacterPuppet(subCharType: gamedataSubCharacter) -> wref<ScriptedPuppet> {
    if this.SubCharacterExists(subCharType) {
      return this.m_uniqueSubCharacters[this.GetSubCharacterIndex(subCharType)].equipmentData.GetOwner();
    };
    return null;
  }

  public final const func GetSubCharacterPersistentID(subCharType: gamedataSubCharacter) -> PersistentID {
    let persistentID: PersistentID;
    if this.SubCharacterExists(subCharType) {
      persistentID = this.m_uniqueSubCharacters[this.GetSubCharacterIndex(subCharType)].persistentID;
    };
    return persistentID;
  }

  public final const func GetSubCharacterEquipment(subCharType: gamedataSubCharacter) -> ref<EquipmentSystemPlayerData> {
    let equipmentData: ref<EquipmentSystemPlayerData>;
    if this.SubCharacterExists(subCharType) {
      equipmentData = this.m_uniqueSubCharacters[this.GetSubCharacterIndex(subCharType)].equipmentData;
    };
    return equipmentData;
  }

  public final const func GetFlathead() -> wref<ScriptedPuppet> {
    return this.GetSubCharacterPuppet(gamedataSubCharacter.Flathead);
  }

  public final const func GetFlatheadPersistentID() -> PersistentID {
    return this.GetSubCharacterPersistentID(gamedataSubCharacter.Flathead);
  }

  public final const func GetFlatheadEquipment() -> wref<EquipmentSystemPlayerData> {
    return this.GetSubCharacterEquipment(gamedataSubCharacter.Flathead);
  }

  public final const func IsFlatheadFollowing() -> Bool {
    return this.GetFlathead() != null;
  }

  public final static func GetInstance(gameInstance: GameInstance) -> ref<SubCharacterSystem> {
    return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"SubCharacterSystem") as SubCharacterSystem;
  }

  public final static func IsFlathead(object: wref<GameObject>) -> Bool {
    let puppet: wref<ScriptedPuppet> = object as ScriptedPuppet;
    if IsDefined(puppet) {
      return puppet.GetRecordID() == t"Character.spiderbot_new";
    };
    return false;
  }

  public final static func IsSubCharacterSpawned(gameInstance: GameInstance, opt characterID: TweakDBID) -> Bool {
    let entities: array<wref<Entity>>;
    let subCharSys: ref<SubCharacterSystem>;
    if !GameInstance.IsValid(gameInstance) {
      return false;
    };
    subCharSys = SubCharacterSystem.GetInstance(gameInstance);
    if !IsDefined(subCharSys) {
      return false;
    };
    GameInstance.GetCompanionSystem(gameInstance).GetSpawnedEntities(entities, characterID);
    if ArraySize(entities) > 0 {
      return true;
    };
    return false;
  }

  private final func OnAddSubCharacterRequest(request: ref<AddSubCharacterRequest>) -> Void {
    this.AddSubCharacter(request.subCharObject);
  }

  private final func OnRemoveSubCharacterRequest(request: ref<RemoveSubCharacterRequest>) -> Void {
    this.RemoveSubCharacter(request.subCharType);
  }

  private final func OnSubCharEquipRequest(request: ref<SubCharEquipRequest>) -> Void {
    if this.SubCharacterExists(request.subCharType) {
      this.m_uniqueSubCharacters[this.GetSubCharacterIndex(request.subCharType)].equipmentData.OnEquipRequest(request);
    };
  }

  private final func OnSubCharEquipRequest(request: ref<SubCharUnequipRequest>) -> Void {
    if this.SubCharacterExists(request.subCharType) {
      this.m_uniqueSubCharacters[this.GetSubCharacterIndex(request.subCharType)].equipmentData.OnUnequipRequest(request);
    };
  }

  private final func OnSpawnUniqueSubCharacterRequest(request: ref<SpawnUniqueSubCharacterRequest>) -> Void {
    let heading: Vector4;
    let offsetDir: Vector3;
    let subCharType: gamedataSubCharacter;
    let subCharRecord: wref<SubCharacter_Record> = TweakDBInterface.GetSubCharacterRecord(request.subCharacterID);
    if !IsDefined(subCharRecord) {
      LogError("[SubCharacterSystem] Tried spawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but it\'s not a valid subCharacter. Please contact rpg team for help.");
      return;
    };
    subCharType = subCharRecord.Type();
    if this.SubCharacterExists(subCharType) {
      LogWarning("[SubCharacterSystem] Tried spawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but a subCharacter with that ID has already been spawned.");
      return;
    };
    heading = -1.00 * GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetWorldForward();
    offsetDir = new Vector3(heading.X, heading.Y, heading.Z);
    GameInstance.GetCompanionSystem(this.GetGameInstance()).SpawnSubcharacter(request.subCharacterID, request.desiredDistance, offsetDir);
    if request.subCharacterID == t"Character.spiderbot_new" {
      this.m_scriptSpawnedFlathead = true;
    };
  }

  private final func OnSpawnUniquePursuitSubCharacterRequest(request: ref<SpawnUniquePursuitSubCharacterRequest>) -> Void {
    let subCharRecord: wref<SubCharacter_Record> = TweakDBInterface.GetSubCharacterRecord(request.subCharacterID);
    if !IsDefined(subCharRecord) {
      LogError("[SubCharacterSystem] Tried spawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but it\'s not a valid subCharacter. Please contact rpg team for help.");
      return;
    };
    GameInstance.GetCompanionSystem(this.GetGameInstance()).SpawnSubcharacterOnPosition(request.subCharacterID, Vector4.Vector4To3(request.position));
  }

  private final func OnDespawnUniqueSubCharacterRequest(request: ref<DespawnUniqueSubCharacterRequest>) -> Void {
    let subCharType: gamedataSubCharacter;
    let subCharRecord: wref<SubCharacter_Record> = TweakDBInterface.GetSubCharacterRecord(request.subCharacterID);
    if !IsDefined(subCharRecord) {
      LogError("[SubCharacterSystem] Tried despawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but it\'s not a valid subCharacter. Please contact rpg team for help.");
      return;
    };
    subCharType = subCharRecord.Type();
    if !this.SubCharacterExists(subCharType) {
      LogWarning("[SubCharacterSystem] Tried despawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but a subCharacter with that ID has not been spawned.");
      return;
    };
    GameInstance.GetCompanionSystem(this.GetGameInstance()).DespawnSubcharacter(request.subCharacterID);
  }

  private final func OnSpawnSubCharacterRequest(request: ref<SpawnSubCharacterRequest>) -> Void {
    let heading: Vector4;
    let offsetDir: Vector3;
    let subCharRecord: wref<SubCharacter_Record> = TweakDBInterface.GetSubCharacterRecord(request.subCharacterID);
    if !IsDefined(subCharRecord) {
      LogError("[SubCharacterSystem] Tried spawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but it\'s not a valid subCharacter. Please contact  rpg team for help.");
      return;
    };
    heading = -1.00 * GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject().GetWorldForward();
    offsetDir = new Vector3(heading.X, heading.Y, heading.Z);
    GameInstance.GetCompanionSystem(this.GetGameInstance()).SpawnSubcharacter(request.subCharacterID, request.desiredDistance, offsetDir);
    if request.subCharacterID == t"Character.spiderbot_new" {
      this.m_scriptSpawnedFlathead = true;
    };
  }

  private final func OnDespawnSubCharacterRequest(request: ref<DespawnSubCharacterRequest>) -> Void {
    let subCharRecord: wref<SubCharacter_Record> = TweakDBInterface.GetSubCharacterRecord(request.subCharacterID);
    if !IsDefined(subCharRecord) {
      LogError("[SubCharacterSystem] Tried despawning a subcharacter with TDBID " + TDBID.ToStringDEBUG(request.subCharacterID) + ", but it\'s not a valid subCharacter. Please contact rpg team for help.");
      return;
    };
    GameInstance.GetCompanionSystem(this.GetGameInstance()).DespawnSubcharacter(request.subCharacterID);
  }

  public final static func DespawnRequest(gameInstance: GameInstance, opt characterID: TweakDBID) -> Bool {
    let entities: array<wref<Entity>>;
    let i: Int32;
    let npc: ref<NPCPuppet>;
    if !GameInstance.IsValid(gameInstance) {
      return false;
    };
    GameInstance.GetCompanionSystem(gameInstance).GetSpawnedEntities(entities, characterID);
    i = 0;
    while i < ArraySize(entities) {
      npc = entities[i] as NPCPuppet;
      if IsDefined(npc) {
        npc.QueueEvent(new SmartDespawnRequest());
      };
      i += 1;
    };
    if ArraySize(entities) > 0 {
      return true;
    };
    return false;
  }

  public final static func CancelDespawnRequest(gameInstance: GameInstance, opt characterID: TweakDBID) -> Bool {
    let entities: array<wref<Entity>>;
    let i: Int32;
    let npc: ref<NPCPuppet>;
    if !GameInstance.IsValid(gameInstance) {
      return false;
    };
    GameInstance.GetCompanionSystem(gameInstance).GetSpawnedEntities(entities, characterID);
    i = 0;
    while i < ArraySize(entities) {
      npc = entities[i] as NPCPuppet;
      if IsDefined(npc) {
        npc.QueueEvent(new CancelSmartDespawnRequest());
      };
      i += 1;
    };
    if ArraySize(entities) > 0 {
      return true;
    };
    return false;
  }
}

public static exec func SpawnFlathead(gi: GameInstance) -> Void {
  let spawnFlatheadRequest: ref<SpawnUniqueSubCharacterRequest>;
  let scs: ref<SubCharacterSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"SubCharacterSystem") as SubCharacterSystem;
  if IsDefined(scs) {
    spawnFlatheadRequest = new SpawnUniqueSubCharacterRequest();
    spawnFlatheadRequest.subCharacterID = t"Character.spiderbot_new";
    scs.QueueRequest(spawnFlatheadRequest);
  };
}

public static exec func DespawnFlathead(gi: GameInstance) -> Void {
  let despawnFlatheadRequest: ref<DespawnUniqueSubCharacterRequest>;
  let scs: ref<SubCharacterSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"SubCharacterSystem") as SubCharacterSystem;
  if IsDefined(scs) {
    despawnFlatheadRequest = new DespawnUniqueSubCharacterRequest();
    despawnFlatheadRequest.subCharacterID = t"Character.spiderbot_new";
    scs.QueueRequest(despawnFlatheadRequest);
  };
}
