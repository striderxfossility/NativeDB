
public static exec func DebugReward(gameInstance: GameInstance, rewardDef: String) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gameInstance);
  let tdbid: TweakDBID = TDBID.Create("QuestRewards." + rewardDef);
  let evt: ref<RewardEvent> = new RewardEvent();
  evt.rewardName = tdbid;
  player.QueueEvent(evt);
}
