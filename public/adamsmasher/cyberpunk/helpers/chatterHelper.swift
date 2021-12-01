
public class CoopIrritationDelayCallback extends DelayCallback {

  public let m_companion: wref<GameObject>;

  public final static func TryCreate(dmgInstigator: wref<GameObject>) -> Void {
    let delayCallback: ref<CoopIrritationDelayCallback>;
    if IsDefined(dmgInstigator) && ScriptedPuppet.IsPlayerCompanion(dmgInstigator) {
      delayCallback = new CoopIrritationDelayCallback();
      delayCallback.m_companion = dmgInstigator;
      GameInstance.GetDelaySystem(dmgInstigator.GetGame()).DelayCallback(delayCallback, 10.00);
    };
  }

  public func Call() -> Void {
    let playerPuppet: wref<PlayerPuppet>;
    if !ScriptedPuppet.IsActive(this.m_companion) {
      return;
    };
    playerPuppet = GameInstance.GetPlayerSystem(this.m_companion.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    if !IsDefined(playerPuppet) || !playerPuppet.GetTargetTrackerComponent().HasHostileThreat(false) || !this.m_companion.GetTargetTrackerComponent().HasHostileThreat(false) {
      return;
    };
    if EngineTime.ToFloat(GameInstance.GetSimTime(this.m_companion.GetGame()) - playerPuppet.GetLastDamageInflictedTime()) >= 10.00 {
      GameObject.PlayVoiceOver(this.m_companion, n"coop_irritation", n"CoopIrritationDelayCallback");
    };
  }
}
