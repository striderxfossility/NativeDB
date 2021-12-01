
public abstract class InteractionUIBase extends inkHUDGameController {

  protected let m_InteractionsBlackboard: wref<IBlackboard>;

  protected let m_InteractionsBBDefinition: ref<UIInteractionsDef>;

  protected let m_DialogsDataListenerId: ref<CallbackHandle>;

  protected let m_DialogsActiveHubListenerId: ref<CallbackHandle>;

  protected let m_DialogsSelectedChoiceListenerId: ref<CallbackHandle>;

  protected let m_InteractionsDataListenerId: ref<CallbackHandle>;

  private let m_lootingDataListenerId: ref<CallbackHandle>;

  protected let m_AreDialogsOpen: Bool;

  protected let m_AreContactsOpen: Bool;

  protected let m_IsLootingOpen: Bool;

  protected let m_AreInteractionsOpen: Bool;

  private let m_interactionIsScrollable: Bool;

  private let m_dialogIsScrollable: Bool;

  private let m_lootingIsScrollable: Bool;

  protected cb func OnInitialize() -> Bool {
    this.m_AreDialogsOpen = false;
    this.m_AreContactsOpen = false;
    this.m_IsLootingOpen = false;
    this.m_AreInteractionsOpen = false;
    this.m_InteractionsBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UIInteractions);
    this.m_InteractionsBBDefinition = GetAllBlackboardDefs().UIInteractions;
    if IsDefined(this.m_InteractionsBlackboard) {
      this.m_DialogsDataListenerId = this.m_InteractionsBlackboard.RegisterDelayedListenerVariant(this.m_InteractionsBBDefinition.DialogChoiceHubs, this, n"OnDialogsData");
      this.m_DialogsActiveHubListenerId = this.m_InteractionsBlackboard.RegisterDelayedListenerInt(this.m_InteractionsBBDefinition.ActiveChoiceHubID, this, n"OnDialogsActivateHub");
      this.m_DialogsSelectedChoiceListenerId = this.m_InteractionsBlackboard.RegisterDelayedListenerInt(this.m_InteractionsBBDefinition.SelectedIndex, this, n"OnDialogsSelectIndex");
      this.m_lootingDataListenerId = this.m_InteractionsBlackboard.RegisterDelayedListenerVariant(this.m_InteractionsBBDefinition.LootData, this, n"OnLootingData");
      this.m_InteractionsDataListenerId = this.m_InteractionsBlackboard.RegisterDelayedListenerVariant(this.m_InteractionsBBDefinition.InteractionChoiceHub, this, n"OnInteractionData");
      this.OnDialogsData(this.m_InteractionsBlackboard.GetVariant(this.m_InteractionsBBDefinition.DialogChoiceHubs));
      this.OnDialogsActivateHub(this.m_InteractionsBlackboard.GetInt(this.m_InteractionsBBDefinition.ActiveChoiceHubID));
      this.OnDialogsSelectIndex(this.m_InteractionsBlackboard.GetInt(this.m_InteractionsBBDefinition.SelectedIndex));
    };
    this.OnInteractionsChanged();
  }

  protected cb func OnUninitialize() -> Bool {
    if IsDefined(this.m_InteractionsBlackboard) {
      this.m_InteractionsBlackboard.UnregisterDelayedListener(this.m_InteractionsBBDefinition.DialogChoiceHubs, this.m_DialogsDataListenerId);
      this.m_InteractionsBlackboard.UnregisterDelayedListener(this.m_InteractionsBBDefinition.ActiveChoiceHubID, this.m_DialogsActiveHubListenerId);
      this.m_InteractionsBlackboard.UnregisterDelayedListener(this.m_InteractionsBBDefinition.SelectedIndex, this.m_DialogsSelectedChoiceListenerId);
      this.m_InteractionsBlackboard.UnregisterDelayedListener(this.m_InteractionsBBDefinition.InteractionChoiceHub, this.m_InteractionsDataListenerId);
      this.m_InteractionsBlackboard.UnregisterDelayedListener(this.m_InteractionsBBDefinition.LootData, this.m_lootingDataListenerId);
    };
  }

  protected cb func OnDialogsData(value: Variant) -> Bool {
    let data: DialogChoiceHubs = FromVariant(value);
    this.m_AreDialogsOpen = ArraySize(data.choiceHubs) > 0;
    this.m_dialogIsScrollable = ArraySize(data.choiceHubs) > 1;
    this.UpdateDialogsData(data);
    this.OnInteractionsChanged();
    this.UpdateListBlackboard();
  }

  protected cb func OnLootingData(value: Variant) -> Bool {
    let data: LootData = FromVariant(value);
    this.m_lootingIsScrollable = data.isActive && ArraySize(data.choices) > 1;
    this.UpdateListBlackboard();
  }

  protected func UpdateDialogsData(data: DialogChoiceHubs) -> Void {
    this.OnInteractionsChanged();
  }

  protected cb func OnDialogsActivateHub(activeHubId: Int32) -> Bool {
    this.OnInteractionsChanged();
  }

  protected cb func OnDialogsSelectIndex(index: Int32) -> Bool {
    this.OnInteractionsChanged();
  }

  protected cb func OnInteractionData(value: Variant) -> Bool {
    let data: InteractionChoiceHubData = FromVariant(value);
    this.m_AreInteractionsOpen = data.active;
    this.m_interactionIsScrollable = data.active && ArraySize(data.choices) > 1;
    this.UpdateInteractionData(data);
    this.OnInteractionsChanged();
    this.UpdateListBlackboard();
  }

  protected func UpdateInteractionData(data: InteractionChoiceHubData) -> Void {
    this.OnInteractionsChanged();
  }

  protected func OnInteractionsChanged() -> Void;

  private final func UpdateListBlackboard() -> Void {
    this.m_InteractionsBlackboard.SetBool(this.m_InteractionsBBDefinition.HasScrollableInteraction, this.m_interactionIsScrollable || this.m_dialogIsScrollable || this.m_lootingIsScrollable);
  }
}
