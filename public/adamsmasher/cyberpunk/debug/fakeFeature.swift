
public class FakeFeature extends GameObject {

  private const let m_choices: array<SFakeFeatureChoice>;

  protected let m_interaction: ref<InteractionComponent>;

  private let m_components: array<ref<IPlacedComponent>>;

  private let m_scaningComponent: ref<ScanningComponent>;

  @default(FakeFeature, false)
  private let was_used: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    let i: Int32;
    let k: Int32;
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"gameinteractionsComponent", false);
    EntityRequestComponentsInterface.RequestComponent(ri, n"scanning", n"gameScanningComponent", false);
    i = 0;
    while i < ArraySize(this.m_choices) {
      k = 0;
      while k < ArraySize(this.m_choices[i].affectedComponents) {
        EntityRequestComponentsInterface.RequestComponent(ri, this.m_choices[i].affectedComponents[k].componentName, n"IPlacedComponent", false);
        k += 1;
      };
      i += 1;
    };
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let k: Int32;
    this.m_interaction = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
    this.m_scaningComponent = EntityResolveComponentsInterface.GetComponent(ri, n"scanning") as ScanningComponent;
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      k = 0;
      while k < ArraySize(this.m_choices[i].affectedComponents) {
        ArrayPush(this.m_components, EntityResolveComponentsInterface.GetComponent(ri, this.m_choices[i].affectedComponents[k].componentName) as IPlacedComponent);
        k += 1;
      };
      i += 1;
    };
    super.OnTakeControl(ri);
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.InitializeChoices();
    this.RefreshChoices();
  }

  protected cb func OnDetach() -> Bool {
    super.OnDetach();
    this.UnInitializeChoices();
  }

  protected cb func OnInteractionChoice(choiceEvent: ref<InteractionChoiceEvent>) -> Bool {
    let choiceID: Int32 = FromVariant(choiceEvent.choice.data[0]);
    this.ResolveChoice(choiceID);
    this.RefreshChoices();
  }

  protected cb func OnEnabledFactChangeTrigerred(evt: ref<FactChangedEvent>) -> Bool {
    let isEnabled: Bool;
    let factName: CName = evt.GetFactName();
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      if Equals(factName, this.m_choices[i].factToEnableName) {
        isEnabled = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(this.m_choices[i].factToEnableName) > 0;
        this.m_choices[i].isEnabled = isEnabled;
      };
      i += 1;
    };
    this.RefreshChoices();
  }

  private final func RefreshChoices() -> Void {
    let choices: array<InteractionChoice>;
    let i: Int32;
    this.m_interaction.ResetChoices();
    i = 0;
    while i < ArraySize(this.m_choices) {
      if this.m_choices[i].isEnabled {
        ArrayPush(choices, this.CreateChoice(this.m_choices[i].choiceID, i));
      };
      i += 1;
    };
    this.m_interaction.SetChoices(choices);
  }

  private final func InitializeChoices() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      if IsNameValid(this.m_choices[i].factToEnableName) {
        this.m_choices[i].callbackID = GameInstance.GetQuestsSystem(this.GetGame()).RegisterEntity(this.m_choices[i].factToEnableName, this.GetEntityID());
      };
      i += 1;
    };
  }

  private final func UnInitializeChoices() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices) {
      if IsNameValid(this.m_choices[i].factToEnableName) {
        GameInstance.GetQuestsSystem(this.GetGame()).UnregisterEntity(this.m_choices[i].factToEnableName, this.m_choices[i].callbackID);
      };
      i += 1;
    };
  }

  private final func CreateChoice(choiceID: String, data: Int32) -> InteractionChoice {
    let choice: InteractionChoice;
    choice.choiceMetaData.tweakDBName = choiceID;
    ArrayPush(choice.data, ToVariant(data));
    return choice;
  }

  private final func ResolveChoice(choiceID: Int32) -> Void {
    let i: Int32;
    if this.m_choices[choiceID].disableOnUse {
      if IsNameValid(this.m_choices[choiceID].factToEnableName) {
        SetFactValue(this.GetGame(), this.m_choices[choiceID].factToEnableName, 0);
      };
      this.m_choices[choiceID].isEnabled = false;
    };
    this.ResolveFact(this.m_choices[choiceID].factOnUse);
    i = 0;
    while i < ArraySize(this.m_choices[choiceID].factsOnUse) {
      this.ResolveFact(this.m_choices[choiceID].factsOnUse[i]);
      i += 1;
    };
    this.ResolveComponents(choiceID);
  }

  private final func ResolveFact(factData: SFactOperationData) -> Void {
    this.was_used = true;
    let uiBlackboard: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
    uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, false);
    if IsNameValid(factData.factName) {
      if Equals(factData.operationType, EMathOperationType.Add) {
        AddFact(this.GetGame(), factData.factName, factData.factValue);
      } else {
        SetFactValue(this.GetGame(), factData.factName, factData.factValue);
      };
    };
  }

  private final func ResolveComponents(choiceID: Int32) -> Void {
    let k: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.m_choices[choiceID].affectedComponents) {
      k = 0;
      while k < ArraySize(this.m_components) {
        if Equals(this.m_choices[choiceID].affectedComponents[i].componentName, this.m_components[k].GetName()) {
          if Equals(this.m_choices[choiceID].affectedComponents[i].operationType, EComponentOperation.Enable) {
            this.m_components[k].Toggle(true);
          } else {
            this.m_components[k].Toggle(false);
          };
        };
        k += 1;
      };
      i += 1;
    };
  }

  protected cb func OnItemTooltip(evt: ref<InteractionActivationEvent>) -> Bool {
    let show: Bool;
    let uiBlackboard: ref<IBlackboard>;
    if evt.activator.IsPlayer() && !evt.hotspot.IsNPC() {
      if Equals(evt.hotspot.GetDisplayName(), "q001_take_gun") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.w_power_corp_handgun_11101_a"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
      if Equals(evt.hotspot.GetDisplayName(), "q001_take_katana") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.w_melee_001__katana_a"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
      if Equals(evt.hotspot.GetDisplayName(), "q003_smartrifle_container") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.w_smart_corp_rifle_21301_a"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
      if Equals(evt.hotspot.GetDisplayName(), "q001_get_dressed") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.q003_jacket"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
      if Equals(evt.hotspot.GetDisplayName(), "q003_shotgun_container") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.w_smart_corp_shotgun_21201_a"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
      if Equals(evt.hotspot.GetDisplayName(), "q003_techrifle_container") && Equals(evt.layerData.tag, n"default") {
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) && !this.was_used {
          show = true;
        };
        if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_deactivate) {
          show = false;
        };
        uiBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).Get(GetAllBlackboardDefs().UI_HudTooltip);
        if IsDefined(uiBlackboard) {
          uiBlackboard.SetVariant(GetAllBlackboardDefs().UI_HudTooltip.ItemId, ToVariant(t"Items.w_tech_corp_rifle_31301_a"));
          uiBlackboard.SetBool(GetAllBlackboardDefs().UI_HudTooltip.ShowTooltip, show);
        };
      };
    };
  }
}
