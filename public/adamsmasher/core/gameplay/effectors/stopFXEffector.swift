
public class StopVFXEffector extends Effector {

  public let m_vfxName: CName;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_vfxName = TweakDBInterface.GetCName(record + t".vfxName", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    GameObjectEffectHelper.StopEffectEvent(this.m_owner, this.m_vfxName);
  }
}

public class StopSFXEffector extends Effector {

  public let m_sfxName: CName;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_sfxName = TweakDBInterface.GetCName(record + t".sfxName", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    GameObject.PlaySound(this.m_owner, this.m_sfxName, n"Scripts:StopSFXEffector:ActionOn");
  }
}
