
public class PlayVFXEffector extends Effector {

  public let m_vfxName: CName;

  public let m_startOnUninitialize: Bool;

  public let m_fireAndForget: Bool;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_vfxName = TweakDBInterface.GetCName(record + t".vfxName", n"");
    this.m_startOnUninitialize = TweakDBInterface.GetBool(record + t".startOnUninitialize", false);
    this.m_fireAndForget = TweakDBInterface.GetBool(record + t".fireAndForget", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if !this.m_startOnUninitialize {
      GameObjectEffectHelper.StartEffectEvent(this.m_owner, this.m_vfxName);
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.Deactivate();
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.Deactivate();
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    if this.m_fireAndForget {
      this.ActionOn(owner);
    };
  }

  protected final func Deactivate() -> Void {
    if this.m_startOnUninitialize {
      GameObjectEffectHelper.StartEffectEvent(this.m_owner, this.m_vfxName);
    } else {
      GameObjectEffectHelper.BreakEffectLoopEvent(this.m_owner, this.m_vfxName);
    };
  }
}

public class PlaySFXEffector extends Effector {

  public let activationSFXName: CName;

  public let deactivationSFXName: CName;

  public let m_startOnUninitialize: Bool;

  public let m_unique: Bool;

  public let m_fireAndForget: Bool;

  public let m_stopActiveSfxOnDeactivate: Bool;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.activationSFXName = TweakDBInterface.GetCName(record + t".activationSFXName", n"");
    this.deactivationSFXName = TweakDBInterface.GetCName(record + t".deactivationSFXName", n"");
    this.m_startOnUninitialize = TweakDBInterface.GetBool(record + t".startOnUninitialize", false);
    this.m_unique = TweakDBInterface.GetBool(record + t".unique", false);
    this.m_fireAndForget = TweakDBInterface.GetBool(record + t".fireAndForget", false);
    this.m_stopActiveSfxOnDeactivate = TweakDBInterface.GetBool(record + t".stopActiveSfxOnDeactivate", true);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if !this.m_startOnUninitialize && IsNameValid(this.activationSFXName) {
      if !this.m_unique {
        GameObject.PlaySound(this.m_owner, this.activationSFXName, n"PlaySFXEffector");
      } else {
        GameObject.PlaySoundWithParams(this.m_owner, this.activationSFXName, n"PlaySFXEffector", audioAudioEventFlags.Unique);
      };
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.Deactivate();
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.Deactivate();
  }

  protected func RepeatedAction(owner: ref<GameObject>) -> Void {
    if this.m_fireAndForget {
      this.ActionOn(owner);
    };
  }

  protected final func Deactivate() -> Void {
    if IsNameValid(this.activationSFXName) {
      if this.m_startOnUninitialize {
        GameObject.PlaySound(this.m_owner, this.activationSFXName, n"PlaySFXEffector");
      } else {
        if this.m_stopActiveSfxOnDeactivate {
          GameObject.StopSound(this.m_owner, this.activationSFXName, n"PlaySFXEffector");
        };
      };
    };
    if IsNameValid(this.deactivationSFXName) {
      GameObject.PlaySound(this.m_owner, this.deactivationSFXName, n"PlaySFXEffector");
    };
  }
}
