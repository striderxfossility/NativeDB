
public class ReadAction extends BaseItemAction {

  public func CompleteAction(gameInstance: GameInstance) -> Void {
    let entry: wref<JournalOnscreen>;
    let entryString: String;
    let shardUIevent: ref<NotifyShardRead>;
    this.CompleteAction(gameInstance);
    entryString = this.GetJournalEntryFromAction();
    if IsStringValid(entryString) {
      GameInstance.GetJournalManager(gameInstance).ChangeEntryState(entryString, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.Notify);
      entry = GameInstance.GetJournalManager(gameInstance).GetEntryByString(entryString, "gameJournalOnscreen") as JournalOnscreen;
    };
    shardUIevent = new NotifyShardRead();
    shardUIevent.title = entry.GetTitle();
    shardUIevent.text = entry.GetDescription();
    shardUIevent.entry = entry;
    GameInstance.GetUISystem(gameInstance).QueueEvent(shardUIevent);
  }

  private final func GetJournalEntryFromAction() -> String {
    return TweakDBInterface.GetString(this.m_objectActionID + t".journalEntry", "");
  }

  public final static func GetJournalEntryFromAction(actionID: TweakDBID) -> String {
    return TweakDBInterface.GetString(actionID + t".journalEntry", "");
  }

  public func IsVisible(context: GetActionsContext, opt objectActionsCallbackController: wref<gameObjectActionsCallbackController>) -> Bool {
    return true;
  }
}
