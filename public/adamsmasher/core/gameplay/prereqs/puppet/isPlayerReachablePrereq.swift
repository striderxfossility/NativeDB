
public class IsPlayerReachablePrereq extends IScriptablePrereq {

  public let m_invert: Bool;

  public let m_checkRMA: Bool;

  protected func Initialize(recordID: TweakDBID) -> Void {
    this.m_invert = TweakDBInterface.GetBool(recordID + t".invert", false);
    this.m_checkRMA = TweakDBInterface.GetBool(recordID + t".checkForRMA", false);
  }

  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let checkNavigationPassed: Bool;
    let checkRMAPassed: Bool;
    let player: wref<ScriptedPuppet> = GetPlayer(game);
    let owner: wref<ScriptedPuppet> = context as ScriptedPuppet;
    if IsDefined(owner) && IsDefined(player) {
      if this.m_checkRMA {
        checkRMAPassed = AIActionHelper.IsPointInRestrictedMovementArea(owner, player.GetWorldPosition());
      };
      if !this.m_invert && !checkRMAPassed {
        return false;
      };
      checkNavigationPassed = AINavigationSystem.HasPathFromAtoB(owner, game, owner.GetWorldPosition(), player.GetWorldPosition());
      if this.m_invert {
        return !checkNavigationPassed || !checkRMAPassed;
      };
      return checkNavigationPassed && checkRMAPassed;
    };
    return false;
  }
}
