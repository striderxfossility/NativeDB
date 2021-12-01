
public class BossHealthBarGameController extends inkHUDGameController {

  private edit let m_healthControllerRef: inkWidgetRef;

  private edit let m_healthPersentage: inkTextRef;

  private edit let m_bossName: inkTextRef;

  private let m_statListener: ref<BossHealthStatListener>;

  private let m_boss: wref<NPCPuppet>;

  private let m_healthController: wref<NameplateBarLogicController>;

  private let m_root: wref<inkWidget>;

  private let m_foldAnimation: ref<inkAnimProxy>;

  private let m_bossPuppets: array<wref<NPCPuppet>>;

  protected cb func OnInitialize() -> Bool {
    this.m_healthController = inkWidgetRef.GetController(this.m_healthControllerRef) as NameplateBarLogicController;
    this.m_statListener = new BossHealthStatListener();
    this.m_statListener.BindHealthbar(this);
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
    IBlackboard.Create(GetAllBlackboardDefs().PuppetState);
    this.m_boss = null;
    ArrayClear(this.m_bossPuppets);
  }

  public final func UpdateHealthValue(newValue: Float) -> Void {
    this.m_healthController.SetNameplateBarProgress(newValue / 100.00, false);
    inkTextRef.SetText(this.m_healthPersentage, IntToString(Cast(newValue)));
  }

  protected cb func OnBossCombatNotifier(evt: ref<BossCombatNotifier>) -> Bool {
    if evt.combatEnded {
      this.ReevaluateBossArray();
    } else {
      this.AddBoss(evt.bossEntity as NPCPuppet);
    };
  }

  protected cb func OnThreatDefeated(evt: ref<ThreatDefeated>) -> Bool {
    if IsDefined(evt.threat) {
      this.RemoveBoss(evt.threat as NPCPuppet);
    } else {
      this.ReevaluateBossArray();
    };
  }

  protected cb func OnThreatUnconscious(evt: ref<ThreatUnconscious>) -> Bool {
    if IsDefined(evt.threat) {
      this.RemoveBoss(evt.threat as NPCPuppet);
    } else {
      this.ReevaluateBossArray();
    };
  }

  protected cb func OnThreatKilled(evt: ref<ThreatDeath>) -> Bool {
    if IsDefined(evt.threat) {
      this.RemoveBoss(evt.threat as NPCPuppet);
    } else {
      this.ReevaluateBossArray();
    };
  }

  protected cb func OnThreatRemoved(evt: ref<ThreatRemoved>) -> Bool {
    if IsDefined(evt.threat) {
      this.RemoveBoss(evt.threat as NPCPuppet);
    } else {
      this.ReevaluateBossArray();
    };
  }

  protected cb func OnThreatInvalid(evt: ref<ThreatInvalid>) -> Bool {
    if IsDefined(evt.threat) {
      this.RemoveBoss(evt.threat as NPCPuppet);
    } else {
      this.ReevaluateBossArray();
    };
  }

  protected cb func OnAnimationEnd(e: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
  }

  protected cb func OnDamageDealt(evt: ref<gameTargetDamageEvent>) -> Bool {
    if this.m_root.IsVisible() {
      this.AddBoss(evt.target as NPCPuppet, true);
    };
  }

  private final func AddBoss(boss: ref<NPCPuppet>, opt priorityTarget: Bool) -> Void {
    if !IsDefined(boss) || !boss.IsBoss() {
      return;
    };
    if ArrayContains(this.m_bossPuppets, boss) {
      if priorityTarget && boss != this.m_boss {
        this.ShowBossHealthBar(boss);
      };
      return;
    };
    ArrayPush(this.m_bossPuppets, boss);
    if !IsDefined(this.m_boss) || priorityTarget {
      this.ShowBossHealthBar(boss);
    };
  }

  private final func RemoveBoss(boss: ref<NPCPuppet>) -> Void {
    if !IsDefined(boss) || !ArrayContains(this.m_bossPuppets, boss) {
      return;
    };
    ArrayRemove(this.m_bossPuppets, boss);
    if ArraySize(this.m_bossPuppets) > 0 && IsDefined(this.m_bossPuppets[0]) {
      this.ShowBossHealthBar(this.m_bossPuppets[0]);
    } else {
      this.HideBossHealthBar();
    };
  }

