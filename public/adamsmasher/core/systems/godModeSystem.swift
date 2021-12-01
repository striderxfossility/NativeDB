
public static func GetImmortality(gameObject: ref<GameObject>, out type: gameGodModeType) -> Bool {
  let godMode: ref<GodModeSystem> = GameInstance.GetGodModeSystem(gameObject.GetGame());
  let entityID: EntityID = gameObject.GetEntityID();
  if !IsDefined(gameObject) || !IsDefined(godMode) {
    return false;
  };
  type = gameGodModeType.Invulnerable;
  if godMode.HasGodMode(entityID, type) {
    return true;
  };
  type = gameGodModeType.Immortal;
  if godMode.HasGodMode(entityID, type) {
    return true;
  };
  return false;
}
