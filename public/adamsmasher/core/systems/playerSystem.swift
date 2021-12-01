
public final native class PlayerSystem extends gamePlayerSystem {

  public final native const func GetLocalPlayerMainGameObject() -> ref<GameObject>;

  public final native const func GetLocalPlayerControlledGameObject() -> ref<GameObject>;

  public final native func LocalPlayerControlExistingObject(entityID: EntityID) -> Void;

  public final native func RegisterPlayerPuppetAttachedCallback(object: ref<IScriptable>, func: CName) -> Uint32;

  public final native func UnregisterPlayerPuppetAttachedCallback(callbackID: Uint32) -> Void;

  public final native func RegisterPlayerPuppetDetachedCallback(object: ref<IScriptable>, func: CName) -> Uint32;

  public final native func UnregisterPlayerPuppetDetachedCallback(callbackID: Uint32) -> Void;

  public final native func FindPlayerControlledObjects(position: Vector4, radius: Float, includeLocalPlayers: Bool, includeRemotePlayers: Bool, out outPlayerGameObjects: array<ref<GameObject>>) -> Uint32;

  public final native func IsInFreeCamera() -> Bool;

  public final native func SetFreeCameraTransform(newTransform: Transform) -> Void;

  public final native func IsCPOControlSchemeForced() -> Bool;

  public final const func GetPossessedByJohnnyFactName() -> String {
    return "isPlayerPossessedByJohnny";
  }

  protected final cb func OnGameRestored(game: GameInstance) -> Bool {
    if Cast(GameInstance.GetQuestsSystem(game).GetFactStr(this.GetPossessedByJohnnyFactName())) {
      this.OnLocalPlayerPossesionChanged(gamedataPlayerPossesion.Johnny);
    } else {
      this.OnLocalPlayerPossesionChanged(gamedataPlayerPossesion.Default);
    };
    return true;
  }

  protected final cb func OnLocalPlayerChanged(controlledObject: wref<GameObject>) -> Bool {
    let controlledPuppetRecordID: TweakDBID;
    let playerStatsBB: ref<IBlackboard>;
    let controlledPuppet: ref<gamePuppetBase> = controlledObject as gamePuppetBase;
    if controlledPuppet == null {
      return false;
    };
    playerStatsBB = GameInstance.GetBlackboardSystem(controlledPuppet.GetGame()).Get(GetAllBlackboardDefs().UI_PlayerStats);
    controlledPuppetRecordID = controlledPuppet.GetRecordID();
    if controlledPuppetRecordID == t"Character.Player_Puppet_Base" {
      playerStatsBB.SetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer, false, true);
    } else {
      if controlledPuppetRecordID == t"Character.johnny_replacer" {
        playerStatsBB.SetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer, true, true);
      } else {
        playerStatsBB.SetBool(GetAllBlackboardDefs().UI_PlayerStats.isReplacer, true, true);
      };
    };
    return true;
  }

  protected final cb func OnLocalPlayerPossesionChanged(playerPossesion: gamedataPlayerPossesion) -> Bool {
    let uiSystem: ref<UISystem>;
    let localPlayer: ref<GameObject> = this.GetLocalPlayerMainGameObject();
    if IsDefined(localPlayer) {
      uiSystem = GameInstance.GetUISystem(localPlayer.GetGame());
    };
    if Equals(playerPossesion, gamedataPlayerPossesion.Default) {
      if IsDefined(uiSystem) {
        uiSystem.ClearGlobalThemeOverride();
      };
    } else {
      if Equals(playerPossesion, gamedataPlayerPossesion.Johnny) {
        if IsDefined(uiSystem) {
          uiSystem.SetGlobalThemeOverride(n"Possessed");
        };
      };
    };
    return true;
  }
}
