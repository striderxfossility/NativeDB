
public class DataTrackingSystem extends ScriptableSystem {

  protected persistent let m_achievementsMask: array<Bool>;

  protected persistent let m_rangedAttacksMade: Int32;

  protected persistent let m_meleeAttacksMade: Int32;

  protected persistent let m_meleeKills: Int32;

  protected persistent let m_rangedKills: Int32;

  protected persistent let m_quickhacksMade: Int32;

  protected persistent let m_distractionsMade: Int32;

  protected persistent let m_legendaryItemsCrafted: Int32;

  protected persistent let m_npcMeleeLightAttackReceived: Int32;

  protected persistent let m_npcMeleeStrongAttackReceived: Int32;

  protected persistent let m_npcMeleeBlockAttackReceived: Int32;

  protected persistent let m_npcMeleeBlockedAttacks: Int32;

  protected persistent let m_npcMeleeDeflectedAttacks: Int32;

  protected persistent let m_downedEnemies: Int32;

  protected persistent let m_killedEnemies: Int32;

  protected persistent let m_defeatedEnemies: Int32;

  protected persistent let m_incapacitatedEnemies: Int32;

  protected persistent let m_finishedEnemies: Int32;

  protected persistent let m_downedWithRanged: Int32;

  protected persistent let m_downedWithMelee: Int32;

  protected persistent let m_downedInTimeDilatation: Int32;

  protected persistent let m_rangedProgress: Int32;

  protected persistent let m_meleeProgress: Int32;

  protected persistent let m_dilationProgress: Int32;

  protected persistent let m_failedShardDrops: Float;

  protected persistent let m_bluelinesUseCount: Int32;

  private let m_twoHeadssourceID: EntityID;

  private let m_twoHeadsValidTimestamp: Float;

  private let m_lastKillTimestamp: Float;

  private let m_enemiesKilledInTimeInterval: array<wref<GameObject>>;

  @default(DataTrackingSystem, 5f)
  private let m_timeInterval: Float;

  @default(DataTrackingSystem, 3f)
  private let m_numerOfKillsRequired: Int32;

  private let m_gunKataKilledEnemies: Int32;

  private let m_gunKataValidTimestamp: Float;

  private let m_hardKneesInProgress: Bool;

  private let m_hardKneesKilledEnemies: Int32;

  private let m_harKneesValidTimestamp: Float;

  private let m_resetKilledReqDelayID: DelayID;

  private let m_resetFinishedReqDelayID: DelayID;

  private let m_resetDefeatedReqDelayID: DelayID;

  private let m_resetIncapacitatedReqDelayID: DelayID;

  private let m_resetDownedReqDelayID: DelayID;

  private let m_resetMeleeAttackReqDelayID: DelayID;

  private let m_resetRangedAttackReqDelayID: DelayID;

  private let m_resetAttackReqDelayID: DelayID;

  private let m_resetNpcMeleeLightAttackReqDelayID: DelayID;

  private let m_resetNpcMeleeStrongAttackReqDelayID: DelayID;

  private let m_resetNpcMeleeFinalAttackReqDelayID: DelayID;

  private let m_resetNpcMeleeBlockAttackReqDelayID: DelayID;

  private let m_resetNpcBlockedReqDelayID: DelayID;

  private let m_resetNpcDeflectedReqDelayID: DelayID;

  private let m_resetNpcGuardbreakReqDelayID: DelayID;

  private func OnAttach() -> Void {
    let i: Int32;
    let size: Int32 = EnumInt(gamedataAchievement.Count);
    if ArraySize(this.m_achievementsMask) > 0 {
      return;
    };
    i = 0;
    while i < size {
      ArrayPush(this.m_achievementsMask, false);
      i += 1;
    };
  }

  private func OnDetach() -> Void;

  private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void;

  private final func AddFlag(achievement: gamedataAchievement) -> Void {
    this.m_achievementsMask[EnumInt(achievement)] = true;
  }