  private final func ReevaluateBossArray() -> Void {
    let i: Int32 = ArraySize(this.m_bossPuppets) - 1;
    while i >= 0 {
      if !IsDefined(this.m_bossPuppets[i]) || !ScriptedPuppet.IsActive(this.m_bossPuppets[i]) || GameObject.IsFriendlyTowardsPlayer(this.m_bossPuppets[i]) {
        ArrayErase(this.m_bossPuppets, i);
      };
      i -= 1;
    };
    if ArraySize(this.m_bossPuppets) == 0 && this.m_root.IsVisible() {
      this.HideBossHealthBar();
    };
  }

  private final func ShowBossHealthBar(puppet: ref<NPCPuppet>) -> Void {
    let playUnfoldAnim: Bool;
    if !IsDefined(puppet) || !puppet.IsBoss() {
      return;
    };
    playUnfoldAnim = !IsDefined(this.m_boss);
    this.UnregisterPreviousBoss();
    this.RegisterToNewBoss(puppet);
    this.m_root.SetVisible(true);
    if playUnfoldAnim {
      if IsDefined(this.m_foldAnimation) {
        this.m_foldAnimation.Stop();
      };
      this.m_foldAnimation = this.PlayLibraryAnimation(n"unfold");
    };
  }

  private final func HideBossHealthBar() -> Void {
    this.UnregisterPreviousBoss();
    this.m_foldAnimation = this.PlayLibraryAnimation(n"fold");
    this.m_foldAnimation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimationEnd");
  }

  private final func RegisterToNewBoss(boss: ref<NPCPuppet>) -> Void {
    let NPCName: String;
    let characterRecord: ref<Character_Record>;
    this.m_boss = boss;
    this.UpdateHealthValue(GameInstance.GetStatPoolsSystem(this.m_boss.GetGame()).GetStatPoolValue(Cast(this.m_boss.GetEntityID()), gamedataStatPoolType.Health));
    GameInstance.GetStatPoolsSystem(this.m_boss.GetGame()).RequestRegisteringListener(Cast(this.m_boss.GetEntityID()), gamedataStatPoolType.Health, this.m_statListener);
    characterRecord = TweakDBInterface.GetCharacterRecord(this.m_boss.GetRecordID());
    if IsNameValid(characterRecord.FullDisplayName()) {
      NPCName = LocKeyToString(characterRecord.FullDisplayName());
    } else {
      NPCName = this.m_boss.GetDisplayName();
    };
    inkTextRef.SetText(this.m_bossName, NPCName);
  }

  private final func UnregisterPreviousBoss() -> Void {
    if !IsDefined(this.m_boss) {
      return;
    };
    GameInstance.GetStatPoolsSystem(this.m_boss.GetGame()).RequestUnregisteringListener(Cast(this.m_boss.GetEntityID()), gamedataStatPoolType.Health, this.m_statListener);
    this.m_boss = null;
  }

  public final static func ReevaluateBossHealthBar(puppet: wref<NPCPuppet>, target: wref<GameObject>, opt combatEnded: Bool) -> Void {
    let bossCombatEvent: ref<BossCombatNotifier>;
    if !IsDefined(puppet) || !puppet.IsBoss() || !IsDefined(target) || !target.IsPlayer() {
      return;
    };
    bossCombatEvent = new BossCombatNotifier();
    bossCombatEvent.bossEntity = puppet;
    bossCombatEvent.combatEnded = combatEnded;
    target.QueueEvent(bossCombatEvent);
  }

  public final static func ReevaluateBossHealthBar(puppet: wref<NPCPuppet>, targetTracker: wref<TargetTrackingExtension>, opt combatEnded: Bool) -> Void {
    let bossCombatEvent: ref<BossCombatNotifier>;
    let hostileThreats: array<TrackedLocation>;
    let target: wref<GameObject>;
    if !IsDefined(puppet) || !puppet.IsBoss() || !IsDefined(targetTracker) {
      return;
    };
    hostileThreats = targetTracker.GetHostileThreats(false);
    if ArraySize(hostileThreats) > 0 && TargetTrackingExtension.GetPlayerFromThreats(hostileThreats, target) {
      bossCombatEvent = new BossCombatNotifier();
      bossCombatEvent.bossEntity = puppet;
      bossCombatEvent.combatEnded = combatEnded;
      target.QueueEvent(bossCombatEvent);
    };
  }
}

public class BossHealthStatListener extends ScriptStatPoolsListener {

  private let m_healthbar: wref<BossHealthBarGameController>;

  public final func BindHealthbar(bar: wref<BossHealthBarGameController>) -> Void {
    this.m_healthbar = bar;
  }

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.m_healthbar.UpdateHealthValue(newValue);
  }
}
