
public class StopAndPlayVFXEffector extends Effector {

  public let m_vfxToStop: CName;

  public let m_vfxToStart: CName;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_vfxToStop = TweakDBInterface.GetCName(record + t".vfxToStop", n"");
    this.m_vfxToStart = TweakDBInterface.GetCName(record + t".vfxToStart", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    GameObjectEffectHelper.StopEffectEvent(this.m_owner, this.m_vfxToStop);
    GameObjectEffectHelper.StartEffectEvent(this.m_owner, this.m_vfxToStart);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    GameObjectEffectHelper.StopEffectEvent(this.m_owner, this.m_vfxToStart);
  }
}

public class StopAndPlaySFXEffector extends Effector {

  public let m_sfxToStop: CName;

  public let m_sfxToStart: CName;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_sfxToStop = TweakDBInterface.GetCName(record + t".sfxToStop", n"");
    this.m_sfxToStart = TweakDBInterface.GetCName(record + t".sfxToStart", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    GameObject.StopSound(this.m_owner, this.m_sfxToStop, n"Scripts:StopAndPlaySFXEffector:ActionOn");
    GameObject.PlaySound(this.m_owner, this.m_sfxToStart, n"Scripts:StopAndPlaySFXEffector:ActionOn");
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    GameObject.StopSound(this.m_owner, this.m_sfxToStart, n"Scripts:StopAndPlaySFXEffector:Uninitialize");
  }
}
