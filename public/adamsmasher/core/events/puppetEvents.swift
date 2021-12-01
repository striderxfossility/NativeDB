
public class ApplyNewStatusEffectEvent extends Event {

  public let effectID: TweakDBID;

  public let instigatorID: TweakDBID;

  public final func SetEffectID(effectName: String) -> Void {
    this.effectID = TDBID.Create(effectName);
  }
}

public class RemoveStatusEffectEvent extends Event {

  public let effectID: TweakDBID;

  public let removeCount: Uint32;

  public final func SetEffectID(effectName: String) -> Void {
    this.effectID = TDBID.Create(effectName);
  }
}
