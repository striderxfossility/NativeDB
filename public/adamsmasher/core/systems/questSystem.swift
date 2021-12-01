
public static func GetGameObjectFromEntityReference(const reference: EntityReference, gameInstance: GameInstance, out target: wref<GameObject>) -> Bool {
  let entityIds: array<EntityID>;
  let nullArrayOfNames: array<CName>;
  if !GameInstance.IsValid(gameInstance) {
    return false;
  };
  GetFixedEntityIdsFromEntityReference(reference, gameInstance, entityIds);
  if ArraySize(entityIds) > 0 {
    target = GameInstance.FindEntityByID(gameInstance, entityIds[0]) as GameObject;
  } else {
    if Equals(CreateEntityReference("#player", nullArrayOfNames), reference) {
      target = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject();
    };
  };
  if !IsDefined(target) {
    return false;
  };
  return true;
}
