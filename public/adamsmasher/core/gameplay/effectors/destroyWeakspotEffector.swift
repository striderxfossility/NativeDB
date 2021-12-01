
public class DestroyWeakspotEffector extends Effector {

  public let m_weakspotIndex: Int32;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_weakspotIndex = TweakDBInterface.GetInt(record + t".weakSpotIndex", 0);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let i: Int32;
    let weakspot: ref<WeakspotObject>;
    let weakspotComponent: ref<WeakspotComponent>;
    let weakspots: array<wref<WeakspotObject>>;
    let npc: ref<NPCPuppet> = owner as NPCPuppet;
    if !IsDefined(npc) {
      return;
    };
    weakspotComponent = npc.GetWeakspotComponent();
    if !IsDefined(weakspotComponent) {
      return;
    };
    weakspotComponent.GetWeakspots(weakspots);
    if ArraySize(weakspots) <= 0 {
      return;
    };
    if this.m_weakspotIndex < 0 {
      i = 0;
      while i < ArraySize(weakspots) {
        if !weakspots[i].IsDead() {
          weakspot = weakspots[i];
        } else {
          i += 1;
        };
      };
    } else {
      if this.m_weakspotIndex >= ArraySize(weakspots) {
        return;
      };
      weakspot = weakspots[this.m_weakspotIndex];
    };
    if GameInstance.GetGodModeSystem(npc.GetGame()).HasGodMode(npc.GetEntityID(), gameGodModeType.Invulnerable) {
      return;
    };
    ScriptedWeakspotObject.Kill(weakspot, GameInstance.GetPlayerSystem(npc.GetGame()).GetLocalPlayerMainGameObject());
  }
}
