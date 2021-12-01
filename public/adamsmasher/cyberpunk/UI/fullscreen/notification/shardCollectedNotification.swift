
public class ShardCollectedInventoryCallback extends InventoryScriptCallback {

  public let m_notificationQueue: wref<JournalNotificationQueue>;

  public let m_journalManager: wref<JournalManager>;

  public func OnItemQuantityChanged(item: ItemID, diff: Int32, total: Uint32, flaggedAsSilent: Bool) -> Void {
    let effect: wref<TriggerHackingMinigameEffector_Record>;
    let entryString: String;
    let journalEntry: wref<JournalOnscreen>;
    let journalHash: Int32;
    if diff < 1 {
      return;
    };
    if Equals(RPGManager.GetItemType(item), gamedataItemType.Gen_Readable) {
      entryString = ReadAction.GetJournalEntryFromAction(ItemActionsHelper.GetReadAction(item).GetID());
      journalEntry = this.m_journalManager.GetEntryByString(entryString, "gameJournalOnscreen") as JournalOnscreen;
      journalHash = this.m_journalManager.GetEntryHash(journalEntry);
      if this.m_journalManager.IsAttachedToAnyActiveQuest(journalHash) {
        this.OpenShardPopup(journalEntry, item, false);
      } else {
        this.m_notificationQueue.PushNotification(journalEntry);
      };
    } else {
      if IsDefined(ItemActionsHelper.GetCrackAction(item)) {
        effect = (ItemActionsHelper.GetCrackAction(item) as CrackAction_Record).Effector() as TriggerHackingMinigameEffector_Record;
        if IsDefined(effect) {
          entryString = effect.JournalEntry();
          if IsStringValid(entryString) {
            journalEntry = this.m_journalManager.GetEntryByString(entryString, "gameJournalOnscreen") as JournalOnscreen;
            journalHash = this.m_journalManager.GetEntryHash(journalEntry);
            if this.m_journalManager.IsAttachedToAnyActiveQuest(journalHash) {
              this.OpenShardPopup(journalEntry, item, true);
            } else {
              this.m_notificationQueue.PushCrackableNotification(item, journalEntry);
            };
          };
        };
      };
    };
  }

  private final func OpenShardPopup(entry: ref<JournalOnscreen>, item: ItemID, isCrypted: Bool) -> Void {
    let evt: ref<NotifyShardRead> = new NotifyShardRead();
    evt.title = GetLocalizedText(entry.GetTitle());
    evt.text = entry.GetDescription();
    evt.entry = entry;
    evt.isCrypted = isCrypted;
    evt.itemID = item;
    this.m_notificationQueue.QueueBroadcastEvent(evt);
  }
}

public class ShardCollectedNotificationViewData extends GenericNotificationViewData {

  public let entry: ref<JournalOnscreen>;

  public let isCrypted: Bool;

  public let itemID: ItemID;

  public let shardTitle: String;

  public func CanMerge(data: ref<GenericNotificationViewData>) -> Bool {
    let compareTo: ref<ShardCollectedNotificationViewData> = data as ShardCollectedNotificationViewData;
    return Equals(compareTo.shardTitle, this.shardTitle);
  }
}

public class ShardCollectedNotification extends GenericNotificationController {

  private edit let m_shardTitle: inkTextRef;

  public func SetNotificationData(notificationData: ref<GenericNotificationViewData>) -> Void {
    let data: ref<ShardCollectedNotificationViewData> = notificationData as ShardCollectedNotificationViewData;
    inkTextRef.SetText(this.m_shardTitle, data.shardTitle);
    this.PlayLibraryAnimation(n"notification_shard");
    this.SetNotificationData(notificationData);
  }
}
