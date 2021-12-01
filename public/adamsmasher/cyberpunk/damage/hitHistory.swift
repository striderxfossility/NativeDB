
public class HitHistory extends IScriptable {

  private let m_hitHistory: array<HitHistoryItem>;

  @default(HitHistory, 5)
  private let m_maxEntries: Int32;

  public final func AddHit(evt: ref<gameHitEvent>) -> Void {
    let hitTime: Float;
    let instigator: wref<GameObject> = null;
    let isMelee: Bool = false;
    if IsDefined(evt.attackData) {
      instigator = evt.attackData.GetInstigator();
      isMelee = AttackData.IsMelee(evt.attackData.GetAttackType());
    };
    if IsDefined(instigator) {
      hitTime = EngineTime.ToFloat(GameInstance.GetSimTime(instigator.GetGame()));
      this.Add(instigator, hitTime, isMelee);
    };
  }

  public final func GetLastDamageTime(object: ref<GameObject>, out isMelee: Bool) -> Float {
    let i: Int32 = 0;
    while i < ArraySize(this.m_hitHistory) {
      if this.m_hitHistory[i].instigator == object {
        isMelee = this.m_hitHistory[i].isMelee;
        return this.m_hitHistory[i].hitTime;
      };
      i += 1;
    };
    return -1.00;
  }

  private final func Add(instigator: wref<GameObject>, hitTime: Float, isMelee: Bool) -> Void {
    let hitHistoryItem: HitHistoryItem;
    let oldestEntryTime: Float = -1.00;
    let oldestEntryNdx: Int32 = -1;
    let entryNdx: Int32 = -1;
    let i: Int32 = 0;
    while i < ArraySize(this.m_hitHistory) {
      if this.m_hitHistory[i].instigator == instigator {
        entryNdx = i;
      } else {
        if oldestEntryTime == -1.00 || oldestEntryTime > this.m_hitHistory[i].hitTime {
          oldestEntryNdx = i;
          oldestEntryTime = this.m_hitHistory[i].hitTime;
        };
        i += 1;
      };
    };
    hitHistoryItem.instigator = instigator;
    hitHistoryItem.hitTime = hitTime;
    hitHistoryItem.isMelee = isMelee;
    if entryNdx == -1 {
      if ArraySize(this.m_hitHistory) < this.m_maxEntries {
        ArrayPush(this.m_hitHistory, hitHistoryItem);
      } else {
        this.m_hitHistory[oldestEntryNdx] = hitHistoryItem;
      };
    } else {
      this.m_hitHistory[entryNdx] = hitHistoryItem;
    };
  }
}
