
public class PlayerCoverHelper extends IScriptable {

  public final static func GetBlockCoverStatusEffectID() -> TweakDBID {
    return t"BaseStatusEffect.BlockCoverVisibilityReduction";
  }

  public final static func BlockCoverVisibilityReduction(owner: wref<GameObject>) -> Void {
    GameInstance.GetStatusEffectSystem(owner.GetGame()).ApplyStatusEffect(owner.GetEntityID(), PlayerCoverHelper.GetBlockCoverStatusEffectID());
  }
}