  private final func GetNameFromDataTrackingFactEnum(dataTrackingFact: ETelemetryData) -> CName {
    return EnumValueToName(n"EDataTrackingFact", Cast(EnumInt(dataTrackingFact)));
  }

  private final func GetCountFromDataTrackingFactEnum(dataTrackingFact: ETelemetryData) -> Int32 {
    return GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(this.GetNameFromDataTrackingFactEnum(dataTrackingFact));
  }

  private final func OnModifyTelemetryVariable(request: ref<ModifyTelemetryVariable>) -> Void {
    switch request.dataTrackingFact {
      case ETelemetryData.MeleeAttacksMade:
        this.m_meleeAttacksMade += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_player_melee_attacks", this.m_meleeAttacksMade);
        SetFactValue(this.GetGameInstance(), n"gmpl_player_melee_attack", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetMeleeAttackReqDelayID);
        this.m_resetMeleeAttackReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetMeleeAttackDelayedRequest(), 1.00);
        break;
      case ETelemetryData.RangedAttacksMade:
        this.m_rangedAttacksMade += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_player_range_attacks", this.m_rangedAttacksMade);
        SetFactValue(this.GetGameInstance(), n"gmpl_player_range_attack", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetRangedAttackReqDelayID);
        this.m_resetRangedAttackReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetRangedAttackDelayedRequest(), 1.00);
        break;
      case ETelemetryData.BluelinesSelected:
        this.m_bluelinesUseCount += request.value;
        if !this.IsAchievementUnlocked(gamedataAchievement.Roleplayer) {
          this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.Roleplayer), this.m_bluelinesUseCount, 10);
        };
        this.ProcessIntCompareAchievement(gamedataAchievement.Roleplayer, this.m_bluelinesUseCount, 10);
        break;
      case ETelemetryData.QuickHacksMade:
        this.m_quickhacksMade += request.value;
        if !this.IsAchievementUnlocked(gamedataAchievement.MustBeTheRats) {
          this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.MustBeTheRats), this.m_quickhacksMade, 30);
        };
        this.ProcessIntCompareAchievement(gamedataAchievement.MustBeTheRats, this.m_quickhacksMade, 30);
        SetFactValue(this.GetGameInstance(), n"gmpl_player_quickhacks", this.m_quickhacksMade);
        SetFactValue(this.GetGameInstance(), n"gmpl_player_quickhack", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetAttackReqDelayID);
        this.m_resetAttackReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetAttackDelayedRequest(), 1.00);
    };
    if NotEquals(request.dataTrackingFact, ETelemetryData.QuickHacksMade) {
      SetFactValue(this.GetGameInstance(), n"gmpl_player_attacks", this.m_meleeAttacksMade + this.m_rangedAttacksMade + this.m_quickhacksMade);
      SetFactValue(this.GetGameInstance(), n"gmpl_player_attack", 1);
      GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetKilledReqDelayID);
      this.m_resetKilledReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCKilledDelayedRequest(), 1.00);
    };
    this.ProcessTutorialFact(request.dataTrackingFact);
  }

  private final func OnModifyNPCTelemetryVariable(request: ref<ModifyNPCTelemetryVariable>) -> Void {
    switch request.dataTrackingFact {
      case ENPCTelemetryData.HitByLightAttack:
        this.m_npcMeleeLightAttackReceived += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_lights", GetFact(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_lights") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.HitByStrongAttack:
        this.m_npcMeleeStrongAttackReceived += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_strongs", GetFact(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_strongs") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.HitByFinalComboAttack:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_combofinal", GetFact(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_combofinal") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.HitByBlockAttack:
        this.m_npcMeleeBlockAttackReceived += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_blockattacks", GetFact(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_blockattacks") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.BlockedAttack:
        this.m_npcMeleeBlockedAttacks += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_blocked_attacks", GetFact(this.GetGameInstance(), n"gmpl_npc_blocked_attacks") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.DeflectedAttack:
        this.m_npcMeleeDeflectedAttacks += request.value;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_deflected_attacks", GetFact(this.GetGameInstance(), n"gmpl_npc_deflected_attacks") + 1);
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 1);
        break;
      case ENPCTelemetryData.WasGuardBreaked:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_guardbreak", GetFact(this.GetGameInstance(), n"gmpl_npc_guardbreak") + 1);
    };
  }

  private final func ProcessTutorialFact(telemetryData: ETelemetryData) -> Void {
    switch telemetryData {
      case ETelemetryData.MeleeAttacksMade:
        if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"melee_combat_tutorial") == 0 && GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"disable_tutorials") == 0 {
          GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"melee_combat_tutorial", 1);
        };
        break;
      case ETelemetryData.RangedAttacksMade:
        if GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"ranged_combat_tutorial") == 0 && GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"block_combat_scripts_tutorials") == 0 && GameInstance.GetQuestsSystem(this.GetGameInstance()).GetFact(n"disable_tutorials") == 0 {
          GameInstance.GetQuestsSystem(this.GetGameInstance()).SetFact(n"ranged_combat_tutorial", 1);
        };
    };
  }

  private final func OnAddAchievementRequest(request: ref<AddAchievementRequest>) -> Void {
    this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(request.achievement));
  }

  private final func OnSetAchievementProgressRequest(request: ref<SetAchievementProgressRequest>) -> Void {
    this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(request.achievement), request.currentValue, request.maxValue);
  }

  private final func UnlockAchievement(achievementRecord: wref<Achievement_Record>) -> Void {
    this.AddFlag(achievementRecord.Type());
    GameInstance.GetAchievementSystem(this.GetGameInstance()).UnlockAchievement(achievementRecord);
  }

  private final func SetAchievementProgress(achievementRecord: wref<Achievement_Record>, currentValue: Int32, maxValue: Int32) -> Void {
    let completion: Float = Cast(currentValue) / Cast(maxValue) * 100.00;
    GameInstance.GetAchievementSystem(this.GetGameInstance()).SetAchievementProgress(achievementRecord, completion);
  }

  private final func OnBluelineSelectedRequest(request: ref<BluelineSelectedRequest>) -> Void {
    let mtvRequest: ref<ModifyTelemetryVariable> = new ModifyTelemetryVariable();
    mtvRequest.dataTrackingFact = ETelemetryData.BluelinesSelected;
    this.QueueRequest(mtvRequest);
  }

  private final func OnSendItemCraftedDataTrackingRequest(request: ref<ItemCraftedDataTrackingRequest>) -> Void {
    if !this.IsAchievementUnlocked(gamedataAchievement.HandyMan) {
      this.ProcessHandyManAchievement(request.targetItem);
    };
  }

  private final func ProcessHandyManAchievement(targetItem: ItemID) -> Void {
    let gameInstance: GameInstance = this.GetGameInstance();
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(gameInstance);
    let itemdata: wref<gameItemData> = transactionSystem.GetItemData(GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject(), targetItem);
    if !itemdata.HasStatData(gamedataStatType.Quality) {
      return;
    };
    if itemdata.GetStatValueByType(gamedataStatType.Quality) >= Cast(TweakDBInterface.GetQualityRecord(t"Quality.Legendary").Value()) {
      this.m_legendaryItemsCrafted += 1;
      this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.HandyMan), this.m_legendaryItemsCrafted, 3);
      if this.m_legendaryItemsCrafted == 3 {
        this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.HandyMan));
      };
    };
  }

  private final func ProcessBreathtakingAchievement() -> Void {
    let achievement: gamedataAchievement;
    let i: Int32;
    let size: Int32;
    if this.IsAchievementUnlocked(gamedataAchievement.Breathtaking) {
      return;
    };
    size = EnumInt(gamedataAchievement.Count);
    i = 0;
    while i < size {
      achievement = IntEnum(i);
      if !this.IsAchievementUnlocked(achievement) && NotEquals(achievement, gamedataAchievement.Breathtaking) {
        return;
      };
      i += 1;
    };
    this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(achievement));
  }

  private final func IsSourcePlayer(attackData: ref<AttackData>) -> Bool {
    return IsDefined(attackData.GetInstigator() as PlayerPuppet);
  }

  private final func CheckTimeDilationSources() -> Bool {
    let timeSystem: ref<TimeSystem> = GameInstance.GetTimeSystem(this.GetGameInstance());
    return timeSystem.IsTimeDilationActive(n"sandevistan") || timeSystem.IsTimeDilationActive(n"kereznikov");
  }

  private final func OnNPCKillDataTrackingRequest(request: ref<NPCKillDataTrackingRequest>) -> Void {
    let attackRecord: ref<Attack_GameEffect_Record> = request.damageEntry.hitEvent.attackData.GetAttackDefinition().GetRecord() as Attack_GameEffect_Record;
    if !request.isDownedRecorded {
      this.m_downedEnemies += 1;
      if this.CheckTimeDilationSources() && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
        this.m_downedInTimeDilatation += 1;
        if !this.IsAchievementUnlocked(gamedataAchievement.MaxPain) {
          this.m_dilationProgress += 1;
          if this.m_dilationProgress >= 2 {
            this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.MaxPain), this.m_downedInTimeDilatation, 50);
            this.m_dilationProgress = 0;
          };
        };
        this.ProcessIntCompareAchievement(gamedataAchievement.MaxPain, this.m_downedInTimeDilatation, 50);
      };
      if AttackData.IsMelee(request.damageEntry.hitEvent.attackData.GetAttackType()) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
        this.m_downedWithMelee += 1;
        if !this.IsAchievementUnlocked(gamedataAchievement.TrueWarrior) {
          this.m_meleeProgress += 1;
          if this.m_meleeProgress >= 4 {
            this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.TrueWarrior), this.m_downedWithMelee, 100);
            this.m_meleeProgress = 0;
          };
        };
        this.ProcessIntCompareAchievement(gamedataAchievement.TrueWarrior, this.m_downedWithMelee, 100);
      } else {
        if AttackData.IsBullet(request.damageEntry.hitEvent.attackData.GetAttackType()) && this.IsSourcePlayer(request.damageEntry.hitEvent.attackData) {
          this.m_downedWithRanged += 1;
          if !this.IsAchievementUnlocked(gamedataAchievement.TrueSoldier) {
            this.m_rangedProgress += 1;
            if this.m_rangedProgress >= 5 {
              this.SetAchievementProgress(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.TrueSoldier), this.m_downedWithRanged, 300);
              this.m_rangedProgress = 0;
            };
            this.ProcessIntCompareAchievement(gamedataAchievement.TrueSoldier, this.m_downedWithRanged, 300);
          };
          this.ProcessTwoHeadsOneBulletAchievement(request);
          this.ProcessGunKataAchievement(request);
        } else {
          if Equals(attackRecord.EffectName(), n"superheroLanding") {
            this.ProcessHardForKneesAchievement();
          };
        };
      };
      if request.damageEntry.hitEvent.attackData.HasFlag(hitFlag.GrenadeQuickhackExplosion) {
        this.ProcessNotTheMobileAchievement(request.damageEntry);
      };
    };
    switch request.eventType {
      case EDownedType.Killed:
        this.m_killedEnemies += 1;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetKilledReqDelayID);
        this.m_resetKilledReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCKilledDelayedRequest(), 1.00);
        break;
      case EDownedType.Finished:
        this.m_finishedEnemies += 1;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_finished_by_player", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetFinishedReqDelayID);
        this.m_resetFinishedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCFinishedDelayedRequest(), 1.00);
        break;
      case EDownedType.Defeated:
        this.m_defeatedEnemies += 1;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_defeated_by_player", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetDefeatedReqDelayID);
        this.m_resetDefeatedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCDefeatedDelayedRequest(), 1.00);
        break;
      case EDownedType.Unconscious:
        this.m_incapacitatedEnemies += 1;
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetIncapacitatedReqDelayID);
        this.m_resetIncapacitatedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCIncapacitatedDelayedRequest(), 1.00);
    };
    GameInstance.GetDelaySystem(this.GetGameInstance()).CancelDelay(this.m_resetDownedReqDelayID);
    this.m_resetDownedReqDelayID = GameInstance.GetDelaySystem(this.GetGameInstance()).DelayScriptableSystemRequest(n"DataTrackingSystem", new ResetNPCDownedDelayedRequest(), 1.00);
    this.ProcessDataTrackingFacts();
  }

  private final func OnTakedownActionDataTrackingRequest(request: ref<TakedownActionDataTrackingRequest>) -> Void {
    switch request.eventType {
      case ETakedownActionType.Takedown:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
        this.m_killedEnemies += 1;
        break;
      case ETakedownActionType.TakedownNonLethal:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        break;
      case ETakedownActionType.TakedownNetrunner:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        break;
      case ETakedownActionType.TakedownMassiveTarget:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        break;
      case ETakedownActionType.AerialTakedown:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 1);
        this.m_incapacitatedEnemies += 1;
        break;
      case ETakedownActionType.KillTarget:
        SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 1);
        this.m_killedEnemies += 1;
    };
    this.ProcessDataTrackingFacts();
  }

  private final func ProcessDataTrackingFacts() -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npcs_killed_by_player", this.m_killedEnemies);
    SetFactValue(this.GetGameInstance(), n"gmpl_npcs_finished_by_player", this.m_finishedEnemies);
    SetFactValue(this.GetGameInstance(), n"gmpl_npcs_defeated_by_player", this.m_defeatedEnemies);
    SetFactValue(this.GetGameInstance(), n"gmpl_npcs_incapacitated_by_player", this.m_incapacitatedEnemies);
    SetFactValue(this.GetGameInstance(), n"gmpl_npcs_downed_by_player", this.m_killedEnemies + this.m_finishedEnemies + this.m_defeatedEnemies + this.m_incapacitatedEnemies);
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_downed_by_player", 1);
    if (this.m_finishedEnemies > 0 || this.m_killedEnemies > 0) && GetFact(this.GetGameInstance(), n"player_killed_npc") == 0 {
      SetFactValue(this.GetGameInstance(), n"player_killed_npc", 1);
    };
  }

  private final func ProcessNotTheMobileAchievement(damageEntry: DamageHistoryEntry) -> Void {
    let currentTime: Float;
    let i: Int32;
    if this.IsAchievementUnlocked(gamedataAchievement.NotTheMobile) {
      return;
    };
    currentTime = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
    if currentTime - this.m_lastKillTimestamp > this.m_timeInterval {
      ArrayClear(this.m_enemiesKilledInTimeInterval);
    };
    this.m_lastKillTimestamp = currentTime;
    i = 0;
    while i < ArraySize(this.m_enemiesKilledInTimeInterval) {
      if this.m_enemiesKilledInTimeInterval[i] == damageEntry.hitEvent.target {
        return;
      };
      i += 1;
    };
    ArrayPush(this.m_enemiesKilledInTimeInterval, damageEntry.hitEvent.target);
    if ArraySize(this.m_enemiesKilledInTimeInterval) >= this.m_numerOfKillsRequired {
      this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.NotTheMobile));
    };
  }

  private final func ProcessIntCompareAchievement(achievement: gamedataAchievement, trackedData: Int32, thresholdValue: Int32) -> Void {
    if !this.IsAchievementUnlocked(achievement) && trackedData >= thresholdValue {
      this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(achievement));
    };
  }

  private final func GetAchievementRecordFromGameDataAchievement(achievement: gamedataAchievement) -> wref<Achievement_Record> {
    let achievementString: String;
    if Equals(achievement, gamedataAchievement.LikeFatherLikeSon) {
      achievementString = "LikeFatherLIkeSon";
    } else {
      achievementString = EnumValueToString("gamedataAchievement", Cast(EnumInt(achievement)));
    };
    return TweakDBInterface.GetAchievementRecord(TDBID.Create("Achievements." + achievementString));
  }

  private final func ProcessTwoHeadsOneBulletAchievement(request: ref<NPCKillDataTrackingRequest>) -> Void {
    let entity: ref<Entity>;
    let damageData: DamageHistoryEntry = request.damageEntry;
    if Equals(WeaponObject.GetWeaponType(damageData.hitEvent.attackData.GetWeapon().GetItemID()), gamedataItemType.Wea_SniperRifle) {
      entity = damageData.hitEvent.attackData.GetInstigator();
      if this.m_twoHeadssourceID == entity.GetEntityID() && this.m_twoHeadsValidTimestamp >= EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) {
        if !this.IsAchievementUnlocked(gamedataAchievement.TwoHeadsOneBullet) {
          this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.TwoHeadsOneBullet));
        };
      } else {
        this.m_twoHeadssourceID = entity.GetEntityID();
        this.m_twoHeadsValidTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) + 1.00;
      };
    };
  }

  private final func ProcessGunKataAchievement(request: ref<NPCKillDataTrackingRequest>) -> Void {
    let damageData: DamageHistoryEntry = request.damageEntry;
    if (Equals(WeaponObject.GetWeaponType(damageData.hitEvent.attackData.GetWeapon().GetItemID()), gamedataItemType.Wea_Revolver) || Equals(WeaponObject.GetWeaponType(damageData.hitEvent.attackData.GetWeapon().GetItemID()), gamedataItemType.Wea_Handgun)) && Vector4.Distance(damageData.source.GetWorldPosition(), damageData.target.GetWorldPosition()) < 7.50 {
      this.m_gunKataKilledEnemies += 1;
      if this.m_gunKataValidTimestamp >= EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) {
        if !this.IsAchievementUnlocked(gamedataAchievement.GunKata) && this.m_gunKataKilledEnemies >= 3 {
          this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.GunKata));
        };
      } else {
        this.m_gunKataKilledEnemies = 1;
        this.m_gunKataValidTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) + 3.50;
      };
    };
  }

  private final func ProcessHardForKneesAchievement() -> Void {
    if this.m_hardKneesInProgress {
      this.m_hardKneesKilledEnemies += 1;
      if this.m_harKneesValidTimestamp >= EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) {
        if !this.IsAchievementUnlocked(gamedataAchievement.ThatIsSoHardForTheKnees) && this.m_hardKneesKilledEnemies >= 2 {
          this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(gamedataAchievement.ThatIsSoHardForTheKnees));
        };
      } else {
        this.m_hardKneesKilledEnemies = 0;
        this.m_hardKneesInProgress = false;
      };
    } else {
      this.m_hardKneesInProgress = true;
      this.m_hardKneesKilledEnemies += 1;
      this.m_harKneesValidTimestamp = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) + 1.00;
    };
  }

  public final const func IsAchievementUnlocked(achievement: gamedataAchievement) -> Bool {
    return this.m_achievementsMask[EnumInt(achievement)];
  }

  private final func OnUpdateShardFailedDrops(request: ref<UpdateShardFailedDropsRequest>) -> Void {
    if request.resetCounter {
      this.m_failedShardDrops = 0.00;
    } else {
      this.m_failedShardDrops += request.newFailedAttempts;
    };
  }

  public final const func GetFailedShardDrops() -> Float {
    return this.m_failedShardDrops;
  }

  private final func OnResetKilledRequest(request: ref<ResetNPCKilledDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_killed_by_player", 0);
  }

  private final func OnResetFinishedRequest(request: ref<ResetNPCFinishedDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_finished_by_player", 0);
  }

  private final func OnResetDefeatedRequest(request: ref<ResetNPCDefeatedDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_defeated_by_player", 0);
  }

  private final func OnResetIncapacitatedRequest(request: ref<ResetNPCIncapacitatedDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_incapacitated_by_player", 0);
  }

  private final func OnResetDownedRequest(request: ref<ResetNPCDownedDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_downed_by_player", 0);
  }

  private final func OnResetMeleeAttackRequest(request: ref<ResetMeleeAttackDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_player_melee_attack", 0);
  }

  private final func OnResetRangedAttackRequest(request: ref<ResetRangedAttackDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_player_range_attack", 0);
  }

  private final func OnResetQuickhackRequest(request: ref<ResetAttackDelayedRequest>) -> Void {
    SetFactValue(this.GetGameInstance(), n"gmpl_player_quickhack", 0);
  }

  private final func OnResetLightHitsReceivedRequest(request: ref<ResetLightHitsReceivedRequest>) -> Void {
    this.m_npcMeleeLightAttackReceived = 0;
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 0);
  }

  private final func OnResetStrongHitsReceivedRequest(request: ref<ResetStrongHitsReceivedRequest>) -> Void {
    this.m_npcMeleeStrongAttackReceived = 0;
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 0);
  }

  private final func OnResetFinalComboHitsReceivedRequest(request: ref<ResetFinalComboHitsReceivedRequest>) -> Void {
    this.m_npcMeleeBlockAttackReceived = 0;
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 0);
  }

  private final func OnResetBlockAttackHitsReceivedRequest(request: ref<ResetBlockAttackHitsReceivedRequest>) -> Void {
    this.m_npcMeleeBlockedAttacks = 0;
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 0);
  }

  private final func OnResetBlockedHitsRequest(request: ref<ResetBlockedHitsRequest>) -> Void {
    this.m_npcMeleeBlockedAttacks = 0;
    SetFactValue(this.GetGameInstance(), n"gmpl_npc_hit_by_melee_attack", 0);
  }

  private final func OnUnlockAllAchievementsRequest(request: ref<UnlockAllAchievementsRequest>) -> Void {
    let achievement: gamedataAchievement;
    let i: Int32 = 0;
    i;
    while i < EnumInt(gamedataAchievement.Count) {
      achievement = IntEnum(i);
      if Equals(achievement, gamedataAchievement.Breathtaking) || Equals(achievement, gamedataAchievement.Count) || Equals(achievement, gamedataAchievement.Invalid) {
      } else {
        if !this.IsAchievementUnlocked(achievement) {
          this.UnlockAchievement(this.GetAchievementRecordFromGameDataAchievement(achievement));
        };
      };
      i += 1;
    };
  }
}

