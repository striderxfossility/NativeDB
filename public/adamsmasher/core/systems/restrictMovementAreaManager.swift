
public native class CombatRestrictMovementAreaScriptCondition extends ICombatRestrictMovementAreaCondition {

  public func IsFulfilled(game: GameInstance, entityId: EntityID, area: RestrictMovementArea, entityEntered: Bool) -> Bool {
    return true;
  }
}

public class CombatRestrictMovementAreaPlayerEnterMainRMACondition extends CombatRestrictMovementAreaScriptCondition {

  public func IsFulfilled(game: GameInstance, entityId: EntityID, area: RestrictMovementArea, entityEntered: Bool) -> Bool {
    let localPlayer: ref<GameObject>;
    if entityEntered {
      return true;
    };
    if GameInstance.GetRestrictMovementAreaManager(game).HasAssignedRestrictMovementArea(entityId) {
      localPlayer = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject();
      if IsDefined(localPlayer) {
        if GameInstance.GetRestrictMovementAreaManager(game).IsPointInRestrictMovementArea(entityId, localPlayer.GetWorldPosition(), true) {
          return true;
        };
      };
    };
    return false;
  }
}

public class CombatRestrictMovementAreaAllDeadCondition extends CombatRestrictMovementAreaScriptCondition {

  public func IsFulfilled(game: GameInstance, entityId: EntityID, area: RestrictMovementArea, entityEntered: Bool) -> Bool {
    let i: Int32;
    let isDead: Bool;
    let isDefeated: Bool;
    let puppetEntityId: EntityID;
    let puppetsInRestrictedArea: array<EntityID>;
    let someoneAlive: Bool = false;
    if entityEntered {
      return true;
    };
    puppetsInRestrictedArea = GameInstance.GetRestrictMovementAreaManager(game).GetAllPuppetsInRestrictMovementArea(area);
    i = 0;
    while i < ArraySize(puppetsInRestrictedArea) {
      puppetEntityId = puppetsInRestrictedArea[i];
      isDefeated = GameInstance.GetStatusEffectSystem(game).HasStatusEffect(puppetEntityId, t"BaseStatusEffect.Defeated");
      isDead = GameInstance.GetStatPoolsSystem(game).HasStatPoolValueReachedMin(Cast(puppetEntityId), gamedataStatPoolType.Health);
      if !isDefeated && !isDead {
        someoneAlive = true;
      };
      i = i + 1;
    };
    if someoneAlive {
      return false;
    };
    return true;
  }
}
