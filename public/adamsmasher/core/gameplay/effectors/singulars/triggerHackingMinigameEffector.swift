
public class TriggerHackingMinigameEffector extends Effector {

  public let m_owner: wref<GameObject>;

  public let m_listener: ref<CallbackHandle>;

  public let m_item: ItemID;

  public let m_reward: TweakDBID;

  public let m_journalEntry: String;

  public let m_fact: CName;

  public let m_factValue: Int32;

  public let m_showPopup: Bool;

  public let m_returnToJournal: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_item = ItemID.FromTDBID(parentRecord);
    this.m_reward = TweakDBInterface.GetTriggerHackingMinigameEffectorRecord(record).Reward().GetID();
    this.m_journalEntry = TweakDBInterface.GetString(record + t".journalEntry", "");
    this.m_fact = TweakDBInterface.GetCName(record + t".factName", n"");
    this.m_factValue = TweakDBInterface.GetInt(record + t".factValue", 0);
    this.m_showPopup = TweakDBInterface.GetBool(record + t".showPopup", false);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().NetworkBlackboard);
    bb.SetString(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, "");
    bb.SetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach, false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().NetworkBlackboard);
    bb.SetString(GetAllBlackboardDefs().NetworkBlackboard.NetworkName, ToString(TDBID.ToNumber(ItemID.GetTDBID(this.m_item))));
    bb.SetVariant(GetAllBlackboardDefs().NetworkBlackboard.NetworkTDBID, ToVariant(ItemID.GetTDBID(this.m_item)));
    bb.SetBool(GetAllBlackboardDefs().NetworkBlackboard.ItemBreach, true);
    this.m_returnToJournal = GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame).GetBool(GetAllBlackboardDefs().HackingMinigame.IsJournalTarget);
    this.m_listener = GameInstance.GetBlackboardSystem(owner.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame).RegisterListenerInt(GetAllBlackboardDefs().HackingMinigame.State, this, n"OnItemCracked");
  }

  protected cb func OnItemCracked(value: Int32) -> Bool {
    let evalMinigame: ref<EvaluateMinigame>;
    if NotEquals(HackingMinigameState.InProgress, IntEnum(value)) {
      if Equals(HackingMinigameState.Succeeded, IntEnum(value)) {
        evalMinigame = new EvaluateMinigame();
        evalMinigame.minigameBB = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().HackingMinigame);
        evalMinigame.reward = this.m_reward;
        evalMinigame.journalEntry = this.m_journalEntry;
        evalMinigame.fact = this.m_fact;
        evalMinigame.factValue = this.m_factValue;
        evalMinigame.item = this.m_item;
        evalMinigame.showPopup = this.m_showPopup;
        evalMinigame.returnToJournal = this.m_returnToJournal;
        this.m_owner.QueueEvent(evalMinigame);
      } else {
        if Equals(HackingMinigameState.Failed, IntEnum(value)) {
          (this.m_owner as ScriptedPuppet).SetItemMinigameAttempted(this.m_item);
        };
      };
      GameInstance.GetEffectorSystem(this.m_owner.GetGame()).RemoveEffector(this.m_owner.GetEntityID(), this.GetRecord());
    };
  }
}
