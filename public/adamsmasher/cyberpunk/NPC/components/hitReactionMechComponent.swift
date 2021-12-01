
public class HitReactionMechComponent extends HitReactionComponent {

  public func EvaluateHit(newHitEvent: ref<gameHitEvent>) -> Void {
    let broadcaster: ref<StimBroadcasterComponent>;
    let hitFeedbackSound: CName;
    let wasNPCAliveBeforeProcessingHit: Bool;
    let npc: ref<NPCPuppet> = this.GetOwner() as NPCPuppet;
    if !IsDefined(npc) {
      return;
    };
    this.CacheVars(newHitEvent);
    this.GetDBParameters();
    this.GetBodyPart(newHitEvent);
    wasNPCAliveBeforeProcessingHit = this.m_isAlive;
    if !this.m_deathHasBeenPlayed {
      this.ProcessMechDeath(newHitEvent, npc);
    };
    if !IsDefined(newHitEvent) {
      if !this.m_isAlive {
        if npc.ShouldSkipDeathAnimation() {
          this.m_animHitReaction.hitType = EnumInt(IntEnum(0l));
        } else {
          this.m_animHitReaction.hitDirection = 0;
          this.m_animHitReaction.hitIntensity = 1;
          this.m_animHitReaction.hitType = EnumInt(animHitReactionType.Death);
          this.m_animHitReaction.hitBodyPart = 4;
          this.m_animHitReaction.npcMovementSpeed = 0;
          this.m_animHitReaction.npcMovementDirection = 0;
        };
        this.m_hitReactionAction.Stop();
        this.m_hitReactionAction.Setup(this.m_animHitReaction);
        this.m_hitReactionAction.Launch();
        AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"hit", this.m_animHitReaction);
      } else {
        return;
      };
    };
    if AttackData.IsBullet(newHitEvent.attackData.GetAttackType()) {
      if !this.GetHitTimerAvailability() && this.m_previousRangedHitTimeStamp != this.GetCurrentTime() && this.m_isAlive {
        return;
      };
    };
    this.SetCumulatedDamages(newHitEvent.target);
    this.SetHitSource(newHitEvent.attackData.GetAttackType());
    this.SetStance();
    this.SetHitReactionThresholds();
    this.SetHitReactionImmunities();
    this.m_reactionType = this.GetReactionType();
    if this.GetCurrentTime() <= this.m_previousHitTime + 0.09 && NotEquals(this.m_lastHitReactionPlayed, EAILastHitReactionPlayed.Twitch) && Equals(this.m_reactionType, animHitReactionType.Twitch) {
      return;
    };
    this.StoreHitData(GameObject.GetAttackAngleInInt(newHitEvent, this.m_animHitReaction.hitSource), this.m_hitIntensity, this.m_reactionType, HitShapeUserDataBase.GetHitReactionZone(this.GetHitShapeUserData()), this.m_animVariation);
    this.m_previousHitTime = this.GetCurrentTime();
    if this.m_animHitReaction.hitType == EnumInt(animHitReactionType.Twitch) {
      this.SendTwitchDataToAnimationGraph();
      broadcaster = this.m_attackData.GetSource().GetStimBroadcasterComponent();
      if IsDefined(broadcaster) {
        broadcaster.SendDrirectStimuliToTarget(this.GetOwner(), gamedataStimType.CombatHit, this.GetOwner());
      };
    } else {
      this.SendMechDataToAIBehavior(this.m_reactionType);
    };
    if AttackData.IsBullet(newHitEvent.attackData.GetAttackType()) {
      if !this.m_isAlive && wasNPCAliveBeforeProcessingHit {
        hitFeedbackSound = n"w_feedback_kill_human_body";
      };
      GameInstance.GetAudioSystem(this.GetOwner().GetGame()).Play(hitFeedbackSound);
    };
  }

  protected cb func OnForcedDeathEvent(forcedDeath: ref<ForcedDeathEvent>) -> Bool {
    super.OnForcedDeathEvent(forcedDeath);
    this.m_animHitReaction.hitDirection = 0;
    this.m_animHitReaction.hitIntensity = 1;
    this.m_animHitReaction.hitType = 7;
    this.m_animHitReaction.hitBodyPart = 4;
    this.m_animHitReaction.npcMovementSpeed = 0;
    this.m_animHitReaction.npcMovementDirection = 0;
    AnimationControllerComponent.ApplyFeatureToReplicate(this.GetOwner(), n"hit", this.m_animHitReaction);
  }

  protected final func ProcessMechDeath(hitEvent: ref<gameHitEvent>, npc: ref<NPCPuppet>) -> Bool {
    let attackData: ref<AttackData> = hitEvent.attackData;
    if ScriptedPuppet.IsAlive(npc) {
      return false;
    };
    StatusEffectHelper.RemoveStatusEffect(npc, t"BaseStatusEffect.Immortal");
    if this.DefeatedRemoveConditions(npc) {
      this.GetOwner().Record1DamageInHistory(attackData.GetInstigator());
      npc.Kill(attackData.GetInstigator());
      this.m_reactionType = animHitReactionType.Death;
      StatusEffectHelper.ApplyStatusEffect(npc, t"Minotaur.DefeatedMinotaur", npc.GetEntityID());
      this.m_isAlive = false;
      return true;
    };
    AnimationControllerComponent.PushEventToReplicate(this.GetOwner(), n"e3_2019_boss_defeated_face");
    return false;
  }
}