public static exec func UnlockAllAchievements(gameInstance: GameInstance) -> Void {
  let evt: ref<UnlockAllAchievementsRequest> = new UnlockAllAchievementsRequest();
  let dataTrackingSystem: ref<DataTrackingSystem> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"DataTrackingSystem") as DataTrackingSystem;
  dataTrackingSystem.QueueRequest(evt);
}

public static exec func UnlockAchievementEnum(gameInstance: GameInstance, achievementString: String) -> Void {
  let dataTrackingSystem: ref<DataTrackingSystem>;
  let evt: ref<AddAchievementRequest> = new AddAchievementRequest();
  let i: Int32 = Cast(EnumValueFromString("gamedataAchievement", achievementString));
  if i >= 0 && i < EnumInt(gamedataAchievement.Count) {
    evt.achievement = IntEnum(i);
    dataTrackingSystem = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"DataTrackingSystem") as DataTrackingSystem;
    dataTrackingSystem.QueueRequest(evt);
  };
}

public static exec func UnlockAchievementInt(gameInstance: GameInstance, achievementNum: String) -> Void {
  let dataTrackingSystem: ref<DataTrackingSystem>;
  let gdAchievement: gamedataAchievement;
  let evt: ref<AddAchievementRequest> = new AddAchievementRequest();
  let i: Int32 = StringToInt(achievementNum);
  if i >= 0 && i < EnumInt(gamedataAchievement.Count) {
    gdAchievement = IntEnum(i);
    evt.achievement = gdAchievement;
    dataTrackingSystem = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"DataTrackingSystem") as DataTrackingSystem;
    dataTrackingSystem.QueueRequest(evt);
  };
}
